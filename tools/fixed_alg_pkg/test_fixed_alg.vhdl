-- --------------------------------------------------------------------
-- Title      : Test vectors for testing the "fixed_alg_pkg" package.
-- This testbench test the algorithemic functions
-- Last Modified: $Date: 2012/02/23 18:32:09 $
-- RCS ID: $Id: test_fixed_alg.vhdl,v 2.2 2012/02/23 18:32:09 l435385 Exp l435385 $
--
--  Created for VHDL-200X-ft, David Bishop (dbishop@vhdl.org) 
-- ---------------------------------------------------------------------------

entity test_fixed_alg is
  generic (
    quiet : BOOLEAN := false);          -- run quietly
end entity test_fixed_alg;

library ieee, ieee_proposed;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.math_real.all;
use ieee_proposed.fixed_float_types.all;
use ieee_proposed.fixed_pkg.all;
use work.fixed_alg_pkg.all;
architecture testbench of test_fixed_alg is
  constant debug : BOOLEAN := false;    -- debug mode, prints out lots of data
  procedure report_error (
    constant errmes   : in STRING;      -- error message
    actual            : in ufixed;      -- data from algorithm
    constant expected : in ufixed) is   -- reference data
  begin  -- function report_error
    assert actual = expected
      report errmes & CR
      & "Actual: " & to_string(actual)
      & " (" & REAL'image(to_real(actual)) & ")" & CR
      & "     /= " & to_string(expected)
      & " (" & REAL'image(to_real(expected)) & ")"
      severity error;
  end procedure report_error;

  procedure report_error (
    constant errmes   :    STRING;      -- error message
    actual            : in sfixed;      -- data from algorithm
    constant expected :    sfixed) is   -- reference data
  begin  -- function report_error
    assert actual = expected
      report errmes & CR
      & "Actual: " & to_string(actual)
      & " (" & REAL'image(to_real(actual)) & ")" & CR
      & "     /= " & to_string(expected)
      & " (" & REAL'image(to_real(expected)) & ")"
      severity error;
  end procedure report_error;

  -- purpose: reports an error
  -- If the result is within 1 bit of the actual, this returns true.
  procedure report_error_bias (
    constant errmes   : in STRING;      -- error message
    actual            : in ufixed;      -- data from algorithm
    constant expected : in ufixed) is   -- reference data
    variable bias           : ufixed (expected'range) := (others => '0');  -- bias
    variable fract1, fract2 : ufixed (expected'range);
  begin  -- function report_error
    if actual /= expected then
      bias(bias'low) := '1';
      fract1         := resize(expected - bias, fract1);
      fract2         := resize(expected + bias, fract2);
      if (actual > fract2 or actual < fract1) then
        report errmes & CR
          & "Actual: " & to_string(actual)
          & " (" & REAL'image(to_real(actual)) & ")" & CR
          & "     /= " & to_string(expected)
          & " (" & REAL'image(to_real(expected)) & ")"
          severity error;
      elsif (debug) then
        report errmes & CR
          & "Actual: " & to_string(actual)
          & " (" & REAL'image(to_real(actual)) & ")" & CR
          & "     /= " & to_string(expected)
          & " (" & REAL'image(to_real(expected)) & ")"
          severity warning;
      end if;
    end if;
  end procedure report_error_bias;

  -- If the result is within 1 bit of the actual, this returns true.
  procedure report_error_bias (
    constant errmes   :    STRING;      -- error message
    actual            : in sfixed;      -- data from algorithm
    constant expected :    sfixed) is   -- reference data
    variable bias           : sfixed (expected'range) := (others => '0');  -- bias
    variable fract1, fract2 : sfixed (expected'range);
  begin  -- function report_error
    if actual /= expected then
      bias(bias'low) := '1';
      fract1         := resize(expected - bias, fract1);
      fract2         := resize(expected + bias, fract2);
      if (actual > fract2 or actual < fract1) then
        report errmes & CR
          & "Actual: " & to_string(actual)
          & " (" & REAL'image(to_real(actual)) & ")" & CR
          & "     /= " & to_string(expected)
          & " (" & REAL'image(to_real(expected)) & ")"
          severity error;
      elsif (debug) then
        report errmes & CR
          & "Actual: " & to_string(actual)
          & " (" & REAL'image(to_real(actual)) & ")" & CR
          & "     /= " & to_string(expected)
          & " (" & REAL'image(to_real(expected)) & ")"
          severity warning;
      end if;
    end if;
  end procedure report_error_bias;

  -- If the result is within 1 bit of the actual, this returns true.
  procedure report_error_precision (
    constant errmes   :    STRING;      -- error message
    actual            : in sfixed;      -- data from algorithm
    constant expected :    sfixed;      -- reference data
    constant bits     : in INTEGER) is  -- Bit precision
    variable fract1, fract2 : sfixed (expected'range);
  begin  -- function report_error
    if actual /= expected then
      -- Round to a number of bits.
      fract1 := precision(expected, bits);
      fract2 := precision(actual, bits);
--      report "fract1 = " & to_string(fract1) severity note;
--      report "fract2 = " & to_string(fract2) severity note;
      if (fract1 /= fract2) then
        report errmes & CR
          & "Actual: " & to_string(actual)
          & " (" & REAL'image(to_real(actual)) & ")" & CR
          & "     /= " & to_string(expected)
          & " (" & REAL'image(to_real(expected)) & ")"
          severity error;
      elsif (debug) then
        report errmes & CR
          & "Actual: " & to_string(actual)
          & " (" & REAL'image(to_real(actual)) & ")" & CR
          & "     /= " & to_string(expected)
          & " (" & REAL'image(to_real(expected)) & ")"
          severity warning;
      end if;
    end if;
  end procedure report_error_precision;


  signal start_nrtest, nrtest_done         : BOOLEAN := false;
  signal start_topalgtest, topalgtest_done : BOOLEAN := false;
  signal start_trigtest, trigtest_done     : BOOLEAN := false;
  signal start_errortest, errortest_done   : BOOLEAN := false;
  signal start_htest, htest_done           : BOOLEAN := false;
  signal start_ftest, ftest_done           : BOOLEAN := false;

begin
  -- purpose: Main tester process
  tester : process is
  begin
    if (debug) then
      start_errortest <= true;
      wait until errortest_done;
    end if;
    start_ftest      <= true;
    wait until ftest_done;
    start_nrtest     <= true;
    wait until nrtest_done;
    start_topalgtest <= true;
    wait until topalgtest_done;
    start_trigtest   <= true;
    wait until trigtest_done;
    start_htest      <= true;
    wait until htest_done;
--    start_complextest <= true;
--    wait until complextest_done;
    report "Fixed point Algorithmic funciton testing completed." severity note;
  end process tester;

  -- Floor ceil and precision test.
  ftest : process is
    variable check16uf, check16uf1, check16uf2 : ufixed (7 downto -8);
    variable checkx1, checkx2                  : ufixed (5 downto -13);
    variable check16sf, check16sf1, check16sf2 : sfixed (7 downto -8);
  begin

    wait until start_ftest;
    check16uf  := to_ufixed (0.0, check16uf'high, check16uf'low);
    check16uf1 := floor (check16uf);
    check16uf2 := to_ufixed (0.0, check16uf2'high, check16uf2'low);
    report_error ("uf floor (0.0)", check16uf1, check16uf2);
    check16uf  := to_ufixed (0.1, check16uf'high, check16uf'low);
    check16uf1 := floor (check16uf);
    check16uf2 := to_ufixed (0.0, check16uf2'high, check16uf2'low);
    report_error ("uf floor (0.1)", check16uf1, check16uf2);
    check16uf  := to_ufixed (0.5, check16uf'high, check16uf'low);
    check16uf1 := floor (check16uf);
    check16uf2 := to_ufixed (0.0, check16uf2'high, check16uf2'low);
    report_error ("uf floor (0.5)", check16uf1, check16uf2);
    check16uf  := to_ufixed (0.7, check16uf'high, check16uf'low);
    check16uf1 := floor (check16uf);
    check16uf2 := to_ufixed (0.0, check16uf2'high, check16uf2'low);
    report_error ("uf floor (0.7)", check16uf1, check16uf2);
    check16uf  := to_ufixed (0.9, check16uf'high, check16uf'low);
    check16uf1 := floor (check16uf);
    check16uf2 := to_ufixed (0.0, check16uf2'high, check16uf2'low);
    report_error ("uf floor (0.9)", check16uf1, check16uf2);
    check16uf  := to_ufixed (1.0, check16uf'high, check16uf'low);
    check16uf1 := floor (check16uf);
    check16uf2 := to_ufixed (1.0, check16uf2'high, check16uf2'low);
    report_error ("uf floor (1.0)", check16uf1, check16uf2);
    check16uf  := to_ufixed (1.1, check16uf'high, check16uf'low);
    check16uf1 := floor (check16uf);
    check16uf2 := to_ufixed (1.0, check16uf2'high, check16uf2'low);
    report_error ("uf floor (1.1)", check16uf1, check16uf2);
    check16uf  := to_ufixed (1.5, check16uf'high, check16uf'low);
    check16uf1 := floor (check16uf);
    check16uf2 := to_ufixed (1.0, check16uf2'high, check16uf2'low);
    report_error ("uf floor (1.5)", check16uf1, check16uf2);
    check16uf  := to_ufixed (1.7, check16uf'high, check16uf'low);
    check16uf1 := floor (check16uf);
    check16uf2 := to_ufixed (1.0, check16uf2'high, check16uf2'low);
    report_error ("uf floor (1.7)", check16uf1, check16uf2);
    check16uf  := to_ufixed (1.9, check16uf'high, check16uf'low);
    check16uf1 := floor (check16uf);
    check16uf2 := to_ufixed (1.0, check16uf2'high, check16uf2'low);
    report_error ("uf floor (1.9)", check16uf1, check16uf2);
    check16uf  := to_ufixed (2.0, check16uf'high, check16uf'low);
    check16uf1 := floor (check16uf);
    check16uf2 := to_ufixed (2.0, check16uf2'high, check16uf2'low);
    report_error ("uf floor (2.0)", check16uf1, check16uf2);
    check16uf  := to_ufixed (2.1, check16uf'high, check16uf'low);
    check16uf1 := floor (check16uf);
    check16uf2 := to_ufixed (2.0, check16uf2'high, check16uf2'low);
    report_error ("uf floor (2.1)", check16uf1, check16uf2);
    check16uf  := to_ufixed (2.5, check16uf'high, check16uf'low);
    check16uf1 := floor (check16uf);
    check16uf2 := to_ufixed (2.0, check16uf2'high, check16uf2'low);
    report_error ("uf floor (2.5)", check16uf1, check16uf2);
    check16uf  := to_ufixed (2.7, check16uf'high, check16uf'low);
    check16uf1 := floor (check16uf);
    check16uf2 := to_ufixed (2.0, check16uf2'high, check16uf2'low);
    report_error ("uf floor (2.7)", check16uf1, check16uf2);
    check16uf  := to_ufixed (2.9, check16uf'high, check16uf'low);
    check16uf1 := floor (check16uf);
    check16uf2 := to_ufixed (2.0, check16uf2'high, check16uf2'low);
    report_error ("uf floor (2.9)", check16uf1, check16uf2);
    -- ceil
    check16uf  := to_ufixed (1.0, check16uf'high, check16uf'low);
    check16uf1 := ceil (check16uf);
    check16uf2 := to_ufixed (1.0, check16uf2'high, check16uf2'low);
    report_error ("uf ceil (1.0)", check16uf1, check16uf2);
    check16uf  := to_ufixed (1.1, check16uf'high, check16uf'low);
    check16uf1 := ceil (check16uf);
    check16uf2 := to_ufixed (2.0, check16uf2'high, check16uf2'low);
    report_error ("uf ceil (1.1)", check16uf1, check16uf2);
    check16uf  := to_ufixed (1.5, check16uf'high, check16uf'low);
    check16uf1 := ceil (check16uf);
    check16uf2 := to_ufixed (2.0, check16uf2'high, check16uf2'low);
    report_error ("uf ceil (1.5)", check16uf1, check16uf2);
    check16uf  := to_ufixed (1.7, check16uf'high, check16uf'low);
    check16uf1 := ceil (check16uf);
    check16uf2 := to_ufixed (2.0, check16uf2'high, check16uf2'low);
    report_error ("uf ceil (1.7)", check16uf1, check16uf2);
    check16uf  := to_ufixed (1.9, check16uf'high, check16uf'low);
    check16uf1 := ceil (check16uf);
    check16uf2 := to_ufixed (2.0, check16uf2'high, check16uf2'low);
    report_error ("uf ceil (1.9)", check16uf1, check16uf2);
    -- precision
    check16uf  := "1010101010101010";
    check16uf1 := precision (check16uf, 6);
    check16uf2 := "1010101010101000";   -- 10101010.10101000
    report_error ("precision (6)", check16uf1, check16uf2);
    check16uf  := "1010101010101010";
    check16uf1 := precision (check16uf, 5);
    check16uf2 := "1010101010101000";
    report_error ("precision (5)", check16uf1, check16uf2);
    check16uf  := "1010101010101010";
    check16uf1 := precision (check16uf, 4);
    check16uf2 := "1010101010110000";
    report_error ("precision (4)", check16uf1, check16uf2);


    -- sfixed
    check16sf  := to_sfixed (1.0, check16sf'high, check16sf'low);
    check16sf1 := floor (check16sf);
    check16sf2 := to_sfixed (1.0, check16sf2'high, check16sf2'low);
    report_error ("floor (1.0)", check16sf1, check16sf2);
    check16sf  := to_sfixed (1.1, check16sf'high, check16sf'low);
    check16sf1 := floor (check16sf);
    check16sf2 := to_sfixed (1.0, check16sf2'high, check16sf2'low);
    report_error ("floor (1.1)", check16sf1, check16sf2);
    check16sf  := to_sfixed (1.5, check16sf'high, check16sf'low);
    check16sf1 := floor (check16sf);
    check16sf2 := to_sfixed (1.0, check16sf2'high, check16sf2'low);
    report_error ("floor (1.5)", check16sf1, check16sf2);
    check16sf  := to_sfixed (1.7, check16sf'high, check16sf'low);
    check16sf1 := floor (check16sf);
    check16sf2 := to_sfixed (1.0, check16sf2'high, check16sf2'low);
    report_error ("floor (1.7)", check16sf1, check16sf2);
    check16sf  := to_sfixed (1.9, check16sf'high, check16sf'low);
    check16sf1 := floor (check16sf);
    check16sf2 := to_sfixed (1.0, check16sf2'high, check16sf2'low);
    report_error ("floor (1.9)", check16sf1, check16sf2);
    check16sf  := to_sfixed (-1.0, check16sf'high, check16sf'low);
    check16sf1 := floor (check16sf);
    check16sf2 := to_sfixed (-1.0, check16sf2'high, check16sf2'low);
    report_error ("floor (-1.0)", check16sf1, check16sf2);
    check16sf  := to_sfixed (-1.1, check16sf'high, check16sf'low);
    check16sf1 := floor (check16sf);
    check16sf2 := to_sfixed (-2.0, check16sf2'high, check16sf2'low);
    report_error ("floor (-1.1)", check16sf1, check16sf2);
    check16sf  := to_sfixed (-1.9, check16sf'high, check16sf'low);
    check16sf1 := floor (check16sf);
    check16sf2 := to_sfixed (-2.0, check16sf2'high, check16sf2'low);
    report_error ("floor (-1.9)", check16sf1, check16sf2);
    -- ceil
    check16sf  := to_sfixed (1.0, check16sf'high, check16sf'low);
    check16sf1 := ceil (check16sf);
    check16sf2 := to_sfixed (1.0, check16sf2'high, check16sf2'low);
    report_error ("ceil (1.0)", check16sf1, check16sf2);
    check16sf  := to_sfixed (1.1, check16sf'high, check16sf'low);
    check16sf1 := ceil (check16sf);
    check16sf2 := to_sfixed (2.0, check16sf2'high, check16sf2'low);
    report_error ("ceil (1.1)", check16sf1, check16sf2);
    check16sf  := to_sfixed (1.5, check16sf'high, check16sf'low);
    check16sf1 := ceil (check16sf);
    check16sf2 := to_sfixed (2.0, check16sf2'high, check16sf2'low);
    report_error ("ceil (1.5)", check16sf1, check16sf2);
    check16sf  := to_sfixed (1.7, check16sf'high, check16sf'low);
    check16sf1 := ceil (check16sf);
    check16sf2 := to_sfixed (2.0, check16sf2'high, check16sf2'low);
    report_error ("ceil (1.7)", check16sf1, check16sf2);
    check16sf  := to_sfixed (1.9, check16sf'high, check16sf'low);
    check16sf1 := ceil (check16sf);
    check16sf2 := to_sfixed (2.0, check16sf2'high, check16sf2'low);
    report_error ("ceil (1.9)", check16sf1, check16sf2);
    check16sf  := to_sfixed (-2.0, check16sf'high, check16sf'low);
    check16sf1 := ceil (check16sf);
    check16sf2 := to_sfixed (-2.0, check16sf2'high, check16sf2'low);
    report_error ("ceil (-2.0)", check16sf1, check16sf2);
    check16sf  := to_sfixed (-2.1, check16sf'high, check16sf'low);
    check16sf1 := ceil (check16sf);
    check16sf2 := to_sfixed (-2.0, check16sf2'high, check16sf2'low);
    report_error ("ceil (-2.1)", check16sf1, check16sf2);
    check16sf  := to_sfixed (-2.5, check16sf'high, check16sf'low);
    check16sf1 := ceil (check16sf);
    check16sf2 := to_sfixed (-2.0, check16sf2'high, check16sf2'low);
    report_error ("ceil (-2.5)", check16sf1, check16sf2);
    check16sf  := to_sfixed (-2.7, check16sf'high, check16sf'low);
    check16sf1 := ceil (check16sf);
    check16sf2 := to_sfixed (-2.0, check16sf2'high, check16sf2'low);
    report_error ("ceil (-2.7)", check16sf1, check16sf2);
    check16sf  := to_sfixed (-2.9, check16sf'high, check16sf'low);
    check16sf1 := ceil (check16sf);
    check16sf2 := to_sfixed (-2.0, check16sf2'high, check16sf2'low);
    report_error ("ceil (-2.9)", check16sf1, check16sf2);
    -- precision
    check16sf  := "0010101010101010";
    check16sf1 := precision (check16sf, 6);
    check16sf2 := "0010101010101000";   -- 10101010.10101000
    report_error ("precision (6)", check16sf1, check16sf2);
    check16sf  := "0010101010101010";
    check16sf1 := precision (check16sf, 5);
    check16sf2 := "0010101010101000";
    report_error ("precision (5)", check16sf1, check16sf2);
    check16sf  := "0010101010101010";
    check16sf1 := precision (check16sf, 4);
    check16sf2 := "0010101010110000";
    report_error ("precision (4)", check16sf1, check16sf2);

    check16sf  := "1010101010101010";
    check16sf1 := precision (check16sf, 6);
    check16sf2 := "1010101010101000";   -- 10101010.10101000
    report_error ("precision (6)", check16sf1, check16sf2);
    check16sf  := "1010101010101010";
    check16sf1 := precision (check16sf, 5);
    check16sf2 := "1010101010101000";
    report_error ("precision (5)", check16sf1, check16sf2);
    check16sf  := "1010101010101010";
    check16sf1 := precision (check16sf, 4);
    check16sf2 := "1010101010110000";
    report_error ("precision (4)", check16sf1, check16sf2);

    assert (quiet)
      report "Floor, Ceil, and precision test completed"
      severity note;
    ftest_done <= true;
    wait;

  end process ftest;


  -- purpose: Newtown Raphson reciprocal and divide test
  -- type   : combinational
  -- inputs : 
  -- outputs: 
  nrtest : process is
    variable divres, divrest      : ufixed (6 downto -7);  -- ufixed7_3/ufixed7_3
    variable check7uf1, check7uf2 : ufixed (3 downto -3);
    variable rdivres              : ufixed (3 downto -4);  -- 1/ufixed7_3
    variable divres2              : ufixed (10 downto -12);  -- ufixed16_8/ufixed7_3
    variable divres2x, divres2xt  : ufixed (11 downto -11);  -- ufixed7_3/ufixed16_8
    variable divres3              : ufixed (15 downto -16);  -- ufixed16_8/ufixed16_8
    variable rdivres3             : ufixed (8 downto -8);  -- 1/ufixed16_8
    variable check7sf1, check7sf2 : sfixed (3 downto -3);
    variable sdivres, sdivrest    : sfixed (7 downto -6);  -- sfixed7_3/sfixed7_3
    variable rsdivres             : sfixed (4 downto -3);  -- 1/sfixed7_3
    variable smodres3             : sfixed (3 downto -8);  -- sfixed7_3 rem sfixed16_8
    variable sdivres2             : sfixed (11 downto -11);  -- sfixed16_8/sfixed7_3
    variable sdivres2x            : sfixed (12 downto -10);  -- sfixed7_3/sfixed16_8
    variable sdivres3             : sfixed (16 downto -15);  -- sfixed16_8/sfixed16_8
    variable rsdivres3            : sfixed (9 downto -7);  -- 1/sfixed16_8

    variable check16uf, check16uf1, check16uf2 : ufixed (7 downto -8);
    variable checkx1, checkx2                  : ufixed (5 downto -13);
    variable check16sf, check16sf1, check16sf2 : sfixed (7 downto -8);
  begin
    wait until start_nrtest;
    -- 1 over X test cases
    check7uf1  := "0010000";            -- 2.0
    rdivres    := nr_reciprocal (check7uf1);
    check7uf2  := "0000100";            -- 0.5
    report_error ("1/2 1/x miscompare", rdivres, check7uf2);
    check16uf1 := "0000001100000000";   -- 3
    rdivres3   := nr_reciprocal (check16uf1);
    report_error ("1/3 1/x miscompare", rdivres3,
                  to_ufixed (1.0/3.0, rdivres3'high, rdivres3'low));
    check7uf1  := "0000100";            -- 0.5
    rdivres    := nr_reciprocal (check7uf1);
    check7uf2  := "0010000";            -- 2.0
    report_error ("1/0.5 1/x miscompare", rdivres, check7uf2);
    -- boundary test
    check7uf1  := "0000001";            -- 0.125
    rdivres    := nr_reciprocal (check7uf1);
    divrest    := "00010000000000";
    report_error ("1/0.125", rdivres, divrest);
    check7uf1  := "1111111";            -- 15.875
    rdivres    := nr_reciprocal (check7uf1);
    divrest    := "00000000001000";     -- 0.0625
    report_error ("1/15.875", rdivres, divrest);
    check16uf1 := to_ufixed (6, check16uf1'high, check16uf1'low);
    rdivres3   := nr_reciprocal (check16uf1);
    report_error ("1/6 1/x miscompare", rdivres3,
                  to_ufixed (1.0/6.0, rdivres3'high, rdivres3'low));
    check16uf1 := to_ufixed (20, check16uf1'high, check16uf1'low);
    rdivres3   := nr_reciprocal (check16uf1);
    report_error ("1/20 1/x miscompare", rdivres3,
                  to_ufixed (1.0/20.0, rdivres3'high, rdivres3'low));
    check16uf1 := to_ufixed (42, check16uf1'high, check16uf1'low);
    rdivres3   := nr_reciprocal (check16uf1);
    report_error ("1/42 1/x miscompare", rdivres3,
                  to_ufixed (1.0/42.0, rdivres3'high, rdivres3'low));
    checkx1 := to_ufixed (6*7, checkx1'high, checkx1'low);
    checkx1 := resize (nr_reciprocal(checkx1),
                       checkx1'high, checkx1'low);
    checkx2 := resize (to_ufixed (1.0/42.0, -checkx1'low, -checkx1'high-1),
                       checkx2);
    report_error ("1/42 1/x mant miscompage", checkx1, checkx2);
    checkx1 := to_ufixed (1.0/42.0, checkx1'high, checkx1'low);
    checkx1 := resize (nr_reciprocal(checkx1), checkx1'high, checkx1'low);

    checkx1 (-5 downto checkx1'low) := (others => '0');  -- toss the lower bits

    checkx2    := to_ufixed (42, checkx2'high, checkx2'low);
    report_error ("42 1/x mant miscompare", checkx1, checkx2);
    check16uf1 := "1000000000000000";   -- 128
    rdivres3   := nr_reciprocal (check16uf1);
    report_error ("1/128 1/x miscompare", rdivres3,
                  to_ufixed (1.0/128.0, divres3'high, divres3'low));

    check16uf1 := "0011111100000000";   -- 63
    rdivres3   := nr_reciprocal (check16uf1);
    report_error ("1/63 1/x miscompare", rdivres3,
                  to_ufixed (1.0/to_real(check16uf1), rdivres3));
    check16uf1 := "0000000111111000";   -- 0.9375
    rdivres3   := nr_reciprocal (check16uf1);
    report_error ("1/0.9375 1/x miscompare", rdivres3,
                  to_ufixed (1.0/to_real(check16uf1), rdivres3));
    check16uf := "0000000001111110";    -- 0.05859+
    rdivres3  := nr_reciprocal (check16uf);
    report_error ("1/" & to_string(check16uf) & " = (" &
                  REAL'image(to_real(check16uf)) & ")", rdivres3,
                  to_ufixed (1.0/to_real(check16uf), rdivres3));
    check16uf1 := "0000011111100000";   -- 3.75+
    rdivres3   := nr_reciprocal (check16uf1);
    report_error ("1/3.75 1/x miscompare", rdivres3,
                  to_ufixed (1.0/to_real(check16uf1), rdivres3));
    -- Enough!  Lets do this exhaustively.
    if (debug) then
--      check16uf2 := "0000000000000001";
--      check16uf1 := "1111111111111111";
--      check16uf := check16uf2;
--      while (check16uf /= check16uf1) loop
--        rdivres3   := nr_reciprocal (check16uf);
--        report_error ("1/" & to_string(check16uf) & " = (" &
--                      real'image(to_real(check16uf)) & ")", rdivres3,
--                      to_ufixed (1.0/to_real(check16uf), rdivres3));
--        check16uf := resize (check16uf + check16uf2, check16uf);
--      end loop;
      check7uf1 := "0000001";
      check7uf2 := "1111111";           -- max
      while (check7uf1 /= check7uf2) loop
        rdivres := nr_reciprocal (check7uf1);
        report_error ("1/" & to_string(check7uf1) & " = (" &
                      REAL'image(to_real(check7uf1)) & ")", rdivres,
                      to_ufixed (1.0/to_real(check7uf1), rdivres));
        check7uf1 := resize (check7uf1 + 0.125, check7uf1);
      end loop;
    end if;
    -- divide test
    check7uf2  := "0110100";            -- 6.5
    check7uf1  := "0010000";            -- 2.0
    divres     := nr_divide (check7uf2, check7uf1);
    check7uf2  := "0011010";
    report_error ("6.5 / 2.0 miscompare", divres, resize(check7uf2, divres));
    check16uf1 := "0000110100000000";   -- 13
    check7uf1  := "0010000";            -- 2.0
    divres2    := nr_divide (check16uf1, check7uf1);
    check16uf1 := "0000011010000000";   -- 6.5
    report_error ("long 13.0 / 2.0 miscompare",
                  divres2, resize(check16uf1, divres2));
    check7uf2 := "0110100";             -- 6.5
    divres    := nr_divide (check7uf2, check7uf2);
    check7uf1 := "0001000";
    report_error_bias ("6.5 / 6.5 miscompare",
                       divres, resize (check7uf1, divres));
    check16uf1 := "0000000100000000";   -- 1
    check7uf2  := "0011000";            -- 3
    divres2    := nr_divide (check16uf1, check7uf2);
    divres3    := "00000000000000000101010101100000";  -- 1/3 to divres2 precision
    report_error_bias ("1/3 miscompare", divres2, resize (divres3, divres2));
    check16uf1 := "0000001100000000";   -- 3
    assert (check16uf1 = 3) report "it's not 3" severity error;
    check7uf2  := "0001000";            -- 1
    assert (check7uf2 = 1) report "It's not 1" severity error;
    divres2x   := nr_divide (check7uf2, check16uf1);
--    divres3 := resize(to_ufixed(1.0/3.0, divres2x'high, divres2x'low),
--                      divres3'high, divres3'low);
    divres2xt  := "00000000000001010101011";  -- 1/3+ to divres2 precision
    report_error_bias ("1/3+ miscompare", divres2x,
                       resize (divres2x, divres2xt));
    check7uf2 := "1000000";             -- 8
    check7uf1 := "0000001";             -- 0.125
    divres    := nr_divide (check7uf2, check7uf1);
    report_error ("8/0.125 miscompare", divres,
                  to_ufixed(8.0/0.125, divres2'high, divres2'low));
    check7uf2 := "1111111";             -- 15.875
    check7uf1 := "0000001";             -- 0.125
    divres    := nr_divide (check7uf2, check7uf1);
    report_error ("15.875/0.125 miscompare", divres,
                  to_ufixed(15.875/0.125, divres2'high, divres2'low));
    check7uf2 := "1000000";             -- 8
    check7uf1 := "0000001";             -- 0.125
    divres    := nr_divide (check7uf1, check7uf2);
    report_error ("0.125/8 miscompare", divres,
                  to_ufixed(0.125/8.0, divres2'high, divres2'low));
    -- Boundary test
    check7uf2 := "1111111";             -- 15.875
    check7uf1 := "0000001";             -- 0.125
    divres    := nr_divide (check7uf1, check7uf2);
    divrest   := "00000000000001";      -- .0078125
    report_error ("0.125/15.875 miscompare", divres,
                  divrest);
    divrest := nr_divide (check7uf1, check7uf2);
    report_error ("divide (0.125,15.875) miscompare", divres,
                  divrest);
    divres  := nr_divide (check7uf2, check7uf1);
    divrest := "11111110000000";        -- 127
    report_error ("15.875/0.125 miscompare", divres,
                  resize (divrest, divres));
    divrest := nr_divide (check7uf2, check7uf1);
    report_error ("divide (15.875,0.125) miscompare", divres,
                  divrest);
    -- signed
    check7sf1 := "0011000";             -- 3.0
    rsdivres  := nr_reciprocal (check7sf1);
    report_error ("reciprocal 3", rsdivres,
                  to_sfixed (1.0/3.0, rsdivres'high, rsdivres'low));
    check7sf1 := "1101000";             -- -3.0
    rsdivres  := nr_reciprocal (check7sf1);
    report_error ("reciprocal -3", rsdivres,
                  to_sfixed (-1.0/3.0, rsdivres'high, rsdivres'low));
    check7sf1 := "0011000";             -- 3.0
    rsdivres := nr_reciprocal (arg         => check7sf1,
                               guard_bits  => fixed_guard_bits,      -- default
                               round_style => fixed_truncate);  -- do not round
    report_error ("reciprocal test, no round", rsdivres,
                  to_sfixed (arg            => 1.0/3.0,
                             left_index     => rsdivres'high,
                             right_index    => rsdivres'low,
                             round_style    => fixed_truncate,  -- do not round
                             overflow_style => fixed_saturate));
    rsdivres := nr_reciprocal (arg         => check7sf1,
                               guard_bits  => 0,       -- no guard bits
                               round_style => fixed_round);
    report_error ("reciprocal test, no guard", rsdivres,
                  to_sfixed (arg            => 1.0/3.0,
                             left_index     => rsdivres'high,
                             right_index    => rsdivres'low,
                             round_style    => fixed_truncate,  -- do not round
                             overflow_style => fixed_saturate));
    check7sf1 := "0111111";             -- 7.785
    rsdivres  := nr_reciprocal (check7sf1);
    report_error ("sfixed 1/" & to_string(check7sf1), rsdivres,
                  to_sfixed (STD_LOGIC_VECTOR'("00000001"), 4, -3));
    check7sf1 := "0000001";             -- 0.125
    rsdivres  := nr_reciprocal (check7sf1);
    report_error ("sfixed 1/" & to_string(check7sf1), rsdivres,
                  to_sfixed (8, 5, -3));
    check7sf1 := "1000000";             -- -8
    rsdivres  := nr_reciprocal (check7sf1);
    report_error ("sfixed 1/" & to_string(check7sf1), rsdivres,
                  to_sfixed (-(1.0/8.0), 5, -8));
    check7sf1 := "1111111";             -- -0.125
    rsdivres  := nr_reciprocal (check7sf1);
    report_error ("sfixed 1/" & to_string(check7sf1), rsdivres,
                  to_sfixed (-8, 6, -3));
    check7sf2 := "0001000";             -- 1.0
    check7sf1 := "0011000";             -- 3.0
    sdivres   := nr_divide (check7sf2, check7sf1);
    report_error_bias ("signed divide test", sdivres,
                       to_sfixed (1.0/3.0, sdivres'high, sdivres'low));
    sdivres := nr_divide (l           => check7sf2,
                          r           => check7sf1,
                          guard_bits  => fixed_guard_bits,      -- default
                          round_style => fixed_truncate);       -- do not round
    report_error ("signed divide test, no round", sdivres,
                  to_sfixed (arg            => 1.0/3.0,
                             left_index     => sdivres'high,
                             right_index    => sdivres'low,
                             round_style    => fixed_truncate,  -- do not round
                             overflow_style => fixed_saturate));
    sdivres := nr_divide (l           => check7sf2,
                          r           => check7sf1,
                          guard_bits  => 0,   -- no guard bits
                          round_style => fixed_round);
    report_error_bias ("signed divide test, no guard", sdivres,
                       to_sfixed (arg            => 1.0/3.0,
                                  left_index     => sdivres'high,
                                  right_index    => sdivres'low,
                                  round_style    => fixed_truncate,  -- do not round
                                  overflow_style => fixed_saturate));

    check7sf2  := "0110100";                  -- 6.5
    check7sf1  := "0010000";                  -- 2.0
    sdivres    := nr_divide (check7sf2, check7sf1);
    check7sf1  := "0011010";
    report_error ("signed 6.5 / 2.0 miscompare", sdivres, check7sf1);
    check16sf1 := "0000110100000000";         -- 13
    check7sf1  := "0010000";                  -- 2.0
    sdivres2   := nr_divide (check16sf1, check7sf1);
    check16sf1 := "0000011010000000";         -- 6.5
    report_error ("long signed 6.5 / 2.0 miscompare", sdivres2, check16sf1);
    check7sf2  := "0110100";                  -- 6.5
    sdivres    := nr_divide (check7sf2, check7sf2);
    check7sf1  := "0001000";
    report_error_bias ("signed 6.5 / 6.5 miscompare", sdivres, check7sf1);
    sdivres2   := "00000000000001010101011";  -- ~1/3
    sdivres3   := resize (sdivres2, sdivres3'high, sdivres3'low);
    check16sf1 := "0000000100000000";         -- 1
    check7sf2  := "0011000";                  -- 3
    sdivres2   := nr_divide (check16sf1, check7sf2);
    report_error_bias ("signed 1/3 miscompare", sdivres2,
                       resize (sdivres3, sdivres2));
    check16sf1 := "0000001100000000";         -- 3
    check7sf2  := "0001000";                  -- 1
    sdivres2x  := nr_divide (check7sf2, check16sf1);
    sdivres3 := resize(to_sfixed(1.0/3.0, sdivres2x'high, sdivres2x'low),
                       sdivres3'high, sdivres3'low);
    report_error_bias ("1/3+ miscompare", sdivres2x,
                       resize(sdivres3, sdivres2x));
    check7sf2 := "0100000";                   -- 4
    check7sf1 := "0000001";                   -- 0.125
    sdivres   := nr_divide (check7sf2, check7sf1);
    report_error ("4/0.125 miscompare", sdivres,
                  to_sfixed(4.0/0.125, sdivres2'high, sdivres2'low));
    sdivres := nr_divide (check7sf2, check7sf1);
    report_error ("divide (4,0.125) miscompare", sdivres,
                  to_sfixed(4.0/0.125, sdivres2'high, sdivres2'low));
    check7sf2 := "0111111";                   -- 7.875
    check7sf1 := "0000001";                   -- 0.125
    sdivres   := nr_divide (check7sf2, check7sf1);
    report_error ("7.875/0.125 miscompare", sdivres,
                  to_sfixed(7.875/0.125, sdivres2'high, sdivres2'low));
    check7sf2 := "0100000";                   -- 4
    check7sf1 := "0000001";                   -- 0.125
    sdivres   := nr_divide (check7sf1, check7sf2);
    report_error ("0.125/4 miscompare", sdivres,
                  to_sfixed(0.125/4.0, sdivres2'high, sdivres2'low));
    check7sf2 := "0111111";                   -- 7.875
    check7sf1 := "0000001";                   -- 0.125
    sdivres   := nr_divide (check7sf1, check7sf2);
    report_error ("0.125/7.875 miscompare", sdivres,
                  to_sfixed(0.125/7.875, sdivres2'high, sdivres2'low));
    check7sf1  := "0010000";                  -- 2.0
    rsdivres   := nr_reciprocal (check7sf1);
    check7sf2  := "0000100";                  -- 0.5
    report_error ("signed 1/2 signed 1/x miscompare", rsdivres, check7sf2);
    check16sf1 := "0000001100000000";         -- 3
    rsdivres3  := nr_reciprocal (check16sf1);
    report_error ("signed 1/3 1/x miscompare", rsdivres3,
                  to_sfixed (1.0/3.0, rsdivres3'high, rsdivres3'low));
    check7sf1  := "0000100";                  -- 0.5
    rsdivres   := nr_reciprocal (check7sf1);
    check7sf2  := "0010000";                  -- 2.0
    report_error ("signed 1/0.5 1/x miscompare", rsdivres, check7sf2);
    check16sf1 := "0100000100000000";         -- 65
    rsdivres3  := nr_reciprocal (check16sf1);
    report_error ("signed 1/65 1/x miscompare", rsdivres3,
                  to_sfixed (1.0/65.0, rsdivres3'high, rsdivres3'low));
    check16sf1 := to_sfixed (1, check16sf1'high, check16sf1'low);
    check16sf2 := "0100000100000000";         -- 65
    sdivres3   := nr_divide (check16sf1, check16sf2);
    report_error ("signed 1/65 miscompare", sdivres3,
                  to_sfixed (1.0/65.0, sdivres3'high, sdivres3'low));
    sdivres3 := nr_divide (check16sf1, check16sf2);
    report_error ("signed divide (1,65) miscompare", sdivres3,
                  to_sfixed (1.0/65.0, sdivres3'high, sdivres3'low));
    -- boundary test, positive only
    check7sf1 := "0111111";                   -- 7.875
    check7sf2 := "0000001";                   -- 0.125
    sdivres   := nr_divide (check7sf1, check7sf2);
    sdivrest  := "00111111000000";            -- 63
    report_error ("7.875/0.125", sdivres, sdivrest);
    sdivres   := nr_divide (check7sf2, check7sf1);
    sdivrest  := "00000000000001";            -- 0.015875
    report_error ("0.125/7.875", sdivres, sdivrest);
    sdivres   := nr_divide (check7sf2, check7sf1, fixed_round, 0);
    report_error_bias ("divide(0.125,7.875, true, 0)", sdivres, sdivrest);

    assert (quiet)
      report "Newton Raphson reciprocal and divide test completed"
      severity note;
    nrtest_done <= true;
  end process nrtest;

  -- purpose: Check the error routines
  errortest : process is
    variable sf1, sf2 : sfixed (1 downto -2);
    variable uf1, uf2 : ufixed (1 downto -2);
  begin
    wait until start_errortest;
    sf1            := "0101";
    sf2            := "0101";
    report "Should not see an error, actual = expected" severity note;
    report_error ("actual = expected", sf1, sf2);
    sf1            := "0110";
    report "Should not see an error, actual = expected+1" severity note;
    report_error ("actual = expected+1", sf1, sf2);
    sf1            := "0100";
    report "Should not see an error, actual = expected-1" severity note;
    report_error ("actual = expected-1", sf1, sf2);
    sf1            := "0111";
    report "Should see an error, actual = expected+2" severity note;
    report_error ("actual = expected+2", sf1, sf2);
    sf1            := "0011";
    report "Should see an error, actual = expected-2" severity note;
    report_error ("actual = expected-2", sf1, sf2);
    sf1            := "1111";
    report "Should see an error, actual /= expected" severity note;
    report_error ("actual /= expected", sf1, sf2);
    uf1            := "0101";
    uf2            := "0101";
    report "ufixed Should not see an error, actual = expected" severity note;
    report_error ("ufixed actual = expected", uf1, uf2);
    uf1            := "0110";
    report "ufixed Should not see an error, actual = expected+1" severity note;
    report_error ("ufixed actual = expected+1", uf1, uf2);
    uf1            := "0100";
    report "ufixed Should not see an error, actual = expected-1" severity note;
    report_error ("ufixed actual = expected-1", uf1, uf2);
    uf1            := "0111";
    report "ufixed Should see an error, actual = expected+2" severity note;
    report_error ("ufixed actual = expected+2", uf1, uf2);
    uf1            := "0011";
    report "ufixed Should see an error, actual = expected-2" severity note;
    report_error ("ufixed actual = expected-2", uf1, uf2);
    uf1            := "1111";
    report "ufixed Should see an error, actual /= expected" severity note;
    report_error ("ufixed actual /= expected", uf1, uf2);
    report "Error processing testing completed" severity note;
    errortest_done <= true;
  end process errortest;

  -- purpose: Top algorithm test (Log, Exp, Sqrt, etc)
  topalgtest : process is
    variable sf1, sf2, sf3, sf4 : sfixed (4 downto -15);  -- signed fixed
    variable uf1, uf2, uf3, uf4 : ufixed (3 downto -15);  -- unsigned fixed
    variable checkreal          : REAL;
    variable checkint           : INTEGER;
  begin
    wait until start_topalgtest;
    -- sqrt(sfixed)
    checkint  := 4;
    sf1       := to_sfixed (checkint, sf1);
    sf2       := sqrt (sf1);
    sf3       := to_sfixed (2, sf3);
    report_error ("sqrt(4)", sf2, sf3);
    checkint  := 2;
    sf1       := to_sfixed (checkint, sf1);
    sf2       := sqrt (sf1);
    sf3       := to_sfixed (MATH_SQRT_2, sf3);
    report_error ("sqrt(2)", sf2, sf3);
    checkreal := 0.5;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := sqrt (sf1);
    sf3       := to_sfixed (sqrt(checkreal), sf3);
    report_error ("sqrt(0.5)", sf2, sf3);
    checkint  := 0;
    sf1       := to_sfixed (checkint, sf1);
    sf2       := sqrt (sf1);
    sf3       := to_sfixed (0, sf3);
    report_error ("sqrt(0)", sf2, sf3);
    if (not quiet) then
      report "Expect a sqrt(negative) error here." severity note;
      checkint := -2;
      sf1      := to_sfixed (checkint, sf1);
      sf2      := sqrt (sf1);
      sf3      := to_sfixed (0, sf3);
      report_error ("sqrt(neg)", sf2, sf3);
    end if;
    -- sqrt(sfixed)
    checkint  := 4;
    uf1       := to_ufixed (checkint, uf1);
    uf2       := sqrt (uf1);
    uf3       := to_ufixed (2, uf3);
    report_error ("ufixed sqrt(4)", uf2, uf3);
    checkint  := 2;
    uf1       := to_ufixed (checkint, uf1);
    uf2       := sqrt (uf1);
    uf3       := to_ufixed (MATH_SQRT_2, uf3);
    report_error ("ufixed sqrt(2)", uf2, uf3);
    checkreal := 0.5;
    uf1       := to_ufixed (checkreal, uf1);
    uf2       := sqrt (uf1);
    uf3       := to_ufixed (sqrt(checkreal), uf3);
    report_error ("ufixed sqrt(0.5)", uf2, uf3);
    checkint  := 0;
    uf1       := to_ufixed (checkint, uf1);
    uf2       := sqrt (uf1);
    uf3       := to_ufixed (0, uf3);
    report_error ("ufixed sqrt(2)", uf2, uf3);
    -- inverse sqrt
    checkint  := 2;
    uf1       := to_ufixed (checkint, uf1);
    uf2       := inverse_sqrt (uf1);
    uf3       := to_ufixed (MATH_1_OVER_SQRT_2, uf3);
    report_error ("ufixed (1/sqrt(2))", uf2, uf3);
    checkint  := 4;
    uf1       := to_ufixed (checkint, uf1);
    uf2       := inverse_sqrt (uf1);
    uf3       := to_ufixed (0.5, uf3);
    report_error ("ufixed (1/sqrt(4))", uf2, uf3);
    checkreal := 0.5;
    uf1       := to_ufixed (checkreal, uf1);
    uf2       := inverse_sqrt (uf1);
    uf3       := to_ufixed (1.0/sqrt(checkreal), uf3);
    report_error ("ufixed (1/sqrt(0.5))", uf2, uf3);
    checkreal := 0.33;
    uf1       := to_ufixed (checkreal, uf1);
    uf2       := inverse_sqrt (uf1);
    uf3       := to_ufixed (1.0/sqrt(to_real(uf1)), uf3);
    report_error ("ufixed (1/sqrt(0.33))", uf2, uf3);
    checkreal := 0.01;
    uf1       := to_ufixed (checkreal, uf1);
    uf2       := inverse_sqrt (uf1);
    uf3       := to_ufixed (1.0/sqrt(to_real(uf1)), uf3);
    report_error ("ufixed (1/sqrt(0.01))", uf2, uf3);
    checkreal := 0.05;
    uf1       := to_ufixed (checkreal, uf1);
    uf2       := inverse_sqrt (uf1);
    uf3       := to_ufixed (1.0/sqrt(to_real(uf1)), uf3);
    report_error ("ufixed (1/sqrt(0.05))", uf2, uf3);
    checkreal := 6.0;
    uf1       := to_ufixed (checkreal, uf1);
    uf2       := inverse_sqrt (uf1);
    uf3       := to_ufixed (1.0/sqrt(checkreal), uf3);
    report_error ("ufixed (1/sqrt(6))", uf2, uf3);
    -- inverse sqrt(sfixed)
    checkint  := 2;
    sf1       := to_sfixed (checkint, sf1);
    sf2       := inverse_sqrt (sf1);
    sf3       := to_sfixed (MATH_1_OVER_SQRT_2, sf3);
    report_error ("sfixed (1/sqrt(2))", sf2, sf3);
    checkint  := 4;
    sf1       := to_sfixed (checkint, sf1);
    sf2       := inverse_sqrt (sf1);
    sf3       := to_sfixed (0.5, sf3);
    report_error ("sfixed (1/sqrt(4))", sf2, sf3);
    checkreal := 0.5;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := inverse_sqrt (sf1);
    sf3       := to_sfixed (1.0/sqrt(checkreal), sf3);
    report_error ("sfixed (1/sqrt(0.5))", sf2, sf3);
    checkreal := 0.33;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := inverse_sqrt (sf1);
    sf3       := to_sfixed (1.0/sqrt(to_real(sf1)), sf3);
    report_error ("sfixed (1/sqrt(0.33))", sf2, sf3);
    checkreal := 0.01;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := inverse_sqrt (sf1);
    sf3       := to_sfixed (1.0/sqrt(to_real(sf1)), sf3);
    report_error ("sfixed (1/sqrt(0.01))", sf2, sf3);
    checkreal := 0.05;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := inverse_sqrt (sf1);
    sf3       := to_sfixed (1.0/sqrt(to_real(sf1)), sf3);
    report_error ("sfixed (1/sqrt(0.05))", sf2, sf3);
    checkreal := 6.0;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := inverse_sqrt (sf1);
    sf3       := to_sfixed (1.0/sqrt(checkreal), sf3);
    report_error ("sfixed (1/sqrt(6))", sf2, sf3);
    -- cbrt(sfixed)
    checkint  := 8;
    sf1       := to_sfixed (checkint, sf1);
    sf2       := cbrt (sf1);
    sf3       := to_sfixed (2, sf3);
    report_error ("cbrt(8)", sf2, sf3);
    checkint  := -8;
    sf1       := to_sfixed (checkint, sf1);
    sf2       := cbrt (sf1);
    sf3       := to_sfixed (-2, sf3);
    report_error ("cbrt(-8)", sf2, sf3);
    checkreal := 2.0**(-9);
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := cbrt (sf1);
    sf3       := to_sfixed (2.0**(-3), sf3);
    report_error ("cbrt(2**-9)", sf2, sf3);
    checkreal := 0.5;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := cbrt (sf1);
    sf3       := to_sfixed (cbrt(checkreal), sf3);
    report_error ("cbrt(0.5)", sf2, sf3);
    checkint  := 0;
    sf1       := to_sfixed (checkint, sf1);
    sf2       := cbrt (sf1);
    sf3       := to_sfixed (0, sf3);
    report_error ("cbrt(2)", sf2, sf3);
    -- cbrt(ufixed)
    checkint  := 8;
    uf1       := to_ufixed (checkint, uf1);
    uf2       := cbrt (uf1);
    uf3       := to_ufixed (2, uf3);
    report_error ("cbrt(8)", uf2, uf3);
    checkreal := 2.0**(-9);
    uf1       := to_ufixed (checkreal, uf1);
    uf2       := cbrt (uf1);
    uf3       := to_ufixed (2.0**(-3), uf3);
    report_error ("cbrt(2**-9)", uf2, uf3);
    checkreal := 0.5;
    uf1       := to_ufixed (checkreal, uf1);
    uf2       := cbrt (uf1);
    uf3       := to_ufixed (cbrt(checkreal), uf3);
    report_error ("cbrt(0.5)", uf2, uf3);
    checkint  := 0;
    uf1       := to_ufixed (checkint, uf1);
    uf2       := cbrt (uf1);
    uf3       := to_ufixed (0, uf3);
    report_error ("cbrt(2)", uf2, uf3);
    -- exp(sfixed)
    checkint  := 1;
    sf1       := to_sfixed (checkint, sf1);
    sf2       := exp (sf1);
    sf3       := to_sfixed (MATH_E, sf3);
    report_error_bias ("exp(1)", sf2, sf3);
    checkint  := 0;
    sf1       := to_sfixed (checkint, sf1);
    sf2       := exp (sf1);
    sf3       := to_sfixed (1, sf3);
    report_error ("exp(0)", sf2, sf3);
    checkreal := MATH_E;
    sf1       := to_sfixed (checkreal, sf1);
    sf2 := exp (arg        => sf1,
                iterations => 13);
    sf3       := to_sfixed (exp(to_real(sf1)), sf3);
    report_error ("exp(E)", sf2, sf3);
    checkreal := 2.0;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := exp (sf1);
    sf3       := to_sfixed (exp(checkreal), sf3);
    report_error ("exp(2)", sf2, sf3);
    checkreal := -2.0;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := exp (sf1);
    sf3       := to_sfixed (exp(checkreal), sf3);
    report_error_bias ("exp(-2)", sf2, sf3);
    -- exp(ufixed)
    checkint  := 1;
    uf1       := to_ufixed (checkint, uf1);
    uf2       := exp (uf1);
    uf3       := to_ufixed (MATH_E, uf3);
    report_error_bias ("ufixed exp(1)", uf2, uf3);
    checkint  := 0;
    uf1       := to_ufixed (checkint, uf1);
    uf2       := exp (uf1);
    uf3       := to_ufixed (1, uf3);
    report_error ("ufixed exp(0)", uf2, uf3);
    checkreal := MATH_E;
    uf1       := to_ufixed (checkreal, uf1);
    uf2 := exp (arg        => uf1,
                iterations => 13);
    uf3       := to_ufixed (exp(to_real(uf1)), uf3);
    report_error ("ufixed exp(E)", uf2, uf3);
    checkreal := 2.0;
    uf1       := to_ufixed (checkreal, uf1);
    uf2       := exp (uf1);
    uf3       := to_ufixed (exp(checkreal), uf3);
    report_error ("ufixed exp(2)", uf2, uf3);
    -- ln(sfixed)
    checkreal := math_e;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := ln (sf1);
    sf3       := to_sfixed (log(to_real(sf1)), sf3);
    report_error ("ln(e)", sf2, sf3);
    -- Accuracy issues here, The further we get from "e" the more loops we have
    -- to go through to get an accurate answer.  Default is 4 loops
    checkreal := math_e * math_e;
    sf1       := to_sfixed (checkreal, sf1);
    sf2 := ln (arg        => sf1,
               iterations => 13);
    sf3       := to_sfixed (log(to_real(sf1)), sf3);
    report_error_bias ("ln(e**2)", sf2, sf3);
    checkreal := 15.0;
    sf1       := to_sfixed (checkreal, sf1);
    sf2 := ln (arg        => sf1,
               iterations => 30);
    sf3       := to_sfixed (log(to_real(sf1)), sf3);
    report_error_bias ("ln(15)", sf2, sf3);
    checkreal := 8.0;
    sf1       := to_sfixed (checkreal, sf1);
    sf2 := ln (arg        => sf1,
               iterations => 17);
    sf3       := to_sfixed (log(to_real(sf1)), sf3);
    report_error ("ln(8)", sf2, sf3);
    checkreal := 1.0;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := ln (sf1);
    sf3       := to_sfixed (0, sf3);
    report_error ("ln(1)", sf2, sf3);
    checkreal := math_pi;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := ln (sf1);
    sf3       := to_sfixed (log(to_real(sf1)), sf3);
    report_error ("ln(PI)", sf2, sf3);
    checkreal := MATH_PI_OVER_4;        -- less than 1
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := ln (sf1);
    sf3       := to_sfixed (log(to_real(sf1)), sf3);
    report_error_bias ("ln(PI/4)", sf2, sf3);
    if (not quiet) then
      report "Expect an ln(-1) error and an ln(0) warning here" severity note;
      checkreal := -1.0;
      sf1       := to_sfixed (checkreal, sf1);
      sf2       := ln (sf1);
      sf3       := to_sfixed (0, sf3);  -- error condition, return zero
      report_error ("ln(-1)", sf2, sf3);
      checkreal := 0.0;
      sf1       := to_sfixed (checkreal, sf1);
      sf2       := ln (sf1);
      sf3       := not saturate(sf3);   -- saturate negative
      report_error ("ln(0)", sf2, sf3);
    end if;
    -- ln(ufixed)
    checkreal := math_e;
    uf1       := to_ufixed (checkreal, uf1);
    sf2       := ln (uf1);
    sf3       := to_sfixed (log(checkreal), sf3);
    report_error ("ufixed ln(e)", sf2, sf3);
    checkreal := 1.0;
    uf1       := to_ufixed (checkreal, uf1);
    sf2       := ln (uf1);
    sf3       := to_sfixed (0, sf3);
    report_error ("ufixed ln(1)", sf2, sf3);
    checkreal := math_pi;
    uf1       := to_ufixed (checkreal, uf1);
    sf2       := ln (uf1);
    sf3       := to_sfixed (log(checkreal), sf3);
    report_error_bias ("ufixed ln(PI)", sf2, sf3);
    checkreal := MATH_PI_OVER_4;
    uf1       := to_ufixed (checkreal, uf1);
    sf2       := ln (uf1);
    sf3       := to_sfixed (log(checkreal), sf3);
    report_error_bias ("ufixed ln(PI/4)", sf2, sf3);
    if (not quiet) then
      report "Expect an ln(0) warning here" severity note;
      checkreal := 0.0;
      uf1       := to_ufixed (checkreal, uf1);
      sf2       := ln (uf1);
      sf3       := not saturate (sf3);  -- saturate negative
      report_error ("ufixed ln(0)", sf2, sf3);
    end if;
    -- log(sfixed, positive)
    sf1 := to_sfixed (8, sf1);
    sf3 := log (arg => sf1, base => 2, iterations => 17);
    sf4 := to_sfixed (log(8.0, 2.0), sf4);
    report_error ("Log2(8)", sf3, sf4);
    sf1 := to_sfixed (3, sf1);
    sf3 := log (sf1, 2);
    sf4 := to_sfixed (log(3.0, 2.0), sf4);
    report_error ("Log2(3)", sf3, sf4);
    sf1 := to_sfixed (0.5, sf1);
    sf3 := log (sf1, 2);
    sf4 := to_sfixed (log(0.5, 2.0), sf4);
    report_error ("Log2(0.5)", sf3, sf4);
    sf1 := to_sfixed (0.75, sf1);
    sf3 := log (sf1, 2);
    sf4 := to_sfixed (log(0.75, 2.0), sf4);
    report_error ("Log2(0.75)", sf3, sf4);
    if (not quiet) then
      report "Expect one log(-1) error and 2 log warnings here" severity note;
      sf1 := to_sfixed (-8, sf1);
      sf3 := log (sf1, 2);
      sf4 := to_sfixed (0, sf4);
      report_error ("Log2(-8)", sf3, sf4);
      sf1 := to_sfixed (0, sf1);
      sf3 := log (sf1, 2);
      sf4 := not saturate (sf4);        -- saturate negative
      report_error ("Log2(0)", sf3, sf4);
      sf1 := to_sfixed (8, sf1);
      sf3 := log (sf1, 1);
      sf4 := saturate (sf4);            -- saturate positive
      report_error ("Log1(8)", sf3, sf4);
    end if;
    sf1 := to_sfixed (2, sf1);
    sf3 := log (sf1, 2);
    sf4 := to_sfixed (1, sf4);
    report_error ("Log2(2)", sf3, sf4);
    -- log(sfixed, sfixed)
    sf1 := to_sfixed (8, sf1);
    sf2 := to_sfixed (2, sf2);
    sf3 := log (arg => sf1, base => sf2, iterations => 17);
    sf4 := to_sfixed (log(8.0, 2.0), sf4);
    report_error ("sfixed Log2(8)", sf3, sf4);
    sf1 := to_sfixed (3, sf1);
    sf2 := to_sfixed (2, sf2);
    sf3 := log (sf1, sf2);
    sf4 := to_sfixed (log(3.0, 2.0), sf4);
    report_error ("sfixed Log2(3)", sf3, sf4);
    sf1 := to_sfixed (0.5, sf1);
    sf2 := to_sfixed (2, sf2);
    sf3 := log (sf1, sf2);
    sf4 := to_sfixed (log(0.5, 2.0), sf4);
    report_error ("sfixed Log2(0.5)", sf3, sf4);
    sf1 := to_sfixed (0.75, sf1);
    sf2 := to_sfixed (2, sf2);
    sf3 := log (sf1, sf2);
    sf4 := to_sfixed (log(0.75, 2.0), sf4);
    report_error ("sfixed Log2(0.75)", sf3, sf4);
    if (not quiet) then
      report "Expect two log(-1) error and 3 log warnings here" severity note;
      sf1 := to_sfixed (-8, sf1);
      sf2 := to_sfixed (2, sf2);
      sf3 := log (sf1, sf2);
      sf4 := to_sfixed (0, sf4);
      report_error ("sfixed Log2(-8)", sf3, sf4);
      sf1 := to_sfixed (2, sf1);
      sf2 := to_sfixed (-8, sf2);
      sf3 := log (sf1, sf2);
      sf4 := to_sfixed (0, sf4);
      report_error ("sfixed Log-8(2)", sf3, sf4);
      sf1 := to_sfixed (0, sf1);
      sf2 := to_sfixed (2, sf2);
      sf3 := log (sf1, sf2);
      sf4 := not saturate (sf4);        -- saturate negative
      report_error ("sfixed Log0(2)", sf3, sf4);
      sf1 := to_sfixed (8, sf1);
      sf2 := to_sfixed (1, sf2);
      sf3 := log (sf1, sf2);
      sf4 := saturate (sf4);            -- saturate positive
      report_error ("sfixed Log1(8)", sf3, sf4);
      sf1 := to_sfixed (2, sf1);
      sf2 := to_sfixed (0, sf2);
      sf3 := log (sf1, sf2);
      sf4 := to_sfixed (0, sf4);
      report_error ("sfixed Log2(0)", sf3, sf4);
    end if;
    sf1 := to_sfixed (8, sf1);
    sf2 := to_sfixed (0, sf2);
    sf3 := log (sf1, sf2);
    sf4 := to_sfixed (0, sf4);
    report_error ("sfixed Log0(8)", sf3, sf4);
    sf1 := to_sfixed (2, sf1);
    sf2 := to_sfixed (2, sf2);
    sf3 := log (sf1, sf2);
    sf4 := to_sfixed (1, sf4);
    report_error ("sfixed Log2(2)", sf3, sf4);
    -- log(ufixed, positive)
    uf1 := to_ufixed (8, uf1);
    sf3 := log (arg => uf1, base => 2, iterations => 17);
    sf4 := to_sfixed (log(8.0, 2.0), sf4);
    report_error ("uf Log2(8)", sf3, sf4);
    uf1 := to_ufixed (3, uf1);
    sf3 := log (uf1, 2);
    sf4 := to_sfixed (log(3.0, 2.0), sf4);
    report_error ("uf Log2(3)", sf3, sf4);
    uf1 := to_ufixed (0.5, uf1);
    sf3 := log (uf1, 2);
    sf4 := to_sfixed (log(0.5, 2.0), sf4);
    report_error ("uf Log2(0.5)", sf3, sf4);
    uf1 := to_ufixed (0.75, uf1);
    sf3 := log (uf1, 2);
    sf4 := to_sfixed (log(0.75, 2.0), sf4);
    report_error ("uf Log2(0.75)", sf3, sf4);
    if (not quiet) then
      report "Expect 2 log warnings here" severity note;
      uf1 := to_ufixed (0, uf1);
      sf3 := log (uf1, 2);
      sf4 := not saturate (sf4);        -- saturate negative
      report_error ("uf Log2(0)", sf3, sf4);
      uf1 := to_ufixed (8, uf1);
      sf3 := log (uf1, 1);
      sf4 := saturate (sf4);            -- saturate positive
      report_error ("uf Log1(8)", sf3, sf4);
    end if;
    uf1 := to_ufixed (2, uf1);
    sf3 := log (uf1, 2);
    sf4 := to_sfixed (1, sf4);
    report_error ("uf Log2(2)", sf3, sf4);
    -- log(ufixed, ufixed)
    uf1 := to_ufixed (8, uf1);
    uf2 := to_ufixed (2, uf2);
    sf3 := log (arg => uf1, base => uf2, iterations => 17);
    sf4 := to_sfixed (log(8.0, 2.0), sf4);
    report_error ("ufixed Log2(8)", sf3, sf4);
    uf1 := to_ufixed (3, uf1);
    uf2 := to_ufixed (2, uf2);
    sf3 := log (uf1, uf2);
    sf4 := to_sfixed (log(3.0, 2.0), sf4);
    report_error ("ufixed Log2(3)", sf3, sf4);
    uf1 := to_ufixed (0.5, uf1);
    uf2 := to_ufixed (2, uf2);
    sf3 := log (uf1, uf2);
    sf4 := to_sfixed (log(0.5, 2.0), sf4);
    report_error ("ufixed Log2(0.5)", sf3, sf4);
    uf1 := to_ufixed (0.75, uf1);
    uf2 := to_ufixed (2, uf2);
    sf3 := log (uf1, uf2);
    sf4 := to_sfixed (log(0.75, 2.0), sf4);
    report_error ("ufixed Log2(0.75)", sf3, sf4);
    if (not quiet) then
      report "Expect 2 log warnings here" severity note;
      uf1 := to_ufixed (0, uf1);
      uf2 := to_ufixed (2, uf2);
      sf3 := log (uf1, uf2);
      sf4 := not saturate (sf4);        -- saturate negative
      report_error ("ufixed Log2(0)", sf3, sf4);
      uf1 := to_ufixed (8, uf1);
      uf2 := to_ufixed (1, uf2);
      sf3 := log (uf1, uf2);
      sf4 := saturate (sf4);            -- saturate positive
      report_error ("ufixed Log1(8)", sf3, sf4);
    end if;
    uf1 := to_ufixed (2, uf1);
    uf2 := to_ufixed (0, uf2);
    sf3 := log (uf1, uf2);
    sf4 := to_sfixed (0, sf4);
    report_error ("ufixed Log0(2)", sf3, sf4);
    uf1 := to_ufixed (2, uf1);
    uf2 := to_ufixed (2, uf2);
    sf3 := log (uf1, uf2);
    sf4 := to_sfixed (1, sf4);
    report_error ("ufixed Log2(2)", sf3, sf4);
    -- power_of(sfixed, integer)
    sf1 := to_sfixed (1, sf1);
    sf3 := power_of (sf1, 2);
    sf4 := to_sfixed (1, sf4);
    report_error ("power_of(1, 2)", sf3, sf4);
    sf1 := to_sfixed (2, sf1);
    sf3 := power_of (sf1, 2);
    sf4 := to_sfixed (4, sf4);
    report_error ("power_of(2, 2)", sf3, sf4);
    sf1 := to_sfixed (0.5, sf1);
    sf3 := power_of (sf1, 3);
    sf4 := to_sfixed (0.125, sf4);
    report_error ("power_of(0.5, 3)", sf3, sf4);
    sf1 := to_sfixed (2, sf1);
    sf3 := power_of (sf1, -1);
    sf4 := to_sfixed (0.5, sf4);
    report_error ("power_of(2, -1)", sf3, sf4);
    sf1 := to_sfixed (0, sf1);
    sf3 := power_of (sf1, 8);
    sf4 := to_sfixed (0, sf4);
    report_error ("power_of(0, 8)", sf3, sf4);
    sf1 := to_sfixed (0.725, sf1);
    sf3 := power_of (sf1, 0);
    sf4 := to_sfixed (1, sf4);
    report_error ("power_of(0.725, 0)", sf3, sf4);
    -- power_of(sfixed, sfixed)
    sf1 := to_sfixed (1, sf1);
    sf2 := to_sfixed (2, sf2);
    sf3 := power_of (sf1, sf2);
    sf4 := to_sfixed (1, sf4);
    report_error ("sfixed power_of(1, 2)", sf3, sf4);
    sf1 := to_sfixed (2, sf1);
    sf2 := to_sfixed (2, sf2);
    sf3 := power_of (sf1, sf2);
    sf4 := to_sfixed (4, sf4);
    report_error ("sfixed power_of(2, 2)", sf3, sf4);
    sf1 := to_sfixed (0.5, sf1);
    sf2 := to_sfixed (3, sf2);
    sf3 := power_of (sf1, sf2);
    sf4 := to_sfixed (0.125, sf4);
    report_error ("sfixed power_of(0.5, 3)", sf3, sf4);
    sf1 := to_sfixed (4, sf1);
    sf2 := to_sfixed (0.5, sf2);
    sf3 := power_of (sf1, sf2);
    sf4 := to_sfixed (2, sf4);
    report_error ("sfixed power_of(4, 0.5)", sf3, sf4);
    sf1 := to_sfixed (2, sf1);
    sf2 := to_sfixed (-1, sf2);
    sf3 := power_of (sf1, sf2);
    sf4 := to_sfixed (0.5, sf4);
    report_error ("sfixed power_of(2, -1)", sf3, sf4);
    -- These work with my routine, but errors out with the math_real one.
--    sf1 := to_sfixed (-2, sf1);
--    sf2 := to_sfixed (2, sf2);
--    sf3 := power_of (sf1, sf2);
--    -- Should be +4, but this is consistant with C.
--    sf4 := to_sfixed (-4, sf4);
--    report_error ("sfixed power_of(-2, 2)", sf3, sf4);
--    sf1 := to_sfixed (-2, sf1);
--    sf2 := to_sfixed (-1, sf2);
--    sf3 := power_of (sf1, sf2);
--    sf4 := to_sfixed (-0.5, sf4);
--    report_error ("sfixed power_of(-2, -1)", sf3, sf4);
    -- pattern test
    sf1 := from_string ("00010.101010101010100");
    sf2 := from_string ("00001.000101010101000");
    sf3 := power_of (sf1, sf2);
    sf4 := to_sfixed (to_real(sf1)**to_real(sf2), sf4);
    report_error ("power_of pattern test", sf3, sf4);
    sf2 := from_string ("00010.101010101010100");
    sf1 := from_string ("00001.000101010101000");
    sf3 := power_of (sf1, sf2);
    sf4 := to_sfixed (to_real(sf1)**to_real(sf2), sf4);
    report_error ("rev power_of pattern test", sf3, sf4);
    -- sfixed ** integer
    sf1 := to_sfixed (1, sf1);
    sf3 := sf1 ** 2;
    sf4 := to_sfixed (1, sf4);
    report_error ("1 ** 2", sf3, sf4);
    sf1 := to_sfixed (2, sf1);
    sf3 := sf1 ** 2;
    sf4 := to_sfixed (4, sf4);
    report_error ("2 ** 2", sf3, sf4);
    sf1 := to_sfixed (0.5, sf1);
    sf3 := sf1 ** 3;
    sf4 := to_sfixed (0.125, sf4);
    report_error ("0.5 ** 3", sf3, sf4);
    sf1 := to_sfixed (2, sf1);
    sf3 := sf1 ** (-1);
    sf4 := to_sfixed (0.5, sf4);
    report_error ("2 ** -1", sf3, sf4);
    sf1 := to_sfixed (0, sf1);
    sf3 := sf1 ** 8;
    sf4 := to_sfixed (0, sf4);
    report_error ("0 ** 8", sf3, sf4);
    sf1 := to_sfixed (0.725, sf1);
    sf3 := sf1 ** 0;
    sf4 := to_sfixed (1, sf4);
    report_error ("0.725 ** 0", sf3, sf4);
    -- sfixed ** sfixed
    sf1 := to_sfixed (1, sf1);
    sf2 := to_sfixed (2, sf2);
    sf3 := sf1 ** sf2;
    sf4 := to_sfixed (1, sf4);
    report_error ("sfixed 1 ** 2", sf3, sf4);
    sf1 := to_sfixed (2, sf1);
    sf2 := to_sfixed (2, sf2);
    sf3 := sf1 ** sf2;
    sf4 := to_sfixed (4, sf4);
    report_error ("sfixed 2 ** 2", sf3, sf4);
    sf1 := to_sfixed (0.5, sf1);
    sf2 := to_sfixed (3, sf2);
    sf3 := sf1 ** sf2;
    sf4 := to_sfixed (0.125, sf4);
    report_error ("sfixed 0.5 ** 3", sf3, sf4);
    sf1 := to_sfixed (4, sf1);
    sf2 := to_sfixed (0.5, sf2);
    sf3 := sf1 ** sf2;
    sf4 := to_sfixed (2, sf4);
    report_error ("sfixed 4 ** 0.5", sf3, sf4);
    sf1 := to_sfixed (2, sf1);
    sf2 := to_sfixed (-1, sf2);
    sf3 := sf1 ** sf2;
    sf4 := to_sfixed (0.5, sf4);
    report_error ("sfixed 2 ** -1", sf3, sf4);
    sf1 := to_sfixed (0, sf1);
    sf2 := to_sfixed (8, sf2);
    sf3 := sf1 ** sf2;
    sf4 := to_sfixed (0, sf4);
    report_error ("sfixed 0 ** 8", sf3, sf4);
    sf1 := to_sfixed (0.725, sf1);
    sf2 := to_sfixed (0, sf2);
    sf3 := sf1 ** sf2;
    sf4 := to_sfixed (1, sf4);
    report_error ("sfixed 0.725 ** 0", sf3, sf4);
    -- power_of(ufixed, integer)
    uf1 := to_ufixed (1, uf1);
    uf3 := power_of (uf1, 2);
    uf4 := to_ufixed (1, uf4);
    report_error ("uf power_of(1, 2)", uf3, uf4);
    uf1 := to_ufixed (2, uf1);
    uf3 := power_of (uf1, 2);
    uf4 := to_ufixed (4, uf4);
    report_error ("uf power_of(2, 2)", uf3, uf4);
    uf1 := to_ufixed (0.5, uf1);
    uf3 := power_of (uf1, 3);
    uf4 := to_ufixed (0.125, uf4);
    report_error ("uf power_of(0.5, 3)", uf3, uf4);
    uf1 := to_ufixed (0, uf1);
    uf3 := power_of (uf1, 8);
    uf4 := to_ufixed (0, uf4);
    report_error ("uf power_of(0, 8)", uf3, uf4);
    uf1 := to_ufixed (0.725, uf1);
    uf3 := power_of (uf1, 0);
    uf4 := to_ufixed (1, uf4);
    report_error ("uf power_of(0.725, 0)", uf3, uf4);
    -- power_of(ufixed, ufixed)
    uf1 := to_ufixed (1, uf1);
    uf2 := to_ufixed (2, uf2);
    uf3 := power_of (uf1, uf2);
    uf4 := to_ufixed (1, uf4);
    report_error ("ufixed power_of(1, 2)", uf3, uf4);
    uf1 := to_ufixed (2, uf1);
    uf2 := to_ufixed (2, uf2);
    uf3 := power_of (uf1, uf2);
    uf4 := to_ufixed (4, uf4);
    report_error ("ufixed power_of(2, 2)", uf3, uf4);
    uf1 := to_ufixed (0.5, uf1);
    uf2 := to_ufixed (3, uf2);
    uf3 := power_of (uf1, uf2);
    uf4 := to_ufixed (0.125, uf4);
    report_error ("ufixed power_of(0.5, 3)", uf3, uf4);
    uf1 := to_ufixed (4, uf1);
    uf2 := to_ufixed (0.5, uf2);
    uf3 := power_of (uf1, uf2);
    uf4 := to_ufixed (2, uf4);
    report_error ("ufixed power_of(4, 0.5)", uf3, uf4);
    uf1 := to_ufixed (0, uf1);
    uf2 := to_ufixed (8, uf2);
    uf3 := power_of (uf1, uf2);
    uf4 := to_ufixed (0, uf4);
    report_error ("ufixed power_of(0, 8)", uf3, uf4);
    uf1 := to_ufixed (0.725, uf1);
    uf2 := to_ufixed (0, uf2);
    uf3 := power_of (uf1, uf2);
    uf4 := to_ufixed (1, uf4);
    report_error ("ufixed power_of(0.725, 0)", uf3, uf4);
    -- ufixed ** integer
    uf1 := to_ufixed (1, uf1);
    uf3 := uf1 ** 2;
    uf4 := to_ufixed (1, uf4);
    report_error ("uf 1 ** 2", uf3, uf4);
    uf1 := to_ufixed (2, uf1);
    uf3 := uf1 ** 2;
    uf4 := to_ufixed (4, uf4);
    report_error ("uf 2 ** 2", uf3, uf4);
    uf1 := to_ufixed (0.5, uf1);
    uf3 := uf1 ** 3;
    uf4 := to_ufixed (0.125, uf4);
    report_error ("uf 0.5 ** 3", uf3, uf4);
    uf1 := to_ufixed (0, uf1);
    uf3 := uf1 ** 8;
    uf4 := to_ufixed (0, uf4);
    report_error ("uf 0 ** 8", uf3, uf4);
    uf1 := to_ufixed (0.725, uf1);
    uf3 := uf1 ** 0;
    uf4 := to_ufixed (1, uf4);
    report_error ("uf 0.725 ** 0", uf3, uf4);
    -- ufixed ** ufixed
    uf1 := to_ufixed (1, uf1);
    uf2 := to_ufixed (2, uf2);
    uf3 := uf1 ** uf2;
    uf4 := to_ufixed (1, uf4);
    report_error ("ufixed 1 ** 2", uf3, uf4);
    uf1 := to_ufixed (2, uf1);
    uf2 := to_ufixed (2, uf2);
    uf3 := uf1 ** uf2;
    uf4 := to_ufixed (4, uf4);
    report_error ("ufixed 2 ** 2", uf3, uf4);
    uf1 := to_ufixed (0.5, uf1);
    uf2 := to_ufixed (3, uf2);
    uf3 := uf1 ** uf2;
    uf4 := to_ufixed (0.125, uf4);
    report_error ("ufixed 0.5 ** 3", uf3, uf4);
    uf1 := to_ufixed (4, uf1);
    uf2 := to_ufixed (0.5, uf2);
    uf3 := uf1 ** uf2;
    uf4 := to_ufixed (2, uf4);
    report_error ("ufixed 4 ** 0.5", uf3, uf4);
    uf1 := to_ufixed (0, uf1);
    uf2 := to_ufixed (8, uf2);
    uf3 := uf1 ** uf2;
    uf4 := to_ufixed (0, uf4);
    report_error ("ufixed 0 ** 8", uf3, uf4);
    uf1 := to_ufixed (0.725, uf1);
    uf2 := to_ufixed (0, uf2);
    uf3 := uf1 ** uf2;
    uf4 := to_ufixed (1, uf4);
    report_error ("ufixed 0.725 ** 0", uf3, uf4);
    assert quiet
      report "Top algorithmic function testing completed." severity note;
    topalgtest_done <= true;
  end process topalgtest;

  -- purpose: Trigonometric test (Sin, Cos, Arctan, etc)
  trigtest : process is
    variable sf1, sf2, sf3, sf4 : sfixed (4 downto -15);  -- signed fixed
    variable checkreal          : REAL;
  begin
    wait until start_trigtest;
    -- sin
    checkreal := 0.0;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := sin (sf1);
    sf3       := to_sfixed (sin(checkreal), sf3);
    report_error ("sin(0)", sf2, sf3);
    checkreal := MATH_PI_OVER_2;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := sin (sf1);
    sf3       := to_sfixed (sin(checkreal), sf3);
    report_error ("sin(PI/2)", sf2, sf3);
    checkreal := MATH_PI_OVER_3;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := sin (sf1);
    sf3       := to_sfixed (sin(checkreal), sf3);
    report_error ("sin(PI/3)", sf2, sf3);
    checkreal := MATH_PI_OVER_4;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := sin (sf1);
    sf3       := to_sfixed (sin(checkreal), sf3);
    report_error ("sin(PI/4)", sf2, sf3);
    checkreal := MATH_PI/8.0;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := sin (sf1);
    sf3       := to_sfixed (sin(checkreal), sf3);
    report_error ("sin(22.5 deg)", sf2, sf3);
    checkreal := MATH_DEG_TO_RAD;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := sin (sf1);
    sf3       := to_sfixed (sin(checkreal), sf3);
    report_error ("sin(1 deg)", sf2, sf3);
    checkreal := MATH_PI_OVER_2 - MATH_DEG_TO_RAD;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := sin (sf1);
    sf3       := to_sfixed (sin(checkreal), sf3);
    report_error ("sin(89 deg)", sf2, sf3);
    checkreal := - MATH_DEG_TO_RAD;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := sin (sf1);
    sf3       := to_sfixed (sin(checkreal), sf3);
    report_error ("sin(-1 deg)", sf2, sf3);
    checkreal := MATH_DEG_TO_RAD - MATH_PI_OVER_2;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := sin (sf1);
    sf3       := to_sfixed (sin(checkreal), sf3);
    report_error ("sin(-89 deg)", sf2, sf3);
    checkreal := - MATH_DEG_TO_RAD - MATH_PI_OVER_2;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := sin (sf1);
    sf3       := to_sfixed (sin(checkreal), sf3);
    report_error ("sin(-91 deg)", sf2, sf3);
    checkreal := MATH_PI_OVER_2 + MATH_PI_OVER_4;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := sin (sf1);
    sf3       := to_sfixed (sin(checkreal), sf3);
    report_error ("sin(PI*3/4 135 deg)", sf2, sf3);
    checkreal := MATH_PI;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := sin (sf1);
    sf3       := to_sfixed (sin(checkreal), sf3);
    report_error ("sin(180 deg)", sf2, sf3);
    checkreal := MATH_PI + MATH_DEG_TO_RAD;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := sin (sf1);
    sf3       := to_sfixed (sin(checkreal), sf3);
    report_error ("sin(181 deg)", sf2, sf3);
    checkreal := MATH_PI + MATH_PI_OVER_2 + MATH_DEG_TO_RAD;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := sin (sf1);
    sf3       := to_sfixed (sin(checkreal), sf3);
    report_error ("sin(271 deg)", sf2, sf3);
    checkreal := MATH_2_PI - MATH_DEG_TO_RAD;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := sin (sf1);
    sf3       := to_sfixed (sin(to_real(sf1)), sf3);
    report_error_bias ("sin(359 deg)", sf2, sf3);
    checkreal := -MATH_PI - MATH_DEG_TO_RAD;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := sin (sf1);
    sf3       := to_sfixed (sin(to_real(sf1)), sf3);
    report_error ("sin(-181 deg)", sf2, sf3);
    checkreal := -MATH_PI - MATH_PI_OVER_2 - MATH_DEG_TO_RAD;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := sin (sf1);
    sf3       := to_sfixed (sin(checkreal), sf3);
    report_error ("sin(-271 deg)", sf2, sf3);
    checkreal := -MATH_2_PI + MATH_DEG_TO_RAD;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := sin (sf1);
    sf3       := to_sfixed (sin(checkreal), sf3);
    report_error_bias ("sin(-359 deg)", sf2, sf3);
    checkreal := MATH_2_PI + MATH_PI_OVER_4;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := sin (sf1);
    sf3       := to_sfixed (sin(checkreal), sf3);
    report_error ("sin(2*PI+1/4 45 deg)", sf2, sf3);
    checkreal := -MATH_2_PI - MATH_PI_OVER_4;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := sin (sf1);
    sf3       := to_sfixed (sin(checkreal), sf3);
    report_error ("sin(-2*PI-1/4 -45 deg)", sf2, sf3);
    -- cos
    checkreal := 0.0;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := cos (sf1);
    sf3       := to_sfixed (cos(checkreal), sf3);
    report_error ("cos(0)", sf2, sf3);
    checkreal := MATH_PI_OVER_2;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := cos (sf1);
    sf3       := to_sfixed (cos(checkreal), sf3);
    report_error ("cos(PI/2)", sf2, sf3);
    checkreal := MATH_PI_OVER_3;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := cos (sf1);
    sf3       := to_sfixed (cos(checkreal), sf3);
    report_error ("cos(PI/3)", sf2, sf3);
    checkreal := MATH_PI_OVER_4;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := cos (sf1);
    sf3       := to_sfixed (cos(checkreal), sf3);
    report_error ("cos(PI/4)", sf2, sf3);
    checkreal := MATH_PI/8.0;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := cos (sf1);
    sf3       := to_sfixed (cos(checkreal), sf3);
    report_error ("cos(22.5 deg)", sf2, sf3);
    checkreal := MATH_DEG_TO_RAD;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := cos (sf1);
    sf3       := to_sfixed (cos(checkreal), sf3);
    report_error ("cos(1 deg)", sf2, sf3);
    checkreal := MATH_PI_OVER_2 - MATH_DEG_TO_RAD;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := cos (sf1);
    sf3       := to_sfixed (cos(checkreal), sf3);
    report_error ("cos(89 deg)", sf2, sf3);
    checkreal := - MATH_DEG_TO_RAD;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := cos (sf1);
    sf3       := to_sfixed (cos(checkreal), sf3);
    report_error ("cos(-1 deg)", sf2, sf3);
    checkreal := MATH_DEG_TO_RAD - MATH_PI_OVER_2;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := cos (sf1);
    sf3       := to_sfixed (cos(checkreal), sf3);
    report_error ("cos(-89 deg)", sf2, sf3);
    checkreal := - MATH_DEG_TO_RAD - MATH_PI_OVER_2;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := cos (sf1);
    sf3       := to_sfixed (cos(checkreal), sf3);
    report_error ("cos(-91 deg)", sf2, sf3);
    checkreal := MATH_PI_OVER_2 + MATH_PI_OVER_4;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := cos (sf1);
    sf3       := to_sfixed (cos(checkreal), sf3);
    report_error_bias ("cos(PI*3/4 = 135 deg)", sf2, sf3);
    checkreal := MATH_PI;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := cos (sf1);
    sf3       := to_sfixed (cos(checkreal), sf3);
    report_error ("cos(180 deg)", sf2, sf3);
    checkreal := MATH_PI + MATH_DEG_TO_RAD;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := cos (sf1);
    sf3       := to_sfixed (cos(checkreal), sf3);
    report_error ("cos(181 deg)", sf2, sf3);
    checkreal := MATH_PI + MATH_PI_OVER_2 + MATH_DEG_TO_RAD;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := cos (sf1);
    sf3       := to_sfixed (cos(checkreal), sf3);
    report_error_bias ("cos(271 deg)", sf2, sf3);
    checkreal := MATH_2_PI - MATH_DEG_TO_RAD;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := cos (sf1);
    sf3       := to_sfixed (cos(checkreal), sf3);
    report_error ("cos(359 deg)", sf2, sf3);
    checkreal := -MATH_PI - MATH_DEG_TO_RAD;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := cos (sf1);
    sf3       := to_sfixed (cos(checkreal), sf3);
    report_error ("cos(-181 deg)", sf2, sf3);
    checkreal := -MATH_PI - MATH_PI_OVER_2 - MATH_DEG_TO_RAD;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := cos (sf1);
    sf3       := to_sfixed (cos(checkreal), sf3);
    report_error_bias ("cos(-271 deg)", sf2, sf3);
    checkreal := -MATH_2_PI + MATH_DEG_TO_RAD;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := cos (sf1);
    sf3       := to_sfixed (cos(checkreal), sf3);
    report_error ("cos(-359 deg)", sf2, sf3);
    checkreal := MATH_2_PI + MATH_PI_OVER_4;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := cos (sf1);
    sf3       := to_sfixed (cos(checkreal), sf3);
    report_error_bias ("cos(2*PI+1/4 45 deg)", sf2, sf3);
    checkreal := -MATH_2_PI - MATH_PI_OVER_4;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := cos (sf1);
    sf3       := to_sfixed (cos(checkreal), sf3);
    report_error_bias ("cos(-2*PI-1/4 -45 deg)", sf2, sf3);
    -- tan
    checkreal := 0.0;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := tan (sf1);
    sf3       := to_sfixed (tan(checkreal), sf3);
    report_error ("tan(0)", sf2, sf3);
    checkreal := MATH_PI_OVER_3;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := tan (sf1);
    sf3       := to_sfixed (tan(to_real(sf1)), sf3);
    report_error ("tan(PI/3)", sf2, sf3);
    checkreal := MATH_PI_OVER_4;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := tan (sf1);
    sf3       := to_sfixed (tan(to_real(sf1)), sf3);
    report_error ("tan(PI/4 = 45 deg)", sf2, sf3);
    checkreal := MATH_PI/8.0;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := tan (sf1);
    sf3       := to_sfixed (tan(to_real(sf1)), sf3);
    report_error ("tan(PI/8 = 22.5 deg)", sf2, sf3);
    checkreal := MATH_DEG_TO_RAD;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := tan (sf1);
    sf3       := to_sfixed (tan(to_real(sf1)), sf3);
    report_error ("tan(1 deg)", sf2, sf3);
    checkreal := MATH_PI_OVER_2 - (10.0 * MATH_DEG_TO_RAD);
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := tan (sf1);
    sf3       := to_sfixed (tan(to_real(sf1)), sf3);
    report_error ("tan(80 deg)", sf2, sf3);
    checkreal := - MATH_DEG_TO_RAD;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := tan (sf1);
    sf3       := to_sfixed (tan(to_real(sf1)), sf3);
    report_error ("tan(-1 deg)", sf2, sf3);
    checkreal := (10.0 * MATH_DEG_TO_RAD) - MATH_PI_OVER_2;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := tan (sf1);
    sf3       := to_sfixed (tan(to_real(sf1)), sf3);
    report_error ("tan(-80 deg)", sf2, sf3);
    checkreal := MATH_PI;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := tan (sf1);
    sf3       := to_sfixed (tan(checkreal), sf3);
    report_error ("tan(180 deg)", sf2, sf3);
    -- arcsin
    checkreal := 0.0;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arcsin (sf1);
    sf3       := to_sfixed (0.0, sf3);
    report_error_bias ("arcsin(0)", sf2, sf3);
    checkreal := sin(MATH_DEG_TO_RAD);
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arcsin (sf1);
    sf3       := to_sfixed (to_real(sf1), sf3);
    report_error ("arcsin(1 deg)", sf2, sf3);
    checkreal := sin(-MATH_DEG_TO_RAD);
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arcsin (sf1);
    sf3       := to_sfixed (arcsin(to_real(sf1)), sf3);
    report_error_bias ("arcsin(-1 deg)", sf2, sf3);
    checkreal := sin(MATH_PI_OVER_4);
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arcsin (sf1);
    sf3       := to_sfixed (arcsin(to_real(sf1)), sf3);
    report_error_bias ("arcsin(45 deg)", sf2, sf3);
    checkreal := sin(-MATH_PI_OVER_4);
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arcsin (sf1);
    sf3       := to_sfixed (arcsin(to_real(sf1)), sf3);
    report_error ("arcsin(-45 deg)", sf2, sf3);
    -- Algorithemic error around 90 degrees.
    checkreal := sin(MATH_PI_OVER_2 - MATH_DEG_TO_RAD);
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arcsin (arg => sf1);
    sf3       := to_sfixed (arcsin(to_real(sf1)), sf3);
    report_error_bias ("arcsin(89 deg)", sf2, sf3);
    checkreal := sin(-MATH_PI_OVER_2 + MATH_DEG_TO_RAD);
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arcsin (arg => sf1);
    sf3       := to_sfixed (arcsin(to_real(sf1)), sf3);
    report_error_bias ("arcsin(-89 deg)", sf2, sf3);
    -- Trigger 1.0 test
    checkreal := 1.0;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arcsin (sf1);
    sf3       := to_sfixed (MATH_PI_OVER_2, sf3);
    report_error ("arcsin(90 deg)", sf2, sf3);
    checkreal := -1.0;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arcsin (sf1);
    sf3       := to_sfixed (-MATH_PI_OVER_2, sf3);
    report_error ("arcsin(-90 deg)", sf2, sf3);
    if (not quiet) then
      report "Expect two errors from arcsin here." severity note;
      -- Trigger > 1.0 error
      checkreal := 1.5;
      sf1       := to_sfixed (checkreal, sf1);
      sf2       := arcsin (sf1);
      sf3       := to_sfixed (0, sf3);
      report_error ("arcsin(1.5)", sf2, sf3);
      checkreal := -1.5;
      sf1       := to_sfixed (checkreal, sf1);
      sf2       := arcsin (sf1);
      sf3       := to_sfixed (0, sf3);
      report_error ("arcsin(-1.5)", sf2, sf3);
    end if;
    -- do it exhaustively
    checkreal := 1.0;
    while (checkreal > -1.0) loop
      sf1       := to_sfixed (checkreal, sf1);
      sf2       := arcsin (sf1);
      sf3       := to_sfixed (arcsin(to_real(sf1)), sf3);
      report_error_bias ("arcsin(" & REAL'image(checkreal) & ")", sf2, sf3);
      checkreal := checkreal - 0.01;
    end loop;

    -- arccos
    checkreal := 0.0;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arccos (sf1);
    sf3       := to_sfixed (MATH_PI_OVER_2, sf3);
    report_error ("arccos(0)", sf2, sf3);
    -- Algorithemic error around 0 degrees.
    checkreal := cos(MATH_DEG_TO_RAD);
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arccos (sf1);
    sf3       := to_sfixed (MATH_DEG_TO_RAD, sf3);
    report_error ("arccos(1 deg)", sf2, sf3);
    checkreal := cos(-MATH_DEG_TO_RAD);
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arccos (sf1);
    sf3       := to_sfixed (MATH_DEG_TO_RAD, sf3);
    report_error ("arccos(-1 deg)", sf2, sf3);
    checkreal := cos(MATH_PI_OVER_4);
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arccos (sf1);
    sf3       := to_sfixed (MATH_PI_OVER_4, sf3);
    report_error_bias ("arccos(45 deg)", sf2, sf3);
    checkreal := cos(-MATH_PI_OVER_4);
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arccos (sf1);
    sf3       := to_sfixed (MATH_PI_OVER_4, sf3);
    report_error_bias ("arccos(-45 deg)", sf2, sf3);
    checkreal := cos(MATH_PI_OVER_2 - MATH_DEG_TO_RAD);
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arccos (sf1);
    sf3       := to_sfixed (MATH_PI_OVER_2 - MATH_DEG_TO_RAD, sf3);
    report_error ("arccos(89 deg)", sf2, sf3);
    checkreal := cos(-MATH_PI_OVER_2 + MATH_DEG_TO_RAD);
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arccos (sf1);
    sf3       := to_sfixed (MATH_PI_OVER_2 - MATH_DEG_TO_RAD, sf3);
    report_error ("arccos(-89 deg)", sf2, sf3);
    -- Trigger 1.0 test
    checkreal := 1.0;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arccos (sf1);
    sf3       := to_sfixed (0.0, sf3);
    report_error ("arccos(90 deg)", sf2, sf3);
    checkreal := -1.0;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arccos (sf1);
    sf3       := to_sfixed (arccos(-1.0), sf3);
    report_error ("arccos(-90 deg)", sf2, sf3);
    if (not quiet) then
      report "Expect two errors from arccos here." severity note;
      -- Trigger > 1.0 error
      checkreal := 1.5;
      sf1       := to_sfixed (checkreal, sf1);
      sf2       := arccos (sf1);
      sf3       := to_sfixed (0, sf3);
      report_error ("arccos(1.5)", sf2, sf3);
      checkreal := -1.5;
      sf1       := to_sfixed (checkreal, sf1);
      sf2       := arccos (sf1);
      sf3       := to_sfixed (0, sf3);
      report_error ("arccos(-1.5)", sf2, sf3);
    end if;
    -- arctan
    checkreal := 0.0;
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arctan (sf1);
    sf3       := to_sfixed (arctan(checkreal), sf3);
    report_error ("arctan(0)", sf2, sf3);
    checkreal := tan(MATH_DEG_TO_RAD);
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arctan (sf1);
    sf3       := to_sfixed (MATH_DEG_TO_RAD, sf3);
    report_error ("arctan(1 deg)", sf2, sf3);
    checkreal := tan(-MATH_DEG_TO_RAD);
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arctan (sf1);
    sf3       := to_sfixed (-MATH_DEG_TO_RAD, sf3);
    report_error ("arctan(-1 deg)", sf2, sf3);
    checkreal := tan(10.0*MATH_DEG_TO_RAD);
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arctan (sf1);
    sf3       := to_sfixed (arctan (to_real(sf1)), sf3);
    report_error ("arctan(10 deg)", sf2, sf3);
    checkreal := tan(-(10.0*MATH_DEG_TO_RAD));
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arctan (sf1);
    sf3       := to_sfixed (arctan (to_real(sf1)), sf3);
    report_error ("arctan(-10 deg)", sf2, sf3);
    checkreal := tan(MATH_PI_OVER_4-(10.0*MATH_DEG_TO_RAD));
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arctan (sf1);
    sf3       := to_sfixed (arctan (to_real(sf1)), sf3);
    report_error ("arctan(35 deg)", sf2, sf3);
    checkreal := tan(-MATH_PI_OVER_4+(10.0*MATH_DEG_TO_RAD));
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arctan (sf1);
    sf3       := to_sfixed (arctan (to_real(sf1)), sf3);
    report_error ("arctan(-35 deg)", sf2, sf3);
    -- Detailed test around 45 degrees
    checkreal := tan(MATH_PI_OVER_4-MATH_DEG_TO_RAD);
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arctan (sf1);
    sf3       := to_sfixed (arctan (to_real(sf1)), sf3);
    report_error ("arctan(44 deg)", sf2, sf3);
    checkreal := tan(-MATH_PI_OVER_4+MATH_DEG_TO_RAD);
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arctan (sf1);
    sf3       := to_sfixed (arctan (to_real(sf1)), sf3);
    report_error ("arctan(-44 deg)", sf2, sf3);
    checkreal := tan(MATH_PI_OVER_4);
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arctan (sf1);
    sf3       := to_sfixed (arctan (to_real(sf1)), sf3);
    report_error ("arctan(45 deg)", sf2, sf3);
    checkreal := tan(-MATH_PI_OVER_4);
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arctan (sf1);
    sf3       := to_sfixed (arctan (to_real(sf1)), sf3);
    report_error ("arctan(-45 deg)", sf2, sf3);
    checkreal := tan(MATH_PI_OVER_4+MATH_DEG_TO_RAD);
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arctan (sf1);
    sf3       := to_sfixed (arctan (to_real(sf1)), sf3);
    report_error ("arctan(46 deg)", sf2, sf3);
    checkreal := tan(-MATH_PI_OVER_4-MATH_DEG_TO_RAD);
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arctan (sf1);
    sf3       := to_sfixed (arctan (to_real(sf1)), sf3);
    report_error ("arctan(-46 deg)", sf2, sf3);
    -- Algorithm not accurate over 1.0
    checkreal := tan(MATH_PI_OVER_4 + (10.0*MATH_DEG_TO_RAD));
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arctan (sf1);
    sf3       := to_sfixed (arctan (to_real(sf1)), sf3);
    report_error ("arctan(55 deg)", sf2, sf3);
    checkreal := tan(-MATH_PI_OVER_4 - (10.0*MATH_DEG_TO_RAD));
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arctan (sf1);
    sf3       := to_sfixed (arctan (to_real(sf1)), sf3);
    report_error ("arctan(-55 deg)", sf2, sf3);
    checkreal := tan(MATH_PI_OVER_2 - (10.0*MATH_DEG_TO_RAD));
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arctan (sf1);
    sf3       := to_sfixed (arctan (to_real(sf1)), sf3);
    report_error ("arctan(80 deg)", sf2, sf3);
    checkreal := tan(-(MATH_PI_OVER_2 - (10.0*MATH_DEG_TO_RAD)));
    sf1       := to_sfixed (checkreal, sf1);
    sf2       := arctan (sf1);
    sf3       := to_sfixed (arctan (to_real(sf1)), sf3);
    report_error ("arctan(-80 deg)", sf2, sf3);
    assert quiet
      report "Trigonometric function testing completed." severity note;
    trigtest_done <= true;
  end process trigtest;

  -- purpose: sinh, cosh, tanh arcsinh, arccosh, arctanh
  htest : process is
    variable sf1, sf2, sf3, sf4 : sfixed (4 downto -15);  -- signed fixed
    variable checkreal          : REAL;
  begin
    wait until start_htest;
    sf1 := to_sfixed (0, sf1'high, sf1'low);
    sf2 := sinh (sf1);
    sf3 := to_sfixed (sinh (to_real(sf1)), sf3);
    report_error ("sinh(0)", sf2, sf3);
    sf1 := to_sfixed (1, sf1'high, sf1'low);
    sf2 := sinh (sf1);
    sf3 := to_sfixed (sinh (to_real(sf1)), sf3);
    report_error ("sinh(1)", sf2, sf3);
    sf1 := to_sfixed (-1, sf1'high, sf1'low);
    sf2 := sinh (sf1);
    sf3 := to_sfixed (sinh (to_real(sf1)), sf3);
    report_error ("sinh(-1)", sf2, sf3);
    sf1 := to_sfixed (2, sf1'high, sf1'low);
    sf2 := sinh (sf1);
    sf3 := to_sfixed (sinh (to_real(sf1)), sf3);
    report_error ("sinh(2)", sf2, sf3);
    sf1 := to_sfixed (-2, sf1'high, sf1'low);
    sf2 := sinh (sf1);
    sf3 := to_sfixed (sinh (to_real(sf1)), sf3);
    report_error ("sinh(-2)", sf2, sf3);
    sf1 := to_sfixed (0.825, sf1'high, sf1'low);
    sf2 := sinh (sf1);
    sf3 := to_sfixed (sinh (to_real(sf1)), sf3);
    report_error ("sinh(0.825)", sf2, sf3);
    sf1 := to_sfixed (-0.825, sf1'high, sf1'low);
    sf2 := sinh (sf1);
    sf3 := to_sfixed (sinh (to_real(sf1)), sf3);
    report_error ("sinh(-0.825)", sf2, sf3);
    if not QUIET then
      -- Saturation test
      sf1 := to_sfixed (8, sf1'high, sf1'low);
      sf2 := sinh (sf1);
      sf3 := saturate (sf3'high, sf3'low);
      report_error ("sinh(8)", sf2, sf3);
      sf1 := to_sfixed (-8, sf1'high, sf1'low);
      sf2 := sinh (sf1);
      sf3 := not saturate (sf3'high, sf3'low);
      report_error ("sinh(-8)", sf2, sf3);
    end if;
    -- cosh
    sf1 := to_sfixed (0, sf1'high, sf1'low);
    sf2 := cosh (sf1);
    sf3 := to_sfixed (cosh (to_real(sf1)), sf3);
    report_error ("cosh(0)", sf2, sf3);
    sf1 := to_sfixed (1, sf1'high, sf1'low);
    sf2 := cosh (sf1);
    sf3 := to_sfixed (cosh (to_real(sf1)), sf3);
    report_error_bias ("cosh(1)", sf2, sf3);
    sf1 := to_sfixed (-1, sf1'high, sf1'low);
    sf2 := cosh (sf1);
    sf3 := to_sfixed (cosh (to_real(sf1)), sf3);
    report_error_bias ("cosh(-1)", sf2, sf3);
    sf1 := to_sfixed (2, sf1'high, sf1'low);
    sf2 := cosh (sf1);
    sf3 := to_sfixed (cosh (to_real(sf1)), sf3);
    report_error_bias ("cosh(2)", sf2, sf3);
    sf1 := to_sfixed (-2, sf1'high, sf1'low);
    sf2 := cosh (sf1);
    sf3 := to_sfixed (cosh (to_real(sf1)), sf3);
    report_error_bias ("cosh(-2)", sf2, sf3);
    sf1 := to_sfixed (0.825, sf1'high, sf1'low);
    sf2 := cosh (sf1);
    sf3 := to_sfixed (cosh (to_real(sf1)), sf3);
    report_error_bias ("cosh(0.825)", sf2, sf3);
    sf1 := to_sfixed (-0.825, sf1'high, sf1'low);
    sf2 := cosh (sf1);
    sf3 := to_sfixed (cosh (to_real(sf1)), sf3);
    report_error_bias ("cosh(-0.825)", sf2, sf3);
    -- saturation
    if not QUIET then
      sf1 := to_sfixed (8, sf1'high, sf1'low);
      sf2 := cosh (sf1);
      sf3 := saturate (sf3'high, sf3'low);
      report_error ("cosh(8)", sf2, sf3);
      sf1 := to_sfixed (-8, sf1'high, sf1'low);
      sf2 := cosh (sf1);
      sf3 := saturate (sf3'high, sf3'low);
      report_error ("cosh(-8)", sf2, sf3);
    end if;
    -- tanh
    sf1 := to_sfixed (0, sf1'high, sf1'low);
    sf2 := tanh (sf1);
    sf3 := to_sfixed (tanh (to_real(sf1)), sf3);
    report_error ("tanh(0)", sf2, sf3);
    sf1 := to_sfixed (1, sf1'high, sf1'low);
    sf2 := tanh (sf1);
    sf3 := to_sfixed (tanh (to_real(sf1)), sf3);
    report_error ("tanh(1)", sf2, sf3);
    sf1 := to_sfixed (-1, sf1'high, sf1'low);
    sf2 := tanh (sf1);
    sf3 := to_sfixed (tanh (to_real(sf1)), sf3);
    report_error_bias ("tanh(-1)", sf2, sf3);
    sf1 := to_sfixed (2, sf1'high, sf1'low);
    sf2 := tanh (sf1);
    sf3 := to_sfixed (tanh (to_real(sf1)), sf3);
    report_error ("tanh(2)", sf2, sf3);
    sf1 := to_sfixed (-2, sf1'high, sf1'low);
    sf2 := tanh (sf1);
    sf3 := to_sfixed (tanh (to_real(sf1)), sf3);
    report_error_precision ("tanh(-2)", sf2, sf3, 9);
    sf1 := to_sfixed (0.825, sf1'high, sf1'low);
    sf2 := tanh (sf1);
    sf3 := to_sfixed (tanh (to_real(sf1)), sf3);
    report_error ("tanh(0.825)", sf2, sf3);
    sf1 := to_sfixed (-0.825, sf1'high, sf1'low);
    sf2 := tanh (sf1);
    sf3 := to_sfixed (tanh (to_real(sf1)), sf3);
    report_error_bias ("tanh(-0.825)", sf2, sf3);
    -- saturation
    sf1 := to_sfixed (4, sf1'high, sf1'low);
    sf2 := tanh (sf1);
    sf3 := to_sfixed (tanh (to_real(sf1)), sf3);
    report_error_precision ("tanh(4)", sf2, sf3, 6);
    sf1 := to_sfixed (-4, sf1'high, sf1'low);
    sf2 := tanh (sf1);
    sf3 := to_sfixed (tanh (to_real(sf1)), sf3);
    report_error_precision ("tanh(-4)", sf2, sf3, 6);
    -- arcsinh
    sf1 := to_sfixed (0, sf1'high, sf1'low);
    sf2 := arcsinh (sf1);
    sf3 := to_sfixed (arcsinh (to_real(sf1)), sf3);
    report_error ("arcsinh(0)", sf2, sf3);
    sf1 := to_sfixed (1, sf1'high, sf1'low);
    sf2 := arcsinh (sf1);
    sf3 := to_sfixed (arcsinh (to_real(sf1)), sf3);
    report_error ("arcsinh(1)", sf2, sf3);
    sf1 := to_sfixed (-1, sf1'high, sf1'low);
    sf2 := arcsinh (sf1);
    sf3 := to_sfixed (arcsinh (to_real(sf1)), sf3);
    report_error ("arcsinh(-1)", sf2, sf3);
    sf1 := to_sfixed (2, sf1'high, sf1'low);
    sf2 := arcsinh (sf1);
    sf3 := to_sfixed (arcsinh (to_real(sf1)), sf3);
    report_error_precision ("arcsinh(2)", sf2, sf3, 10);
    sf1 := to_sfixed (-2, sf1'high, sf1'low);
    sf2 := arcsinh (sf1);
    sf3 := to_sfixed (arcsinh (to_real(sf1)), sf3);
    report_error_precision ("arcsinh(-2)", sf2, sf3, 10);
    sf1 := to_sfixed (2.5, sf1'high, sf1'low);
    sf2 := arcsinh (sf1);
    sf3 := to_sfixed (arcsinh (to_real(sf1)), sf3);
    report_error_precision ("arcsinh(2.5)", sf2, sf3, 9);
    sf1 := to_sfixed (-2.5, sf1'high, sf1'low);
    sf2 := arcsinh (sf1);
    sf3 := to_sfixed (arcsinh (to_real(sf1)), sf3);
    report_error_precision ("arcsinh(-2.5)", sf2, sf3, 9);
    sf1 := to_sfixed (3, sf1'high, sf1'low);
    sf2 := arcsinh (sf1);
    sf3 := to_sfixed (arcsinh (to_real(sf1)), sf3);
    report_error_precision ("arcsinh(3)", sf2, sf3, 7);
    sf1 := to_sfixed (-3, sf1'high, sf1'low);
    sf2 := arcsinh (sf1);
    sf3 := to_sfixed (arcsinh (to_real(sf1)), sf3);
    report_error_precision ("arcsinh(-3)", sf2, sf3, 7);

    -- arccosh
    if not QUIET then
      sf1 := to_sfixed (0, sf1'high, sf1'low);
      sf2 := arccosh (sf1);
      sf3 := to_sfixed (0, sf3);
      report_error ("arccosh(0)", sf2, sf3);
      sf1 := to_sfixed (1, sf1'high, sf1'low);
      sf2 := arccosh (sf1);
      sf3 := to_sfixed (0, sf3);
      report_error ("arccosh(1)", sf2, sf3);
    end if;
    sf1 := to_sfixed (2, sf1'high, sf1'low);
    sf2 := arccosh (sf1);
    sf3 := to_sfixed (arccosh (to_real(sf1)), sf3);
    report_error ("arccosh(2)", sf2, sf3);
    sf1 := to_sfixed (2.5, sf1'high, sf1'low);
    sf2 := arccosh (sf1);
    sf3 := to_sfixed (arccosh (to_real(sf1)), sf3);
    report_error_precision ("arccosh(2.5)", sf2, sf3, 10);
    sf1 := to_sfixed (3, sf1'high, sf1'low);
    sf2 := arccosh (sf1);
    sf3 := to_sfixed (arccosh (to_real(sf1)), sf3);
    report_error_precision ("arccosh(3)", sf2, sf3, 8);
    -- arctanh
    sf1 := to_sfixed (0.1, sf1'high, sf1'low);
    sf2 := arctanh (sf1);
    sf3 := to_sfixed (arctanh (to_real(sf1)), sf3);
    report_error ("arctanh(0.1)", sf2, sf3);
    sf1 := to_sfixed (-0.1, sf1'high, sf1'low);
    sf2 := arctanh (sf1);
    sf3 := to_sfixed (arctanh (to_real(sf1)), sf3);
    report_error ("arctanh(-0.1)", sf2, sf3);
    sf1 := to_sfixed (0.25, sf1'high, sf1'low);
    sf2 := arctanh (sf1);
    sf3 := to_sfixed (arctanh (to_real(sf1)), sf3);
    report_error ("arctanh(0.25)", sf2, sf3);
    sf1 := to_sfixed (-0.25, sf1'high, sf1'low);
    sf2 := arctanh (sf1);
    sf3 := to_sfixed (arctanh (to_real(sf1)), sf3);
    report_error ("arctanh(-0.25)", sf2, sf3);
    sf1 := to_sfixed (0.5, sf1'high, sf1'low);
    sf2 := arctanh (sf1);
    sf3 := to_sfixed (arctanh (to_real(sf1)), sf3);
    report_error_bias ("arctanh(0.5)", sf2, sf3);
    sf1 := to_sfixed (-0.5, sf1'high, sf1'low);
    sf2 := arctanh (sf1);
    sf3 := to_sfixed (arctanh (to_real(sf1)), sf3);
    report_error_bias ("arctanh(-0.5)", sf2, sf3);
    sf1 := to_sfixed (0.75, sf1'high, sf1'low);
    sf2 := arctanh (sf1);
    sf3 := to_sfixed (arctanh (to_real(sf1)), sf3);
    report_error_precision ("arctanh(0.75)", sf2, sf3, 6);
    sf1 := to_sfixed (-0.75, sf1'high, sf1'low);
    sf2 := arctanh (sf1);
    sf3 := to_sfixed (arctanh (to_real(sf1)), sf3);
    report_error_precision ("arctanh(-0.75)", sf2, sf3, 6);
    -- Algorithm breaks down as you approach 1.0
    sf1 := to_sfixed (0.9, sf1'high, sf1'low);
    sf2 := arctanh (sf1);
    sf3 := to_sfixed (arctanh (to_real(sf1)), sf3);
    report_error_precision ("arctanh(0.9)", sf2, sf3, 2);
    sf1 := to_sfixed (-0.9, sf1'high, sf1'low);
    sf2 := arctanh (sf1);
    sf3 := to_sfixed (arctanh (to_real(sf1)), sf3);
    report_error_precision ("arctanh(-0.9)", sf2, sf3, 2);
    if not QUIET then
      sf1 := to_sfixed (1, sf1'high, sf1'low);
      sf2 := arctanh (sf1);
      sf3 := saturate (sf3'high, sf3'low);
      report_error ("arctanh(1)", sf2, sf3);
      sf1 := to_sfixed (-1, sf1'high, sf1'low);
      sf2 := arctanh (sf1);
      sf3 := not saturate (sf3'high, sf3'low);
      report_error ("arctanh(-1)", sf2, sf3);
      sf1 := to_sfixed (2, sf1'high, sf1'low);
      sf2 := arctanh (sf1);
      sf3 := saturate (sf3'high, sf3'low);
      report_error ("arctanh(2)", sf2, sf3);
      sf1 := to_sfixed (-2, sf1'high, sf1'low);
      sf2 := arctanh (sf1);
      sf3 := not saturate (sf3'high, sf3'low);
      report_error ("arctanh(-2)", sf2, sf3);
    end if;
    assert quiet
      report "Hyperbolic function testing completed" severity note;
    htest_done <= true;
  end process htest;
  
end architecture testbench;
