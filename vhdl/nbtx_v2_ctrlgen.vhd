LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY nbtx_v2_ctrlgen IS
  PORT (
    clk           : in std_logic;
    clk_10m       : in std_logic;
    thisbit       : in std_logic;
    nextbit       : in std_logic;
    resetn        : in std_logic;

    outsel0       : in std_logic_vector(2 downto 0);
    outsel1       : in std_logic_vector(2 downto 0);
    outsel2       : in std_logic_vector(2 downto 0);
    outsel3       : in std_logic_vector(2 downto 0);
    outsel4       : in std_logic_vector(2 downto 0);
    outsel5       : in std_logic_vector(2 downto 0);
    outsel6       : in std_logic_vector(2 downto 0);
    outselosc     : in std_logic_vector(2 downto 0);

    osc_ena_out   : out std_logic;
    pa_ena_out6   : out std_logic;
    pa_ena_out5   : out std_logic;
    pa_ena_out4   : out std_logic;
    pa_ena_out3   : out std_logic;
    pa_ena_out2   : out std_logic;
    pa_ena_out1   : out std_logic;
    pa_ena_out0   : out std_logic);
END nbtx_v2_ctrlgen;


ARCHITECTURE rtl OF nbtx_v2_ctrlgen IS

signal clk_10mn : std_logic;
signal state      : std_logic_vector(3 downto 0);
signal next_state : std_logic_vector(3 downto 0);
signal pa_ena0    : std_logic;
signal pa_ena1    : std_logic;
signal pa_ena2    : std_logic;
signal pa_ena3    : std_logic;
signal pa_ena4    : std_logic;
signal pa_ena_out0_temp : std_logic;
signal pa_ena_out1_temp : std_logic;
signal pa_ena_out2_temp : std_logic;
signal pa_ena_out3_temp : std_logic;
signal pa_ena_out4_temp : std_logic;
signal pa_ena_out5_temp : std_logic;
signal pa_ena_out6_temp : std_logic;
signal osc_ena_out_temp : std_logic;

BEGIN

  clk_10mn <= not clk_10m;

  state_sel : process (clk_10mn, resetn)
  begin
    if resetn = '0' then
      state <= "1111";
    elsif rising_edge(clk_10mn) then
      state <= next_state;
    end if;
  end process state_sel;

  gen_pa_enas : process (clk_10m) -- , state, next_state
  begin
    if state = "1111" then -- idle
      pa_ena0 <= '0';
      pa_ena1 <= '0';
      pa_ena2 <= '0';
      pa_ena3 <= '0';
      pa_ena4 <= '0';
      if thisbit = '0' then
        next_state <= "1111";
      else
        next_state <= "0000";
      end if;
    elsif state = "0000" then -- 0
      pa_ena0 <= '1';
      pa_ena1 <= '0';
      pa_ena2 <= '0';
      pa_ena3 <= '0';
      pa_ena4 <= '0';
      next_state <= "0001";
    elsif state = "0001" then -- 1
      pa_ena0 <= '1';
      pa_ena1 <= '1';
      pa_ena2 <= '0';
      pa_ena3 <= '0';
      pa_ena4 <= '0';
      next_state <= "0010";
    elsif state = "0010" then -- 2
      pa_ena0 <= '1';
      pa_ena1 <= '1';
      pa_ena2 <= '1';
      pa_ena3 <= '0';
      pa_ena4 <= '0';
      next_state <= "0011";
    elsif state = "0011" then -- 3
      pa_ena0 <= '1';
      pa_ena1 <= '1';
      pa_ena2 <= '1';
      pa_ena3 <= '1';
      pa_ena4 <= '0';
      next_state <= "0100";
    elsif state = "0100" then -- 4
      pa_ena0 <= '1';
      pa_ena1 <= '1';
      pa_ena2 <= '1';
      pa_ena3 <= '1';
      pa_ena4 <= '1';
      next_state <= "0101";
    elsif state = "0101" then -- 5
      pa_ena0 <= '1';
      pa_ena1 <= '1';
      pa_ena2 <= '1';
      pa_ena3 <= '1';
      pa_ena4 <= '1';
      if nextbit = '0' then
        next_state <= "0110";
      else
        next_state <= "1110";
      end if;
    elsif state = "0110" then -- 6
      pa_ena0 <= '1';
      pa_ena1 <= '1';
      pa_ena2 <= '1';
      pa_ena3 <= '1';
      pa_ena4 <= '0';
      next_state <= "0111";
    elsif state = "0111" then -- 7
      pa_ena0 <= '1';
      pa_ena1 <= '1';
      pa_ena2 <= '1';
      pa_ena3 <= '0';
      pa_ena4 <= '0';
      next_state <= "1000";
    elsif state = "1000" then -- 8
      pa_ena0 <= '1';
      pa_ena1 <= '1';
      pa_ena2 <= '0';
      pa_ena3 <= '0';
      pa_ena4 <= '0';
      next_state <= "1001";
    elsif state = "1001" then -- 9
      pa_ena0 <= '1';
      pa_ena1 <= '0';
      pa_ena2 <= '0';
      pa_ena3 <= '0';
      pa_ena4 <= '0';
      next_state <= "1111";
    elsif state = "1110" then -- output hold state for multibit data. holds enable signals high.
      pa_ena0 <= '1';
      pa_ena1 <= '1';
      pa_ena2 <= '1';
      pa_ena3 <= '1';
      pa_ena4 <= '1';
      if thisbit = '1' and nextbit = '0' and clk = '0' then
        next_state <= "0101";
      else
        next_state <= "1110";
      end if;
    else -- others
      pa_ena0 <= '0';
      pa_ena1 <= '0';
      pa_ena2 <= '0';
      pa_ena3 <= '0';
      pa_ena4 <= '0';
      next_state <= "1111";
    end if;
  end process gen_pa_enas;


  -- TAPEOUT FIX / NAKU DEMO 3 / ND3
  -- 26.11.2018, 07.15
  -- pa_ena_out-signals were glitching
  -- so they need to be clocked DFFs
  with outselosc select
    osc_ena_out_temp <= pa_ena0 when "000",
                   pa_ena1 when "001",
                   pa_ena2 when "010",
                   pa_ena3 when "011",
                   pa_ena4 when "100",
                   '0' when "110",
                   '1' when "111",
                   pa_ena0 when others;

  with outsel0 select
    pa_ena_out0_temp <= pa_ena0 when "000",
                   pa_ena1 when "001",
                   pa_ena2 when "010",
                   pa_ena3 when "011",
                   pa_ena4 when "100",
                   '0' when "110",
                   '1' when "111",
                   pa_ena0 when others;

  with outsel1 select
    pa_ena_out1_temp <= pa_ena0 when "000",
                   pa_ena1 when "001",
                   pa_ena2 when "010",
                   pa_ena3 when "011",
                   pa_ena4 when "100",
                   '0' when "110",
                   '1' when "111",
                   pa_ena0 when others;

  with outsel2 select
    pa_ena_out2_temp <= pa_ena0 when "000",
                   pa_ena1 when "001",
                   pa_ena2 when "010",
                   pa_ena3 when "011",
                   pa_ena4 when "100",
                   '0' when "110",
                   '1' when "111",
                   pa_ena0 when others;

  with outsel3 select
    pa_ena_out3_temp <= pa_ena0 when "000",
                   pa_ena1 when "001",
                   pa_ena2 when "010",
                   pa_ena3 when "011",
                   pa_ena4 when "100",
                   '0' when "110",
                   '1' when "111",
                   pa_ena0 when others;

  with outsel4 select
    pa_ena_out4_temp <= pa_ena0 when "000",
                   pa_ena1 when "001",
                   pa_ena2 when "010",
                   pa_ena3 when "011",
                   pa_ena4 when "100",
                   '0' when "110",
                   '1' when "111",
                   pa_ena0 when others;

  with outsel5 select
    pa_ena_out5_temp <= pa_ena0 when "000",
                   pa_ena1 when "001",
                   pa_ena2 when "010",
                   pa_ena3 when "011",
                   pa_ena4 when "100",
                   '0' when "110",
                   '1' when "111",
                   pa_ena0 when others;

  with outsel6 select
    pa_ena_out6_temp <= pa_ena0 when "000",
                   pa_ena1 when "001",
                   pa_ena2 when "010",
                   pa_ena3 when "011",
                   pa_ena4 when "100",
                   '0' when "110",
                   '1' when "111",
                   pa_ena0 when others;

  gen_outputs : process (clk_10m, resetn)
  begin
    if resetn = '0' then
      osc_ena_out <= '0';
      pa_ena_out0 <= '0';
      pa_ena_out1 <= '0';
      pa_ena_out2 <= '0';
      pa_ena_out3 <= '0';
      pa_ena_out4 <= '0';
      pa_ena_out5 <= '0';
      pa_ena_out6 <= '0';
    elsif rising_edge(clk_10m) then
      osc_ena_out <= osc_ena_out_temp;
      pa_ena_out0 <= pa_ena_out0_temp;
      pa_ena_out1 <= pa_ena_out1_temp;
      pa_ena_out2 <= pa_ena_out2_temp;
      pa_ena_out3 <= pa_ena_out3_temp;
      pa_ena_out4 <= pa_ena_out4_temp;
      pa_ena_out5 <= pa_ena_out5_temp;
      pa_ena_out6 <= pa_ena_out6_temp;
    end if;
  end process;

--  with outsel0 select
--    pa_ena_out0 <= pa_ena0 when "000",
--                   pa_ena1 when "001",
--                   pa_ena2 when "010",
--                   pa_ena3 when "011",
--                   pa_ena4 when "100",
--                   '0' when "110",
--                   '1' when "111",
--                   pa_ena0 when others;
--
--  with outsel1 select
--    pa_ena_out1 <= pa_ena0 when "000",
--                   pa_ena1 when "001",
--                   pa_ena2 when "010",
--                   pa_ena3 when "011",
--                   pa_ena4 when "100",
--                   '0' when "110",
--                   '1' when "111",
--                   pa_ena0 when others;
--
--  with outsel2 select
--    pa_ena_out2 <= pa_ena0 when "000",
--                   pa_ena1 when "001",
--                   pa_ena2 when "010",
--                   pa_ena3 when "011",
--                   pa_ena4 when "100",
--                   '0' when "110",
--                   '1' when "111",
--                   pa_ena0 when others;
--
--  with outsel3 select
--    pa_ena_out3 <= pa_ena0 when "000",
--                   pa_ena1 when "001",
--                   pa_ena2 when "010",
--                   pa_ena3 when "011",
--                   pa_ena4 when "100",
--                   '0' when "110",
--                   '1' when "111",
--                   pa_ena0 when others;
--
--  with outsel4 select
--    pa_ena_out4 <= pa_ena0 when "000",
--                   pa_ena1 when "001",
--                   pa_ena2 when "010",
--                   pa_ena3 when "011",
--                   pa_ena4 when "100",
--                   '0' when "110",
--                   '1' when "111",
--                   pa_ena0 when others;
--
--  with outsel5 select
--    pa_ena_out5 <= pa_ena0 when "000",
--                   pa_ena1 when "001",
--                   pa_ena2 when "010",
--                   pa_ena3 when "011",
--                   pa_ena4 when "100",
--                   '0' when "110",
--                   '1' when "111",
--                   pa_ena0 when others;
--
END rtl;

