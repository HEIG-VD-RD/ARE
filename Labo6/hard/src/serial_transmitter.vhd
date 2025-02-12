library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity serial_transmitter is
    generic (
        -- Clock frequency in Hz
        CLK_FREQ    : integer := 50_000_000;  -- 50 MHz
        -- Baud rate
        BAUD_RATE   : integer := 9600         -- 9600 bauds
    );
    port (
        -- System signals
        clk_i       : in  std_logic;
        reset_i     : in  std_logic;
        
        -- Control signals
        data_i      : in  std_logic_vector(19 downto 0);  -- 20 bits data input
        start_i     : in  std_logic;                      -- Start transmission
        busy_o      : out std_logic;                      -- Transmission in progress
        
        -- Serial output
        tx_o        : out std_logic                       -- Serial output
    );
end entity serial_transmitter;

architecture rtl of serial_transmitter is
    -- Constants
    constant CYCLES_PER_BIT : integer := CLK_FREQ / BAUD_RATE;
    constant TX_DATA_WIDTH  : integer := 20;
    
    -- Types
    type state_t is (IDLE, START_BIT, DATA_BITS, STOP_BIT);
    
    -- Registers
    signal state            : state_t;
    signal bit_counter      : integer range 0 to TX_DATA_WIDTH-1;
    signal cycle_counter    : integer range 0 to CYCLES_PER_BIT-1;
    signal shift_reg        : std_logic_vector(TX_DATA_WIDTH-1 downto 0);
    
begin
    -- Main process
    process(clk_i, reset_i)
    begin
        if reset_i = '1' then
            state <= IDLE;
            bit_counter <= 0;
            cycle_counter <= 0;
            shift_reg <= (others => '0');
            tx_o <= '1';          -- Idle state = high
            busy_o <= '0';

        elsif rising_edge(clk_i) then
            
            case state is
                when IDLE =>
                    tx_o <= '1';      -- Idle state = high
                    busy_o <= '0';
                    
                    -- Start new transmission
                    if start_i = '1' then
                        shift_reg <= data_i;
                        state <= START_BIT;
                        cycle_counter <= 0;
                        busy_o <= '1';
                    end if;
                    
                when START_BIT =>
                    tx_o <= '0';      -- Start bit = low
                    
                    if cycle_counter = CYCLES_PER_BIT-1 then
                        state <= DATA_BITS;
                        cycle_counter <= 0;
                        bit_counter <= 0;
                    else
                        cycle_counter <= cycle_counter + 1;
                    end if;
                    
                when DATA_BITS =>
                    tx_o <= shift_reg(TX_DATA_WIDTH-1);  -- Send MSB first
                    
                    if cycle_counter = CYCLES_PER_BIT-1 then
                        cycle_counter <= 0;
                        
                        if bit_counter = TX_DATA_WIDTH-1 then
                            state <= STOP_BIT;
                        else
                            bit_counter <= bit_counter + 1;
                            -- Shift data
                            shift_reg <= shift_reg(TX_DATA_WIDTH-2 downto 0) & '0';
                        end if;
                    else
                        cycle_counter <= cycle_counter + 1;
                    end if;
                    
                when STOP_BIT =>
                    tx_o <= '1';      -- Stop bit = high
                    
                    if cycle_counter = CYCLES_PER_BIT-1 then
                        state <= IDLE;
                        cycle_counter <= 0;
                    else
                        cycle_counter <= cycle_counter + 1;
                    end if;
            end case;
        end if;
    end process;

end architecture rtl;