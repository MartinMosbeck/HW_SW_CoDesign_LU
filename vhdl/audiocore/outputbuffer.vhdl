library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.math_pkg.all;

library work;
use work.audiocore_pkg.all;

entity outputbuffer is
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
		
		ready: in std_logic;
		validout : out std_logic;
		data_out : out std_logic_vector(31 downto 0)
	);
end outputbuffer;

architecture behavior of outputbuffer is
	type state is
	(
		IDLE,
		WART
	);
	signal state_cur, state_next: state;
	
	subtype bufferpos is integer range 0 to N-1;
	signal rpos_cur, rpos_next , wpos_cur, wpos_next : bufferpos; 

	signal data_out_cur, data_out_next : std_logic_vector(31 downto 0);
	signal validout_cur, validout_next : std_logic;

	signal packetcnt, packetcnt_next: integer range 0 to 255; 

	signal data_cnt_next, data_cnt_cur: integer range 0 to N-1;
	
	signal data1,data2,data3,data4: byte;
	
	signal address1_addr, address2_addr, address3_addr, address4_addr, address5_addr: std_logic_vector(log2c(N)-1 downto 0);
	
	function pos_plus1(pos : bufferpos)
		return bufferpos is
	begin
		if pos = N-1 then
			return 0;
		else
			return pos + 1;
		end if;
	end pos_plus1;
	
begin
	address1_addr <= std_logic_vector(to_unsigned(rpos_cur,log2c(N)));
	address2_addr <= std_logic_vector(to_unsigned(pos_plus1(rpos_cur),log2c(N)));
	address3_addr <= std_logic_vector(to_unsigned(pos_plus1(pos_plus1(rpos_cur)),log2c(N)));
	address4_addr <= std_logic_vector(to_unsigned(pos_plus1(pos_plus1(pos_plus1(rpos_cur))),log2c(N)));
	address5_addr <= std_logic_vector(to_unsigned(wpos_cur,log2c(N)));

	ram: qp_ram
	generic map
	(
	  ADDR_WIDTH => log2c(N),
	  DATA_WIDTH => 8
	)
	port map
	(
	clk=>clk,
	address1 => address1_addr,
	address2 => address2_addr,
	address3 => address3_addr,
	address4 => address4_addr,
	data_out1 => data1,
	data_out2 => data2,
	data_out3 => data3,
	data_out4 => data4,
	address5 => address5_addr,
	wr => validin,
	data_in => data_in
	);

	------------------
	-- FIFO action --
	------------------
	outputbuffer_action: process (validin,data_in,ready, rpos_cur, wpos_cur, data_out_cur, validout_cur, packetcnt, state_cur, data_cnt_cur)
	begin
		-- to avoid latches
		rpos_next <= rpos_cur;
		wpos_next <= wpos_cur;
		data_out_next <= data_out_cur;
		validout_next <= validout_cur;
		packetcnt_next <= packetcnt;
		data_cnt_next<=data_cnt_cur;
		state_next <= state_cur;

		if validin = '1' and data_cnt_cur > 4 and state_cur = IDLE and packetcnt /= 255 and ready = '1' then
			data_cnt_next <= data_cnt_cur - 3;
		elsif validin = '1' then
			if data_cnt_cur = N-1 then--Überlaufbehandlung: Immer aktuellste Daten vorhalten
				rpos_next <= pos_plus1(rpos_cur);
			else
				data_cnt_next <= data_cnt_cur + 1;
			end if;
		elsif data_cnt_cur > 4 and state_cur = IDLE and packetcnt /= 255 and ready = '1' then
			data_cnt_next <= data_cnt_cur - 4;
		end if;

		-- action at in
		if validin = '1' then
			wpos_next <= pos_plus1(wpos_cur);
		end if;

		-- action at out
		if data_cnt_cur > 4 and packetcnt /= 255 and ready = '1' then
			case state_cur is
				when IDLE=>
					data_out_next <= data1 & data2 & data3 & data4;
					validout_next <= '1';
					rpos_next <= pos_plus1(pos_plus1(pos_plus1(pos_plus1(rpos_cur))));
					packetcnt_next <= pos_plus1(pos_plus1(pos_plus1(pos_plus1(packetcnt))));
					state_next <= WART;
				when WART=>
					state_next <= IDLE;
			end case;
		elsif packetcnt = 255 then
			packetcnt_next <= 0;
			validout_next <= '0';
		else
			validout_next <= '0';
		end if;	

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
			data_out_cur <= (others=>'0');
			validout_cur <= '0';
			packetcnt <= 0;
			data_cnt_cur<=0;
			state_cur <= IDLE;
		elsif rising_edge(clk) then
			-- internal
			rpos_cur <= rpos_next;
			wpos_cur <= wpos_next;
			data_out_cur <= data_out_next;
			validout_cur <= validout_next;
			packetcnt <= packetcnt_next;
			data_cnt_cur <= data_cnt_next;
			state_cur <= state_next;
			
			-- outputs
			data_out <= data_out_next;
			validout <= validout_next;
		end if;
	end process sync;
end behavior;
