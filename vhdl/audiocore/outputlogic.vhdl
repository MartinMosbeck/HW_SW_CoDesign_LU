library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.audiocore_pkg.all;

entity outputlogic is
	port 
	(
		clk : in std_logic;
		res_n : in std_logic;

		data_in : in fixedpoint;
		validin : in std_logic;
		
		data_out : out byte;
		validout : out std_logic
	);
end outputlogic;

architecture behavior of outputlogic is
	signal data_out_cur,data_out_next, data: fixedpoint;
	signal validout_cur, validout_next, valid :std_logic;
begin

	deci: decimator
	generic 
	(
		N => 2
	)	
	port map 
	(
		clk =>clk,
		res_n =>res_n,

		data_in =>data_in,
		validin =>validin,
		
		data_out =>data, 
		validout => valid
	);


	do_output: process (data,valid)
	begin
		data_out_next <= data_out_cur;
		validout_next <= validout_cur;

		if(valid = '0') then
			validout_next <= '0';
		else
			validout_next <= '1';
			
			data_out_next <=byte(round(30*data)+128);--!FIXEDPOINT2INT
		end if; 
	end process do_output;

	sync: process (clk,res_n)
	begin
		if res_n = '0' then
			data_out_cur <= (others =>'0');
			validout_cur <= '0';
		elsif rising_edge(clk) then
			--internals
				data_out_cur <= data_out_next;
				validout_cur <= validout_next;
			--outputs
				data_out <= data_out_next;
				validout <= validout_next;
		end if;
	end process sync;

end outputlogic;
