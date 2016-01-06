-- --------------------------------------------------------------------
-- Title      : fixed_alg_pkg_body_real.vhd
-- These are the algorithemic functions.  In this package you will find
-- routines for doing complex arithmetic and basic Trig functions.  These
-- functions are not optomized, and are placed here as examples.  In the
-- future, a new complex number format will be used and placed into the
-- fixed point packages.
-- Last Modified: $Date: 2012/02/23 18:32:09 $
-- RCS ID: $Id: fixed_alg_pkg-body_real.vhdl,v 1.3 2012/02/23 18:32:09 l435385 Exp l435385 $
--
--  Created for VHDL-200X-ft, David Bishop (dbishop@vhdl.org) 
-- ---------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

package body fixed_alg_pkg is
  -- This differed constant will tell you if the package body is synthesizable
  -- or implimented as real numbers.
  constant fixed_alg_synth_or_real : BOOLEAN             := false;  -- differed constant
  -- null array constants
  constant NAUF                    : ufixed (0 downto 1) := (others => '0');
  constant NASF                    : sfixed (0 downto 1) := (others => '0');

  -- purpose: Returns a saturated number
  function saturate (
    constant left_index  : INTEGER;
    constant right_index : INTEGER)
    return sfixed is
    variable result : sfixed (left_index downto right_index) :=
      (others => '1');
  begin
    result (left_index) := '0';
    return result;
  end function saturate;

  -- purpose: Returns a saturated number
  function saturate (
    constant left_index  : INTEGER;
    constant right_index : INTEGER)
    return ufixed is
    constant result : ufixed (left_index downto right_index) :=
      (others => '1');
  begin
    return result;
  end function saturate;


  -----------------------------------------------------------------------------
  -- Visible functions
  -----------------------------------------------------------------------------
  -- Rounds to a given precision.  "places" is the number of bits to round to.
  function precision (
    arg                     : sfixed;
    constant places         : NATURAL;
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style)
    return sfixed is
    variable arg_real : REAL;
    variable argr     : sfixed (arg'high downto -places);  -- rounded
    variable result   : sfixed (arg'range);
  begin
    if (arg'length < 1) then
      return NASF;
    else
      arg_real := to_real (arg);
      argr := to_sfixed (arg            => arg_real,
                         left_index     => arg'high,
                         right_index    => -places,
                         round_style    => round_style,
                         overflow_style => overflow_style);
      result := resize (argr,
                        arg'high, arg'low);
      return result;
    end if;
  end function precision;

  function precision (
    arg                     : ufixed;
    constant places         : NATURAL;
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style)
    return ufixed is
    variable arg_real : REAL;
    variable argr     : ufixed (arg'high downto -places);  -- rounded
    variable result   : ufixed (arg'range);
  begin
    if (arg'length < 1) then
      return NAUF;
    else
      argr := resize (arg            => arg,
                      left_index     => arg'high,
                      right_index    => -places,
                      round_style    => round_style,
                      overflow_style => overflow_style);
      result := resize (argr,
                        arg'high, arg'low);
      return result;
    end if;
  end function precision;

  -- largest integer not greater than arg
  function floor (
    arg                     : ufixed;
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style)
    return ufixed is
    variable arg_real : REAL;
    variable result   : ufixed (arg'range);
  begin
    if arg'high < 0 then
      report fixed_alg_pkg'instance_name & "floor (ufixed) :" &
        "left index less than zero (" & INTEGER'image(arg'high) & ")"
        severity error;
      result := (others => '0');
    else
      arg_real := floor (to_real (arg));
      result := to_ufixed (arg            => arg_real,
                           left_index     => result'high,
                           right_index    => result'low,
                           round_style    => round_style,
                           overflow_style => overflow_style);
    end if;
    return result;
  end function floor;

  function floor (
    arg                     : sfixed;
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style)
    return sfixed is
    variable arg_real : REAL;
    variable result   : sfixed (arg'range);
  begin
    if arg'high < 0 then
      report fixed_alg_pkg'instance_name & "floor (sfixed) :" &
        "left index less than zero (" & INTEGER'image(arg'high) & ")"
        severity error;
      result := (others => '0');
    else
      arg_real := floor (to_real (arg));
      result := to_sfixed (arg            => arg_real,
                           left_index     => result'high,
                           right_index    => result'low,
                           round_style    => round_style,
                           overflow_style => overflow_style);
    end if;
    return result;
  end function floor;

  -- largest integer not less than arg
  function ceil (
    arg                     : ufixed;
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style)
    return ufixed is
    variable arg_real : REAL;
    variable result   : ufixed (arg'range);
  begin
    if arg'high < 0 then
      report fixed_alg_pkg'instance_name & "ceil (ufixed) :" &
        "left index less than zero (" & INTEGER'image(arg'high) & ")"
        severity error;
      result := (others => '0');
    else
      arg_real := ceil (to_real (arg));
      result := to_ufixed (arg            => arg_real,
                           left_index     => result'high,
                           right_index    => result'low,
                           round_style    => round_style,
                           overflow_style => overflow_style);
    end if;
    return result;
  end function ceil;

  function ceil (
    arg                     : sfixed;
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style)
    return sfixed is
    variable arg_real : REAL;
    variable result   : sfixed (arg'range);
  begin
    if arg'high < 1 then
      report fixed_alg_pkg'instance_name & "ceil (sfixed) :" &
        "left index less than one (" & INTEGER'image(arg'high) & ")"
        severity error;
      result := (others => '0');
    else
      arg_real := ceil (to_real (arg));
      result := to_sfixed (arg            => arg_real,
                           left_index     => result'high,
                           right_index    => result'low,
                           round_style    => round_style,
                           overflow_style => overflow_style);
    end if;
    return result;
  end function ceil;


  -- Newton-Raphson divide (uses a loop to do division)
  function nr_divide (
    l, r                 : sfixed;      -- fixed point input
    constant round_style : fixed_round_style_type := fixed_round_style;
    constant guard_bits  : NATURAL                := fixed_guard_bits;
    constant iterations  : NATURAL                := 0)
    return sfixed is
    variable l_real, r_real : REAL;
  begin
    if (l'length < 1 or r'length < 1) then
      return NASF;
    else
      l_real := to_real (l);
      r_real := to_real (r);
      return to_sfixed (arg         => l_real/r_real,
                        left_index  => l'high-r'low+1,
                        right_index => l'low-r'high,
                        round_style => round_style,
                        guard_bits  => guard_bits);
    end if;
  end function nr_divide;

  -- Newton-Raphson reciprocal (uses a loop to do division)
  function nr_reciprocal (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed is
    variable arg_real : REAL;
  begin
    if (arg'length < 1) then
      return NASF;
    else
      arg_real := to_real (arg);
      return to_sfixed (arg            => 1.0/arg_real,
                        left_index     => -arg'low+1,
                        right_index    => -arg'high,
                        round_style    => round_style,
                        guard_bits     => guard_bits,
                        overflow_style => overflow_style);
    end if;
  end function nr_reciprocal;

  function sqrt (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits)
    return sfixed is
    variable arg_real : REAL;
    variable result   : REAL;
  begin
    if (arg'length < 1) then
      return NASF;
    elsif (arg < 0) then                -- negative argument
      report "fixed_alg_pkg.sqrt(sfixed): Square root of a negative number."
        severity error;
      return to_sfixed (0, arg'high, arg'low);
    elsif (arg = 0) then                -- sqrt (0)
      return to_sfixed (0, arg'high, arg'low);
    else
      arg_real := to_real(arg);
      result   := sqrt (arg_real);
      return to_sfixed (arg            => result,
                        left_index     => arg'high,
                        right_index    => arg'low,
                        round_style    => round_style,
                        guard_bits     => guard_bits,
                        overflow_style => overflow_style);
    end if;
  end function sqrt;

  function cbrt (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits)
    return sfixed is
    variable arg_real : REAL;
    variable result   : REAL;
  begin
    if (arg'length < 1) then
      return NASF;
    elsif (arg = 0) then                -- cbrt (0)
      return to_sfixed (0, arg'high, arg'low);
    else
      arg_real := to_real(arg);
      result   := cbrt (arg_real);
      return to_sfixed (arg            => result,
                        left_index     => arg'high,
                        right_index    => arg'low,
                        round_style    => round_style,
                        guard_bits     => guard_bits,
                        overflow_style => overflow_style);
    end if;
  end function cbrt;

  function inverse_sqrt (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed is
    variable arg_real : REAL;
    variable result   : REAL;
  begin
    if (arg'length < 1) then
      return NASF;
    elsif (arg < 0) then                -- negative argument
      report "fixed_alg_pkg.inverse_sqrt(sfixed): Square root of a negative number."
        severity error;
      return to_sfixed (0, arg'high, arg'low);
    elsif (arg = 0) then                -- 1/sqrt (0)
      report "fixed_alg_pkg.inverse_sqrt(sfixed): Divide by zero"
        severity error;
      return to_sfixed (0, arg'high, arg'low);
    else
      arg_real := to_real(arg);
      result   := 1.0/sqrt (arg_real);
      return to_sfixed (arg            => result,
                        left_index     => arg'high,
                        right_index    => arg'low,
                        round_style    => round_style,
                        guard_bits     => guard_bits,
                        overflow_style => overflow_style);
    end if;
  end function inverse_sqrt;

  -- returns e**arg
  function exp (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed is
    variable arg_real : REAL;
    variable result   : REAL;
  begin
    if (arg'length < 1) then
      return NASF;
    elsif (arg = 0) then                -- exp (0)
      return to_sfixed (1, arg'high, arg'low);
    else
      arg_real := to_real(arg);
      result   := exp (arg_real);
      return to_sfixed (arg            => result,
                        left_index     => arg'high,
                        right_index    => arg'low,
                        round_style    => round_style,
                        guard_bits     => guard_bits,
                        overflow_style => overflow_style);
    end if;
  end function exp;

  -- returns ln(arg)/ln(base)
  function log (
    arg                     : sfixed;    -- fixed point input
    base                    : POSITIVE;  -- Log of a positive number
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed is
    variable base_fixed : sfixed (arg'high downto 0);
  begin
    base_fixed := to_sfixed (arg            => base,
                             left_index     => arg'high,
                             right_index    => 0,
                             overflow_style => overflow_style);
    return log (arg            => arg,
                base           => base_fixed,
                overflow_style => overflow_style,
                round_style    => round_style,
                guard_bits     => guard_bits);
  end function log;

  -- returns ln(arg)/ln(base)
  function log (
    arg                     : sfixed;   -- fixed point input
    base                    : sfixed;   -- Log of a positive number
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed is
    variable arg_real  : REAL;
    variable base_real : REAL;
    variable result    : REAL;
  begin
    if (arg'length < 1 or base'length < 1) then
      return NASF;
    elsif (arg < 0 or base < 0) then    -- log(-X) = error
      report "Fixed_Alg_Pkg.log(sfixed): Log of negative number."
        severity error;
      return to_sfixed (0, arg'high, arg'low);
    elsif (arg = 0) then                -- log(0) = -inf
      assert (NO_WARNING)
        report "Fixed_Alg_Pkg.log(sfixed): Arg = 0.0" severity warning;
      return not saturate (arg'high, arg'low);
    elsif (base = 0) then               -- log0(X) = 0
      return to_sfixed (0, arg'high, arg'low);
    elsif (arg = 1) then                -- log(1) = zero
      return to_sfixed (0, arg'high, arg'low);
    elsif (base = 1) then               -- log1(x) = inf
      assert (NO_WARNING)
        report "Fixed_Alg_Pkg.log(sfixed): Base = 1.0" severity warning;
      return saturate (arg'high, arg'low);
    elsif (arg = base) then             -- log(X,X) = 1
      return to_sfixed (1, arg'high, arg'low);
    else
      arg_real  := to_real (arg);
      base_real := to_real (base);
      result    := log (arg_real) / log (base_real);
      return to_sfixed (arg            => result,
                        left_index     => arg'high,
                        right_index    => arg'low,
                        round_style    => round_style,
                        guard_bits     => guard_bits,
                        overflow_style => overflow_style);
    end if;
  end function log;

  -- returns l**r
  function power_of (
    l, r                    : sfixed;        -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits)
    return sfixed is
    variable r_real, l_real, result : REAL;  -- Real versions
  begin
    if (l'length < 1 or r'length < 1) then
      return NASF;
    elsif (l = 0) then                       -- 0**X = 0
      return to_sfixed (0, l'high, l'low);
    elsif (r = 0) then                       -- X**0 = 1
      return to_sfixed (1, l'high, l'low);
    else
      l_real := to_real(l);
      r_real := to_real(r);
      result := l_real ** r_real;
      return to_sfixed (arg            => result,
                        left_index     => l'high,
                        right_index    => l'low,
                        round_style    => round_style,
                        guard_bits     => guard_bits,
                        overflow_style => overflow_style);
    end if;
  end function power_of;

  -- returns l**r
  function power_of (
    l                       : sfixed;   -- fixed point input
    r                       : INTEGER;  -- Integer input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits)
    return sfixed is
    variable base_fixed : sfixed (l'high downto 0);
  begin
    base_fixed := to_sfixed (arg            => r,
                             left_index     => l'high,
                             right_index    => 0,
                             overflow_style => overflow_style);
    return power_of (l              => l,
                     r              => base_fixed,
                     overflow_style => overflow_style,
                     round_style    => round_style,
                     guard_bits     => guard_bits);
  end function power_of;

  -- returns ln(arg)
  function ln (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed is
    variable arg_real, result : REAL;   -- Real versions
  begin
    if arg'length < 1 then
      return NASF;
    elsif (to_x01(arg(arg'high)) = '1') then
      report "Fixed_Alg_Pkg.ln(sfixed): Arg < 0.0" severity error;
      return to_sfixed (0, arg'high, arg'low);
    elsif (arg = 0) then
      assert (NO_WARNING)
        report "Fixed_Alg_Pkg.ln(sfixed): Arg = 0.0" severity warning;
      return not saturate (arg'high, arg'low);
    elsif (arg = 1) then                -- log(1) = zero
      return to_sfixed (0, arg'high, arg'low);
    else
      arg_real := to_real (arg);
      result   := log (arg_real);
      return to_sfixed (arg            => result,
                        left_index     => arg'high,
                        right_index    => arg'low,
                        round_style    => round_style,
                        guard_bits     => guard_bits,
                        overflow_style => overflow_style);
    end if;
  end function ln;

  function "**" (
    l, r : sfixed)                      -- fixed point input
    return sfixed is
  begin
    return power_of (l => l,
                     r => r);
  end function "**";

  function "**" (
    l : sfixed;                         -- fixed point input
    r : INTEGER)
    return sfixed is
  begin
    return power_of (l => l,
                     r => r);
  end function "**";

  function nr_divide (
    l, r                 : ufixed;      -- fixed point input
    constant round_style : fixed_round_style_type := fixed_round_style;
    constant guard_bits  : NATURAL                := fixed_guard_bits;
    constant iterations  : NATURAL                := 0)
    return ufixed is
    variable l_real, r_real : REAL;
  begin
    if (l'length < 1 or r'length < 1) then
      return NAuF;
    else
      l_real := to_real (l);
      r_real := to_real (r);
      return to_ufixed (arg         => l_real/r_real,
                        left_index  => l'high-r'low,
                        right_index => l'low-r'high-1,
                        round_style => round_style,
                        guard_bits  => guard_bits);
    end if;
  end function nr_divide;

  -- Newton-Raphson reciprocal (uses a loop to do division)
  function nr_reciprocal (
    arg                     : ufixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return ufixed is
    variable arg_real : REAL;
  begin
    if (arg'length < 1) then
      return NAUF;
    else
      arg_real := to_real (arg);
      return to_ufixed (arg            => 1.0/arg_real,
                        left_index     => -arg'low,
                        right_index    => -arg'high-1,
                        round_style    => round_style,
                        guard_bits     => guard_bits,
                        overflow_style => overflow_style);
    end if;
  end function nr_reciprocal;
  
  function sqrt (
    arg                     : ufixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits)
    return ufixed is
    variable arg_real : REAL;
    variable result   : REAL;
  begin
    if (arg'length < 1) then
      return NAUF;
    elsif (arg = 0) then                -- sqrt (0)
      return to_ufixed (0, arg'high, arg'low);
    else
      arg_real := to_real(arg);
      result   := sqrt (arg_real);
      return to_ufixed (arg            => result,
                        left_index     => arg'high,
                        right_index    => arg'low,
                        round_style    => round_style,
                        guard_bits     => guard_bits,
                        overflow_style => overflow_style);
    end if;
  end function sqrt;

  function cbrt (
    arg                     : ufixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits)
    return ufixed is
    variable arg_real : REAL;
    variable result   : REAL;
  begin
    if (arg'length < 1) then
      return NAUF;
    elsif (arg = 0) then                -- cbrt (0)
      return to_ufixed (0, arg'high, arg'low);
    else
      arg_real := to_real(arg);
      result   := cbrt (arg_real);
      return to_ufixed (arg            => result,
                        left_index     => arg'high,
                        right_index    => arg'low,
                        round_style    => round_style,
                        guard_bits     => guard_bits,
                        overflow_style => overflow_style);
    end if;
  end function cbrt;

  function inverse_sqrt (
    arg                     : ufixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return ufixed is
    variable arg_real : REAL;
    variable result   : REAL;
  begin
    if (arg'length < 1) then
      return NAUF;
    elsif (arg = 0) then                -- 1/sqrt (0)
      report "fixed_alg_pkg.inverse_sqrt(ufixed): Divide by zero"
        severity error;
      return to_ufixed (0, arg'high, arg'low);
    else
      arg_real := to_real(arg);
      result   := 1.0/sqrt (arg_real);
      return to_ufixed (arg            => result,
                        left_index     => arg'high,
                        right_index    => arg'low,
                        round_style    => round_style,
                        guard_bits     => guard_bits,
                        overflow_style => overflow_style);
    end if;
  end function inverse_sqrt;

  -- returns e**arg
  function exp (
    arg                     : ufixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return ufixed is
    variable arg_real : REAL;
    variable result   : REAL;
  begin
    if (arg'length < 1) then
      return NAUF;
    elsif (arg = 0) then                -- cbrt (0)
      return to_ufixed (1, arg'high, arg'low);
    else
      arg_real := to_real(arg);
      result   := exp (arg_real);
      return to_ufixed (arg            => result,
                        left_index     => arg'high,
                        right_index    => arg'low,
                        round_style    => round_style,
                        guard_bits     => guard_bits,
                        overflow_style => overflow_style);
    end if;
  end function exp;

  -- returns ln(arg)/ln(base)
  function log (
    arg                     : ufixed;    -- fixed point input
    base                    : POSITIVE;  -- Log of a positive number
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed is
    variable arg_real   : REAL;
    variable base_real  : REAL;
    variable result     : REAL;
    variable base_fixed : ufixed (arg'high downto 0);
  begin
    base_fixed := to_ufixed (arg            => base,
                             left_index     => arg'high,
                             right_index    => 0,
                             overflow_style => overflow_style);
    return log (arg            => arg,
                base           => base_fixed,
                overflow_style => overflow_style,
                round_style    => round_style,
                guard_bits     => guard_bits);
  end function log;

  -- returns ln(arg)/ln(base)
  function log (
    arg                     : ufixed;   -- fixed point input
    base                    : ufixed;   -- Log of a positive number
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed is
    variable arg_real  : REAL;
    variable base_real : REAL;
    variable result    : REAL;
  begin
    if (arg'length < 1 or base'length < 1) then
      return NASF;
    elsif (arg = 0) then                -- log(0) = -inf
      assert (NO_WARNING)
        report "Fixed_Alg_Pkg.log(ufixed): Arg = 0.0" severity warning;
      return not saturate (arg'high+1, arg'low);
    elsif (base = 0) then               -- log0(X) = 0
      return to_sfixed (0, arg'high+1, arg'low);
    elsif (arg = 1) then                -- log(1) = zero
      return to_sfixed (0, arg'high+1, arg'low);
    elsif (base = 1) then               -- log1(x) = inf
      assert (NO_WARNING)
        report "Fixed_Alg_Pkg.log(ufixed): Base = 1.0" severity warning;
      return saturate (arg'high+1, arg'low);
    elsif (arg = base) then             -- log(X,X) = 1
      return to_sfixed (1, arg'high+1, arg'low);
    else
      arg_real  := to_real (arg);
      base_real := to_real (base);
      result    := log (arg_real) / log (base_real);
      return to_sfixed (arg            => result,
                        left_index     => arg'high+1,
                        right_index    => arg'low,
                        round_style    => round_style,
                        guard_bits     => guard_bits,
                        overflow_style => overflow_style);
    end if;
  end function log;

  -- returns l**r
  function power_of (
    l, r                    : ufixed;        -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits)
    return ufixed is
    variable r_real, l_real, result : REAL;  -- Real versions
  begin
    if (l'length < 1 or r'length < 1) then
      return NAUF;
    elsif (l = 0) then                       -- 0**X = 0
      return to_ufixed (0, l'high, l'low);
    elsif (r = 0) then                       -- X**0 = 1
      return to_ufixed (1, l'high, l'low);
    else
      l_real := to_real(l);
      r_real := to_real(r);
      result := l_real ** r_real;
      return to_ufixed (arg            => result,
                        left_index     => l'high,
                        right_index    => l'low,
                        round_style    => round_style,
                        guard_bits     => guard_bits,
                        overflow_style => overflow_style);
    end if;
  end function power_of;

  -- returns l**r
  function power_of (
    l                       : ufixed;   -- fixed point input
    r                       : NATURAL;  -- Integer input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits)
    return ufixed is
    variable base_fixed : ufixed (l'high downto 0);
  begin
    base_fixed := to_ufixed (arg            => r,
                             left_index     => l'high,
                             right_index    => 0,
                             overflow_style => overflow_style);
    return power_of (l              => l,
                     r              => base_fixed,
                     overflow_style => overflow_style,
                     round_style    => round_style,
                     guard_bits     => guard_bits);
  end function power_of;

  -- returns ln(arg)
  function ln (
    arg                     : ufixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed is
    variable arg_real, result : REAL;   -- Real versions
  begin
    if arg'length < 1 then
      return NASF;
    elsif (arg = 0) then
      assert (NO_WARNING)
        report "Fixed_Alg_Pkg.ln(ufixed): Arg = 0.0" severity warning;
      return not saturate (arg'high+1, arg'low);
    elsif (arg = 1) then                -- ln(1) = zero
      return to_sfixed (0, arg'high+1, arg'low);
    else
      arg_real := to_real (arg);
      result   := log (arg_real);
      return to_sfixed (arg            => result,
                        left_index     => arg'high+1,
                        right_index    => arg'low,
                        round_style    => round_style,
                        guard_bits     => guard_bits,
                        overflow_style => overflow_style);
    end if;
  end function ln;

  -- returns log2(arg)
  function log2 (
    arg                     : ufixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed is
    variable arg_real, result : REAL;
  begin
    if arg'length < 1 then
      return NASF;
    elsif (arg = 0) then
      assert (NO_WARNING)
        report "Fixed_Alg_Pkg.log2(ufixed): Arg = 0.0" severity warning;
      return not saturate (arg'high+1, arg'low);
    elsif (arg = 1) then                -- ln(1) = zero
      return to_sfixed (0, arg'high+1, arg'low);
    else
      arg_real := to_real (arg);
      result   := log2 (arg_real);
      return to_sfixed (arg            => result,
                        left_index     => arg'high+1,
                        right_index    => arg'low,
                        round_style    => round_style,
                        guard_bits     => guard_bits,
                        overflow_style => overflow_style);
    end if;
  end function log2;

  -- returns log10(arg)
  function log10 (
    arg                     : ufixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed is
    variable arg_real, result : REAL;
  begin
    if arg'length < 1 then
      return NASF;
    elsif (arg = 0) then
      assert (NO_WARNING)
        report "Fixed_Alg_Pkg.log10(ufixed): Arg = 0.0" severity warning;
      return not saturate (arg'high+1, arg'low);
    elsif (arg = 1) then                -- ln(1) = zero
      return to_sfixed (0, arg'high+1, arg'low);
    else
      arg_real := to_real (arg);
      result   := log10 (arg_real);
      return to_sfixed (arg            => result,
                        left_index     => arg'high+1,
                        right_index    => arg'low,
                        round_style    => round_style,
                        guard_bits     => guard_bits,
                        overflow_style => overflow_style);
    end if;
  end function log10;
  
  
  function "**" (
    l, r : ufixed)                      -- fixed point input
    return ufixed is
  begin
    return power_of (l => l,
                     r => r);
  end function "**";

  function "**" (
    l : ufixed;                         -- fixed point input
    r : NATURAL)
    return ufixed is
  begin
    return power_of (l => l,
                     r => r);
  end function "**";

  -----------------------------------------------------------------------------
  -- Angle functions
  -- sine, cosine, tangent, arc_sine, arc_cosine, arc_tangent
  function sin (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant bounded        : BOOLEAN                   := false)  -- Bounded by 0 to 2PI
    return sfixed is
    variable arg_real, result : REAL;   -- real versions
  begin
    if arg'length < 1 then
      return NASF;
    else
      arg_real := to_real (arg);
      result   := sin (arg_real);
      return to_sfixed (arg            => result,
                        left_index     => arg'high,
                        right_index    => arg'low,
                        round_style    => round_style,
                        guard_bits     => guard_bits,
                        overflow_style => overflow_style);
    end if;
  end function sin;

  function cos (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant bounded        : BOOLEAN                   := false)  -- Bounded by 0 to 2PI
    return sfixed is
    variable arg_real, result : REAL;   -- real versions
  begin
    if arg'length < 1 then
      return NASF;
    else
      arg_real := to_real (arg);
      result   := cos (arg_real);
      return to_sfixed (arg            => result,
                        left_index     => arg'high,
                        right_index    => arg'low,
                        round_style    => round_style,
                        guard_bits     => guard_bits,
                        overflow_style => overflow_style);
    end if;
  end function cos;

  function tan (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant bounded        : BOOLEAN                   := false)  -- Bounded by 0 to 2PI
    return sfixed is
    variable arg_real, result : REAL;   -- real versions
  begin
    if arg'length < 1 then
      return NASF;
    else
      arg_real := to_real (arg);
      result   := tan (arg_real);
      return to_sfixed (arg            => result,
                        left_index     => arg'high,
                        right_index    => arg'low,
                        round_style    => round_style,
                        guard_bits     => guard_bits,
                        overflow_style => overflow_style);
    end if;
  end function tan;

  function arcsin (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed is
    variable arg_real, result : REAL;   -- real versions
    constant one              : sfixed (1 downto 0) := "01";  -- 1
    constant mone             : sfixed (1 downto 0) := "11";  -- -1
  begin
    if arg'length < 1 then
      return NASF;
    elsif (arg > one) or (arg < mone) then                    -- -1 < x < 1
      report "Fixed_Alg_Pkg.arcsin(sfixed): Argument not in range 1.0 to -1.0"
        severity error;
      return to_sfixed (0, arg'high, arg'low);
    elsif (arg = one or arg = mone) then
      if (to_x01(arg(arg'high)) = '1') then
        return to_sfixed (-MATH_PI_OVER_2, arg'high, arg'low);
      else
        return to_sfixed (MATH_PI_OVER_2, arg'high, arg'low);
      end if;
    else
      arg_real := to_real (arg);
      result   := arcsin (arg_real);
      return to_sfixed (arg            => result,
                        left_index     => arg'high,
                        right_index    => arg'low,
                        round_style    => round_style,
                        guard_bits     => guard_bits,
                        overflow_style => overflow_style);
    end if;
  end function arcsin;

  function arccos (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed is
    variable arg_real, result : REAL;   -- real versions
    constant one              : sfixed (1 downto 0) := "01";  -- 1
    constant mone             : sfixed (1 downto 0) := "11";  -- -1
  begin
    if arg'length < 1 then
      return NASF;
    elsif (arg > one) or (arg < mone) then                    -- -1 < x < 1
      report "Fixed_Alg_Pkg.arccos(sfixed): Argument not in range 1.0 to -1.0"
        severity error;
      return to_sfixed (0, arg'high, arg'low);
    elsif (arg = one) then
      return to_sfixed (0, arg'high, arg'low);
    elsif (arg = mone) then
      return to_sfixed (MATH_PI, arg'high, arg'low);
    else
      arg_real := to_real (arg);
      result   := arccos (arg_real);
      return to_sfixed (arg            => result,
                        left_index     => arg'high,
                        right_index    => arg'low,
                        round_style    => round_style,
                        guard_bits     => guard_bits,
                        overflow_style => overflow_style);
    end if;
  end function arccos;

  function arctan (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed is
    variable arg_real, result : REAL;   -- real versions
  begin
    if arg'length < 1 then
      return NASF;
    else
      arg_real := to_real (arg);
      result   := arctan (arg_real);
      return to_sfixed (arg            => result,
                        left_index     => arg'high,
                        right_index    => arg'low,
                        round_style    => round_style,
                        guard_bits     => guard_bits,
                        overflow_style => overflow_style);
    end if;
  end function arctan;

  function sinh (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed is
    variable arg_real, result : REAL;   -- real versions
  begin
    if arg'length < 1 then
      return NASF;
    else
      arg_real := to_real (arg);
      result   := sinh (arg_real);
      return to_sfixed (arg            => result,
                        left_index     => arg'high,
                        right_index    => arg'low,
                        round_style    => round_style,
                        guard_bits     => guard_bits,
                        overflow_style => overflow_style);
    end if;
  end function sinh;

  function cosh (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed is
    variable arg_real, result : REAL;   -- real versions
  begin
    if arg'length < 1 then
      return NASF;
    else
      arg_real := to_real (arg);
      result   := cosh (arg_real);
      return to_sfixed (arg            => result,
                        left_index     => arg'high,
                        right_index    => arg'low,
                        round_style    => round_style,
                        guard_bits     => guard_bits,
                        overflow_style => overflow_style);
    end if;
  end function cosh;

  function tanh (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed is
    variable arg_real, result : REAL;   -- real versions
  begin
    if arg'length < 1 then
      return NASF;
    else
      arg_real := to_real (arg);
      result   := tanh (arg_real);
      return to_sfixed (arg            => result,
                        left_index     => arg'high,
                        right_index    => arg'low,
                        round_style    => round_style,
                        guard_bits     => guard_bits,
                        overflow_style => overflow_style);
    end if;
  end function tanh;


  function arcsinh (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed is
    variable arg_real, result : REAL;   -- real versions
  begin
    if arg'length < 1 then
      return NASF;
    else
      arg_real := to_real (arg);
      result   := arcsinh (arg_real);
      return to_sfixed (arg            => result,
                        left_index     => arg'high,
                        right_index    => arg'low,
                        round_style    => round_style,
                        guard_bits     => guard_bits,
                        overflow_style => overflow_style);
    end if;
  end function arcsinh;

  function arccosh (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed is
    variable arg_real, result : REAL;   -- real versions
  begin
    if arg'length < 1 then
      return NASF;
    else
      arg_real := to_real (arg);
      result   := arccosh (arg_real);
      return to_sfixed (arg            => result,
                        left_index     => arg'high,
                        right_index    => arg'low,
                        round_style    => round_style,
                        guard_bits     => guard_bits,
                        overflow_style => overflow_style);
    end if;
  end function arccosh;

  function arctanh (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed is
    variable arg_real, result : REAL;   -- real versions
  begin
    if arg'length < 1 then
      return NASF;
    else
      arg_real := to_real (arg);
      result   := arctanh (arg_real);
      return to_sfixed (arg            => result,
                        left_index     => arg'high,
                        right_index    => arg'low,
                        round_style    => round_style,
                        guard_bits     => guard_bits,
                        overflow_style => overflow_style);
    end if;
  end function arctanh;
  
end package body fixed_alg_pkg;
