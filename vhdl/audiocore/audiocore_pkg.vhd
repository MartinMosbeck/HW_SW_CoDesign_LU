library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package audiocore_pkg is
	subtype byte is std_logic_vector(7 downto 0);
	subtype sgdma_frame is std_logic_vector(31 downto 0);
	subtype index_time is integer range 0 to 24; 
	subtype index is natural;
	subtype fixpoint is signed(31 downto 0);
	subtype fixpoint_product is signed(63 downto 0);

	type fixpoint_array is array(natural range <>) of fixpoint; 

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

			validout 		: out std_logic -- should FIFO take the data
		);
	end component;

	component FIFO is
		generic
		(
			N: natural := 32
		);
		port
		(
			clk : in std_logic;
			res_n : in std_logic;

			in1 : in byte;
			in2 : in byte;
			validin : in std_logic;

			validout : out std_logic;
			data_out : out byte
		);
	end component;

	--Temp fürs Debuggen (fixpointFIFO)
	component fixFIFO is
		generic
		(
			N: natural := 32
		);
		port
		(
			clk : in std_logic;
			res_n : in std_logic;

			in1 : in fixpoint;
			in2 : in fixpoint;
			validin : in std_logic;

			validout : out std_logic;
			data_out : out fixpoint
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
			data_out : out std_logic_vector(31 downto 0)
		);
	end component;
	
	component qp_ram is
		generic
		(
			ADDR_WIDTH : integer range 1 to integer'high;
			DATA_WIDTH : integer range 1 to integer'high
		);
		port
		(
			clk : in std_logic;
			address1 : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
			address2 : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
			address3 : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
			address4 : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
			data_out1 : out std_logic_vector(DATA_WIDTH - 1 downto 0);
			data_out2 : out std_logic_vector(DATA_WIDTH - 1 downto 0);
			data_out3 : out std_logic_vector(DATA_WIDTH - 1 downto 0);
			data_out4 : out std_logic_vector(DATA_WIDTH - 1 downto 0);
			address5 : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
			wr : in std_logic;
			data_in : in std_logic_vector(DATA_WIDTH - 1 downto 0)
		);
	end component;
	
	component IIRFilter is
	port 
	(
		clk 		: in std_logic;
		res_n 		: in std_logic;

		data_in 	: in fixpoint;
		validin 	: in std_logic;

		data_out 	: out fixpoint;
		validout 	: out std_logic
	);
	end component;
	
	component dp_ram is
	generic
	(
		ADDR_WIDTH : integer range 1 to integer'high
	);
	port
	(
		clk : in std_logic;
		address_out : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
		data_out : out fixpoint;
		address_in : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
		wr : in std_logic;
		data_in : in fixpoint
	);
	end component;
	
	component tp_ram is
	generic
	(
		ADDR_WIDTH : integer range 1 to integer'high
	);
	port
	(
		clk : in std_logic;
		address_out : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
		data_out : out byte;
		address_in1 : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
		address_in2 : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
		wr : in std_logic;
		data_in1 : in byte;
		data_in2 : in byte
	);
	end component;
	
	component IIRFilter_Buffer is
	generic
	(
		N: natural := 32
	);
	port 
	(
		clk : in std_logic;
		res_n : in std_logic;

		data_in : in fixpoint;
		validin : in std_logic;

		rdy : in std_logic;
		validout : out std_logic;
		data_out : out fixpoint
	);
	end component;
	
	component outputbuffer_debug is
	generic
	(
		N: natural := 32
	);
	port 
	(
		clk : in std_logic;
		res_n : in std_logic;

		data_in : in fixpoint;
		validin : in std_logic;
		
		ready: in std_logic;
		validout : out std_logic;
		data_out : out std_logic_vector(31 downto 0)
	);
	end component;
	
	component output_mem is
	generic
	(
		N: natural := 2048
	);
	port 
	(
		clk : in std_logic;
		res_n : in std_logic;

		data_in : in byte;
		validin : in std_logic;
		
		audiooutleft_data : out std_logic_vector(31 downto 0);
		audiooutleft_ready : in std_logic;
		audiooutleft_valid : out std_logic;
		
		audiooutright_data : out std_logic_vector(31 downto 0);
		audiooutright_ready : in std_logic;
		audiooutright_valid : out std_logic
	);
	end component;
	
	component dp_ram_std is
	generic
	(
		ADDR_WIDTH : integer range 1 to integer'high;
		DATA_WIDTH : integer range 1 to integer'high
	);
	port
	(
		clk : in std_logic;
		address_out : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
		data_out : out std_logic_vector(DATA_WIDTH - 1 downto 0);
		address_in : in std_logic_vector(ADDR_WIDTH - 1 downto 0);
		wr : in std_logic;
		data_in : in std_logic_vector(DATA_WIDTH - 1 downto 0)
	);
	end component;
	
	component IIRFilter_audioout is	
	port 
	(
		clk 		: in std_logic;
		res_n 		: in std_logic;

		data_in 	: in fixpoint;
		validin 	: in std_logic;

		data_out 	: out fixpoint;
		validout 	: out std_logic
	);
	end component;

	component FIRFilter is
	port
	(
		clk 		: in std_logic;
		res_n 		: in std_logic;

		data_in 	: in fixpoint;
		validin 	: in std_logic;

		data_out 	: out fixpoint;
		validout 	: out std_logic
	);
	end component;

	component fixpoint_magnitude is
	port
	(
		clk			: in std_logic;
		res_n		: in std_logic;
		valid_in	: in std_logic;
		data_in		: in fixpoint;

		valid_out	: out std_logic;
		data_out	: out fixpoint;

		-- durchschleifen von I und Q
		I_in	: in fixpoint;
		I_out	: out fixpoint;
		Q_in	: in fixpoint;
		Q_out	: out fixpoint
	);
	end component;
	
	component FIRFilter_demod is
	port 
	(
		clk 		: in std_logic;
		res_n 		: in std_logic;

		data_in 	: in fixpoint;
		validin 	: in std_logic;

		data_out 	: out fixpoint;
		validout 	: out std_logic
	);
	end component;
	
	component demodulator_FIR is
	port 
	(
		clk : in std_logic;
		res_n : in std_logic;

		data_in_I : in fixpoint;
		data_in_Q : in fixpoint;
		validin_I : in std_logic;
		validin_Q : in std_logic;
		
		data_out : out fixpoint;
		validout : out std_logic
	);
	end component;
end package audiocore_pkg;
