


----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.math_pkg.all;
use work.textmode_controller_pkg.all;

----------------------------------------------------------------------------------
--                                 ENTITY                                       --
----------------------------------------------------------------------------------

entity cursor_controller is
	generic
	(
		CLK_FREQ : integer;
		BLINK_PERIOD : time range 1 ms to 2000 ms;
		ROW_COUNT : integer;
		COLUM_COUNT : integer;
		COLOR_WIDTH : integer
	);
	port
	(
		clk : in std_logic;
		res_n : in std_logic;
	
		cursor_state : in std_logic_vector(1 downto 0);
		cursor_color : in std_logic_vector(COLOR_WIDTH-1 downto 0);
		
		position_row : in std_logic_vector(log2c(ROW_COUNT)-1 downto 0);
		position_colum : in std_logic_vector(log2c(COLUM_COUNT)-1 downto 0);
		
		vram_addr_row 	: in std_logic_vector(log2c(ROW_COUNT)-1 downto 0);
		vram_addr_colum : in std_logic_vector(log2c(COLUM_COUNT)-1 downto 0);
		vram_rd : in std_logic;		

		vram_data_color_in : in std_logic_vector(COLOR_WIDTH-1 downto 0);
		vram_data_color_out : out std_logic_vector(COLOR_WIDTH-1 downto 0)
	);
end entity cursor_controller;


----------------------------------------------------------------------------------
--                               ARCHITECTURE                                   --
----------------------------------------------------------------------------------

architecture beh of cursor_controller is
	constant CLK_PERIOD : time := 1E9 / CLK_FREQ * 1 ns;
  	constant CNT_MAX    : integer := BLINK_PERIOD / CLK_PERIOD;
	
	type CURSOR_CONTROLLER_STATE_TYPE is (CURSOR_OFF, CURSOR_ON, CURSOR_BLINK_ON, CURSOR_BLINK_OFF);
	
	signal cursor_controller_state : CURSOR_CONTROLLER_STATE_TYPE;
	signal cursor_controller_state_next : CURSOR_CONTROLLER_STATE_TYPE; 
	
	signal blink_cnt : integer range 0 to CNT_MAX;
	signal blink_cnt_next : integer range 0 to CNT_MAX;

	-- signal indicating that vram_data_color_out has to be changed 
	signal change_output : std_logic; 
	signal change_output_next : std_logic; 

begin

	sync : process(clk, res_n)
	begin
		if res_n = '0' then
			blink_cnt <= 0;
			cursor_controller_state <= CURSOR_OFF;
		elsif rising_edge(clk) then
			blink_cnt <= blink_cnt_next;
			cursor_controller_state <= cursor_controller_state_next;
			change_output <= change_output_next;
		end if;
	
	end process;

		
	next_state : process (change_output, cursor_state, cursor_controller_state, blink_cnt, position_colum, vram_addr_colum, position_row, vram_addr_row, vram_rd)
	begin
		cursor_controller_state_next <= cursor_controller_state;
		blink_cnt_next <= 0;
		change_output_next <= change_output;
 

		case cursor_state is
			when CURSOR_STATE_ON =>
				cursor_controller_state_next <= CURSOR_ON;
			when CURSOR_STATE_OFF =>
				cursor_controller_state_next <= CURSOR_OFF;
			when others => -- CURSOR_STATE_BLINK 
				if cursor_controller_state /= CURSOR_BLINK_OFF then
					cursor_controller_state_next <= CURSOR_BLINK_ON;	
				end if;			
		end case;
		

		case cursor_controller_state is
			when CURSOR_ON =>
				if vram_rd = '1' and (position_colum = vram_addr_colum) and (position_row = vram_addr_row) then
					change_output_next <= '1';
				elsif vram_rd = '1' then
					change_output_next <= '0';
				end if;
			
			when CURSOR_BLINK_ON =>

				blink_cnt_next <= blink_cnt + 1;
				if blink_cnt = CNT_MAX-1 then
					blink_cnt_next <= 0;
					cursor_controller_state_next <= CURSOR_BLINK_OFF;		
				end if;

				if vram_rd = '1' and (position_colum = vram_addr_colum) and (position_row = vram_addr_row) then
					change_output_next <= '1';
				elsif vram_rd = '1' then
					change_output_next <= '0';
				end if;

			when CURSOR_BLINK_OFF =>
				blink_cnt_next <= blink_cnt + 1;
				if blink_cnt = CNT_MAX-1 then
					blink_cnt_next <= 0;
					cursor_controller_state_next <= CURSOR_BLINK_ON;		
				end if;	
				change_output_next <= '0';	
				
			when others =>
				change_output_next <= '0';
		end case;
		
	end process;	
		

	output : process(cursor_controller_state, vram_data_color_in, position_colum, position_row, vram_addr_colum, vram_addr_row, cursor_color, change_output)
	begin
	
		vram_data_color_out <= vram_data_color_in; -- default: don't change input
		
		if change_output = '1' then 
			vram_data_color_out <= cursor_color;
		end if;

		
	end process;

end architecture beh;




