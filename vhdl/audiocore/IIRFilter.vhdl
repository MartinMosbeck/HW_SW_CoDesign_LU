library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.audiocore_pkg.all;


entity IIRFilter is	
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
	
	constant order: natural := 4;
	function a(index:index) 
		return fixpoint is
	begin 
		case index is
		    when 0 =>
			    return "11111111111111000001110001000001";
		    when 1 =>
			    return "00000000000001011011001001111011";
		    when 2 =>
			    return "11111111111111000100011010110000";
		    when 3 =>
			    return "00000000000000001110101010011011";
		    when others=> return x"FFFFFFFF";
		end case;
	end function;
	function b(index:index) 
		return fixpoint is
	begin 
		case index is
		     when 0 =>
			    return "00000000000000000000000001001010";
		    when 1 =>
			    return "11111111111111111111111100001000";
		    when 2 =>
			    return "00000000000000000000000101100000";
		    when 3 =>
			    return "11111111111111111111111100001000";
		    when 4 =>
			    return "00000000000000000000000001001010";
		    when others=> return x"FFFFFFFF";
		end case;
	end function;


	signal xhist_cur,xhist_next : fixpoint_array (order downto 0) := (others =>  (others => '0'));
	signal yhist_cur,yhist_next : fixpoint_array (order-1 downto 0) := (others => (others => '0'));

	signal data_out_cur, data_out_next : fixpoint;
	
	signal validout_cur, validout_next: std_logic;

begin
	compute: process (validin,data_in, validout_cur, xhist_cur, yhist_cur, data_out_cur)
		variable xhist_temp : fixpoint_array(order downto 0);
		variable data_out_temp : fixpoint;
	begin
		data_out_next <= data_out_cur;
		validout_next <= validout_cur;
		xhist_next <= xhist_cur;
		yhist_next <= yhist_cur;

		if(validin = '1') then
			data_out_temp := (others => '0');

			--shift xhist
			for i in 1 to order loop
				xhist_temp(i) := xhist_cur(i-1);
			end loop;

			xhist_temp(0) := data_in;
			
			--add up

			for i in 0 to order loop
				data_out_temp := data_out_temp + fixpoint_mult(xhist_temp(i),b(i));
			end loop;

			for i in 0 to order-1 loop
				data_out_temp := data_out_temp + fixpoint_mult(yhist_cur(i),a(i));
			end loop;

			--shift yhist
			for i in 1 to order-1 loop
				yhist_next(i) <= yhist_cur(i-1);
			end loop; 
		
			yhist_next(0) <= data_out_temp;

			data_out_next <= data_out_temp;
			validout_next <= '1';
			
			xhist_next <= xhist_temp;
		else
			validout_next <= '0';
		end if;

	end process compute;

	sync: process (clk,res_n)	
	begin
		if(res_n = '0') then
			xhist_cur <= (others => (others => '0'));
			yhist_cur <= (others => (others => '0'));
			data_out_cur <= (others => '0');
			validout_cur <= '0';
		elsif(rising_edge(clk)) then
			xhist_cur <= xhist_next;
			yhist_cur <= yhist_next;
			data_out_cur <= data_out_next;
			validout_cur <= validout_next;
			
			data_out <= data_out_next;
			validout <= validout_next;
		end if;
	end process sync;
		
end behavior;
