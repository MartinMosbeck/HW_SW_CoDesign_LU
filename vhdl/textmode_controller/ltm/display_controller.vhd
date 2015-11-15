

----------------------------------------------------------------------------------
--                                LIBRARIES                                     --
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.math_pkg.all;
use work.display_controller_pkg.all;


----------------------------------------------------------------------------------
--                                 ENTITY                                       --
----------------------------------------------------------------------------------

entity display_controller is
	port
	(
		clk	: in  std_logic;	-- global system clk 
		res_n	: in  std_logic;	-- system reset

		-- connection video ram
		vram_addr_row	: out std_logic_vector(log2c(30)-1 downto 0);
		vram_addr_colum : out std_logic_vector(log2c(100)-1 downto 0);
		vram_data	: in std_logic_vector(15 downto 0);	
		vram_rd	: out std_logic;					                


		-- connection to font rom
		char              : out std_logic_vector(log2c(256) - 1 downto 0);
		char_height_pixel : out std_logic_vector(log2c(16) - 1 downto 0);
		decoded_char      : in std_logic_vector(0 to 8 - 1);


		-- connection to display
		--nclk    : out std_logic;			-- display clk
		hd	    : out std_logic;	        -- horizontal sync signal
		vd	    : out std_logic;            -- vertical sync signal
		den	    : out std_logic;            -- data enable 
		r	    : out std_logic_vector(7 downto 0);		-- pixel color value (red)
		g	    : out std_logic_vector(7 downto 0);		-- pixel color value (green)
		b 	    : out std_logic_vector(7 downto 0);		-- pixel color value (blue)

		grest	: out std_logic		-- display reset
	);
end entity display_controller;



----------------------------------------------------------------------------------
--                               ARCHITECTURE                                   --
----------------------------------------------------------------------------------

architecture beh of display_controller is

	constant CLK_PER_HORIZONTAL_LINE : integer := 1056;
	constant H_LINE_PER_FRAME : integer := 525;

	constant H_SYNC_BACK_PORCH : integer := 216;	-- in CLK-periods
	constant H_SYNC_FRONT_PORCH : integer := 40;	-- in CLK-periods

	constant VERTICAL_BACK_PORCH : integer := 35;	-- in Horizontal lines
	constant VERTICAL_FRONT_PORCH : integer := 10;	-- in Horizontal lines


	constant CHARS_PER_HORIZONTAL_LINE : integer := CLK_PER_HORIZONTAL_LINE / 8;
	constant HSBP_CHARS : integer := H_SYNC_BACK_PORCH / 8;		-- horizontal back porch in chars 
	constant HSFP_CHARS : integer := H_SYNC_FRONT_PORCH / 8;



	signal vertical_display_area : std_logic;
	
	
	signal clk_cnt : std_logic_vector(log2c(CLK_PER_HORIZONTAL_LINE)-1 downto 0 );
	alias char_pixel_cnt : std_logic_vector(2 downto 0) is clk_cnt(2 downto 0);
	alias colum_cnt : std_logic_vector(clk_cnt'length -1-3 downto 0) is clk_cnt(clk_cnt'length -1 downto 3);
	
	signal hline_cnt : integer range 0 to H_LINE_PER_FRAME;
	
	signal char_pixel_buffer : std_logic_vector(0 to 7);
	signal char_pixel_buffer_next : std_logic_vector(0 to 7);
	
	signal attribut_buffer : std_logic_vector(7 downto 0);
	signal attribut_buffer_next : std_logic_vector(7 downto 0);
	
begin
    
    
    
	snyc : process(clk, res_n)
	begin
	
	if res_n = '0' then -- reset
	
		--reset counter signals
		clk_cnt <= (others=>'0');
		hline_cnt <= 0;

		grest <= '0'; 

		char_pixel_buffer <= (others=>'0');    
		attribut_buffer <= (others=>'0');

	elsif rising_edge(clk) then
	

		grest <= '1'; 
		char_pixel_buffer <= char_pixel_buffer_next;  
		attribut_buffer <= attribut_buffer_next;
		  
		
		
		clk_cnt <= clk_cnt + 1; -- inc clk counter 
		
		if clk_cnt = CLK_PER_HORIZONTAL_LINE - 1  then -- line complete
			clk_cnt <= (others=>'0');
			hline_cnt <= hline_cnt + 1; --inc line counter

			-- check for line counter overflow --> frame complete
			if hline_cnt = H_LINE_PER_FRAME - 1 then  
				hline_cnt <= 0;
			end if;
        
      	end if;
    
	end if;
    
	end process;
  
  

	output : process(res_n, vertical_display_area, hline_cnt, clk_cnt, char_pixel_buffer, attribut_buffer)
		variable color_index : integer range 0 to 15;
	begin

			hd <= '1'; -- idle state 1
			vd <= '1';

			-- generate the horizontal sync pulse
			if clk_cnt = 0 then 
				hd <= '0';
			end if;
	
			-- generate the vertical sync pulse
			if hline_cnt = 0 then 
				vd <= '0';
			end if;
	
			r <= (others => '0');
			g <= (others => '0');
			b <= (others => '0');
			den <= '0';

	
			if vertical_display_area = '1' then 

				if clk_cnt >= (H_SYNC_BACK_PORCH) and 
					clk_cnt < (CLK_PER_HORIZONTAL_LINE - H_SYNC_FRONT_PORCH) then	
	
					-- char_pixel_buffer
					-- attribut_buffer
			
					if char_pixel_buffer(to_integer(unsigned(char_pixel_cnt))) = '1' then --foreground
						color_index := to_integer(unsigned(attribut_buffer(7 downto 4)));
					else --background
						color_index := to_integer(unsigned(attribut_buffer(3 downto 0)));
					end if;			
				
					r <= COLOR_TABLE(color_index)(23 downto 16);
					g <= COLOR_TABLE(color_index)(15 downto 8);
					b <= COLOR_TABLE(color_index)(7 downto 0);
					den <= '1'; 
				
				end if;
			end if;
		--end if;
			
	end process;


	fetch : process (decoded_char, attribut_buffer, char_pixel_buffer, colum_cnt, char_pixel_cnt, vram_data, hline_cnt, vertical_display_area)
			variable cur_colum : std_logic_vector(colum_cnt'length-1 downto 0);
	
			variable line_counter : std_logic_vector(log2c(H_LINE_PER_FRAME)-1 downto 0);
			alias cur_char_line : std_logic_vector(4 downto 0) is line_counter(8 downto 4);
			alias cur_char_height : std_logic_vector(3 downto 0) is line_counter(3 downto 0);
	begin
	
		vram_addr_row <= (others=>'0');
		vram_addr_colum <= (others=>'0');
		char <= (others=>'0');
		char_height_pixel <= (others=>'0');
		
		vram_rd <= '0';
		attribut_buffer_next <= attribut_buffer;
		char_pixel_buffer_next <= char_pixel_buffer;
		
		
		if colum_cnt >= (HSBP_CHARS-1) and 
			colum_cnt <= (CHARS_PER_HORIZONTAL_LINE - HSFP_CHARS-2) and vertical_display_area = '1' then	
		
		-- char_pixel_buffer
		-- attribut_buffer
			line_counter := std_logic_vector(to_unsigned(hline_cnt,log2c(H_LINE_PER_FRAME))) - VERTICAL_BACK_PORCH;
			
			if char_pixel_cnt = 3 then
				cur_colum := colum_cnt - HSBP_CHARS + 1;
				vram_addr_colum <= cur_colum(6 downto 0);
				vram_addr_row <= cur_char_line;	
				vram_rd <= '1';
			end if;
			
			
			if char_pixel_cnt = 6 then
				char <= vram_data(7 downto 0);
				char_height_pixel <= cur_char_height;
			end if;
			
			if char_pixel_cnt = 7 then
				char_pixel_buffer_next <= decoded_char;
				attribut_buffer_next <= vram_data(15 downto 8);
			end if;
		
		end if;
		
	end process;


	display_area : process(clk, res_n, clk_cnt, hline_cnt) 
	begin
		vertical_display_area <= '0';

		if hline_cnt >= VERTICAL_BACK_PORCH and --vertical back porch
		hline_cnt < (H_LINE_PER_FRAME - VERTICAL_FRONT_PORCH) then --vertical front porch
			vertical_display_area <= '1';
		end if;

	end process;
end architecture beh;


 



