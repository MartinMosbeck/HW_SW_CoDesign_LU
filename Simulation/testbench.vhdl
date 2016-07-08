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
  
  signal Iin: fixpoint;
  signal validin: std_logic;
  
  signal Iout: fixpoint;
  signal validout: std_logic;
  
  signal counter: integer:=30000;
  
  begin
    dut : entity work.FIRFilter
		port map
		(
		clk => clk,
		res_n => res,

		data_in => Iin,
		validin => validin,

		data_out => Iout,
		validout => validout
		);
    
    stimulus : process is
      begin
		res <= '0'; wait for 20 ns;
		res <= '1'; wait for 20 ns;
		validin <= '1';

		Iin <= x"ffe20000";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Iin <= x"ffde4845";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		
		
		validin <= '0';
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <= '1';
		
		Iin <= x"ffe5e9ab";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Iin <= x"ffd2f96b";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Iin <= x"ffe53198";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Iin <= x"ffd948fc";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Iin <= x"ffd71d0e";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Iin <= x"ffd4243e";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		
		validin <= '0';
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <= '1';
		
		Iin <= x"ffd1e69c";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Iin <= x"ffd01e15";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Iin <= x"ffc0864a";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Iin <= x"ffc5d56c";
		
		validin <= '0';
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <= '1';
		
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Iin <= x"ffd07c06";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Iin <= x"ffc182cd";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		
		Iin <= x"ffb62f70";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Iin <= x"ffb4e56b";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Iin <= x"ffab001f";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Iin <= x"ffc33427";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Iin <= x"ffb8e4e1";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Iin <= x"ffb9cbed";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Iin <= x"ffa65e2a";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Iin <= x"ffc0021c";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Iin <= x"ffb2da7d";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Iin <= x"ffd0b121";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		Iin <= x"ffbdad9b";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;

		  
		validin <= '0';
		
		report integer'image(to_integer(unsigned(Iout)));
		--report integer'image(to_integer(unsigned(Qout)));
		--endloop
		loop
		  clk <= '1'; wait for 5 ns;
		  clk <= '0'; wait for 5 ns;
        end loop;
      end process stimulus;
end architecture testbench;