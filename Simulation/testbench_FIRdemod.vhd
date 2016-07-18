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
  
  signal Iin: fixpoint;
  signal Qin: fixpoint;
  signal validin: std_logic;
  
  signal data_out: fixpoint;
  signal validout: std_logic;
  
  begin
	dut: entity work.demodulator_FIR
	port map
	(
		clk => clk,
		res_n => res,

		data_in_I => Iin,
		data_in_Q => Qin,
		validin_I => validin,
		validin_Q => validin,
		
		data_out => data_out,
		validout => validout
	);
    
    stimulus : process is
      begin
		res <= '0'; wait for 20 ns;
		res <= '1'; wait for 20 ns;
		validin <= '1';
		--0
		Iin <= x"fff5a337";
		Qin <= x"0011c24b";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--1
		Iin <= x"ffca93b0";
		Qin <= x"0036ea3e";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--2
		Iin <= x"ffcf6b1c";
		Qin <= x"00248a50";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--3
		Iin <= x"ffe63477";
		Qin <= x"00372d96";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--4
		Iin <= x"000d83d3";
		Qin <= x"003d907b";
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