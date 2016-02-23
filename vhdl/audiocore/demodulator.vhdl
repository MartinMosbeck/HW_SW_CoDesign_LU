library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.audiocore_pkg.all;

entity demodulator is
	port 
	(
		clk : in std_logic;
		res_n : in std_logic;

		data_in_I : in fixpoint;
		data_in_Q : in fixpoint;
		validin_I : in std_logic;
		validin_Q : in std_logic;
		
		data_out : out fixpoint;
		validout : out std_logic
	);
end demodulator;

architecture behavior of demodulator is
	signal data_out_cur,data_out_next, data_con_I, data_con_Q, data_con_I_next, data_con_Q_next: fixpoint;
	signal validout_cur, validout_next :std_logic;
	constant min1: fixpoint := x"FFFF0000";

	signal validintern_cur, validintern_next: std_logic;
	signal data1_cur, data1_next, data2_cur, data2_next: fixpoint;

	function fixpoint_mult(a,b:fixpoint) return fixpoint is
				variable result_full : fixpoint_product;
	begin
		result_full := a * b;

		return result_full(47 downto 16);
	end function;
begin

	do_demodulation: process (data_in_I,data_in_Q,validin_I, data_out_cur, validout_cur, data_con_I, data_con_Q,validintern_cur, data1_cur, data2_cur)--,validin_Q
	begin
		data_out_next <= data_out_cur;
		validout_next <= validout_cur;
		data_con_I_next <= data_con_I;
		data_con_Q_next <= data_con_Q;
		data1_next <= data1_cur;
		data2_next <= data2_cur;
		validintern_next <= validintern_cur;

		if(validin_I = '0') then--bzw and validin_Q ='0'
			validintern_next <= '0';
		else
			validintern_next <= '1';
			data1_next <= fixpoint_mult(data_in_I,data_con_Q);
			data2_next <= fixpoint_mult(data_in_Q,data_con_I);
			data_con_I_next <= data_in_I;
			data_con_Q_next <= fixpoint_mult(min1,data_in_Q);
		end if; 

		if(validintern_cur = '1') then
			data_out_next <= data1_cur + data2_cur;
			validout_next <= '1';
		else
			validout_next <= '0';
		end if;
	end process do_demodulation;

	sync: process (clk,res_n)
	begin
		if res_n = '0' then
			data_out_cur <= (others =>'0');
			validout_cur <= '0';

			data_con_I <= (others => '0');
			data_con_Q <= (others => '0');

			data1_cur <= (others => '0');
			data2_cur <= (others => '0');
			validintern_cur <= '0';
		elsif rising_edge(clk) then
			--internals
				data_out_cur <= data_out_next;
				validout_cur <= validout_next;
				data_con_I <= data_con_I_next;
				data_con_Q <= data_con_Q_next;

				data1_cur <= data1_next;
				data2_cur <= data2_next;
				validintern_cur <= validintern_next;
			--outputs
				data_out <= data_out_next;
				validout <= validout_next;
		end if;
	end process sync;

end behavior;
