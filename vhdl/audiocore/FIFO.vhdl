library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.audiocore_pkg.all;
use work.math_pkg.all;

entity FIFO is
	generic
	(
		N: natural := 32
	);
	port 
	(
		clk : in std_logic;
		res_n : in std_logic;

		in1 : in byte;
		in2 : in byte;
		validin : in std_logic;

		validout : out std_logic;
		data_out : out byte
	);
end FIFO;

architecture behavior of FIFO is
	type buffer_type is array (N-1 downto 0) of byte;
	subtype bufferpos is integer range 0 to N-1;

	signal rpos_cur, rpos_next , wpos_cur, wpos_next : bufferpos; 

	signal data : byte;

	signal validout_cur, validout_next : std_logic;
	
	signal rpos_addr, wpos_addr, wpos_p1_addr : std_logic_vector(log2c(N)-1 downto 0);
	
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
	rpos_addr <= std_logic_vector(to_unsigned(rpos_cur,log2c(N)));
	wpos_addr <= std_logic_vector(to_unsigned(wpos_cur,log2c(N)));
	wpos_p1_addr <= std_logic_vector(to_unsigned(pos_plus1(wpos_cur),log2c(N)));
	FIFO_RAM: tp_ram
	generic map
	(
		ADDR_WIDTH => log2c(N)
	)
	port map
	(
		clk => clk,
		address_out => rpos_addr,
		data_out => data,
		address_in1 => wpos_addr,
		address_in2 => wpos_p1_addr,
		wr => validin,
		data_in1 => in1,
		data_in2 => in2
	);

	------------------
	-- FIFO action --
	------------------
	fifo_action: process (validin,in1,in2, rpos_cur, wpos_cur, validout_cur, data)
	begin
		-- to avoid latches
		rpos_next <= rpos_cur;
		wpos_next <= wpos_cur;
		validout_next <= validout_cur;

		-- action at in
		if validin = '1' then
			wpos_next <= pos_plus1(pos_plus1(wpos_cur));
		end if;

		-- action at out
		if rpos_cur /= wpos_cur then
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
			rpos_cur <= 0;
			wpos_cur <= 0;
			validout_cur <= '0';

		elsif rising_edge(clk) then
			-- internal
			rpos_cur <= rpos_next;
			wpos_cur <= wpos_next;
			validout_cur <= validout_next;
			
			-- outputs
			data_out <= data;
			validout <= validout_cur;
		end if;
	end process sync;
end behavior;
