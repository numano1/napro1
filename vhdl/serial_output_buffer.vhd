-- Serial output data is updated on the falling edge of the clock
-- signal and is supposed to be read on the rising edge.
-- Counter is updated on the rising edge of the block.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity serial_output_buffer is
  generic (
    N : integer := 8);
  port (
    data_in   : in  std_logic_vector(N-1 downto 0);
    clk       : in  std_logic;
    reset     : in  std_logic;
    data_out  : out std_logic);
end serial_output_buffer;



architecture rtl of serial_output_buffer is

  signal counter   : std_logic_vector(2 downto 0);
  signal one       : std_logic_vector(2 downto 0);

begin  -- rtl

  output_bits : process (clk, reset, counter, data_in)
  begin  -- process output_bits

    if reset = '0' then
--      counter <= "111";
      data_out <= data_in(7);
--    elsif clk'event and clk = '0' then
    elsif clk'event and clk = '0' then
      data_out <= data_in(to_integer(unsigned(counter)));
--    elsif clk'event and clk = '1' then
--      counter <= std_logic_vector( resize(unsigned(counter), 3) - resize(unsigned(one), 3) );
--    else
    end if;
    
  end process output_bits;
  
  update_counter : process (clk, reset, counter, data_in)
  begin  -- process output_bits

    if reset = '0' then
      counter <= "111";
    elsif clk'event and clk = '1' then
      counter <= std_logic_vector( resize(unsigned(counter), 3) - resize(unsigned(one), 3) );
    end if;
    
  end process update_counter;

  one <= "001";

end rtl;
