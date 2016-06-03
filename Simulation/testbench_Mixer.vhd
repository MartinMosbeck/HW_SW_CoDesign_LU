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
		Iin <= x"61";
		Qin <= x"bd";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--1
		Iin <= x"c2";
		Qin <= x"a5";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--2
		Iin <= x"a1";
		Qin <= x"42";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--3
		Iin <= x"3a";
		Qin <= x"44";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--4
		Iin <= x"57";
		Qin <= x"af";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--5
		Iin <= x"d3";
		Qin <= x"c3";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--6
		Iin <= x"bc";
		Qin <= x"54";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--7
		Iin <= x"4d";
		Qin <= x"37";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--8
		Iin <= x"3b";
		Qin <= x"9b";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--9
		Iin <= x"aa";
		Qin <= x"d3";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--10
		Iin <= x"d4";
		Qin <= x"76";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--11
		Iin <= x"65";
		Qin <= x"1e";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--12
		Iin <= x"3b";
		Qin <= x"82";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--13
		Iin <= x"8a";
		Qin <= x"e6";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--14
		Iin <= x"d7";
		Qin <= x"96";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--15
		Iin <= x"91";
		Qin <= x"18";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--16
		Iin <= x"2c";
		Qin <= x"4f";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--17
		Iin <= x"6a";
		Qin <= x"d7";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--18
		Iin <= x"c0";
		Qin <= x"af";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--19
		Iin <= x"ae";
		Qin <= x"37";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--20
		Iin <= x"4d";
		Qin <= x"31";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--21
		Iin <= x"49";
		Qin <= x"ae";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--22
		Iin <= x"b1";
		Qin <= x"c4";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--23
		Iin <= x"a9";
		Qin <= x"52";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--24
		Iin <= x"58";
		Qin <= x"3f";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--25
		Iin <= x"57";
		Qin <= x"ad";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--26
		Iin <= x"a6";
		Qin <= x"bd";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--27
		Iin <= x"bb";
		Qin <= x"57";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--28
		Iin <= x"54";
		Qin <= x"34";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--29
		Iin <= x"52";
		Qin <= x"9c";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--30
		Iin <= x"ba";
		Qin <= x"bf";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--31
		Iin <= x"bc";
		Qin <= x"68";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--32
		Iin <= x"59";
		Qin <= x"32";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--33
		Iin <= x"2f";
		Qin <= x"89";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--34
		Iin <= x"a9";
		Qin <= x"cc";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--35
		Iin <= x"d1";
		Qin <= x"75";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--36
		Iin <= x"6d";
		Qin <= x"25";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--37
		Iin <= x"39";
		Qin <= x"6e";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--38
		Iin <= x"80";
		Qin <= x"d3";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--39
		Iin <= x"e1";
		Qin <= x"a2";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--40
		Iin <= x"8e";
		Qin <= x"17";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--41
		Iin <= x"26";
		Qin <= x"4f";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--42
		Iin <= x"6c";
		Qin <= x"bf";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--43
		Iin <= x"b7";
		Qin <= x"a7";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--44
		Iin <= x"a5";
		Qin <= x"36";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--45
		Iin <= x"3b";
		Qin <= x"3e";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--46
		Iin <= x"51";
		Qin <= x"be";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--47
		Iin <= x"b6";
		Qin <= x"b2";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--48
		Iin <= x"a4";
		Qin <= x"4a";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--49
		Iin <= x"5b";
		Qin <= x"44";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--50
		Iin <= x"4e";
		Qin <= x"a7";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--51
		Iin <= x"b8";
		Qin <= x"aa";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--52
		Iin <= x"ac";
		Qin <= x"47";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--53
		Iin <= x"2d";
		Qin <= x"53";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--54
		Iin <= x"60";
		Qin <= x"b3";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--55
		Iin <= x"c2";
		Qin <= x"a5";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--56
		Iin <= x"b2";
		Qin <= x"51";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--57
		Iin <= x"33";
		Qin <= x"36";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--58
		Iin <= x"37";
		Qin <= x"ac";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--59
		Iin <= x"c3";
		Qin <= x"cd";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--60
		Iin <= x"bf";
		Qin <= x"5d";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--61
		Iin <= x"47";
		Qin <= x"2b";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--62
		Iin <= x"3d";
		Qin <= x"96";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--63
		Iin <= x"ac";
		Qin <= x"d4";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--64
		Iin <= x"db";
		Qin <= x"5f";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--65
		Iin <= x"53";
		Qin <= x"27";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--66
		Iin <= x"20";
		Qin <= x"84";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--67
		Iin <= x"9f";
		Qin <= x"db";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--68
		Iin <= x"d4";
		Qin <= x"8a";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--69
		Iin <= x"65";
		Qin <= x"1d";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--70
		Iin <= x"0f";
		Qin <= x"7f";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--71
		Iin <= x"91";
		Qin <= x"ca";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--72
		Iin <= x"ce";
		Qin <= x"83";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--73
		Iin <= x"7a";
		Qin <= x"3d";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--74
		Iin <= x"27";
		Qin <= x"74";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--75
		Iin <= x"7a";
		Qin <= x"c8";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--76
		Iin <= x"d7";
		Qin <= x"78";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--77
		Iin <= x"73";
		Qin <= x"3b";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--78
		Iin <= x"2d";
		Qin <= x"90";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--79
		Iin <= x"86";
		Qin <= x"bc";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--80
		Iin <= x"de";
		Qin <= x"7b";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--81
		Iin <= x"90";
		Qin <= x"35";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--82
		Iin <= x"1e";
		Qin <= x"6c";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--83
		Iin <= x"67";
		Qin <= x"c4";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--84
		Iin <= x"d8";
		Qin <= x"7f";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--85
		Iin <= x"9d";
		Qin <= x"3c";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--86
		Iin <= x"1c";
		Qin <= x"52";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--87
		Iin <= x"46";
		Qin <= x"c0";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--88
		Iin <= x"d8";
		Qin <= x"b7";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--89
		Iin <= x"b3";
		Qin <= x"3a";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--90
		Iin <= x"31";
		Qin <= x"52";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--91
		Iin <= x"3b";
		Qin <= x"b2";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--92
		Iin <= x"bb";
		Qin <= x"ba";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--93
		Iin <= x"cf";
		Qin <= x"57";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--94
		Iin <= x"45";
		Qin <= x"3b";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--95
		Iin <= x"23";
		Qin <= x"a6";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--96
		Iin <= x"9b";
		Qin <= x"b7";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--97
		Iin <= x"ce";
		Qin <= x"79";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--98
		Iin <= x"68";
		Qin <= x"3d";
		clk <= '1'; wait for 5 ns;
		clk <= '0'; wait for 5 ns;
		--99
		Iin <= x"1f";
		Qin <= x"7a";
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