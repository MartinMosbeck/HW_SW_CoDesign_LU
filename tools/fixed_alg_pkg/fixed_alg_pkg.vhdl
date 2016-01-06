-- --------------------------------------------------------------------
-- Title      : fixed_alg_pkg.vhd
-- These are the algorithemic functions.  In this package you will find
-- routines for doing complex arithmetic and basic Trig functions.  These
-- functions are not optomized, and are placed here as examples.  In the
-- future, a new complex number format will be used and placed into the
-- fixed point packages.
-- Last Modified: $Date: 2012/02/23 18:32:09 $
-- RCS ID: $Id: fixed_alg_pkg.vhdl,v 2.2 2012/02/23 18:32:09 l435385 Exp l435385 $
--
--  Created for VHDL-200X-ft, David Bishop (dbishop@vhdl.org) 
-- ---------------------------------------------------------------------------
library ieee_proposed;
use ieee_proposed.fixed_float_types.all;
use ieee_proposed.fixed_pkg.all;

package fixed_alg_pkg is
  -- This differed constant will tell you if the package body is synthesizable
  -- or implimented as real numbers.
  constant fixed_alg_synth_or_real : BOOLEAN;  -- differed constant

  -- Rounds to a given precision.  "places" is the number of bits to round to.
  function precision (
    arg                     : sfixed;
    constant places         : NATURAL;
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style)
    return sfixed;

  function precision (
    arg                     : ufixed;
    constant places         : NATURAL;
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style)
    return ufixed;

  -- largest integer not greater than arg
  function floor (
    arg                     : ufixed;
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style)
    return ufixed;

  function floor (
    arg                     : sfixed;
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style)
    return sfixed;

  -- largest integer not less than arg
  function ceil (
    arg                     : ufixed;
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style)
    return ufixed;

  function ceil (
    arg                     : sfixed;
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style)
    return sfixed;


  -- Newton-Raphson divide (uses a loop to do division)
  function nr_divide (
    l, r                 : sfixed;      -- fixed point input
    constant round_style : fixed_round_style_type := fixed_round_style;
    constant guard_bits  : NATURAL                := fixed_guard_bits;
    constant iterations  : NATURAL                := 0)
    return sfixed;

  -- Newton-Raphson reciprocal (uses a loop to do division)
  function nr_reciprocal (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed;
  
  function sqrt (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits)
    return sfixed;

  function cbrt (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits)
    return sfixed;

  function inverse_sqrt (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed;

  -- returns e**arg
  function exp (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed;

  -- returns ln(arg)/ln(base)
  function log (
    arg                     : sfixed;    -- fixed point input
    base                    : POSITIVE;  -- Log of a positive number
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed;

  -- returns ln(arg)/ln(base)
  function log (
    arg                     : sfixed;   -- fixed point input
    base                    : sfixed;   -- Log of a positive number
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed;

  -- returns l**r
  function power_of (
    l, r                    : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits)
    return sfixed;

  -- returns l**r
  function power_of (
    l                       : sfixed;   -- fixed point input
    r                       : INTEGER;  -- Integer input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits)
    return sfixed;

  -- returns ln(arg)
  function ln (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed;

  function "**" (
    l, r : sfixed)                      -- fixed point input
    return sfixed;

  function "**" (
    l : sfixed;                         -- fixed point input
    r : INTEGER)
    return sfixed;

  -- Uses nr_reciprocal
  function nr_divide (
    l, r                 : ufixed;      -- fixed point input
    constant round_style : fixed_round_style_type := fixed_round_style;
    constant guard_bits  : NATURAL                := fixed_guard_bits;
    constant iterations  : NATURAL                := 0)
    return ufixed;

  -- Newton-Raphson reciprocal (uses a loop to do division)
  function nr_reciprocal (
    arg                     : ufixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return ufixed;

  -- Square root
  function sqrt (
    arg                     : ufixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits)
    return ufixed;

  -- Cube root
  function cbrt (
    arg                     : ufixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits)
    return ufixed;

  -- 1.0/SQRT(x) (more efficient that SQRT(x))
  function inverse_sqrt (
    arg                     : ufixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return ufixed;

  -- returns e**arg
  function exp (
    arg                     : ufixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return ufixed;

  -- returns ln(arg)/ln(base)
  function log (
    arg                     : ufixed;    -- fixed point input
    base                    : POSITIVE;  -- Log of a positive number
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed;

  -- returns ln(arg)/ln(base)
  function log (
    arg                     : ufixed;   -- fixed point input
    base                    : ufixed;   -- Log of a positive number
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed;

  -- returns l**r
  function power_of (
    l, r                    : ufixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits)
    return ufixed;

  -- returns l**r
  function power_of (
    l                       : ufixed;   -- fixed point input
    r                       : NATURAL;  -- Integer input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits)
    return ufixed;

  -- returns ln(arg)
  function ln (
    arg                     : ufixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed;

  -- returns log2(arg)
  function log2 (
    arg                     : ufixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed;

  -- returns log10(arg)
  function log10 (
    arg                     : ufixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed;
  
  function "**" (
    l, r : ufixed)                      -- fixed point input
    return ufixed;

  function "**" (
    l : ufixed;                         -- fixed point input
    r : NATURAL)
    return ufixed;

  -----------------------------------------------------------------------------
  -- Trigonometric functions
  -- sine, cosine, tangent, arc_sine, arc_cosine, arc_tangent
  function sin (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant bounded        : BOOLEAN                   := false)  -- Bounded by 0 to 2PI
    return sfixed;

  function cos (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant bounded        : BOOLEAN                   := false)  -- Bounded by 0 to 2PI
    return sfixed;

  function tan (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant bounded        : BOOLEAN                   := false)  -- Bounded by 0 to 2PI
    return sfixed;

  function arcsin (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed;

  function arccos (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed;

  function arctan (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed;

  function sinh (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed;

  function cosh (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed;

  function tanh (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed;

  function arcsinh (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed;

  function arccosh (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed;

  function arctanh (
    arg                     : sfixed;   -- fixed point input
    constant overflow_style : fixed_overflow_style_type := fixed_overflow_style;
    constant round_style    : fixed_round_style_type    := fixed_round_style;
    constant guard_bits     : NATURAL                   := fixed_guard_bits;
    constant iterations     : NATURAL                   := 0)
    return sfixed;
end package fixed_alg_pkg;
