library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use napro1_addr_pkg_v2.all;

entity mem_reg_napro1 is
  port (
    write_reg         : in  std_logic;
    addr_in           : in  std_logic_vector(5 downto 0);
    byte_in           : in  std_logic_vector(7 downto 0);
    resetn            : in  std_logic;
    porst_out         : out std_logic;
    byte_out          : out std_logic_vector(7 downto 0);
    ctrl              : out std_logic_vector(7 downto 0);
    nbtx_ctrl         : out std_logic_vector(7 downto 0);
    trigs             : out std_logic_vector(7 downto 0);
    resets            : out std_logic_vector(7 downto 0);
    idxmax_ook        : out std_logic_vector(5 downto 0);
    idxmax            : out std_logic_vector(5 downto 0);
    word_to_write     : out std_logic_vector(5 downto 0);
    idx_to_write      : out std_logic_vector(5 downto 0);
    idx_to_read       : out std_logic_vector(5 downto 0);
    word_to_read      : in  std_logic_vector(5 downto 0);
    outselosc         : out std_logic_vector(2 downto 0);
    pa_outsel         : out std_logic_vector(20 downto 0);
    trim_bits         : out std_logic_vector(63 downto 0);
    tunefreq_coarce_med : out std_logic_vector(6 downto 0);
    tunefreq_fine_p     : out std_logic_vector(5 downto 0);
    tunefreq_fine_n     : out std_logic_vector(5 downto 0)
    );
end mem_reg_napro1;



architecture rtl of mem_reg_napro1 is

  type trim_bits_t is array (7 downto 0) of std_logic_vector(7 downto 0);
  signal trim_bits_reg  : trim_bits_t;

  type tx_words_t is array (23 downto 0) of std_logic_vector(7 downto 0);
  signal tx_words_reg   : tx_words_t;

  signal ctrl_reg                 : std_logic_vector(7 downto 0);
  signal nbtx_ctrl_reg            : std_logic_vector(7 downto 0);
  signal trigs_sig                : std_logic_vector(7 downto 0); -- (0) = temperature trig for DSP
  signal resets_sig               : std_logic_vector(7 downto 0);
  signal idxmax_ook_sig           : std_logic_vector(5 downto 0);  
  signal idxmax_sig               : std_logic_vector(5 downto 0);  
  signal word_to_write_sig        : std_logic_vector(5 downto 0);
  signal idx_to_write_sig         : std_logic_vector(5 downto 0);
  signal idx_to_read_sig          : std_logic_vector(5 downto 0);
  signal outselosc_sig            : std_logic_vector(2 downto 0);
  signal pa_outsel_sig            : std_logic_vector(20 downto 0);
  signal tunefreq_coarce_med_sig  : std_logic_vector(7 downto 0);
  signal tunefreq_fine_p_sig      : std_logic_vector(7 downto 0);
  signal tunefreq_fine_n_sig      : std_logic_vector(7 downto 0);


begin -- rtl

  stages : for i in 1 to 8 generate
    trim_bits( (i*8-1) downto ((i-1)*8) ) <= trim_bits_reg(i-1)(7 downto 0);
  end generate stages;
  
--  tx_word_stages : for i in 1 to 24 generate
--    tx_words( (i*8-1) downto ((i-1)*8) ) <= tx_words_reg(i-1)(7 downto 0);
--  end generate tx_word_stages;

  mem_reg_write : process (resetn, write_reg) -- dec_data_in_x, dec_data_in_y) -- offset_cal_sw
  begin
    if resetn = '0' then
                                  --MSB    LSB
      ctrl_reg                  <= "11000010";
      nbtx_ctrl_reg             <= "00001000";
      trigs_sig                 <= (others => '0');
      resets_sig                <= (others => '0');
      
      idxmax_ook_sig            <= "010000";
      idxmax_sig                <= "000111";
      word_to_write_sig         <= "111111";
      idx_to_write_sig          <= "000000";
      idx_to_read_sig           <= "000000";

      outselosc_sig             <= "000";
      pa_outsel_sig             <= "100100011010001000110";

      trim_bits_reg(0)          <= napro1_default_trim_bits(7 downto 0);
      trim_bits_reg(1)          <= napro1_default_trim_bits(15 downto 8);
      trim_bits_reg(2)          <= napro1_default_trim_bits(23 downto 16);
      trim_bits_reg(3)          <= napro1_default_trim_bits(31 downto 24);
      trim_bits_reg(4)          <= napro1_default_trim_bits(39 downto 32);
      trim_bits_reg(5)          <= napro1_default_trim_bits(47 downto 40);
      trim_bits_reg(6)          <= napro1_default_trim_bits(55 downto 48);
      trim_bits_reg(7)          <= napro1_default_trim_bits(63 downto 56);

      tunefreq_coarce_med_sig   <= "00110101";
      tunefreq_fine_p_sig       <= "00000000";
      tunefreq_fine_n_sig       <= "00000000";
      

    elsif write_reg'event and write_reg = '1' then
      if addr_in(5 downto 0) = addr_ctrl_reg then
        ctrl_reg(7 downto 0) <= byte_in(7 downto 0);

      elsif addr_in(5 downto 0) = addr_nbtx_ctrl then
        nbtx_ctrl_reg(7 downto 0) <= byte_in(7 downto 0);

      elsif addr_in(5 downto 0) = addr_idxmax_ook then
        idxmax_ook_sig(5 downto 0) <= byte_in(5 downto 0);

      elsif addr_in(5 downto 0) = addr_idxmax then
        idxmax_sig(5 downto 0) <= byte_in(5 downto 0);
      
      elsif addr_in(5 downto 0) = addr_trigs then
        trigs_sig(7 downto 0) <= byte_in(7 downto 0);

      elsif addr_in(5 downto 0) = addr_resets then
        resets_sig <= byte_in;

      elsif addr_in(5 downto 0) = addr_idx_to_write then
        idx_to_write_sig <= byte_in(5 downto 0);

      elsif addr_in(5 downto 0) = addr_idx_to_read then
        idx_to_read_sig <= byte_in(5 downto 0);

      elsif addr_in(5 downto 0) = addr_word_to_write then
        word_to_write_sig <= byte_in(5 downto 0);

      elsif addr_in(5 downto 0) = addr_outselosc then
        outselosc_sig <= byte_in(2 downto 0);

      elsif addr_in(5 downto 0) = addr_pa_outsel_a then
        pa_outsel_sig(7 downto 0) <= byte_in(7 downto 0);
      elsif addr_in(5 downto 0) = addr_pa_outsel_b then
        pa_outsel_sig(15 downto 8) <= byte_in(7 downto 0);
      elsif addr_in(5 downto 0) = addr_pa_outsel_c then
        pa_outsel_sig(20 downto 16) <= byte_in(4 downto 0);

      elsif addr_in(5 downto 0) = addr_tunefreq_coarce_med then
        tunefreq_coarce_med_sig <= byte_in(7 downto 0);
      elsif addr_in(5 downto 0) = addr_tunefreq_fine_p then
        tunefreq_fine_p_sig <= byte_in(7 downto 0);
      elsif addr_in(5 downto 0) = addr_tunefreq_fine_n then
        tunefreq_fine_n_sig <= byte_in(7 downto 0);

      elsif addr_in(5 downto 0) = addr_trim_reg_0 then
        trim_bits_reg(0) <= byte_in;
      elsif addr_in(5 downto 0) = addr_trim_reg_1 then
        trim_bits_reg(1) <= byte_in;
      elsif addr_in(5 downto 0) = addr_trim_reg_2 then
        trim_bits_reg(2) <= byte_in;
      elsif addr_in(5 downto 0) = addr_trim_reg_3 then
        trim_bits_reg(3) <= byte_in;
      elsif addr_in(5 downto 0) = addr_trim_reg_4 then
        trim_bits_reg(4) <= byte_in;
      elsif addr_in(5 downto 0) = addr_trim_reg_5 then
        trim_bits_reg(5) <= byte_in;
      elsif addr_in(5 downto 0) = addr_trim_reg_6 then
        trim_bits_reg(6) <= byte_in;
      elsif addr_in(5 downto 0) = addr_trim_reg_7 then
        trim_bits_reg(7) <= byte_in;
  
      end if;
    end if;
  end process mem_reg_write;


  
  with addr_in select
  byte_out <= ctrl_reg when addr_ctrl_reg,
              nbtx_ctrl_reg when addr_nbtx_ctrl,
              "00" & idxmax_ook_sig when addr_idxmax_ook,
              "00" & idxmax_sig when addr_idxmax,
              trigs_sig when addr_trigs,
              resets_sig when addr_resets,
              "00" & word_to_write_sig when addr_word_to_write,
              "00" & idx_to_write_sig when addr_idx_to_write,
              "00" & idx_to_read_sig when addr_idx_to_read,
              "00" & word_to_read when addr_word_to_read,

              "00000" & outselosc_sig(2 downto 0) when addr_outselosc,
              pa_outsel_sig(7 downto 0) when addr_pa_outsel_a,
              pa_outsel_sig(15 downto 8) when addr_pa_outsel_b,
              "000" & pa_outsel_sig(20 downto 16) when addr_pa_outsel_c,

              tunefreq_coarce_med_sig when addr_tunefreq_coarce_med,
              tunefreq_fine_p_sig when addr_tunefreq_fine_p,
              tunefreq_fine_n_sig when addr_tunefreq_fine_n,

              trim_bits_reg(0) when addr_trim_reg_0,
              trim_bits_reg(1) when addr_trim_reg_1,
              trim_bits_reg(2) when addr_trim_reg_2,
              trim_bits_reg(3) when addr_trim_reg_3,
              trim_bits_reg(4) when addr_trim_reg_4,
              trim_bits_reg(5) when addr_trim_reg_5,
              trim_bits_reg(6) when addr_trim_reg_6,
              trim_bits_reg(7) when addr_trim_reg_7,

              "00000000" when others;


  porst_out             <= ctrl_reg(PORST_BIT);
  --ena_tx_continuous     <= ctrl_reg(ENA_TX_CONTINUOUS_BIT);
  idxmax_ook            <= idxmax_ook_sig;
  idxmax                <= idxmax_sig;
  ctrl                  <= ctrl_reg;
  nbtx_ctrl             <= nbtx_ctrl_reg;
  trigs                 <= trigs_sig;
  resets                <= resets_sig;
  word_to_write         <= word_to_write_sig;
  idx_to_write          <= idx_to_write_sig;
  idx_to_read           <= idx_to_read_sig;
  outselosc             <= outselosc_sig;
  pa_outsel             <= pa_outsel_sig;
  tunefreq_coarce_med   <= tunefreq_coarce_med_sig(6 downto 0);
  tunefreq_fine_p       <= tunefreq_fine_p_sig(5 downto 0);
  tunefreq_fine_n       <= tunefreq_fine_n_sig(5 downto 0);

end rtl;
