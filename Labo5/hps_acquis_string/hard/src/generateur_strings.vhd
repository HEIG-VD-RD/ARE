------------------------------------------------------------------------------------------
-- HEIG-VD
-- Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- School of Business and Engineering in Canton de Vaud
------------------------------------------------------------------------------------------
-- REDS Institute
-- Reconfigurable Embedded Digital Systems
------------------------------------------------------------------------------------------
--
-- File                 : generateur_strings.vhd
-- Author               : Anthony Convers
-- Date                 : 14.11.2022
--
-- Context              : ARE acquisition nombre lab
--
------------------------------------------------------------------------------------------
-- Description : Generate strings
--
------------------------------------------------------------------------------------------
-- Dependencies :
--
------------------------------------------------------------------------------------------
-- Modifications :
-- Ver    Date        Engineer      Comments
-- 0.0    14.11.2022  ACS           Initial version.
-- 0.1    18.07.2023  ACS           Change nomber formula.
--
------------------------------------------------------------------------------------------

library IEEE;
use IEEE.Std_Logic_1164.all;
use ieee.numeric_std.all;

entity generateur_strings is
    port (clock_i       : in  std_logic;  -- system clock
          reset_i       : in  std_logic;  -- reset
          cmd_init_i    : in  std_logic;
          cmd_new_char_i : in  std_logic;
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
end generateur_strings;

architecture struct of generateur_strings is

    --| Components declaration |------------------------------------------------------------

    --| Signals declaration    |------------------------------------------------------------
    constant x_axis_init_val_c : signed(7 downto 0) := to_signed(0, 8);
    constant cpt_val_0_c : unsigned(31 downto 0) := to_unsigned(50000000, 32);  --1Hz
    constant cpt_val_1_c : unsigned(31 downto 0) := to_unsigned(50000, 32);	    --1kHz
    constant cpt_val_2_c : unsigned(31 downto 0) := to_unsigned(500, 32);		--100kHz
    constant cpt_val_3_c : unsigned(31 downto 0) := to_unsigned(50, 32);		--1MHz
    
    type ascii_array_type is array (0 to 15) of std_logic_vector(127 downto 0);
    type checksum_array_type is array (0 to 15) of std_logic_vector(7 downto 0);
    
    -- string of 16 char (15 caratères + 1Null), Null is recommended to avoid bug with printf
    constant messages : ascii_array_type := (
        X"48656C6C6F20776F726C642120202000", 
        X"4C61626F7261746F6972652041524500",
        X"54657374696E67207668646C20202000",
        X"47616D65206F766572203A2820202000",
        X"484549472D5644205265647320202000",
        X"4269656E746F742066696E693F202000",
        X"56616C69646174696F6E20646F6E6500",
        X"56656E6472656469206170726D202000",
        X"4269656E746F74206C65207765656B00",
        X"4761676E65722120427261766F202000",
        X"45737361796520656E636F7265202000",
        X"50617573652063616665212020202000",
        X"546F7574207661206269656E3F202000",
        X"4572726575722073797374656D652000",
        X"436F6E74696E756520656E636F726500",
        X"456D6265646465642073797374656D00" 
    );
    
    constant messages_check : checksum_array_type := (
        X"43",
        X"94",
        X"F4",
        X"C8",
        X"0E",
        X"E6",
        X"2F",
        X"BF",
        X"6E",
        X"31",
        X"BA",
        X"B2",
        X"20",
        X"41",
        X"1F",
        X"31" 
    );
    
    signal buffer_messages : ascii_array_type := messages;
    signal buffer_checksum : checksum_array_type := messages_check;
    
    signal counter_array_s : integer range 0 to 15;

    signal x_axis_val_s  : std_logic_vector(7 downto 0);
    signal init_system_s : std_logic;
    signal auto_s        : std_logic;
    signal lfsr_s        : std_logic;
    signal cmd_new_char_reg_s  : std_logic_vector(1 downto 0);
    signal cpt_s         : unsigned(31 downto 0);
    signal pulse_s       : std_logic;

begin

    ----------------------------------------------------------------------------------------
    --| Components intanciation |-----------------------------------------------------------


    ----------------------------------------------------------------------------------------
    --| pulse system processing |-----------------------------------------------------------
    process(clock_i, reset_i)
    begin
        if reset_i = '1' then
            x_axis_val_s <= std_logic_vector(x_axis_init_val_c);
            counter_array_s <= 0;

        elsif rising_edge(clock_i) then
            if init_system_s = '1' then
                x_axis_val_s <= std_logic_vector(x_axis_init_val_c);
                counter_array_s <= 0;
            else
                if auto_s = '1' then    -- Auto generate pulse
                    if pulse_s = '1' then
                        x_axis_val_s <= x_axis_val_s(6 downto 0) & lfsr_s;
                        --counter_array_s <= counter_array_s + 1;
                    end if;
                else                    -- Manual generate pulse
                    if ((cmd_new_char_reg_s(1) = '0') and (cmd_new_char_reg_s(0) = '1')) then
                        x_axis_val_s <= x_axis_val_s(6 downto 0) & lfsr_s;
                        --counter_array_s <= counter_array_s + 1;
                    end if;
                end if;
                
                counter_array_s <= to_integer(unsigned(x_axis_val_s)); -- X
                
            end if;
        end if;
    end process;
    
    lfsr_s <= x_axis_val_s(7) XNOR x_axis_val_s(5) XNOR x_axis_val_s(4) XNOR x_axis_val_s(3);

    process(clock_i, reset_i)
    begin
      if reset_i = '1' then
        init_system_s <= '0';
        auto_s        <= '0';
        cmd_new_char_reg_s  <= "00";
      elsif rising_edge(clock_i) then
        init_system_s <= cmd_init_i;
        auto_s        <= auto_i;
        cmd_new_char_reg_s  <= cmd_new_char_reg_s(0) & cmd_new_char_i;
      end if;
    end process;
    
    process(clock_i, reset_i)
    begin
      if reset_i = '1' then
        cpt_s   <= cpt_val_0_c;
        pulse_s <= '0';
      elsif rising_edge(clock_i) then
        if auto_s = '1' then
          if cpt_s = 0 then
            if delay_i="00" then
				cpt_s   <= cpt_val_0_c;
            elsif delay_i="01" then
				cpt_s   <= cpt_val_1_c;
            elsif delay_i="10" then
				cpt_s   <= cpt_val_2_c;
            else
				cpt_s   <= cpt_val_3_c;
            end if;
            pulse_s <= '1';
          else
            cpt_s   <= cpt_s - 1;
            pulse_s <= '0';
          end if;
        else
          if delay_i="00" then
			cpt_s   <= cpt_val_0_c;
          elsif delay_i="01" then
			cpt_s   <= cpt_val_1_c;
          elsif delay_i="10" then
			cpt_s   <= cpt_val_2_c;
          else
			cpt_s   <= cpt_val_3_c;
          end if;
          pulse_s <= '0';
        end if;
      end if;
    end process;

    char_1_o  <= buffer_messages(counter_array_s)(127-(8*0) downto 120-(8*0));
    char_2_o  <= buffer_messages(counter_array_s)(127-(8*1) downto 120-(8*1));
    char_3_o  <= buffer_messages(counter_array_s)(127-(8*2) downto 120-(8*2));
    char_4_o  <= buffer_messages(counter_array_s)(127-(8*3) downto 120-(8*3));
    char_5_o  <= buffer_messages(counter_array_s)(127-(8*4) downto 120-(8*4));
    char_6_o  <= buffer_messages(counter_array_s)(127-(8*5) downto 120-(8*5));
    char_7_o  <= buffer_messages(counter_array_s)(127-(8*6) downto 120-(8*6));
    char_8_o  <= buffer_messages(counter_array_s)(127-(8*7) downto 120-(8*7));
    char_9_o  <= buffer_messages(counter_array_s)(127-(8*8) downto 120-(8*8));
    char_10_o <= buffer_messages(counter_array_s)(127-(8*9) downto 120-(8*9));
    char_11_o <= buffer_messages(counter_array_s)(127-(8*10) downto 120-(8*10));
    char_12_o <= buffer_messages(counter_array_s)(127-(8*11) downto 120-(8*11));
    char_13_o <= buffer_messages(counter_array_s)(127-(8*12) downto 120-(8*12));
    char_14_o <= buffer_messages(counter_array_s)(127-(8*13) downto 120-(8*13));
    char_15_o <= buffer_messages(counter_array_s)(127-(8*14) downto 120-(8*14));
    char_16_o <= buffer_messages(counter_array_s)(127-(8*15) downto 120-(8*15));
    checksum_o <= buffer_checksum(counter_array_s);


end struct;
