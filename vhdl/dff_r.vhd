-------------------------------------------------------------------------------
-- Title      : A resetable D flip-flop
-------------------------------------------------------------------------------
-- File	      : dff_r.vhd
-- Author     : Vesa Turunen
-- Company    : 
-- Created    : 2008-01-28
-- Last update: 2008-01-28
-------------------------------------------------------------------------------
-- DESCRIPTION: A Rising edge triggered D flip-flop with active low reset.
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY dff_r IS
  PORT (
    d  : IN  STD_LOGIC;			-- data input
    c  : IN  STD_LOGIC;			-- clock input
    rn : IN  STD_LOGIC;			-- reset (active low)
    q  : OUT STD_LOGIC);		-- data output
END dff_r;


ARCHITECTURE rtl OF dff_r IS
BEGIN

  dff : PROCESS (c, rn)
  BEGIN
    IF rn = '0' THEN			-- asynchronous reset (active low)
      q <= '0';
    ELSIF c'event AND c = '1' THEN	-- rising clock edge
      q <= d;
    END IF;
  END PROCESS dff;
END rtl;

