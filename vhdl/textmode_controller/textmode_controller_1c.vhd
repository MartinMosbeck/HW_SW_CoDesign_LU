----------------------------------------------------------------------------------
-- Company:      TU Wien - ECS Group                                            --
-- Engineer:     Florian Huemer                                                  --
--                                                                              --
-- Create Date:  2011                                                     --
-- Design Name:                                                           --
-- Module Name:                                                         --
-- Project Name:                                                          --
-- Description:          --
----------------------------------------------------------------------------------


----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

use work.math_pkg.all;
use work.video_ram_pkg.all;
use work.font_pkg.all;
use work.display_controller_pkg.all;
use work.cursor_controller_pkg.all;


----------------------------------------------------------------------------------
--                                 ENTITY                                       --
----------------------------------------------------------------------------------

entity textmode_controller_1c is
	generic
	(
		ROW_COUNT : integer := 30;
		COLUM_COUNT : integer := 100;
		CLK_FREQ : integer := 25000000
	);
	port
	(
		clk	: in  std_logic;
		res_n	: in  std_logic;
		
		wr	: in std_logic;
		busy	: out std_logic;		

		instr : in std_logic_vector(7 downto 0);
		instr_data : in std_logic_vector(15 downto 0);
		
		hd	    : out std_logic;         -- horizontal sync signal
		vd	    : out std_logic;            -- vertical sync signal
		den	    : out std_logic;            -- data enable 
		r	    : out std_logic_vector(7 downto 0);		-- pixel color value (red)
		g	    : out std_logic_vector(7 downto 0);		-- pixel color value (green)
		b 	    : out std_logic_vector(7 downto 0);		-- pixel color value (blue)

		grest	: out std_logic		-- display reset
	);
end entity textmode_controller_1c;



----------------------------------------------------------------------------------
--                               ARCHITECTURE                                   --
----------------------------------------------------------------------------------

architecture struct of textmode_controller_1c is 


	component textmode_controller_fsm is
		generic
		(
			ROW_COUNT : integer;
			COLUM_COUNT : integer
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
	end component textmode_controller_fsm;


	constant ADDR_WIDTH_RAM : integer := log2c(COLUM_COUNT)+log2c(ROW_COUNT);
	
	--signals between controller and video ram
	signal wr_address_ram : std_logic_vector(ADDR_WIDTH_RAM-1 downto 0);
	signal wr_ram : std_logic;
	signal wr_data_ram : std_logic_vector(15 downto 0); 
	signal scroll_offset_ram : std_logic_vector(log2c(ROW_COUNT)-1 downto 0);

	--signals between video ram and display controller
	signal rd_data_char_ram : std_logic_vector(7 downto 0);
	
	signal rd_data_bg_cc_in_ram : std_logic_vector(3 downto 0);
	signal rd_data_bg_cc_out_ram : std_logic_vector(3 downto 0);
	
	signal rd_data_fg_ram : std_logic_vector(3 downto 0);
	
	signal vram_out_addr_row : std_logic_vector(log2c(ROW_COUNT)-1 downto 0);
	signal vram_out_addr_colum : std_logic_vector(log2c(COLUM_COUNT)-1 downto 0);
	signal vram_out_addr : std_logic_vector(log2c(COLUM_COUNT)+log2c(ROW_COUNT)-1 downto 0);
	
	signal rd_ram : std_logic;
	
	
	--signals between font rom and display controller
	signal rom_decoded_char : std_logic_vector(7 downto 0);
	signal font_rom_addr : std_logic_vector(11 downto 0);
	
	-- signals between controller and cursor controller
	signal cursor_position_row : std_logic_vector(log2c(ROW_COUNT)-1 downto 0);
	signal cursor_position_colum : std_logic_vector(log2c(COLUM_COUNT)-1 downto 0);
	signal cursor_color : std_logic_vector(3 downto 0);
	signal cursor_state : std_logic_vector(1 downto 0);
	
begin


	controller : textmode_controller_fsm
		generic map
		(
			ROW_COUNT => ROW_COUNT,
			COLUM_COUNT => COLUM_COUNT
		)
		port map
		(
			clk => clk,
			res_n => res_n,
			
			wr => wr,
			busy => busy,
			instr => instr,
			instr_data => instr_data,
			
			video_ram_addr => wr_address_ram, 
			video_ram_data => wr_data_ram, 
			video_ram_wr => wr_ram,	
			
			scroll_offset => scroll_offset_ram,
			cursor_position_row => cursor_position_row,
			cursor_position_colum => cursor_position_colum,
			cursor_color => cursor_color,
			cursor_state => cursor_state
		);

	vram_out_addr <= vram_out_addr_colum & vram_out_addr_row;

	video_ram_inst : video_ram 
		generic map
		(
			DATA_WIDTH => 16,
			ROW_COUNT => ROW_COUNT,
			COLUM_COUNT => COLUM_COUNT
		)
		port map
		(
			clk => clk,
			
			data_in => wr_data_ram,
			addr_wr => wr_address_ram,
			wr =>	wr_ram,
			
			data_out(7 downto 0) => rd_data_char_ram,
			data_out(11 downto 8) => rd_data_bg_cc_in_ram,
			data_out(15 downto 12) => rd_data_fg_ram,
			
			addr_rd => vram_out_addr,
			
			rd => rd_ram,
			
			scroll_offset => scroll_offset_ram
			
		);
	
	
	font_rom_inst : font_rom
		port map
		(
			vga_clk	=> clk,
			char => font_rom_addr(11 downto 4),
			char_height_pixel => font_rom_addr(3 downto 0),
			decoded_char => rom_decoded_char 
		);
	
	
	display_controller_inst : display_controller
		port map
		(
			clk => clk,
			res_n => res_n,

			-- connection video ram
			vram_addr_row =>  vram_out_addr_row,
			vram_addr_colum =>  vram_out_addr_colum,
			vram_data(7 downto 0) => rd_data_char_ram, 	--character
			vram_data(11 downto 8) => rd_data_bg_cc_out_ram, -- background color
			vram_data(15 downto 12) => rd_data_fg_ram, -- foreground color
			
			vram_rd	=> rd_ram,

			-- connection to font rom
			char => font_rom_addr(11 downto 4),
			char_height_pixel => font_rom_addr(3 downto 0),
			decoded_char => rom_decoded_char,

			-- connection to display
			hd => hd,
			vd => vd,
			den => den,
			r => r,
			g => g,
			b => b,

			grest => grest
		);
		
	
	cursor_controller_inst : cursor_controller
		generic map
		(
			CLK_FREQ => CLK_FREQ,
			BLINK_PERIOD => 1000 ms,
			ROW_COUNT => ROW_COUNT,
			COLUM_COUNT => COLUM_COUNT,
			COLOR_WIDTH => 4
		) 
		port map
		(
			clk => clk, 
			res_n => res_n,
	
			cursor_state => cursor_state,
			cursor_color => cursor_color,
		
			position_row => cursor_position_row,
			position_colum => cursor_position_colum,
		
			vram_addr_row =>  vram_out_addr_row,
			vram_addr_colum =>  vram_out_addr_colum,
			vram_rd => rd_ram,		
	
			vram_data_color_in => rd_data_bg_cc_in_ram,
			vram_data_color_out => rd_data_bg_cc_out_ram
		);

end architecture struct;


-- EOF --

