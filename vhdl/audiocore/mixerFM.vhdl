library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.audiocore_pkg.all;

entity mixerFM is
	port 
	(
		clk : in std_logic;
		res_n : in std_logic;

		Iin : in byte;
		Qin : in byte;
		validin : in std_logic;
		
		Iout : out fixpoint;
		Qout : out fixpoint;
		validout : out std_logic
	);
end mixerFM;

architecture behavior of mixerFM is
	
	signal Iout_cur, Iout_next : fixpoint;
	signal Qout_cur, Qout_next : fixpoint;
	signal validout_cur, validout_next : std_logic;
	signal t_cur,t_next : index_time; 


	function fixpoint_mult(a,b:fixpoint) return fixpoint is
				variable result_full : fixpoint_product;
	begin
		result_full := a * b;

		return result_full(55 downto 24);
	end function;
	
	function lookup_sin(index:index_time) 
		return fixpoint is
	begin 
		case index is
			when 0 =>
				return "00000000000000000000000000000000";
			when 1 =>
				return "00000000111111110111111010101101";
			when 2 =>
				return "00000000001000000001010111010110";
			when 3 =>
				return "11111111000001001000100011010011";
			when 4 =>
				return "11111111110000000101010111011101";
			when 5 =>
				return "00000000111100110111100001110000";
			when 6 =>
				return "00000000010111100011110101101001";
			when 7 =>
				return "11111111000110000101110101000010";
			when 8 =>
				return "11111111100001001010101111001011";
			when 9 =>
				return "00000000110110000010010111011111";
			when 10 =>
				return "00000000100101100111100100011000";
			when 11 =>
				return "11111111001110101011111110100101";
			when 12 =>
				return "11111111010100001100000110000110";
			when 13 =>
				return "00000000101011110011111001111010";
			when 14 =>
				return "00000000110001010100000001011011";
			when 15 =>
				return "11111111011010011000011011101000";
			when 16 =>
				return "11111111001001111101101000100001";
			when 17 =>
				return "00000000011110110101010000110101";
			when 18 =>
				return "00000000111001111010001010111110";
			when 19 =>
				return "11111111101000011100001010010111";
			when 20 =>
				return "11111111000011001000011110010000";
			when 21 =>
				return "00000000001111111010101000100011";
			when 22 =>
				return "00000000111110110111011100101101";
			when 23 =>
				return "11111111110111111110101000101010";
			when 24 =>
				return "11111111000000001000000101010011";

		end case;
	end function;

	function lookup_cos(index:index_time)
		return fixpoint is
	begin	
		case index is
			when 0 =>
				return "00000001000000000000000000000000";
			when 1 =>
				return "00000000000100000001001100001010";
			when 2 =>
				return "11111111000000100000010011000110";
			when 3 =>
				return "11111111110100000000011111001000";
			when 4 =>
				return "00000000111101111111010100010000";
			when 5 =>
				return "00000000010011110001101110111100";
			when 6 =>
				return "11111111000100011111101000101100";
			when 7 =>
				return "11111111100100110000000000100001";
			when 8 =>
				return "00000000111000000101010110100010";
			when 9 =>
				return "00000000100010010010101111110001";
			when 10 =>
				return "11111111001100001110010001000100";
			when 11 =>
				return "11111111010111001101000111001001";
			when 12 =>
				return "00000000101110101001110110110000";
			when 13 =>
				return "00000000101110101001110110110000";
			when 14 =>
				return "11111111010111001101000111001001";
			when 15 =>
				return "11111111001100001110010001000100";
			when 16 =>
				return "00000000100010010010101111110001";
			when 17 =>
				return "00000000111000000101010110100010";
			when 18 =>
				return "11111111100100110000000000100001";
			when 19 =>
				return "11111111000100011111101000101100";
			when 20 =>
				return "00000000010011110001101110111100";
			when 21 =>
				return "00000000111101111111010100010000";
			when 22 =>
				return "11111111110100000000011111001000";
			when 23 =>
				return "11111111000000100000010011000110";
			when 24 =>
				return "00000000000100000001001100001010";

			
		end case;
	end function;

begin
	mix_it: process (Iin,QIn,validin)
		variable I_temp : fixpoint;
		variable Q_temp : fixpoint;
	begin
		Iout_next <= Iout_cur;
		Qout_next <= Qout_cur;
		validout_next <= validout_cur;
		t_next <= t_cur;
		
		if(validin = '1') then
			I_temp := (others => '0');
			Q_temp := (others => '0');

			validout_next <= '1';
			I_temp(31 downto 24) := signed(unsigned(Iin) - to_unsigned(127,8)); 
			Q_temp(31 downto 24) := signed(unsigned(Qin) - to_unsigned(127,8));

			Iout_next <= fixpoint_mult(I_temp,lookup_cos(t_cur)) - fixpoint_mult(Q_temp,lookup_sin(t_cur));
			Qout_next <= fixpoint_mult(I_temp,lookup_sin(t_cur)) + fixpoint_mult(Q_temp,lookup_cos(t_cur));

			if(t_cur = 24) then
				t_next <= 0;
			else
				t_next <= t_cur + 1;
			end if;

		else
			validout_next <= '0';
		end if;

	end process mix_it;

	sync: process (clk,res_n)
	begin
		if res_n ='0' then
			Iout_cur <= (others => '0');
			Qout_cur <= (others => '1');
			validout_cur <= '0';
			t_cur <= 0;
		elsif rising_edge(clk) then
			--internals
			Iout_cur <= Iout_next;
			Qout_cur <= Qout_next;
			validout_cur <= validout_next;
			t_cur <= t_next;

			--outputs
			validout <= validout_next;
			Iout <= Iout_next;
			Qout <= Qout_next;
		end if;
	end process sync;
	
end behavior;