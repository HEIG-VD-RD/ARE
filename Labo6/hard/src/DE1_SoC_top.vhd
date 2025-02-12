------------------------------------------------------------------------------------------
-- HEIG-VD
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : DE1_SoC_top.vhd
-- Author               : Anthony Convers
-- Date                 : 13.07.2022
--
-- Context              : ARE
--
------------------------------------------------------------------------------------------
-- Description : top design for DE1-SoC board
--
------------------------------------------------------------------------------------------
-- Dependencies :
--
------------------------------------------------------------------------------------------
-- Modifications :
-- Ver    Date        Engineer      Comments
-- 0.0    13.07.2022  ACS           Initial version.
--
------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity DE1_SoC_top is
    port ( -- clock pins
           CLOCK_50_i  : in  std_logic;
           CLOCK2_50_i : in  std_logic;
           CLOCK3_50_i : in  std_logic;
           CLOCK4_50_i : in  std_logic;

           -- ADC
           ADC_CS_N_o : out std_logic;
           ADC_DIN_o  : out std_logic;
           ADC_DOUT_i : in std_logic;
           ADC_SCLK_o : out std_logic;

           -- Audio
           AUD_ADCLRCK_io : inout std_logic;
           AUD_ADCDAT_i   : in std_logic;
           AUD_DACLRCK_io : inout std_logic;
           AUD_DACDAT_o   : out std_logic;
           AUD_XCK_o      : out std_logic;
           AUD_BCLK_io    : inout std_logic;

           -- SDRAM
           DRAM_ADDR_o  : out std_logic_vector(12 downto 0);
           DRAM_BA_o    : out std_logic_vector(1 downto 0);
           DRAM_CAS_N_o : out std_logic;
           DRAM_CKE_o   : out std_logic;
           DRAM_CLK_o   : out std_logic;
           DRAM_CS_N_o  : out std_logic;
           DRAM_DQ_io   : inout std_logic_vector(15 downto 0);
           DRAM_LDQM_o  : out std_logic;
           DRAM_RAS_N_o : out std_logic;
           DRAM_UDQM_o  : out std_logic;
           DRAM_WE_N_o  : out std_logic;

           --I2C Bus for Configuration of the Audio and Video-In Chips
           FPGA_I2C_SCLK_o  : out std_logic;
           FPGA_I2C_SDAT_io : inout std_logic;

           -- 40-pin headers
           GPIO_0_io    : inout std_logic_vector(35 downto 0);
           GPIO_1_io    : inout std_logic_vector(35 downto 0);

           -- Seven Segment Displays
           HEX0_o       : out std_logic_vector(6 downto 0);
           HEX1_o       : out std_logic_vector(6 downto 0);
           HEX2_o       : out std_logic_vector(6 downto 0);
           HEX3_o       : out std_logic_vector(6 downto 0);
           HEX4_o       : out std_logic_vector(6 downto 0);
           HEX5_o       : out std_logic_vector(6 downto 0);

           -- IR
           IRDA_RXD_i   : in std_logic;
           IRDA_TXD_o   : out std_logic;

           -- Pushbuttons
           KEY_i        : in std_logic_vector(3 downto 0);

           -- LEDs
           LEDR_o       : out std_logic_vector(9 downto 0);

           -- PS2 Ports
           PS2_CLK_io   : inout std_logic;
           PS2_DAT_io   : inout std_logic;
           PS2_CLK2_io  : inout std_logic;
           PS2_DAT2_io  : inout std_logic;

           -- Slider Switches
           SW_i         : in std_logic_vector(9 downto 0);

           -- Video-In
           TD_CLK27_i   : in std_logic;
           TD_DATA_i    : in std_logic_vector(7 downto 0);
           TD_HS_i      : in std_logic;
           TD_RESET_N_o : out std_logic;
           TD_VS_i      : in std_logic;
           
           -- VGA
           VGA_R_o       : out std_logic_vector(7 downto 0);
           VGA_G_o       : out std_logic_vector(7 downto 0);
           VGA_B_o       : out std_logic_vector(7 downto 0);
           VGA_CLK_o     : out std_logic;
           VGA_SYNC_N_o  : out std_logic;
           VGA_BLANK_N_o : out std_logic;
           VGA_HS_o      : out std_logic;
           VGA_VS_o      : out std_logic;
           
           -- DDR3 SDRAM
           HPS_DDR3_ADDR_o      : out std_logic_vector(14 downto 0);
           HPS_DDR3_BA_o        : out std_logic_vector(2 downto 0);
           HPS_DDR3_CAS_N_o     : out std_logic;
           HPS_DDR3_CKE_o       : out std_logic;
           HPS_DDR3_CK_N_o      : out std_logic;
           HPS_DDR3_CK_P_o      : out std_logic;
           HPS_DDR3_CS_N_o      : out std_logic;
           HPS_DDR3_DM_o        : out std_logic_vector(3 downto 0);
           HPS_DDR3_DQ_io       : inout std_logic_vector(31 downto 0);
           HPS_DDR3_DQS_N_io    : inout std_logic_vector(3 downto 0);
           HPS_DDR3_DQS_P_io    : inout std_logic_vector(3 downto 0);
           HPS_DDR3_ODT_o       : out std_logic;
           HPS_DDR3_RAS_N_o     : out std_logic;
           HPS_DDR3_RESET_N_o   : out std_logic;
           HPS_DDR3_RZQ_i       : in std_logic;
           HPS_DDR3_WE_N_o      : out std_logic;

           -- Ethernet
           --HPS_ENET_GTX_CLK_o   : out std_logic;
           --HPS_ENET_INT_N_io    : inout std_logic;
           --HPS_ENET_MDC_o       : out std_logic;
           --HPS_ENET_MDIO_io     : inout std_logic;
           --HPS_ENET_RX_CLK_i    : in std_logic;
           --HPS_ENET_RX_DATA_i   : in std_logic_vector(3 downto 0);
           --HPS_ENET_RX_DV_i     : in std_logic;
           --HPS_ENET_TX_DATA_o   : out std_logic_vector(3 downto 0);
           --HPS_ENET_TX_EN_o     : out std_logic;
           
           -- Flash
           --HPS_FLASH_DATA_io    : inout std_logic_vector(3 downto 0);
           --HPS_FLASH_DCLK_o     : out std_logic;
           --HPS_FLASH_NCSO_o     : out std_logic;

           -- Accelerometer
           --HPS_GSENSOR_INT_io   : inout std_logic;

           -- General Purpose I/O
           --HPS_GPIO_io          : inout std_logic_vector(1 downto 0);
           
           -- I2C
           --HPS_I2C_CONTROL_io   : inout std_logic;
           --HPS_I2C1_SCLK_io     : inout std_logic;
           --HPS_I2C1_SDAT_io     : inout std_logic;
           --HPS_I2C2_SCLK_io     : inout std_logic;
           --HPS_I2C2_SDAT_io     : inout std_logic;

           -- Pushbutton
           HPS_KEY_io           : inout std_logic;

           -- LED
           HPS_LED_io           : inout std_logic;

           -- SD Card
           --HPS_SD_CLK_o         : out std_logic;
           --HPS_SD_CMD_io        : inout std_logic;
           --HPS_SD_DATA_io       : inout std_logic_vector(3 downto 0);

           -- SPI
           --HPS_SPIM_CLK_o       : out std_logic;
           --HPS_SPIM_MISO_i      : in std_logic;
           --HPS_SPIM_MOSI_o      : out std_logic;
           --HPS_SPIM_SS_io       : inout std_logic;

           -- UART
           HPS_UART_RX_i        : in std_logic;
           HPS_UART_TX_o        : out std_logic;

           -- USB
           --HPS_CONV_USB_N_io    : inout std_logic;
           --HPS_USB_CLKOUT_i     : in std_logic;
           --HPS_USB_DATA_io      : inout std_logic_vector(7 downto 0);
           --HPS_USB_DIR_i        : in std_logic;
           --HPS_USB_NXT_i        : in std_logic;
           --HPS_USB_STP_o        : out std_logic;

           -- LTC connector
           --HPS_LTC_GPIO_io      : inout std_logic;

           -- FAN
           FAN_CTRL_o           : out std_logic
           );
end DE1_SoC_top;

architecture top of DE1_SoC_top is

    --| Components declaration |--------------------------------------------------------------
    component qsys_system is
        port (
            ------------------------------------
            -- FPGA Side
            ------------------------------------
            -- Global signals
            clk_clk                          : in    std_logic                     := 'X';             -- clk
			reset_reset_n                    : in    std_logic                     := 'X';             -- reset_n
            -- Pio signals
            constante_id_export              : in    std_logic_vector(31 downto 0) := (others => 'X'); -- export
			-- Avalon bus bridge
            avalon_bus_bridge_clk            : out   std_logic;                                        -- clk
            avalon_bus_bridge_reset          : out   std_logic;                                        -- reset
            avalon_bus_bridge_address        : out   std_logic_vector(13 downto 0);                    -- address
            avalon_bus_bridge_byteenable     : out   std_logic_vector(3 downto 0);                     -- byteenable
            avalon_bus_bridge_write          : out   std_logic;                                        -- write
            avalon_bus_bridge_writedata      : out   std_logic_vector(31 downto 0);                    -- writedata
            avalon_bus_bridge_read           : out   std_logic;                                        -- read
            avalon_bus_bridge_readdatavalid  : in    std_logic                     := 'X';             -- readdatavalid
            avalon_bus_bridge_readdata       : in    std_logic_vector(31 downto 0) := (others => 'X'); -- readdata
            avalon_bus_bridge_waitrequest    : in    std_logic                     := 'X';             -- waitrequest
            avalon_bus_bridge_irq            : in    std_logic                     := 'X';             -- irq
            ------------------------------------
            -- HPS Side
            ------------------------------------
            -- DDR3 SDRAM
            memory_mem_a                    : out   std_logic_vector(14 downto 0);                    -- mem_a
            memory_mem_ba                   : out   std_logic_vector(2 downto 0);                     -- mem_ba
            memory_mem_ck                   : out   std_logic;                                        -- mem_ck
            memory_mem_ck_n                 : out   std_logic;                                        -- mem_ck_n
            memory_mem_cke                  : out   std_logic;                                        -- mem_cke
            memory_mem_cs_n                 : out   std_logic;                                        -- mem_cs_n
            memory_mem_ras_n                : out   std_logic;                                        -- mem_ras_n
            memory_mem_cas_n                : out   std_logic;                                        -- mem_cas_n
            memory_mem_we_n                 : out   std_logic;                                        -- mem_we_n
            memory_mem_reset_n              : out   std_logic;                                        -- mem_reset_n
            memory_mem_dq                   : inout std_logic_vector(31 downto 0) := (others => 'X'); -- mem_dq
            memory_mem_dqs                  : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs
            memory_mem_dqs_n                : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- mem_dqs_n
            memory_mem_odt                  : out   std_logic;                                        -- mem_odt
            memory_mem_dm                   : out   std_logic_vector(3 downto 0);                     -- mem_dm
            memory_oct_rzqin                : in    std_logic                     := 'X';             -- oct_rzqin
            
            -- UART
            hps_io_0_hps_io_uart0_inst_RX    : in    std_logic                     := 'X';             -- hps_io_uart0_inst_RX
            hps_io_0_hps_io_uart0_inst_TX    : out   std_logic;                                        -- hps_io_uart0_inst_TX
    
            -- Pushbutton
            hps_io_0_hps_io_gpio_inst_GPIO54  : inout std_logic                     := 'X';             -- hps_io_gpio_inst_GPIO54
    
            -- LED
            hps_io_0_hps_io_gpio_inst_GPIO53  : inout std_logic                     := 'X'              -- hps_io_gpio_inst_GPIO53
        );
    end component qsys_system;
    
    component avl_user_interface is
        port(
            -- Avalon bus
            avl_clk_i           : in  std_logic;
            avl_reset_i         : in  std_logic;
            avl_address_i       : in  std_logic_vector(13 downto 0);
            avl_byteenable_i    : in  std_logic_vector(3 downto 0);
            avl_write_i         : in  std_logic;
            avl_writedata_i     : in  std_logic_vector(31 downto 0);
            avl_read_i          : in  std_logic;
            avl_readdatavalid_o : out std_logic;
            avl_readdata_o      : out std_logic_vector(31 downto 0);
            avl_waitrequest_o   : out std_logic;
            avl_irq_o           : out std_logic;
            -- User interface
            button_i            : in  std_logic_vector(3 downto 0);
            switch_i            : in  std_logic_vector(9 downto 0);
            led_o               : out std_logic_vector(9 downto 0);
            hex0_o              : out std_logic_vector(6 downto 0);
            hex1_o              : out std_logic_vector(6 downto 0);
            hex2_o              : out std_logic_vector(6 downto 0);
            hex3_o              : out std_logic_vector(6 downto 0);
            -- Con 80p interface
            serial_data_o       : out std_logic;
            con_80p_status_i    : in  std_logic_vector(1 downto 0)
        );
    end component avl_user_interface;
    
    component interface_con_80p_max10_prot_0x10 is
        port(
            s_data_i          : in  std_logic;
            con_80p_status_o  : out std_logic_vector(1 downto 0);
            GPIO_0_io         : inout std_logic_vector(35 downto 0);
            GPIO_1_io         : inout std_logic_vector(35 downto 0)
        );
    end component interface_con_80p_max10_prot_0x10;
    
    --| Constants declarations |--------------------------------------------------------------
    constant CONSTANT_ID_C : std_logic_vector(31 downto 0) := x"cafe0006";
    
    --| Signals declarations   |--------------------------------------------------------------
    -- Avalon bus signal
    signal avl_clk : std_logic;
    signal avl_reset : std_logic;
    signal avl_address : std_logic_vector(13 downto 0);
    signal avl_byteenable : std_logic_vector(3 downto 0);
    signal avl_write : std_logic;
    signal avl_writedata : std_logic_vector(31 downto 0);
    signal avl_read : std_logic;
    signal avl_readdatavalid : std_logic;
    signal avl_readdata : std_logic_vector(31 downto 0);
    signal avl_waitrequest : std_logic;
    signal avl_irq : std_logic;
    
    -- Serial
    signal serial_data_s : std_logic;
    signal con_80p_status_s : std_logic_vector(1 downto 0);

begin

-- Seven Segment Displays
-- Switch OFF by default
HEX4_o <= (others => '1');
HEX5_o <= (others => '1');

---------------------------------------------------------
--  HPS mapping
---------------------------------------------------------

    System : component qsys_system
    port map (
        ------------------------------------
        -- FPGA Side
        ------------------------------------
        -- Global signals
        clk_clk                        => CLOCK_50_i,
        reset_reset_n                  => '1',
        -- Pio signals
        constante_id_export            => CONSTANT_ID_C,
        -- Avalon bus bridge
        avalon_bus_bridge_clk            => avl_clk,
        avalon_bus_bridge_reset          => avl_reset,
        avalon_bus_bridge_address        => avl_address,
        avalon_bus_bridge_byteenable     => avl_byteenable,
        avalon_bus_bridge_write          => avl_write,
        avalon_bus_bridge_writedata      => avl_writedata,
        avalon_bus_bridge_read           => avl_read,
        avalon_bus_bridge_readdatavalid  => avl_readdatavalid,
        avalon_bus_bridge_readdata       => avl_readdata,
        avalon_bus_bridge_waitrequest    => avl_waitrequest,
        avalon_bus_bridge_irq            => avl_irq,
        ------------------------------------
        -- HPS Side
        ------------------------------------
        -- DDR3 SDRAM
        memory_mem_a        => HPS_DDR3_ADDR_o,
        memory_mem_ba       => HPS_DDR3_BA_o,
        memory_mem_ck       => HPS_DDR3_CK_P_o,
        memory_mem_ck_n     => HPS_DDR3_CK_N_o,
        memory_mem_cke      => HPS_DDR3_CKE_o,
        memory_mem_cs_n     => HPS_DDR3_CS_N_o,
        memory_mem_ras_n    => HPS_DDR3_RAS_N_o,
        memory_mem_cas_n    => HPS_DDR3_CAS_N_o,
        memory_mem_we_n     => HPS_DDR3_WE_N_o,
        memory_mem_reset_n  => HPS_DDR3_RESET_N_o,
        memory_mem_dq       => HPS_DDR3_DQ_io,
        memory_mem_dqs      => HPS_DDR3_DQS_P_io,
        memory_mem_dqs_n    => HPS_DDR3_DQS_N_io,
        memory_mem_odt      => HPS_DDR3_ODT_o,
        memory_mem_dm       => HPS_DDR3_DM_o,
        memory_oct_rzqin    => HPS_DDR3_RZQ_i,
        
        -- UART
        hps_io_0_hps_io_uart0_inst_RX     => HPS_UART_RX_i,
        hps_io_0_hps_io_uart0_inst_TX     => HPS_UART_TX_o,
    
        -- Pushbutton
        hps_io_0_hps_io_gpio_inst_GPIO54  => HPS_KEY_io,
    
        -- LED
        hps_io_0_hps_io_gpio_inst_GPIO53  => HPS_LED_io
    );
    
---------------------------------------------------------
--  Avalon user interface
---------------------------------------------------------

    avl_user_interface_inst : component avl_user_interface
    port map (
        avl_clk_i           => avl_clk,
        avl_reset_i         => avl_reset,
        avl_address_i       => avl_address,
        avl_byteenable_i    => avl_byteenable,
        avl_write_i         => avl_write,
        avl_writedata_i     => avl_writedata,
        avl_read_i          => avl_read,
        avl_readdatavalid_o => avl_readdatavalid,
        avl_readdata_o      => avl_readdata,
        avl_waitrequest_o   => avl_waitrequest,
        avl_irq_o           => avl_irq,
        button_i            => KEY_i,
        switch_i            => SW_i,
        led_o               => LEDR_o,
        hex0_o              => HEX0_o,
        hex1_o              => HEX1_o,
        hex2_o              => HEX2_o,
        hex3_o              => HEX3_o,
        serial_data_o       => serial_data_s,
        con_80p_status_i    => con_80p_status_s
    );
    
---------------------------------------------------------
--  Connector 80 poles
---------------------------------------------------------
---- utilisation du design de liaison serial.
interface_con_80p_inst : component interface_con_80p_max10_prot_0x10
    port map (
        s_data_i         => serial_data_s,
        con_80p_status_o => con_80p_status_s,
        GPIO_0_io        => GPIO_0_io,
        GPIO_1_io        => GPIO_1_io
    );

    

end top;
