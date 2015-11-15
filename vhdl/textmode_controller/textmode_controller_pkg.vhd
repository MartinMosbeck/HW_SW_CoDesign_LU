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
--use work.display_controller_pkg.all;

----------------------------------------------------------------------------------
--                                 PACKAGE                                      --
----------------------------------------------------------------------------------

package textmode_controller_pkg is
  
  	-- cursor options
  	constant CURSOR_STATE_OFF : std_logic_vector(1 downto 0) := "00";
  	constant CURSOR_STATE_ON : std_logic_vector(1 downto 0) := "01";
  	constant CURSOR_STATE_BLINK : std_logic_vector(1 downto 0) := "11";
  
	--Instructions for this textmode video controller
	constant INSTR_NOP : std_logic_vector(7 downto 0) := (others=>'0');

	constant INSTR_SET_CHAR : std_logic_vector(7 downto 0) := x"01";
	constant INSTR_CLEAR_SCREEN : std_logic_vector(7 downto 0) := x"02";
	constant INSTR_SET_CURSOR_POSITION : std_logic_vector(7 downto 0) := x"03";
	constant INSTR_CFG : std_logic_vector(7 downto 0) := x"04";
	constant INSTR_DELETE : std_logic_vector(7 downto 0) := x"05";
	constant INSTR_MOVE_CURSOR_NEXT : std_logic_vector(7 downto 0) := x"06";
	constant INSTR_NEW_LINE : std_logic_vector(7 downto 0) := x"07";
	
	------------------------------------------------------
	--              COMPONENTS                          --
	------------------------------------------------------

	------------------------------------------------------
	-- TODO:
	-- textmode_controller_nios
	-- textmode_controller_mimi
	------------------------------------------------------

	component textmode_controller_1c is
		generic
		(
			ROW_COUNT : integer := 30;
			COLUM_COUNT : integer := 100;
			CLK_FREQ : integer
		);
		port
		(
			clk	: in  std_logic;
			res_n	: in  std_logic;
			
			wr	    : in std_logic;
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
	end component textmode_controller_1c;
	

	component textmode_controller_2c is
		generic
		(
			ROW_COUNT : integer := 30;
			COLUM_COUNT : integer := 100;
			LCD_CLK_FREQ : integer
		);
		port
		(
			sys_clk	: in  std_logic;
			sys_res_n	: in  std_logic;
			
			lcd_clk	: in  std_logic;
			lcd_res_n	: in  std_logic;

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
	end component textmode_controller_2c;



end textmode_controller_pkg;







