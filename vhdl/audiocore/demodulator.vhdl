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
	constant min1: fixpoint := x"FF000000";

	function fixpoint_mult(a,b:fixpoint) return fixpoint is
				variable result_full : fixpoint_product;
	begin
		result_full := a * b;

		return result_full(55 downto 24);
	end function;
begin

	do_demodulation: process (data_in_I,data_in_Q,validin_I, validin_Q)
	variable data_I: fixpoint;
	begin
		data_out_next <= data_out_cur;
		validout_next <= validout_cur;

		if(validin_I = '0' or validin_Q = '0') then
			validout_next <= '0';
		else
			validout_next <= '1';
			data_I := fixpoint_mult(data_in_I,data_con_I) - fixpoint_mult(data_in_Q,data_con_Q);
			data_con_I_next <= data_in_I;
			data_con_Q_next <= fixpoint_mult(min1,data_in_Q);
			data_out_next <= data_I;
		end if; 
	end process do_demodulation;

	sync: process (clk,res_n)
	begin
		if res_n = '0' then
			data_out_cur <= (others =>'0');
			validout_cur <= '0';
		elsif rising_edge(clk) then
			--internals
				data_out_cur <= data_out_next;
				validout_cur <= validout_next;
				data_con_I <= data_con_I_next;
				data_con_Q <= data_con_Q_next;
			--outputs
				data_out <= data_out_next;
				validout <= validout_next;
		end if;
	end process sync;

end behavior;
