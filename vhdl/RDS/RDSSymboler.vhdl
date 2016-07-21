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
	function lookup_sin(argument:fixpoint)--TODO
		return fixpoint is
	begin
		if(argument(31) = '1')then
			return x"00000000";
		else
			return x"FFFFFFFF";
		end if;
	end function lookup_sin;
	function lookup_cos(argument:fixpoint)--TODO
		return fixpoint is
	begin
		if(argument(31) = '1')then
			return x"00000000";
		else
			return x"FFFFFFFF";
		end if;
	end function lookup_cos;
	function lookup_arg(I,Q:fixpoint)--TODO
		return fixpoint is
	begin
		return x"00000000";
	end function lookup_arg;

	constant anzsamplesHalf : natural := 53;
	constant anzsamples : natural := 105;

	constant ovterm: fixpoint := (others => '0');--WERT ANPASSEN AN UNSER FIXPOINT!!!
	constant ufterm: fixpoint := (others => '0');--WERT ANPASSEN AN UNSER FIXPOINT!!!

	signal cnt_cur, cnt_next : natural:=0;

	signal cos_corr_cur, cos_corr_next: fixpoint := (others => '0');--WERT ANPASSEN AN UNSER FIXPOINT!!!
	signal sin_corr_cur, sin_corr_next: fixpoint;

	signal lastI_cur, lastI_next: fixpoint;
	signal I_corr_cur, I_corr_next : fixpoint;
	signal Q_corr_cur, Q_corr_next : fixpoint;
	signal phi_cur, phi_next : fixpoint;

	signal code_mode_cur, code_mode_next: std_logic;
	signal code_word_next, code_word_cur: fixpoint;

	signal validintern_cur1, validintern_cur2, validintern_next1, validintern_next2, validintern_cur3, validintern_next3: std_logic;
	signal validout_next, validout_cur: std_logic;

	signal vorganger_cur, vorganger_next: std_logic;
	signal double_cur, double_next: std_logic;

	signal bit1_cur, bit1_next, bit2_cur, bit2_next, dbit_cur, dbit_next: std_logic;

	signal lastbit_cur, lastbit_next: std_logic;
	signal data_out_cur, data_out_next: byte;
	signal bit_cnt_cur, bit_cnt_next: natural range 0 to 7 := 7;
	signal RDSByte_cur, RDSByte_next: byte;
begin
	symboldetection: process (Iin, Qin, validin, code_mode_cur, cnt_cur, lastI_cur, sin_corr_cur, cos_corr_cur, I_corr_cur, Q_corr_cur, phi_cur, validout_cur, validintern_cur1, validintern_cur2, bit_cnt_cur, RDSByte_cur, dbit_cur, bit1_cur, bit2_cur, lastbit_cur, validintern_cur3, code_word_cur, vorganger_cur, double_cur)
		variable err_term, phi_cor, phi_corr: fixpoint;
		variable vorganger, double: std_logic;
		variable code_neg: fixpoint;
		variable bit1, bit2, lastbit: std_logic;
	begin
		--Latches
		code_mode_next <= code_mode_cur;
		cnt_next <= cnt_cur;
		lastI_next <= lastI_cur;
		code_word_next <= code_word_cur;
		phi_next <= phi_cur;
		sin_corr_next <= sin_corr_cur;
		cos_corr_next <= cos_corr_cur;
		dbit_next <= dbit_cur;
		bit2_next <= bit2_cur;
		bit1_next <= bit1_cur;
		vorganger_next <= vorganger_cur;
		double_next <= double_cur;
		lastbit_next <= lastbit_cur;
		data_out_next <= data_out_cur;
		bit_cnt_next <= bit_cnt_cur;
		RDSByte_next <= RDSByte_cur;

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
				phi_cor := phi_cur - signed(err_term(31) & err_term(31) & std_logic_vector(err_term(31 downto 2))) + signed(err_term(31) & err_term(31) & err_term(31) & err_term(31) & std_logic_vector(err_term(31 downto 4)));
				if(phi_cor >= ovterm)then
					phi_corr := phi_cor - ovterm;
				elsif(phi_cor <= ufterm)then
					phi_corr := phi_cor + ufterm;
				end if;
				phi_next <= phi_corr;
				sin_corr_next <= lookup_sin(phi_corr);--TODO!!!
				cos_corr_next <= lookup_cos(phi_corr);--TODO!!!
			end if;
		end if;

		--diffcoding
		validintern_next3 <= '0';
		if(validintern_cur2 = '1')then
			dbit_next <= '0';
			vorganger := vorganger_cur;
			double := double_cur;
			if(code_mode_cur = '1')then
				dbit_next <= '1';
				--Das negierte zuerst bearbeiten
				if(code_word_cur(31)='1')then
					code_neg:=not(code_word_cur - 1);
				else
					code_neg:=(not code_word_cur) + 1;
				end if;
				if(code_neg(31) = '1' and vorganger = '1')then
					double := '1';
					vorganger := '1';
				elsif(code_neg(31)='0' and vorganger = '0')then
					double := '1';
					vorganger := '0';
				else
					if(double = '0')then
						double := '1';
					else
						if(code_neg(31) = '1' and vorganger = '0') then
							bit1_next <= '1';--bit(1);
							validintern_next3 <= '1';
						elsif(code_neg(31) = '0' and vorganger = '1')then
							bit1_next <= '0';--bit(0);
							validintern_next3 <= '1';
						end if;
						double := '0';
					end if;
					vorganger:= code_neg(31);
				end if;
			end if;
			if(code_word_cur(31) = '1' and vorganger = '1')then
				double := '1';
				vorganger := '1';
			elsif(code_word_cur(31) = '0' and vorganger = '0')then
				double := '1';
				vorganger := '0';
			else
				if(double = '0')then
					double := '1';
				else
					if(code_word_cur(31) = '1' and vorganger = '0') then
						bit2_next <= '1';--bit(1);
						validintern_next3 <= '1';
					elsif(code_word_cur(31) = '0' and vorganger = '1')then
						bit2_next <= '0';--bit(0);
						validintern_next3 <= '1';
					end if;
					double := '0';
				end if;
				vorganger := code_word_cur(31);
			end if;
			vorganger_next <= vorganger;
			double_next <= double;
		end if;

		--bit + Ausgabe in Byte
		validout_next <= '0';
		if(validintern_cur3 = '1')then
			lastbit:=lastbit_cur;
			if(dbit_cur = '1')then
				bit1:=lastbit xor bit1_cur;
				lastbit:= bit1_cur;
			end if;
			bit2:=lastbit xor bit2_cur;
			lastbit_next <= bit2_cur;

			--Ausgabe von bit1,bit2 (in der Reihenfolge)
			if(dbit_cur = '1')then
				if(bit_cnt_cur > 1)then
					RDSByte_next(bit_cnt_cur downto bit_cnt_cur - 1) <= bit1 & bit2;
					bit_cnt_next <= bit_cnt_cur - 2;
				elsif(bit_cnt_cur = 1)then
					data_out_next <= RDSByte_cur(7 downto 2) & bit1 & bit2;
					bit_cnt_next <= 7;
					validout_next <= '1';
				else
					data_out_next <= RDSByte_cur(7 downto 1) & bit1;
					bit_cnt_next <= 6;
					validout_next <= '1';
					RDSByte_next(7) <= bit2;
				end if;
			else
				if(bit_cnt_cur = 0)then
					--VOLL
					data_out_next <=  RDSByte_cur(7 downto 1) & bit2;
					bit_cnt_next <= 7;
					validout_next <= '1';
				else
					RDSByte_next(bit_cnt_cur) <= bit2;
					bit_cnt_next <= bit_cnt_cur - 1;
				end if;
			end if;
		end if;
	end process symboldetection;

	sync: process (clk,res_n)
	begin
		if res_n ='0' then
			validintern_cur1 <= '0';
			validintern_cur2 <= '0';
			validintern_cur3 <= '0';
			code_word_cur <= (others => '0');
			code_mode_cur <= '0';
			sin_corr_cur <= (others => '0');
			cos_corr_cur <= (others => '1');--TODO!!!!
			lastI_cur <= (others => '0');
			I_corr_cur <= (others => '0');
			Q_corr_cur <= (others => '0');
			phi_cur <= (others => '0');
			validout_cur <= '0';
			cnt_cur <= 0;
			data_out_cur <= (others => '0');
			vorganger_cur <= '0';
			double_cur <= '0';
			bit1_cur <= '0';
			bit2_cur <= '0';
			dbit_cur <= '0';
			lastbit_cur <= '0';
			bit_cnt_cur <= 7;
			RDSByte_cur <= (others => '0');
		elsif rising_edge(clk) then
			--internals
			validintern_cur1 <= validintern_next1;
			validintern_cur2 <= validintern_next2;
			validintern_cur3 <= validintern_next3;
			validout_cur <= validout_next;
			code_word_cur <= code_word_next;
			code_mode_cur <= code_mode_next;
			sin_corr_cur <= sin_corr_next;
			cos_corr_cur <= cos_corr_next;
			lastI_cur <= lastI_next;
			I_corr_cur <= I_corr_next;
			Q_corr_cur <= Q_corr_next;
			phi_cur <= phi_next;
			cnt_cur <= cnt_next;
			data_out_cur <= data_out_next;
			vorganger_cur <= vorganger_next;
			double_cur <= double_next;
			bit1_cur <= bit1_next;
			bit2_cur <= bit2_next;
			dbit_cur <= dbit_next;
			lastbit_cur <= lastbit_next;
			bit_cnt_cur <= bit_cnt_next;
			RDSByte_cur <= RDSByte_next;

			--outputs
			validout <= validout_next;
			RDSout <= data_out_next;
		end if;
	end process sync;
end behavior;