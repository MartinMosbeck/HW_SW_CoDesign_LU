library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.audiocore_pkg.all;


entity enqueuer is
	port 
	(
		clk 			: in std_logic;
		res_n			: in std_logic;

		valid 			: in std_logic;
		startofpacket	: in std_logic;
		endofpacket 	: in std_logic;

		data_in 		: in sgdma_frame;

		ready_in	: out std_logic;
		
		Iout1 			: out byte;
		Iout2 			: out byte;
		Qout1 			: out byte;
		Qout2 			: out byte; 

		validout 		: out std_logic; -- should FIFO take the data
		outmode 		: out std_logic  -- enqueue 1 or 2
	);
end enqueuer;

architecture behavior of enqueuer is
	type state is 
	(
		IDLE,
		HEADER,
		DATA	
	);
	
	signal state_cur, state_next: state;
	
	signal Iout1_cur, Iout2_cur, Qout1_cur, Qout2_cur : byte;
	signal Iout1_next, Iout2_next, Qout1_next, Qout2_next : byte;

	signal validout_cur, validout_next : std_logic;
	signal outmode_cur, outmode_next : std_logic;

	signal framecounter_cur, framecounter_next : integer range 0 to 16;

	alias byte1 is data_in(31 downto 24);
	alias byte2 is data_in(23 downto 16);
	alias byte3 is data_in(15 downto 8);
	alias byte4 is data_in(7 downto 0);

	signal ready_in_cur, ready_in_next: std_logic;

begin

	---------------------
	-- OUT & STATENEXT --
	---------------------
	out_statenext: process (state_cur,valid,startofpacket,endofpacket,data_in, ready_in_cur, Iout1_cur, Iout2_cur, Qout1_cur, Qout2_cur, validout_cur, outmode_cur, framecounter_cur)
	begin
		-- to avoid latches
		state_next <= state_cur;
		Iout1_next <= Iout1_cur;
		Iout2_next <= Iout2_cur;
		Qout1_next <= Qout1_cur;
		Qout2_next <= Qout2_cur;
		validout_next <= validout_cur;
		outmode_next <= outmode_cur;
		framecounter_next <= framecounter_cur;
		ready_in_next <= ready_in_cur;
	
		-- if not valid stay in state but set validout=0
		if(valid ='0') then
			validout_next <= '0';
			ready_in_next <= '1';
		elsif(valid = '1') then
			case state_cur is
				when IDLE =>
					validout_next <= '0';
					if(startofpacket = '1') then
						framecounter_next <= 1;
						state_next <= HEADER; 
					end if;
				when HEADER =>
					if framecounter_cur = 3 then
						if (byte3 = x"88") and (byte4 = x"b5") then 
							state_next <= DATA;
						else
							state_next <= IDLE;
						end if;
					else
						framecounter_next <= framecounter_cur + 1;
					end if;
				when DATA =>
					if endofpacket = '1' then
						state_next <= IDLE;
						ready_in_next <= '0';
					end if;

					Iout1_next <= byte1;
					Qout1_next <= byte2;
					Iout2_next <= byte3;
					Qout2_next <= byte4;
					validout_next <= '1';
					outmode_next <= '1';
			end case;
		end if;
	end process out_statenext;
	

	----------
	-- SYNC --
	----------
	sync: process (clk,res_n)
		
	begin
		if res_n = '0' then
	
			--defaults
			state_cur <= IDLE;
			Iout1_cur <= (others=>'0');
			Iout2_cur <= (others=>'0');
			Qout1_cur <= (others=>'0');
			Qout2_cur <= (others=>'0');
			validout_cur <= '0';
			outmode_cur <= '0';
			framecounter_cur <= 0;
			ready_in_cur <= '0';
	
		elsif rising_edge(clk) then
			-- internal
			state_cur <= state_next;
			Iout1_cur <= Iout1_next;
			Iout2_cur <= Iout2_next;
			Qout1_cur <= Qout1_next;
			Qout2_cur <= Qout2_next;
			validout_cur <= validout_next;
			outmode_cur <= outmode_next;
			framecounter_cur <= framecounter_next;
			ready_in_cur <= ready_in_next;
			
			-- outputs
			Iout1 <= Iout1_next;	
			Iout2 <= Iout2_next;	
			Qout1 <= Qout1_next;	
			Qout2 <= Qout2_next;	
			validout <= validout_next;	
			outmode <= outmode_next;
			ready_in <= ready_in_next;
		end if;		
	
	end process sync;
end behavior;
