--WARNUNG!!! DER BLOCK IST FÜR NACH DEN DECIMATOR GEDACHT (max. jeder 10. Takt ein DATUM!!!)
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.audiocore_pkg.all;

entity RDSSymboler is
	port 
	(
		clk : in std_logic;
		res_n : in std_logic;

		Iin : in fixpoint;
		Qin : in fixpoint;
		validin : in std_logic;
		
		RDSout : out byte;
		validout : out std_logic
	);
end RDSSymboler;

architecture behavior of RDSSymboler is
	function fixpoint_mult(a,b:fixpoint) return fixpoint is
				variable result_full : fixpoint_product;
	begin
		result_full := a * b;

		return result_full(47 downto 16);
	end fixpoint_mult;
	
	constant anzsamplesHalf : natural := 53;
	constant anzsamples : natural := 105;
	
	signal cos_corr_cur, cos_corr_next: fixpoint := 32768;--WERT ANPASSEN AN UNSER FIXPOINT!!!
	signal sin_corr_cur, sin_corr_next: fixpoint;
	
	signal lastI_cur, lastI_next: fixpoint;
	signal I_corr_cur, I_corr_next : fixpoint;
	signal Q_corr_cur, Q_corr_next : fixpoint;
	signal phi_cur, phi_next : fixpoint;
	
	signal code_mode_cur, code_mode_next: std_logic;
	signal code_word_next, code_word_cur: fixpoint;
	
	signal validintern_cur1, validintern_cur2, validintern_next1, validintern_next2: std_logic;
	signal validout_next, validout_cur: std_logic;

begin
	symboldetection: process (Iin, Qin)
		variable err_term, phi_cor, phi_corr: fixpoint;
	begin
		--Latches
		code_mode_next <= code_mode_cur;
		cnt_next <= cnt_cur;
		lastI_next <= lastI_cur;
		
		--rds_demod
		if(validin = '1') then
			-- Shift nicht nötig?
			--I und Q fix
			I_corr_next <= fixpoint_mult(Iin,cos_corr_cur)-fixpoint_mult(Qin,sin_corr_cur);
			Q_corr_next <= fixpoint_mult(Iin,sin_corr_cur)+fixpoint_mult(Qin,cos_corr_cur);
			-- Shift nicht nötig?
			lastI_next <= I_corr_cur;
			cnt_next <= cnt_cur + 1;
			validintern_next1 <= '1';
		else
			validintern_next1 <= '0';
			I_corr_next <= I_corr_cur;
			Q_corr_next <= Q_corr_cur;
		end if;
		
		validintern_next2 <= '0';
		if(validintern_cur1 = '1')then
			if(I_corr_cur(31) /= lastI_cur(31))then--Zerocrossing
				if(cnt_cur > anzsamplesHalf + anzsamples)then
					code_mode_next <= '0';
					code_word_next <= lastI_cur;--diffcoding(lastI_cur) als 2.
					if(cnt_cur > anzsamplesHalf + 2*anzsamples)then
						code_mode_next <= '1';
						--diffcoding(-lastI_cur) == -code_word_next als 1.
					end if;
					validintern_next2 <= '1';
				end if;
				cnt_next <= 1;
			end if;
			
			if(cnt_cur = anzsamplesHalf)then
				code_mode_next <= '0';
				code_word_next <= I_corr_cur;--diffcoding(I_corr_cur)
				validintern_next2 <= '1';
				err_term := lookup_arg(I_corr_cur,Q_corr_cur);--TODO!!!
				phi_cor := phi_cur - err_term slr 2 + err_term slr 4;--Einfach nur Teil des Vektors nehmen
				if(phi_cor >= ovterm)then--OV-UFTERM NOCH DIE RICHTIGEN WERTE FINDEN!!!
					phi_corr := phi_cor - ovterm;
				elsif(phi_cor <= ufterm)then
					phi_corr := phi_cor + ufterm;
				end if;
				phi_next <= phi_corr;
				sin_corr_next <= sin_lookup(phi_corr);--TODO!!!
				cos_corr_next <= cos_lookup(phi_corr);--TODO!!!
			end if;
		end if;
		
		--diffcoding--TODOOOOO!!!!!
		if(validintern_cur2 = '1')then
			if(code_mode_cur = '1')then
				--Das negierte zuerst bearbeiten
			end if;
			if(code_word_cur(31) = '1' and vor = '1')then
			elsif(code_word_cur(31) = '0' and vor = '0')then
			
			validout_next <= '1';
		else
			validout_next <= '0';
		end if;
	end process symboldetection;

	sync: process (clk,res_n)
	begin
		if res_n ='0' then
		
		elsif rising_edge(clk) then
			--internals

			--outputs
			validout <= validout_next;
			RDSout <= ;
		end if;
	end process sync;
	
end behavior;