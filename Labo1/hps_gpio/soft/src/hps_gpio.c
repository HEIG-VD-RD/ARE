/*****************************************************************************************
 * HEIG-VD
 * Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
 * School of Business and Engineering in Canton de Vaud
 *****************************************************************************************
 * REDS Institute
 * Reconfigurable Embedded Digital Systems
 *****************************************************************************************
 *
 * File                 : hps_gpio.c
 * Author               : Rafael Dousse
 * Date                 : 01.10.24
 *
 * Context              : ARE Introduction lab
 *
 *****************************************************************************************
 * Brief: light HPS user LED up when HPS user button pressed, for DE1-SoC board
 *
 *****************************************************************************************
 * Modifications :
 * Ver    Date        Student      Comments
 *
 *
 *****************************************************************************************/
#include <stdint.h>
#include <stdio.h>
#include <inttypes.h>

int __auto_semihosting;

#define BASE_ADDRESS 0xFF709000
#define GPIO_SWPORTA_DR (BASE_ADDRESS + 0x00)
#define GPIO_SWPORTA_DDR (BASE_ADDRESS + 0x04)
#define GPIO_EXT_PORTA (BASE_ADDRESS + 0x50)

#define LED (1 << 24)
#define BUTTON (1 << 25)

volatile uint32_t *gpio_dr_ptr = (volatile uint32_t *)GPIO_SWPORTA_DR;
volatile uint32_t *gpio_ddr_ptr = (volatile uint32_t *)GPIO_SWPORTA_DDR;
volatile uint32_t *gpio_extporta = (volatile uint32_t *)GPIO_EXT_PORTA;

uint32_t button_state;

int main(void)
{
	printf("Test Labo introduction\n");
	// On spécifie que on veut que la LED soit une sortie
	*gpio_ddr_ptr |= LED;

	while (1)
	{
		// On fait un ET entre le registre et le bit du bouton
		//  Si le registre est a 1 alors le bouton est relaché mais si
		//  le registre est à 0 alors le bouton est appuyé
		button_state = (uint32_t)(((*gpio_extporta) & BUTTON));
		if (button_state != 0)
		{
			*gpio_dr_ptr &= ~LED;
		}
		else
		{
			*gpio_dr_ptr |= LED;
		}
	}
	return 0;
}
