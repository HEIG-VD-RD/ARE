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
 * Brief: Conception d'une interface évoluée sur le bus Avalon avec la carte DE1-SoC
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

#include "avalon_function.h"
#include "axi_lw.h"

int __auto_semihosting;

#define NUM_KEYS 4

#define SWITCH_9_8 0x300
#define SWITCH_7 0x80
#define SWITCH_0 0x1

int main(void)
{
    printf("Laboratoire: Conception d'une interface évoluée  \n");
    // TO BE COMPLETE

    volatile uint32_t *constante = (volatile uint32_t *)CONSTANTE_BASE;
    volatile uint32_t *ID = ID_REG;
    uint32_t nbr_error = 0;
    Leds_write(0x0);
    printf("Constante : 0x%x \n", *constante);
    printf("ID : 0x%x \n", *ID);
    

    bool previousState[NUM_KEYS] = {false, false, false, false};
    bool currentState[NUM_KEYS] = {false, false, false, false};

    while (1)
    {
        // Lecture des switchs
        uint32_t switches = Switches_read();
        // Etat des switch 9-8 sélectionne le délay (hz)
        uint32_t sw_delay = (switches & SWITCH_9_8) >> 8;
        // Etat switch 7 indique le mode (manuel ou automatique)
        uint32_t sw_mode = (switches & SWITCH_7) >> 7;
        // Etat switch 0 selectionne la fiabilité de la communication
        uint32_t reliability = switches & SWITCH_0;


        delay_freq_t delay;

        mode_gen_t mode = (sw_mode == 1) ? AUTOMATIC : MANUAL;

        switch (sw_delay)
        {
        case 0x0:
            delay = UN_HZ;
            break;
        case 0x1:
            delay = UN_KHZ;
            break;
        case 0x2:
            delay = CENT_KHZ;
            break;
        case 0x3:
            delay = UN_MHZ;
            break;
        default:
            printf("Error: Invalid delay value\n");
            delay = UN_HZ;
        }

        Leds_write(switches);
        Mode_delay_write(delay);
        Mode_gen_write(mode);
        char_data_t data = Read_string_and_verify();

        

        for (int i = 0; i < NUM_KEYS; i++)
        {
            previousState[i] = currentState[i];
            currentState[i] = Key_read(i);
        }

        // If key 0 is pressed, initialisation des 16 caractere et le checksum
        if (!previousState[0] && currentState[0])
        {
            Initialize_char();
            Reset_command();
            nbr_error = 0;
        }

        // If key 1 is pressed, generation de nouvelle chaine de caractere
        // et son checksum quand mode manuel sélectionné
        if ((!previousState[1] && currentState[1]) && (mode == MANUAL))
        {
            Generate_new_char();
            Reset_command();
        }

        // If key 2 is pressed, lecture successive des 16 caractère
        // et checksum tant que le bouton n'est pas relâché donc faut
        // supprimer le edge detection.
        // Si chaine coherante, intégrité correcte il faut afficher le status okay
        // Sinon il faut calculer le nombre d'erreur cumulé et afficher un message spécial
        if (currentState[2])
        {
            char_data_t data = Read_string_and_verify();

            if (data.integrity == 0)
            {
                printf("OK : status: %d , checksum: %d, calcul integrity: %d, string: %s\n", data.status, data.checksum, data.integrity, data.string);
            }
            else
            {
                nbr_error++;
                printf("ER : status: %d , checksum: %d, calcul integrity: %d, string: %s\n \
                        ER : nombre d’erreur cumulée : %d\n", data.status, data.checksum, data.integrity, data.string, nbr_error);
            }
        }

    }

    return 0;
}
