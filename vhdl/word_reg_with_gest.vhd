library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.napro1_addr_pkg_v2.all;

entity word_reg_with_gest is
  port (
    write_word : in  std_logic;
    idx_write  : in  std_logic_vector(5 downto 0);
    word_in    : in  std_logic_vector(5 downto 0);
    resetn     : in  std_logic;

    idx_to_tx   : in  std_logic_vector(5 downto 0);
    idx_to_read : in  std_logic_vector(5 downto 0);

    ena_gest    : in  std_logic;
    gest1_in    : in  std_logic_vector(15 downto 0);
    gest2_in    : in  std_logic_vector(15 downto 0);

    ena_dppm    : in  std_logic;
    b_dppm      : in  std_logic_vector(2 downto 0);

    word_to_tx  : out std_logic_vector(5 downto 0);
    first_word  : out std_logic_vector(5 downto 0);
    word_to_mem : out std_logic_vector(5 downto 0);
    bits_to_ook : out std_logic_vector(47 downto 0)
  );
end word_reg_with_gest;

architecture rtl of word_reg_with_gest is

  -- Flattened storage for 64 x 6-bit words to avoid VHDL array -> SV unpacked array
  signal tx_words_reg_flat : std_logic_vector(64*6-1 downto 0);

  -- --- helpers --------------------------------------------------------------
  function get_word(v : std_logic_vector; idx : unsigned) return std_logic_vector is
    variable base : integer := to_integer(idx) * 6;
  begin
    return v(base+5 downto base);
  end function;

  procedure set_word(signal v : inout std_logic_vector; idx : unsigned; w : std_logic_vector) is
    variable base : integer := to_integer(idx) * 6;
  begin
    v(base+5 downto base) <= w(5 downto 0);
  end procedure;

begin

  -- Reset defaults & indexed write
  word_reg_write : process (resetn, write_word)
    variable i : integer;
  begin
    if resetn = '0' then
      -- Initialize from package defaults
      for i in 0 to 63 loop
        set_word(tx_words_reg_flat, to_unsigned(i,6), std_logic_vector(to_unsigned(default_words(i), 6)));
      end loop;
    elsif write_word'event and write_word = '1' then
      set_word(tx_words_reg_flat, unsigned(idx_write), word_in);
    end if;
  end process;

  -- Read datapaths
  word_to_tx  <= get_word(tx_words_reg_flat, unsigned(idx_to_tx));
  word_to_mem <= get_word(tx_words_reg_flat, unsigned(idx_to_read));
  first_word  <= get_word(tx_words_reg_flat, to_unsigned(0,6));

  -- OOK bit vector connection (optionally prepend gesture words)
  connect_ook_data : process(ena_gest, gest1_in, gest2_in, tx_words_reg_flat)
  begin
    if ena_gest = '0' then
      bits_to_ook <= tx_words_reg_flat(47 downto 0);
    else
      bits_to_ook <= gest2_in & gest1_in & tx_words_reg_flat(15 downto 0);
    end if;
  end process;

end rtl;
