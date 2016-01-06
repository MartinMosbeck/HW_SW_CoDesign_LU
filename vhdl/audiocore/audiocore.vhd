
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--library work;
--use work.fir_package.all;


entity audiocore is
	port (
		clk   : in std_logic;
		res_n : in std_logic;
		
		-- stream input
		asin_data : in std_logic_vector(31 downto 0);
		asin_startofpacket : in std_logic;
		asin_endofpacket : in std_logic;
		asin_valid : in std_logic;
		asin_ready : out std_logic;
		
		-- stream output
		asout_data : out std_logic_vector(31 downto 0);
		asout_startofpacket : out std_logic;
		asout_endofpacket : out std_logic;
		asout_valid : out std_logic;
		asout_ready : in std_logic
	);
end entity;

-----------------------------------------------------------------
-------------------- BEGIN OF ARCHITECTURE ----------------------
-----------------------------------------------------------------
architecture rtl of audiocore is
	signal clk_top, rst_n_top : std_logic;
	
begin
	clk_top <= clk;
	rst_n_top <= rst_n;

	enq : enqueuer 
	port map
	(
		clk 			=> clk_top,
		rst_n 			=> rst_n_top,	
		valid 			=>,	
		startofpacket	=>,	
		endofpacket 	=>,	
		data_in 		=>,	
		
		Iout1 			=>,			
		Iout2 			=>,		
		Qout1 			=>,		
		Qout2 			=>,		
		outvalid 		=>,		
		outmode 		=>		
	);

	fifoI : FIFO
	port map
	(
		clk 		=> clk_top,
		rst_n 		=> rst_n_top,

		in1 		=>,
		in2 		=>,
		invalid 	=>,
		inmode 		=>,

		outvalid 	=>,
		data_out 	=>
	);

	fifoQ : FIFO
	port map
	(
		clk 		=> clk_top,
		rst_n 		=> rst_n_top,

		in1 		=>,
		in2 		=>,
		invalid 	=>,
		inmode 		=>,

		outvalid 	=>,
		data_out 	=>
	);

	mix : mixerFM
	port map
	(
		clk 		=> clk_top,
		rst_n 		=> rst_n_top,

		Iin 		=>,
		Qin 		=>,
		invalid 	=>,
			
		Iout 		=>,
		Qout 		=>,
		outvalid 	=>,
	);

	deci : decimator
	generic map
	(
		N => 20
	)
	port map
	(
		clk 		=> clk_top,
		rst_n		=> rst_n_top,

		data_in 	=>,
		invalid 	=>,
			
		data_out 	=>,
		outvalid 	=>
	);

	
end architecture;

