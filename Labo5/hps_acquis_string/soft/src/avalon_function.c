/*****************************************************************************************
 * HEIG-VD
 * Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
 * School of Business and Engineering in Canton de Vaud
 *****************************************************************************************
 * REDS Institute
 * Reconfigurable Embedded Digital Systems
 *****************************************************************************************
 *
 * File                 : avalon	_function.c
 * Author               :
 * Date                 :
 *
 * Context              : ARE lab
 *
 *****************************************************************************************
 * Brief: Pio function
 *
 *****************************************************************************************
 * Modifications :
 * Ver    Date        Student      Comments
 * 1.0 	18.10.2024 	 Rafael Dousse
 *
 *****************************************************************************************/
#include "avalon_function.h"



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
	return !my_key_value; // key pressed is 0. Bouton actif bas.
}

uint32_t Switches_read(void)
{
	volatile uint32_t *value_switchs = SWITCH_REG;
	return ((*value_switchs & SWITCHS_MASK));
}

uint32_t Status_read(void)
{
	volatile uint32_t *value_status = STATUS_REG;
	return *value_status & STATUS_MASK;
}

uint32_t Mode_gen_read(void)
{
	volatile uint32_t *value_mode_gen = MODE_DELAY_GEN_REG;
	return *value_mode_gen & MODE_GEN_MASK;
}

uint32_t Delay_gen_read(void)
{
	volatile uint32_t *value_mode_delay = MODE_DELAY_GEN_REG;
	return *value_mode_delay & MODE_DELAY_MASK;
}

uint32_t Checksum_read(void)
{
	volatile uint32_t *value_checksum = CHECKSUM_REG;
	return *value_checksum & CHECKSUM_MASK;
}

void Mode_gen_write(mode_gen_t value)
{

	volatile uint32_t *value_mode_gen = MODE_DELAY_GEN_REG;
    uint32_t current_state = *value_mode_gen;
    current_state &= ~MODE_GEN_MASK;
    current_state |= (value << 4);
    *value_mode_gen = current_state;
}

void Mode_delay_write(delay_freq_t value)
{
    volatile uint32_t *value_mode_delay = MODE_DELAY_GEN_REG;
    uint32_t current_state = *value_mode_delay;

    current_state &= ~MODE_DELAY_MASK;
    current_state |= value;
    *value_mode_delay = current_state;
}

void Initialize_char(void) {

    *STATUS_REG = INIT_CHAR_MASK;
}

void Generate_new_char(void) {
    *STATUS_REG = NEW_CHAR_MASK;
}

void Reset_command(void) {
    *STATUS_REG = 0x0;
}

void ack_write() {
    *ACK_REG = 1;
    *ACK_REG = 0;
}

// Dans avalon_function.c
char_data_t Read_string_and_verify(void) {
    char_data_t result;
    uint32_t status = Status_read();
    while (status != 3)
    {
        status = Status_read();
        //wait...
    }
    

    // Lire les registres
    uint32_t chars_1_4 = *CHAR_1_4_REG;
    uint32_t chars_5_8 = *CHAR_5_8_REG;
    uint32_t chars_9_12 = *CHAR_9_12_REG;
    uint32_t chars_13_16 = *CHAR_13_16_REG;

    // Aquitter la lecture des caractères
    ack_write();

    // Extraire les caractères individuels
    result.string[0] = (chars_1_4 >> 24) & 0xFF;
    result.string[1] = (chars_1_4 >> 16) & 0xFF;
    result.string[2] = (chars_1_4 >> 8) & 0xFF;
    result.string[3] = chars_1_4 & 0xFF;

    result.string[4] = (chars_5_8 >> 24) & 0xFF;
    result.string[5] = (chars_5_8 >> 16) & 0xFF;
    result.string[6] = (chars_5_8 >> 8) & 0xFF;
    result.string[7] = chars_5_8 & 0xFF;

    result.string[8] = (chars_9_12 >> 24) & 0xFF;
    result.string[9] = (chars_9_12 >> 16) & 0xFF;
    result.string[10] = (chars_9_12 >> 8) & 0xFF;
    result.string[11] = chars_9_12 & 0xFF;

    result.string[12] = (chars_13_16 >> 24) & 0xFF;
    result.string[13] = (chars_13_16 >> 16) & 0xFF;
    result.string[14] = (chars_13_16 >> 8) & 0xFF;
    result.string[15] = chars_13_16 & 0xFF;

    // Lire le checksum
    result.checksum = Checksum_read();

    // Lire le status
    result.status = Status_read();

    // Calculer l'intégrité
    uint16_t sum = 0;
    for(int i = 0; i < 16; i++) {
        sum += result.string[i];
    }
    sum += result.checksum;
    result.integrity = sum & 0xFF;
    result.string[16] = '\0';
    

    return result;
}
