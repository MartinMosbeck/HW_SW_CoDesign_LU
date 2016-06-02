library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.audiocore_pkg.all;

entity tp_ram is
 generic
 (
  ADDR_WIDTH : integer range 1 to integer'high
 );
 port
 (
  clk : in std_logic;
  --auslesen
  address_out : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
  data_out : out byte;
  --reinschreiben
  address_in1 : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
  address_in2 : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
  wr : in std_logic;
  data_in1 : in byte;
  data_in2 : in byte
 );
end entity tp_ram;

architecture beh of tp_ram is
 subtype RAM_ENTRY_TYPE is byte;
 type RAM_TYPE is array (0 to (2 ** ADDR_WIDTH) - 1) of RAM_ENTRY_TYPE;
 signal ram : RAM_TYPE := (others => x"00");
begin
 process(clk)
 begin
  if rising_edge(clk) then
    data_out <= ram(to_integer(unsigned(address_out)));
    if wr = '1' then
      ram(to_integer(unsigned(address_in1))) <= data_in1;
      ram(to_integer(unsigned(address_in2))) <= data_in2;
    end if;
  end if;
 end process;
end architecture beh;
