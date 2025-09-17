-------------------------------------------------------------------------------
-- Title      : A resetable D flip-flop
-------------------------------------------------------------------------------
-- File	      : dff_r.vhd
-- Author     : Vesa Turunen, Mika Pulkkinen
-- Company    : 
-- Created    : 2008-01-28
-- Last update: 2014/06/23
-------------------------------------------------------------------------------
-- DESCRIPTION: A Rising edge triggered D flip-flop with active low reset.
--              Output is set to input s at reset.
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY dfp_r IS
  PORT (
    d  : IN  STD_LOGIC;			-- data input
    c  : IN  STD_LOGIC;			-- clock input
    s  : in  std_logic;   -- default value at reset
    rn : IN  STD_LOGIC;			-- reset (active low)
    q  : OUT STD_LOGIC);		-- data output
END dfp_r;


ARCHITECTURE rtl OF dfp_r IS
BEGIN

  dff : PROCESS (c, rn)
  BEGIN
    IF rn = '0' THEN			-- asynchronous reset (active low)
      q <= s;
    ELSIF c'event AND c = '1' THEN	-- rising clock edge
      q <= d;
    END IF;
  END PROCESS dff;
END rtl;

