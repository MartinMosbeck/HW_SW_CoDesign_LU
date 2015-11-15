----------------------------------------------------------------------------------
-- Company:      TU Wien - ECS Group                                            --
-- Engineer:     Thomas Polzer                                                  --
--                                                                              --
-- Create Date:  21.09.2010                                                     --
-- Design Name:  DIDELU                                                         --
-- Module Name:  font_rom                                                       --
-- Project Name: DIDELU                                                         --
-- Description:  Font ROM - Entity                                              --
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.font_pkg.all;
use work.math_pkg.all;

----------------------------------------------------------------------------------
--                                 ENTITY                                       --
----------------------------------------------------------------------------------

entity font_rom is
  port
  (
    vga_clk           : in std_logic;
    char              : in std_logic_vector(log2c(CHAR_COUNT) - 1 downto 0);
    char_height_pixel : in std_logic_vector(log2c(CHAR_HEIGHT) - 1 downto 0);
    decoded_char      : out std_logic_vector(0 to CHAR_WIDTH - 1)
  );
end entity font_rom;

--- EOF ---