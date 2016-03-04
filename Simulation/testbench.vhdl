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

  -- Set up the signals on the 3bit_counter
  signal button1 : std_logic;
  signal button4 : std_logic;
  signal led1    : std_logic;
  signal led2    : std_logic;
  signal led3    : std_logic;

  -- Set up the vcc signal as 1
  signal vcc  : std_logic := '1';
  
  signal clk: std_logic;
  signal res: std_logic;
  
  signal Iin: byte;
  signal Qin: byte;
  signal validin: std_logic;
  
  signal Iout: fixpoint;
  signal Qout: fixpoint;
  signal validout: std_logic;
  
  begin
    dut : entity work.mixerFM
		port map
		(
			clk => clk,
			res_n => res,

			Iin => Iin,
			Qin => Qin,
			validin=> validin,
			
			Iout => Iout,
			Qout => Qout,
			validout => validout	
		);
    
    stimulus : process is
      begin
		res <= '0'; wait for 20 ns;
		res <= '1'; wait for 20 ns;
        --loop
		  validin <= '1';
		  Iin <= "01001111";
		  Qin <= "01100000";
		  clk <= '1'; wait for 10 ns;
		  clk <= '0'; wait for 10 ns;
		  
		  validin <= '0';
		loop
		  clk <= '1'; wait for 10 ns;
		  clk <= '0'; wait for 10 ns;
        end loop;
      end process stimulus;
end architecture testbench;