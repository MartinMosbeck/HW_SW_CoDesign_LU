package body lookup is
	variable sin_memory is memory;
	variable cos_memory is memory;

	sin_memory(0) := "00000000000000000000000000000000";

	cos_memory(0) := "00000001000000000000000000000000";

	function sin_lookup(arg : fixpoint) return fixpoint is
		return sin_memory(to_integer(arg(31 downto 31 - EXP_SIZE + 1)));
	end sin_lookup;

	function cos_lookup(arg : fixpoint) return fixpoint is
		return cos_memory(arg(31 downto 31 - EXP_SIZE + 1));
	end cos_lookup;
end package body lookup;
