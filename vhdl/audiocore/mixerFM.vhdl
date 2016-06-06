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

	signal validintern1_next, validintern1_cur, validintern2_cur, validintern2_next: std_logic;
	signal Itemp1_next, Itemp1_cur, Itemp2_next, Itemp2_cur, Qtemp1_next, Qtemp1_cur, Qtemp2_next, Qtemp2_cur: fixpoint;
	
	signal I_temp_cur, I_temp_next, Q_temp_cur, Q_temp_next: fixpoint;
	
	signal lookup_cos_cur, lookup_cos_next, lookup_sin_cur, lookup_sin_next: fixpoint;


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
				return "00000000000000001111111101111110";
			when 2 =>
				return "00000000000000000010000000010101";
			when 3 =>
				return "11111111111111110000010010001001";
			when 4 =>
				return "11111111111111111100000001010110";
			when 5 =>
				return "00000000000000001111001101111000";
			when 6 =>
				return "00000000000000000101111000111101";
			when 7 =>
				return "11111111111111110001100001011110";
			when 8 =>
				return "11111111111111111000010010101100";
			when 9 =>
				return "00000000000000001101100000100101";
			when 10 =>
				return "00000000000000001001011001111001";
			when 11 =>
				return "11111111111111110011101011000000";
			when 12 =>
				return "11111111111111110101000011000010";
			when 13 =>
				return "00000000000000001010111100111110";
			when 14 =>
				return "00000000000000001100010101000000";
			when 15 =>
				return "11111111111111110110100110000111";
			when 16 =>
				return "11111111111111110010011111011011";
			when 17 =>
				return "00000000000000000111101101010100";
			when 18 =>
				return "00000000000000001110011110100010";
			when 19 =>
				return "11111111111111111010000111000011";
			when 20 =>
				return "11111111111111110000110010001000";
			when 21 =>
				return "00000000000000000011111110101010";
			when 22 =>
				return "00000000000000001111101101110111";
			when 23 =>
				return "11111111111111111101111111101011";
			when 24 =>
				return "11111111111111110000000010000010";


		end case;
	end function;

	function lookup_cos(index:index_time)
		return fixpoint is
	begin	
		case index is
			when 0 =>
				return "00000000000000010000000000000000";
			when 1 =>
				return "00000000000000000001000000010011";
			when 2 =>
				return "11111111111111110000001000000101";
			when 3 =>
				return "11111111111111111101000000001000";
			when 4 =>
				return "00000000000000001111011111110101";
			when 5 =>
				return "00000000000000000100111100011011";
			when 6 =>
				return "11111111111111110001000111111011";
			when 7 =>
				return "11111111111111111001001100000001";
			when 8 =>
				return "00000000000000001110000001010101";
			when 9 =>
				return "00000000000000001000100100101011";
			when 10 =>
				return "11111111111111110011000011100101";
			when 11 =>
				return "11111111111111110101110011010010";
			when 12 =>
				return "00000000000000001011101010011101";
			when 13 =>
				return "00000000000000001011101010011101";
			when 14 =>
				return "11111111111111110101110011010010";
			when 15 =>
				return "11111111111111110011000011100101";
			when 16 =>
				return "00000000000000001000100100101011";
			when 17 =>
				return "00000000000000001110000001010101";
			when 18 =>
				return "11111111111111111001001100000001";
			when 19 =>
				return "11111111111111110001000111111011";
			when 20 =>
				return "00000000000000000100111100011011";
			when 21 =>
				return "00000000000000001111011111110101";
			when 22 =>
				return "11111111111111111101000000001000";
			when 23 =>
				return "11111111111111110000001000000101";
			when 24 =>
				return "00000000000000000001000000010011";

			
		end case;
	end function;

begin
	mix_it: process (Iin,QIn,validin, Iout_cur, Qout_cur, t_cur, validout_cur, Itemp1_cur, Itemp2_cur, Qtemp1_cur, Qtemp2_cur, validintern1_cur,validintern2_cur, I_temp_cur, Q_temp_cur, lookup_cos_cur, lookup_sin_cur)
		variable I_temp : fixpoint;
		variable Q_temp : fixpoint;
		variable t_temp: index_time;
	begin
		Iout_next <= Iout_cur;
		Qout_next <= Qout_cur;
		validout_next <= validout_cur;
		t_next <= t_cur;

		validintern1_next <= validintern1_cur;
		validintern2_next <= validintern2_cur;
		Itemp1_next <= Itemp1_cur;
		Itemp2_next <= Itemp2_cur;
		Qtemp1_next <= Qtemp1_cur;
		Qtemp2_next <= Qtemp2_cur;
		I_temp_next <= I_temp_cur;
		Q_temp_next <= Q_temp_cur;
		
		lookup_cos_next<=lookup_cos_cur;
		lookup_sin_next<=lookup_sin_cur;
		
		if(validin = '1') then
			I_temp := (others => '0');
			Q_temp := (others => '0');

			validintern1_next <= '1';
			I_temp(23 downto 16) := signed(unsigned(Iin) - to_unsigned(127,8)); 
			Q_temp(23 downto 16) := signed(unsigned(Qin) - to_unsigned(127,8));
			
			if(I_temp(23) = '1' and I_temp(23 downto 16) /= "10000000") then
			  I_temp(31 downto 24) := (others => '1');
			end if;
			if(Q_temp(23) = '1' and Q_temp(23 downto 16) /= "10000000") then
			  Q_temp(31 downto 24) := (others => '1');
			end if;
			
			I_temp_next <= I_temp;
			Q_temp_next <= Q_temp;
		else
			validintern1_next <= '0';
		end if;
		
		if(validintern1_cur = '1') then
			validintern2_next <= '1';
			
			Itemp1_next <= fixpoint_mult(I_temp_cur,lookup_cos_cur);
			Itemp2_next <= fixpoint_mult(Q_temp_cur,lookup_sin_cur);
			Qtemp1_next <= fixpoint_mult(I_temp_cur,lookup_sin_cur);
			Qtemp2_next <= fixpoint_mult(Q_temp_cur,lookup_cos_cur);

			if(t_cur = 24) then
				t_temp := 0;
			else
				t_temp := t_cur + 1;
			end if;
			lookup_sin_next <= lookup_sin(t_temp);
			lookup_cos_next <= lookup_cos(t_temp);
			t_next <= t_temp;
		else
			validintern2_next <= '0';
		end if;

		if(validintern2_cur = '1') then
			Iout_next <= Itemp1_cur - Itemp2_cur;
			Qout_next <= Qtemp1_cur + Qtemp2_cur;
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

			validintern1_cur <= '0';
			validintern2_cur <= '0';
			Itemp1_cur <= (others => '0');
			Itemp2_cur <= (others => '0');
			Qtemp1_cur <= (others => '0');
			Qtemp2_cur <= (others => '0');
			I_temp_cur <= (others => '0');
			Q_temp_cur <= (others => '0');
			
			lookup_sin_cur <= lookup_sin(0);
			lookup_cos_cur <= lookup_cos(0);
		elsif rising_edge(clk) then
			--internals
			Iout_cur <= Iout_next;
			Qout_cur <= Qout_next;
			validout_cur <= validout_next;
			t_cur <= t_next;

			validintern1_cur <= validintern1_next;
			validintern2_cur <= validintern2_next;
			Itemp1_cur <= Itemp1_next;
			Itemp2_cur <= Itemp2_next;
			Qtemp1_cur <= Qtemp1_next;
			Qtemp2_cur <= Qtemp2_next;
			I_temp_cur <= I_temp_next;
			Q_temp_cur <= Q_temp_next;
			lookup_cos_cur <= lookup_cos_next;
			lookup_sin_cur <= lookup_sin_next;

			--outputs
			validout <= validout_next;
			Iout <= Iout_next;
			Qout <= Qout_next;
		end if;
	end process sync;
	
end behavior;
