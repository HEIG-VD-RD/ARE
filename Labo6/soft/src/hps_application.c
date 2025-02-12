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
 * Brief: Mesure du temps de reaction avec la carte DE1-SoC et MAX10
 *
 *****************************************************************************************
 * Modifications :
 * Ver    Date        Student      Comments
 *
 *
 *****************************************************************************************/
#include <stdint.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include "axi_lw.h"
#include "utils.h"

int __auto_semihosting;

#define VALUE_OFF 0x00000000
#define SWITCH_3_0 0x0000000F
#define KEY_1 0x00000002
#define KEY_0 0x00000001

// Min function
#define min(a, b) ((a) < (b) ? (a) : (b))
// Max function
#define max(a, b) ((a) > (b) ? (a) : (b))


game_state_t game_state = GAME_IDLE;

bool pushed = false;
bool early_reaction = false;

// both true since key is active low
bool key_prev_state = true;
bool key_curr_state = true;

double reaction_start_time = 0;
double reaction_time = 0;
int random_wait_time = 0;

// Call to configuration functions for the interrupts
void set_A9_IRQ_stack(void);
void config_GIC(void);
void enable_A9_interrupts(void);

int main(void)
{

    printf("Laboratoire: Mesure du temps de reaction \n");

    // TO BE COMPLETE

    // Initialisation

    // Leds off
    Leds_write(VALUE_OFF);
    // 7 segments off
    for (int i = 0; i < 4; i++)
    {
        Seg7_write_hex(i, 0);
    }
    // UART config
    uart_init();
    //  IRQ stack config
    set_A9_IRQ_stack();
    // GIC config
    config_GIC();
    // Interrupts enable
    enable_A9_interrupts();
    // Activer les interruptions Avalon
    Interrupt_mask_set(true);

    // Constant reading
    volatile uint32_t *constante = (volatile uint32_t *)CONSTANTE_BASE;
    printf("Constante à l'adresse 0xFF200000 de l'AXI: 0x%X\n", *constante);
    constante = (volatile uint32_t *)INTERFACE_REG(ID_OFFSET);
    printf("Interface user ID à l'adresse 0xFF210000 de notre interface: 0x%X\n", *constante);
    printf("Les règles du jeu vont être affiché sur la console série avec une connection UART.\n");
    printf("Pour y accèder, connecter le cable, ouvrer une console et entrez dans la console:\n");
    printf("sudo picocom -b 9600 /dev/ttyUSB0 \n");

    // Max10 config, turn off all leds
    for (int i = 0; i <= 10; i++)
    {
        Max10_set_leds(i, 0x0);

        // Small delay to avoid saturating the serial terminal
        for (volatile int delay = 0; delay < 1000000; delay++)
            ;
    }

    data_time times_game;
    times_game.best_time = 0;
    times_game.worst_time = 0;
    times_game.last_time = 0;
    times_game.total_errors = 0;
    times_game.total_attempts = 0;

    afficher_regles_du_jeu_uart();

    srand(time(NULL));

    while (1)
    {
        uint32_t switch_value = Switchs_read();
        uint32_t state_sw30 = switch_value & SWITCH_3_0;

        number_t value_to_display;

        // Display best time
        if (switch_value & 0x1)
        {
            get_number(&value_to_display, times_game.best_time);
            Update_display(value_to_display);
        }
        // Display worst time
        else if (switch_value & 0x2)
        {
            get_number(&value_to_display, times_game.worst_time);
            Update_display(value_to_display);
        }
        // Display total errors
        else if (switch_value & 0x4)
        {
            get_number(&value_to_display, times_game.total_errors);
            Update_display(value_to_display);
        }

        // Display total attempts
        else if (switch_value & 0x8)
        {
            get_number(&value_to_display, times_game.total_attempts);
            Update_display(value_to_display);
        }
        // Display last time
        else
        {
            get_number(&value_to_display, times_game.last_time);
            Update_display(value_to_display);
        }

        // Read the key state with a rising edge
        key_prev_state = key_curr_state;
        key_curr_state = Key_read(1);

        switch (game_state)
        {
        case GAME_IDLE:

            // In case we pushed the button when the game isn't active
            pushed = false;
            early_reaction = false;
            if (key_curr_state && !key_prev_state)
            {

                random_wait_time = (rand() % 4) + 1;
                Counter_reset();
                Counter_start();
                Max10_show_figure(WAITING);
                game_state = GAME_WAITING;
                uart_send_string("\r\nDébut du jeu! Attendez le carré pour appuyer sur KEY0.", true);
            }

            break;
        case GAME_WAITING:
            // Wait for the random time to be elapsed
            if (Counter_get_value() >= random_wait_time * 1000)
            {                                              
                Max10_show_figure(START);                 
                reaction_start_time = Counter_get_value(); 

                game_state = GAME_REACTING;
                
                break;
            }
            else if (pushed)
            {
                early_reaction = true;
                game_state = GAME_REACTING;
            }
            break;
        case GAME_REACTING:

            if (pushed)
            {
                reaction_time = Counter_get_value() - reaction_start_time;

                if (early_reaction)
                {
                    times_game.total_errors++;
                    Max10_show_figure(OFF);
                    game_state = GAME_IDLE;
                    afficher_resultats_uart(times_game, reaction_time, true);
                    early_reaction = false;
                }
                else
                {

                    times_game.last_time = reaction_time;
                    times_game.best_time = times_game.best_time == 0 ? reaction_time : min(times_game.best_time, reaction_time);
                    times_game.worst_time = max(times_game.worst_time, reaction_time);
                    times_game.total_attempts++;
                    Max10_show_figure(END);
                    afficher_resultats_uart(times_game, reaction_time, false);
                    game_state = GAME_FINISHED;
                }

                pushed = false;
            }

            break;
        case GAME_FINISHED:
            game_state = GAME_IDLE;
            break;
        default:
            break;
        }
    }

    return 0;
}


void fpga_ISR(void)
{
    // Read registers to determine which peripheral has caused an interrupt
    uint32_t irq_status = Interrupt_status_read();
    uint32_t leds = Leds_read(LED9); 

    if (irq_status & 0x1)
    {
        Interrupt_ack();
        pushed = true;
        Leds_write(leds ^ LED9);
        Counter_stop();
    }
}
