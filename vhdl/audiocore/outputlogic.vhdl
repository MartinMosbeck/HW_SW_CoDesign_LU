library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.audiocore_pkg.all;

entity outputlogic is
	port 
	(
		clk : in std_logic;
		res_n : in std_logic;

		data_in : in fixpoint;
		validin : in std_logic;
		
		data_out : out byte;
		validout : out std_logic
	);
end outputlogic;

architecture behavior of outputlogic is
	signal data_out_cur,data_out_next : byte; 
	signal data : fixpoint;
	signal validout_cur, validout_next, valid : std_logic;

	function fixpoint_mult(a,b:fixpoint) return fixpoint is
				variable result_full : fixpoint_product;
	begin
		result_full := a * b;

		return result_full(47 downto 16);
	end function;
begin

	deci: decimator
	generic map
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


	do_output: process (data,valid, data_out_cur, validout_cur)
		constant factor : fixpoint := x"00000300";
		variable data_fixp : fixpoint;
		variable data_out_fixp: fixpoint;
		constant v127 : fixpoint := "00000000011111110000000000000000";
	begin
		data_out_next <= data_out_cur;
		validout_next <= validout_cur;

		if(valid = '0') then
			validout_next <= '0';
		else
			validout_next <= '1';

			data_fixp := fixpoint_mult(data,factor);
			data_out_fixp := data_fixp + v127;
			data_out_next <= std_logic_vector(data_out_fixp(23 downto 16));
			
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

end behavior;
