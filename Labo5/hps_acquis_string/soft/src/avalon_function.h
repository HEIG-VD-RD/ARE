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
 * Author               :
 * Date                 :
 *
 * Context              : ARE lab
 *
 *****************************************************************************************
 * Brief: Header file for pio function
 *
 *****************************************************************************************
 * Modifications :
 * Ver    Date        Student      Comments
 *
*****************************************************************************************/
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include "axi_lw.h"


// Base address
#define CONSTANTE_BASE AXI_LW_HPS_FPGA_BASE_ADD
#define INTERFACE_BASE_ADD 0xFF210000

// ACCESS MACROS
#define INTERFACE_REG(_x_) ((volatile uint32_t *)(INTERFACE_BASE_ADD + _x_)) // _x_ is an offset with respect to the base address
// #define H2F(_x_)   (volatile uint32_t *)(H2F_BASE_ADD + _x_)

// Offset interface
#define ID_OFFSET 0x0
#define BOUTON_OFFSET 0x4
#define SWITCH_OFFSET 0x8
#define LED_OFFSET 0xC
#define STATUS_OFFSET 0x10
#define MODE_DELAY_GEN_OFFSET 0x14
#define ACK_OFFSET 0x18
//#define OTHER2_OFFSET 0x1C
#define CHAR_1_4_OFFSET 0x20
#define CHAR_5_8_OFFSET 0x24
#define CHAR_9_12__OFFSET 0x28
#define CHAR_13_16__OFFSET 0x2C
#define CHECKSUM_OFFSET 0x30

#define ID_REG INTERFACE_REG(ID_OFFSET)
#define LED_REG INTERFACE_REG(LED_OFFSET)
#define SWITCH_REG INTERFACE_REG(SWITCH_OFFSET)
#define BOUTON_REG INTERFACE_REG(BOUTON_OFFSET)
#define STATUS_REG INTERFACE_REG(STATUS_OFFSET)
#define MODE_DELAY_GEN_REG INTERFACE_REG(MODE_DELAY_GEN_OFFSET)
#define ACK_REG INTERFACE_REG(ACK_OFFSET)
#define CHAR_1_4_REG INTERFACE_REG(CHAR_1_4_OFFSET)
#define CHAR_5_8_REG INTERFACE_REG(CHAR_5_8_OFFSET)
#define CHAR_9_12_REG INTERFACE_REG(CHAR_9_12__OFFSET)
#define CHAR_13_16_REG INTERFACE_REG(CHAR_13_16__OFFSET)
#define CHECKSUM_REG INTERFACE_REG(CHECKSUM_OFFSET)

#define SWITCHS_MASK 0x3FF
#define LEDS_MASK 0x3FF
#define KEY_MASK 0xF
#define STATUS_MASK 0x3
#define MODE_GEN_MASK 0x10
#define MODE_DELAY_MASK 0x3
#define INIT_CHAR_MASK 0x1
#define NEW_CHAR_MASK 0x10

#define CHECKSUM_MASK (uint32_t)(0xFF)

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

typedef enum
{
	MANUAL,
	AUTOMATIC,
} mode_gen_t;

typedef enum
{
	UN_HZ,
	UN_KHZ,
	CENT_KHZ,
	UN_MHZ,
} delay_freq_t;

typedef enum
{
    NON_FIABLE,
    FIABLE,
} reliability_t;


typedef struct {
    char string[17];          // La chaîne de 16 caractères
    uint32_t checksum;        // Le checksum
    uint32_t integrity;       // Le résultat du calcul d'intégrité
    uint32_t status;         // Le status actuel
} char_data_t;

// Fonction qui lit tous les caractères et calcule l'intégrité
char_data_t Read_string_and_verify(void);

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

// Switchs_read function : Read the switchs value
// Parameter : None
// Return : Value of all Switchs (SW9 to SW0)
uint32_t Switches_read(void);

// Status_read function : Read the status value
// Parameter : None
// Return : Value of the status
uint32_t Status_read(void);

// Mode_gen_read function : Read the mode gen value
// Parameter : None
// Return : Value of the mode
uint32_t Mode_gen_read(void);

// Mode_delay_gen_read function : Read the mode delay value
// Parameter : None
// Return : Value of the mode delay
uint32_t Delay_gen_read(void);

// Checksum_read function : Read the checksum value
// Parameter : None
// Return : Value of the checksum
uint32_t Checksum_read(void);

void Initialize_char(void);

void Generate_new_char(void);

void Reset_command(void);

void Mode_gen_write(mode_gen_t value);

void Mode_delay_write(delay_freq_t value);

