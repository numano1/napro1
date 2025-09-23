library ieee;
use ieee.std_logic_1164.all;

package napro1_addr_pkg_v2 is

  constant addr_ctrl_reg                : std_logic_vector(5 downto 0) := "000001";
  constant addr_nbtx_ctrl               : std_logic_vector(5 downto 0) := "000010";
  constant addr_idxmax_ook              : std_logic_vector(5 downto 0) := "000011";
  constant addr_idxmax                  : std_logic_vector(5 downto 0) := "000100";
  constant addr_trigs                   : std_logic_vector(5 downto 0) := "000101";
  constant addr_resets                  : std_logic_vector(5 downto 0) := "000110";

  constant addr_word_to_write           : std_logic_vector(5 downto 0) := "001000";
  constant addr_idx_to_write            : std_logic_vector(5 downto 0) := "001001";
  constant addr_idx_to_read             : std_logic_vector(5 downto 0) := "001010";
  constant addr_word_to_read            : std_logic_vector(5 downto 0) := "001011";

  constant addr_outselosc               : std_logic_vector(5 downto 0) := "100000";
  constant addr_pa_outsel_a             : std_logic_vector(5 downto 0) := "100001";
  constant addr_pa_outsel_b             : std_logic_vector(5 downto 0) := "100010";
  constant addr_pa_outsel_c             : std_logic_vector(5 downto 0) := "100011";

  constant addr_tunefreq_coarce_med     : std_logic_vector(5 downto 0) := "100100";
  constant addr_tunefreq_fine_p         : std_logic_vector(5 downto 0) := "100101";
  constant addr_tunefreq_fine_n         : std_logic_vector(5 downto 0) := "100110";

  constant addr_trim_reg_0 : std_logic_vector(5 downto 0)       := "111000";
  constant addr_trim_reg_1 : std_logic_vector(5 downto 0)       := "111001";
  constant addr_trim_reg_2 : std_logic_vector(5 downto 0)       := "111010";
  constant addr_trim_reg_3 : std_logic_vector(5 downto 0)       := "111011";
  constant addr_trim_reg_4 : std_logic_vector(5 downto 0)       := "111100";
  constant addr_trim_reg_5 : std_logic_vector(5 downto 0)       := "111101";
  constant addr_trim_reg_6 : std_logic_vector(5 downto 0)       := "111110";
  constant addr_trim_reg_7 : std_logic_vector(5 downto 0)       := "111111";
  
  --constant napro1_default_trim_bits : std_logic_vector(63 downto 0) := "1111000011000110001100010000000100001000000010001110101100010100";
  constant napro1_default_trim_bits : std_logic_vector(63 downto 0) := "1100010010011010101010011010101011110000110000001000010000111110";
  
  -- bit indices in ctrl
  constant ENA_TX_CONTINUOUS_BIT      : integer := 0; -- enable 1st order mode of integrator
  constant ENA_OOK_BIT                : integer := 1;
  constant ENA_PPM_BIT                : integer := 2;
  constant ENA_DPPM_BIT               : integer := 3;
  constant ENA_GEST_TO_TX_BIT         : integer := 4;
  constant PORST_BIT                  : integer := 6;
  constant ENA_CLK_TO_CODER_BIT       : integer := 7;
  
  -- bit indices in disp_ctrl
  --constant DISA_DISP_BIT                : integer := 0;
  
  -- bit indices in sig_ctrl
  --constant ADC_CLK_CONT_BIT             : integer := 0;
  -- bit indices in nbtx_ctrl
  constant NBTX_ENA_GEST_BIT : integer := 0;
  constant NBTX_B_DPPM_0_BIT : integer := 1;
  constant NBTX_B_DPPM_1_BIT : integer := 2;
  constant NBTX_B_DPPM_2_BIT : integer := 3;
  
  -- indices in trigs
  constant TX_TRIG_BIT        : integer := 0;
  constant IDX_WRITE_TRIG_BIT : integer := 1;

  -- resets
  constant RESET_OOK_BIT  : integer := 0;
  constant RESET_PPM_BIT  : integer := 1;
  constant RESET_DPPM_BIT : integer := 2;
  constant RESET_NBTX_CTRLGEN_BIT : integer := 3;

  type word_array_t is array (0 to 63) of integer range 0 to 63;
  constant default_words : word_array_t := (19, 45, 12, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63); 
  
end napro1_addr_pkg_v2;



package body napro1_addr_pkg_v2 is
  
  
end napro1_addr_pkg_v2;
