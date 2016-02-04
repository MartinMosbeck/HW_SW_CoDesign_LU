library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.audiocore_pkg.all;

package lookup is
	constant EXP_SIZE : integer := 8;
	type memory is array (0 to (2**EXP_SIZE) - 1) of fixpoint;
	function sin_lookup(arg : fixpoint) return fixpoint;
	function cos_lookup(arg : fixpoint) return fixpoint;
end package;
