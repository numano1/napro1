library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.napro1_addr_pkg_v2.all;

entity word_reg_with_gest is
  port (
    write_word        : in  std_logic;
    idx_write         : in  std_logic_vector(5 downto 0);
    word_in           : in  std_logic_vector(5 downto 0);
    resetn            : in  std_logic;
    idx_to_tx         : in  std_logic_vector(5 downto 0);
    idx_to_read       : in  std_logic_vector(5 downto 0);
    ena_gest          : in  std_logic;
    gest1_in          : in  std_logic_vector(15 downto 0);
    gest2_in          : in  std_logic_vector(15 downto 0);
    ena_dppm          : in  std_logic;
    b_dppm            : in  std_logic_vector(2 downto 0);
    word_to_tx        : out std_logic_vector(5 downto 0);
    first_word        : out std_logic_vector(5 downto 0);
    word_to_mem       : out std_logic_vector(5 downto 0);
    bits_to_ook       : out std_logic_vector(47 downto 0)
    );
end word_reg_with_gest;



architecture rtl of word_reg_with_gest is

  signal tx_words : std_logic_vector(64*6-1 downto 0);
  
  type tx_words_t is array (63 downto 0) of std_logic_vector(5 downto 0);
  signal tx_words_reg   : tx_words_t;

--  signal gest_words : std_logic_vector(6*6-1 downto 0);

--  type gest_words_t is array (5 downto 0) of std_logic_vector(5 downto 0);
--  signal gest_words_reg : gest_words_t;

begin -- rtl

  tx_word_stages : for i in 1 to 64 generate
      tx_words( (i*6-1) downto ((i-1)*6) ) <= tx_words_reg(i-1)(5 downto 0);
  end generate tx_word_stages;

--  gest_word_stages : for i in 1 to 6 generate
--    gest_words( (i*6-1) downto ((i-1)*6 ) <= gest_words_reg(i-1)(5 downto 0);
--  end generate gest_word_stages;

  word_reg_write : process (resetn, write_word)
  begin
    if resetn = '0' then
                                  --MSB    LSB
      tx_words_reg(0)           <= std_logic_vector(to_unsigned(default_words(0),6));
      tx_words_reg(1)           <= std_logic_vector(to_unsigned(default_words(1),6));
      tx_words_reg(2)           <= std_logic_vector(to_unsigned(default_words(2),6));
      tx_words_reg(3)           <= std_logic_vector(to_unsigned(default_words(3),6));
      tx_words_reg(4)           <= std_logic_vector(to_unsigned(default_words(4),6));
      tx_words_reg(5)           <= std_logic_vector(to_unsigned(default_words(5),6));
      tx_words_reg(6)           <= std_logic_vector(to_unsigned(default_words(6),6));
      tx_words_reg(7)           <= std_logic_vector(to_unsigned(default_words(7),6));

      tx_words_reg(8)           <= std_logic_vector(to_unsigned(default_words(8),6));
      tx_words_reg(9)           <= std_logic_vector(to_unsigned(default_words(9),6));
      tx_words_reg(10)           <= std_logic_vector(to_unsigned(default_words(10),6));
      tx_words_reg(11)           <= std_logic_vector(to_unsigned(default_words(11),6));
      tx_words_reg(12)           <= std_logic_vector(to_unsigned(default_words(12),6));
      tx_words_reg(13)           <= std_logic_vector(to_unsigned(default_words(13),6));
      tx_words_reg(14)           <= std_logic_vector(to_unsigned(default_words(14),6));
      tx_words_reg(15)           <= std_logic_vector(to_unsigned(default_words(15),6));

      tx_words_reg(16)           <= std_logic_vector(to_unsigned(default_words(16),6));
      tx_words_reg(17)           <= std_logic_vector(to_unsigned(default_words(17),6));
      tx_words_reg(18)           <= std_logic_vector(to_unsigned(default_words(18),6));
      tx_words_reg(19)           <= std_logic_vector(to_unsigned(default_words(19),6));
      tx_words_reg(20)           <= std_logic_vector(to_unsigned(default_words(20),6));
      tx_words_reg(21)           <= std_logic_vector(to_unsigned(default_words(21),6));
      tx_words_reg(22)           <= std_logic_vector(to_unsigned(default_words(22),6));
      tx_words_reg(23)           <= std_logic_vector(to_unsigned(default_words(23),6));

      tx_words_reg(24)           <= std_logic_vector(to_unsigned(default_words(24),6));
      tx_words_reg(25)           <= std_logic_vector(to_unsigned(default_words(25),6));
      tx_words_reg(26)           <= std_logic_vector(to_unsigned(default_words(26),6));
      tx_words_reg(27)           <= std_logic_vector(to_unsigned(default_words(27),6));
      tx_words_reg(28)           <= std_logic_vector(to_unsigned(default_words(28),6));
      tx_words_reg(29)           <= std_logic_vector(to_unsigned(default_words(29),6));
      tx_words_reg(30)           <= std_logic_vector(to_unsigned(default_words(30),6));
      tx_words_reg(31)           <= std_logic_vector(to_unsigned(default_words(31),6));

      tx_words_reg(32)           <= std_logic_vector(to_unsigned(default_words(32),6));
      tx_words_reg(33)           <= std_logic_vector(to_unsigned(default_words(33),6));
      tx_words_reg(34)           <= std_logic_vector(to_unsigned(default_words(34),6));
      tx_words_reg(35)           <= std_logic_vector(to_unsigned(default_words(35),6));
      tx_words_reg(36)           <= std_logic_vector(to_unsigned(default_words(36),6));
      tx_words_reg(37)           <= std_logic_vector(to_unsigned(default_words(37),6));
      tx_words_reg(38)           <= std_logic_vector(to_unsigned(default_words(38),6));
      tx_words_reg(39)           <= std_logic_vector(to_unsigned(default_words(39),6));

      tx_words_reg(40)           <= std_logic_vector(to_unsigned(default_words(40),6));
      tx_words_reg(41)           <= std_logic_vector(to_unsigned(default_words(41),6));
      tx_words_reg(42)           <= std_logic_vector(to_unsigned(default_words(42),6));
      tx_words_reg(43)           <= std_logic_vector(to_unsigned(default_words(43),6));
      tx_words_reg(44)           <= std_logic_vector(to_unsigned(default_words(44),6));
      tx_words_reg(45)           <= std_logic_vector(to_unsigned(default_words(45),6));
      tx_words_reg(46)           <= std_logic_vector(to_unsigned(default_words(46),6));
      tx_words_reg(47)           <= std_logic_vector(to_unsigned(default_words(47),6));

      tx_words_reg(48)           <= std_logic_vector(to_unsigned(default_words(48),6));
      tx_words_reg(49)           <= std_logic_vector(to_unsigned(default_words(49),6));
      tx_words_reg(50)           <= std_logic_vector(to_unsigned(default_words(50),6));
      tx_words_reg(51)           <= std_logic_vector(to_unsigned(default_words(51),6));
      tx_words_reg(52)           <= std_logic_vector(to_unsigned(default_words(52),6));
      tx_words_reg(53)           <= std_logic_vector(to_unsigned(default_words(53),6));
      tx_words_reg(54)           <= std_logic_vector(to_unsigned(default_words(54),6));
      tx_words_reg(55)           <= std_logic_vector(to_unsigned(default_words(55),6));

      tx_words_reg(56)           <= std_logic_vector(to_unsigned(default_words(56),6));
      tx_words_reg(57)           <= std_logic_vector(to_unsigned(default_words(57),6));
      tx_words_reg(58)           <= std_logic_vector(to_unsigned(default_words(58),6));
      tx_words_reg(59)           <= std_logic_vector(to_unsigned(default_words(59),6));
      tx_words_reg(60)           <= std_logic_vector(to_unsigned(default_words(60),6));
      tx_words_reg(61)           <= std_logic_vector(to_unsigned(default_words(61),6));
      tx_words_reg(62)           <= std_logic_vector(to_unsigned(default_words(62),6));
      tx_words_reg(63)           <= std_logic_vector(to_unsigned(default_words(63),6));

    elsif write_word'event and write_word = '1' then
      tx_words_reg(to_integer(unsigned(idx_write))) <= word_in;
    end if;
  end process word_reg_write;


  
  --with idx_to_read select
  --word_out <= tx_words_reg(0) when "000000",
  --            "000000" when others;

  word_for_tx : process (resetn, idx_to_tx, tx_words_reg)
  begin
    --if resetn = '0' then
    --  word_to_tx <= "000000";
    --elsif idx_to_tx'event then
      word_to_tx <= tx_words_reg(to_integer(unsigned(idx_to_tx)));
    --end if;
  end process word_for_tx;



  word_for_mem : process (resetn, idx_to_read, tx_words_reg)
  begin
    --if resetn = '0' then
    --  word_to_mem <= "000000";
    --elsif idx_to_read'event then
      word_to_mem <= tx_words_reg(to_integer(unsigned(idx_to_read)));
    --end if;
  end process word_for_mem;

  first_word <= tx_words_reg(0);

  -- ND3: commented line below and added process connect_ook_data
  --bits_to_ook <= tx_words(47 downto 0);

  connect_ook_data : process(ena_gest, gest1_in, gest2_in, tx_words)
  begin
    if ena_gest = '0' then
      bits_to_ook <= tx_words(47 downto 0);
    else
      bits_to_ook <= gest2_in & gest1_in & tx_words(15 downto 0);
    end if;
  end process connect_ook_data;

end rtl;
