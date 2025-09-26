library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.napro1_addr_pkg_v2.all;

entity napro1_spi_interface is
  port (
    sck           : in std_logic;
    mosi          : in std_logic;
    miso          : out std_logic;
    ss            : in std_logic;
    resetn        : in std_logic;
    porst_in      : in std_logic;
    byte_from_reg : in std_logic_vector(7 downto 0);
    byte_to_reg   : out std_logic_vector(7 downto 0);
    addr_to_reg   : out std_logic_vector(5 downto 0);
    write_word    : out std_logic;
    idx_out       : out std_logic_vector(5 downto 0);
    write         : out std_logic
    );
end napro1_spi_interface;

architecture rtl of napro1_spi_interface is

  component serial_output_buffer is
    generic (
      N : integer);
    port (
      data_in   : in  std_logic_vector(N-1 downto 0);
      clk       : in  std_logic;
      reset     : in  std_logic;
      data_out  : out std_logic);
  end component;
  
  
  
  --signal read_signal    : std_logic;
  signal write_sig      : std_logic;  
  signal write_word_sig : std_logic;  
  signal data_in        : std_logic_vector(15 downto 0);
  signal ssn            : std_logic;
  signal counter        : std_logic_vector(3 downto 0); -- Counts # of input bits
  --signal one              : std_logic_vector(3 downto 0); -- Signal that is added to the counter when bits are received
  
  signal LAST_FRME      : std_logic;
  signal FRME           : std_logic;
  --signal PORST          : std_logic;
  signal aPAR           : std_logic; -- calculated address & R/W-bit odd parity (1 if # of ones is even)
  signal aPAR_MISMATCH  : std_logic; -- is set to one if calculated aPAR doesn't match the received aPAR
  signal dPAR           : std_logic; -- odd parity of output data bits (1 if # of ones is even)
  signal output_info    : std_logic_vector(7 downto 0); -- The first eight bits that are output through MISO line
  signal outbuf_in      : std_logic_vector(7 downto 0);
  signal outbuf_out     : std_logic;
  signal addr_sig       : std_logic_vector(5 downto 0);
  
  --signal edge_detector_reset  : std_logic;
--  signal ss_edge_detected     : std_logic;

--  signal should_give_t_trig : std_logic;


begin -- rtl
  
  update_counter : process (sck, ss, resetn)
  begin
    if resetn = '0' or ss = '1' then
      counter <= "1111";
    elsif sck'event and sck = '0' and counter > "0000" then
      counter <= std_logic_vector(resize(unsigned(counter), 4) - to_unsigned(1, 4));
    end if;
  end process update_counter;
  
  update_data_in : process (sck, ss, resetn)
  begin
    if resetn = '0' then
      data_in <= (others => '0');
    elsif ss = '1' then
      data_in <= "0000000000000000";
    elsif sck'event and sck = '1' then
      data_in(to_integer(unsigned(counter))) <= mosi;
    end if;
  end process update_data_in;
  
--  update_read : process (sck, ss, resetn, counter, data_in)
--  begin
--    if resetn = '0' or ss = '1' then
--      read <= '0';
--    elsif sck'event and sck = '1' then
--      if counter = "1001" and mosi = '0' then     -- reino
--        read <= '1';
--      end if;
--    end if;
--  end process update_read;
  
  update_write_sig : process (sck, ss, resetn, counter, data_in)
  begin
    if resetn = '0' or ss = '1' then
      write_sig <= '0';
    elsif sck'event and sck = '0' then
      if counter = "0000" and data_in(9) = '1' and apar_mismatch = '0' then
        write_sig <= '1';
      end if;
    end if;
  end process update_write_sig;

  update_write_word_sig : process (sck, ss, resetn, counter, data_in)
  begin
    if resetn = '0' or ss = '1' then
      write_word_sig <= '0';
    elsif sck'event and sck = '0' then
      if counter = "0000" and data_in(9) = '1' and apar_mismatch = '0' and (addr_sig = addr_idx_to_write) then
        write_word_sig <= '1';
      end if;
    end if;
  end process update_write_word_sig;

--  update_should_give_t_trig : process (write_sig, addr_sig)
--  begin
--    if resetn = '0' then
--      should_give_t_trig <= '0';
--    else
--      if write_sig'event and write_sig = '1' then
--        if addr_sig = addr_T_programmable_byte_1 then
--          should_give_t_trig <= '1';
--        else
--          should_give_t_trig <= '0';
--        end if;
--      end if;
--    end if;
--  end process;
  
--  update_t_trig : process (ss, resetn, addr_sig)
--  begin
--    if resetn = '0' then
--      t_trig <= '0';
--    else
--      if ss'event and ss = '1' then
--        if addr_sig = addr_trigs then
--          t_trig <= '1';
--        else
--          t_trig <= '0';
--        end if;
--      end if;
--    end if;
--  end process;
  

--  update_reread : process (sck, ss, resetn, counter, ss_edge_detected)
--  begin
--    if resetn = '0' then
--      reread <= '1';
--    elsif sck'event and sck = '1' then
--      if counter = "1100" and ss_edge_detected = '1' then
--        reread <= '0';
--      elsif counter = "1011" then
--        reread <= '1';
--      end if;
--    end if;
--  end process update_reread;

  update_addr_sig : process (ss, resetn, data_in)
  begin
    if resetn = '0' then
      addr_sig <= (others => '0');
    elsif ss = '0' then
      addr_sig <= data_in(15 downto 10);
    end if;
  end process update_addr_sig;
  
  addr_to_reg <= addr_sig;
  
  update_byte_to_reg : process (ss, resetn, data_in)
  begin
    if resetn = '0' then
      byte_to_reg <= (others => '0');
    elsif ss = '0' then
        byte_to_reg <= data_in(7 downto 0);
    end if;
  end process update_byte_to_reg;

  -- FRME bit is set to 1 if:
  --  1. Number of received rising clock edges is not a multiple of 16
  --  2. Address and R/W parity is not correct fails
  update_frme : process (ss, sck, resetn, counter)
  begin
    if resetn = '0' then
      FRME <= '0';
    elsif sck'event and sck = '1' then
      FRME <= counter(0) or counter(1) or counter(2) or counter(3) or aPAR_MISMATCH;
    end if;
  end process update_frme;
  
  update_last_frme : process (ss, resetn)
  begin
    if resetn = '0' then
      LAST_FRME <= '0';
    elsif ss'event and ss = '1' then
      LAST_FRME <= FRME;
    end if;
  end process update_last_frme;
  
--  update_porst : process (resetn)
--  begin
--    if resetn = '0' then
--      PORST <= '0';
--    else
--      PORST <= '1';
--    end if;
--  end process update_porst;
  
  with ss select
    miso <= outbuf_out when '0',
            'Z' when others;

  ssn   <= not ss;
  --read  <= read_signal;
  write <= write_sig;
  write_word <= write_word_sig;
  idx_out <= data_in(5 downto 0);
  
  --edge_detector_reset <= read_signal and write_signal;
  
  aPAR <= not ( ((((((data_in(15) xor data_in(14)) xor data_in(13)) xor data_in(12)) xor data_in(11)) xor data_in(10)) xor data_in(9)) );
  dPAR <= not ( (((((((byte_from_reg(7) xor byte_from_reg(6)) xor byte_from_reg(5)) xor byte_from_reg(4)) xor byte_from_reg(3)) xor byte_from_reg(2)) xor byte_from_reg(1))) xor byte_from_reg(0) );
  aPAR_MISMATCH <= aPAR xor data_in(8);

  with counter select
    outbuf_in <= output_info when "1111",
                 output_info when "1110",
                 output_info when "1101",
                 output_info when "1100",
                 output_info when "1011",
                 output_info when "1010",
                 output_info when "1001",
                 byte_from_reg when others;


  output_info(7) <= '0';
  output_info(6) <= LAST_FRME;
  output_info(5) <= porst_in;
  output_info(4) <= '0';
  output_info(3) <= '0';
  output_info(2) <= '0';
  output_info(1) <= '1';
  output_info(0) <= dPAR;

  outbuf : serial_output_buffer
  generic map (
    N => 8)
  port map (
    data_in  => outbuf_in,
    clk      => sck,
    reset    => ssn,
    data_out => outbuf_out);

end; -- rtl
