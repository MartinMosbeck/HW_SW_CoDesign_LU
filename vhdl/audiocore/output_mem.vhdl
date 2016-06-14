library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.math_pkg.all;

library work;
use work.audiocore_pkg.all;

entity output_mem is
	generic
	(
		N: natural := 32
	);
	port 
	(
		clk : in std_logic;
		res_n : in std_logic;

		data_in : in byte;
		validin : in std_logic;
		
-- 		address : out std_logic_vector(15 downto 0);
-- 		chipselect : out std_logic;
-- 		read : out std_logic;
-- 		write : out std_logic;
-- 		writedata : out std_logic_vector(31 downto 0);
-- 		readdata : in std_logic_vector(31 downto 0)
		audiooutleft_data : out std_logic_vector(31 downto 0);
		audiooutleft_ready : in std_logic;
		audiooutleft_valid : out std_logic;
		
		audiooutright_data : out std_logic_vector(31 downto 0);
		audiooutright_ready : in std_logic;
		audiooutright_valid : out std_logic
	);
end output_mem;

architecture behavior of output_mem is
	type state is
	(
		IDLE,
		WART,
		WARTNOMA,
		WARTNO
	);
	signal state_cur, state_next: state;
	
	type chanstate is
	(
		LEFT,
		RIGHT
	);
	signal channel_cur, channel_next: chanstate;
	
	subtype bufferpos is integer range 0 to N-1;
	signal rpos_cur, rpos_next , wpos_cur, wpos_next : bufferpos; 
	
	signal address_wpos, address_rpos: std_logic_vector(log2c(N)-1 downto 0);
	
	function pos_plus1(pos : bufferpos)
		return bufferpos is
	begin
		if pos = N-1 then
			return 0;
		else
			return pos + 1;
		end if;
	end pos_plus1;
	
	signal free_cur, free_next : integer range -127 to 128 := 1;
	signal write_cur, write_next, read_cur, read_next, chipselect_cur, chipselect_next: std_logic;
	signal outdata: std_logic_vector(7 downto 0);
	signal address_next, address_cur: std_logic_vector(15 downto 0);
	signal validout_cur, validout_next: std_logic;
	
	signal start_flag, start_flag_next: std_logic;
	signal data_cnt_cur, data_cnt_next : bufferpos := 0;
	
begin
	address_rpos <= std_logic_vector(to_unsigned(rpos_cur,log2c(N)));
	address_wpos <= std_logic_vector(to_unsigned(wpos_cur,log2c(N)));

	ram: dp_ram_std
	generic map
	(
		ADDR_WIDTH => log2c(N),
		DATA_WIDTH => 8
	)
	port map
	(
		clk => clk,
		address_out => address_rpos,
		data_out => outdata,
		address_in => address_wpos,
		wr => validin,
		data_in => data_in
	);
	
	audiooutright_data <= outdata & x"000000";
	audiooutleft_data <= outdata & x"000000";

	------------------
	-- FIFO action --
	------------------
	outputbuffer_action: process (validin, rpos_cur, wpos_cur, state_cur, channel_cur, free_cur, address_cur, validout_cur, audiooutleft_ready, start_flag, data_cnt_cur)--readdata
	begin
		-- to avoid latches
		rpos_next <= rpos_cur;
		wpos_next <= wpos_cur;
		state_next <= state_cur;
		channel_next <= channel_cur;
		free_next <= free_cur;
		start_flag_next <= start_flag;
		data_cnt_next <= data_cnt_cur;
		
		if(data_cnt_cur > 1024) then
			start_flag_next <= '1';
		end if;

		-- action at in
		if validin = '1' then
			wpos_next <= pos_plus1(wpos_cur);
		end if;
		
		if validin = '1' and start_flag = '0' then
			data_cnt_next <= data_cnt_cur + 1;
		end if;

		-- action at out
		if wpos_cur /= rpos_cur and audiooutleft_ready = '1' and start_flag = '1' then
			case state_cur is
				when IDLE=>
					validout_next <= '1';
					state_next <= WART;
				when WART=>
					rpos_next <= pos_plus1(rpos_cur);
					state_next <= IDLE;
				when WARTNOMA =>
					state_next <= WARTNO;
				when WARTNO =>
					state_next <= IDLE;
			end case;
		else
			validout_next <= '0';
		end if;
-- 		if wpos_cur /= rpos_cur and free_cur > 0 then
-- 				write_next <= '1';
-- 				chipselect_next <= '1';
-- 				case channel_cur is
-- 					when LEFT =>
-- 						address_next <= x"0008";
-- 						channel_next <= RIGHT;
-- 					when RIGHT =>
-- 						address_next <= x"000C";
-- 						--free_next <= free_cur - 1;
-- 						rpos_next <= pos_plus1(rpos_cur);
-- 						channel_next <= LEFT;
-- 				end case;
-- 		elsif free_cur <= 0 then
-- 				chipselect_next <= '1';
-- 				read_next <= '1';
-- 				address_next <= x"0004";
-- 				case state_cur is
-- 					when IDLE =>
-- 						state_next <= WART;
-- 					when WART => 
-- 						state_next <= IDLE;
-- 						free_next <= to_integer(signed(readdata(31 downto 24)));
-- 				end case;
-- 		else
-- 			chipselect_next <= '0';
-- 			read_next <= '0';
-- 			address_next <= address_cur;
-- 			write_next <= '0';
-- 		end if;	

	end process outputbuffer_action;

	----------
	-- SYNC --
	----------
	sync: process (clk,res_n)
		
	begin
		if res_n = '0' then
			--defaults
			rpos_cur <= 0;
			wpos_cur <= 0;
			state_cur <= IDLE;
			channel_cur <= LEFT;
			read_cur <= '0';
			write_cur <= '0';
			chipselect_cur <= '0';
			address_cur <= (others => '0');
			free_cur <= 1;
			
			validout_cur <= '0';
			start_flag <= '0';
			data_cnt_cur <= 0;
		elsif rising_edge(clk) then
			-- internal
			rpos_cur <= rpos_next;
			wpos_cur <= wpos_next;
			state_cur <= state_next;
			channel_cur <= channel_next;
			read_cur <= read_next;
			write_cur <= write_next;
			chipselect_cur <= chipselect_next;
			address_cur <= address_next;
			free_cur <= free_next;
			validout_cur <= validout_next;
			start_flag <= start_flag_next;
			data_cnt_cur <= data_cnt_next;
			
			-- outputs
-- 			address <= address_cur;
-- 			chipselect <= chipselect_cur;
-- 			read <= read_cur;
-- 			write <= write_cur;
			audiooutleft_valid <= validout_next;
			audiooutright_valid <= validout_next;
		end if;
	end process sync;
end behavior;
