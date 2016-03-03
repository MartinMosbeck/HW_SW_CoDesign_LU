library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.audiocore_pkg.all;

entity outputbuffer is
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
end outputbuffer;

architecture behavior of outputbuffer is
	type state is
	(
		IDLE,
		WART
	);
	signal state_cur, state_next: state;

	type buffer_type is array (N-1 downto 0) of fixpoint;
	subtype bufferpos is integer range 0 to N-1;

	signal fields_cur, fields_next : buffer_type;

	signal rpos_cur, rpos_next , wpos_cur, wpos_next : bufferpos; 

	signal data_out_cur, data_out_next : std_logic_vector(31 downto 0);

	signal validout_cur, validout_next : std_logic;

	signal packetcnt, packetcnt_next: integer range 0 to 255; 

	subtype cntpos is integer range 0 to N;
	signal data_cnt_next, data_cnt_cur: cntpos;

	
	function pos_plus1(pos : bufferpos)
		return bufferpos is
	begin
		if pos = N-1 then
			return 0;
		else
			return pos + 1;
		end if;
	end pos_plus1;
	
begin
	------------------
	-- FIFO action --
	------------------
	outputbuffer_action: process (validin,data_in,ready, fields_cur, rpos_cur, wpos_cur, data_out_cur, validout_cur, packetcnt, state_cur, data_cnt_cur)
	variable data1,data2,data3,data4: byte;
	variable full:std_logic:='0';
	begin
		-- to avoid latches
		fields_next <= fields_cur;
		rpos_next <= rpos_cur;
		wpos_next <= wpos_cur;
		data_out_next <= data_out_cur;
		validout_next <= validout_cur;
		packetcnt_next <= packetcnt;

		data_cnt_next<=data_cnt_cur;

		state_next <= state_cur;

		--FUNZT NOCH NED
		--if data_cnt_cur = N then
		--	full:='1';
		--end if;
		--if data_cnt_cur = 0 then
		--	full:='0';
		--end if;

		if validin = '1' and data_cnt_cur > 4 and state_cur = IDLE and packetcnt /= 255 and ready = '1' then-- and full='0' then
			data_cnt_next <= data_cnt_cur;
		elsif validin = '1' then --and full='0' then
			data_cnt_next <= data_cnt_cur + 1;
		elsif data_cnt_cur > 4 and state_cur = IDLE and packetcnt /= 255 and ready = '1' then
			data_cnt_next <= data_cnt_cur - 1;
		end if;

		-- action at in
		if validin = '1' then --and full='0' then
			fields_next(wpos_cur) <= data_in;
			wpos_next <= pos_plus1(wpos_cur);
		end if;

		-- action at out
		if data_cnt_cur > 4 and packetcnt /= 255 and ready = '1' then
			case state_cur is
				when IDLE=>
					--data1:=fields_cur(rpos_cur);
					--data2:=fields_cur(pos_plus1(rpos_cur));
					--data3:=fields_cur(pos_plus1(pos_plus1(rpos_cur)));
					--data4:=fields_cur(pos_plus1(pos_plus1(pos_plus1(rpos_cur))));
					data_out_next <= std_logic_vector(fields_cur(rpos_cur));--data1 & data2 & data3 & data4;
					validout_next <= '1';
					rpos_next <= pos_plus1(rpos_cur);
					packetcnt_next <= pos_plus1(pos_plus1(pos_plus1(pos_plus1(packetcnt))));
					state_next <= WART;
				when WART=>
					state_next <= IDLE;
			end case;
		elsif packetcnt = 255 then
			packetcnt_next <= 0;
			validout_next <= '0';
		else
			validout_next <= '0';
		end if;	

	end process outputbuffer_action;

	----------
	-- SYNC --
	----------
	sync: process (clk,res_n)
		
	begin
		if res_n = '0' then
			--defaults
			fields_cur <= (others=>(others=>'0'));
			rpos_cur <= 0;
			wpos_cur <= 0;
			data_out_cur <= (others=>'0');
			validout_cur <= '0';
			packetcnt <= 0;
			data_cnt_cur<=0;

			state_cur <= IDLE;

		elsif rising_edge(clk) then
			-- internal
			fields_cur <= fields_next;
			rpos_cur <= rpos_next;
			wpos_cur <= wpos_next;
			data_out_cur <= data_out_next;
			validout_cur <= validout_next;
			packetcnt <= packetcnt_next;

			data_cnt_cur <= data_cnt_next;

			state_cur <= state_next;
			
			-- outputs
			data_out <= data_out_next;
			validout <= validout_next;
		end if;
	end process sync;
end behavior;
