library IEEE;
use IEEE.std_logic_1164.all;

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
		data_out : out byte
	);
end outputbuffer;

architecture behavior of outputbuffer is
	type buffer_type is array (N-1 downto 0) of byte;
	subtype bufferpos is integer range 0 to N-1;

	signal fields_cur, fields_next : buffer_type;

	signal rpos_cur, rpos_next , wpos_cur, wpos_next : bufferpos; 

	signal data_out_cur, data_out_next : byte;

	signal validout_cur, validout_next : std_logic;
	
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
	------------------
	-- FIFO action --
	------------------
	outputbuffer_action: process (validin,data_in,ready)
	begin
		-- to avoid latches
		fields_next <= fields_cur;
		rpos_next <= rpos_cur;
		wpos_next <= wpos_cur;
		data_out_next <= data_out_cur;
		validout_next <= validout_cur;

		-- action at in
		if validin = '1' then
			fields_next(wpos_cur) <= data_in;
			wpos_next <= pos_plus1(wpos_cur);
		end if;

		-- action at out
		if rpos_cur /= wpos_cur and ready = '1' then
			data_out_next <= fields_cur(rpos_cur);
			validout_next <= '1';
			rpos_next <= pos_plus1(rpos_cur);
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
			fields_cur <= (others=>(others=>'0'));
			rpos_cur <= 0;
			wpos_cur <= 0;
			data_out_cur <= (others=>'0');
			validout_cur <= '0';

		elsif rising_edge(clk) then
			-- internal
			fields_cur <= fields_next;
			rpos_cur <= rpos_next;
			wpos_cur <= wpos_next;
			data_out_cur <= data_out_next;
			validout_cur <= validout_next;
			
			-- outputs
			data_out <= data_out_next;
			validout <= validout_next;
		end if;
	end process sync;
end behavior;
