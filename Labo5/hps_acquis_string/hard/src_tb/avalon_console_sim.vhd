-----------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : avalon_slv_tb.vhd
-- Description  : testbench pour interface avalon slave
--
-- Auteur       : S. Masle
-- Date         : 11.07.2022
--
-- Utilise      : 
--
--| Modifications |-----------------------------------------------------------
-- Ver   Auteur Date         Description
-- 1.0   SMS    11.07.2022   Version initiale
------------------------------------------------------------------------------
library ieee;
    use ieee.std_logic_1164.all;
    use ieee.numeric_std.all;
    use ieee.math_real.uniform;

entity avalon_console_sim is
end avalon_console_sim;

architecture Behavioral of avalon_console_sim is

    component avl_user_interface
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
            cmd_new_nbr_o       : out std_logic;
            auto_o              : out std_logic;
            delay_o             : out std_logic_vector(1 downto 0)
        );
    end component;
    
    component generateur_strings is
        port (
            clock_i       : in  std_logic;  -- system clock
            reset_i       : in  std_logic;  -- reset
            cmd_init_i    : in  std_logic;
            cmd_new_nbr_i : in  std_logic;
            auto_i        : in  std_logic;
            delay_i       : in  std_logic_vector(1 downto 0); -- delay value for input pulses
            char_1_o      : out std_logic_vector(7 downto 0);
            char_2_o      : out std_logic_vector(7 downto 0);
            char_3_o      : out std_logic_vector(7 downto 0);
            char_4_o      : out std_logic_vector(7 downto 0);
            char_5_o      : out std_logic_vector(7 downto 0);
            char_6_o      : out std_logic_vector(7 downto 0);
            char_7_o      : out std_logic_vector(7 downto 0);
            char_8_o      : out std_logic_vector(7 downto 0);
            char_9_o      : out std_logic_vector(7 downto 0);
            char_10_o     : out std_logic_vector(7 downto 0);
            char_11_o     : out std_logic_vector(7 downto 0);
            char_12_o     : out std_logic_vector(7 downto 0);
            char_13_o     : out std_logic_vector(7 downto 0);
            char_14_o     : out std_logic_vector(7 downto 0);
            char_15_o     : out std_logic_vector(7 downto 0);
            char_16_o     : out std_logic_vector(7 downto 0);
            checksum_o    : out std_logic_vector(7 downto 0)
        );
    end component generateur_strings;

    constant ClockPeriod : TIME := 20 ns;
    constant pulse_c     : time := 4 ns;

    signal clock_sti : std_logic;
    signal reset_sti : std_logic;

    signal address_sti         : std_logic_vector(13 downto 0);
    signal byteenable_sti      : std_logic_vector(3 downto 0);
    signal read_sti            : std_logic;
    signal read_data_valid_obs : std_logic;
    signal read_data_obs       : std_logic_vector(31 downto 0);
    signal write_sti           : std_logic;
    signal write_data_sti      : std_logic_vector(31 downto 0);
    signal waitrequest_obs     : std_logic;
    signal button_n_s          : std_logic_vector(3 downto 0);
    signal button_sti          : std_logic_vector(31 downto 0);
    signal switch_sti          : std_logic_vector(31 downto 0);
    signal lp36_status_sti     : std_logic_vector(31 downto 0);
    signal led_obs             : std_logic_vector(31 downto 0) := (others => '0');
    signal char_1_sti          : std_logic_vector(7 downto 0);
    signal char_2_sti          : std_logic_vector(7 downto 0);
    signal char_3_sti          : std_logic_vector(7 downto 0);
    signal char_4_sti          : std_logic_vector(7 downto 0);
    signal char_5_sti          : std_logic_vector(7 downto 0);
    signal char_6_sti          : std_logic_vector(7 downto 0);
    signal char_7_sti          : std_logic_vector(7 downto 0);
    signal char_8_sti          : std_logic_vector(7 downto 0);
    signal char_9_sti          : std_logic_vector(7 downto 0);
    signal char_10_sti         : std_logic_vector(7 downto 0);
    signal char_11_sti         : std_logic_vector(7 downto 0);
    signal char_12_sti         : std_logic_vector(7 downto 0);
    signal char_13_sti         : std_logic_vector(7 downto 0);
    signal char_14_sti         : std_logic_vector(7 downto 0);
    signal char_15_sti         : std_logic_vector(7 downto 0);
    signal char_16_sti         : std_logic_vector(7 downto 0);
    signal checksum_sti        : std_logic_vector(7 downto 0);
    signal cmd_init_obs        : std_logic;
    signal cmd_new_nbr_obs     : std_logic;
    signal auto_obs            : std_logic;
    signal delay_obs           : std_logic_vector(1 downto 0);

    
begin

    DUT: entity work.avl_user_interface
        port map (
            -- Avalon bus
            avl_clk_i           => clock_sti,
            avl_reset_i         => reset_sti,
            avl_address_i       => address_sti,
            avl_byteenable_i    => byteenable_sti,
            avl_write_i         => write_sti,
            avl_writedata_i     => write_data_sti,
            avl_read_i          => read_sti,
            avl_readdatavalid_o => read_data_valid_obs,
            avl_readdata_o      => read_data_obs,
            avl_waitrequest_o   => waitrequest_obs,
    
            -- User input-output
            button_i            => button_n_s,
            switch_i            => switch_sti(9 downto 0),
            led_o               => led_obs(9 downto 0),
            char_1_i            => char_1_sti,
            char_2_i            => char_2_sti,
            char_3_i            => char_3_sti,
            char_4_i            => char_4_sti,
            char_5_i            => char_5_sti,
            char_6_i            => char_6_sti,
            char_7_i            => char_7_sti,
            char_8_i            => char_8_sti,
            char_9_i            => char_9_sti,
            char_10_i           => char_10_sti,
            char_11_i           => char_11_sti,
            char_12_i           => char_12_sti,
            char_13_i           => char_13_sti,
            char_14_i           => char_14_sti,
            char_15_i           => char_15_sti,
            char_16_i           => char_16_sti,
            checksum_i          => checksum_sti,
            cmd_init_o          => cmd_init_obs,
            cmd_new_nbr_o       => cmd_new_nbr_obs,
            auto_o              => auto_obs,
            delay_o             => delay_obs
        );
        
    button_n_s <= not button_sti(3 downto 0);   -- button_i (key) is active low
    
    gen_strings_inst: entity work.generateur_strings
        port map (
            clock_i       => clock_sti,
            reset_i       => reset_sti,
            cmd_init_i    => cmd_init_obs,
            cmd_new_nbr_i => cmd_new_nbr_obs,
            auto_i        => auto_obs,
            delay_i       => delay_obs,
            char_1_o      => char_1_sti,
            char_2_o      => char_2_sti,
            char_3_o      => char_3_sti,
            char_4_o      => char_4_sti,
            char_5_o      => char_5_sti,
            char_6_o      => char_6_sti,
            char_7_o      => char_7_sti,
            char_8_o      => char_8_sti,
            char_9_o      => char_9_sti,
            char_10_o     => char_10_sti,
            char_11_o     => char_11_sti,
            char_12_o     => char_12_sti,
            char_13_o     => char_13_sti,
            char_14_o     => char_14_sti,
            char_15_o     => char_15_sti,
            char_16_o     => char_16_sti,
            checksum_o    => checksum_sti
        );

    -- Generate clock signal
    GENERATE_REFCLOCK : process
    begin
 
        while true loop
            clock_sti <= '1',
                         '0' after ClockPeriod/2;
            wait for ClockPeriod;
        end loop;
        wait;
    end process;

end Behavioral;
