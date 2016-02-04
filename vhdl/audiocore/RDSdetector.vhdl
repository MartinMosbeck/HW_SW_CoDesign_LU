library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.audiocore_pkg.all;

entity RDSdetector is
port
(
	clk : in std_logic;
	res_n : in std_logic;
	validin : in std_logic;
	data_in : in fixpoint;

	pilotToneI : in fixpoint;
	pilotToneQ : in fixpoint;

	validout : out std_logic;
	symbol_out : out std_logic

);
end RDSdetector;

architecture RDSdetector_beh is
	constant kp : fixpoint := "00000000001001100110011001100110";
	constant ki : fixpoint := "00000000000110011001100110011001";
	constant bit_rate : integer := 2375;		--2*1187.5
	--constant f : integer := 19000;
	--constant fs : integer := 2.5*10**6/20;
	--constant two_pi : fixpoint := "00000110010010000111111011010100";
	--constant f_divided_by_fs := 00000000001001101110100101111000;
	--this is 2*pi*f/fs
	constant exp_arg : fixpoint := "00000000111101000111110111000110";

	signal vcoI : fixpoint := (others => '0');
	signal vcoQ : fixpoint := (others => '0');
	signal e : fixpoint := (others => '0');
	signal e_old : fixpoint := (others => '0');
	signal phi_hat : fixpoint := (others => '0');
	signal phi_hat_old : fixpoint := (others => '0');
	signal phd_output : fixpoint := (others => '0');
	signal phd_output_old : fixpoint := (others => '0');
	signal phase : fixpoint := "00000010100111100011010011011000";	--is initially at 2*pi*5/12
	signal symbolI : fixpoint;
	signal symbolQ : fixpoint;
	signal sin_arg : fixpoint;
	signal cos_arg : fixpoint;
	signal n : unsigned(31 downto 0) := (others => '0');
	begin
	process(clk, res_n, sin_arg)
	begin
		if !res_n then
			vco				<= (others => '0');
			e				<= (others => '0');
			e_old			<= (others => '0');
			phi_hat			<= (others => '0');
			phi_hat_old 	<= (others => '0');
			phd_output		<= (others => '0');
			phd_output_old	<= (others => '0');
		elsif rising_edge(clk) then
			--XXX this needs to happen at our sample frequency, however
			--clk is probably a lot faster, hence we'd update the pll's signals
			--but the input signal (the pilotTone) would stay the same, since we
			--would be on the same sample
			e_old <= e;
			phi_hat_old <= phi_hat;
			phd_output_old <= phd_output;
		end if;
	end process;

	--pll implementation
	process(phi_hat_old, sin_arg, vcoI, vcoQ, pilotToneQ, pilotToneI, phd_output, phd_output_old)
	begin
		
		sin_arg <= exp_arg*n + phi_hat_old;
		cos_arg <= sin_arg;
		vcoQ <= cos_lookup(cos_arg);
		vcoI <= -sin_lookup(sin_arg);
		phd_output <= fixpoint_mult(pilotToneQ, vcoI) + fixpoint_mult(pilotToneI, vcoQ);	--imag(pilotTone*vco)
		e <= e_old + (kp+ki) * phd_output - ki*phd_output_old;	--Filter integrator 
		phi_hat <= phi_hat_old + e;		--Update VCO 
	end process;

end RDSdetector;
