library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.audiocore_pkg.all;


entity IIRFilter is
	generic 
	(
		order 		: natural;
		a 			: fixpoint_array (order-1 downto 0);
		b 			: fixpoint_array (order downto 0)
	);	
	port 
	(
		clk 		: in std_logic;
		res_n 		: in std_logic;

		data_in 	: in fixpoint;
		validin 	: in std_logic;

		data_out 	: out fixpoint;
		validout 	: out std_logic
	);
end IIRFilter;

architecture behavior of IIRFIlter is
	function fixpoint_mult(a,b:fixpoint) return fixpoint is
		variable result_full : fixpoint_product;
	begin
		result_full := a * b;

		return result_full(47 downto 16);
	end function;


	signal xhist_cur,xhist_next : fixpoint_array (order downto 0) := (others =>  others => '0'));
	signal yhist_cur,yhist_next : fixpoint_array (order-1 downto 0) := (others => (others => '0'));

	signal data_out_cur, data_out_next : fixpoint;

begin
	compute: process (validin,data_in)
		variable xhist_temp : fixpoint_array(order downto 0);
		variable yhist_temp : fixpoint_array(order-1 downto 0);
		variable data_out_temp : fixpoint;
	begin
		data_out_next <= data_out_cur;
		validout_next <= validout_cur;
		xhist_next <= xhist_cur;
		yhist_next <= yhist_cur;

        if(validin)
			xhist_temp := xhist_cur;
			yhist_temp := yhist_cur;
			data_out_temp := 0;

			--shift xhist
			for i in 1 to order loop
				xhist_temp(i) := xhist_temp(i-1);
			end loop;

			xhist_temp(0) := data_in;
			
			--add up

			for i in 0 to order loop
				data_out_temp := data_out_temp + fixpoint_mult(xhist_temp(i),b(i));
			end loop;

			for i in 0 to order-1 loop
				data_out_temp := data_out_temp + fixpoint_mult(yhist_temp(i),a(i));
			end loop;

			--shift yhist
			for i in 1 to order-1 loop
				yhist_temp(i) := yhist_temp(i-1);
			end loop; 
		
			yhist_temp(0) := data_out_temp;

			data_out_next <= data_out_temp;
			validout_next <= '1';
		else
			validout_next <= '0';
		end if;

	end process compute;

	sync: process (clk,rst_n)	
	begin
		if(rst_n = '0') then
			xhist_cur <= (others => (others => '0'));
			yhist_cur <= (others => (others => '0'));
			data_out_cur <= (others => '0');
			validout_cur <= '0';
		elsif(rising_edge(clk))
			xhist_cur <= xhist_next;
			yhist_cur <= yhist_next;
			data_out_cur <= data_out_next;
			validout_cur <= validout_next;
		end if;
	end process sync;
		
end behavior;
