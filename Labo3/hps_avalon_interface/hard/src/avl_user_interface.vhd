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
-- Author               : 
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

LIBRARY ieee;
  USE ieee.std_logic_1164.ALL;
  USE ieee.numeric_std.ALL;

ENTITY avl_user_interface IS
  PORT (
    -- Avalon bus
    avl_clk_i : IN STD_LOGIC;
    avl_reset_i : IN STD_LOGIC;
    avl_address_i : IN STD_LOGIC_VECTOR(13 DOWNTO 0);
    avl_byteenable_i : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    avl_write_i : IN STD_LOGIC;
    avl_writedata_i : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
    avl_read_i : IN STD_LOGIC;
    avl_readdatavalid_o : OUT STD_LOGIC;
    avl_readdata_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    avl_waitrequest_o : OUT STD_LOGIC;
    -- User interface
    boutton_i : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
    switch_i : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    led_o : OUT STD_LOGIC_VECTOR(9 DOWNTO 0);
    lp36_we_o : OUT STD_LOGIC;
    lp36_sel_o : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
    lp36_data_o : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
    lp36_status_i : IN STD_LOGIC_VECTOR(1 DOWNTO 0)
  );
END avl_user_interface;

ARCHITECTURE rtl OF avl_user_interface IS

  --| Components declaration |--------------------------------------------------------------

  COMPONENT timer IS
    GENERIC (
      T1_g : NATURAL RANGE 1 TO 1023 := 50);
    PORT (
      clock_i : IN STD_LOGIC;
      reset_i : IN STD_LOGIC;
      start_i : IN STD_LOGIC;
      timer_o : OUT STD_LOGIC
    );
  END COMPONENT;
  --| Constants declarations |--------------------------------------------------------------
  CONSTANT IP_USER_ID_C : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"cafe1234";
  --CONSTANT OTHERS_VAL_C : STD_LOGIC_VECTOR(31 DOWNTO 0) := x"1234cafe";

  --| Signals declarations   |--------------------------------------------------------------   
  SIGNAL led_reg_s : STD_LOGIC_VECTOR(9 DOWNTO 0);
  SIGNAL lp36_data_reg_s : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL lp36_we_reg_s : STD_LOGIC;
  SIGNAL lp36_sel_reg_s : STD_LOGIC_VECTOR(3 DOWNTO 0);

  SIGNAL boutton_s : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL readdatavalid_next_s : STD_LOGIC;
  SIGNAL readdata_next_s : STD_LOGIC_VECTOR(31 DOWNTO 0);
  SIGNAL readdatavalid_reg_s : STD_LOGIC;
  SIGNAL readdata_reg_s : STD_LOGIC_VECTOR(31 DOWNTO 0);

  SIGNAL start_timer_s : STD_LOGIC;
  SIGNAL start_running_s : STD_LOGIC;
BEGIN

  --| Components instantiation |--------------------------------------------------------------
 
  myTimer : timer
  -- 50 cycles = 1us
  GENERIC MAP(T1_g => 50)
  PORT MAP(
    clock_i => avl_clk_i,
    reset_i => avl_reset_i,
    start_i => start_timer_s,
    timer_o => lp36_we_reg_s
  );

  -- Read access part
  -- Input signals
  boutton_s <= NOT boutton_i;
  start_timer_s <= start_running_s and (not lp36_we_reg_s);

  -- Read decoder process made following the adress map specification
  read_decoder_p : PROCESS (ALL)
  BEGIN
    readdatavalid_next_s <= '0'; --valeur par defaut
    readdata_next_s <= (OTHERS => '0'); --valeur par defaut
    
    IF avl_read_i = '1' THEN
      readdatavalid_next_s <= '1';

      CASE (to_integer(unsigned(avl_address_i))) IS

        WHEN 0 =>
          readdata_next_s <= IP_USER_ID_C;
        WHEN 1 =>
          readdata_next_s(9 DOWNTO 0) <= led_reg_s;
        WHEN 2 =>
          readdata_next_s(9 DOWNTO 0) <= switch_i;
        WHEN 3 =>
          readdata_next_s(3 DOWNTO 0) <= boutton_s;
        WHEN 4 =>
          readdata_next_s(1 DOWNTO 0) <= lp36_status_i;
        WHEN 5 =>
          readdata_next_s(0) <= lp36_we_reg_s;
        WHEN 6 =>
          readdata_next_s <= lp36_data_reg_s;
        WHEN 7 =>
          readdata_next_s(3 DOWNTO 0) <= lp36_sel_reg_s;
        WHEN OTHERS =>
          readdata_next_s <= (OTHERS => '0');
      END CASE;
    END IF;
  END PROCESS;

  -- Read register process to manage the read register
  read_register_p : PROCESS (avl_reset_i, avl_clk_i)
  BEGIN
    IF avl_reset_i = '1' THEN
      readdatavalid_reg_s <= '0';
      readdata_reg_s <= (OTHERS => '0');
    ELSIF rising_edge(avl_clk_i) THEN
      readdatavalid_reg_s <= readdatavalid_next_s;
      readdata_reg_s <= readdata_next_s;
    END IF;
  END PROCESS;

  -- Output signals
  avl_readdata_o <= readdata_reg_s;
  avl_readdatavalid_o <= readdatavalid_reg_s;

  -- Write access part

  -- Write channel with register management following the adress map specification
  write_register_p : PROCESS (avl_reset_i, avl_clk_i)
  BEGIN
  
  IF avl_reset_i = '1' THEN
  led_reg_s <= (OTHERS => '0');
  lp36_data_reg_s <= (OTHERS => '0');

  ELSIF rising_edge(avl_clk_i) THEN
      start_running_s <= '0';
      IF avl_write_i = '1' THEN
        CASE (to_integer(unsigned(avl_address_i))) IS
          WHEN 0 =>
            -- Reserved
          WHEN 1 =>
            led_reg_s <= avl_writedata_i(9 DOWNTO 0);
          WHEN 2 =>
            -- Reserved
          WHEN 3 =>
            -- Reserved
          WHEN 4 =>
            -- Reserved
          WHEN 5 =>
            start_running_s <= avl_writedata_i(0);
          WHEN 6 =>
            lp36_data_reg_s <= avl_writedata_i;
          WHEN 7 =>
            lp36_sel_reg_s <= avl_writedata_i(3 DOWNTO 0);
          WHEN OTHERS =>
            NULL;
        END CASE;
      END IF;
    END IF;
  END PROCESS;

  -- Output signals
  led_o <= led_reg_s;
  lp36_data_o <= lp36_data_reg_s;
  lp36_sel_o <= lp36_sel_reg_s;
  lp36_we_o <= lp36_we_reg_s;

  -- Interface management
END rtl;