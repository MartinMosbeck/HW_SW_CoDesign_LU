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
	--Die Filterordnung passt so, die Ordnung beim IIR ist die Anzahl der a-Koeffizienten (=b-1)
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

	--Die verzögerten x[k] und y[k]
	signal xhist_cur,xhist_next : fixpoint_array (order downto 0) := (others =>  (others => '0'));
	signal yhist_cur,yhist_next : fixpoint_array (order-1 downto 0) := (others => (others => '0'));
	--Die Pipeline (valid und Daten)
	signal valid_array_cur, valid_array_next: std_logic_vector(2*order-1 downto 0) := (others => '0');
	signal data_out_array_cur, data_out_array_next: fixpoint_array(2*order-1 downto 0) := (others => (others => '0'));
	--Ausgangssignale
	signal data_out_cur, data_out_next : fixpoint;
	signal validout_cur, validout_next: std_logic;
	--Signale um das "Hochlaufen" des Filters gesondert zu behandeln (bis die Pipeline (fast) voll ist)
	signal start_flag, start_flag_next: std_logic:='0';
	constant full: std_logic_vector(2*order-1 downto 0):= (others => '1');
	
	signal rdy_vor, valid_vor_next: std_logic;
	
	signal valid_buffer_out: std_logic;
	signal data_buffer_out: fixpoint;
	
	signal valid_buffer_in, valid_buffer_in_next : std_logic;
	signal data_out_tmp_cur, data_out_tmp_next: fixpoint;
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
		data_in => data_out_array_cur(order),
		validin => valid_buffer_in,
		rdy => valid_array_cur(order-1),
		validout => valid_buffer_out,
		data_out => data_buffer_out,
		validout_vor => valid_vor_next
	);
	
	compute: process (validin,data_in, xhist_cur, yhist_cur, data_out_cur,valid_array_cur, data_out_array_cur,start_flag,validout_cur, data_buffer_out, valid_buffer_out)
		variable data_out_temp : fixpoint;--valiout_cur in sensitivy list zum besseren simulieren, sonst unnötig hier drin
	begin
		--Latches
		xhist_next <= xhist_cur;
		if(start_flag = '0')then
			yhist_next <= yhist_cur;
		end if;
		data_out_next <= data_out_tmp_cur;
		data_out_tmp_next <= data_out_tmp_cur;
		for i in 0 to 2*order-1 loop
			data_out_array_next(i)<=data_out_array_cur(i);
		end loop;
		validout_next<='0';
		
		--VALIDPIPELINE
		--Jedesmal wenn validin 1 ist wird ein bit zusätzlich aufgefüllt in die Pipeline
		--ist die pipeline voll bis zum vorletzten Platz dann sind da nur einser drin
		--Wird nur benötigt für die Startbehandlung, validout wird beim raushiften gesondert behandelt
		if(validin='1')then
		       valid_array_next(0) <= '1';
		       valid_array_next(order downto 1) <= valid_array_cur(order-1 downto 0);
		end if;
		if(valid_buffer_out = '1')then
			valid_array_next(order+1) <= '1';
			valid_array_next(2*order-1 downto order+2) <= valid_array_cur(2*order-2 downto order+1);
		end if;
		--Startbehandlung: Auch im einfachen Filter nötig, die Pipeline muss dafür vollständig mit Daten
		--sein ausgenommen dem letzten Pipelineplatz, da wird dann erstmals ein durchshiften gemacht
		start_flag_next <= start_flag;
		if(valid_array_cur = full) then
		    start_flag_next <= '1';
		end if;

		valid_buffer_in_next <= '0';
		--DATENPIPELINE
		--Vorbereitung und Invarianten
		if(validin = '1') then
			valid_buffer_in_next <= '1';
			--shift xhist
			for i in 1 to order loop
				xhist_next(i) <= xhist_cur(i-1);
			end loop;
			xhist_next(0) <= data_in;

			data_out_array_next(0)<=fixpoint_mult(xhist_cur(order-1),b(order));
			
			--add up
			for i in 1 to order loop
				data_out_array_next(i)<=data_out_array_cur(i-1)+fixpoint_mult(xhist_cur(order-1),b(order-i));
			end loop;
		end if;
		
		if(valid_buffer_out = '1')then
			data_out_array_next(order+1) <= data_buffer_out - yhist_cur(order-1);--fixpoint_mult(yhist_cur, a(order-1));
			for i in 2 to order-1 loop
				data_out_array_next(i+order)<=data_out_array_cur(i+order-1) - yhist_cur(order-i);--fixpoint_mult(yhist_cur,a(order-i));
			end loop;
		end if;
		
		--Nachbereitung
		if(start_flag='1' and valid_buffer_out = '1') then
			data_out_temp := data_out_array_cur(2*order-1) - yhist_cur(0);--fixpoint_mult(yhist_cur,a(0));
			--yhist_next <= data_out_temp;
			for i in 0 to order-1 loop
				yhist_next(i) <= fixpoint_mult(data_out_temp,a(i));
			end loop;
			data_out_tmp_next  <= data_out_temp;
			validout_next <= '1';
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
			start_flag <= '0';
			valid_buffer_in <= '0';
			data_out_tmp_cur <= (others => '0');
		elsif(rising_edge(clk)) then
			xhist_cur <= xhist_next;
			if(valid_buffer_out = '0')then
				yhist_cur <= yhist_next;
			else
				yhist_cur <= yhist_cur;
			end if;
			valid_buffer_in<=valid_buffer_in_next;
			
			data_out_tmp_cur <= data_out_tmp_next;
			data_out_cur <= data_out_next;
			validout_cur <= validout_next;
			valid_array_cur<= valid_array_next;
			data_out_array_cur<=data_out_array_next;
			start_flag <= start_flag_next;
			
			data_out <= data_out_cur;
			validout <= validout_cur;
		end if;
	end process sync;
		
end behavior;
