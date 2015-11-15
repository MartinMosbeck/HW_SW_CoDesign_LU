----------------------------------------------------------------------------------
-- Company:      TU Wien - ECS Group                                            
-- Engineer:     Florian Huemer                                                  
--                                                                              
-- Create Date:  2011                                                    
-- Design Name:  textmode_controller                                                         
-- Module Name:  textmode_controller_fsm                                                       
-- Project Name: graphic_lib                                                         
-- Description:          
--
--
--  Color information is always stored in the bits 15-8 of instr_data. 
--
--
--	video ram layout: (also data layout for set char/clear screen instruction)
--
--		 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0
--		+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
--		| fg-color  | bg-color  |     character code    |
--		+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
--
--
--
--
--  data layout for config instruction
-- 
-- 		 15 14 13 12 11 10  9  8  7  6  5  4  3  2  1  0
--		+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
--		|XX|XX|XX|XX|cursorcolor|XX|XX|XX|XX|ac|as|c1|c0|
--		+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
--
-- 
--  XX: Don't care
--
--  ac: Auto Increment Cursor
--  If activated the cursor will automaticly move to the next position after each SET_CHAR instruction. 
--
--  as: Auto scroll
--  This flag enables/disables the automatic scroll function of the controller. 
--  If activated, this feature will also clear the complete line after a newline event occurred (e.g. INSTR_NEW_LINE).
--
--  c0-c1:
--  Cursor state
----------------------------------------------------------------------------------


----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

use work.textmode_controller_pkg.all;
use work.math_pkg.all;

----------------------------------------------------------------------------------
--                                 ENTITY                                       --
----------------------------------------------------------------------------------

entity textmode_controller_fsm is
	generic
	(
		ROW_COUNT : integer := 30;
		COLUM_COUNT : integer := 100
	);
	port
	(
		clk	: in  std_logic;
		res_n	: in  std_logic;
		
		wr	: in std_logic;
		busy	: out std_logic;		

		instr : in std_logic_vector(7 downto 0);
		instr_data : in std_logic_vector(15 downto 0);	
		
		scroll_offset : out std_logic_vector(log2c(ROW_COUNT)-1 downto 0);
		cursor_position_row : out std_logic_vector(log2c(ROW_COUNT)-1 downto 0);
		cursor_position_colum : out std_logic_vector(log2c(COLUM_COUNT)-1 downto 0);
		cursor_color : out std_logic_vector(3 downto 0);
		cursor_state : out std_logic_vector(1 downto 0);
		
		video_ram_addr : out std_logic_vector( (log2c(COLUM_COUNT)+log2c(ROW_COUNT)-1) downto 0);
		video_ram_data : out std_logic_vector(15 downto 0);
		video_ram_wr : out std_logic	
	);
end entity textmode_controller_fsm;



----------------------------------------------------------------------------------
--                               ARCHITECTURE                                   --
----------------------------------------------------------------------------------

architecture beh of textmode_controller_fsm is


constant CHAR_LINEFEED : std_logic_vector(7 downto 0) := x"0A";
constant CHAR_BACKSPACE : std_logic_vector(7 downto 0) := x"08";
constant CHAR_CARRIAGE_RETURN : std_logic_vector(7 downto 0) := x"0D";

constant VIDEO_RAM_ADDRESSWIDTH : integer := log2c(COLUM_COUNT) + log2c(ROW_COUNT);

type TEXTMODE_CONTROLLER_STATE_TYPE is (IDLE, CLEAR_SCREEN, SET_CHAR, DELETE, DELETE_NEXT, SET_CURSOR_POSITION, NEW_LINE, CLEAR_LINE, SET_CFG, MOVE_CURSOR_NEXT, NOP);

signal textmode_controller_state : TEXTMODE_CONTROLLER_STATE_TYPE;
signal textmode_controller_state_next : TEXTMODE_CONTROLLER_STATE_TYPE; 

signal instr_data_buffer : std_logic_vector(15 downto 0);
signal instr_data_buffer_next : std_logic_vector(15 downto 0);

-- colum
signal x_cursor : integer range 0 to COLUM_COUNT;
signal x_cursor_next : integer range 0 to COLUM_COUNT;

-- row
signal y_cursor : integer range 0 to ROW_COUNT;
signal y_cursor_next : integer range 0 to ROW_COUNT;

-- scoll counter
signal sig_scroll_offset : integer range 0 to ROW_COUNT; 
signal sig_scroll_offset_next : integer range 0 to ROW_COUNT; 

-- flags
signal cfg_register : std_logic_vector(3 downto 0);
signal cfg_register_next : std_logic_vector(3 downto 0);

alias cursor_mode : std_logic_vector(1 downto 0) is cfg_register(1 downto 0);
alias cursor_mode_next : std_logic_vector(1 downto 0) is cfg_register_next(1 downto 0);

alias auto_scroll : std_logic is cfg_register(2);
alias auto_scroll_next : std_logic is cfg_register_next(2);

alias auto_inc_cursor : std_logic is cfg_register(3);
alias auto_inc_cursor_next : std_logic is cfg_register_next(3);

signal sig_cursor_color : std_logic_vector(3 downto 0);
signal sig_cursor_color_next : std_logic_vector(3 downto 0);

begin

	--------------------------------------------------------------------
	--                    PROCESS : SYNC                              --
	--------------------------------------------------------------------

	sync : process(res_n, clk)
	begin
		if res_n = '0' then
			textmode_controller_state <= CLEAR_SCREEN;--IDLE;
			x_cursor <= 0;
			y_cursor <= 0;
			
			auto_inc_cursor <= '0';
			auto_scroll <= '0';
			sig_scroll_offset <= 0;
			cursor_mode <= CURSOR_STATE_BLINK;
			sig_cursor_color <= "1010";
			instr_data_buffer <= (others=>'0');
			
   	elsif rising_edge(clk) then
			textmode_controller_state <= textmode_controller_state_next;
			
			instr_data_buffer <= instr_data_buffer_next;
			x_cursor <= x_cursor_next;
			y_cursor <= y_cursor_next;
			sig_scroll_offset <= sig_scroll_offset_next;
			
			cfg_register <= cfg_register_next;

			sig_cursor_color <= sig_cursor_color_next;
		end if;
	end process sync;

	--------------------------------------------------------------------
	--                    PROCESS : NEXT_STATE                        --
	--------------------------------------------------------------------

	next_state : process (textmode_controller_state, wr, instr, x_cursor, y_cursor, instr_data)
	begin
		textmode_controller_state_next <= textmode_controller_state;		

		case textmode_controller_state is

			---------------------------------------------------
			when IDLE =>
				if wr = '1' then
					case instr is
						when INSTR_CLEAR_SCREEN =>  textmode_controller_state_next <= CLEAR_SCREEN;
						when INSTR_SET_CHAR => 
							if instr_data(7 downto 0) = CHAR_LINEFEED or 
								instr_data(7 downto 0) = CHAR_CARRIAGE_RETURN then --new line
								textmode_controller_state_next <= NEW_LINE;
							elsif instr_data(7 downto 0) = CHAR_BACKSPACE then 
								textmode_controller_state_next <= DELETE;
							else
								textmode_controller_state_next <= SET_CHAR;
							end if;
						when INSTR_DELETE => textmode_controller_state_next <= DELETE;
						when INSTR_SET_CURSOR_POSITION => textmode_controller_state_next <= SET_CURSOR_POSITION;
						when INSTR_CFG => textmode_controller_state_next <= SET_CFG;
						when INSTR_MOVE_CURSOR_NEXT => textmode_controller_state_next <= MOVE_CURSOR_NEXT;
						when INSTR_NEW_LINE => textmode_controller_state_next <= NEW_LINE;
						when INSTR_NOP => textmode_controller_state_next <= NOP;	
						when others => 
					end case; 
				end if;
			
			---------------------------------------------------
			when NOP => 
				textmode_controller_state_next <= IDLE;
				
			---------------------------------------------------
			when CLEAR_SCREEN =>
				if (x_cursor = (COLUM_COUNT-1) and y_cursor = (ROW_COUNT-1)) then
					textmode_controller_state_next <= IDLE;
				end if;
			
			---------------------------------------------------
			when SET_CHAR =>
				if auto_inc_cursor = '0' then
					textmode_controller_state_next <= MOVE_CURSOR_NEXT;
				end if;
			
			---------------------------------------------------
			when DELETE =>
				textmode_controller_state_next <= DELETE_NEXT;

			---------------------------------------------------
			when DELETE_NEXT =>
				textmode_controller_state_next <= IDLE;
			
			---------------------------------------------------
			when SET_CURSOR_POSITION =>
				textmode_controller_state_next <= IDLE;
			
			---------------------------------------------------			
			when NEW_LINE =>
				if auto_scroll = '0' then
					textmode_controller_state_next <= CLEAR_LINE;
				else
					textmode_controller_state_next <= IDLE;
				end if;
						
			---------------------------------------------------			
			when CLEAR_LINE =>
				if x_cursor = COLUM_COUNT-1 then
					textmode_controller_state_next <= IDLE;
				end if;
				
			---------------------------------------------------
			when SET_CFG =>
				textmode_controller_state_next <= IDLE;
				
			---------------------------------------------------	
			when MOVE_CURSOR_NEXT => 	
				if x_cursor = COLUM_COUNT-1 then
					textmode_controller_state_next <= NEW_LINE;
				else 
					textmode_controller_state_next <= IDLE;
				end if;
			
			---------------------------------------------------	
			when others =>      
          		null;
		end case;
	end process next_state;


	--------------------------------------------------------------------
	--                    PROCESS : OUTPUT                            --
	--------------------------------------------------------------------	

	output : process (cfg_register, wr, auto_inc_cursor, sig_cursor_color, instr_data, instr_data_buffer, textmode_controller_state, x_cursor, y_cursor, auto_scroll, sig_scroll_offset)
	begin
	 
		busy <= '1';
		video_ram_wr <= '0';
		
		instr_data_buffer_next <= instr_data_buffer;
		
		x_cursor_next <= x_cursor;
		y_cursor_next <= y_cursor;
		
		video_ram_data <= (others => '0'); 
		video_ram_addr <= (others => '0'); 		
		
		
		cfg_register_next <= cfg_register;
		
		sig_scroll_offset_next <= sig_scroll_offset;
		
		sig_cursor_color_next <= sig_cursor_color;

		case textmode_controller_state is

			---------------------------------------------------
			when IDLE =>
				busy <= '0';
				if wr = '1' then
					instr_data_buffer_next <= instr_data; --buffer input value
				end if;
			
			---------------------------------------------------
			when CLEAR_SCREEN => 
				video_ram_addr <= 	std_logic_vector(to_unsigned(x_cursor, log2c(COLUM_COUNT))) & 
									std_logic_vector(to_unsigned(y_cursor, log2c(ROW_COUNT)));
				video_ram_data <= instr_data_buffer(15 downto 0);
				video_ram_wr <= '1';
				
				sig_scroll_offset_next <= 0;
				
				if x_cursor = COLUM_COUNT-1 then
					x_cursor_next <= 0;
					if y_cursor = ROW_COUNT-1 then
						y_cursor_next <= 0;
					else
						y_cursor_next <= y_cursor + 1; 
					end if;
				else
					x_cursor_next <= x_cursor + 1;
				end if;
			
			---------------------------------------------------
			when SET_CHAR =>
				video_ram_addr <= 	std_logic_vector(to_unsigned(x_cursor, log2c(COLUM_COUNT))) & 
										std_logic_vector(to_unsigned(y_cursor, log2c(ROW_COUNT)));
				video_ram_data <= instr_data_buffer(15 downto 0);
				video_ram_wr <= '1';
			
			---------------------------------------------------
			when DELETE =>
				if x_cursor = 0 then 
					if y_cursor = 0 then
						-- do nothing
					else
						y_cursor_next <= y_cursor - 1; 	
						x_cursor_next <= COLUM_COUNT - 1;
					end if;
				else
					x_cursor_next <= x_cursor - 1;
				end if;

			---------------------------------------------------
			when DELETE_NEXT =>			
				video_ram_addr <= 	std_logic_vector(to_unsigned(x_cursor, log2c(COLUM_COUNT))) & 
									std_logic_vector(to_unsigned(y_cursor, log2c(ROW_COUNT)));
				video_ram_data <= instr_data_buffer(15 downto 8) & x"00";
				video_ram_wr <= '1';
			
			---------------------------------------------------
			when SET_CURSOR_POSITION =>
				x_cursor_next <= to_integer(unsigned( instr_data_buffer(log2c(COLUM_COUNT)+8 downto 8) ));
				y_cursor_next <= to_integer(unsigned( instr_data_buffer(log2c(ROW_COUNT) downto 0) ));
			
			---------------------------------------------------			
			when NEW_LINE =>
				x_cursor_next <= 0;
					
				if auto_scroll = '0' then --auto-scroll
					if y_cursor = ROW_COUNT-1 then
						if sig_scroll_offset = ROW_COUNT-1 then 
							sig_scroll_offset_next <= 0;
						else
							sig_scroll_offset_next <= sig_scroll_offset + 1;
						end if; 
					else
						 y_cursor_next <=  y_cursor + 1;
					end if; 
				else		-- no auto-scroll
					if y_cursor = ROW_COUNT-1 then
						y_cursor_next <= 0; 
					else 
						y_cursor_next <= y_cursor + 1;
					end if;
				end if;
				
			---------------------------------------------------
			when CLEAR_LINE =>
				video_ram_addr <= 	std_logic_vector(to_unsigned(x_cursor, log2c(COLUM_COUNT))) & 
									std_logic_vector(to_unsigned(y_cursor, log2c(ROW_COUNT)));
				video_ram_data <= instr_data_buffer(15 downto 8) & x"00";
				video_ram_wr <= '1';
			
				if x_cursor = COLUM_COUNT-1 then
					x_cursor_next <= 0;
				else
					x_cursor_next <= x_cursor + 1;
				end if;
			
			---------------------------------------------------
			when SET_CFG =>
				sig_cursor_color_next <= instr_data_buffer(11 downto 8);
				cfg_register_next <= instr_data_buffer(3 downto 0);
			
			---------------------------------------------------	
			when MOVE_CURSOR_NEXT => 	
				if x_cursor = COLUM_COUNT-1 then
					x_cursor_next <= 0;
				else
					x_cursor_next <= x_cursor + 1;
				end if;
			
			---------------------------------------------------
			when others =>
		end case;
	end process output;
	
	scroll_offset <= std_logic_vector(to_unsigned(sig_scroll_offset, log2c(ROW_COUNT)));
	cursor_position_colum <= std_logic_vector(to_unsigned(x_cursor, log2c(COLUM_COUNT)));
	cursor_position_row <= std_logic_vector(to_unsigned(y_cursor, log2c(ROW_COUNT)));
	cursor_state <= cursor_mode;
	cursor_color <= sig_cursor_color;

end architecture beh;

-- EOF --





