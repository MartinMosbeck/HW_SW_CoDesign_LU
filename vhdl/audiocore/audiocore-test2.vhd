
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.audiocore_pkg.all;
 
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
		asout_ready : in std_logic;
		
		--debug output
		gpio_0_31 : out std_logic_vector(31 downto 0);--asout_data
		gpio_32 : out std_logic;--valid
		gpio_33 : out std_logic;--ready
		gpio_34 : out std_logic--clk
	);
end entity;

-----------------------------------------------------------------
-------------------- BEGIN OF ARCHITECTURE ----------------------
-----------------------------------------------------------------
architecture rtl of audiocore is
	signal clk_top, res_n_top : std_logic;
	signal enq_Iout1, enq_Iout2, enq_Qout1, enq_Qout2 : byte;
	signal enq_validout : std_logic;
	signal fifoI_validout, fifoQ_validout : std_logic;
	signal fifoI_data_out, fifoQ_data_out : byte;
	signal mixer_Iout, mixer_Qout : fixpoint;
	signal mixer_validout : std_logic;
	signal Ideci_data_out, Qdeci_data_out : fixpoint;
	signal Ideci_validout, Qdeci_validout : std_logic;
	signal FMdemod_data_out : fixpoint;
	signal FMdemod_validout : std_logic;
	signal outlogic_data_out: byte;
	signal outlogic_validout: std_logic;

	signal fifoIbyte, fifoQbyte: fixpoint;
	
	signal outvalid: std_logic;
	signal outdata: std_logic_vector(31 downto 0);

begin
	clk_top <= clk;
	res_n_top <= res_n;
	asin_ready<='1';

	--debug
	gpio_0_31 <= outdata;
	gpio_32 <= outvalid;
	gpio_33 <= asout_ready;
	gpio_34 <= clk;
	
	enq : enqueuer 
	port map
	(
		clk 			=> clk_top,
		res_n 			=> res_n_top,	
		valid 			=> asin_valid,	
		startofpacket	=> asin_startofpacket,	
		endofpacket 	=> asin_endofpacket,	
		data_in 		=> asin_data,
		
		Iout1 			=> enq_Iout1,			
		Iout2 			=> enq_Iout2,		
		Qout1 			=> enq_Qout1,		
		Qout2 			=> enq_Qout2,		
		validout 		=> enq_validout
	);

	fifoI : FIFO
	generic map
	(
		N => 32
	)
	port map
	(
		clk 		=> clk_top,
		res_n 		=> res_n_top,

		in1 		=> enq_Iout1,
		in2 		=> enq_Iout2,
		validin 	=> enq_validout,

		validout 	=> fifoI_validout,
		data_out 	=> fifoI_data_out
	);

	fifoQ : FIFO
	generic map
	(
		N => 32
	)
	port map
	(
		clk 		=> clk_top,
		res_n 		=> res_n_top,

		in1 		=> enq_Qout1,
		in2 		=> enq_Qout2,
		validin 	=> enq_validout,

		validout 	=> fifoQ_validout,
		data_out 	=> fifoQ_data_out
	);

	Ideci : decimator
	generic map
	(
		N => 20
	)
	port map
	(
		clk 		=> clk_top,
		res_n		=> res_n_top,

		data_in (7 downto 0)	=> signed(fifoI_data_out),
		validin 	=> fifoI_validout,
			
		data_out 	=> fifoIbyte,
		validout 	=> Ideci_validout
	);

	Qdeci : decimator
	generic map
	(
		N => 20
	)
	port map
	(
		clk 		=> clk_top,
		res_n		=> res_n_top,

		data_in(7 downto 0) 	=> signed(fifoQ_data_out),
		validin 	=> fifoQ_validout,
			
		data_out 	=> fifoQbyte,
		validout 	=> Qdeci_validout
	);

	--TEST 2
	FII_FOO : FIFO
	generic map
	(
		N => 128
	)
	port map
	(
		clk 		=> clk_top,
		res_n 		=> res_n_top,

		in1 		=> std_logic_vector(fifoIbyte(7 downto 0)),
		in2 		=> std_logic_vector(fifoQbyte(7 downto 0)),
		validin 	=> Ideci_validout,

		validout 	=> outlogic_validout,
		data_out 	=> outlogic_data_out
	);

	outbuffer: outputbuffer
	generic map
	(
		N => 512--testweise 4096, eher besser mit 512
	)
	port map
	(
		clk => clk_top,
		res_n => res_n_top,

		data_in => outlogic_data_out,
		validin => outlogic_validout,
		
		ready => asout_ready,
		validout => outvalid,
		data_out => outdata
	);
	asout_valid<=outvalid;
	asout_data<=outdata;

	--Buffer does not send start/end
	asout_startofpacket <= '0';
	asout_endofpacket <= '0';
	
end architecture;
