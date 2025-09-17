-------------------------------------------------------------------------------
-- MUX ------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Connect one of two inputs to the output according to a control signal.
-------------------------------------------------------------------------------
--      GENERICS
--        n = number of bits in the input signals
--      INPUTS:
--        input0   = input signal 0
--        input1   = input signal 1
--        selector = selects the input. 0 selects input0, 1 selects input1.
--
--      OUTPUTS:
--        output = output signal
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux2 is
  port (
    input0   : in  std_logic;
    input1   : in  std_logic;
    selector : in  std_logic;
    output   : out std_logic);
end mux2;

architecture rtl of mux2 is

begin  -- rtl

  -- purpose: connect the selected input to the output
  make_connection : process (selector, input0, input1)

  begin  -- process select

    if selector = '0' then
      output <= input0;
    else
      output <= input1;
    end if;
    
  end process;

end rtl;
