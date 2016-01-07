library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.audiocore_pkg.all;

entity outputlogic is
	port 
	(
		clk : in std_logic;
		res_n : in std_logic;

		data_in : in fixpoint;
		validin : in std_logic;
		
		data_out : out byte;
		validout : out std_logic
	);
end outputlogic;

architecture behavior of outputlogic is
	signal data_out_cur,data_out_next, data : fixpoint;
	signal validout_cur, validout_next, valid : std_logic;
	variable factor0 : fixpoint;
	variable product : fixpoint_product;
begin

	deci: decimator
	generic 
	(
		N => 2
	)	
	port map 
	(
		clk =>clk,
		res_n =>res_n,

		data_in =>data_in,
		validin =>validin,
		
		data_out =>data, 
		validout => valid
	);


	do_output: process (data,valid)
	begin
		data_out_next <= data_out_cur;
		validout_next <= validout_cur;

		if(valid = '0') then
			validout_next <= '0';
		else
			validout_next <= '1';
			
			--sign extend
--			if(data(31) = '1' then
--				factor0(63 downto 56) := (others => '1');
--			else
--				factor0(63 downto 56) := (others => '0');
--			end if;
--			factor0(23 downto 0) := (others => '0');
--			factor0(55 downto 24) := data;
--
--			factor1(63 downto 48) := to_signed(30, 16);
--			factor1(47 downto 0) := (others => '0');
--			product := factor0 * factor1;
--			data_out_next <= product(103 downto 71);
		
			factor0(31 downto 24) := to_signed(30,8);
			factor0(23 downto 0) := (others => '0');
			product := (others => '0');
			product := factor0 * data;

			data_out_next <= product(55 downto 24);

		end if; 
	end process do_output;

	sync: process (clk,res_n)
	begin
		if res_n = '0' then
			data_out_cur <= (others =>'0');
			validout_cur <= '0';
		elsif rising_edge(clk) then
			--internals
				data_out_cur <= data_out_next;
				validout_cur <= validout_next;
			--outputs
				data_out <= data_out_next;
				validout <= validout_next;
		end if;
	end process sync;

end outputlogic;
