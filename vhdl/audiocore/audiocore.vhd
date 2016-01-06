
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.audiocore_pkg.all;

library ieee_proposed;
use ieee_proposed.fixed_float_types.all;
use ieee_proposed.fixed_pkg.all;
 
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
		asout_data : out std_logic_vector(7 downto 0);--!Sending bytewise to sgdma
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
	signal clk_top, res_n_top : std_logic;
	signal enq_Iout1, enq_Iout2, enq_Qout1, enq_Qout2 : byte;
	signal enq_validout, enq_outmode : std_logic;
	signal fifoI_validout, fifoQ_validout : std_logic;
	signal fifoI_data_out, fifoQ_data_out : byte;
	signal mixer_Iout, mixer_Qout : sfixed(7 downto -24);
	signal mixer_validout : std_logic;
	signal Ideci_data_out, Qdeci_data_out : sfixed(7 downto -24);
	signal Ideci_validout, Qdeci_validout : std_logic;
	signal FMdemod_data_out : sfixed(7 downto -24);
	signal FMdemod_validout : std_logic;
	signal outlogic_data_out: byte;
	signal outlogic_validout: std_logic;

begin
	clk_top <= clk;
	res_n_top <= res_n;

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
		validout 		=> enq_validout,		
		outmode 		=> enq_outmode
	);

	

	fifoI : FIFO
	port map
	(
		clk 		=> clk_top,
		res_n 		=> res_n_top,

		in1 		=> enq_Iout1,
		in2 		=> enq_Iout2,
		validin 	=> enq_validout,
		inmode 		=> enq_outmode,

		validout 	=> fifoI_validout,
		data_out 	=> fifoI_data_out
	);

	fifoQ : FIFO
	port map
	(
		clk 		=> clk_top,
		res_n 		=> res_n_top,

		in1 		=> enq_Qout1,
		in2 		=> enq_Qout2,
		validin 	=> enq_validout,
		inmode 		=> enq_outmode,

		validout 	=> fifoQ_validout,
		data_out 	=> fifoQ_data_out
	);

	mix : mixerFM
	port map
	(
		clk 		=> clk_top,
		res_n 		=> res_n_top,

		Iin 		=> fifoI_data_out,
		Qin 		=> fifoQ_data_out,
		validin		=> fifoI_validout,	--could also use fifoQ_validout
			
		Iout 		=> mixer_Iout,
		Qout 		=> mixer_Qout,
		validout 	=> mixer_validout
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

		data_in 	=> mixer_Iout,
		validin 	=> mixer_validout,
			
		data_out 	=> Ideci_data_out,
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

		data_in 	=> mixer_Qout,
		validin 	=> mixer_validout,
			
		data_out 	=> Qdeci_data_out,
		validout 	=> Qdeci_validout
	);

	FMdemod : demodulator
	port map
	(
		clk			=> clk_top,
		res_n		=> res_n_top,

		data_in_I	=> Ideci_data_out,
		data_in_Q	=> Qdeci_data_out,
		validin_I	=> Ideci_validout,
		validin_Q	=> Qdeci_validout,

		data_out 	=> FMdemod_data_out,
		validout 	=> FMdemod_validout
	);

	outlogic : outputlogic
	port map
	(
		clk => clk_top,
		res_n => res_n_top,

		data_in => FMdemod_data_out,
		validin => FMdemod_validout,

		data_out => outlogic_data_out,
		validout => outlogic_validout
	);

	outbuffer: outputbuffer
	generic map
	(
		N => 32
	)
	port map
	(
		clk => clk_top,
		res_n => res_n_top,

		data_in => outlogic_data_out,
		validin => outlogic_validout,
		
		ready => asout_ready,
		validout => asout_valid,
		data_out => asout_data
	);

	--Buffer does not send start/end
--	asout_startofpacket <= open;
--	asout_endofpacket <= open;
	
end architecture;

