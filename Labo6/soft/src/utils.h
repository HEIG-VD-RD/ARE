/*****************************************************************************************
 * HEIG-VD
 * Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
 * School of Business and Engineering in Canton de Vaud
 *****************************************************************************************
 * REDS Institute
 * Reconfigurable Embedded Digital Systems
 *****************************************************************************************
 *
 * File                 : utils.h
 * Author               : Rafael Dousse & Romain Humair
 * Date                 : 18.12.2025
 *
 * Context              : ARE lab
 *
 *****************************************************************************************
 * Brief: Header file for the utils functions
 *
 *****************************************************************************************
 * Modifications :
 * Ver    Date        Student      Comments
 * 0.0    18.12.2025  RAD & RHR     Initial version.
 *
 *****************************************************************************************/
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include "axi_lw.h"

// Base address
#define INTERFACE_BASE_ADD 0xFF210000
#define CONSTANTE_BASE AXI_LW_HPS_FPGA_BASE_ADD // base address for variable to read

// ACCESS MACROS
#define INTERFACE_REG(_x_) ((volatile uint32_t *)(INTERFACE_BASE_ADD + _x_)) // _x_ is an offset with respect to the base address

// Offset interface
#define ID_OFFSET 0x0
#define BOUTON_OFFSET 0x4
#define SWITCH_OFFSET 0x8
#define LED_OFFSET 0xc
#define HEX_OFFSET 0x10

#define SERIAL_STAT_R 0x14
#define SERIAL_DATA_R_W 0x18
#define SERIAL_START_W 0x1C
#define INTERRUPT_STATUS_R 0x20
#define INTERRUPT_ACK_W 0x20
#define INTERRUPT_MASK_W 0x24
#define COUNTER_VALUE_R 0x30
#define COUNTER_ACTION_W 0x34

// UART communication register
#define UART0_BASE 0xFFC02000
#define UART_REG(_x_) ((volatile uint32_t *)(UART0_BASE + _x_)) // _x_ is an offset with respect to the base address
#define UART0_THR 0x0											// Transmit Holding Register
#define UART0_DLL 0x0											// Divisor Latch Low Register
#define UART0_DLH 0x4											// Divisor Latch High Register
#define UART0_LSR 0x14											// Line Status Register
#define UART0_LCR 0xC											// Line Control Register
#define LSR_THRE (1 << 5)										// Transmit Holding Register Empty flag
#define UART0_FCR 0x8											// Offset du FIFO Control Register
#define FCR_FIFO_ENABLE 0x1										// Activer les FIFO en émission et réception

#define BOUTON_BITS 0x0000000F
#define SWITCHS_BITS 0x000003FF
#define LEDS_BITS 0x000003FF
#define LED0 (uint32_t)(1 << 0)
#define LED1 (uint32_t)(1 << 1)
#define LED2 (uint32_t)(1 << 2)
#define LED3 (uint32_t)(1 << 3)
#define LED4 (uint32_t)(1 << 4)
#define LED5 (uint32_t)(1 << 5)
#define LED6 (uint32_t)(1 << 6)
#define LED7 (uint32_t)(1 << 7)
#define LED8 (uint32_t)(1 << 8)
#define LED9 (uint32_t)(1 << 9)

// Masks for the HEX displays
#define HEX_3 0x0FE00000
#define HEX_2 0x001FC000
#define HEX_1 0x00003F80
#define HEX_0 0x0000007f
#define HEX_MAX 0xF

// Figures for the MAX10
#define FIGURE_MASK 0xFFFF
#define VAL_START 0x03f1C63F
#define VAL_WAITING 0x0847C84
#define VAL_END 0x00E39C0
#define ZONE_L 0x6
#define ZONE_H 0x7

// State of the game
typedef enum
{
	WAITING,
	START,
	END,
	OFF
} state_t;

// State machine for the game
typedef enum
{
    GAME_IDLE,
    GAME_WAITING,
    GAME_REACTING,
    GAME_FINISHED
} game_state_t;


// Data structure for the game
typedef struct
{
	uint32_t best_time;
	uint32_t worst_time;
	uint32_t last_time;
	uint32_t total_errors;
	uint32_t total_attempts;
} data_time;

// Struct that represent a number
typedef struct
{
	uint32_t millier;
	uint32_t centieme;
	uint32_t dizaine;
	uint32_t unite;
} number_t;

// Numbers and letters in hexa
extern uint32_t hexValue[];

// Leds_write function : Write a value to all Leds (LED9 to LED0)
// Parameter : "value"= data to be applied to all Leds
// Return : None
void Leds_write(uint32_t value);

// Leds_set function : Set to ON some or all Leds (LED9 to LED0)
// Parameter : "maskleds"= Leds selected to apply a set (maximum 0x3FF)
// Return : None
void Leds_set(uint32_t maskleds);

// Leds_read function : Read the value of all Leds (LED9 to LED0)
// Parameter : "led"= mask to select the Leds to read
// Return : Value of the Led
uint32_t Leds_read(uint32_t led);

// Key_read function : Read one Key status, pressed or not (KEY0 or KEY1 or KEY2 or KEY3)
// Parameter : "key_number"= select the key number to read, from 0 to 3
// Return : True(1) if key is pressed, and False(0) if key is not pressed
bool Key_read(int key_number);

// Key_read_edge function : Read one Key status, pressed or not but only on the rising edge
// Parameter : "key_number"= select the key number to read, from 0 to 3
// Return : True(1) if key is pressed, and False(0) if key is not pressed
bool Key_read_edge(int key_number);

// Switchs_read function : Read the switchs value
// Parameter : None
// Return : Value of all Switchs (SW9 to SW0)
uint32_t Switchs_read(void);

// Seg7_write function : Write digit segment value to one 7-segments display (HEX0 or HEX1 or HEX2 or HEX3)
// Parameter : "seg7_number"= select the 7-segments number, from 0 to 3
// Parameter : "value"= digit segment value to be applied on the selected 7-segments (maximum 0x7F to switch ON all segments)
// Return : None
void Seg7_write(int seg7_number, uint32_t value);

// Seg7_write_hex function : Write an Hexadecimal value to one 7-segments display (HEX0 or HEX1 or HEX2 or HEX3)
// Parameter : "seg7_number"= select the 7-segments number, from 0 to 3
// Parameter : "value"= Hexadecimal value to be display on the selected 7-segments, form 0x0 to 0xF
// Return : None
void Seg7_write_hex(int seg7_number, uint32_t value);

// Update_display function : Update the value of the 7-segments displays in one operation
// Parameter : "chrono" Value to be displayed
void Update_display(number_t chrono);

// Serial_status_read function : Read the status of the serial communication
// Parameter : None
// bit [1:0] : State of the serial communication (connecteur 80 pôles)
// bit [2] : State busy of serial communication
// Return : Status of the serial communication
uint32_t Serial_status_read(void);

// Serial_data_write function : Write a data to the serial communication
// Parameter : "data"= data to be written
// Return : None
void Serial_data_write(uint32_t data);

// Serial_data_read function : Read a data from the serial communication
// Parameter : None
// Return : Data read from the serial communication
uint32_t Serial_data_read(void);

// Serial_start function : Start or stop the serial communication
// Parameter : "start"= True(1) to start the serial communication, False(0) to stop the serial communication
// Return : None
void Serial_start(bool start);

// Interrupt_status_read function : Read the status of the interrupt
// Parameter : None
// bit [0] : Status of the interrupt
// bit [1] : Status of the mask interrupt
// Return : Status of the interrupt
uint32_t Interrupt_status_read(void);

// Interrupt_ack function : Acknowledge the interrupt
// Parameter : None
// Return : None
void Interrupt_ack(void);

// Interrupt_mask_set function : Set the mask of the interrupt
// Parameter : "enable"= True(1) to enable the interrupt, False(0) to disable the interrupt
// Return : None
void Interrupt_mask_set(bool enable);

// Counter_value_read function : Read the value of the counter
// Parameter : None
// Return : Value of the counter in ms
double Counter_get_value(void);

// Counter_action function : Action on the counter
// Parameter1 : "enable"= True(1) to enable the counter, False(0) to disable the counter
// Parameter2 : "reset"= True(1) to reset the counter, False(0) to not reset the counter
// Return : None
void Counter_action(bool enable, bool reset);

// uart_init function : Initialize the UART communication
// Parameter : None
// Return : None
void uart_init();

// uart_send function : Send a character to the UART communication
// Parameter1 : "c"= character to be sent
// Parameter2 : "add_newline"= True(1) to add a new line after the character.
// Return : None
void uart_send_string(const char *str, bool add_newline);

// uart_send_number function : Send a number to the UART communication
// Parameter1 : "number"= number to be sent
// Parameter2 : "suffix"= suffix to be added after the number
// Return : None
void uart_send_number(uint32_t number, const char *suffix);

// afficher_resultats_uart function : Display the results of the game on the UART communication
// Parameter1 : "datas"= data of the game
// Parameter2 : "reaction_time"= reaction time of the player
// Parameter3 : "early_press"= True(1) if the player press the key too early
// Return : None
void afficher_resultats_uart(data_time datas, uint32_t reaction_time, bool early_press);

// Max10_set_leds function : Set the value of the LEDs of the MAX10
// Parameter1 : "zone_code"= zone of the MAX10 to be set
// Parameter2 : "led_data"= value to be set on the selected zone
// Return : True(1) if the operation is successful, False(0) if the max10 is not connected
bool Max10_set_leds(uint32_t zone_code, uint16_t led_data);

// afficher_regles_du_jeu_uart function : Display the rules of the game on the UART communication
// Parameter : None
// Return : None
void afficher_regles_du_jeu_uart();

// Counter_reset function : Reset the counter
// Parameter : None
// Return : None
void Counter_reset(void);

// Counter_start function : Start the counter
// Parameter : None
// Return : None
void Counter_start(void);

// Counter_stop function : Stop the counter
// Parameter : None
// Return : None
void Counter_stop(void);

// Max10_show_figure function : Show a figure on the MAX10
// Parameter : "figure"= figure to be displayed
// Return : None
void Max10_show_figure(state_t figure);

// get_number function : Convert a chrono value to a number values
// Parameter1 : "num"= Number to be filled
// Parameter2 : "value"= Value to be converted
// Return : None
void get_number(number_t *num, uint32_t value);