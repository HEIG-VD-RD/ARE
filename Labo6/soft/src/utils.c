/*****************************************************************************************
 * HEIG-VD
 * Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
 * School of Business and Engineering in Canton de Vaud
 *****************************************************************************************
 * REDS Institute
 * Reconfigurable Embedded Digital Systems
 *****************************************************************************************
 *
 * File                 : utils.c
 * Author               : Rafael Dousse & Romain Humair
 * Date                 : 18.12.2025
 *
 * Context              : ARE lab
 *
 *****************************************************************************************
 * Brief: Utils functions
 *
 *****************************************************************************************
 * Modifications :
 * Ver    Date        Student      Comments
 * 0.0    18.12.2025  RAD & RHR     Initial version.
 *
 *****************************************************************************************/
#include "utils.h"

uint32_t hexValue[] = {
    0x3f, // 0
    0x06, // 1
    0x5b, // 2
    0x4f, // 3
    0x66, // 4
    0x6d, // 5
    0x7d, // 6
    0x07, // 7
    0x7f, // 8
    0x6f, // 9
    0x77, // A
    0x7c, // b
    0x39, // C
    0x5e, // d
    0x79, // E
    0x71  // F
};

uint32_t Switchs_read(void)
{
    volatile uint32_t *value_switchs = INTERFACE_REG(SWITCH_OFFSET);
    return ((*value_switchs & SWITCHS_BITS));
}

void Leds_write(uint32_t value)
{
    if (value > 0x3FF)
    {
        printf("Error: value is too big\n");
        return;
    }
    volatile uint32_t *value_leds = INTERFACE_REG(LED_OFFSET);
    *value_leds = value; 
}

void Leds_set(uint32_t maskleds)
{
    if (maskleds > 0x3ff)
    {
        printf("Error: maskleds is too big\n");
        return;
    }
    volatile uint32_t *value_leds = INTERFACE_REG(LED_OFFSET);
    *value_leds |= maskleds; 
}

uint32_t Leds_read(uint32_t led)
{
    volatile uint32_t *value_leds = INTERFACE_REG(LED_OFFSET);
    return (*value_leds & led);
}

bool Key_read(int key_number)
{
    volatile uint32_t *dataValue = INTERFACE_REG(BOUTON_OFFSET);
    uint32_t my_key_value = (*dataValue >> key_number) & 0x1;
    return my_key_value;
}

void Seg7_write(int seg7_number, uint32_t value)
{

    uint32_t maskSeg;
    volatile uint32_t *dataRegister = INTERFACE_REG(HEX_OFFSET);
    switch (seg7_number)
    {
    case 0:
        maskSeg = HEX_0;
        break;
    case 1:
        maskSeg = HEX_1;
        value = value << 7;
        break;
    case 2:
        maskSeg = HEX_2;
        value = value << 14;
        break;
    case 3:
        maskSeg = HEX_3;
        value = value << 21;
        break;
    default:
        printf("Wrong number. It should be between [0:3] and not %d\n", seg7_number);
        return;
    }

    // Operation to write one hex segment and not erase the others
    *dataRegister &= ~maskSeg;
    *dataRegister |= (~value & maskSeg);
}

void Seg7_write_hex(int seg7_number, uint32_t value)
{

    if (value > HEX_MAX)
    {
        printf("Value not accepted. It shoud be bewteen [0x0:0xf] and not %lu\n", value);
        return;
    }
    // Use of the precedent function and the array to write an hexa value
    Seg7_write(seg7_number, hexValue[value]);
}

void Update_display(number_t chrono)
{
    if (chrono.unite > 9)
    {
        printf("Erreur unite: valeur trop grande %d\n", chrono.unite);
        chrono.unite = 9;
    }
    if (chrono.dizaine > 9)
    {
        printf("Erreur dizaine: valeur trop grande %d\n", chrono.dizaine);
        chrono.dizaine = 9;
    }
    if (chrono.centieme > 9)
    {
        printf("Erreur centieme: valeur trop grande %d\n", chrono.centieme);
        chrono.centieme = 9;
    }
    if (chrono.millier > 9)
    {
        printf("Erreur milli: valeur trop grande %d\n", chrono.millier);
        chrono.millier = 9;
    }

    // Build the complete value to display
    uint32_t complete_value = (hexValue[chrono.millier] << 21) |  // Hex3
                              (hexValue[chrono.centieme] << 14) | // Hex2
                              (hexValue[chrono.dizaine] << 7) |   // Hex1
                              (hexValue[chrono.unite]);           // Hex0

    volatile uint32_t *dataRegister = INTERFACE_REG(HEX_OFFSET);

    // Negate the value to display since the leds are active low
    *dataRegister = ~complete_value;
}

// Serial and interrupt functions

uint32_t Serial_status_read(void)
{
    volatile uint32_t *serial_status = INTERFACE_REG(SERIAL_STAT_R);
    return (*serial_status & 0x07); // Bits [2:0] seulement
}

void Serial_data_write(uint32_t data)
{
    volatile uint32_t *serial_data = INTERFACE_REG(SERIAL_DATA_R_W);
    *serial_data = data & 0xFFFFF; 
}

uint32_t Serial_data_read(void)
{
    volatile uint32_t *serial_data = INTERFACE_REG(SERIAL_DATA_R_W);
    return (*serial_data & 0xFFFFF); 
}

void Serial_start(bool start)
{
    volatile uint32_t *serial_start = INTERFACE_REG(SERIAL_START_W);
    *serial_start = start ? 0x1 : 0x0;
}

uint32_t Interrupt_status_read(void)
{
    volatile uint32_t *interrupt_status = INTERFACE_REG(INTERRUPT_STATUS_R);
    return (*interrupt_status & 0x03); 
}

void Interrupt_ack(void)
{
    volatile uint32_t *interrupt_ack = INTERFACE_REG(INTERRUPT_ACK_W);
    *interrupt_ack = 0x1; 
}

void Interrupt_mask_set(bool enable)
{
    volatile uint32_t *interrupt_mask = INTERFACE_REG(INTERRUPT_MASK_W);
    *interrupt_mask = enable ? 0x1 : 0x0;
}

// Counter functions

double Counter_get_value(void)
{
    volatile uint32_t *counter_value = INTERFACE_REG(COUNTER_VALUE_R);
    double value = (double)(*counter_value);

    // Return the value in ms
    return ((value * 20.0) / 1000000.0);
}

void Counter_action(bool enable, bool reset)
{
    volatile uint32_t *counter_action = INTERFACE_REG(COUNTER_ACTION_W);
    uint32_t value = (reset << 1) | (enable << 0); // Combinaison des bits
    *counter_action = value;
}

void Counter_start(void)
{
    Counter_action(0x1, 0x0); 
}

void Counter_stop(void)
{
    Counter_action(0x0, 0x0); 
}

void Counter_reset(void)
{
    Counter_action(0x0, 0x1);
}

// UART functions
void uart_init()
{
    volatile uint32_t *uart0_lcr = UART_REG(UART0_LCR);
    volatile uint32_t *uart0_dll = UART_REG(UART0_DLL);
    volatile uint32_t *uart0_dlh = UART_REG(UART0_DLH);
    volatile uint32_t *uart0_fcr = UART_REG(UART0_FCR);

    // Configuration: Bits [1:0] = 11 => for 8 data bits, 1 stop bit, no parity
    *uart0_lcr = 0x03;

    // Configuration for baudrate to 9600
    // Calcul: Baudrate = Fréquence Clock Série(l4_sp_clk = 100MHz) / 16 * Divisor
    // So: Divisor = Fréquence Clock Série / (16 * Baudrate)
    // Divisor = 100MHz / (16 * 9600) = 651.0416666666667 = 0x28B
    *uart0_lcr |= 0x80;  // Activate DLAB (bit 7 = 1) to access DLL and DLH
    *uart0_dll = 0x8B;   // DLL = 11 (0x0B)
    *uart0_dlh = 0x02;   // DLH = 2 (0x02)
    *uart0_lcr &= ~0x80; // Désactiver le DLAB (bit 7 = 0)

    // Activer les FIFO en émission et réception
    *uart0_fcr = 0x01; // Bit 0 = 1 (FIFO Enable)
}

void uart_send_string(const char *str, bool add_newline)
{

    volatile uint32_t *uart0_thr = UART_REG(UART0_THR);
    volatile uint32_t *uart0_lsr = UART_REG(UART0_LSR);

    while (*str)
    {
        // Wait for the THR to be empty
        while (!(*uart0_lsr & LSR_THRE))
        {
            
        }
        // Write the character to the UART in the THR register
        *uart0_thr = *str;
        str++;
    }

    // Add a newline if requested
    if (add_newline)
    {
        while (!(*uart0_lsr & LSR_THRE))
        {
        }
        *uart0_thr = '\r';
        while (!(*uart0_lsr & LSR_THRE))
        {
        }
        *uart0_thr = '\n';
    }
}

void uart_send_number(uint32_t number, const char *suffix)
{
    char buffer[12];

    // Formate the number to a string                                
    snprintf(buffer, sizeof(buffer), "%u", number);
    uart_send_string(buffer, false);                

    if (suffix)
    {
        uart_send_string(suffix, false);
    }

    uart_send_string(" ", true);
}

void afficher_regles_du_jeu_uart()
{
    uart_send_string("*Règles du jeu :*", true);
    uart_send_string("1. Une séquence de mesure de temps de réaction va commencer des que vous appuyer key1.", true);
    uart_send_string("2. Le symbole de la croix va s'afficher sur les LEDs de la Max10. Il faut donc attendre.", true);
    uart_send_string("3. Il faut appuyer sur KEY0 dès que le symbole carré exterieur apparaît.", true);
    uart_send_string("4. Votre temps de réaction sera mesuré et affiché dans ce terminal.", true);
    uart_send_string("Si vous appuyer trop tôt, alors les leds vont s'éteindre et ce tour sera compté comme une erreur.", true);
    uart_send_string("Appuyer sur key1 pour commencer!", true);
}

void afficher_resultats_uart(data_time datas, uint32_t reaction_time, bool early_press)
{

    if (early_press)
    {
        uart_send_string("\r\n*Mesure interrompue!*", true);
        uart_send_string("- Nombre total d'erreurs : ", false);
        uart_send_number(datas.total_errors, NULL);
        uart_send_string("- Nombre total de tentatives : ", false);
        uart_send_number(datas.total_attempts, NULL);

        return;
    }

    uart_send_string("\r\n*Résultats*", true);

    uart_send_string("Temps de réaction: ", false);
    uart_send_number(reaction_time, " ms");

    uart_send_string("Meilleur temps: ", false);
    uart_send_number(datas.best_time, " ms");

    uart_send_string("Pire temps: ", false);
    uart_send_number(datas.worst_time, " ms");

    uart_send_string("Nombre total d'erreurs: ", false);
    uart_send_number(datas.total_errors, NULL);

    uart_send_string("Nombre total de tentatives: ", false);
    uart_send_number(datas.total_attempts, NULL);
}


// MAX10 functions

bool Max10_set_leds(uint32_t zone_code, uint16_t led_data)
{
    // Check if the Max10 is connected
    uint32_t status = Serial_status_read();
    if ((status & 0x03) != 0x01)
    {
        printf("Erreur : Max10 non valide ou non connecté (statut : 0x%x)\n", status);
        return false;
    }

    // Build the data to send
    uint32_t data_to_send = ((zone_code & 0xF) << 16) | (led_data & 0xFFFF);

    // Write the data
    Serial_data_write(data_to_send);

    // Start the transmission
    Serial_start(true);

    // Wait for the transmission to finish
    while (Serial_status_read() & (1 << 2))
    {

    }

    return true;
}

void Max10_show_figure(state_t figure)
{

    switch (figure)
    {
    case WAITING:
        Max10_set_leds(ZONE_L, VAL_WAITING & FIGURE_MASK);
        Max10_set_leds(ZONE_H, (VAL_WAITING >> 16) & FIGURE_MASK);
        break;
    case START:
        Max10_set_leds(ZONE_L, VAL_START & FIGURE_MASK);
        Max10_set_leds(ZONE_H, (VAL_START >> 16) & FIGURE_MASK);
        break;
    case END:
        Max10_set_leds(ZONE_L, VAL_END & FIGURE_MASK);
        Max10_set_leds(ZONE_H, (VAL_END >> 16) & FIGURE_MASK);
        break;
    case OFF:
        Max10_set_leds(ZONE_H, 0x0);
        Max10_set_leds(ZONE_L, 0x0);
    default:

        break;
    }
}

/**
 * @brief Convert a chrono value to a number values
 * @param num Number to be filled
 * @param chrono Chrono to be converted
 */
void get_number(number_t *num, uint32_t value)
{

    num->millier = value / 1000;
    num->centieme = (value / 100) % 10;
    num->dizaine = (value / 10) % 10;
    num->unite = value % 10;

    if (num->millier >= 10)
    {
        num->millier = 9;
        num->centieme = 9;
        num->dizaine = 9;
        num->unite = 9;
        return;
    }
}
