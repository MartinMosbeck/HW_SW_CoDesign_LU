library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.audiocore_pkg.all;

entity debugger is
	port 
	(
		clk 			: in std_logic;
		res_n			: in std_logic;

		valid 			: in std_logic;
		data_in 		: in sgdma_frame;-- auf einen oder mehrere Fixpoints ändern
		
		output 			: out byte;
		validout 		: out std_logic;
		ready			: in std_logic
	);
end debugger;

architecture behavior of debugger is
	type state is (IDLE,TWO,THREE,FOUR,FIVE	);
	signal state_cur, state_next: state;
	
	signal output_cur,output_next : byte;

	signal validout_cur, validout_next : std_logic;

	alias byte1 is data_in(31 downto 24);
	alias byte2 is data_in(23 downto 16);
	alias byte3 is data_in(15 downto 8);
	alias byte4 is data_in(7 downto 0);
	
	signal buffer1_cur, buffer2_cur, buffer3_cur, buffer4_cur, buffer1_next, buffer2_next, buffer3_next, buffer4_next: byte;

begin
	out_statenext: process (state_cur,valid,data_in,ready)
	begin
		-- to avoid latches
		state_next <= state_cur;
		output_next <= output_cur;
		validout_next <= '0';
		buffer1_next <= buffer1_cur;
		buffer2_next <= buffer2_cur;
		buffer3_next <= buffer3_cur;
		buffer4_next <= buffer4_cur;
		
		case state_cur is
			when IDLE =>
				if (valid = '1') then--Hier anz buffer modden
					buffer1_next <= byte1;
					buffer2_next <= byte2;
					buffer3_next <= byte3;
					buffer4_next <= byte4;
					state_next <= TWO;
				end if;
			when TWO =>
				if (ready = '1') then
					validout_next <= '1';
					output_next <= byte1;
					state_next <= THREE; 
				end if;
			when THREE =>
				if (ready = '1') then
					validout_next <= '1';
					output_next <= byte2;
					state_next <= FOUR;
				end if;
			when FOUR=>
				if (ready = '1') then
					validout_next <= '1';
					output_next <= byte3;
					state_next <= FIVE;
				end if;
			when FIVE=>
				if (ready = '1') then
					validout_next <= '1';
					output_next <= byte4;
					state_next <= IDLE;
				end if;
		end case;
	end process out_statenext;

	sync: process (clk,res_n)
	begin
		if res_n = '0' then
			state_cur <= IDLE;
			output_cur <= (others=>'0');
			validout_cur <= '0';
			buffer1_cur <= x"00";
			buffer2_cur <= x"00";
			buffer3_cur <= x"00";
			buffer4_cur <= x"00";
		elsif rising_edge(clk) then
			state_cur <= state_next;
			output_cur <= output_next;
			validout_cur <= validout_next;
			buffer1_cur <= buffer1_next;
			buffer2_cur <= buffer1_next;
			buffer3_cur <= buffer3_next;
			buffer4_cur <= buffer4_next;
			-- outputs
			output <= output_next;	
			validout <= validout_next;	
		end if;		
	end process sync;
end behavior;
