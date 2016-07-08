library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.audiocore_pkg.all;


entity FIRFilter is
	port 
	(
		clk 		: in std_logic;
		res_n 		: in std_logic;

		data_in 	: in fixpoint;
		validin 	: in std_logic;

		data_out 	: out fixpoint;
		validout 	: out std_logic
	);
end FIRFilter;

architecture behavior of FIRFilter is
	function fixpoint_mult(a,b:fixpoint) return fixpoint is
		variable result_full : fixpoint_product;
	begin
		result_full := a * b;

		return result_full(47 downto 16);
	end function;
	
	--IIR-FILTER: Nachfolgend die Filterordnung eintragen, und die Koeffizienten a[x] und b[x]
	--Koeffizienten in der Form 16 Vorkomma/16 Nachkomma Stellen Zweierkomplement Fixpunkt
	--SONST NIX ÄNDERN IM FILTER, da rennt ziemlich perverse Scheisse unten ab
	--Die Filterordnung passt so, die Ordnung beim IIR ist die Anzahl der a-Koeffizienten (=b-1)
	constant order: natural := 4;
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

	--Die verzögerten x[k] und y[k]
	signal xhist_cur,xhist_next : fixpoint_array (order downto 0) := (others =>  (others => '0'));
	--Die Pipeline (valid und Daten)
	signal valid_array_cur, valid_array_next: std_logic_vector(order-1 downto 0) := (others => '0');
	signal data_out_array_cur, data_out_array_next: fixpoint_array(order-1 downto 0);
	--Ausgangssignale
	signal data_out_cur, data_out_next : fixpoint;
	signal validout_cur, validout_next: std_logic;
	--Versatzarrays (um für jeden a[i] und b[i] jedes Datums den richtigen x[k] und y[k] in der Pipeline zuweisen zu können)
	type datashift_array is array(natural range <>) of natural range 0 to order;
	signal shift_array_x_cur, shift_array_x_next: datashift_array(order-1 downto 0) := (others => order-1);
begin
	compute: process (validin,data_in, validout_cur, xhist_cur, data_out_cur,valid_array_cur, shift_array_x_cur,data_out_array_cur)
	begin
		--Latches
		xhist_next <= xhist_cur;
		data_out_array_next(0) <= (others => '0');
		data_out_next <= data_out_cur;
		
		
		--VALIDPIPELINE
		--validin durch die Pipeline bis zu validout durchschieben (einfache Kette)
		validout_next <= valid_array_cur(order-1);
		valid_array_next(order-1 downto 1) <= valid_array_cur(order-2 downto 0);
		valid_array_next(0) <= validin;
		
		--VERSATZ-KORREKTUR
		--Versatz-Korrektur für FIR-Teil (=index des xhist belassen oder ändern für nächste
		--FIR-Koeffizienten-Multiplikation
		for i in 1 to order-1 loop
			if(validin = '1') then
				shift_array_x_next(i) <= shift_array_x_cur(i-1);
			else
				shift_array_x_next(i) <= shift_array_x_cur(i-1)-1;
			end if;
		end loop;

		--DATENPIPELINE
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
		for i in 1 to order-1 loop
			data_out_array_next(i)<=data_out_array_cur(i-1)+fixpoint_mult(xhist_cur(shift_array_x_cur(i-1)),b(order-i));
		end loop;
		
		--Nachbereitung
		if(valid_array_cur(order-1) = '1') then
			data_out_next <= data_out_array_cur(order-1) + fixpoint_mult(xhist_cur(shift_array_x_cur(order-1)),b(0));
		end if;

	end process compute;

	sync: process (clk,res_n)	
	begin
		if(res_n = '0') then
			xhist_cur <= (others => (others => '0'));
			data_out_cur <= (others => '0');
			validout_cur <= '0';
			valid_array_cur <= (others => '0');
			data_out_array_cur <= (others => (others => '0'));
			shift_array_x_cur <= (others => order-1);
		elsif(rising_edge(clk)) then
			xhist_cur <= xhist_next;
			data_out_cur <= data_out_next;
			validout_cur <= validout_next;
			valid_array_cur<= valid_array_next;
			data_out_array_cur<=data_out_array_next;
			shift_array_x_cur<=shift_array_x_next;
			
			data_out <= data_out_next;
			validout <= validout_next;
		end if;
	end process sync;
		
end behavior;