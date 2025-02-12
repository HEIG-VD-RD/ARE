------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : avl_user_interface.vhd
-- Author               : rhr
-- Date                 : 12.01.2025
--
-- Context              : Avalon user interface
--
------------------------------------------------------------------------------------------
-- Description : 
--   
------------------------------------------------------------------------------------------
-- Dependencies : 
--   
------------------------------------------------------------------------------------------
-- Modifications :
-- Ver    Date        Engineer    Comments
-- 0.0    See header  rhr         Initial version

------------------------------------------------------------------------------------------

library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    
entity avl_user_interface is
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
end avl_user_interface;

architecture rtl of avl_user_interface is

  	--| Components declaration |--------------------------------------------------------------
	-- Serial transmitter component used to send data to the Max10_leds board
	component serial_transmitter is
        generic (
            CLK_FREQ    : integer := 50_000_000;	-- System clock frequency in Hz
            BAUD_RATE   : integer := 9600			-- Serial communication speed in bauds
        );
        port (
            clk_i       : in  std_logic;			-- System clock input
            reset_i     : in  std_logic;			-- Asynchronous reset input
            data_i      : in  std_logic_vector(19 downto 0); -- Data to transmit (4-bit code + 16-bit data)
            start_i     : in  std_logic;			-- Start transmission when '1'
            busy_o      : out std_logic;			-- '1' when transmitter is busy
            tx_o        : out std_logic				-- Serial output line
        );
    end component serial_transmitter;
    for all : serial_transmitter use entity work.serial_transmitter;

  	--| Constants declarations |--------------------------------------------------------------
  	-- Interface identification constant
	constant INTERFACE_ID   : std_logic_vector(31 downto 0) := x"CAFE3456";  -- ID
	constant CLK_FREQUENCY  : integer := 50_000_000;    -- 50 MHz system clock
    constant BAUD_RATE      : integer := 9600;          -- 9600 bauds serial communication
    --constant BAUD_RATE      : integer := 10_000_000;

	-- Read address mapping constants
  	constant ADDR_ID_R          : std_logic_vector(7 downto 0) := x"00";	-- Interface ID register
    constant ADDR_BUTTONS_R     : std_logic_vector(7 downto 0) := x"01";	-- Buttons state
    constant ADDR_SWITCHES_R    : std_logic_vector(7 downto 0) := x"02";	-- Switches state
    constant ADDR_LEDS_R        : std_logic_vector(7 downto 0) := x"03";	-- LEDs state
    constant ADDR_DISP_R        : std_logic_vector(7 downto 0) := x"04";	-- 7-segment displays state
	constant ADDR_SERIAL_STAT_R : std_logic_vector(7 downto 0) := x"05";	-- Serial status register
    constant ADDR_SERIAL_DATA_R : std_logic_vector(7 downto 0) := x"06";	-- Serial data register
	constant ADDR_IRQ_STATUS_R  : std_logic_vector(7 downto 0) := x"08";	-- Interrupt status
    constant ADDR_CNT_VALUE_R   : std_logic_vector(7 downto 0) := x"0C";	-- Counter value
	-- Address mapping constants - WRITE
    constant ADDR_LEDS_W        : std_logic_vector(7 downto 0) := x"03";	-- LEDs control
    constant ADDR_DISP_W        : std_logic_vector(7 downto 0) := x"04";	-- 7-segment displays control
	constant ADDR_SERIAL_DATA_W : std_logic_vector(7 downto 0) := x"06";	-- Serial data to send
    constant ADDR_SERIAL_START_W: std_logic_vector(7 downto 0) := x"07";	-- Start serial transmission
	constant ADDR_IRQ_ACK_W     : std_logic_vector(7 downto 0) := x"08";	-- Interrupt acknowledge
    constant ADDR_IRQ_MASK_W    : std_logic_vector(7 downto 0) := x"09";	-- Interrupt mask control
	constant ADDR_CNT_CTRL_W    : std_logic_vector(7 downto 0) := x"0D";	-- Counter control


    --| Signals declarations   |--------------------------------------------------------------  
    -- Internal registers for read/write access
    signal reg_leds      : std_logic_vector(9 downto 0);	-- LED register
    signal reg_hex0      : std_logic_vector(6 downto 0);	-- 7-segment display 0 register
    signal reg_hex1      : std_logic_vector(6 downto 0);	-- 7-segment display 1 register
    signal reg_hex2      : std_logic_vector(6 downto 0);	-- 7-segment display 2 register
    signal reg_hex3      : std_logic_vector(6 downto 0);	-- 7-segment display 3 register
    -- Interrupt control registers
    signal irq_mask          : std_logic;	-- '1' enables interrupts, '0' disables them
    signal irq_pending       : std_logic;	-- '1' when interrupt is waiting to be processed
    signal key0_prev         : std_logic;	-- Previous state of KEY0 for edge detection
    signal irq_ack			 : std_logic;    -- Interrupt acknowledge
	-- Internal signals
    signal readdata_next_s      : std_logic_vector(31 downto 0);	-- Next read data value
    signal readdatavalid_next_s : std_logic;						-- Next read data valid flag
	-- Avalon
    signal reg_readdata         : std_logic_vector(31 downto 0);	-- Registered read data
    signal reg_readdatavalid    : std_logic;						-- Registered read valid flag
    -- Counter signals
    signal counter_value     : unsigned(31 downto 0);	-- 32-bit counter value (20ns precision)
    signal counter_enable    : std_logic;				-- Counter enable control
    -- Serial transmitter signals
    signal serial_data         : std_logic_vector(19 downto 0);	-- Data to send serially
    signal serial_start        : std_logic;						-- Start transmission trigger
    signal serial_busy         : std_logic;						-- Transmitter busy flag
	signal serial_data_s       : std_logic;

begin
	--------------------------------------------------------------
	-- Serial transmitter instance for Max10_leds board communication
    serial_tx : serial_transmitter
	generic map (
		CLK_FREQ  => CLK_FREQUENCY,
		BAUD_RATE => BAUD_RATE
	)
	port map (
		clk_i     => avl_clk_i,
		reset_i   => avl_reset_i,
		data_i    => serial_data,
		start_i   => serial_start,
		busy_o    => serial_busy,
		tx_o      => serial_data_s
	);
	
	serial_data_o <= serial_data_s;

	--------------------------------------------------------------
	-- Output assignments
    led_o <= reg_leds;                     -- Drive board LEDs
    hex0_o <= reg_hex0;                    -- Drive 7-segment display 0
    hex1_o <= reg_hex1;                    -- Drive 7-segment display 1
    hex2_o <= reg_hex2;                    -- Drive 7-segment display 2
    hex3_o <= reg_hex3;                    -- Drive 7-segment display 3

    avl_readdata_o <= reg_readdata;        -- Avalon read data output
    avl_readdatavalid_o <= reg_readdatavalid;  -- Avalon read valid output
    avl_waitrequest_o <= '0';              -- No used

    avl_irq_o <= irq_pending and irq_mask; -- IRQ only active if enabled by mask

	--------------------------------------------------------------
    -- Read decoder process - Combinatorial logic for read operations
    read_decoder_p : process(all)
    begin
        readdatavalid_next_s <= '0';       	-- default value
        readdata_next_s <= (others => '0'); -- default value
		
		-- Process Avalon read requests
        if avl_read_i = '1' then
            readdatavalid_next_s <= '1';	-- Signal valid read data for next cycle

			-- Address decoder for read operations
            case avl_address_i(7 downto 0) is

                when ADDR_ID_R =>       -- Interface ID
                    readdata_next_s <= INTERFACE_ID;
                    
                when ADDR_BUTTONS_R =>  -- Buttons
                    readdata_next_s <= (31 downto 4 => '0') & button_i;
                    
                when ADDR_SWITCHES_R => -- Switches
                    readdata_next_s <= (31 downto 10 => '0') & switch_i;
                    
                when ADDR_LEDS_R =>     -- LEDs
                    readdata_next_s <= (31 downto 10 => '0') & reg_leds;
                    
                when ADDR_DISP_R =>     -- 7-segment displays
                    readdata_next_s <= (31 downto 28 => '0') & reg_hex3 & reg_hex2 & reg_hex1 & reg_hex0;
                
				when ADDR_SERIAL_STAT_R => -- Serial status
                    readdata_next_s <= (31 downto 3 => '0') & serial_busy & con_80p_status_i;
                    
                when ADDR_SERIAL_DATA_R => -- Serial data 
                    readdata_next_s <= (31 downto 20 => '0') & serial_data;

				when ADDR_IRQ_STATUS_R =>  -- IRQ status register
                    readdata_next_s <= (31 downto 2 => '0') & 
										irq_mask &        -- bit 1: interrupt mask
										irq_pending;      -- bit 0: interrupt pending

				when ADDR_CNT_VALUE_R =>   -- Counter value
					readdata_next_s <= std_logic_vector(counter_value);
				
                when others =>	-- Return 0 for invalid addresses
                    readdata_next_s <= (others => '0');

            end case;
        end if;
    end process read_decoder_p;
	--------------------------------------------------------------
	-- Read register process - Synchronizes read data to Avalon clock
    read_register_p : process(avl_reset_i, avl_clk_i)
    begin
        if avl_reset_i = '1' then	-- Asynchronous reset
            reg_readdatavalid <= '0';
            reg_readdata <= (others => '0');
        elsif rising_edge(avl_clk_i) then
			-- Register read data and valid signal
            reg_readdatavalid <= readdatavalid_next_s;
            reg_readdata <= readdata_next_s;
        end if;
    end process read_register_p;

	--------------------------------------------------------------
    -- Write access process - Handles Avalon write operations
    write_access_p : process(avl_clk_i, avl_reset_i)
    begin
		if avl_reset_i = '1' then	-- Asynchronous reset
			reg_leds <= (others => '0');	-- All LEDs off
			reg_hex0 <= (others => '1');  	-- All segments off
			reg_hex1 <= (others => '1');	-- All segments off
			reg_hex2 <= (others => '1');	-- All segments off
			reg_hex3 <= (others => '1');	-- All segments off
			serial_data <= (others => '0');
			serial_start <= '0';
			irq_mask <= '0';     			-- Disable interrupts
			irq_ack <= '0';
			counter_enable <= '0'; 			-- Disable counter
            counter_value <= (others => '0');
			
        elsif rising_edge(avl_clk_i) then
			-- Clear start signal after one cycle
            serial_start <= '0';
			irq_ack <= '0';

			-- Counter always counts when enabled
            if counter_enable = '1' then
                counter_value <= counter_value + 1;	-- Increment every 20ns
            end if;
			
			-- Process Avalon write requests
            if avl_write_i = '1' then
                case avl_address_i(7 downto 0) is

                    when ADDR_LEDS_W =>  -- LEDs
                        reg_leds <= avl_writedata_i(9 downto 0);

                    when ADDR_DISP_W =>  -- 7-segment displays
                        reg_hex0 <= avl_writedata_i(6 downto 0);
                        reg_hex1 <= avl_writedata_i(13 downto 7);
                        reg_hex2 <= avl_writedata_i(20 downto 14);
                        reg_hex3 <= avl_writedata_i(27 downto 21);

					when ADDR_SERIAL_DATA_W =>  -- Serial data
                        serial_data <= avl_writedata_i(19 downto 0);

					when ADDR_SERIAL_START_W => -- Start serial transmission
                        if avl_writedata_i(0) = '1' and serial_busy = '0' then
                            serial_start <= '1';
                        end if;

					when ADDR_IRQ_ACK_W =>  -- Acknowledge interrupt
                        if avl_writedata_i(0) = '1' then
                            irq_ack <= '1';
                        end if;
                        
                    when ADDR_IRQ_MASK_W => -- Set interrupt mask
                        irq_mask <= avl_writedata_i(0);
					
					when ADDR_CNT_CTRL_W =>  -- Counter control
                        -- bit 0: enable/disable counter
						counter_enable <= avl_writedata_i(0);
                        -- bit 1: reset counter
                        if avl_writedata_i(1) = '1' then
                            counter_value <= (others => '0');
                        end if;
						
                    when others =>
                        null;

                end case;
            end if;
        end if;
    end process write_access_p;

	--------------------------------------------------------------
    -- Interrupt detection process - Handles KEY0 button interrupts
    interrupt_p : process(avl_clk_i, avl_reset_i)
    begin
		if avl_reset_i = '1' then	-- Asynchronous reset
			key0_prev <= '1';		-- Active low button
			irq_pending <= '0';		-- Clear any pending interrupts

        elsif rising_edge(avl_clk_i) then
            
			-- Update previous state for next detection
			key0_prev <= button_i(0);
			
			-- Detect rising edge on KEY0 (button release)
			if button_i(0) = '0' and key0_prev = '1' then
				irq_pending <= '1';	-- Set interrupt pending
			elsif irq_ack = '1' then
                irq_pending <= '0';
			end if;
        end if;
    end process interrupt_p;

end rtl; 