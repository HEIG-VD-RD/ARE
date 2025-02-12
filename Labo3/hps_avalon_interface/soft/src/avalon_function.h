/*****************************************************************************************
 * HEIG-VD
 * Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
 * School of Business and Engineering in Canton de Vaud
 *****************************************************************************************
 * REDS Institute
 * Reconfigurable Embedded Digital Systems
 *****************************************************************************************
 *
 * File                 : avalon_function.h
 * Author               : Rafael Dousse & Patrick Maillard
 * Date                 : 09.11.2024
 *
 * Context              : ARE lab
 *
 *****************************************************************************************
 * Brief: Header file for avalon function
 *
 *****************************************************************************************
 * Modifications :
 * Ver    Date        Student      Comments
 * 0.0    09.11.2024  RAD & PAM     Initial version.
 *
*****************************************************************************************/
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include "axi_lw.h"


// Base address
#define H2F_BASE_ADD AXI_LW_HPS_FPGA_BASE_ADD
#define INTERFACE_BASE_ADD 0xFF210000

// ACCESS MACROS
#define INTERFACE_REG(_x_) ((volatile uint32_t *)(INTERFACE_BASE_ADD + _x_)) // _x_ is an offset with respect to the base address
// #define H2F(_x_)   (volatile uint32_t *)(H2F_BASE_ADD + _x_)

// Offset interface
#define ID_OFFSET 0x0
#define LED_OFFSET 0x4
#define SWITCH_OFFSET 0x8
#define BOUTON_OFFSET 0xC
#define LP36_STATUS_OFFSET 0x10
#define LP36_WE_OFFSET 0x14
#define LP36_DATA_OFFSET 0x18
#define LP36_SEL_OFFSET 0x1C

#define ID_REG INTERFACE_REG(ID_OFFSET)
#define LED_REG INTERFACE_REG(LED_OFFSET)
#define SWITCH_REG INTERFACE_REG(SWITCH_OFFSET)
#define BOUTON_REG INTERFACE_REG(BOUTON_OFFSET)
#define LP36_STATUS_REG INTERFACE_REG(LP36_STATUS_OFFSET)
#define LP36_WE_REG INTERFACE_REG(LP36_WE_OFFSET)
#define LP36_DATA_REG INTERFACE_REG(LP36_DATA_OFFSET)
#define LP36_SEL_REG INTERFACE_REG(LP36_SEL_OFFSET)

#define SWITCHS_BITS 0x000003FF
#define LEDS_BITS 0x000003FF
#define BOUTON_BITS 0x0000000F
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

#define LP36_STATUS_VALID 0x01

#define NUM_MODE 4

// Variable to store the state of the keys
bool positive_edge[4] = {true, true, true, true};

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

// Max10_check_status function : Check the status of the LP36
// Parameter : None
// Return : True(1) if the status is valid, and False(0) if the status is not valid
bool Max10_check_status(void);

// Max10_write_leds function : Write a value to the LP36
// Parameter1 : "value"= data to be applied to the LP36
// Parameter2 : "sel"= select the leds to write
// Return : None
void Max10_write_leds(uint32_t value, uint8_t sel);

// Max10_read_leds function : Read the value of the LP36
// Parameter : "sel"= select the leds to read
// Return : Value of the leds
uint32_t Max10_read_leds(uint8_t sel);

// Max10_write_all function : Write a value to all the leds 
// Parameter : "value"= data to be applied to all the leds of the LP36
// Return : None
void Max10_write_all(uint32_t value);




