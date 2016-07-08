library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.audiocore_pkg.all;

entity demodulator_FIR is
	port 
	(
		clk : in std_logic;
		res_n : in std_logic;

		data_in_I : in fixpoint;
		data_in_Q : in fixpoint;
		validin_I : in std_logic;
		validin_Q : in std_logic;
		
		data_out : out fixpoint;
		validout : out std_logic
	);
end demodulator_FIR;

architecture behavior of demodulator_FIR is
	constant order: natural := 30; --Die Filterordnung von FIRFilter_demod
	constant max: natural := order + 15 - 1;--Filterordnung + 15 delay - 1 für insgesamt order+15 arrayelemente
	--do_demodulation-process
	signal data_out_cur,data_out_next, data_con_I, data_con_Q, data_con_I_next, data_con_Q_next: fixpoint;
	signal validout_cur, validout_next :std_logic;
	signal validintern_cur, validintern_next: std_logic := '0';
	signal data1_cur, data1_next, data2_cur, data2_next: fixpoint;
	signal normalI_array_cur, normalI_array_next, normalQ_array_cur, normalQ_array_next: fixpoint_array(max downto 0):=(others =>  (others => '0'));
	--filter-signale
	signal filteredI, filteredQ: fixpoint;
	signal validin_FIRI, validin_FIRQ: std_logic;
	--normalization-process
	signal valid_to_FIR_cur, valid_to_FIR_next: std_logic;
	signal normalI_cur, normalI_next, normalQ_cur, normalQ_next: fixpoint;
	--sqrt-signale
	signal data_sqrt_I, data_sqrt_Q, sqrt: fixpoint;
	signal validin_sqrt: std_logic;
	--prepare_sqrt-process
	signal data_to_sqrt_I_cur, data_to_sqrt_I_next, data_to_sqrt_Q_cur, data_to_sqrt_Q_next, input_to_sqrt_cur, input_to_sqrt_next: fixpoint;
	signal valid_to_sqrt_cur, valid_to_sqrt_next: std_logic;
	
	
	function fixpoint_mult(a,b:fixpoint) return fixpoint is
				variable result_full : fixpoint_product;
	begin
		result_full := a * b;

		return result_full(47 downto 16);
	end function;
	
	function fixpoint_div(a,b:fixpoint) return fixpoint is
				variable result_full : fixpoint_product;
	begin
		result_full := a / b;

		return result_full(47 downto 16);
	end function;
begin

	prepare_sqrt: process(data_in_I, data_in_Q,validin_I, data_to_sqrt_I_cur, data_to_sqrt_Q_cur, input_to_sqrt_cur)
	begin
		data_to_sqrt_I_next <= data_to_sqrt_I_cur;
		data_to_sqrt_Q_next <= data_to_sqrt_Q_cur;
		input_to_sqrt_next <= input_to_sqrt_cur;

		if(validin_I = '1') then
			data_to_sqrt_I_next <= data_in_I;
			data_to_sqrt_Q_next <= data_in_Q;
			--Das braucht eventuell 2 Takte
			input_to_sqrt_next <= fixpoint_mult(data_in_I,data_in_I) + fixpoint_mult(data_in_Q,data_in_Q);
			valid_to_sqrt_next <= '1';
		else
			valid_to_sqrt_next <= '0';
		end if;
	end process prepare_sqrt;

	--Ultrafastsqrt(~10% ungenauigkeit): Das größere + die hälfte des kleineren Wertes (nicht verwendet)
	wurzel: fixpoint_magnitude
	port map
	(
		clk => clk,
		res_n => res_n,
		data_in => input_to_sqrt_cur,
		valid_in => valid_to_sqrt_cur,
		I_in => data_to_sqrt_I_cur,
		Q_in => data_to_sqrt_Q_cur,
		data_out => sqrt,
		valid_out => validin_sqrt,
		I_out => data_sqrt_I,
		Q_out => data_sqrt_Q
	);
	
	do_normalization: process(data_sqrt_I, data_sqrt_Q, sqrt, validin_sqrt, normalI_cur, normalQ_cur)
	begin
		normalI_next <= normalI_cur;
		normalQ_next <= normalQ_cur;

		if(validin_sqrt = '1') then
			--Das wird sicher länger als einen Takt brauchen
			-- und musst auch eine fixpoint_div sein
			normalI_next <= fixpoint_div(data_sqrt_I,sqrt);
			normalQ_next <= fixpoint_div(data_sqrt_Q,sqrt);
			valid_to_FIR_next <= '1';
		else
			valid_to_FIR_next <= '0';
		end if;
		
	end process do_normalization;

	filterI : FIRFilter_demod
	port map
	(
		clk => clk,
		res_n => res_n,
		data_in => normalI_cur,
		validin => valid_to_FIR_cur,
		data_out => filteredI,
		validout => validin_FIRI
	);
	filterQ : FIRFilter_demod
	port map
	(
		clk => clk,
		res_n => res_n,
		data_in => normalQ_cur,
		validin => valid_to_FIR_cur,
		data_out => filteredQ,
		validout => validin_FIRQ
	);
	
	do_demodulation: process (filteredQ,filteredI,validintern_cur,data1_cur,data2_cur, normalI_array_cur, normalQ_array_cur, normalI_cur, normalQ_cur, data_out_cur, validin_FIRI)
	begin
		normalI_array_next(0) <= normalI_cur;
		normalQ_array_next(0) <= normalQ_cur;
		normalI_array_next(max downto 1) <= normalI_array_cur(max-1 downto 0);
		normalQ_array_next(max downto 1) <= normalQ_array_cur(max-1 downto 0);
		data_out_next <= data_out_cur;
		data1_next <= data1_cur;
		data2_next <= data2_cur;

		--signal(length(dl):length(dl)+15) = 0;
		--fmdemod = imag(signal(16:length(dl)+15).*conj(dl));
		--fmdemod = imag(filtered(16-end)*conj(normal))
		--fmdemod = filteredQ*normalI - filteredI*normalQ
		if(validin_FIRI= '1') then
			data1_next <= fixpoint_mult(filteredQ,normalI_array_cur(max));
			data2_next <= fixpoint_mult(filteredI,normalQ_array_cur(max));
			validintern_next <= '1';
		else
			validintern_next <= '0';
		end if; 

		if(validintern_cur = '1') then
			data_out_next <= data1_cur - data2_cur;
			validout_next <= '1';
		else
			validout_next <= '0';
		end if;
	end process do_demodulation;

	sync: process (clk,res_n)
	begin
		if res_n = '0' then
			data_out_cur <= (others =>'0');
			validout_cur <= '0';
			data_con_I <= (others => '0');
			data_con_Q <= (others => '0');
			data1_cur <= (others => '0');
			data2_cur <= (others => '0');
			validintern_cur <= '0';
			normalI_array_cur <= (others =>  (others => '0'));
			normalQ_array_cur <= (others =>  (others => '0'));
			
			valid_to_FIR_cur <= '0';
			normalI_cur <= (others => '0');
			normalQ_cur <= (others => '0');
			
			data_to_sqrt_I_cur <= (others => '0');
			data_to_sqrt_Q_cur <= (others => '0');
			input_to_sqrt_cur <= (others => '0');
			valid_to_sqrt_cur <= '0';
		elsif rising_edge(clk) then
			--internals
				data_out_cur <= data_out_next;
				validout_cur <= validout_next;
				data_con_I <= data_con_I_next;
				data_con_Q <= data_con_Q_next;
				data1_cur <= data1_next;
				data2_cur <= data2_next;
				validintern_cur <= validintern_next;
				normalI_array_cur <= normalQ_array_next;
				normalQ_array_cur <= normalQ_array_next;
				
				valid_to_FIR_cur <= valid_to_FIR_next;
				normalI_cur <= normalI_next;
				normalQ_cur <= normalQ_next;
				
				data_to_sqrt_I_cur <= data_to_sqrt_I_next;
				data_to_sqrt_Q_cur <= data_to_sqrt_Q_next;
				input_to_sqrt_cur <= input_to_sqrt_next;
				valid_to_sqrt_cur <= valid_to_sqrt_next;
			--outputs
				data_out <= data_out_next;
				validout <= validout_next;
		end if;
	end process sync;

end behavior;