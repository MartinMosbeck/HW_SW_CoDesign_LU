library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.math_pkg.all;

library work;
use work.audiocore_pkg.all;

entity outputbuffer_debug is
	generic
	(
		N: natural := 32
	);
	port 
	(
		clk : in std_logic;
		res_n : in std_logic;

		data_in : in fixpoint;
		validin : in std_logic;
		
		ready: in std_logic;
		validout : out std_logic;
		data_out : out std_logic_vector(31 downto 0)
	);
end outputbuffer_debug;

architecture behavior of outputbuffer_debug is
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
	
	signal data: fixpoint;
	
	signal address_rpos, address_wpos: std_logic_vector(log2c(N)-1 downto 0);
	
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
	address_rpos <= std_logic_vector(to_unsigned(rpos_cur,log2c(N)));
	address_wpos <= std_logic_vector(to_unsigned(wpos_cur,log2c(N)));

	
	ram: dp_ram
	generic map
	(
	ADDR_WIDTH => log2c(N)
	)
	port map
	(
	clk => clk,
	address_out => address_rpos,
	data_out => data,
	address_in => address_wpos,
	wr => validin,
	data_in => data_in
	);

	------------------
	-- FIFO action --
	------------------
	outputbuffer_action: process (validin,data_in,ready, rpos_cur, wpos_cur, data_out_cur, validout_cur, packetcnt, state_cur, data)
	begin
		-- to avoid latches
		rpos_next <= rpos_cur;
		wpos_next <= wpos_cur;
		data_out_next <= data_out_cur;
		validout_next <= validout_cur;
		packetcnt_next <= packetcnt;
		state_next <= state_cur;


		-- action at in
		if validin = '1' then
			wpos_next <= pos_plus1(wpos_cur);
		end if;

		-- action at out
		if rpos_cur /= wpos_cur and packetcnt /= 255 and ready = '1' then
			case state_cur is
				when IDLE=>
					data_out_next <= std_logic_vector(data);
					validout_next <= '1';
					rpos_next <= pos_plus1(rpos_cur);
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
			state_cur <= IDLE;
		elsif rising_edge(clk) then
			-- internal
			rpos_cur <= rpos_next;
			wpos_cur <= wpos_next;
			data_out_cur <= data_out_next;
			validout_cur <= validout_next;
			packetcnt <= packetcnt_next;
			state_cur <= state_next;
			
			-- outputs
			data_out <= data_out_next;
			validout <= validout_next;
		end if;
	end process sync;
end behavior;
