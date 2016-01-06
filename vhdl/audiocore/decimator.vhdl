library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.audiocore_pkg.all;

entity decimator is
	generic 
	(
		N : integer
	);	
	port 
	(
		clk : in std_logic;
		res_n : in std_logic;

		data_in : in fixedpoint;
		validin : in std_logic;
		
		data_out : out fixedpoint;
		validout : out std_logic
	);
end decimator;

architecture behavior of decimator is
	signal data_out_cur,data_out_next : fixedpoint;
	signal validout_cur, validout_next :std_logic;
	signal cnt_cur, cnt_next : integer range 0 to N-1;
begin

	do_decimation: process (data_in,validin)
	begin
		data_out_next <= data_out_cur;
		validout_next <= validout_cur;
		cnt_next <= cnt_cur;

		if(validin = '0') then
			validout_next <= '0';
		else
			if(cnt_cur = N-1) then
				cnt_next <= 0;
				validout_next <= '1';
				data_out_next <= data_in;
			else
				validout_next <= '0';
				cnt_next <= cnt_cur + 1;
			end if;
		end if; 
	end process do_decimation;

	sync: process (clk,res_n)
	begin
		if res_n = '0' then
			data_out_cur <= (others =>'0');
			validout_cur <= '0';
			cnt_cur <= 0;
		elsif rising_edge(clk) then
			--internals
				data_out_cur <= data_out_next;
				validout_cur <= validout_next;
				cnt_cur <= cnt_next;	
			--outputs
				data_out <= data_out_next;
				validout <= validout_next;
		end if;
	end process sync;

end behavior;
