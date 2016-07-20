library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.audiocore_pkg.all;

entity mixerRDS is
	port 
	(
		clk : in std_logic;
		res_n : in std_logic;

		fixin : in fixpoint;
		validin : in std_logic;
		
		Iout : out fixpoint;
		Qout : out fixpoint;
		validout : out std_logic
	);
end mixerRDS;

architecture behavior of mixerRDS is
	
	signal Iout_cur, Iout_next : fixpoint;
	signal Qout_cur, Qout_next : fixpoint;
	signal validout_cur, validout_next : std_logic;
	signal t_cur,t_next : index_time;
	signal lookup_cos_cur, lookup_cos_next: fixpoint;
	signal lookup_sin_cur, lookup_sin_next: fixpoint;


	function fixpoint_mult(a,b:fixpoint) return fixpoint is
				variable result_full : fixpoint_product;
	begin
		result_full := a * b;

		return result_full(47 downto 16);
	end function;
	
	function lookup_sin(index:index_time) 
		return fixpoint is
	begin 
		case index is
			when 0 =>
					return "00000000000000000000000000000000";
			when 1 =>
					return "00000000000000001111110110001110";
			when 2 =>
					return "00000000000000000100010111100000";
			when 3 =>
					return "11111111111111110001010110110011";
			when 4 =>
					return "11111111111111110111100110001111";
			when 5 =>
					return "00000000000000001100010101000000";
			when 6 =>
					return "00000000000000001011110011001101";
			when 7 =>
					return "11111111111111110110111011001000";
			when 8 =>
					return "11111111111111110001101100101110";
			when 9 =>
					return "00000000000000000101001000101001";
			when 10 =>
					return "00000000000000001111101101110111";
			when 11 =>
					return "11111111111111111111001100100100";
			when 12 =>
					return "11111111111111110000000011111110";
			when 13 =>
					return "11111111111111111100011010010111";
			when 14 =>
					return "00000000000000001110111100110000";
			when 15 =>
					return "00000000000000000111101101010100";
			when 16 =>
					return "11111111111111110011001011001101";
			when 17 =>
					return "11111111111111110100110000100000";
			when 18 =>
					return "00000000000000001001101110100001";
			when 19 =>
					return "00000000000000001101111011000100";
			when 20 =>
					return "11111111111111111010000111000011";
			when 21 =>
					return "11111111111111110000011101000100";
			when 22 =>
					return "00000000000000000001100110110001";
			when 23 =>
					return "00000000000000001111111111010001";
			when 24 =>
					return "00000000000000000010110011001110";
		end case;
	end function;

	function lookup_cos(index:index_time)
		return fixpoint is
	begin	
		case index is
			when 0 =>
					return "00000000000000010000000000000000";
			when 1 =>
					return "00000000000000000010001101000110";
			when 2 =>
					return "11111111111111110000100110111001";
			when 3 =>
					return "11111111111111111001100011011100";
			when 4 =>
					return "00000000000000001101100111011010";
			when 5 =>
					return "00000000000000001010001100101110";
			when 6 =>
					return "11111111111111110101001100011110";
			when 7 =>
					return "11111111111111110010110100101101";
			when 8 =>
					return "00000000000000000111001011001001";
			when 9 =>
					return "00000000000000001111001001110101";
			when 10 =>
					return "11111111111111111101000000001000";
			when 11 =>
					return "11111111111111110000000001010011";
			when 12 =>
					return "11111111111111111110100110000011";
			when 13 =>
					return "00000000000000001111100101111010";
			when 14 =>
					return "00000000000000000101101100111101";
			when 15 =>
					return "11111111111111110001111110101011";
			when 16 =>
					return "11111111111111110110011011110000";
			when 17 =>
					return "00000000000000001011011000100111";
			when 18 =>
					return "00000000000000001100101101000010";
			when 19 =>
					return "11111111111111111000000111011101";
			when 20 =>
					return "11111111111111110001000111111011";
			when 21 =>
					return "00000000000000000011110010001011";
			when 22 =>
					return "00000000000000001111111010110101";
			when 23 =>
					return "00000000000000000000100110100110";
			when 24 =>
					return "11111111111111110000001111110100";
		end case;
	end function;

begin
	mix_it: process (fixin,validin, Iout_cur, Qout_cur, t_cur, validout_cur, lookup_cos_cur, lookup_sin_cur)
		variable t_temp: index_time;
	begin
		Iout_next <= Iout_cur;
		Qout_next <= Qout_cur;
		validout_next <= validout_cur;
		t_next <= t_cur;
		
		lookup_cos_next<=lookup_cos_cur;
		lookup_sin_next<=lookup_sin_cur;
		
		if(validin = '1') then
			Iout_next <= fixpoint_mult(fixin,lookup_cos_cur);
			Qout_next <= fixpoint_mult(fixin,lookup_sin_cur);
			
			if(t_cur = 24) then
				t_temp := 0;
			else
				t_temp := t_cur + 1;
			end if;
			lookup_sin_next <= lookup_sin(t_temp);
			lookup_cos_next <= lookup_cos(t_temp);
			t_next <= t_temp;
			validout_next <= '1';
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

			lookup_sin_cur <= lookup_sin(0);
			lookup_cos_cur <= lookup_cos(0);
		elsif rising_edge(clk) then
			--internals
			Iout_cur <= Iout_next;
			Qout_cur <= Qout_next;
			validout_cur <= validout_next;
			t_cur <= t_next;

			lookup_cos_cur <= lookup_cos_next;
			lookup_sin_cur <= lookup_sin_next;

			--outputs
			validout <= validout_next;
			Iout <= Iout_next;
			Qout <= Qout_next;
		end if;
	end process sync;
	
end behavior;