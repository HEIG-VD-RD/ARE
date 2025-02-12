/*****************************************************************************************
 * HEIG-VD
 * Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
 * School of Business and Engineering in Canton de Vaud
 *****************************************************************************************
 * REDS Institute
 * Reconfigurable Embedded Digital Systems
 *****************************************************************************************
 *
 * File                 : app_timer_irq.c
 * Author               : Anthony Convers
 * Date                 : 27.10.2022
 *
 * Context              : ARE lab
 *
 *****************************************************************************************
 * Brief: Using timer IRQ on DE1-SoC board
 *
 *****************************************************************************************
 * Modifications :
 * Ver    Date        Student      Comments
 * 0.0    27.10.2022  ACS           Initial version.
 *
 *****************************************************************************************/
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include "axi_lw.h"
#include "pio_function.h"
#include "timer_config.h"

int __auto_semihosting;

#define NUM_KEYS 4

// Struct to represent time
typedef struct {
	uint32_t seconds;
	uint32_t milliseconds;

 } my_time_t;

// Struct that represent a number
typedef struct{
	int centieme;
	int dizaine;
	int unite;
	int milli;
} number_t;

// Function prototypes
void set_A9_IRQ_stack(void);
void config_GIC(void);
void enable_A9_interrupts(void);
void init_chrono(my_time_t *chrono, uint32_t seconds);
void update_display(number_t chrono);
void get_number(number_t *num, my_time_t chrono);

// Variable to be called from timer handler so we can change the value of our chronoo
int signal_event_flag;


int main(void)
{

    printf("Laboratoire: Timer IRQ \n");
    // TO BE COMPLETE

    // Initialisation

    // Timer config
    init_timer();
    // IRQ stack config
    set_A9_IRQ_stack();
    // GIC config
    config_GIC();
    // Interrupts enable
    enable_A9_interrupts();



    // PIO init
    Leds_init();
    Segs7_init();
    Switchs_init();
    Keys_init();
    
    signal_event_flag = 0;
    my_time_t chrono;
    number_t numeral_time;
    init_chrono(&chrono, 0);

    volatile uint32_t *constante = (volatile uint32_t *)CONSTANTE_BASE;
    printf("Constante ID : 0x%x \n", *constante);
    for (int i = 0; i < 4; i++)
    {
        Seg7_write_hex(i, 0);
    }
    Leds_write(0x0);
    bool previousState[NUM_KEYS] = {false, false, false, false};
    while (1)
    {
    	uint32_t value_switches = Switchs_read();

        // Catch the event of the timer
    	if(signal_event_flag){
    		signal_event_flag = 0;
			Leds_toggle(0x200);

            // Decrement the chrono
			if (chrono.milliseconds == 0) {
			        if (chrono.seconds > 0) {
			            chrono.seconds--;
			            chrono.milliseconds = 9;
			        }
			    } else {
			        chrono.milliseconds -= 1;
			    }

            // If the chrono is at 0, stop the timer
			if((chrono.milliseconds == 0) && (chrono.seconds == 0)){
				pause_timer();
				Leds_clear(0x100);
			}

        	get_number(&numeral_time,chrono);
        	update_display(numeral_time);

    	}
        bool currentState[NUM_KEYS] = {false, false, false, false};

		for (int i = 0; i < NUM_KEYS; i++) {
			currentState[i] = Key_read(i);
		}

        // If key 0 is pressed, start the timer
        if (currentState[0] && !previousState[0])
        {
        	if((chrono.seconds  != 0) || (chrono.milliseconds != 0)){

        	resume_timer();
        	Leds_set(0x100);
        	}
        }

        // If key 1 is pressed, stop the timer
        if (currentState[1] && !previousState[1])
        {
        	pause_timer();
        	Leds_clear(0x100);
        }

        // If key 2 is pressed, set the timer
        if (currentState[2] && !previousState[2])
        {
        	Leds_write( value_switches & 0x0ff);
        	init_chrono(&chrono, value_switches& 0x0ff);
        	get_number(&numeral_time,chrono);
        	update_display(numeral_time);
            
        }

        // Change of state for the previous. For the rising edge verification
        for (int i = 0; i < NUM_KEYS; i++)
        {
            previousState[i] = currentState[i];
        }
    }

    return 0;
}

/**
 * @brief Initiate the chrono to a value in seconds
 * @param chrono Chrono
 * @param seconds Value to set up
 */
void init_chrono(my_time_t *chrono, uint32_t seconds) {
    chrono->seconds = seconds;
    chrono->milliseconds = 0;
}

/**
 * @brief Convert a chrono value to a number values
 * @param num Number to be filled
 * @param chrono Chrono to be converted
 */
void get_number(number_t *num, my_time_t chrono){

	num->centieme = (int)chrono.seconds / 100;
	num->dizaine = (int)(chrono.seconds / 10) % 10;
    num->unite = (int)chrono.seconds % 10;
	num->milli = (int)chrono.milliseconds;
}

/**
 * @brief Update the value of the  7segments displays
 * @param chrono Chrono to be displayed
 */
void update_display(number_t chrono) {
    Seg7_write_hex(0, chrono.milli );
    Seg7_write_hex(1, chrono.unite);
    Seg7_write_hex(2, chrono.dizaine);
    Seg7_write_hex(3, chrono.centieme);
}

/**
 * @brief Timer handler
 */
void hps_timer_ISR(void)
{
	//printf("hello\n");
	clear_interrupt();
	signal_event_flag = 1;
}
