/*****************************************************************************************
 * HEIG-VD
 * Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
 * School of Business and Engineering in Canton de Vaud
 *****************************************************************************************
 * REDS Institute
 * Reconfigurable Embedded Digital Systems
 *****************************************************************************************
 *
 * File                 : hps_application.c
 * Author               :
 * Date                 :
 *
 * Context              : ARE lab
 *
 *****************************************************************************************
 * Brief: Conception d'une interface simple sur le bus Avalon avec la carte DE1-SoC
 *
 *****************************************************************************************
 * Modifications :
 * Ver    Date        Student      Comments
 *
 *
 *****************************************************************************************/
#include "avalon_function.h"

// #include "pio_function.h"

int __auto_semihosting;

#define SWITCH_9_8 (0x3 << 8)
#define SWITCH_7_0 (0xFF)
#define VALUE_A 0xAAAAAAAA
#define VALUE_F 0xFFFFFFFF
#define VALUE_5 0x55555555
#define VALUE_OFF 0x00000000
#define MODE_3 0x3
int main(void)
{
	printf("Laboratoire: Conception d'une interface simple \n");

	// Check the status of the LP36
	if(Max10_check_status() == false ){
		printf("Erreur : Configuration non valide.\n");
		return -1;
	}

	// Read and display the constants
	volatile uint32_t *constante = (volatile uint32_t *)H2F_BASE_ADD;
	printf("Constante à l'adresse 0xFF200000 de l'AXI: 0x%X\n", *constante);
	constante = (volatile uint32_t *)INTERFACE_BASE_ADD;
	printf("Constante à l'adresse 0xFF210000 de notre interface: 0x%X\n", *constante);

	// Sets the LEDs to 0
	Leds_write((VALUE_OFF));
	Max10_write_all(VALUE_OFF);
	
	// Counter variable for the squared leds
	uint32_t i = 0;

	while (1)
	{
		uint32_t switch_value = Switchs_read();
		uint32_t state_sw98 = switch_value & SWITCH_9_8;
		uint32_t state_sw70 = switch_value & SWITCH_7_0;
		uint32_t key_10 = (Key_read(1) << 1) | Key_read(0);
		uint32_t lp36_selection;
		uint32_t value_to_write;

		// We continuously write the value of the switches to the LEDs of the de1soc
		Leds_write(switch_value);

		// We select which LEDs of the lp36 to write
		lp36_selection = (state_sw98 >> 8);

		// Depending on the value of the key 10, we select the value to write
		switch(key_10){
			case 0:
				value_to_write = 0x0 | state_sw70;

				// If we are in mode 3, we rotate the value to write since we need to 
				// move "down" the value to write in the square leds
				if(lp36_selection == MODE_3){
					// Rotate the value to write
					value_to_write = (value_to_write << (5 * i)) | (value_to_write >> (25 - (5 * i)));
				}
				break;
			case 1:
				value_to_write =  VALUE_A;
				break;
			case 2:
				value_to_write =  VALUE_5;
				break;
			case 3:
				value_to_write = VALUE_F ;
				break;
		}

		// If we are in mode 3 and push the key 2, we increment the counter
		if (Key_read_edge(2) && lp36_selection == 0x3)
		{
			i = (i + 1) % 5;
		}

		// With the key 3, we reset the counter and turn off the leds
		// Otherwise, we write the value to the leds
		if (Key_read(3))
		{
			i = 0;
			value_to_write = VALUE_OFF ;
			Max10_write_all(value_to_write);
		}
		else{
			Max10_write_leds(value_to_write,lp36_selection);
		}

	}
}
