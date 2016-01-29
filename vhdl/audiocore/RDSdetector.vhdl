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

	validout : out std_logic;
	symbol_out : out std_logic
);
end RDSdetector;

architecture RDSdetector_beh is
	constant kp : fixpoint := "00000000001001100110011001100110";
	constant ki : fixpoint := "00000000000110011001100110011001";
	constant bit_rate : integer := 2375;		--2*1187.5
	constant f : integer := 19000;
	constant pi : fixpoint := "00000011001001000011111101101010";

	signal vco : fixpoint := (others => '0');
	signal e : fixpoint := (others => '0');
	signal e_old : fixpoint := (others => '0');
	signal phi_hat : fixpoint := (others => '0');
	signal phi_hat_old : fixpoint := (others => '0');
	signal phd_output : fixpoint := (others => '0');
	signal phd_output_old : fixpoint := (others => '0');
	signal phase : fixpoint := "00000010100111100011010011011000";	--2*pi*5/12
	
begin
	process(clk, res_n)
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
			-- TODO
		end if;
	end process;

end RDSdetector;
