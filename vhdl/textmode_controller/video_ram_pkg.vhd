






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


----------------------------------------------------------------------------------
--                                 PACKAGE                                      --
----------------------------------------------------------------------------------

package video_ram_pkg is
  
	component video_ram is
		generic
		(
			DATA_WIDTH : integer := 16;
			COLUM_COUNT : integer := 100;
			ROW_COUNT : integer := 30
		);
		port
		(
			clk 				: in std_logic;
			data_in 		: in std_logic_vector(DATA_WIDTH - 1 downto 0);
			addr_wr			: in std_logic_vector(log2c(COLUM_COUNT) + log2c(ROW_COUNT)-1 downto 0);
			wr					: in std_logic;
		
			data_out		: out std_logic_vector(DATA_WIDTH - 1 downto 0);
			addr_rd			: in std_logic_vector(log2c(COLUM_COUNT) + log2c(ROW_COUNT)-1 downto 0);
			rd					: in std_logic;
		
			scroll_offset : in std_logic_vector(log2c(ROW_COUNT)-1 downto 0)
		
		);
	end component; 
	

end video_ram_pkg;







