library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.audiocore_pkg.all;

entity FIFO is
	port 
	(
		clk : in std_logic;
		res_n : in std_logic;

		in1 : in byte;
		in2 : in byte;
		validin : in std_logic;
		inmode : in std_logic;

		validout : out std_logic;
		data_out : out byte
	);
end FIFO;

architecture behavior of FIFO is
	type buffer_type is array (31 downto 0) of byte;
	subtype bufferpos is integer range 0 to 31;

	signal fields_cur, fields_next : buffer_type;

	signal rpos_cur, rpos_next , wpos_cur, wpos_next : bufferpos; 

	signal data_out_cur, data_out_next : byte;

	signal validout_cur, validout_next : std_logic;
	
	function pos_plus1(pos : bufferpos)
		return bufferpos is
	begin
		if pos = 31 then
			return 0;
		else
			return pos + 1;
		end if;
	end pos_plus1;
	
begin
	------------------
	-- FIFO action --
	------------------
	fifo_action: process (validin,inmode,in1,in2)
	begin
		-- to avoid latches
		fields_next <= fields_cur;
		rpos_next <= rpos_cur;
		wpos_next <= wpos_cur;
		data_out_next <= data_out_cur;
		validout_next <= validout_cur;

		-- action at in
		if validin = '1' then
			if inmode = '0' then
				fields_next(wpos_cur) <= in1;
				wpos_next <= pos_plus1(wpos_cur);
			else
				fields_next(wpos_cur) <= in1;
				fields_next(pos_plus1(wpos_cur)) <= in2;
				wpos_next <= pos_plus1(pos_plus1(wpos_cur));
			end if;
		end if;

		-- action at out
		if rpos_cur /= wpos_cur then
			data_out_next <= fields_cur(rpos_cur);
			validout_next <= '1';
			rpos_next <= pos_plus1(rpos_cur);
		else
			validout_next <= '0';
		end if;		

	end process fifo_action;

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
