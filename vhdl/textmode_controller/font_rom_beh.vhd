----------------------------------------------------------------------------------
-- Company:      TU Wien - ECS Group                                            --
-- Engineer:     Thomas Polzer                                                  --
--                                                                              --
-- Create Date:  21.09.2010                                                     --
-- Design Name:  DIDELU                                                         --
-- Module Name:  font_rom_beh                                                   --
-- Project Name: DIDELU                                                         --
-- Description:  Font ROM - Architecture                                        --
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.font_pkg.all;

----------------------------------------------------------------------------------
--                               ARCHITECTURE                                   --
----------------------------------------------------------------------------------

architecture beh of font_rom is
begin

  --------------------------------------------------------------------
  --                    PROCESS : SYNC                              --
  --------------------------------------------------------------------

  process(vga_clk)
    variable address : std_logic_vector(log2c(CHAR_COUNT) + log2c(CHAR_HEIGHT) - 1 downto 0);
  begin
    if rising_edge(vga_clk) then
      address := char & char_height_pixel;
      decoded_char <= FONT_TABLE(to_integer(unsigned(address)));
    end if;
  end process;
  
end architecture beh;

--- EOF ---
