library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
  
entity coderP is
  port (
    clk         : in std_logic;
    clk_10m     : in std_logic;
    resetn      : in std_logic;

    outsel0     : in std_logic_vector(2 downto 0);
    outsel1     : in std_logic_vector(2 downto 0);
    outsel2     : in std_logic_vector(2 downto 0);
    outsel3     : in std_logic_vector(2 downto 0);
    outsel4     : in std_logic_vector(2 downto 0);
    outsel5     : in std_logic_vector(2 downto 0);
    outsel6     : in std_logic_vector(2 downto 0);
    outselosc   : in std_logic_vector(2 downto 0);

    -- DPPM-related signals
    word_in     : in std_logic_vector(5 downto 0);
    cntrstval   : in std_logic; -- must be '0' when DPPM running, '1' otherwise
    reqword     : out std_logic;
    resetn_nbtx_ctrlgen : in std_logic;
    
    -- OOK-related signals
    ena_ook     : in std_logic;
    thisbit_in  : in std_logic;
    nextbit_in  : in std_logic;

    -- NBTX v2 outputs
    pulse_trig  : out std_logic;
    tx_ena      : out std_logic;
    osc_ena     : out std_logic;
    pa_ena_out0 : out std_logic;
    pa_ena_out1 : out std_logic;
    pa_ena_out2 : out std_logic;
    pa_ena_out3 : out std_logic;
    pa_ena_out4 : out std_logic;
    pa_ena_out5 : out std_logic;
    pa_ena_out6 : out std_logic
    );
end coderP;


architecture rtl of coderP is

  signal clkn     : std_logic;
  signal cnt      : std_logic_vector(6 downto 0);
  signal cntn     : std_logic_vector(6 downto 0);
  signal maxcnt   : std_logic_vector(6 downto 0);
  --signal compres  : std_logic_vector(2 downto 0); -- result of comparison.
  --signal latout   : std_logic_vector(3 downto 0);
  --signal andout   : std_logic_vector(3 downto 0);
  signal max_reached  : std_logic; -- is 1 if count is equal to max input
  --signal s0, s1, s2, s3, t3 : std_logic;
  --signal moda, modb : std_logic;
  signal pulse_trig_sig : std_logic;
  signal pulse_trig_sig_delayed : std_logic;
  signal reqword_sig    : std_logic;
  signal max_reached_synced : std_logic;
  signal max_reached_synced_delayed : std_logic;
  --signal cntrstval     : std_logic; -- what value each counter DFF resets to
  --signal h0 : std_logic;
  signal resetn_counter : std_logic;
  signal cntrstval_internal : std_logic;
  signal tx_ena_sig : std_logic;

  --signal clk_to_ctrlgen : std_logic;
  --signal clk_10m_to_ctrlgen : std_logic;
  signal thisbit_to_ctrlgen   : std_logic;
  signal nextbit_to_ctrlgen   : std_logic;
  signal osc_ena_from_ctrlgen : std_logic;
  signal pa_ena_from_ctrlgen  : std_logic_vector(6 downto 0);

--  signal thisbit_int : std_logic;
--  signal nextbit_int : std_logic;

COMPONENT dfp_r IS
  PORT (
    d  : IN  STD_LOGIC;			-- data input
    c  : IN  STD_LOGIC;			-- clock input
    s  : in  std_logic;   -- default value at reset
    rn : IN  STD_LOGIC;			-- reset (active low)
    q  : OUT STD_LOGIC);		-- data output
END COMPONENT;

component nbtx_v2_ctrlgen IS
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
END component;

begin -- rtl
  
  clkn       <= not clk;
  --tx_ena_sig <= pulse_trig_sig;
  --cntrstval  <= not cntff_s;

--  thisbit_to_ctrlgen <= thisbit;
--  nextbit_to_ctrlgen <= nextbit;
  --thisbit_to_ctrlgen <= thisbit_int;
  --nextbit_to_ctrlgen <= nextbit_int;
  
  
  cntn(0)    <= not cnt(0);
  cntn(1)    <= not cnt(1);
  cntn(2)    <= not cnt(2);
  cntn(3)    <= not cnt(3);
  cntn(4)    <= not cnt(4);
  cntn(5)    <= not cnt(5);
  cntn(6)    <= not cnt(6);
  
  --cntrstval_internal <= '0';
  cntrstval_internal <= cntrstval;
  
--  process (clk, resetn)
--    begin
--      if resetn = '0' then
--        cnt <= (others => '0');
--      else
--        if rising_edge(clk) then
--          cnt <= cnt + 1;
--        end if;
--      end if;
--    end process;
  
  ff0 : dfp_r
  port map (
    d   => cntn(0),
    c   => clk,
    s   => cntrstval_internal,
    rn  => resetn_counter,
    q   => cnt(0));
  
  ff1 : dfp_r
  port map (
    d   => cntn(1),
    c   => cntn(0),
    s   => cntrstval_internal,
    rn  => resetn_counter,
    q   => cnt(1));

  ff2 : dfp_r
  port map (
    d   => cntn(2),
    c   => cntn(1),
    s   => cntrstval_internal,
    rn  => resetn_counter,
    q   => cnt(2));

  ff3 : dfp_r
  port map (
    d   => cntn(3),
    c   => cntn(2),
    s   => cntrstval_internal,
    rn  => resetn_counter,
    q   => cnt(3));

  ff4 : dfp_r
  port map (
    d   => cntn(4),
    c   => cntn(3),
    s   => cntrstval_internal,
    rn  => resetn_counter,
    q   => cnt(4));

  ff5 : dfp_r
  port map (
    d   => cntn(5),
    c   => cntn(4),
    s   => cntrstval_internal,
    rn  => resetn_counter,
    q   => cnt(5));

  ff6 : dfp_r
  port map (
    d   => cntn(6),
    c   => cntn(5),
    s   => cntrstval_internal,
    rn  => resetn_counter,
    q   => cnt(6));

  ff_maxreach : dfp_r
  port map (
    d => max_reached,
    c => clkn,
    s => '0',
    rn => resetn,
    q => max_reached_synced);

  ff_maxreach2 : dfp_r
  port map (
    d => max_reached_synced,
    c => clk,
    s => '0',
    rn => resetn,
    q => max_reached_synced_delayed);

  --cntout <= cnt;

  maxcnt <= std_logic_vector(unsigned(word_in) + to_unsigned(1, 7));
  max_reached <= (cntn(0) xor maxcnt(0)) and (cntn(1) xor maxcnt(1)) and (cntn(2) xor maxcnt(2)) and (cntn(3) xor maxcnt(3)) and (cntn(4) xor maxcnt(4)) and (cntn(5) xor maxcnt(5)) and (cntn(6) xor maxcnt(6));
  
  
  --s0 <= max_reached and (not s1);
  --t3 <= clkn and (max_reached or s3);
  --t3 <= clkn and max_reached;
  
--  ffout1 : dfp_r
--  port map (
--    d   => s0,
--    c   => clkn,
--    s   => '0',
--    rn  => resetn,
--    q   => s1);
--
--  ffout2 : dfp_r
--  port map (
--    d   => s1,
--    c   => clk,
--    s   => '0',
--    rn  => resetn,
--    q   => s2);
--
--  ffout3 : dfp_r
--  port map (
--    d   => s2,
--    c   => t3,
--    s   => '0',
--    rn  => resetn,
--    q   => s3);
  
--  moda <= s1 and (not s2);
--  modb <= s2 and s3;
  
  generate_pulse_trig : process (resetn, cnt, clk)
  begin
    if resetn = '0' then
      pulse_trig_sig <= '0';
    else
      if falling_edge(clk) then
        if cnt = "0000000" then
          pulse_trig_sig <= '1';
        else
          pulse_trig_sig <= '0';
        end if;
      end if;
    end if;
  end process;
  
  ff_ptrigdel : dfp_r
  port map (
    d => pulse_trig_sig,
    c => clk,
    s => '0',
    rn => resetn,
    q => pulse_trig_sig_delayed);
  
--  pulse_trig_sig  <= max_reached_synced;
--  reqword_sig     <= not(moda or modb);
--  reqword_sig <= max_reached_synced and max_reached_synced_delayed;
  reqword_sig <= pulse_trig_sig and pulse_trig_sig_delayed;
  
  pulse_trig      <= pulse_trig_sig;
  reqword         <= reqword_sig; --pulse_trig_sig;
  --reqword <= cntn(5);
  --reqword <= imptrig_sig;

--  DPPM related blocks
--  dff_h0 : dfp_r
--  port map (
--    d => max_reached,
--    c => clkn,
--    s => '0',
--    rn => resetn,
--    q => h0);
  
--  dff_h0_delayed : dfp_r
--  port map (
--    d => h0,
--    c => clkn,
--    s => '0',
--    rn => resetn,
--    q => h0_delayed);

--  dff_rescnt : dfp_r
--  port map (
--    d => max_reached,
--    c => clk,
--    s => '0',
--    rn => resetn,
--    q => h0);

  resetn_counter <= not(max_reached_synced and max_reached_synced_delayed) and resetn;
  tx_ena <= tx_ena_sig;

  --resetn_counter <= not((not resetn) or h0);
  --resetn_counter <= not(max_reached_synced and max_reached_synced_delayed);
  
  the_ctrlgen : nbtx_v2_ctrlgen
  port map (
    clk           => clk,     --clk_to_ctrlgen,
    clk_10m       => clk_10m,  --clk_10mhz_to_ctrlgen,
    thisbit       => thisbit_to_ctrlgen,
    nextbit       => nextbit_to_ctrlgen,
    resetn        => resetn_nbtx_ctrlgen,
    outsel0       => outsel0,
    outsel1       => outsel1,
    outsel2       => outsel2,
    outsel3       => outsel3,
    outsel4       => outsel4,
    outsel5       => outsel5,
    outsel6       => outsel6,
    outselosc     => outselosc,

    osc_ena_out   => osc_ena_from_ctrlgen,
    pa_ena_out6   => pa_ena_from_ctrlgen(6),
    pa_ena_out5   => pa_ena_from_ctrlgen(5),
    pa_ena_out4   => pa_ena_from_ctrlgen(4),
    pa_ena_out3   => pa_ena_from_ctrlgen(3),
    pa_ena_out2   => pa_ena_from_ctrlgen(2),
    pa_ena_out1   => pa_ena_from_ctrlgen(1),
    pa_ena_out0   => pa_ena_from_ctrlgen(0)
  );

  osc_ena     <= osc_ena_from_ctrlgen;
  pa_ena_out6 <= pa_ena_from_ctrlgen(6);
  pa_ena_out5 <= pa_ena_from_ctrlgen(5);
  pa_ena_out4 <= pa_ena_from_ctrlgen(4);
  pa_ena_out3 <= pa_ena_from_ctrlgen(3);
  pa_ena_out2 <= pa_ena_from_ctrlgen(2);
  pa_ena_out1 <= pa_ena_from_ctrlgen(1);
  pa_ena_out0 <= pa_ena_from_ctrlgen(0);

  with ena_ook select
    thisbit_to_ctrlgen <= pulse_trig_sig when '0',
                          thisbit_in when others;

  with ena_ook select
    nextbit_to_ctrlgen <= '0' when '0',
                          nextbit_in when others;

end; -- rtl
