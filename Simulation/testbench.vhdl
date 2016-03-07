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
		validin <= '1';
		--0
		Iin <= "01001111";
		Qin <= "01100000";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--1
		Iin <= "01110010";
		Qin <= "10111000";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--2
		Iin <= "10101111";
		Qin <= "10011111";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--3
		Iin <= "10001101";
		Qin <= "01001101";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--4
		Iin <= "01011001";
		Qin <= "01100001";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--5
		Iin <= "01100001";
		Qin <= "10100110";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--6
		Iin <= "10011110";
		Qin <= "10101011";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--7
		Iin <= "10100001";
		Qin <= "01011100";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--8
		Iin <= "01011011";
		Qin <= "01001100";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--9
		Iin <= "01011011";
		Qin <= "10100101";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--10
		Iin <= "10010111";
		Qin <= "10110101";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--11
		Iin <= "10110000";
		Qin <= "01100111";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--12
		Iin <= "01101100";
		Qin <= "01001000";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--13
		Iin <= "01001010";
		Qin <= "10010010";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--14
		Iin <= "10010101";
		Qin <= "11000000";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--15
		Iin <= "10101000";
		Qin <= "01110001";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--16
		Iin <= "01101010";
		Qin <= "01001001";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--17
		Iin <= "01010100";
		Qin <= "10000101";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--18
		Iin <= "10001110";
		Qin <= "10101111";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--19
		Iin <= "10101011";
		Qin <= "01111001";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--20
		Iin <= "01100100";
		Qin <= "01001001";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--21
		Iin <= "01011000";
		Qin <= "10001100";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--22
		Iin <= "10100001";
		Qin <= "10101000";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--23
		Iin <= "10100101";
		Qin <= "01101101";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--24
		Iin <= "01100010";
		Qin <= "01011011";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--25
		Iin <= "01001110";
		Qin <= "10010011";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--26
		Iin <= "10011011";
		Qin <= "10110001";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--27
		Iin <= "10110110";
		Qin <= "01101100";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--28
		Iin <= "01011100";
		Qin <= "01010010";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--29
		Iin <= "01010001";
		Qin <= "10010001";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--30
		Iin <= "10011100";
		Qin <= "10101011";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--31
		Iin <= "10110101";
		Qin <= "01110000";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--32
		Iin <= "01101000";
		Qin <= "01001110";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--33
		Iin <= "00111110";
		Qin <= "10001011";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--34
		Iin <= "10100101";
		Qin <= "10101000";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--35
		Iin <= "10110010";
		Qin <= "01101011";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--36
		Iin <= "01100001";
		Qin <= "01011011";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--37
		Iin <= "01010001";
		Qin <= "10011100";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--38
		Iin <= "10010010";
		Qin <= "10101010";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--39
		Iin <= "10110011";
		Qin <= "01100001";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--40
		Iin <= "01101101";
		Qin <= "01010001";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--41
		Iin <= "01000100";
		Qin <= "10100001";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--42
		Iin <= "10010100";
		Qin <= "10100011";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--43
		Iin <= "10110100";
		Qin <= "01100101";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--44
		Iin <= "01110111";
		Qin <= "01010010";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--45
		Iin <= "01001001";
		Qin <= "10010100";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--46
		Iin <= "10000111";
		Qin <= "10101101";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--47
		Iin <= "10101110";
		Qin <= "01101100";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--48
		Iin <= "01110000";
		Qin <= "01010111";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--49
		Iin <= "01001010";
		Qin <= "10010000";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--50
		Iin <= "01111010";
		Qin <= "10110011";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--51
		Iin <= "10101111";
		Qin <= "01101111";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--52
		Iin <= "01111001";
		Qin <= "01000000";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--53
		Iin <= "01001000";
		Qin <= "10010000";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--54
		Iin <= "10001000";
		Qin <= "10101110";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--55
		Iin <= "10110100";
		Qin <= "01111011";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--56
		Iin <= "10000110";
		Qin <= "01000111";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--57
		Iin <= "01001011";
		Qin <= "01111010";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--58
		Iin <= "01101100";
		Qin <= "10110100";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--59
		Iin <= "10110110";
		Qin <= "01111001";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--60
		Iin <= "10001111";
		Qin <= "01010110";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--61
		Iin <= "01001111";
		Qin <= "01111010";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--62
		Iin <= "01101010";
		Qin <= "10100001";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--63
		Iin <= "10100011";
		Qin <= "10001111";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--64
		Iin <= "10010001";
		Qin <= "01001111";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--65
		Iin <= "01011011";
		Qin <= "01110010";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--66
		Iin <= "01111001";
		Qin <= "10101101";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--67
		Iin <= "10100110";
		Qin <= "10000011";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--68
		Iin <= "10000011";
		Qin <= "01010100";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--69
		Iin <= "01011000";
		Qin <= "01110011";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--70
		Iin <= "10000001";
		Qin <= "10110111";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--71
		Iin <= "10110011";
		Qin <= "10001001";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--72
		Iin <= "10000100";
		Qin <= "01000001";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--73
		Iin <= "01011000";
		Qin <= "01111001";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--74
		Iin <= "01111010";
		Qin <= "10101110";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--75
		Iin <= "10101110";
		Qin <= "10010000";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--76
		Iin <= "10000000";
		Qin <= "01000111";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--77
		Iin <= "01001111";
		Qin <= "01101011";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--78
		Iin <= "10000110";
		Qin <= "10110010";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--79
		Iin <= "10101101";
		Qin <= "10001000";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--80
		Iin <= "10000101";
		Qin <= "01010011";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--81
		Iin <= "01010100";
		Qin <= "01101011";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--82
		Iin <= "01110110";
		Qin <= "10100110";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--83
		Iin <= "10110010";
		Qin <= "10010000";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--84
		Iin <= "01111101";
		Qin <= "01010100";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--85
		Iin <= "01010101";
		Qin <= "01111000";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--86
		Iin <= "10001101";
		Qin <= "10101001";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--87
		Iin <= "10100110";
		Qin <= "01110100";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--88
		Iin <= "01111010";
		Qin <= "01011011";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--89
		Iin <= "01000110";
		Qin <= "10010101";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--90
		Iin <= "10000100";
		Qin <= "10101011";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--91
		Iin <= "11000001";
		Qin <= "01110000";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--92
		Iin <= "01110001";
		Qin <= "01010101";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--93
		Iin <= "01001100";
		Qin <= "10001110";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--94
		Iin <= "10001011";
		Qin <= "10101011";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--95
		Iin <= "10111001";
		Qin <= "01101100";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--96
		Iin <= "10000011";
		Qin <= "01001011";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--97
		Iin <= "01000110";
		Qin <= "10001010";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--98
		Iin <= "10000110";
		Qin <= "10101111";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		--99
		Iin <= "10110111";
		Qin <= "01110010";
		clk <= '1'; wait for 10 ns;
		clk <= '0'; wait for 10 ns;
		  
		validin <= '0';
		--endloop
		loop
		  clk <= '1'; wait for 10 ns;
		  clk <= '0'; wait for 10 ns;
        end loop;
      end process stimulus;
end architecture testbench;