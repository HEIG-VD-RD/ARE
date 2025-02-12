------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : interface_con_80p_max10_prot_0x20.vhd
-- Author               : Anthony Convers
-- Date                 : 04.08.2022
--
-- Context              : Interface de1soc to max10 baord with protocol 0x20
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
    
entity interface_con_80p_max10_prot_0x20 is
  port(
    lp36_we_i         : in  std_logic;
    lp36_sel_i        : in  std_logic_vector(3 downto 0);
    lp36_data_i       : in  std_logic_vector(31 downto 0);
    lp36_status_o     : out std_logic_vector(1 downto 0);
    GPIO_0_io         : inout std_logic_vector(35 downto 0);
    GPIO_1_io         : inout std_logic_vector(35 downto 0)
  );
end interface_con_80p_max10_prot_0x20;

architecture rtl of interface_con_80p_max10_prot_0x20 is

    --| Components declaration |---------------------------------------------------------
    
    --| Constants declarations |--------------------------------------------------------------

    --| Signals declarations   |--------------------------------------------------------------   
    -- Connector 80 poles
    signal DBH_s : std_logic_vector(79 downto 4);
    signal DBH_di_s : std_logic_vector(79 downto 4);
    signal GPIO_0_s : std_logic_vector(35 downto 0);
    signal GPIO_0_oe_s : std_logic_vector(35 downto 0);
    signal GPIO_0_di_s : std_logic_vector(35 downto 0);
    signal GPIO_1_s : std_logic_vector(35 downto 0);
    signal GPIO_1_oe_s : std_logic_vector(35 downto 0);
    signal GPIO_1_di_s : std_logic_vector(35 downto 0);
    
    -- Parallel bus with 36 links
    signal lp36_we_s : std_logic;
    signal lp36_sel_s : std_logic_vector(3 downto 0);
    signal lp36_data_s : std_logic_vector(31 downto 0);
    signal lp36_switch_s : std_logic_vector(5 downto 0);
    signal lp36_boutton_s : std_logic_vector(5 downto 0);
    signal lp36_config_s : std_logic_vector(5 downto 0);
    signal lp36_config_verif_s : std_logic_vector(1 downto 0);

begin

---------------------------------------------------------
--  GPIO 1 & 2 <=> Connector 80 poles 
---------------------------------------------------------
-- portes 3 états
gpio_0_tristate : for i in GPIO_0_s'range generate
   GPIO_0_io(i)   <= GPIO_0_s(i)  when GPIO_0_oe_s(i) = '1'  else
                       'Z';
   GPIO_0_di_s(i) <= GPIO_0_io(i);
end generate;

gpio_1_tristate : for i in GPIO_1_s'range generate
   GPIO_1_io(i)   <= GPIO_1_s(i)  when GPIO_1_oe_s(i) = '1'  else
                       'Z';
   GPIO_1_di_s(i) <= GPIO_1_io(i);
end generate;

-- Connector 80 poles (DBH when output)
GPIO_1_s (8 downto 0) <= DBH_s(13) & DBH_s(10) & DBH_s(11) & DBH_s(8) & DBH_s(9) & DBH_s(6) & DBH_s(7) & DBH_s(4) & DBH_s(5);
GPIO_1_s (17 downto 9) <= DBH_s(20) & DBH_s(21) & DBH_s(18) & DBH_s(19) & DBH_s(16) & DBH_s(17) & DBH_s(14) & DBH_s(15) & DBH_s(12);
GPIO_1_s (26 downto 18) <= DBH_s(32) & DBH_s(28) & DBH_s(30) & DBH_s(26) & DBH_s(27) & DBH_s(24) & DBH_s(25) & DBH_s(22) & DBH_s(23);
GPIO_1_s (35 downto 27) <= DBH_s(39) & DBH_s(40) & DBH_s(37) & DBH_s(38) & DBH_s(35) & DBH_s(36) & DBH_s(33) & DBH_s(34) & DBH_s(31);

GPIO_0_s (8 downto 0) <= DBH_s(53) & DBH_s(50) & DBH_s(51) & DBH_s(48) & DBH_s(49) & DBH_s(46) & DBH_s(47) & DBH_s(44) & DBH_s(45);
GPIO_0_s (17 downto 9) <= DBH_s(60) & DBH_s(61) & DBH_s(58) & DBH_s(59) & DBH_s(56) & DBH_s(57) & DBH_s(54) & DBH_s(55) & DBH_s(52);
GPIO_0_s (26 downto 18) <= DBH_s(71) & DBH_s(68) & DBH_s(69) & DBH_s(66) & DBH_s(67) & DBH_s(64) & DBH_s(65) & DBH_s(62) & DBH_s(63);
GPIO_0_s (35 downto 27) <= DBH_s(78) & DBH_s(79) & DBH_s(76) & DBH_s(77) & DBH_s(74) & DBH_s(75) & DBH_s(72) & DBH_s(73) & DBH_s(70);

-- Connector 80 poles (DBH when input)
DBH_di_s(12 downto 4) <= GPIO_1_di_s(9) & GPIO_1_di_s(6) & GPIO_1_di_s(7) & GPIO_1_di_s(4) & GPIO_1_di_s(5) & GPIO_1_di_s(2) & GPIO_1_di_s(3) & GPIO_1_di_s(0) & GPIO_1_di_s(1);
DBH_di_s(21 downto 13) <= GPIO_1_di_s(16) & GPIO_1_di_s(17) & GPIO_1_di_s(14) & GPIO_1_di_s(15) & GPIO_1_di_s(12) & GPIO_1_di_s(13) & GPIO_1_di_s(10) & GPIO_1_di_s(11) & GPIO_1_di_s(8);
DBH_di_s(31 downto 22) <= GPIO_1_di_s(27) & GPIO_1_di_s(24) & '0' & GPIO_1_di_s(25) & GPIO_1_di_s(22) & GPIO_1_di_s(23) & GPIO_1_di_s(20) & GPIO_1_di_s(21) & GPIO_1_di_s(18) & GPIO_1_di_s(19);   -- DBH_29 : NC
DBH_di_s(40 downto 32) <= GPIO_1_di_s(34) & GPIO_1_di_s(35) & GPIO_1_di_s(32) & GPIO_1_di_s(33) & GPIO_1_di_s(30) & GPIO_1_di_s(31) & GPIO_1_di_s(28) & GPIO_1_di_s(29) & GPIO_1_di_s(26);

DBH_di_s(52 downto 44) <= GPIO_0_di_s(9) & GPIO_0_di_s(6) & GPIO_0_di_s(7) & GPIO_0_di_s(4) & GPIO_0_di_s(5) & GPIO_0_di_s(2) & GPIO_0_di_s(3) & GPIO_0_di_s(0) & GPIO_0_di_s(1);
DBH_di_s(61 downto 53) <= GPIO_0_di_s(16) & GPIO_0_di_s(17) & GPIO_0_di_s(14) & GPIO_0_di_s(15) & GPIO_0_di_s(12) & GPIO_0_di_s(13) & GPIO_0_di_s(10) & GPIO_0_di_s(11) & GPIO_0_di_s(8);
DBH_di_s(70 downto 62) <= GPIO_0_di_s(27) & GPIO_0_di_s(24) & GPIO_0_di_s(25) & GPIO_0_di_s(22) & GPIO_0_di_s(23) & GPIO_0_di_s(20) & GPIO_0_di_s(21) & GPIO_0_di_s(18) & GPIO_0_di_s(19);
DBH_di_s(79 downto 71) <= GPIO_0_di_s(34) & GPIO_0_di_s(35) & GPIO_0_di_s(32) & GPIO_0_di_s(33) & GPIO_0_di_s(30) & GPIO_0_di_s(31) & GPIO_0_di_s(28) & GPIO_0_di_s(29) & GPIO_0_di_s(26);

---------------------------------------------------------
-- Connector 80 poles usage for 36 parallel links
---------------------------------------------------------

-- Inputs and Outputs signals
lp36_we_s <= lp36_we_i;
lp36_sel_s <= lp36_sel_i;
lp36_data_s <= lp36_data_i;
lp36_status_o <= lp36_config_verif_s;

-- Utilisation du design MAX10 avec liaison parallèle sur 36 liens direct.
-- Configuration des signaux input et output sur con80p
GPIO_1_oe_s(8 downto 0) <= "011111111";
GPIO_1_oe_s(17 downto 9) <= "000000001";
GPIO_1_oe_s(26 downto 18) <= "000000000";
GPIO_1_oe_s(35 downto 27) <= "000000000";

GPIO_0_oe_s(8 downto 0) <= "111111111";
GPIO_0_oe_s(17 downto 9) <= "111111111";
GPIO_0_oe_s(26 downto 18) <= "111111111";
GPIO_0_oe_s(35 downto 27) <= "111111001";

-- Output signal du connecteur 80p
DBH_s(4) <= lp36_we_s;
DBH_s(8 downto 5) <= lp36_sel_s;
DBH_s(12 downto 9) <= lp36_data_s(3 downto 0);
DBH_s(43 downto 13) <= (others => '0');
DBH_s(71 downto 44) <= lp36_data_s(31 downto 4);
DBH_s(73 downto 72) <= (others => '0');
DBH_s(79 downto 74) <= lp36_config_s;

-- Input signal du connecteur 80p
lp36_switch_s <= DBH_di_s(24 downto 19);
lp36_boutton_s <= DBH_di_s(18 downto 13);
lp36_config_verif_s <= DBH_di_s(73 downto 72);

-- Configuration on connector 80p
lp36_config_s <= "100000";  --config prot 0x20


end rtl; 