
----------------------------------------------------------------------------------
-- Company:      TU Wien - ECS Group                                            
-- Engineer:     Florian Huemer                                                 
--                                                                              
-- Create Date:  2011                                                 
-- Design Name:                                                           
-- Module Name:                                                   
-- Project Name: graphic_lib                                                          
-- Description:  
--
--
--     x & y
--     colum & row
--
--
--                                              
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.math_pkg.all;

----------------------------------------------------------------------------------
--                                 ENTITY                                       --
----------------------------------------------------------------------------------

--! @brief Video Ram Entity 
entity video_ram is
	generic
	(
		DATA_WIDTH : integer := 16;
		COLUM_COUNT : integer := 100;
		ROW_COUNT : integer := 30
	);
	port
	(
		clk 			: in std_logic;
		data_in 		: in std_logic_vector(DATA_WIDTH - 1 downto 0);
		addr_wr			: in std_logic_vector(log2c(COLUM_COUNT) + log2c(ROW_COUNT)-1 downto 0);
		wr				: in std_logic;
		
		data_out		: out std_logic_vector(DATA_WIDTH - 1 downto 0);
		addr_rd			: in std_logic_vector(log2c(COLUM_COUNT) + log2c(ROW_COUNT)-1 downto 0);
		rd				: in std_logic;
		
		scroll_offset : in std_logic_vector(log2c(ROW_COUNT)-1 downto 0)
		
	);
end entity video_ram;



----------------------------------------------------------------------------------
--                               ARCHITECTURE                                   --
----------------------------------------------------------------------------------

architecture beh of video_ram is 

	
type mem_type is array ( (2** (log2c(ROW_COUNT) + log2c(COLUM_COUNT)))-1 downto 0) of std_logic_vector( DATA_WIDTH - 1 downto 0) ;
signal ram : mem_type ;

constant ROW_ADDR_WIDTH : integer := log2c(ROW_COUNT);
constant COLUM_ADDR_WIDTH : integer := log2c(COLUM_COUNT);

begin

	sync : process (clk)
		variable row_address_wr : integer range 0 to 2**(log2c(ROW_COUNT)); 		
		variable address_wr : std_logic_vector(log2c(ROW_COUNT) + log2c(COLUM_COUNT)-1 downto 0);
		
		variable row_address_rd : integer range 0 to 2**(log2c(ROW_COUNT)); 		
		variable address_rd : std_logic_vector(log2c(ROW_COUNT) + log2c(COLUM_COUNT)-1 downto 0);

	begin
		if rising_edge(clk) then
			
			-- write to ram
			if wr = '1' then
				row_address_wr := to_integer(unsigned(addr_wr(ROW_ADDR_WIDTH-1 downto 0))) + to_integer(unsigned(scroll_offset)); 
				if row_address_wr > ROW_COUNT - 1 then
					row_address_wr := row_address_wr - ROW_COUNT;
				end if;
				address_wr := addr_wr(ROW_ADDR_WIDTH+COLUM_ADDR_WIDTH-1 downto ROW_ADDR_WIDTH) & std_logic_vector(to_unsigned(row_address_wr, ROW_ADDR_WIDTH));
				ram(to_integer(unsigned(address_wr))) <= data_in;
			end if;
		
			-- read from ram
			if rd = '1' then
				row_address_rd := to_integer(unsigned(addr_rd(ROW_ADDR_WIDTH-1 downto 0))) + to_integer(unsigned(scroll_offset)); 
				if row_address_rd > ROW_COUNT - 1 then
					row_address_rd := row_address_rd - ROW_COUNT;
				end if;
				address_rd := addr_rd(ROW_ADDR_WIDTH+COLUM_ADDR_WIDTH-1 downto ROW_ADDR_WIDTH) & std_logic_vector(to_unsigned(row_address_rd, ROW_ADDR_WIDTH));
				data_out <= ram(to_integer(unsigned(address_rd)));
			end if;
		
		end if;
		
	end process;

end architecture beh;


--- EOF ---


