------------------------------------------------------------------------------------------
-- HEIG-VD ///////////////////////////////////////////////////////////////////////////////
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute ////////////////////////////////////////////////////////////////////////
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : timer.vhd
-- Author               : Rafael Dousse & Patrick Maillard
-- Date                 : 10.11.2024
--
-- Context              : Avalon user interface
--
------------------------------------------------------------------------------------------
-- Description : Timer utilisé pour le Write enable du LP36 qui doit être actif pendant 1 micro seconde.
--               Dans le cadre du laboratoire avalon_interface
--   
------------------------------------------------------------------------------------------
-- Dependencies : 
--   
------------------------------------------------------------------------------------------
-- Modifications :
-- Ver    Date        Engineer    Comments
-- 0.0    See header  RAD & PAM   Initial version

------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY timer IS
    GENERIC (
        T1_g : NATURAL RANGE 1 TO 1023 := 50);
    PORT (
        clock_i : IN STD_LOGIC;
        reset_i : IN STD_LOGIC;
        start_i : IN STD_LOGIC;
        timer_o : OUT STD_LOGIC
    );
END timer;
ARCHITECTURE comport OF timer IS

    -- Declaration des signaux internes
    SIGNAL etat_fut : unsigned(10 DOWNTO 0);
    SIGNAL etat_pres : unsigned(10 DOWNTO 0);
    SIGNAL Q_decr : unsigned(10 DOWNTO 0);

BEGIN

    etat_fut <= to_unsigned(T1_g, etat_pres'length) WHEN start_i = '1' ELSE
        Q_decr when etat_pres > 0 ELSE
        etat_pres;

    PROCESS (clock_i, reset_i)
    BEGIN
        IF reset_i = '0' THEN
            etat_pres <= to_unsigned(T1_g, etat_pres'length);
        ELSIF rising_edge(clock_i) THEN
            etat_pres <= etat_fut;
        END IF;
    END PROCESS;

    -- Incrémentation de l'état
    Q_decr <= etat_pres - 1;

    timer_o <= '1' when etat_pres > 0 ELSE '0';
END comport;