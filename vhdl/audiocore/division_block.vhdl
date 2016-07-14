library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.audiocore_pkg.all;

entity division_block is
	port 
	(
		clk : in std_logic;
		res_n : in std_logic;

		div_in1 : in fixpoint;
		div_in2 : in fixpoint;
		validin : in std_logic;

		div_out : out fixpoint;
		validout : out std_logic
	);
end division_block;


architecture behavior of division_block is
	signal sign_array_cur, sign_array_next: std_logic_vector(62 downto 0);
	signal valid_array_next,valid_array_cur: std_logic_vector(62 downto 0);
	signal akku_array_cur, akku_array_next: fixpoint_array (62 downto 0) := (others => (others => '0'));
	signal divisor_array_cur, divisor_array_next: fixpoint_array(62 downto 0);
	signal dividend_array_cur, dividend_array_next: fixpoint_array(62 downto 0);
	signal data_out_cur, data_out_next: fixpoint;
	signal validout_cur, validout_next: std_logic;
	
	type double_array is array(natural range <>) of signed(63 downto 0);
	signal quotient_array_cur, quotient_array_next: double_array(62 downto 0);
begin
	do_division: process(validin, valid_array_cur, sign_array_cur, div_in1, div_in2, dividend_array_cur, akku_array_cur, quotient_array_cur, divisor_array_cur)
		variable sign1,sign2:std_logic;
		variable in1,in2:fixpoint;
		variable akku_tmp:fixpoint_array(62 downto 0);
		variable sol: fixpoint;
	begin
		valid_array_next(62 downto 1)<= valid_array_cur(61 downto 0);
		sign_array_next(62 downto 1) <= sign_array_cur(61 downto 0);

		--Init
		if(validin = '1') then
			--Unsign
			if(div_in1(31)='1')then
				sign1:='1';
				in1:=not(div_in1 - 1);
			else
				sign1:='0';
			end if;
			if(div_in2(31)='1')then
				sign2:='1';
				in2:=not(div_in1 - 1);
			else
				sign2:='0';
			end if;
			sign_array_next(0) <= sign1 xor sign2;
			dividend_array_next(0) <= in1;
			divisor_array_next(0) <= in2;
			
			valid_array_next(0) <= '1';
		else
			valid_array_next(0) <= '0';
		end if;
		
		--invarianten
		for i in 1 to 62 loop
			if(i <= 32 and dividend_array_cur(i-1)(32-i) = '1')then
				akku_tmp(i) := akku_array_cur(i-1)(31 downto 1) & '1';
			else
				akku_tmp(i) := akku_array_cur(i-1) sll 1;
			end if;
			if(divisor_array_cur(i-1) < akku_tmp(i))then
				quotient_array_next(i) <= quotient_array_cur(i-1)(63 downto 1) & '1';
				akku_array_next(i) <= akku_tmp(i) - divisor_array_cur(i-1);
			else
				quotient_array_next(i) <= quotient_array_cur(i-1) sll 1;
				akku_array_next(i) <= akku_tmp(i);
			end if;
		end loop;
		
		--exit
		if(valid_array_cur(62)='1')then
			--Resign
			if(sign_array_cur(62) = '1')then
				sol := (not quotient_array_cur(62)(45 downto 14)) + 1;
			else
				sol := quotient_array_cur(62)(45 downto 14);
			end if;
			data_out_next <= sol;
			validout_next <= '1';
		else
			data_out_next <= data_out_cur;
			validout_next <= '0';
		end if;
	end process do_division;

	sync: process (clk,res_n)
	begin
		if res_n = '0' then
			sign_array_cur <= (others => '0');
			valid_array_cur <= (others => '0');
			akku_array_cur <= (others => (others => '0'));
			divisor_array_cur <= (others => (others => '0'));
			dividend_array_cur <= (others => (others => '0'));
			quotient_array_cur <= (others => (others => '0'));
			data_out_cur <= (others => '0');
			validout_cur <= '0';
		elsif rising_edge(clk) then
			--internals
			sign_array_cur <= sign_array_next;
			valid_array_cur <= valid_array_next;
			akku_array_cur <= akku_array_next;
			divisor_array_cur <= divisor_array_next;
			dividend_array_cur <= dividend_array_next;
			quotient_array_cur <= quotient_array_next;
			data_out_cur <= data_out_next;
			validout_cur <= validout_next;

			--outputs
			div_out <= data_out_next;
			validout <= validout_next;
		end if;
	end process sync;
end behavior;