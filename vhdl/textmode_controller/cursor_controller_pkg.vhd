----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.math_pkg.all;


----------------------------------------------------------------------------------
--                                 PACKAGE                                      --
----------------------------------------------------------------------------------



package cursor_controller_pkg is

	component cursor_controller is
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
	end component cursor_controller;


end package cursor_controller_pkg;



