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
	
	constant order: natural := 4;--ist eigentlich 5 (order-1)
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

	signal valid_array_cur, valid_array_next: std_logic_vector(2*order-1 downto 0) := (others => '0');
	
	signal data_out_array_cur, data_out_array_next: fixpoint_array(2*order-1 downto 0);

	signal data_out_cur, data_out_next : fixpoint;
	
	signal validout_cur, validout_next: std_logic;
	
	type datashift_array is array(natural range <>) of integer;
	signal shift_array_x_cur, shift_array_x_next: datashift_array(order-1 downto 0) := (others => order-1);
	signal shift_array_y_cur, shift_array_y_next: datashift_array(order downto 0) := (others => 0);
	
	signal start_flag, start_flag_next, startout_flag, startout_flag_next: std_logic:='0';

begin
	compute: process (validin,data_in, validout_cur, xhist_cur, yhist_cur, data_out_cur,valid_array_cur, shift_array_x_cur, shift_array_y_cur,data_out_array_cur,startout_flag,start_flag)
		variable xhist_temp : fixpoint_array(order downto 0);
		variable data_out_temp : fixpoint;
	begin
		xhist_next <= xhist_cur;
		yhist_next <= yhist_cur;
		
		start_flag_next <= start_flag;
		startout_flag_next <= startout_flag;
		
		validout_next <= valid_array_cur(2*order-1);
		data_out_next <= data_out_cur;
		valid_array_next(2*order-1 downto 1) <= valid_array_cur(2*order-2 downto 0);
		valid_array_next(0) <= validin;
		data_out_array_next(0) <= (others => '0');
		
		for i in 1 to order-1 loop
			if(validin = '1') then
				shift_array_x_next(i) <= shift_array_x_cur(i-1);
			else
				shift_array_x_next(i) <= shift_array_x_cur(i-1)-1;
			end if;
		end loop;
		      
		if(valid_array_cur(order-1) = '1') then
		    start_flag_next <= '1';
		end if;
		
		if(valid_array_cur(2*order-1) = '1')then
		  startout_flag_next <= '1';
		end if;
		
		if(start_flag = '1' and startout_flag = '1' and valid_array_cur(order-1) = '0'  and valid_array_cur(2*order-1) = '0')then
				shift_array_y_next(0) <= shift_array_y_cur(0);
		elsif(start_flag = '1' and valid_array_cur(order-1) = '0'  and shift_array_y_cur(0) < order)then
				shift_array_y_next(0) <= shift_array_y_cur(0)+1;
                elsif(startout_flag = '1' and valid_array_cur(2*order-1) = '0' and shift_array_y_cur(0) >0) then
				shift_array_y_next(0) <= shift_array_y_cur(0)-1;
                end if;
		for i in 1 to order loop
                                if(valid_array_cur(2*order-1) = '0' and shift_array_y_cur(i-1) >0) then
                                shift_array_y_next(i) <= shift_array_y_cur(i-1)-1;
                                else
                                shift_array_y_next(i) <= shift_array_y_cur(i-1);
                                end if;
		end loop;

		--Vorbereitung
		if(validin = '1') then
			--shift xhist
			for i in 1 to order loop
				xhist_next(i) <= xhist_cur(i-1);
			end loop;

			xhist_next(0) <= data_in;
			
			data_out_array_next(0)<=fixpoint_mult(xhist_cur(order-1),b(order));
		end if;
		
		--add up
		--Invarianten
		for i in 1 to order loop
			data_out_array_next(i)<=data_out_array_cur(i-1)+fixpoint_mult(xhist_cur(shift_array_x_cur(i-1)),b(order-i));
		end loop;
		for i in 1 to order-1 loop
			if(shift_array_y_cur(i-1) < order) then
			  data_out_array_next(i+order)<=data_out_array_cur(i+order-1) - fixpoint_mult(yhist_cur(shift_array_y_cur(i-1)),a(order-i));
			end if;
		end loop;
		
		--Nachbereitung
		if(valid_array_cur(2*order-1) = '1') then
			data_out_temp := data_out_array_cur(2*order-1) - fixpoint_mult(yhist_cur(shift_array_y_cur(order)),a(0));

			--shift yhist
			for i in 1 to order-1 loop
				yhist_next(i) <= yhist_cur(i-1);
			end loop; 
			
			data_out_next  <= data_out_temp;
			yhist_next(0) <= data_out_temp;
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
			
			valid_array_cur<= valid_array_next;
			data_out_array_cur<=data_out_array_next;
			shift_array_x_cur<=shift_array_x_next;
			shift_array_y_cur<=shift_array_y_next;
			
			start_flag <= start_flag_next;
			startout_flag <= startout_flag_next;
			
			data_out <= data_out_next;
			validout <= validout_next;
		end if;
	end process sync;
		
end behavior;
