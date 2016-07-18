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
		validin <= '0';
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <='1';
		--1
		Iin <= x"ffca93b0";
		Qin <= x"0036ea3e";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <= '0';
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <='1';
		--2
		Iin <= x"ffcf6b1c";
		Qin <= x"00248a50";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <= '0';
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <='1';
		--3
		Iin <= x"ffe63477";
		Qin <= x"00372d96";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <= '0';
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <='1';
		--4
		Iin <= x"000d83d3";
		Qin <= x"003d907b";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <= '0';
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <='1';
		
		--5
		Iin <= x"001c6e1a";
		Qin <= x"00383d9e";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <= '0';
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <='1';
		--6
		Iin <= x"001a5e04";
		Qin <= x"00330d5f";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <= '0';
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <='1';
		--7
		Iin <= x"001cfbcd";
		Qin <= x"00308864";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <= '0';
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <='1';
		--8
		Iin <= x"00057a1f";
		Qin <= x"003b854b";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <= '0';
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <='1';
		--9
		Iin <= x"ffffbb6c";
		Qin <= x"0038e926";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <= '0';
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <='1';
		
		--10
		Iin <= x"0020e49d";
		Qin <= x"002f9891";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <= '0';
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <='1';
		--11
		Iin <= x"003364c3";
		Qin <= x"00232e11";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <= '0';
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <='1';
		--12
		Iin <= x"0028cc5b";
		Qin <= x"002b8fd0";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <= '0';
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <='1';
		--13
		Iin <= x"002728c7";
		Qin <= x"0028a660";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <= '0';
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <='1';
		--14
		Iin <= x"00165527";
		Qin <= x"00344d73";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <= '0';
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <='1';
		
		--15
		Iin <= x"ffee9f82";
		Qin <= x"003a402f";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <= '0';
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <='1';
		--16
		Iin <= x"fff3f2f6";
		Qin <= x"00313c4c";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <= '0';
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <='1';
		--17
		Iin <= x"001bb963";
		Qin <= x"0034a30c";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <= '0';
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <='1';
		--18
		Iin <= x"00127768";
		Qin <= x"0034e36d";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <= '0';
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <='1';
		--19
		Iin <= x"0002b63c";
		Qin <= x"003b8f89";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <= '0';
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		validin <='1';
		  
		--validin <= '0';
		--endloop
		loop
		  clk <= '1'; wait for 10 ns;
		  clk <= '0'; wait for 10 ns;
        end loop;
      end process stimulus;
end architecture testbench;