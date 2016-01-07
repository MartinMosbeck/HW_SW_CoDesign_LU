library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.fixed_alg_pkg.all;

package audiocore_pkg is
	subtype byte is std_logic_vector(7 downto 0);
	subtype sgdma_frame is std_logic_vector(31 downto 0);
	subtype index_time is integer range 0 to 24; 
	subtype fixpoint is signed(31 downto 0);
	subtype fixpoint_product is signed(63 downto 0);

	component enqueuer is
		port
		(
			clk 			: in std_logic;
			res_n 			: in std_logic;

			valid 			: in std_logic;
			startofpacket	: in std_logic;
			endofpacket 	: in std_logic;

			data_in 		: in sgdma_frame;
			
			Iout1 			: out byte;
			Iout2 			: out byte;
			Qout1 			: out byte;
			Qout2 			: out byte; 

			validout 		: out std_logic; -- should FIFO take the data
			outmode 		: out std_logic  -- enqueue 1 or 2
		);
	end component;

	component FIFO is
		port
		(
			clk : in std_logic;
			res_n : in std_logic;

			in1 : in byte;
			in2 : in byte;
			validin : in std_logic;
			inmode : in std_logic;

			validout : out std_logic;
			data_out : out byte
		);
	end component;

	component mixerFM is
		port
		(
			clk : in std_logic;
			res_n : in std_logic;

			Iin : in byte;
			Qin : in byte;
			validin : in std_logic;
			
			Iout : out fixpoint;
			Qout : out fixpoint;
			validout : out std_logic	
		);
	end component;

	component decimator is
		generic 
		(
			N : integer
		);	
		port 
		(
			clk : in std_logic;
			res_n : in std_logic;

			data_in : in fixpoint;
			validin : in std_logic;
			
			data_out : out fixpoint;
			validout : out std_logic
		);	
	end component;

	component demodulator is
		port 
		(
			clk : in std_logic;
			res_n: in std_logic;

			data_in_I : in fixpoint;
			data_in_Q : in fixpoint;
			validin_I : in std_logic;
			validin_Q : in std_logic;
			
			data_out : out fixpoint;
			validout : out std_logic
		);
	end component;


	component outputbuffer is
		generic
		(
			N: natural := 32
		);
		port 
		(
			clk : in std_logic;
			res_n : in std_logic;

			data_in : in byte;
			validin : in std_logic;
			
			ready: in std_logic;
			validout : out std_logic;
			data_out : out byte
		);
	end component;

	component outputlogic is
		port 
		(
			clk : in std_logic;
			res_n : in std_logic;

			data_in : in fixpoint;
			validin : in std_logic;
			
			data_out : out byte;
			validout : out std_logic
		);
	end component;

end package audiocore_pkg;
