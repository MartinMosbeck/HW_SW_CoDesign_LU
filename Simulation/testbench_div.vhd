-- Load Altera libraries for this chip
library IEEE;
--LIBRARY MAXII;
use IEEE.STD_LOGIC_1164.all;
--USE MAXII.MAXII_COMPONENTS.ALL;
library work;
use work.audiocore_pkg.all;

entity audiocore_Simulation is
end audiocore_Simulation;

architecture testbench of audiocore_Simulation is
  
  signal clk: std_logic;
  signal res: std_logic;
  
  signal a: fixpoint;
  signal b: fixpoint;
  signal validin: std_logic;
  
  signal data_out: fixpoint;
  signal validout: std_logic;
  
  begin
	dut: entity work.division_block
	port map
	(
		clk => clk,
		res_n => res,

		div_in1 => a,
		div_in2 => b,
		validin => validin,

		div_out => data_out,
		validout => validout
	);
    
    stimulus : process is
      begin
		res <= '0'; wait for 20 ns;
		res <= '1'; wait for 20 ns;
		validin <= '1';
		--0
		a <= x"FFF5a337";
		b <= x"000cef08";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--1
		a <= x"ffe63477";
		b <= x"002abb83";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		  
		validin <= '0';
		--endloop
		loop
		  clk <= '1'; wait for 10 ns;
		  clk <= '0'; wait for 10 ns;
        end loop;
      end process stimulus;
end architecture testbench;