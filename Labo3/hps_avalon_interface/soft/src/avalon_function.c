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
 * Brief: Avalon functions
 *
 *****************************************************************************************
 * Modifications :
 * Ver    Date        Student      Comments
 * 0.0    09.11.2024  RAD & PAM     Initial version.
 *
*****************************************************************************************/
#include "avalon_function.h"


uint32_t Switchs_read(void)
{
	volatile uint32_t *value_switchs = SWITCH_REG;
	return ((*value_switchs & SWITCHS_BITS));
}


void Leds_write(uint32_t value)
{
	if (value > 0x3FF)
	    {
	        printf("Error: value is too big\n");
	        return;
	    }
	volatile uint32_t *value_leds = LED_REG;
	*value_leds = value; // Remplace directement la valeur des LEDs
}

void Leds_set(uint32_t maskleds)
{
	if (maskleds > 0x3ff)
	{
		printf("Error: maskleds is too big\n");
		return;
	}
	volatile uint32_t *value_leds = LED_REG;
	 *value_leds |= maskleds; // Allume les LEDs spécifiées par le masque
}

uint32_t Leds_read(uint32_t led)
{
	volatile uint32_t *value_leds = LED_REG;

	return (*value_leds & led);
}

bool Key_read(int key_number)
{
	volatile uint32_t *dataValue = BOUTON_REG;
	uint32_t my_key_value = (*dataValue >> key_number) & 0x1;
	return my_key_value;
}


bool Key_read_edge(int key_number)
{
	volatile uint32_t *dataValue = BOUTON_REG;
	// Get the key number and check its value
	uint32_t my_key_value = (*dataValue >> key_number) & 0x1;

	if (my_key_value == 1 && !positive_edge[key_number])
	{									  // Key is pressed (active low) and no edge detected yet
		positive_edge[key_number] = true; // Mark the positive edge (key press) as detected
		return true; // Rising edge (key press) detected
	}
	else if (my_key_value == 0 && positive_edge[key_number])
	{									   // Key is released (active low)
		positive_edge[key_number] = false; // Reset the edge detection for the next press
	}

	return false;
}

bool Max10_check_status(void)
{
    volatile uint32_t *status = LP36_STATUS_REG;
    return ((*status & LP36_STATUS_VALID) == LP36_STATUS_VALID);
}

int Max10_check_WE(void){
	volatile uint32_t *we_reg = LP36_WE_REG;

	return *we_reg;
}

int Max10_read_sel(void){
	volatile uint32_t *sel_reg = LP36_WE_REG;

	return *sel_reg;
}

void Max10_write_leds(uint32_t value, uint8_t sel)
{
	volatile uint32_t *sel_reg = LP36_SEL_REG;
	volatile uint32_t *data_reg = LP36_DATA_REG;
	volatile uint32_t *we_reg = LP36_WE_REG;

    if (sel > 0x0F)
    {
        printf("Erreur : Valeur de sel invalide.\n");
        return;
    }
	*we_reg = 1; //start_running_s dans vhdl
    *sel_reg = sel;
    *data_reg = value;
}

uint32_t Max10_read_leds(uint8_t sel)
{
	volatile uint32_t *sel_reg = LP36_SEL_REG;
	volatile uint32_t *data_reg = LP36_DATA_REG;

    if (sel > 0x0F)
    {
        printf("Erreur : Valeur de sel invalide.\n");
        return 0;
    }


    *sel_reg = sel;
    return *data_reg;
}

void Max10_write_all(uint32_t value){

		for(uint32_t i = 0; i < NUM_MODE; i++){
			Max10_write_leds(value,i);
		}
}

