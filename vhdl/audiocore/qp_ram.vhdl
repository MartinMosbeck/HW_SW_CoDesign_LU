library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity qp_ram is
 generic
 (
  ADDR_WIDTH : integer range 1 to integer'high;
  DATA_WIDTH : integer range 1 to integer'high
 );
 port
 (
  clk : in std_logic;
  --auslesen
  address1 : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
  address2 : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
  address3 : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
  address4 : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
  data_out1 : out std_logic_vector(DATA_WIDTH - 1 downto 0);
  data_out2 : out std_logic_vector(DATA_WIDTH - 1 downto 0);
  data_out3 : out std_logic_vector(DATA_WIDTH - 1 downto 0);
  data_out4 : out std_logic_vector(DATA_WIDTH - 1 downto 0);
  --reinschreiben
  address5 : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
  wr : in std_logic;
  data_in : in std_logic_vector(DATA_WIDTH - 1 downto 0)
 );
end entity qp_ram;

architecture beh of qp_ram is
 subtype RAM_ENTRY_TYPE is std_logic_vector(DATA_WIDTH - 1 downto 0);
 type RAM_TYPE is array (0 to (2 ** ADDR_WIDTH) - 1) of RAM_ENTRY_TYPE;
 signal ram : RAM_TYPE := (others => x"00");
begin
 process(clk)
 begin
  if rising_edge(clk) then
    data_out1 <= ram(to_integer(unsigned(address1)));
    data_out2 <= ram(to_integer(unsigned(address2)));
    data_out3 <= ram(to_integer(unsigned(address3)));
    data_out4 <= ram(to_integer(unsigned(address4)));
    if wr = '1' then
      ram(to_integer(unsigned(address5))) <= data_in;
    end if;
  end if;
 end process;
end architecture beh;