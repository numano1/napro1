LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use ieee.numeric_std.all;

entity clkdiv10 is
  port (
    c      : IN  STD_LOGIC;		-- clock input
    rn     : IN  STD_LOGIC;		-- reset (active low)
    c_out  : OUT STD_LOGIC);		-- data output
end clkdiv10;


ARCHITECTURE rtl OF clkdiv10 IS

  signal cnt : unsigned(3 downto 0);
  
BEGIN

  count : PROCESS (c, rn)
  BEGIN
    IF rn = '0' THEN			-- asynchronous reset (active low)
      cnt <= "0000";
    ELSIF falling_edge(c) then
      if to_integer(cnt) < 9 then
        cnt <= to_unsigned((to_integer(cnt) + 1), 4);
      else
        cnt <= "0000";
      end if;
    END IF;
  END PROCESS count;

  divide : process (c, cnt, rn)
  begin
    if rn = '0' then
      c_out <= '0';
    elsif rising_edge(c) then
      if cnt > 4 then
        c_out <= '1';
      else
        c_out <= '0';
      end if;
    end if;
  end process divide;

END rtl;

