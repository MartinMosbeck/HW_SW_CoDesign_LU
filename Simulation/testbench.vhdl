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
  
  signal Iin: byte;
  signal Qin: byte;
  signal validin: std_logic;
  
  signal Iout: fixpoint;
  signal Qout: fixpoint;
  signal validout: std_logic;
  
  signal counter: integer:=30000;
  
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
		validin <= '1';
		--0
		Iin <= "00110110";
		Qin <= "11001010";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--1
		Iin <= "11111010";
		Qin <= "11000111";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--2
		Iin <= "11010111";
		Qin <= "01000010";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--3
		Iin <= "00110001";
		Qin <= "01011100";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--4
		Iin <= "01001010";
		Qin <= "11001011";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--5
		Iin <= "11101110";
		Qin <= "11011010";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--6
		Iin <= "11101001";
		Qin <= "01011011";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--7
		Iin <= "00110111";
		Qin <= "00101001";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--8
		Iin <= "00101001";
		Qin <= "10111101";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--9
		Iin <= "11100001";
		Qin <= "11010011";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--10
		Iin <= "11101000";
		Qin <= "01010010";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--11
		Iin <= "00110111";
		Qin <= "01011011";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--12
		Iin <= "00010011";
		Qin <= "11001011";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--13
		Iin <= "10110011";
		Qin <= "11111100";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--14
		Iin <= "11001010";
		Qin <= "01110000";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--15
		Iin <= "01010101";
		Qin <= "01010011";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--16
		Iin <= "00110101";
		Qin <= "11001010";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--17
		Iin <= "11001101";
		Qin <= "11010100";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--18
		Iin <= "11010100";
		Qin <= "01101011";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--19
		Iin <= "00111000";
		Qin <= "01000100";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--20
		Iin <= "00010111";
		Qin <= "10110101";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--21
		Iin <= "11000101";
		Qin <= "11001100";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--22
		Iin <= "11011111";
		Qin <= "01011001";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--23
		Iin <= "00110110";
		Qin <= "00110001";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--24
		Iin <= "00010100";
		Qin <= "10101010";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--25
		Iin <= "10100000";
		Qin <= "11011101";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--26
		Iin <= "11100010";
		Qin <= "01101101";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--27
		Iin <= "01011111";
		Qin <= "00011001";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--28
		Iin <= "00000110";
		Qin <= "10100101";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--29
		Iin <= "10100010";
		Qin <= "11010110";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--30
		Iin <= "10111110";
		Qin <= "01011111";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--31
		Iin <= "01010001";
		Qin <= "00100010";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--32
		Iin <= "00010001";
		Qin <= "01110111";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--33
		Iin <= "01011101";
		Qin <= "11010100";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--34
		Iin <= "11010110";
		Qin <= "10000110";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--35
		Iin <= "01100111";
		Qin <= "00101110";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--36
		Iin <= "00010110";
		Qin <= "10100000";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--37
		Iin <= "01110011";
		Qin <= "11100001";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--38
		Iin <= "11110011";
		Qin <= "01001011";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--39
		Iin <= "01110001";
		Qin <= "00110110";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--40
		Iin <= "00001110";
		Qin <= "10111010";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--41
		Iin <= "01110100";
		Qin <= "11010101";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--42
		Iin <= "11110000";
		Qin <= "00110101";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--43
		Iin <= "01110001";
		Qin <= "00010010";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--44
		Iin <= "00100011";
		Qin <= "10011101";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--45
		Iin <= "01001101";
		Qin <= "11011110";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--46
		Iin <= "10100111";
		Qin <= "01101000";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--47
		Iin <= "01111110";
		Qin <= "00001111";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--48
		Iin <= "00101001";
		Qin <= "10100001";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--49
		Iin <= "10001000";
		Qin <= "11111111";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--50
		Iin <= "11001011";
		Qin <= "10000111";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--51
		Iin <= "01100001";
		Qin <= "00001000";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--52
		Iin <= "00010101";
		Qin <= "01101010";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--53
		Iin <= "01001111";
		Qin <= "11111111";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--54
		Iin <= "11011100";
		Qin <= "10000001";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--55
		Iin <= "01111001";
		Qin <= "00000000";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--56
		Iin <= "00101110";
		Qin <= "01100011";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--57
		Iin <= "01100110";
		Qin <= "11011010";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--58
		Iin <= "10011011";
		Qin <= "10110001";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--59
		Iin <= "10001010";
		Qin <= "00111100";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--60
		Iin <= "00100011";
		Qin <= "01010100";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--61
		Iin <= "01011100";
		Qin <= "11110100";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--62
		Iin <= "10100111";
		Qin <= "10010100";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--63
		Iin <= "10000011";
		Qin <= "00001100";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--64
		Iin <= "00011110";
		Qin <= "00110010";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--65
		Iin <= "00101110";
		Qin <= "11011111";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--66
		Iin <= "10010100";
		Qin <= "10100101";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--67
		Iin <= "10010100";
		Qin <= "01000001";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--68
		Iin <= "00010111";
		Qin <= "00111101";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--69
		Iin <= "01000001";
		Qin <= "11010011";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--70
		Iin <= "11001010";
		Qin <= "11100001";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--71
		Iin <= "10101011";
		Qin <= "00110000";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--72
		Iin <= "01000001";
		Qin <= "00100000";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--73
		Iin <= "00011100";
		Qin <= "10110101";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--74
		Iin <= "10100001";
		Qin <= "11111111";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--75
		Iin <= "11001101";
		Qin <= "01011011";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--76
		Iin <= "01011100";
		Qin <= "00000000";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--77
		Iin <= "00101010";
		Qin <= "10010010";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--78
		Iin <= "01110011";
		Qin <= "11111110";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--79
		Iin <= "10111000";
		Qin <= "10000111";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--80
		Iin <= "01100000";
		Qin <= "00100000";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--81
		Iin <= "00100010";
		Qin <= "10001110";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--82
		Iin <= "10000100";
		Qin <= "11111100";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--83
		Iin <= "10111001";
		Qin <= "10010100";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--84
		Iin <= "01110001";
		Qin <= "00101110";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--85
		Iin <= "00101100";
		Qin <= "01100101";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--86
		Iin <= "01101010";
		Qin <= "11100010";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--87
		Iin <= "10110000";
		Qin <= "10101100";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--88
		Iin <= "01011100";
		Qin <= "00010011";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--89
		Iin <= "00011010";
		Qin <= "01011101";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--90
		Iin <= "00111101";
		Qin <= "11001111";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--91
		Iin <= "10011110";
		Qin <= "01111111";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--92
		Iin <= "01110111";
		Qin <= "00100011";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--93
		Iin <= "00001011";
		Qin <= "01110011";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--94
		Iin <= "10000100";
		Qin <= "11101011";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--95
		Iin <= "11110110";
		Qin <= "10111010";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--96
		Iin <= "10000011";
		Qin <= "00100101";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--97
		Iin <= "00101001";
		Qin <= "00100111";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--98
		Iin <= "01000000";
		Qin <= "10110100";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--99
		Iin <= "10101110";
		Qin <= "11101111";
		counter <= counter + 10000;
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		  
		validin <= '0';
		
		report integer'image(to_integer(unsigned(Iout)));
		report integer'image(to_integer(unsigned(Qout)));
		--endloop
		loop
		  clk <= '1'; wait for 5 ns;
		  clk <= '0'; wait for 5 ns;
        end loop;
      end process stimulus;
end architecture testbench;