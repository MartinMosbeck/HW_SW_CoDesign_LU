
----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.math_pkg.all;


package display_controller_pkg is

	constant DISPLAY_WIDTH : integer := 800;
	constant DISPLAY_HEIGHT : integer := 480;
	
	type COLOR_TYPE is array (0 to 15) of std_logic_vector(23 downto 0);
	
	constant COLOR_TABLE : COLOR_TYPE :=
	(
		x"000000", -- black
		x"0000AA", -- blue
		x"00AA00", -- green
		x"00AAAA", -- cyan
		x"AA0000", -- red
		x"AA00AA", -- pink
		x"AA5500", -- brown
		x"AAAAAA", -- gray
		x"555555", -- dark gray
		x"5555FF", -- light blue
		x"55FF55", -- light green
		x"55FFFF", -- light cyan
		x"FF5555", -- light red
		x"FF55FF", -- 
		x"FFFF55", -- yellow
		x"FFFFFF"  -- white
	);
	
	
component display_controller is 
	port
	(
		clk	: in  std_logic;	-- global system clk 
		res_n	: in  std_logic;	-- system reset

		-- connection video ram
		vram_addr_row	: out std_logic_vector(log2c(30)-1 downto 0);
		vram_addr_colum : out std_logic_vector(log2c(100)-1 downto 0);
		vram_data	: in std_logic_vector(15 downto 0);	
		vram_rd	: out std_logic;						                


		-- connection to font rom
		char              : out std_logic_vector(log2c(256) - 1 downto 0);
		char_height_pixel : out std_logic_vector(log2c(16) - 1 downto 0);
		decoded_char      : in std_logic_vector(0 to 8 - 1);


		-- connection to display
		--nclk    : out std_logic;			-- display clk
		hd	    : out std_logic;	        -- horizontal sync signal
		vd	    : out std_logic;            -- vertical sync signal
		den	    : out std_logic;            -- data enable 
		r	    : out std_logic_vector(7 downto 0);		-- pixel color value (red)
		g	    : out std_logic_vector(7 downto 0);		-- pixel color value (green)
		b 	    : out std_logic_vector(7 downto 0);		-- pixel color value (blue)

		grest	: out std_logic		-- display reset
	);
end component display_controller;


end display_controller_pkg;



