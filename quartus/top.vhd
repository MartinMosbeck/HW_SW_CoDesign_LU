library ieee;
use ieee.std_logic_1164.all; 

use work.sync_pkg.all;

entity top is 
	port (
		CLOCK_50      : in std_logic;
		KEY           : in std_logic_vector(0 downto 0);
		
		-- LTM
		LTM_CLK       : out   std_logic;                        -- clk
		LTM_GREST     : out   std_logic;                        -- grest
		LTM_DEN       : out   std_logic;                        -- den
		LTM_HD        : out   std_logic;                        -- hd
		LTM_VD        : out   std_logic;                        -- vd 
		LTM_R         : out   std_logic_vector(7 downto 0);     -- r
		LTM_G         : out   std_logic_vector(7 downto 0);     -- g
		LTM_B         : out   std_logic_vector(7 downto 0);     -- b

		-- Ethernet 0
		ENET0_GTX_CLK : out std_logic;
		ENET0_MDC     : out std_logic;
		ENET0_MDIO    : inout std_logic;
		ENET0_RESET_N : out std_logic;
		ENET0_RX_CLK  : in std_logic;
		ENET0_RX_DATA : in std_logic_vector(3 downto 0);
		ENET0_RX_DV   : in std_logic;
		ENET0_TX_DATA : out std_logic_vector(3 downto 0);
		ENET0_TX_EN   : out std_logic;
		
		DRAM_ADDR     : out std_logic_vector(12 downto 0);
		DRAM_BA       : out std_logic_vector(1 downto 0);
		DRAM_CAS_N    : out std_logic;
		DRAM_CKE      : out std_logic;
		DRAM_CS_N     : out std_logic;
		DRAM_DQ       : inout std_logic_vector(31 downto 0) := (others => 'X');
		DRAM_DQM      : out std_logic_vector (3 downto 0);
		DRAM_RAS_N    : out std_logic;
		DRAM_WE_N     : out std_logic;
		DRAM_CLK      : out std_logic;
		
		I2C_SDAT      : inout std_logic;
		I2C_SCLK      : out std_logic;
		
		AUD_BCLK      : in    std_logic  := 'X'; 
		AUD_DACDAT    : out   std_logic; 
		AUD_DACLRCK   : in    std_logic  := 'X';
		AUD_XCK       : out   std_logic
);
end entity;



architecture arch of top is
	signal sys_clk, clk_125, clk_25, clk_2p5, tx_clk : std_logic;
	signal res_n : std_logic;
	signal mdc, mdio_in, mdio_oen, mdio_out : std_logic;
	signal eth_mode, ena_10 : std_logic;
	
	--signal key_n : std_logic;
	--signal pll_locked, pll_locked_n : std_logic;

   component tse_tutorial is
        port (
            clk_clk                             : in    std_logic                     := 'X';             -- clk
            clk_125_clk                         : out   std_logic;                                        -- clk
            clk_25_clk                          : out   std_logic;                                        -- clk
            clk_2p5_clk                         : out   std_logic;                                        -- clk
            reset_reset_n                       : in    std_logic                     := 'X';             -- reset_n
            
				textmode_vd                         : out   std_logic;                                        -- vd
            textmode_den                        : out   std_logic;                                        -- den
            textmode_r                          : out   std_logic_vector(7 downto 0);                     -- r
            textmode_g                          : out   std_logic_vector(7 downto 0);                     -- g
            textmode_b                          : out   std_logic_vector(7 downto 0);                     -- b
            textmode_grest                      : out   std_logic;                                        -- grest
            textmode_hd                         : out   std_logic;
				
				tse_mac_mdio_connection_mdc         : out   std_logic;                                        -- mdc
            tse_mac_mdio_connection_mdio_in     : in    std_logic                     := 'X';             -- mdio_in
            tse_mac_mdio_connection_mdio_out    : out   std_logic;                                        -- mdio_out
            tse_mac_mdio_connection_mdio_oen    : out   std_logic;                                        -- mdio_oen
            tse_mac_rgmii_connection_rgmii_in   : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- rgmii_in
            tse_mac_rgmii_connection_rgmii_out  : out   std_logic_vector(3 downto 0);                     -- rgmii_out
            tse_mac_rgmii_connection_rx_control : in    std_logic                     := 'X';             -- rx_control
            tse_mac_rgmii_connection_tx_control : out   std_logic;                                        -- tx_control
            tse_mac_status_connection_set_10    : in    std_logic                     := 'X';             -- set_10
            tse_mac_status_connection_set_1000  : in    std_logic                     := 'X';             -- set_1000
            tse_mac_status_connection_eth_mode  : out   std_logic;                                        -- eth_mode
            tse_mac_status_connection_ena_10    : out   std_logic;                                        -- ena_10
            tse_pcs_mac_rx_clock_connection_clk : in    std_logic                     := 'X';             -- clk
            tse_pcs_mac_tx_clock_connection_clk : in    std_logic                     := 'X';             -- clk
            sdram_addr                          : out   std_logic_vector(12 downto 0);                    -- addr
            sdram_ba                            : out   std_logic_vector(1 downto 0);                     -- ba
            sdram_cas_n                         : out   std_logic;                                        -- cas_n
            sdram_cke                           : out   std_logic;                                        -- cke
            sdram_cs_n                          : out   std_logic;                                        -- cs_n
            sdram_dq                            : inout std_logic_vector(31 downto 0) := (others => 'X'); -- dq
            sdram_dqm                           : out   std_logic_vector(3 downto 0);                     -- dqm
            sdram_ras_n                         : out   std_logic;                                        -- ras_n
            sdram_we_n                          : out   std_logic;                                        -- we_n
				sdram_clk_clk                       : out   std_logic;                                         -- clk
				
            audio_config_SDAT                   : inout std_logic                     := 'X';             -- SDAT
				audio_config_SCLK                   : out   std_logic;                                        -- SCLK
				
            audio_BCLK                          : in    std_logic                     := 'X';             -- BCLK
            audio_DACDAT                        : out   std_logic;                                        -- DACDAT
            audio_DACLRCK                       : in    std_logic                     := 'X';             -- DACLRCK
				audio_clk_clk                       : out   std_logic                                         -- audio clock
        );
    end component tse_tutorial;
	
	component my_ddio_out2 is
		port (
			datain_h		: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
			datain_l		: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
			outclock		: IN STD_LOGIC ;
			dataout		: OUT STD_LOGIC_VECTOR (0 DOWNTO 0)
		);
	end component;
	
begin

	mdio_in    <= ENET0_MDIO;
	ENET0_MDC  <= mdc;
	ENET0_MDIO <= 'Z' when mdio_oen = '1' else mdio_out;
	
	ENET0_RESET_N <= res_n;

	tx_clk <= clk_125 when eth_mode = '1' else -- GbE Mode   = 125MHz clock
	          clk_2p5 when eth_mode = '0' and ena_10 = '1' else   -- 10Mb Mode  = 2.5MHz clock
	          clk_25;                          -- 100Mb Mode = 25 MHz clock

	ddio_out_inst : my_ddio_out2
		port map(
			datain_h   => "1",
			datain_l   => "0",
			outclock   => tx_clk,
			dataout(0) => ENET0_GTX_CLK
		);
		
	--key_n <= not KEY(0);
	
	sync_inst : sync
		generic map
		(
			SYNC_STAGES => 2,
			RESET_VALUE => '0'
		)
		port map
		(
			sys_clk   => CLOCK_50,
			sys_res_n => '1',
			data_in   => KEY(0),
			data_out  => res_n
		);

	u0 : component tse_tutorial
		port map (
			clk_clk                             => CLOCK_50,
			clk_125_clk                         => clk_125,
         clk_25_clk                          => clk_25, 
         clk_2p5_clk                         => clk_2p5,
			reset_reset_n                       => res_n,
			
			textmode_grest                      => LTM_GREST,
			textmode_vd                         => LTM_VD,
			textmode_hd                         => LTM_HD,
			textmode_den                        => LTM_DEN,
			textmode_r                          => LTM_R,
			textmode_g                          => LTM_G,
			textmode_b                          => LTM_B,
		
			tse_mac_mdio_connection_mdc         => mdc,
			tse_mac_mdio_connection_mdio_in     => mdio_in,
			tse_mac_mdio_connection_mdio_out    => mdio_out,
			tse_mac_mdio_connection_mdio_oen    => mdio_oen,
			tse_mac_rgmii_connection_rgmii_in   => ENET0_RX_DATA, 
			tse_mac_rgmii_connection_rgmii_out  => ENET0_TX_DATA,
			tse_mac_rgmii_connection_rx_control => ENET0_RX_DV,
			tse_mac_rgmii_connection_tx_control => ENET0_TX_EN,
			tse_mac_status_connection_set_10    => 'X',
			tse_mac_status_connection_set_1000  => 'X',
			tse_mac_status_connection_eth_mode  => eth_mode,
			tse_mac_status_connection_ena_10    => ena_10,
			tse_pcs_mac_rx_clock_connection_clk => ENET0_RX_CLK,
			tse_pcs_mac_tx_clock_connection_clk => tx_clk,
			
			sdram_addr                          => DRAM_ADDR,
			sdram_ba                            => DRAM_BA,
			sdram_cas_n                         => DRAM_CAS_N,
			sdram_cke                           => DRAM_CKE,
			sdram_cs_n                          => DRAM_CS_N,
			sdram_dq                            => DRAM_DQ,
			sdram_dqm                           => DRAM_DQM,
			sdram_ras_n                         => DRAM_RAS_N,
			sdram_we_n         						=> DRAM_WE_N,
			sdram_clk_clk                       => DRAM_CLK,
			
			audio_config_SDAT                   => I2C_SDAT,
			audio_config_SCLK                   => I2C_SCLK,
			
			audio_BCLK                          => AUD_BCLK,
			audio_DACDAT                        => AUD_DACDAT,
			audio_DACLRCK                       => AUD_DACLRCK,
			audio_clk_clk                       => AUD_XCK
		);
		
		LTM_CLK <= clk_25;

end architecture;

