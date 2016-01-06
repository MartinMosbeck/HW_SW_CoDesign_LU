library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package audiocore_pkg is
	subtype fixedpoint is signed(31 downto 0); -- 8.24 fixed point 
	subtype byte is std_logic_vector(7 downto 0);
	subtype sgdma_frame is std_logic_vector(31 downto 0);
	subtype index_time is integer range 0 to 24; 
end package audiocore_pkg;
