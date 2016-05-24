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
	
	--IIR-FILTER: Nachfolgend die Filterordnung eintragen, und die Koeffizienten a[x] und b[x]
	--Koeffizienten in der Form 16 Vorkomma/16 Nachkomma Stellen Zweierkomplement Fixpunkt
	--SONST NIX ÄNDERN IM FILTER, da rennt ziemlich perverse Scheisse unten ab
	--Die Filterordnung passt so, die Ordnung beim IIR ist die Anzahl der a-Koeffizienten (=b-1)
	constant order: natural := 4;
	function a(index:index) 
		return fixpoint is
	begin 
		case index is
		    when 0 =>
			    return "11111111111111000001110001000001";--FFFC 1C41
		    when 1 =>
			    return "00000000000001011011001001111011";--5 B27B
		    when 2 =>
			    return "11111111111111000100011010110000";--FFFC 46B0
		    when 3 =>
			    return "00000000000000001110101010011011";--EA9B
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

	--Die verzögerten x[k] und y[k]
	signal xhist_cur,xhist_next : fixpoint_array (order downto 0) := (others =>  (others => '0'));
	signal yhist_cur,yhist_next : fixpoint_array (order-1 downto 0) := (others => (others => '0'));
	--Die Pipeline (valid und Daten)
	signal valid_array_cur, valid_array_next: std_logic_vector(2*order-1 downto 0) := (others => '0');
	signal data_out_array_cur, data_out_array_next: fixpoint_array(2*order-1 downto 0);
	--Ausgangssignale
	signal data_out_cur, data_out_next : fixpoint;
	signal validout_cur, validout_next: std_logic;
	--Versatzarrays (um für jeden a[i] und b[i] jedes Datums den richtigen x[k] und y[k] in der Pipeline zuweisen zu können)
	type datashift_array is array(natural range <>) of natural range 0 to order;
	signal shift_array_x_cur, shift_array_x_next: datashift_array(order-1 downto 0) := (others => order-1);
	signal shift_array_y_cur, shift_array_y_next: datashift_array(order downto 0) := (others => 0);
	--Signale um das "Hochlaufen" des Filters gesondert zu behandeln (bis die Pipeline Daten empfangen hat)
	signal start_flag, start_flag_next, startout_flag, startout_flag_next: std_logic:='0';
	
	signal rdy, rdy_next: std_logic := '0';
	signal valid_buffer_in, valid_buffer_in_next, valid_buffer_out, valid_buffer_out_next : std_logic;
	signal data_buffer_out, data_buffer_out_next, data_buffer_in, data_buffer_in_next : fixpoint;
begin
	IIR_Buffer: IIRFilter_Buffer
	generic map
	(
		N => 32
	)
	port  map
	(
		clk => clk,
		res_n => res_n,
		data_in => data_buffer_in,
		validin => valid_buffer_in,
		rdy => rdy,
		validout => valid_buffer_out,
		data_out => data_buffer_out
	);

	compute: process (validin,data_in, validout_cur, xhist_cur, yhist_cur, data_out_cur,valid_array_cur, shift_array_x_cur, shift_array_y_cur,data_out_array_cur,startout_flag,start_flag, valid_buffer_in, valid_buffer_out, rdy, data_buffer_out)
		variable data_out_temp : fixpoint;
	begin
		--Latches
		xhist_next <= xhist_cur;
		yhist_next <= yhist_cur;
		data_out_array_next(0) <= (others => '0');
		data_out_next <= data_out_cur;
		rdy_next <= '1';
		
		--Startbehandlung: Der Filter muss zuerst die Pipeline bis zum FIR-Teil bzw. IIR-Teil mit einem Eingangsdatum
		--durchlaufen haben, dass die Versatz-Korrekturen anfangen dürfen (sonst verschieben diese wegen der leeren 
		--Filterpipeline die Korrektur schon vorher und damit falsch) [nur für FIR-Anteil notwendig]
		start_flag_next <= start_flag;
		startout_flag_next <= startout_flag;
		if(valid_array_cur(order-1) = '1') then--Ende FIR-Teil
		    start_flag_next <= '1';
		end if;
		if(valid_array_cur(2*order-1) = '1')then--Ende IIR-Teil=Filterende
		  startout_flag_next <= '1';
		end if;
		
		--VALIDPIPELINE
		--validin durch die Pipeline bis zu validout durchschieben (einfache Kette)
		validout_next <= valid_array_cur(2*order-1);
		--valid_array_next(2*order-1 downto 1) <= valid_array_cur(2*order-2 downto 0);
		valid_array_next(order downto 1) <= valid_array_cur(order-1 downto 0);
		valid_buffer_in_next <= valid_array_next(order);
		valid_array_next(order+1) <= valid_buffer_out;
		valid_array_next(2*order-1 downto order+2) <= valid_array_cur(2*order-2 downto order+1);
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
		
		--Versatz-Korrektur für den IIR-Teil (erst wenn ein Datum in der Pipeline teil- bzw. vollständig durch ist)
		--Versatz-Korrektur für den initialen Startwert des IIR-Teiles (von dem beginnt jedes Datum, dass in den IIR-Teil eintritt)
		if(start_flag = '1' and startout_flag = '1' and valid_array_cur(order-1) = '0'  and valid_array_cur(2*order-1) = '0')then
			--Invalides Datum kommt vom FIR zum IIR und gleichzeitig wird ein invalides am Ende aus der Pipeline genommen
			shift_array_y_next(0) <= shift_array_y_cur(0);
		elsif(start_flag = '1' and valid_array_cur(order-1) = '0'  and shift_array_y_cur(0) < order)then
			--Invalides Datum kommt vom FIR zum IIR
			shift_array_y_next(0) <= shift_array_y_cur(0)+1;
        elsif(startout_flag = '1' and valid_array_cur(2*order-1) = '0' and shift_array_y_cur(0) >0) then
			--Invalides Datum wird am Ende der Pipeline herausgenommen
			shift_array_y_next(0) <= shift_array_y_cur(0)-1;
		else
			shift_array_y_next(0) <= shift_array_y_cur(0);
		end if;
        --Versatz-Korrektur für die Daten in dem IIR-Teil (wenn ein invalides Datum rausgenommen wird haben alle nachfolgenden
        --Daten einen Versatz um 1 während sie gerade im IIR-Teil sind)
		for i in 1 to order loop
			if(valid_array_cur(2*order-1) = '0' and shift_array_y_cur(i-1) >0) then
				shift_array_y_next(i) <= shift_array_y_cur(i-1)-1;
			else
				shift_array_y_next(i) <= shift_array_y_cur(i-1);
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
		for i in 1 to order loop
			data_out_array_next(i)<=data_out_array_cur(i-1)+fixpoint_mult(xhist_cur(shift_array_x_cur(i-1)),b(order-i));
		end loop;
		data_buffer_in_next <= data_out_array_cur(order);
		for i in 1 to order-1 loop
			if(rdy = '1' and shift_array_y_cur(i-1) < order) then
				--Wenn mindestens order invalide Daten hintereinander kommen sind nachfolgend alle shift_array_y_cur = order
				data_out_array_next(i+order)<=data_buffer_out - fixpoint_mult(yhist_cur(shift_array_y_cur(i-1)),a(order-i));
			else
				data_out_array_next(i+order)<=data_out_array_cur(i+order);
			end if;
		end loop;
		
		--Nachbereitung
		if(valid_array_cur(2*order-1) = '1') then
			data_out_temp := data_out_array_cur(2*order-1) - fixpoint_mult(yhist_cur(shift_array_y_cur(order)),a(0));

			--shift yhist
			for i in 1 to order-1 loop
				yhist_next(i) <= yhist_cur(i-1);
			end loop; 
			yhist_next(0) <= data_out_temp;

			data_out_next  <= data_out_temp;
			
			rdy_next <= '0';
		end if;

	end process compute;

	sync: process (clk,res_n)	
	begin
		if(res_n = '0') then
			xhist_cur <= (others => (others => '0'));
			yhist_cur <= (others => (others => '0'));
			data_out_cur <= (others => '0');
			validout_cur <= '0';
			valid_array_cur <= (others => '0');
			data_out_array_cur <= (others => (others => '0'));
			shift_array_x_cur <= (others => order-1);
			shift_array_y_cur <= (others => 0);
			start_flag <= '0';
			startout_flag <= '0';
			
			rdy <= '0';
			valid_buffer_in <= '0';
			valid_buffer_out <= '0';
			data_buffer_in <= (others => '0');
			data_buffer_out <= (others => '0');
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
			
			rdy <= rdy_next;
			valid_buffer_in <= valid_buffer_in_next;
			valid_buffer_out <= valid_buffer_out_next;
			data_buffer_in <= data_buffer_in_next;
			data_buffer_out <= data_buffer_out_next;
			
			data_out <= data_out_next;
			validout <= validout_next;
		end if;
	end process sync;
		
end behavior;
