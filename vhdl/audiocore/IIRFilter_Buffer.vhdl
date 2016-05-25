library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.audiocore_pkg.all;
use work.math_pkg.all;

entity IIRFilter_Buffer is
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

		rdy : in std_logic;
		validout : out std_logic;
		data_out : out fixpoint;
		
		validout_vor : out std_logic
	);
end IIRFilter_Buffer;

architecture behavior of IIRFilter_Buffer is
	subtype bufferpos is integer range 0 to N-1;

	signal rpos_cur, rpos_next , wpos_cur, wpos_next : bufferpos; 

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

	signal rpos_addr, wpos_addr : std_logic_vector(log2c(N)-1 downto 0);
begin
    rpos_addr <= std_logic_vector(to_unsigned(rpos_cur,log2c(N)));
    wpos_addr <= std_logic_vector(to_unsigned(wpos_cur,log2c(N)));
	ram: dp_ram
	generic map
	(
	  ADDR_WIDTH => log2c(N)
	)
	port map
	(
		clk => clk,
		address_out => rpos_addr,
		data_out => data_out,
		address_in => wpos_addr,
		wr => validin,
		data_in => data_in
	);

	------------------
	-- FIFO action --
	------------------
	fifo_action: process (validin,data_in, rpos_cur, wpos_cur, validout_cur, rdy)
	begin
		-- to avoid latches
		rpos_next <= rpos_cur;
		wpos_next <= wpos_cur;
		validout_next <= validout_cur;

		-- action at in
		if validin = '1' then
			wpos_next <= pos_plus1(wpos_cur);
		end if;

		-- action at out
		if rpos_cur /= wpos_cur and rdy = '1' then
			validout_next <= '1';
			rpos_next <= pos_plus1(rpos_cur);
			validout_vor <= '1';
		else
			validout_next <= '0';
			validout_vor <= '0';
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
			validout <= validout_next;
		end if;
	end process sync;
end behavior;
