library IEEE;
use IEEE.std_logic_1164.all;

library ieee_proposed;
use ieee_proposed.fixed_float_types.all;
use ieee_proposed.fixed_pkg.all;

library work;
use work.audiocore_pkg.all;

entity demodulator is
	port 
	(
		clk : in std_logic;
		res_n : in std_logic;

		data_in_I : in sfixed(7 downto -24);
		data_in_Q : in sfixed(7 downto -24);
		validin_I : in std_logic;
		validin_Q : in std_logic;
		
		data_out : out sfixed(7 downto -24);
		validout : out std_logic
	);
end demodulator;

architecture behavior of demodulator is
	signal data_out_cur,data_out_next, data_con_I, data_con_Q, data_con_I_next, data_con_Q_next: sfixed(7 downto -24);
	signal validout_cur, validout_next :std_logic;
	variable data_I, data_Q: sfixed(7 downto -24);
begin

	do_demodulation: process (data_in,validin_I, validin_Q)
	begin
		data_out_next <= data_out_cur;
		validout_next <= validout_cur;

		if(validin_I = '0' or validin_Q = '0') then
			validout_next <= '0';
		else
			validout_next <= '1';
			data_I := data_in_I * data_con_I - data_in_Q * data_con_Q;
			data_Q := data_in_I * data_con_Q + data_con_I * data_in_Q;
			data_con_I_next <= data_in_I;
			data_con_Q_next <= -data_in_Q;
			data_out_next <= arctan(data_Q/data_I);
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

end demodulator;
