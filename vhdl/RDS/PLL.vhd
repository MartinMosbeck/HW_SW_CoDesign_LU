library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.audiocore_pkg.all;

entity PLL
port
(
	clk : in std_logic;
	res_n : in std_logic;
	validin : in std_logic;
	data_in : in fixpoint;

	pilotTone : in fixpoint;

	validout : out std_logic;
	vcoQ_out : out fixpoint;
	vcoI_out : out fixpoint;

);
end PLL;

architecture PLL_beh of PLL is
	constant kp : fixpoint := "00000000001001100110011001100110";
	constant ki : fixpoint := "00000000000110011001100110011001";
	
	constant exp_arg : fixpoint := "00000000111101000111110111000110";	--this is 2*pi*f/fs

	signal vcoI : fixpoint := (others => '0');
	signal vcoQ : fixpoint := (others => '0');

	signal pilotTone_cur : fixpoint := (others => '0');
	signal pilotTone_next : fixpoint := (others => '0');

	signal validout_cur : std_logic := '0';
	signal validout_next : std_logic := '0';

	signal e : fixpoint := (others => '0');
	signal e_old : fixpoint := (others => '0');
	signal e_old_next : fixpoint := (others => '0');
	signal phi_hat : fixpoint := (others => '0');
	signal phi_hat_old : fixpoint := (others => '0');
	signal phi_hat_old_next : fixpoint := (others => '0');
	signal phd_output : fixpoint := (others => '0');
	signal phd_output_old : fixpoint := (others => '0');
	signal phd_output_old_next : fixpoint := (others => '0');
	signal sin_arg : fixpoint;
	signal cos_arg : fixpoint;
	signal n : unsigned(31 downto 0) := (others => '0');
	signal n_next : unsigned(31 downto 0) := (others => '0');

begin

	sync : process(clk, res_n)
	begin
		if !res_n then
			e_old			<= (others => '0');
			phi_hat_old 	<= (others => '0');
			phd_output_old	<= (others => '0');
			validout_cur	<= '0';
			n				<= (others => '0');
		elsif rising_edge(clk) then
				e_old <= e_old_next;
				phi_hat_old <= phi_hat_old_next;
				phd_output_old <= phd_output_old_next;
				pilotTone_cur <= pilotTone_next;
				validout_cur <= validout_next;
				n <= n_next;
		end if;
	end process;


	transition : process(pilotTone_cur, pilotTone, e, e_old, phi_hat, phi_hat_old, phd_output, phd_output_old)
	begin
		pilotTone_next <= pilotTone_cur;
		e_old_next <= e_old;
		phi_hat_old_next <= phi_hat_old;
		phd_output_old_next <= phd_output_old;
		validout_next <= '0';

		if validin = '1' then
			pilotTone_next <= pilotTone;
			e_old_next <= e;
			phi_hat_old_next <= phi_hat;
			phd_output_old_next <= phd_output;
			validout_next <= '1';
			n_next <= n + 1;
		end if;
	end process;


	--actual pll implementation
	calculate_vco : process(phi_hat_old, sin_arg, vcoI, vcoQ, pilotTone_cur, phd_output, phd_output_old, e, e_old)
	begin
		
		sin_arg <= exp_arg*n + phi_hat_old;
		cos_arg <= sin_arg;
		vcoQ <= cos_lookup(cos_arg);
		vcoI <= -sin_lookup(sin_arg);
		phd_output <= fixpoint_mult(pilotTone_cur, vcoI);	--imag(pilotTone*vco)
		e <= e_old + (kp+ki) * phd_output - ki*phd_output_old;	--Filter integrator 
		phi_hat <= phi_hat_old + e;		--Update VCO 
	end process;


	output : process
	begin
		vcoQ_out <= vcoQ;
		vcoI_out <= vcoI;
		validout <= validout_cur;
	end process;
	
end PLL;
