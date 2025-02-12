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
-- Author               : Anthony Convers
-- Date                 : 04.08.2022
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
-- 0.0    See header              Initial version

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
    -- User interface
    button_i            : in  std_logic_vector(3 downto 0);
    switch_i            : in  std_logic_vector(9 downto 0);
    led_o               : out std_logic_vector(9 downto 0);
    -- Gen strings
    char_1_i            : in  std_logic_vector(7 downto 0);
    char_2_i            : in  std_logic_vector(7 downto 0);
    char_3_i            : in  std_logic_vector(7 downto 0);
    char_4_i            : in  std_logic_vector(7 downto 0);
    char_5_i            : in  std_logic_vector(7 downto 0);
    char_6_i            : in  std_logic_vector(7 downto 0);
    char_7_i            : in  std_logic_vector(7 downto 0);
    char_8_i            : in  std_logic_vector(7 downto 0);
    char_9_i            : in  std_logic_vector(7 downto 0);
    char_10_i           : in  std_logic_vector(7 downto 0);
    char_11_i           : in  std_logic_vector(7 downto 0);
    char_12_i           : in  std_logic_vector(7 downto 0);
    char_13_i           : in  std_logic_vector(7 downto 0);
    char_14_i           : in  std_logic_vector(7 downto 0);
    char_15_i           : in  std_logic_vector(7 downto 0);
    char_16_i           : in  std_logic_vector(7 downto 0);
    checksum_i          : in  std_logic_vector(7 downto 0);
    cmd_init_o          : out std_logic;
    cmd_new_char_o      : out std_logic;
    auto_o              : out std_logic;
    delay_o             : out std_logic_vector(1 downto 0)
  );
end avl_user_interface;

architecture rtl of avl_user_interface is

    --| Components declaration |--------------------------------------------------------------

    --| Constants declarations |--------------------------------------------------------------
    -- User ID constant
    constant USER_ID : std_logic_vector(31 downto 0) := X"ABCD1234";

    constant STATUS_BIT      : std_logic := '1';  -- Snapshot functionality is available status[1] = 1  


    -- Timing constants
    constant CLOCK_FREQ : integer := 50_000_000;  -- 50 MHz
    constant WE_DURATION : integer := CLOCK_FREQ / 1_000_000;  -- 1 us



    --| Signals declarations   |--------------------------------------------------------------   
    -- Internal registers
    -- IO DE1-SoC
    signal reg_leds             : std_logic_vector(9 downto 0);  

    -- Avalon
    signal reg_readdata       : std_logic_vector(31 downto 0);
    signal reg_readdatavalid  : std_logic;

    -- Internal signals
    signal readdata_next_s      : std_logic_vector(31 downto 0);
    signal readdatavalid_next_s : std_logic;

    -- Control signals
    signal write_request        : std_logic;

    -- Regs
    signal mode_gen_reg       : std_logic;
    signal delay_gen_reg      : std_logic_vector(1 downto 0);
    signal cmd_init_reg       : std_logic;
    signal cmd_new_char_reg   : std_logic;
    signal read_data          : std_logic_vector(31 downto 0);
    signal read_valid         : std_logic;

    -- Chars registers
    signal char_1_4_reg_s        : std_logic_vector(31 downto 0);
    signal char_5_8_reg_s        : std_logic_vector(31 downto 0);
    signal char_9_12_reg_s       : std_logic_vector(31 downto 0);
    signal char_13_16_reg_s      : std_logic_vector(31 downto 0);

    -- Checksum register
    signal checksum_reg_s        : std_logic_vector(7 downto 0);

    -- MSS
    type state_t is (RESET, MEM, WAIT_ACK);
    signal current_state, next_state : state_t;
    signal mem_s                 : std_logic;
    signal status_s              : std_logic;
    signal ack_s                 : std_logic;

begin


    -- Chars registers process
    process(avl_clk_i, avl_reset_i)
    begin 
        if avl_reset_i = '1' then
            -- Lors du reset, on initialise les registres avec des valeurs par défaut
            char_1_4_reg_s    <= (others => '0');
            char_5_8_reg_s    <= (others => '0');
            char_9_12_reg_s   <= (others => '0');
            char_13_16_reg_s  <= (others => '0');
            checksum_reg_s    <= (others => '0');
        elsif rising_edge(avl_clk_i) then
            if mem_s = '1' then
                -- Mise à jour des registres avec les entrées
                char_1_4_reg_s(7 downto 0)     <= char_4_i;
                char_1_4_reg_s(15 downto 8)    <= char_3_i;
                char_1_4_reg_s(23 downto 16)   <= char_2_i;
                char_1_4_reg_s(31 downto 24)   <= char_1_i;

                char_5_8_reg_s(7 downto 0)     <= char_8_i;
                char_5_8_reg_s(15 downto 8)    <= char_7_i;
                char_5_8_reg_s(23 downto 16)   <= char_6_i;
                char_5_8_reg_s(31 downto 24)   <= char_5_i;

                char_9_12_reg_s(7 downto 0)    <= char_12_i;
                char_9_12_reg_s(15 downto 8)   <= char_11_i;
                char_9_12_reg_s(23 downto 16)  <= char_10_i;
                char_9_12_reg_s(31 downto 24)  <= char_9_i;

                char_13_16_reg_s(7 downto 0)   <= char_16_i;
                char_13_16_reg_s(15 downto 8)  <= char_15_i;
                char_13_16_reg_s(23 downto 16) <= char_14_i;
                char_13_16_reg_s(31 downto 24) <= char_13_i;

                checksum_reg_s <= checksum_i; -- Enregistrement du checksum
            end if;
        end if;
    end process;

    -- Read access part
    read_decoder_p : process(all)
    begin
        readdatavalid_next_s <= '0';        -- default value
        readdata_next_s <= (others => '0'); -- default value
        if avl_read_i = '1' then -- Avalon read request
            readdatavalid_next_s <= '1';    -- 
            CASE (to_integer(unsigned(avl_address_i))) is
                when 0 =>
                    readdata_next_s <= USER_ID;
                when 1 =>
                    readdata_next_s(3 downto 0) <= button_i;
                when 2 =>
                    readdata_next_s(9 downto 0) <= switch_i;
                when 3 =>
                    readdata_next_s(9 downto 0) <= reg_leds;
                when 4 =>
                    readdata_next_s(1 downto 0) <= STATUS_BIT & status_s;
                when 5 =>
                    readdata_next_s <= (31 downto 5 => '0') & mode_gen_reg & "00" & delay_gen_reg;
                -- when 6 =>
                    --readdata_next_s <= read_data;
                --when 7 =>
                    --readdata_next_s(3 downto 0) <= "0000";
                when 8 =>
                    readdata_next_s <= char_1_4_reg_s;
                when 9 =>
                    readdata_next_s <= char_5_8_reg_s;
                when 10 =>
                    readdata_next_s <= char_9_12_reg_s;
                when 11 =>
                    readdata_next_s <= char_13_16_reg_s;
                when 12 =>
                    readdata_next_s(7 downto 0) <= checksum_reg_s;
                when others =>
                    readdata_next_s <= (others => '0');
                end case;
        end if;
    end process;

    -- Read register process
    read_register_p : process(avl_reset_i, avl_clk_i)
    begin
        if avl_reset_i='1' then
            reg_readdatavalid <= '0';
            reg_readdata <= (others => '0');
        elsif rising_edge(avl_clk_i) then
            reg_readdatavalid <= readdatavalid_next_s;
            reg_readdata <= readdata_next_s;
        end if;
    end process;


    -- Write access part
    write_process: process(avl_clk_i, avl_reset_i)
    begin
        if avl_reset_i = '1' then
            reg_leds <= (others => '0');

        elsif rising_edge(avl_clk_i) then
            write_request <= '0';  -- Default state
            if avl_write_i = '1' then -- Avalon write request
               case (to_integer(unsigned(avl_address_i))) is
                    when 0 =>
                        null;
                    when 1 =>
                        null;
                    when 2 =>
                        null;
                    when 3 =>
                        reg_leds <= avl_writedata_i(9 downto 0);
                    when 4 =>
                        cmd_init_reg <= avl_writedata_i(0);
                        cmd_new_char_reg <= avl_writedata_i(4);
                    when 5 =>
                        mode_gen_reg <= avl_writedata_i(4);
                        delay_gen_reg <= avl_writedata_i(1 downto 0);
                    when 6 =>
                        ack_s <= avl_writedata_i(0);
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process write_process;

    -- MSS - signal mem
    
    -- Process de registre d'état
    state_reg : process(avl_clk_i, avl_reset_i)
    begin
        if avl_reset_i = '1' then
            current_state <= RESET;
        elsif rising_edge(avl_clk_i) then
            current_state <= next_state;
        end if;
    end process;

    -- Process combinatoire pour le prochain état
    next_state_logic : process(current_state, ack_s)
    begin
        case current_state is
            when RESET =>
                next_state <= MEM;
                
            when MEM =>
                next_state <= WAIT_ACK;
                
            when WAIT_ACK =>
                if ack_s = '1' then
                    next_state <= MEM;
                else
                    next_state <= WAIT_ACK;
                end if;
        end case;
    end process;

    -- Process combinatoire pour les sorties
    mem_output_logic : process(current_state)
    begin
        case current_state is
            when RESET =>
                mem_s <= '0';
                
            when MEM =>
                mem_s <= '1';
                
            when WAIT_ACK =>
                mem_s <= '0';
        end case;
    end process;

    -- Interface management

    -- Interface outputs
    -- Output assignments
    -- IO DE1-SoC
    led_o <= reg_leds;

    -- Avalon
    avl_readdata_o <= reg_readdata;
    avl_readdatavalid_o <= reg_readdatavalid;
    avl_waitrequest_o <= '0';  -- Not used

    -- User interface
    cmd_init_o <= cmd_init_reg;
    cmd_new_char_o <= cmd_new_char_reg;
    auto_o <= mode_gen_reg;
    delay_o <= delay_gen_reg;
    
    
    
end rtl; 