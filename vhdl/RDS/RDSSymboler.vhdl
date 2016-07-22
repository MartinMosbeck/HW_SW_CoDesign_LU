--WARNUNG!!! DER BLOCK IST FÜR NACH DEN DECIMATOR GEDACHT (max. jeder 10. Takt ein DATUM!!!)
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.audiocore_pkg.all;

entity RDSSymboler is
	port 
	(
		clk : in std_logic;
		res_n : in std_logic;

		Iin : in fixpoint;
		Qin : in fixpoint;
		validin : in std_logic;
		
		RDSout : out byte;
		validout : out std_logic
	);
end RDSSymboler;

architecture behavior of RDSSymboler is
	constant pihalbe: fixpoint := x"0001921F";-- wie der name sagt
	constant pi: fixpoint := x"0003243F";
	constant dreipihalbe: fixpoint := x"0004B65F";
	constant zweipi: fixpoint := x"0006487E";

	function lookup_sin(argument:fixpoint)--lookup_cos ruft die +pi/2 auf
		return fixpoint is

		variable phi_abs: fixpoint;
		variable neg: std_logic;
		variable phi_ein: fixpoint;
		variable erg: fixpoint;
	begin
		if(argument(31)='1')then
			phi_abs:=not(argument - 1);
			neg := '1';
		else
			phi_abs:= argument;
			neg := '0';
		end if;

		if(phi_abs < pihalbe)then
			phi_ein := phi_abs;
		elsif(phi_abs > pihalbe and phi_abs < pi)then
			phi_ein := pi-phi_abs;
		elsif(phi_abs > pi and phi_abs < dreipihalbe)then
			if(neg = '1')then
				neg:='0';
			else
				neg:='1';
			end if;
			phi_ein := phi_abs - pi;
		else
			if(neg = '1')then
				neg:='0';
			else
				neg:='1';
			end if;
			phi_ein := zweipi - phi_abs;
		end if;

		case phi_ein(31 downto 10) is
			when "0000000000000000000000" => erg := "00000000000000000000000000000000";
			when "0000000000000000000001" => erg := "00000000000000000000001111111111";
			when "0000000000000000000010" => erg := "00000000000000000000011111111111";
			when "0000000000000000000011" => erg := "00000000000000000000101111111110";
			when "0000000000000000000100" => erg := "00000000000000000000111111111101";
			when "0000000000000000000101" => erg := "00000000000000000001001111111010";
			when "0000000000000000000110" => erg := "00000000000000000001011111110111";
			when "0000000000000000000111" => erg := "00000000000000000001101111110001";
			when "0000000000000000001000" => erg := "00000000000000000001111111101010";
			when "0000000000000000001001" => erg := "00000000000000000010001111100001";
			when "0000000000000000001010" => erg := "00000000000000000010011111010110";
			when "0000000000000000001011" => erg := "00000000000000000010101111001000";
			when "0000000000000000001100" => erg := "00000000000000000010111110111000";
			when "0000000000000000001101" => erg := "00000000000000000011001110100100";
			when "0000000000000000001110" => erg := "00000000000000000011011110001101";
			when "0000000000000000001111" => erg := "00000000000000000011101101110011";
			when "0000000000000000010000" => erg := "00000000000000000011111101010101";
			when "0000000000000000010001" => erg := "00000000000000000100001100110100";
			when "0000000000000000010010" => erg := "00000000000000000100011100001101";
			when "0000000000000000010011" => erg := "00000000000000000100101011100011";
			when "0000000000000000010100" => erg := "00000000000000000100111010110100";
			when "0000000000000000010101" => erg := "00000000000000000101001010000000";
			when "0000000000000000010110" => erg := "00000000000000000101011001000110";
			when "0000000000000000010111" => erg := "00000000000000000101101000001000";
			when "0000000000000000011000" => erg := "00000000000000000101110111000100";
			when "0000000000000000011001" => erg := "00000000000000000110000101111001";
			when "0000000000000000011010" => erg := "00000000000000000110010100101001";
			when "0000000000000000011011" => erg := "00000000000000000110100011010011";
			when "0000000000000000011100" => erg := "00000000000000000110110001110110";
			when "0000000000000000011101" => erg := "00000000000000000111000000010010";
			when "0000000000000000011110" => erg := "00000000000000000111001110100111";
			when "0000000000000000011111" => erg := "00000000000000000111011100110101";
			when "0000000000000000100000" => erg := "00000000000000000111101010111011";
			when "0000000000000000100001" => erg := "00000000000000000111111000111010";
			when "0000000000000000100010" => erg := "00000000000000001000000110110001";
			when "0000000000000000100011" => erg := "00000000000000001000010100100000";
			when "0000000000000000100100" => erg := "00000000000000001000100010000110";
			when "0000000000000000100101" => erg := "00000000000000001000101111100100";
			when "0000000000000000100110" => erg := "00000000000000001000111100111001";
			when "0000000000000000100111" => erg := "00000000000000001001001010000101";
			when "0000000000000000101000" => erg := "00000000000000001001010111001000";
			when "0000000000000000101001" => erg := "00000000000000001001100100000010";
			when "0000000000000000101010" => erg := "00000000000000001001110000110010";
			when "0000000000000000101011" => erg := "00000000000000001001111101011001";
			when "0000000000000000101100" => erg := "00000000000000001010001001110101";
			when "0000000000000000101101" => erg := "00000000000000001010010110000111";
			when "0000000000000000101110" => erg := "00000000000000001010100010001111";
			when "0000000000000000101111" => erg := "00000000000000001010101110001101";
			when "0000000000000000110000" => erg := "00000000000000001010111001111111";
			when "0000000000000000110001" => erg := "00000000000000001011000101100111";
			when "0000000000000000110010" => erg := "00000000000000001011010001000100";
			when "0000000000000000110011" => erg := "00000000000000001011011100010101";
			when "0000000000000000110100" => erg := "00000000000000001011100111011011";
			when "0000000000000000110101" => erg := "00000000000000001011110010010110";
			when "0000000000000000110110" => erg := "00000000000000001011111101000100";
			when "0000000000000000110111" => erg := "00000000000000001100000111100111";
			when "0000000000000000111000" => erg := "00000000000000001100010001111101";
			when "0000000000000000111001" => erg := "00000000000000001100011100000111";
			when "0000000000000000111010" => erg := "00000000000000001100100110000101";
			when "0000000000000000111011" => erg := "00000000000000001100101111110110";
			when "0000000000000000111100" => erg := "00000000000000001100111001011011";
			when "0000000000000000111101" => erg := "00000000000000001101000010110010";
			when "0000000000000000111110" => erg := "00000000000000001101001011111101";
			when "0000000000000000111111" => erg := "00000000000000001101010100111010";
			when "0000000000000001000000" => erg := "00000000000000001101011101101010";
			when "0000000000000001000001" => erg := "00000000000000001101100110001101";
			when "0000000000000001000010" => erg := "00000000000000001101101110100010";
			when "0000000000000001000011" => erg := "00000000000000001101110110101001";
			when "0000000000000001000100" => erg := "00000000000000001101111110100010";
			when "0000000000000001000101" => erg := "00000000000000001110000110001101";
			when "0000000000000001000110" => erg := "00000000000000001110001101101011";
			when "0000000000000001000111" => erg := "00000000000000001110010100111010";
			when "0000000000000001001000" => erg := "00000000000000001110011011111011";
			when "0000000000000001001001" => erg := "00000000000000001110100010101101";
			when "0000000000000001001010" => erg := "00000000000000001110101001010001";
			when "0000000000000001001011" => erg := "00000000000000001110101111100110";
			when "0000000000000001001100" => erg := "00000000000000001110110101101100";
			when "0000000000000001001101" => erg := "00000000000000001110111011100100";
			when "0000000000000001001110" => erg := "00000000000000001111000001001100";
			when "0000000000000001001111" => erg := "00000000000000001111000110100110";
			when "0000000000000001010000" => erg := "00000000000000001111001011110000";
			when "0000000000000001010001" => erg := "00000000000000001111010000101011";
			when "0000000000000001010010" => erg := "00000000000000001111010101010111";
			when "0000000000000001010011" => erg := "00000000000000001111011001110100";
			when "0000000000000001010100" => erg := "00000000000000001111011110000001";
			when "0000000000000001010101" => erg := "00000000000000001111100001111111";
			when "0000000000000001010110" => erg := "00000000000000001111100101101110";
			when "0000000000000001010111" => erg := "00000000000000001111101001001100";
			when "0000000000000001011000" => erg := "00000000000000001111101100011011";
			when "0000000000000001011001" => erg := "00000000000000001111101111011011";
			when "0000000000000001011010" => erg := "00000000000000001111110010001010";
			when "0000000000000001011011" => erg := "00000000000000001111110100101010";
			when "0000000000000001011100" => erg := "00000000000000001111110110111010";
			when "0000000000000001011101" => erg := "00000000000000001111111000111010";
			when "0000000000000001011110" => erg := "00000000000000001111111010101011";
			when "0000000000000001011111" => erg := "00000000000000001111111100001011";
			when "0000000000000001100000" => erg := "00000000000000001111111101011011";
			when "0000000000000001100001" => erg := "00000000000000001111111110011100";
			when "0000000000000001100010" => erg := "00000000000000001111111111001100";
			when "0000000000000001100011" => erg := "00000000000000001111111111101101";
			when "0000000000000001100100" => erg := "00000000000000001111111111111101";
			when others=> return x"00000000";
		end case;

		if(neg = '1')then
			return (not erg) + 1;
		else
			return erg;
		end if;
	end function lookup_sin;
	function lookup_arg(I,Q:fixpoint;dynshift:natural)
		return fixpoint is

		variable I_ein, Q_ein: fixpoint;
		variable piminus, minuspi,neg:std_logic:='0';
		variable IQ_combo: byte;
		variable erg: fixpoint;
	begin
		if(I(31) = '0' and Q(31) = '0')then--1. Quadrant
			I_ein := I;
			Q_ein := Q;
		elsif(I(31) = '1' and Q(31) = '0')then--2. Quadrant
			I_ein:= not(I - 1);
			Q_ein:= Q;
			piminus := '1';
		elsif(I(31) = '1' and Q(31) = '1')then--3.
			I_ein := not(I - 1);
			Q_ein := not(Q - 1);
			minuspi := '1';
		elsif(I(31) = '0' and Q(31) = '1')then--4.
			I_ein := I;
			Q_ein := not(Q - 1);
			neg := '1';
		end if;

		IQ_combo := std_logic_vector(I_ein(31-dynshift downto 28-dynshift)) & std_logic_vector(Q_ein(31-dynshift downto 28-dynshift));

		case IQ_combo is
			when "00000000" => erg := "00000000000000001100100100001111";
			when "00000001" => erg := "00000000000000010001101101101110";
			when "00000010" => erg := "00000000000000010011111111000001";
			when "00000011" => erg := "00000000000000010101001101101000";
			when "00000100" => erg := "00000000000000010101111110010111";
			when "00000101" => erg := "00000000000000010110011111011000";
			when "00000110" => erg := "00000000000000010110110111001100";
			when "00000111" => erg := "00000000000000010111001001001001";
			when "00001000" => erg := "00000000000000010111010111001011";
			when "00001001" => erg := "00000000000000010111100010011011";
			when "00001010" => erg := "00000000000000010111101011101010";
			when "00001011" => erg := "00000000000000010111110011010110";
			when "00001100" => erg := "00000000000000010111111001111000";
			when "00001101" => erg := "00000000000000010111111111011110";
			when "00001110" => erg := "00000000000000011000000100010101";
			when "00001111" => erg := "00000000000000011000001000100101";
			when "00010000" => erg := "00000000000000000111011010110001";
			when "00010001" => erg := "00000000000000001100100100001111";
			when "00010010" => erg := "00000000000000001111101110011000";
			when "00010011" => erg := "00000000000000010001101101101110";
			when "00010100" => erg := "00000000000000010011000010110110";
			when "00010101" => erg := "00000000000000010011111111000001";
			when "00010110" => erg := "00000000000000010100101011100001";
			when "00010111" => erg := "00000000000000010101001101101000";
			when "00011000" => erg := "00000000000000010101101000100101";
			when "00011001" => erg := "00000000000000010101111110010111";
			when "00011010" => erg := "00000000000000010110010000010100";
			when "00011011" => erg := "00000000000000010110011111011000";
			when "00011100" => erg := "00000000000000010110101100001011";
			when "00011101" => erg := "00000000000000010110110111001100";
			when "00011110" => erg := "00000000000000010111000000110000";
			when "00011111" => erg := "00000000000000010111001001001001";
			when "00100000" => erg := "00000000000000000101001001011110";
			when "00100001" => erg := "00000000000000001001011010000111";
			when "00100010" => erg := "00000000000000001100100100001111";
			when "00100011" => erg := "00000000000000001110110101100011";
			when "00100100" => erg := "00000000000000010000011111000110";
			when "00100101" => erg := "00000000000000010001101101101110";
			when "00100110" => erg := "00000000000000010010101001111000";
			when "00100111" => erg := "00000000000000010011011001000111";
			when "00101000" => erg := "00000000000000010011111111000001";
			when "00101001" => erg := "00000000000000010100011110000010";
			when "00101010" => erg := "00000000000000010100110111110110";
			when "00101011" => erg := "00000000000000010101001101101000";
			when "00101100" => erg := "00000000000000010101100000010000";
			when "00101101" => erg := "00000000000000010101110000010101";
			when "00101110" => erg := "00000000000000010101111110010111";
			when "00101111" => erg := "00000000000000010110001010101100";
			when "00110000" => erg := "00000000000000000011111010110110";
			when "00110001" => erg := "00000000000000000111011010110001";
			when "00110010" => erg := "00000000000000001010010010111100";
			when "00110011" => erg := "00000000000000001100100100001111";
			when "00110100" => erg := "00000000000000001110010101100011";
			when "00110101" => erg := "00000000000000001111101110011000";
			when "00110110" => erg := "00000000000000010000110100111000";
			when "00110111" => erg := "00000000000000010001101101101110";
			when "00111000" => erg := "00000000000000010010011100001110";
			when "00111001" => erg := "00000000000000010011000010110110";
			when "00111010" => erg := "00000000000000010011100011010110";
			when "00111011" => erg := "00000000000000010011111111000001";
			when "00111100" => erg := "00000000000000010100010110110101";
			when "00111101" => erg := "00000000000000010100101011100001";
			when "00111110" => erg := "00000000000000010100111101101000";
			when "00111111" => erg := "00000000000000010101001101101000";
			when "01000000" => erg := "00000000000000000011001010001000";
			when "01000001" => erg := "00000000000000000110000101101000";
			when "01000010" => erg := "00000000000000001000101001011000";
			when "01000011" => erg := "00000000000000001010110010111011";
			when "01000100" => erg := "00000000000000001100100100001111";
			when "01000101" => erg := "00000000000000001110000001000101";
			when "01000110" => erg := "00000000000000001111001101010111";
			when "01000111" => erg := "00000000000000010000001100011111";
			when "01001000" => erg := "00000000000000010001000001001110";
			when "01001001" => erg := "00000000000000010001101101101110";
			when "01001010" => erg := "00000000000000010010010011101000";
			when "01001011" => erg := "00000000000000010010110100001110";
			when "01001100" => erg := "00000000000000010011010000100000";
			when "01001101" => erg := "00000000000000010011101001001111";
			when "01001110" => erg := "00000000000000010011111111000001";
			when "01001111" => erg := "00000000000000010100010010010101";
			when "01010000" => erg := "00000000000000000010101001000111";
			when "01010001" => erg := "00000000000000000101001001011110";
			when "01010010" => erg := "00000000000000000111011010110001";
			when "01010011" => erg := "00000000000000001001011010000111";
			when "01010100" => erg := "00000000000000001011000111011010";
			when "01010101" => erg := "00000000000000001100100100001111";
			when "01010110" => erg := "00000000000000001101110010110111";
			when "01010111" => erg := "00000000000000001110110101100011";
			when "01011000" => erg := "00000000000000001111101110011000";
			when "01011001" => erg := "00000000000000010000011111000110";
			when "01011010" => erg := "00000000000000010001001001001010";
			when "01011011" => erg := "00000000000000010001101101101110";
			when "01011100" => erg := "00000000000000010010001101101101";
			when "01011101" => erg := "00000000000000010010101001111000";
			when "01011110" => erg := "00000000000000010011000010110110";
			when "01011111" => erg := "00000000000000010011011001000111";
			when "01100000" => erg := "00000000000000000010010001010011";
			when "01100001" => erg := "00000000000000000100011100111110";
			when "01100010" => erg := "00000000000000000110011110100110";
			when "01100011" => erg := "00000000000000001000010011100110";
			when "01100100" => erg := "00000000000000001001111011001000";
			when "01100101" => erg := "00000000000000001011010101101000";
			when "01100110" => erg := "00000000000000001100100100001111";
			when "01100111" => erg := "00000000000000001101101000011010";
			when "01101000" => erg := "00000000000000001110100011100101";
			when "01101001" => erg := "00000000000000001111010111000111";
			when "01101010" => erg := "00000000000000010000000100001010";
			when "01101011" => erg := "00000000000000010000101011101111";
			when "01101100" => erg := "00000000000000010001001110101100";
			when "01101101" => erg := "00000000000000010001101101101110";
			when "01101110" => erg := "00000000000000010010001001011000";
			when "01101111" => erg := "00000000000000010010100010001011";
			when "01110000" => erg := "00000000000000000001111111010101";
			when "01110001" => erg := "00000000000000000011111010110110";
			when "01110010" => erg := "00000000000000000101101111011000";
			when "01110011" => erg := "00000000000000000111011010110001";
			when "01110100" => erg := "00000000000000001000111100000000";
			when "01110101" => erg := "00000000000000001010010010111100";
			when "01110110" => erg := "00000000000000001011100000000101";
			when "01110111" => erg := "00000000000000001100100100001111";
			when "01111000" => erg := "00000000000000001101100000011010";
			when "01111001" => erg := "00000000000000001110010101100011";
			when "01111010" => erg := "00000000000000001111000100100110";
			when "01111011" => erg := "00000000000000001111101110011000";
			when "01111100" => erg := "00000000000000010000010011100110";
			when "01111101" => erg := "00000000000000010000110100111000";
			when "01111110" => erg := "00000000000000010001010010110001";
			when "01111111" => erg := "00000000000000010001101101101110";
			when "10000000" => erg := "00000000000000000001110001010100";
			when "10000001" => erg := "00000000000000000011011111111010";
			when "10000010" => erg := "00000000000000000101001001011110";
			when "10000011" => erg := "00000000000000000110101100010000";
			when "10000100" => erg := "00000000000000001000000111010001";
			when "10000101" => erg := "00000000000000001001011010000111";
			when "10000110" => erg := "00000000000000001010100100111010";
			when "10000111" => erg := "00000000000000001011101000000101";
			when "10001000" => erg := "00000000000000001100100100001111";
			when "10001001" => erg := "00000000000000001101011010000101";
			when "10001010" => erg := "00000000000000001110001010010011";
			when "10001011" => erg := "00000000000000001110110101100011";
			when "10001100" => erg := "00000000000000001111011100011010";
			when "10001101" => erg := "00000000000000001111111111011100";
			when "10001110" => erg := "00000000000000010000011111000110";
			when "10001111" => erg := "00000000000000010000111011110011";
			when "10010000" => erg := "00000000000000000001100110000011";
			when "10010001" => erg := "00000000000000000011001010001000";
			when "10010010" => erg := "00000000000000000100101010011100";
			when "10010011" => erg := "00000000000000000110000101101000";
			when "10010100" => erg := "00000000000000000111011010110001";
			when "10010101" => erg := "00000000000000001000101001011000";
			when "10010110" => erg := "00000000000000001001110001011000";
			when "10010111" => erg := "00000000000000001010110010111011";
			when "10011000" => erg := "00000000000000001011101110011001";
			when "10011001" => erg := "00000000000000001100100100001111";
			when "10011010" => erg := "00000000000000001101010100111110";
			when "10011011" => erg := "00000000000000001110000001000101";
			when "10011100" => erg := "00000000000000001110101001000100";
			when "10011101" => erg := "00000000000000001111001101010111";
			when "10011110" => erg := "00000000000000001111101110011000";
			when "10011111" => erg := "00000000000000010000001100011111";
			when "10100000" => erg := "00000000000000000001011100110101";
			when "10100001" => erg := "00000000000000000010111000001010";
			when "10100010" => erg := "00000000000000000100010000101001";
			when "10100011" => erg := "00000000000000000101100101001001";
			when "10100100" => erg := "00000000000000000110110100110111";
			when "10100101" => erg := "00000000000000000111111111010101";
			when "10100110" => erg := "00000000000000001001000100010101";
			when "10100111" => erg := "00000000000000001010000011111000";
			when "10101000" => erg := "00000000000000001010111110001011";
			when "10101001" => erg := "00000000000000001011110011100001";
			when "10101010" => erg := "00000000000000001100100100001111";
			when "10101011" => erg := "00000000000000001101010000101111";
			when "10101100" => erg := "00000000000000001101111001011000";
			when "10101101" => erg := "00000000000000001110011110100010";
			when "10101110" => erg := "00000000000000001111000000100011";
			when "10101111" => erg := "00000000000000001111011111110000";
			when "10110000" => erg := "00000000000000000001010101001000";
			when "10110001" => erg := "00000000000000000010101001000111";
			when "10110010" => erg := "00000000000000000011111010110110";
			when "10110011" => erg := "00000000000000000101001001011110";
			when "10110100" => erg := "00000000000000000110010100010001";
			when "10110101" => erg := "00000000000000000111011010110001";
			when "10110110" => erg := "00000000000000001000011100101111";
			when "10110111" => erg := "00000000000000001001011010000111";
			when "10111000" => erg := "00000000000000001010010010111100";
			when "10111001" => erg := "00000000000000001011000111011010";
			when "10111010" => erg := "00000000000000001011110111110000";
			when "10111011" => erg := "00000000000000001100100100001111";
			when "10111100" => erg := "00000000000000001101001101001011";
			when "10111101" => erg := "00000000000000001101110010110111";
			when "10111110" => erg := "00000000000000001110010101100011";
			when "10111111" => erg := "00000000000000001110110101100011";
			when "11000000" => erg := "00000000000000000001001110100111";
			when "11000001" => erg := "00000000000000000010011100010100";
			when "11000010" => erg := "00000000000000000011101000001111";
			when "11000011" => erg := "00000000000000000100110001101010";
			when "11000100" => erg := "00000000000000000101110111111111";
			when "11000101" => erg := "00000000000000000110111010110010";
			when "11000110" => erg := "00000000000000000111111001110010";
			when "11000111" => erg := "00000000000000001000110100111001";
			when "11001000" => erg := "00000000000000001001101100000100";
			when "11001001" => erg := "00000000000000001010011111011011";
			when "11001010" => erg := "00000000000000001011001111000111";
			when "11001011" => erg := "00000000000000001011111011010011";
			when "11001100" => erg := "00000000000000001100100100001111";
			when "11001101" => erg := "00000000000000001101001010001010";
			when "11001110" => erg := "00000000000000001101101101010001";
			when "11001111" => erg := "00000000000000001110001101110011";
			when "11010000" => erg := "00000000000000000001001001000001";
			when "11010001" => erg := "00000000000000000010010001010011";
			when "11010010" => erg := "00000000000000000011011000001010";
			when "11010011" => erg := "00000000000000000100011100111110";
			when "11010100" => erg := "00000000000000000101011111010000";
			when "11010101" => erg := "00000000000000000110011110100110";
			when "11010110" => erg := "00000000000000000111011010110001";
			when "11010111" => erg := "00000000000000001000010011100110";
			when "11011000" => erg := "00000000000000001001001001000011";
			when "11011001" => erg := "00000000000000001001111011001000";
			when "11011010" => erg := "00000000000000001010101001111100";
			when "11011011" => erg := "00000000000000001011010101101000";
			when "11011100" => erg := "00000000000000001011111110010101";
			when "11011101" => erg := "00000000000000001100100100001111";
			when "11011110" => erg := "00000000000000001101000111100010";
			when "11011111" => erg := "00000000000000001101101000011010";
			when "11100000" => erg := "00000000000000000001000100001010";
			when "11100001" => erg := "00000000000000000010000111101110";
			when "11100010" => erg := "00000000000000000011001010001000";
			when "11100011" => erg := "00000000000000000100001010110110";
			when "11100100" => erg := "00000000000000000101001001011110";
			when "11100101" => erg := "00000000000000000110000101101000";
			when "11100110" => erg := "00000000000000000110111111000110";
			when "11100111" => erg := "00000000000000000111110101101101";
			when "11101000" => erg := "00000000000000001000101001011000";
			when "11101001" => erg := "00000000000000001001011010000111";
			when "11101010" => erg := "00000000000000001010000111111011";
			when "11101011" => erg := "00000000000000001010110010111011";
			when "11101100" => erg := "00000000000000001011011011001110";
			when "11101101" => erg := "00000000000000001100000000111100";
			when "11101110" => erg := "00000000000000001100100100001111";
			when "11101111" => erg := "00000000000000001101000101010001";
			when "11110000" => erg := "00000000000000000000111111111010";
			when "11110001" => erg := "00000000000000000001111111010101";
			when "11110010" => erg := "00000000000000000010111101110010";
			when "11110011" => erg := "00000000000000000011111010110110";
			when "11110100" => erg := "00000000000000000100110110001001";
			when "11110101" => erg := "00000000000000000101101111011000";
			when "11110110" => erg := "00000000000000000110100110010011";
			when "11110111" => erg := "00000000000000000111011010110001";
			when "11111000" => erg := "00000000000000001000001100101011";
			when "11111001" => erg := "00000000000000001000111100000000";
			when "11111010" => erg := "00000000000000001001101000101111";
			when "11111011" => erg := "00000000000000001010010010111100";
			when "11111100" => erg := "00000000000000001010111010101100";
			when "11111101" => erg := "00000000000000001011100000000101";
			when "11111110" => erg := "00000000000000001100000011001110";
			when "11111111" => erg := "00000000000000001100100100001111";
			when others => return x"FFFFFFFF";
		end case;

		if(neg = '1')then
			return (not erg) + 1;
		elsif(minuspi = '1')then
			return erg - pi;
		elsif(piminus = '1')then
			return pi - erg;
		else
			return erg;
		end if;
	end function lookup_arg;

	constant anzsamplesHalf : natural := 53;
	constant anzsamples : natural := 105;

	constant ovterm: fixpoint := x"0006487E";-- 2Pi
	constant ufterm: fixpoint := x"FFF9B782";-- -2Pi

	signal cnt_cur, cnt_next : natural:=0;

	signal cos_corr_cur, cos_corr_next: fixpoint := x"00010000";-- 1
	signal sin_corr_cur, sin_corr_next: fixpoint;

	signal lastI_cur, lastI_next: fixpoint;
	signal I_corr_cur, I_corr_next : fixpoint;
	signal Q_corr_cur, Q_corr_next : fixpoint;
	signal phi_cur, phi_next, phipih_cur, phipih_next : fixpoint;

	signal code_mode_cur, code_mode_next: std_logic;
	signal code_word_next, code_word_cur: fixpoint;

	signal validintern_cur1, validintern_cur2, validintern_next1, validintern_next2, validintern_cur3, validintern_next3: std_logic;
	signal validout_next, validout_cur: std_logic;
	signal validlook_cur1, validlook_next1, validlook_cur2, validlook_next2, validlook_cur3, validlook_next3: std_logic;

	signal vorganger_cur, vorganger_next: std_logic;
	signal double_cur, double_next: std_logic;

	signal bit1_cur, bit1_next, bit2_cur, bit2_next, dbit_cur, dbit_next: std_logic;

	signal lastbit_cur, lastbit_next: std_logic;
	signal data_out_cur, data_out_next: byte;
	signal bit_cnt_cur, bit_cnt_next: natural range 0 to 7 := 7;
	signal RDSByte_cur, RDSByte_next: byte;
	
	signal err_term_cur, err_term_next: fixpoint;

	signal dynshift_cur, dynshift_next: natural range 0 to 24 := 0;
begin
	symboldetection: process (Iin, Qin, validin, code_mode_cur, cnt_cur, lastI_cur, sin_corr_cur, cos_corr_cur, I_corr_cur, Q_corr_cur, phi_cur, validout_cur, validintern_cur1, validintern_cur2, bit_cnt_cur, RDSByte_cur, dbit_cur, bit1_cur, bit2_cur, lastbit_cur, validintern_cur3, code_word_cur, vorganger_cur, double_cur, dynshift_cur, err_term_cur, phipih_cur, validlook_cur1, validlook_cur2, validlook_cur3)
		variable phi_cor, phi_corr: fixpoint;
		variable vorganger, double: std_logic;
		variable code_neg: fixpoint;
		variable bit1, bit2, lastbit: std_logic;
		variable I_abs, Q_abs: fixpoint;
	begin
		--Latches
		code_mode_next <= code_mode_cur;
		cnt_next <= cnt_cur;
		lastI_next <= lastI_cur;
		code_word_next <= code_word_cur;
		phi_next <= phi_cur;
		sin_corr_next <= sin_corr_cur;
		cos_corr_next <= cos_corr_cur;
		dbit_next <= dbit_cur;
		bit2_next <= bit2_cur;
		bit1_next <= bit1_cur;
		vorganger_next <= vorganger_cur;
		double_next <= double_cur;
		lastbit_next <= lastbit_cur;
		data_out_next <= data_out_cur;
		bit_cnt_next <= bit_cnt_cur;
		RDSByte_next <= RDSByte_cur;
		dynshift_next <= dynshift_cur;
		err_term_next <= err_term_cur;
		phipih_next <= phipih_cur;

		if(validin = '1') then
			I_corr_next <= fixpoint_mult(Iin,cos_corr_cur)-fixpoint_mult(Qin,sin_corr_cur);
			Q_corr_next <= fixpoint_mult(Iin,sin_corr_cur)+fixpoint_mult(Qin,cos_corr_cur);
			lastI_next <= I_corr_cur;
			cnt_next <= cnt_cur + 1;
			validintern_next1 <= '1';
		else
			validintern_next1 <= '0';
			I_corr_next <= I_corr_cur;
			Q_corr_next <= Q_corr_cur;
		end if;

		validintern_next2 <= '0';
		if(validintern_cur1 = '1')then
			if(I_corr_cur(31) /= lastI_cur(31))then--Zerocrossing
				if(cnt_cur > anzsamplesHalf + anzsamples)then
					code_mode_next <= '0';
					code_word_next <= lastI_cur;
					if(cnt_cur > anzsamplesHalf + 2*anzsamples)then
						code_mode_next <= '1';
					end if;
					validintern_next2 <= '1';
				end if;
				cnt_next <= 1;
			end if;

			if(cnt_cur = anzsamplesHalf)then
				code_mode_next <= '0';
				code_word_next <= I_corr_cur;
				validintern_next2 <= '1';

				if(I_corr_cur(31)='1')then
					I_abs:=not(I_corr_cur - 1);
				else
					I_abs := I_corr_cur;
				end if;
				if(Q_corr_cur(31) = '1' )then
					Q_abs:=not(Q_corr_cur - 1);
				else
					Q_abs:=Q_corr_cur;
				end if;
				if(I_abs > Q_abs)then
					if(I_abs(31 downto 16) = "0000000000000000")then
						dynshift_next <= 16;
					elsif(I_abs(31 downto 17) = "000000000000000")then
						dynshift_next <= 15;
					elsif(I_abs(31 downto 18) = "00000000000000")then
						dynshift_next <= 14;
					elsif(I_abs(31 downto 19) = "0000000000000")then
						dynshift_next <= 13;
					elsif(I_abs(31 downto 20) = "000000000000")then
						dynshift_next <= 12;
					elsif(I_abs(31 downto 21) = "00000000000")then
						dynshift_next <= 11;
					elsif(I_abs(31 downto 22) = "0000000000")then
						dynshift_next <= 10;
					elsif(I_abs(31 downto 23) = "000000000")then
						dynshift_next <= 9;
					elsif(I_abs(31 downto 24) = "00000000")then
						dynshift_next <= 8;
					elsif(I_abs(31 downto 25) = "0000000")then
						dynshift_next <= 7;
					elsif(I_abs(31 downto 26) = "000000")then
						dynshift_next <= 6;
					elsif(I_abs(31 downto 27) = "00000")then
						dynshift_next <= 5;
					elsif(I_abs(31 downto 28) = "0000")then
						dynshift_next <= 4;
					elsif(I_abs(31 downto 29) = "000")then
						dynshift_next <= 3;
					elsif(I_abs(31 downto 30) = "00")then
						dynshift_next <= 2;
					elsif(I_abs(31) = '0')then
						dynshift_next <= 1;
					else
						dynshift_next <= 0;
					end if;
				else
					if(Q_abs(31 downto 16) = "0000000000000000")then
						dynshift_next <= 16;
					elsif(Q_abs(31 downto 17) = "000000000000000")then
						dynshift_next <= 15;
					elsif(Q_abs(31 downto 18) = "00000000000000")then
						dynshift_next <= 14;
					elsif(Q_abs(31 downto 19) = "0000000000000")then
						dynshift_next <= 13;
					elsif(Q_abs(31 downto 20) = "000000000000")then
						dynshift_next <= 12;
					elsif(Q_abs(31 downto 21) = "00000000000")then
						dynshift_next <= 11;
					elsif(Q_abs(31 downto 22) = "0000000000")then
						dynshift_next <= 10;
					elsif(Q_abs(31 downto 23) = "000000000")then
						dynshift_next <= 9;
					elsif(Q_abs(31 downto 24) = "00000000")then
						dynshift_next <= 8;
					elsif(Q_abs(31 downto 25) = "0000000")then
						dynshift_next <= 7;
					elsif(Q_abs(31 downto 26) = "000000")then
						dynshift_next <= 6;
					elsif(Q_abs(31 downto 27) = "00000")then
						dynshift_next <= 5;
					elsif(Q_abs(31 downto 28) = "0000")then
						dynshift_next <= 4;
					elsif(Q_abs(31 downto 29) = "000")then
						dynshift_next <= 3;
					elsif(Q_abs(31 downto 30) = "00")then
						dynshift_next <= 2;
					elsif(Q_abs(31) = '0')then
						dynshift_next <= 1;
					else
						dynshift_next <= 0;
					end if;
				end if;
				validlook_next1 <= '1';
			else
				validlook_next1 <= '0';
			end if;
		end if;

		if(validlook_cur1 = '1')then
			err_term_next <= lookup_arg(I_corr_cur,Q_corr_cur,dynshift_cur);
			validlook_next2 <= '1';
		else
			validlook_next2 <= '0';
		end if;
		
		if(validlook_cur2 = '1')then
			phi_cor := phi_cur - signed(err_term_cur(31) & err_term_cur(31) & std_logic_vector(err_term_cur(31 downto 2))) + signed(err_term_cur(31) & err_term_cur(31) & err_term_cur(31) & err_term_cur(31) & std_logic_vector(err_term_cur(31 downto 4)));
			if(phi_cor >= ovterm)then
				phi_corr := phi_cor - ovterm;
			elsif(phi_cor <= ufterm)then
				phi_corr := phi_cor + ufterm;
			else
				phi_corr := phi_cor;
			end if;
			phi_next <= phi_corr;
			phipih_next <= phi_corr + pihalbe;
			validlook_next3 <= '1';
		else
			validlook_next3 <= '0';
		end if;
		
		if(validlook_cur3 = '1')then
			sin_corr_next <= lookup_sin(phi_cur);
			cos_corr_next <= lookup_sin(phipih_cur);
		end if;

		validintern_next3 <= '0';
		if(validintern_cur2 = '1')then
			dbit_next <= '0';
			vorganger := vorganger_cur;
			double := double_cur;
			if(code_mode_cur = '1')then
				dbit_next <= '1';
				--Das negierte zuerst bearbeiten
				if(code_word_cur(31)='1')then
					code_neg:=not(code_word_cur - 1);
				else
					code_neg:=(not code_word_cur) + 1;
				end if;
				if(code_neg(31) = '1' and vorganger = '1')then
					double := '1';
					vorganger := '1';
				elsif(code_neg(31)='0' and vorganger = '0')then
					double := '1';
					vorganger := '0';
				else
					if(double = '0')then
						double := '1';
					else
						if(code_neg(31) = '1' and vorganger = '0') then
							bit1_next <= '1';
							validintern_next3 <= '1';
						elsif(code_neg(31) = '0' and vorganger = '1')then
							bit1_next <= '0';
							validintern_next3 <= '1';
						end if;
						double := '0';
					end if;
					vorganger:= code_neg(31);
				end if;
			end if;
			if(code_word_cur(31) = '1' and vorganger = '1')then
				double := '1';
				vorganger := '1';
			elsif(code_word_cur(31) = '0' and vorganger = '0')then
				double := '1';
				vorganger := '0';
			else
				if(double = '0')then
					double := '1';
				else
					if(code_word_cur(31) = '1' and vorganger = '0') then
						bit2_next <= '1';
						validintern_next3 <= '1';
					elsif(code_word_cur(31) = '0' and vorganger = '1')then
						bit2_next <= '0';
						validintern_next3 <= '1';
					end if;
					double := '0';
				end if;
				vorganger := code_word_cur(31);
			end if;
			vorganger_next <= vorganger;
			double_next <= double;
		end if;

		validout_next <= '0';
		if(validintern_cur3 = '1')then
			lastbit:=lastbit_cur;
			if(dbit_cur = '1')then
				bit1:=lastbit xor bit1_cur;
				lastbit:= bit1_cur;
			end if;
			bit2:=lastbit xor bit2_cur;
			lastbit_next <= bit2_cur;

			--Ausgabe von bit1,bit2 (in der Reihenfolge)
			if(dbit_cur = '1')then
				if(bit_cnt_cur > 1)then
					RDSByte_next(bit_cnt_cur downto bit_cnt_cur - 1) <= bit1 & bit2;
					bit_cnt_next <= bit_cnt_cur - 2;
				elsif(bit_cnt_cur = 1)then
					data_out_next <= RDSByte_cur(7 downto 2) & bit1 & bit2;
					bit_cnt_next <= 7;
					validout_next <= '1';
				else
					data_out_next <= RDSByte_cur(7 downto 1) & bit1;
					bit_cnt_next <= 6;
					validout_next <= '1';
					RDSByte_next(7) <= bit2;
				end if;
			else
				if(bit_cnt_cur = 0)then
					data_out_next <=  RDSByte_cur(7 downto 1) & bit2;
					bit_cnt_next <= 7;
					validout_next <= '1';
				else
					RDSByte_next(bit_cnt_cur) <= bit2;
					bit_cnt_next <= bit_cnt_cur - 1;
				end if;
			end if;
		end if;
	end process symboldetection;

	sync: process (clk,res_n)
	begin
		if res_n ='0' then
			validintern_cur1 <= '0';
			validintern_cur2 <= '0';
			validintern_cur3 <= '0';
			code_word_cur <= (others => '0');
			code_mode_cur <= '0';
			sin_corr_cur <= (others => '0');
			cos_corr_cur <= x"00010000";
			lastI_cur <= (others => '0');
			I_corr_cur <= (others => '0');
			Q_corr_cur <= (others => '0');
			phi_cur <= (others => '0');
			validout_cur <= '0';
			cnt_cur <= 0;
			data_out_cur <= (others => '0');
			vorganger_cur <= '0';
			double_cur <= '0';
			bit1_cur <= '0';
			bit2_cur <= '0';
			dbit_cur <= '0';
			lastbit_cur <= '0';
			bit_cnt_cur <= 7;
			RDSByte_cur <= (others => '0');
			validlook_cur1 <= '0';
			validlook_cur2 <= '0';
			validlook_cur3 <= '0';
			err_term_cur <= (others => '0');
			phipih_cur <= (others => '0');
		elsif rising_edge(clk) then
			--internals
			validintern_cur1 <= validintern_next1;
			validintern_cur2 <= validintern_next2;
			validintern_cur3 <= validintern_next3;
			validout_cur <= validout_next;
			code_word_cur <= code_word_next;
			code_mode_cur <= code_mode_next;
			sin_corr_cur <= sin_corr_next;
			cos_corr_cur <= cos_corr_next;
			lastI_cur <= lastI_next;
			I_corr_cur <= I_corr_next;
			Q_corr_cur <= Q_corr_next;
			phi_cur <= phi_next;
			cnt_cur <= cnt_next;
			data_out_cur <= data_out_next;
			vorganger_cur <= vorganger_next;
			double_cur <= double_next;
			bit1_cur <= bit1_next;
			bit2_cur <= bit2_next;
			dbit_cur <= dbit_next;
			lastbit_cur <= lastbit_next;
			bit_cnt_cur <= bit_cnt_next;
			RDSByte_cur <= RDSByte_next;
			validlook_cur1 <= validlook_next1;
			validlook_cur2 <= validlook_next2;
			validlook_cur3 <= validlook_next3;
			err_term_cur <= err_term_next;
			phipih_cur <= phipih_next;

			--outputs
			validout <= validout_cur;
			RDSout <= data_out_cur;
		end if;
	end process sync;
end behavior;