-- Source: https://en.wikipedia.org/wiki/Alpha_max_plus_beta_min_algorithm
--WARNUNG!!! DIESER BLOCK ERWARTET MAXIMAL ALLE 4 ZYKLEN EIN NEUES DATUM!!!
--Derzeit wird an dieser Stelle(direkt nach dem Decimator)max. jeder 20. Zyklus ein Datum enthalten

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.audiocore_pkg.all;

entity fixpoint_magnitude is
	port
	(
		clk			: in std_logic;
		res_n		: in std_logic;

		valid_in	: in std_logic;
		data_in		: in fixpoint;--Von diesem Block nicht benötigt

		valid_out	: out std_logic;
		data_out	: out fixpoint;

		-- durchschleifen von I und Q
		I_in	: in fixpoint;
		I_out	: out fixpoint;
		Q_in	: in fixpoint;
		Q_out	: out fixpoint
	);
 end fixpoint_magnitude;


 architecture behavior of fixpoint_magnitude is

	function fixpoint_mult(a,b:fixpoint) return fixpoint is
		variable result_full : fixpoint_product;
	begin
		result_full := a * b;

		return result_full(47 downto 16);
	end function;

	signal I_abs_cur, I_abs_next : fixpoint;
	signal Q_abs_cur, Q_abs_next : fixpoint;

	signal I_buf_cur, I_buf_next : fixpoint;
	signal Q_buf_cur, Q_buf_next : fixpoint;

	signal Q_out_cur, Q_out_next : fixpoint;
	signal I_out_cur, I_out_next : fixpoint;

	-- elements of sum
	signal elem1_cur, elem1_next : fixpoint;
	signal elem2_cur, elem2_next : fixpoint;

	signal data_out_cur, data_out_next : fixpoint;
	signal valid_out_cur, valid_out_next : std_logic;

	type state_type is (IDLE, Q_bigger, Q_not_bigger, ADD);

	signal state_cur, state_next : state_type;

	constant alpha : fixpoint := "00000000000000001111010111011110";
	constant beta : fixpoint := "00000000000000000110010111010111";

begin

nextstate_out: process (state_cur, valid_in, I_in, Q_in, I_abs_cur, Q_abs_cur, I_buf_cur, Q_buf_cur, I_out_cur, Q_out_cur, elem1_cur, elem2_cur, state_cur, data_out_cur)
variable I_abs, Q_abs: fixpoint;
begin
	I_abs_next <= I_abs_cur;
	Q_abs_next <= Q_abs_cur;
	I_buf_next <= I_buf_cur;
	Q_buf_next <= Q_buf_cur;
	I_out_next <= I_out_cur;
	Q_out_next <= Q_out_cur;
	elem1_next <= elem1_cur;
	elem2_next <= elem2_cur;
	data_out_next <= data_out_cur;
	valid_out_next <= '0';
	state_next <= state_cur;

	case state_cur is
		when IDLE =>
			if(valid_in = '1') then
				I_buf_next <= I_in;
				Q_buf_next <= Q_in;

				if(I_in(31)='1')then
					I_abs := not(I_in - 1);
				else
					I_abs := I_in;
				end if;
				if(Q_in(31)='1')then
					Q_abs := not(Q_in - 1);
				else
					Q_abs := Q_in;
				end if;

				if( Q_abs > I_abs) then
					state_next <= Q_bigger;
				else
					state_next <= Q_not_bigger;
				end if;
				I_abs_next <= I_abs;
				Q_abs_next <= Q_abs;
			end if;

		when Q_bigger =>
			elem1_next <= fixpoint_mult (alpha, Q_abs_cur);
			elem2_next <= fixpoint_mult (beta, I_abs_cur);

			state_next <= ADD;

		when Q_not_bigger =>
			elem1_next <= fixpoint_mult (alpha, I_abs_cur);
			elem2_next <= fixpoint_mult (beta, Q_abs_cur);

			state_next <= ADD;

		when ADD =>
			valid_out_next <= '1';
			data_out_next <= elem1_cur + elem2_cur;
			I_out_next <= I_buf_cur;
			Q_out_next <= Q_buf_cur;

			state_next <= IDLE;

	end case;

end process nextstate_out;

sync: process (clk, res_n)
begin
	if(res_n = '0') then
		I_abs_cur <= (others => '0');
		Q_abs_cur <= (others => '0');
		I_buf_cur <= (others => '0');
		Q_buf_cur <= (others => '0');
		I_out_cur <= (others => '0');
		Q_out_cur <= (others => '0');
		elem1_cur <= (others => '0');
		elem2_cur <= (others => '0');
		data_out_cur <= (others => '0');
		valid_out_cur <= '0';
		state_cur <= IDLE;

	elsif(rising_edge(clk)) then
		I_abs_cur <= I_abs_next;
		Q_abs_cur <= Q_abs_next;
		I_buf_cur <= I_buf_next;
		Q_buf_cur <= Q_buf_next;
		I_out_cur <= I_out_next;
		Q_out_cur <= Q_out_next;
		elem1_cur <= elem1_next;
		elem2_cur <= elem2_next;
		data_out_cur <= data_out_next;
		valid_out_cur <= valid_out_next;
		state_cur <= state_next;
	end if;
end process sync;

	I_out <= I_out_cur;
	Q_out <= Q_out_cur;
	data_out <= data_out_cur;
	valid_out <= valid_out_cur;

end  behavior;
