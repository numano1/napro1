library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use napro1_addr_pkg_v2.all;

entity napro1 is
  port (
    ss              : in std_logic;
    sck             : in std_logic;
    mosi            : in std_logic;
    miso            : out std_logic;
    resetn          : in std_logic;

    clk_gest        : in std_logic;
    gest1_in        : in std_logic_vector(15 downto 0);
    gest2_in        : in std_logic_vector(15 downto 0);

    clk_10m         : in std_logic;
    outselosc       : out std_logic_vector(2 downto 0);
    pa_outsel       : out std_logic_vector(20 downto 0);
    --clk_in          : in std_logic;

    reqword_ppm     : in std_logic;
    reqword_dppm    : in std_logic;
    reqword_out     : out std_logic; -- reqword only for testbenching
    
    clk_ook         : out std_logic;
    ena_ook_out     : out std_logic;
    data_ook        : out std_logic;
    data_ook_next   : out std_logic;
    resetn_ook      : out std_logic;
    
    tx_word_out     : out std_logic_vector(5 downto 0);

    clk_ppm         : out std_logic;
    resetn_ppm      : out std_logic;

    clk_dppm        : out std_logic;
    resetn_dppm     : out std_logic;
    dppm_cntrstval  : out std_logic;
    resetn_nbtx_ctrlgen  : out std_logic;

    clk_1m_to_coder : out std_logic;
    clk_10m_to_coder : out std_logic;

    trim_bits       : out std_logic_vector(63 downto 0);
    tunefreq_coarce : out std_logic_vector(2 downto 0);
    tunefreq_med    : out std_logic_vector(3 downto 0);
    tunefreq_fine_p : out std_logic_vector(5 downto 0);
    tunefreq_fine_n : out std_logic_vector(5 downto 0)
    );
end napro1;

architecture rtl of napro1 is

component napro1_spi_interface is
  port (
    ss               : in std_logic;
    sck              : in std_logic;
    mosi             : in std_logic;
    miso             : out std_logic;
    resetn           : in std_logic;
    porst_in         : in std_logic;
    byte_from_reg    : in std_logic_vector(7 downto 0);
    byte_to_reg      : out std_logic_vector(7 downto 0);
    addr_to_reg      : out std_logic_vector(5 downto 0);
    write_word       : out std_logic;
    idx_out          : out std_logic_vector(5 downto 0);
    write            : out std_logic);
end component;

component mem_reg_napro1 is
  port (
    write_reg        : in  std_logic;
    addr_in          : in  std_logic_vector(5 downto 0);
    byte_in          : in  std_logic_vector(7 downto 0);
    resetn           : in  std_logic;
    porst_out        : out std_logic;
    byte_out         : out std_logic_vector(7 downto 0);
    ctrl             : out std_logic_vector(7 downto 0);
    nbtx_ctrl        : out std_logic_vector(7 downto 0);
    trigs            : out std_logic_vector(7 downto 0);
    resets           : out std_logic_vector(7 downto 0);
    idxmax_ook       : out std_logic_vector(5 downto 0);
    idxmax           : out std_logic_vector(5 downto 0);
    word_to_write    : out std_logic_vector(5 downto 0);
    idx_to_write     : out std_logic_vector(5 downto 0);
    idx_to_read      : out std_logic_vector(5 downto 0);
    word_to_read     : in  std_logic_vector(5 downto 0);
    outselosc        : out std_logic_vector(2 downto 0);
    pa_outsel        : out std_logic_vector(20 downto 0);
    trim_bits        : out std_logic_vector(63 downto 0);
    tunefreq_coarce_med : out std_logic_vector(6 downto 0);
    tunefreq_fine_p     : out std_logic_vector(5 downto 0);
    tunefreq_fine_n     : out std_logic_vector(5 downto 0)
    );
end component;

-- ND3: changed to word_reg_with_gest
--component word_reg is
--  port (
--    write_word        : in  std_logic;
--    idx_write         : in  std_logic_vector(5 downto 0);
--    word_in           : in  std_logic_vector(5 downto 0);
--    resetn            : in  std_logic;
--    idx_to_tx         : in  std_logic_vector(5 downto 0);
--    idx_to_read       : in  std_logic_vector(5 downto 0);
--    word_to_tx        : out std_logic_vector(5 downto 0);
--    first_word        : out std_logic_vector(5 downto 0);
--    word_to_mem       : out std_logic_vector(5 downto 0);
--    bits_to_ook       : out std_logic_vector(47 downto 0)
--    );
--end component;

component word_reg_with_gest is
  port (
    write_word        : in  std_logic;
    idx_write         : in  std_logic_vector(5 downto 0);
    word_in           : in  std_logic_vector(5 downto 0);
    resetn            : in  std_logic;
    idx_to_tx         : in  std_logic_vector(5 downto 0);
    idx_to_read       : in  std_logic_vector(5 downto 0);
    ena_gest          : in  std_logic;
    ena_dppm          : in  std_logic;
    b_dppm            : in  std_logic_vector(2 downto 0);
    gest1_in          : in  std_logic_vector(15 downto 0);
    gest2_in          : in  std_logic_vector(15 downto 0);
    word_to_tx        : out std_logic_vector(5 downto 0);
    first_word        : out std_logic_vector(5 downto 0);
    word_to_mem       : out std_logic_vector(5 downto 0);
    bits_to_ook       : out std_logic_vector(47 downto 0)
    );
end component;

component clkdiv10 is
  port (
    c     : in std_logic;
    rn    : in std_logic;
    c_out : out std_logic
  );
end component;


component mux2 is
  port (
    input0   : in  std_logic;
    input1   : in  std_logic;
    selector : in  std_logic;
    output   : out std_logic);
end component;

component dff_r is
  PORT (
    d  : IN  STD_LOGIC;			-- data input
    c  : IN  STD_LOGIC;			-- clock input
    rn : IN  STD_LOGIC;			-- reset (active low)
    q  : OUT STD_LOGIC);		-- data output
end component;

component dfp_r IS
  PORT (
    d  : IN  STD_LOGIC;			-- data input
    c  : IN  STD_LOGIC;			-- clock input
    s  : IN  STD_LOGIC;   -- default value at reset
    rn : IN  STD_LOGIC;			-- reset (active low)
    q  : OUT STD_LOGIC);		-- data output
END component;


  signal ssn              : std_logic;
  signal spi_byte_out     : std_logic_vector(7 downto 0);
  signal spi_addr_out     : std_logic_vector(5 downto 0);
  signal spi_write_out    : std_logic;
  signal mem_byte_out     : std_logic_vector(7 downto 0);
  signal spi_write_word_out : std_logic;

  signal porst            : std_logic;
  --signal pdow             : std_logic;

  signal clk_1m : std_logic;
  --signal clk_in  : std_logic;
  signal clk_1mn : std_logic;  
  
  
  --signal coder_done       : std_logic;
  --signal coder_done_delayed : std_logic;
  --signal coder_done_delayed2 : std_logic;
  --signal coder_done_rstn  : std_logic;
  signal ctrl_reg         : std_logic_vector(7 downto 0);
  signal trigs_from_mem   : std_logic_vector(7 downto 0);
  signal resets_from_mem  : std_logic_vector(7 downto 0);
  signal resetn_to_idxcnt : std_logic;
  signal resetn_to_idxcnt_synced : std_logic;
  
  signal reqword          : std_logic;
  signal reqwordn         : std_logic;
  signal idxcnt           : std_logic_vector(5 downto 0);
  signal idxmax_ook       : std_logic_vector(5 downto 0);
  signal idxmax           : std_logic_vector(5 downto 0);
  --signal idx_to_write     : std_logic_vector(5 downto 0);
  --signal word_to_write    : std_logic_vector(5 downto 0);
  signal idxmax_reached         : std_logic;
  signal idxmax_reached_synced  : std_logic;

  signal ena_ook              : std_logic;  
  signal run_ook_sig          : std_logic;
  signal clk_ook_sig          : std_logic;
  signal clk_ook_sign         : std_logic;
  signal resetn_ook_sig       : std_logic;

  signal idxmax_ook_reached   : std_logic;
  signal gate_clk_ook_nonsync : std_logic;
  signal resetn_gate_clk_ook  : std_logic;
  signal gate_clk_ook_synced  : std_logic;
--  signal gate_clk_ook_synced_del1 : std_logic;
--  signal gate_clk_ook_synced_del2 : std_logic;
--  signal ook_selfrst              : std_logic;
  
  signal ena_ppm              : std_logic;  
  signal run_ppm_sig          : std_logic;
  signal clkcnt_ppm           : std_logic_vector(5 downto 0);
  signal clk_ppm_sig          : std_logic;
  signal clk_ppm_sign         : std_logic;
  signal resetn_ppm_sig       : std_logic;

  signal ena_dppm             : std_logic;  
  signal run_dppm_sig         : std_logic;
  signal run_dppm_sign        : std_logic;
  --signal clkcnt_dppm          : std_logic_vector(5 downto 0);
  signal clk_dppm_sig         : std_logic;
  signal clk_dppm_sign        : std_logic;
  signal resetn_dppm_sig      : std_logic;
  signal resetn_nbtx_ctrlgen_sig : std_logic;
  signal reqword_dppmn        : std_logic;
  signal dppm_cntrstval_delayed1 : std_logic;
  signal dppm_cntrstval_delayed2 : std_logic;
  signal dppm_cntrstval_delayed3 : std_logic;

  signal ena_gest_to_tx       : std_logic;


  signal resetn_gate_clk_ppm          : std_logic;
  signal gate_clk_ppm_nonsync         : std_logic;
  signal gate_clk_ppm_synced          : std_logic;
  --signal gate_clk_ppm_synced_delayed  : std_logic;
  --signal gate_clk_ppm_synced_delayed2 : std_logic;

  signal resetn_gate_clk_dppm   : std_logic;
  signal gate_clk_dppm_nonsync  : std_logic;
  signal gate_clk_dppm_synced   : std_logic;
  --signal gate_clk_dppm_synced_delayed  : std_logic;
  --signal gate_clk_dppm_synced_delayed2 : std_logic;
  
  signal resetn_tx_procedure          : std_logic;
  
  signal ena_tx_continuous    : std_logic;
  signal bits_to_ook          : std_logic_vector(47 downto 0);
  signal trim_bits_ana        : std_logic_vector(63 downto 0);
  signal tx_trig_from_mem     : std_logic;
  signal tx_trig_from_mem_mid : std_logic;
  signal tx_trig_synced       : std_logic;
  signal tx_trig_synced_delayed1 : std_logic;
  signal tx_trig_synced_delayed2 : std_logic;
  signal ena_clk_to_coder     : std_logic;

  signal data_ook_sig           : std_logic;
  signal data_ook_next_sig      : std_logic;
  signal bitcnt                 : std_logic_vector(5 downto 0);
  signal data_vec_ook           : std_logic_vector(47 downto 0);
  
  signal write_word             : std_logic;
  signal word_to_write_from_mem : std_logic_vector(5 downto 0);
  signal idx_to_write_from_mem  : std_logic_vector(5 downto 0);
  signal idx_to_read_from_mem   : std_logic_vector(5 downto 0);
  signal idx_from_spi           : std_logic_vector(5 downto 0);
  signal word_from_word_reg     : std_logic_vector(5 downto 0);

  --signal idx_to_read    : std_logic_vector(5 downto 0);
  signal word_to_tx_from_word_reg     : std_logic_vector(5 downto 0);
  signal first_word_from_word_reg     : std_logic_vector(5 downto 0);
  signal tx_word_out_reg              : std_logic_vector(5 downto 0); -- DEADLINE FIX: register added to provide tx_word_out faster at rising edge of reqword
  signal word_to_read_from_word_reg   : std_logic_vector(5 downto 0);

  signal outselosc_from_mem           : std_logic_vector(2 downto 0);
  signal pa_outsel_sig                : std_logic_vector(20 downto 0);
  signal tunefreq_coarce_med_from_mem : std_logic_vector(6 downto 0);
  signal tunefreq_fine_p_from_mem     : std_logic_vector(5 downto 0);
  signal tunefreq_fine_n_from_mem     : std_logic_vector(5 downto 0);

  signal clk_1m_to_coder_not_gated    : std_logic;
  signal clk_10m_to_coder_not_gated   : std_logic;

  signal gest1_trigged : std_logic_vector(15 downto 0);
  signal gest2_trigged : std_logic_vector(15 downto 0);
  signal nbtx_ctrl_reg : std_logic_vector(7 downto 0);
  signal ena_gest      : std_logic;
  signal b_dppm        : std_logic_vector(2 downto 0);

begin --rtl

  ssn                       <= not ss;
  reqwordn                  <= not reqword;
  clk_1mn                   <= not clk_1m;
  clk_ook_sign              <= not clk_ook_sig;
  clk_ppm_sign              <= not clk_ppm_sig;
  clk_dppm_sign             <= not clk_dppm_sig;
  ena_ook                   <= ctrl_reg(ENA_OOK_BIT);
  ena_ppm                   <= ctrl_reg(ENA_PPM_BIT);
  ena_dppm                  <= ctrl_reg(ENA_DPPM_BIT);
  ena_tx_continuous         <= ctrl_reg(ENA_TX_CONTINUOUS_BIT);
  ena_clk_to_coder          <= ctrl_reg(ENA_CLK_TO_CODER_BIT);
  ena_gest_to_tx            <= ctrl_reg(ENA_GEST_TO_TX_BIT);
  ena_gest                  <= nbtx_ctrl_reg(NBTX_ENA_GEST_BIT);
  b_dppm                    <= nbtx_ctrl_reg(NBTX_B_DPPM_2_BIT downto NBTX_B_DPPM_2_BIT-2);
  tx_trig_from_mem          <= trigs_from_mem(TX_TRIG_BIT);
  write_word                <= trigs_from_mem(IDX_WRITE_TRIG_BIT);
  reqword_dppmn             <= not reqword_dppm;

  -- ND3
  ena_ook_out <= ena_ook;

  --reqword                   <= reqword_ppm or (reqword_dppm and run_dppm_sig);
  reqmux : mux2
  port map (
    input0    => reqword_ppm,
    input1    => reqword_dppm,
    selector  => ena_dppm,
    output    => reqword);
  
  reqword_out <= reqword;
  
  the_interface : napro1_spi_interface
    port map (
      sck              => sck,
      mosi             => mosi,
      miso             => miso,
      ss               => ss,
      resetn           => resetn,
      porst_in         => porst,
      byte_from_reg    => mem_byte_out,
      byte_to_reg      => spi_byte_out,
      addr_to_reg      => spi_addr_out,
      write_word       => spi_write_word_out,
      idx_out          => idx_from_spi,
      write            => spi_write_out);
    
  memory_register : mem_reg_napro1
    port map (
      write_reg         => spi_write_out,
      addr_in           => spi_addr_out,
      byte_in           => spi_byte_out,
      resetn            => resetn,
      porst_out         => porst,
      byte_out          => mem_byte_out,
      ctrl              => ctrl_reg,
      nbtx_ctrl         => nbtx_ctrl_reg,
      trigs             => trigs_from_mem,
      resets            => resets_from_mem,
      --ena_tx_continuous => ena_tx_continuous,
      idxmax_ook        => idxmax_ook,
      idxmax            => idxmax,
      word_to_write     => word_to_write_from_mem,
      idx_to_write      => idx_to_write_from_mem,
      idx_to_read       => idx_to_read_from_mem,
      word_to_read      => word_to_read_from_word_reg,
      outselosc         => outselosc_from_mem,
      pa_outsel         => pa_outsel_sig,
      trim_bits         => trim_bits_ana,
      tunefreq_coarce_med => tunefreq_coarce_med_from_mem,
      tunefreq_fine_p     => tunefreq_fine_p_from_mem,
      tunefreq_fine_n     => tunefreq_fine_n_from_mem
      );

-- ND3: word_reg_with_gest
  word_register : word_reg_with_gest
    port map (
      write_word => spi_write_word_out,
      idx_write  => idx_from_spi,
      word_in    => word_to_write_from_mem,
      resetn     => resetn,
      idx_to_tx   => idxcnt,
      idx_to_read => idx_to_read_from_mem,
      ena_gest    => ena_gest,
      gest1_in    => gest1_trigged,
      gest2_in    => gest2_trigged,
      ena_dppm    => ena_dppm,
      b_dppm      => b_dppm,
      word_to_tx  => word_to_tx_from_word_reg,
      first_word  => first_word_from_word_reg,
      word_to_mem => word_to_read_from_word_reg,
      bits_to_ook => bits_to_ook);


  trig_gests : process (resetn, gest1_in, gest2_in, clk_gest)
  begin
    if resetn = '0' then
      gest1_trigged <= (others => '0');
      gest2_trigged <= (others => '0');
    elsif falling_edge(clk_gest) then
      gest1_trigged <= gest1_in;
      gest2_trigged <= gest2_in;
    end if;
  end process trig_gests;

  count_idxcnt : process (resetn_to_idxcnt_synced, reqwordn) -- DEADLINE FIX: idxmax used to switch at rising edge of reqword. resetn_to_idxcnt was used instead of the synced one.
  begin
    if resetn_to_idxcnt_synced = '0' then
      if ena_dppm = '1' then
        idxcnt <= "000000";
      else
        idxcnt <= "000000"; -- DEADLINE FIX: was 111111 before
      end if;
    else
      if rising_edge(reqwordn) then -- DEADLINE FIX: idxmax used to switch at rising edge of reqword
        if idxmax_reached = '0' then
          idxcnt <= std_logic_vector(unsigned(idxcnt) + "000001");
        end if;
      end if;
    end if;
  end process;

  count_ppm_clk_edges : process (resetn, run_ppm_sig, clk_ppm_sig)
  begin
    if resetn = '0' or run_ppm_sig = '0' then
      clkcnt_ppm <= (others => '1');-- std_logic_vector(to_unsigned(47,6));
    else
      if rising_edge(clk_ppm_sig) then
        clkcnt_ppm <= std_logic_vector(unsigned(clkcnt_ppm) + "000001");
      end if;
    end if;
  end process;
  
  set_data_vec_ook : process (resetn, run_ook_sig)
  begin
    if resetn = '0' then
      data_vec_ook <= bits_to_ook(47 downto 0);
    else
      if rising_edge(run_ook_sig) then
        data_vec_ook <= bits_to_ook(47 downto 0);
      end if;
    end if;
  end process;

  -- DEADLINE FIX 
  set_data_ook : process (resetn, run_ook_sig, clk_ook_sig) -- run_ook_sig, 
  begin
    if resetn = '0' or run_ook_sig = '0' then -- ND3: pakotetaan data_ook_sig nollaan my\F6s kun run_ook_sig = 0
      data_ook_sig <= '0'; -- ND3: Oli aiemmin '1' -- DEADLINE FIX: was set to data_vec_ook(0) at reset
    else
      if rising_edge(clk_ook_sig) then
        data_ook_sig <= data_vec_ook(to_integer(unsigned(bitcnt)));
      end if;
    end if;
  end process;

  -- ND3
  set_data_ook_next : process (resetn, run_ook_sig, clk_ook_sig) -- run_ook_sig, 
  begin
    if resetn = '0' or run_ook_sig = '0' then -- ND3: pakotetaan data_ook_sig nollaan myF6s kun run_ook_sig = 0
      data_ook_next_sig <= '0'; -- DEADLINE FIX: was set to data_vec_ook(0) at reset
    else
      if rising_edge(clk_ook_sig) then
        -- ND3: nextbit index needs to go back to 0 when idxmax_ook or 47 is reached
        if to_integer(unsigned(bitcnt)) >= 47 then
          data_ook_next_sig <= data_vec_ook(0); -- ND3 test: meneeko rikki jos laittaa arvon '1' tassa data_vec_ook(0);
        else
          data_ook_next_sig <= data_vec_ook(to_integer(unsigned(bitcnt)) + 1);
        end if;
      end if;
    end if;
  end process;

  count_ook_bits : process (resetn, clk_ook_sig, run_ook_sig)
  begin
    if resetn = '0' or run_ook_sig = '0' then
      bitcnt  <= std_logic_vector(to_unsigned(0, 6));
    else
      if falling_edge(clk_ook_sig) then
        if to_integer(unsigned(bitcnt)) < 47 then
          bitcnt <= std_logic_vector(unsigned(bitcnt) + to_unsigned(1, 6));
        else
          bitcnt <= (others => '0');
        end if;
      end if;
    end if;
  end process;



  --
  -- LOGIC FOR GATING CLK_OOK
  --
  idxmax_ook_reached <= (not ena_tx_continuous) and (idxmax_ook(0) xnor bitcnt(0)) and (idxmax_ook(1) xnor bitcnt(1)) and (idxmax_ook(2) xnor bitcnt(2)) and (idxmax_ook(3) xnor bitcnt(3)) and (idxmax_ook(4) xnor bitcnt(4)) and (idxmax_ook(5) xnor bitcnt(5));
  gate_clk_ook_nonsync <= idxmax_ook_reached; -- and (clkcnt_ppm(0) and '1') and (clkcnt_ppm(1) and '1') and (clkcnt_ppm(2) and '1') and (clkcnt_ppm(3) and '1') and (clkcnt_ppm(4) and '1') and (clkcnt_ppm(5) and '1');

  gateclkook_ff : dff_r
  port map (
    d => gate_clk_ook_nonsync,
    c => clk_ook_sign,
    rn => resetn_gate_clk_ook,
    q => gate_clk_ook_synced);
    
  resetn_gate_clk_ook <= not(not(resetn) or not(resetn_tx_procedure));
  
  

  --
  -- LOGIC FOR SELF-RESETTING OOK BLOCK
  --
--  ook_selfrst_ff0 : dff_r
--  port map (
--    d => gate_clk_ook_synced,
--    c => clk_1m,
--    rn => resetn_gate_clk_ook,
--    q => gate_clk_ook_synced_del1);
--    
--  ook_selfrst_ff1 : dff_r
--  port map (
--    d => gate_clk_ook_synced_del1,
--    c => clk_1mn,
--    rn => resetn_gate_clk_ook,
--    q => gate_clk_ook_synced_del2);
--
--  ook_selfrst <= gate_clk_ook_synced_del1 and (not gate_clk_ook_synced_del2);
  
  --
  -- LOGIC FOR GATING CLK_PPM
  --
  idxmax_reached <= (not ena_tx_continuous) and (idxmax(0) xnor idxcnt(0)) and (idxmax(1) xnor idxcnt(1)) and (idxmax(2) xnor idxcnt(2)) and (idxmax(3) xnor idxcnt(3)) and (idxmax(4) xnor idxcnt(4)) and (idxmax(5) xnor idxcnt(5));

  idxmaxreg : dff_r
  port map (
    d   => idxmax_reached,
    c   => reqword,
    rn  => resetn_tx_procedure,
    q   =>  idxmax_reached_synced);

  -- DEADLINE FIX: removes the ones ('1') from the logic of gate_clk_ppm_nonsync
  --gate_clk_ppm_nonsync <= idxmax_reached_synced and (clkcnt_ppm(0) and '1') and (clkcnt_ppm(1) and '1') and (clkcnt_ppm(2) and '1') and (clkcnt_ppm(3) and '1') and (clkcnt_ppm(4) and '1') and (clkcnt_ppm(5) and '1');
  gate_clk_ppm_nonsync <= idxmax_reached_synced and clkcnt_ppm(0) and clkcnt_ppm(1) and clkcnt_ppm(2)and clkcnt_ppm(3) and clkcnt_ppm(4) and clkcnt_ppm(5);

  gateclkppm_ff : dff_r
  port map (
    d => gate_clk_ppm_nonsync,
    c => clk_ppm_sign,
    rn => resetn_gate_clk_ppm,
    q => gate_clk_ppm_synced);
    
  resetn_gate_clk_ppm <= not(not(resetn) or not(resetn_tx_procedure));
  
  
  
  --
  -- LOGIC FOR GATING CLK_DPPM
  --
--  gate_clk_dppm_nonsync <= idxmax_reached and (clkcnt_ppm(0) and word_to_tx_from_word_reg(0)) and (clkcnt_ppm(1) and word_to_tx_from_word_reg(1)) and (clkcnt_ppm(2) and word_to_tx_from_word_reg(2)) and (clkcnt_ppm(3) and word_to_tx_from_word_reg(3)) and (clkcnt_ppm(4) and word_to_tx_from_word_reg(4)) and (clkcnt_ppm(5) and word_to_tx_from_word_reg(5));
--
--  gateclkdppm_ff : dff_r
--  port map (
--    d => gate_clk_dppm_nonsync,
--    c => clk_dppm_sign,
--    rn => resetn_gate_clk_dppm,
--    q => gate_clk_dppm_synced);
    
  gate_clk_dppm_nonsync <= idxmax_reached and not ena_tx_continuous;
  
  gateclkdppm_ff : dff_r
  port map (
    d =>  gate_clk_dppm_nonsync,
    c =>  reqword_dppmn,
    rn => resetn_gate_clk_dppm,
    q =>  gate_clk_dppm_synced);
    
  resetn_gate_clk_dppm <= not(not(resetn) or not(resetn_tx_procedure));
  
  
  
  --
  -- Synchronizer for TX_TRIG
  --
  txtrigsync_ff0 : dff_r
  port map (
    d => tx_trig_from_mem,
    c => clk_1mn,
    rn => resetn,
    q => tx_trig_from_mem_mid);
    
  txtrigsync_ff1 : dff_r
  port map (
    d => tx_trig_from_mem_mid,
    c => clk_1mn,
    rn => resetn,
    q => tx_trig_synced);

  txtrigsync_ff2 : dff_r
  port map (
    d => tx_trig_synced,
    c => clk_1mn,
    rn => resetn,
    q => tx_trig_synced_delayed1);

  txtrigsync_ff3 : dff_r
  port map (
    d => tx_trig_synced_delayed1,
    c => clk_1mn,
    rn => resetn,
    q => tx_trig_synced_delayed2);

  resetn_tx_procedure  <= not((not tx_trig_synced_delayed1) and tx_trig_synced_delayed2);

  --
  -- Solve when coder has finished
  --
--  coderdone_ff : dff_r
--  port map (
--    d => idxmax_reached,
--    c => reqword,
--    rn => coder_done_rstn,
--    q => coder_done);
--    
--  coderdone_delay1_ff : dff_r
--  port map (
--    d => coder_done,
--    c => clk_1mn,
--    rn => resetn,
--    q => coder_done_delayed);
--
--  coderdone_delay2_ff : dff_r
--  port map (
--    d => coder_done_delayed,
--    c => clk_1m,
--    rn => resetn,
--    q => coder_done_delayed2);

  --resetn_to_idxcnt <= resetn and not (coder_done_delayed and not coder_done_delayed2);
  resetn_to_idxcnt <= resetn and resetn_tx_procedure and resetn_ook_sig and resetn_ppm_sig and resetn_dppm_sig;

  resetn_to_idxcnt_reg : dff_r
  port map (
  d => resetn_to_idxcnt,
  c => clk_1m,
  rn => resetn,
  q => resetn_to_idxcnt_synced);
  

--  coder_done_rstn <= tx_trig_synced;
  
  run_ook_sig <= ena_ook and tx_trig_synced;
  clk_ook_sig <= run_ook_sig and clk_1m and (not gate_clk_ook_synced);

  with ena_ook select
  clk_ook     <= clk_ook_sig when '1',
                 '1' when others;
  
  

  run_ppm_sig <= ena_ppm and tx_trig_synced; -- and (not coder_done);
  clk_ppm_sig <= run_ppm_sig and clk_1m and (not gate_clk_ppm_synced);
  --clk_ppm       <= clk_ppm_sig and ena_ppm;

  with ena_ppm select
  clk_ppm <= clk_ppm_sig when '1',
             '1' when others;


  run_dppm_sig <= ena_dppm and tx_trig_synced; -- and (not coder_done);
  clk_dppm_sig <= run_dppm_sig and clk_1m and (not gate_clk_dppm_synced);
  --clk_dppm      <= clk_dppm_sig and ena_dppm;
  
  with ena_dppm select
  clk_dppm <= clk_dppm_sig when '1',
              '1' when others;

  --dppm_cntrstval <= not run_dppm_sig;
  run_dppm_sign <= not run_dppm_sig;

  --dppm_cntrstval_nonsynced <= run_dppm_sign;

  cntrstval_delay_ff : dfp_r
  port map (
    d   => run_dppm_sign,
    c   => clk_1m,
    s   => '0',
    rn  => resetn,
    q   => dppm_cntrstval_delayed1);

  cntrstval_delay_ff2 : dfp_r
  port map (
    d   => dppm_cntrstval_delayed1,
    c   => clk_1m,
    s   => '0',
    rn  => resetn,
    q   => dppm_cntrstval_delayed2);

  cntrstval_delay_ff3 : dfp_r
  port map (
    d   => dppm_cntrstval_delayed2,
    c   => clk_1m,
    s   => '0',
    rn  => resetn,
    q   => dppm_cntrstval_delayed3);

  cntrstvalreg_ff : dfp_r
  port map (
    d   => dppm_cntrstval_delayed3,
    c   => clk_1m,
    s   => '0',
    rn  => resetn,
    q   => dppm_cntrstval);

  the_clkdiv : clkdiv10
  port map (
    c   => clk_10m,
    rn  => resetn,
    c_out => clk_1m);

  --dppm_cntrstval <= '0';
  --dppm_cntrstval <= '1';


  -- DEADLINE FIX: process for triggering word_to_tx_from_word_reg to a register at rising edge of reqword
  -- DEADLINE FIX: resetn_to_idxcnt was used instead of the synced one
  update_tx_word_out : process (resetn_to_idxcnt_synced, reqword)
  begin
    if resetn_to_idxcnt_synced = '0' then
      tx_word_out_reg <= first_word_from_word_reg;
    else
      if rising_edge(reqword) then
        tx_word_out_reg <= word_to_tx_from_word_reg;
      end if;
    end if;
  end process;

  tx_word_out   <= tx_word_out_reg; --word_to_tx_from_word_reg; -- DEADLINE FIX: tx_word_out_reg is directed to tx_word_out instead of word_to_tx_from_word_reg
  data_ook      <= data_ook_sig;
  data_ook_next <= data_ook_next_sig;
  trim_bits     <= trim_bits_ana;

  resetn_ook_sig <= not(resets_from_mem(RESET_OOK_BIT) or not resetn or not resetn_tx_procedure);
  resetn_ppm_sig <= not(resets_from_mem(RESET_PPM_BIT) or not resetn or not resetn_tx_procedure);
  resetn_dppm_sig <= not(resets_from_mem(RESET_DPPM_BIT) or not resetn or not resetn_tx_procedure);
  resetn_nbtx_ctrlgen_sig <= not(resets_from_mem(RESET_NBTX_CTRLGEN_BIT) or not resetn or not resetn_tx_procedure);


  resetn_ook  <= resetn_ook_sig;
  resetn_ppm  <= resetn_ppm_sig;
  resetn_dppm <= resetn_dppm_sig;
  resetn_nbtx_ctrlgen <= resetn_nbtx_ctrlgen_sig;

  with ena_clk_to_coder select
  clk_1m_to_coder <= clk_1m_to_coder_not_gated when '1',
                     '0' when others;

  with ena_clk_to_coder select
  clk_10m_to_coder <= clk_10m_to_coder_not_gated when '1',
                      '0' when others;

  outselosc <= outselosc_from_mem;
  pa_outsel <= pa_outsel_sig;
  tunefreq_coarce <= tunefreq_coarce_med_from_mem(6 downto 4);
  tunefreq_med    <= tunefreq_coarce_med_from_mem(3 downto 0);
  tunefreq_fine_p <= tunefreq_fine_p_from_mem;
  tunefreq_fine_n <= tunefreq_fine_n_from_mem;

  clk_10m_to_coder_not_gated <= clk_10m;

  mux_clk_1m : process (ena_ook, ena_dppm, clk_1m, clk_10m)
    variable sel : std_logic_vector(1 downto 0);
  begin
    sel(1) := ena_ook;
    sel(0) := ena_dppm;
    case sel is
      when "10" =>
        clk_1m_to_coder_not_gated <= clk_ook_sig;
      when "01" =>
        clk_1m_to_coder_not_gated <= clk_dppm_sig;
      when others =>
        clk_1m_to_coder_not_gated <= clk_1m;
    end case;
  end process mux_clk_1m;


  --mclkn <= not mclk;

end rtl;
