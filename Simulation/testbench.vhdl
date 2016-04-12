-- Load Altera libraries for this chip
library IEEE;
--LIBRARY MAXII;
use IEEE.STD_LOGIC_1164.all;
--USE MAXII.MAXII_COMPONENTS.ALL;
use ieee.numeric_std.all;
library work;
use work.audiocore_pkg.all;

entity audiocore_Simulation is
end audiocore_Simulation;

architecture testbench of audiocore_Simulation is
  
  signal clk: std_logic:='0';
  signal res: std_logic;
  
  signal Istart, Iend, Ivalid, Iready, Ostart, Oend, Ovalid, Oready: std_logic;
  signal Idata, Odata: std_logic_vector(31 downto 0);
  
  signal counter: integer:=30000;
  
  begin
    dut : entity work.audiocore
		port map
		(
		clk   => clk,
		res_n => res,
		
		-- stream input
		asin_data => Idata,
		asin_startofpacket => Istart,
		asin_endofpacket => Iend,
		asin_valid => Ivalid,
		asin_ready => Iready,

		-- stream output
		asout_data => Odata,
		asout_startofpacket => Ostart,
		asout_endofpacket => Oend,
		asout_valid => Ovalid,
		asout_ready => Oready
	);
    
    stimulus : process is
      begin
		res <= '0'; wait for 20 ns;
		res <= '1'; wait for 20 ns;
		Ivalid <= '1';
		Oready <= '1';

		Istart <= '1';
		Iend <= '0';
		
		Idata <= x"00000000";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Istart <= '0';
		Idata <= x"00000000";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"00000000";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"000088b5";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		
		Idata <= x"61bdc2a5";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"a1423a44";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"57afd3c3";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"bc544d37";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"3b9baad3";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"d476651e";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"3b828ae6";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"d7969118";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		
		Idata <= x"2c4f6ad7";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"c0afae37";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"4d3149ae";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"b1c4a952";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"583f57ad";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"a6bdbb57";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"5434529c";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"babfbc68";
		Iend <= '1';
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		
		Istart <= '1';
		Iend <= '0';
		
		Idata <= x"00000000";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Istart <= '0';
		Idata <= x"00000000";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"00000000";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"000088b5";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		
		Idata <= x"59322f89";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"a9ccd175";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"6d25396e";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"80d3e1a2";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"8e17264f";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"6cbfb7a7";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"a5363b3e";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"51beb6b2";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		
		Idata <= x"a44a5b44";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"4ea7b8aa";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"ac472d53";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"60b3c2a5";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"b2513336";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"37acc3cd";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"bf5d472b";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Idata <= x"3d96acd4";
		Iend <= '1';
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Iend <= '0';
		  
		Ivalid <= '0';
		
		loop
		  clk <= '1'; wait for 5 ns;
		  clk <= '0'; wait for 5 ns;
        end loop;
      end process stimulus;
end architecture testbench;