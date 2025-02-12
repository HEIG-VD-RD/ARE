/*****************************************************************************************
 * HEIG-VD
 * Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
 * School of Business and Engineering in Canton de Vaud
 *****************************************************************************************
 * REDS Institute
 * Reconfigurable Embedded Digital Systems
 *****************************************************************************************
 *
 * File                 : execptions.c
 * Author               : Anthony Convers
 * Date                 : 27.10.2022
 *
 * Context              : ARE lab
 *
 *****************************************************************************************
 * Brief: defines exception vectors for the A9 processor
 *        provides code that sets the IRQ mode stack, and that dis/enables interrupts
 *        provides code that initializes the generic interrupt controller
 *
 *****************************************************************************************
 * Modifications :
 * Ver    Date        Engineer      Comments
 * 0.0    27.10.2022  ACS           Initial version.
 *
*****************************************************************************************/
#include <stdint.h>

#include "address_map_arm.h"
#include "int_defines.h"
/* This file:
 * 1. defines exception vectors for the A9 processor
 * 2. provides code that sets the IRQ mode stack, and that dis/enables interrupts
 * 3. provides code that initializes the generic interrupt controller
*/


#define IICIAR 0xFFFEC10C
// Interrupt END of Interrupt Register (EOIR)
#define IICEOIR 0xFFFEC110
// Interrupt Priority Mask Register (PMR)
#define ICCPMR 0xFFFEC104
// Interrupt Control Register (ICCR)
#define ICCICR 0xFFFEC100
// Interrupt Distributor Control Register (ICDDCR)
#define ICDDCR 0xFFFED000

void fpga_ISR(void);
#define FPGA_IRQ0_ID 72 


// Define the IRQ exception handler
void __attribute__((interrupt)) __cs3_isr_irq(void)
{
	/***********
	 * TO DO
	 **********/

	// Read CPU Interface registers to determine which peripheral has caused an interrupt
	int interrupt_ID = *((int *)IICIAR);

	// Handle the interrupt if it comes from the timer
	if (interrupt_ID == FPGA_IRQ0_ID)
	{
		fpga_ISR();
	}
	else
	{
		while (1)
			;
	}

	// Clear interrupt from the CPU Interface
	*(int *)IICEOIR = interrupt_ID;
	return;
}

// Define the remaining exception handlers
void __attribute__ ((interrupt)) __cs3_reset (void)
{
    while(1);
}

void __attribute__ ((interrupt)) __cs3_isr_undef (void)
{
    while(1);
}

void __attribute__ ((interrupt)) __cs3_isr_swi (void)
{
    while(1);
}

void __attribute__ ((interrupt)) __cs3_isr_pabort (void)
{
    while(1);
}

void __attribute__ ((interrupt)) __cs3_isr_dabort (void)
{
    while(1);
}

void __attribute__ ((interrupt)) __cs3_isr_fiq (void)
{
    while(1);
}

/* 
 * Initialize the banked stack pointer register for IRQ mode
*/
void set_A9_IRQ_stack(void)
{
	uint32_t stack, mode;
	stack = A9_ONCHIP_END - 7;		// top of A9 onchip memory, aligned to 8 bytes
	/* change processor to IRQ mode with interrupts disabled */
	mode = INT_DISABLE | IRQ_MODE;
	asm("msr cpsr, %[ps]" : : [ps] "r" (mode));
	/* set banked stack pointer */
	asm("mov sp, %[ps]" : : [ps] "r" (stack));

	/* go back to SVC mode before executing subroutine return! */
	mode = INT_DISABLE | SVC_MODE;
	asm("msr cpsr, %[ps]" : : [ps] "r" (mode));
}

/* 
 * Turn on interrupts in the ARM processor
*/
void enable_A9_interrupts(void)
{
	uint32_t status = SVC_MODE | INT_ENABLE;
	asm("msr cpsr, %[ps]" : : [ps]"r"(status));
}

/*
 * Configure the Generic Interrupt Controller (GIC)
 */
void config_GIC(void)
{
	/***********
	 * TO DO
	 **********/

	config_interrupt(FPGA_IRQ0_ID,1);

	// We set the priority mask register to 0xFFFF. We can receive all interrupts
	(*(int *) ICCPMR ) = 0xFF;
	// CPU interface control register activation. With 1 we say we can receive interrupts
	(*(int *) ICCICR ) = 1;
	// Distributor control register activation. Without it we can't distribute interrupts even if they are activated
	(*(int *) ICDDCR ) = 1;


}

//QUESTION: Y A T IL BESOIN DE CETTE FONCTION (CONFIG INTERRUPT)?? ELLLE ETAIS PAS DE BASE... JE L AI JUSTE REPRIS DE L ANCIEN LABO
// ET EST CE QU ON DOIT AUSSI CONFIGURER LES INTERRUPTIONS POUR LE TIMER? COMME L ANCIEN LABO
// Fonction pour configurer une interruption dans le GIC
void config_interrupt(int N, int CPU_target)
{
    int reg_offset, index, value, address;

    // Configurer ICDISERn (Interrupt Set-Enable Registers)
    reg_offset = (N >> 5) * 4; // Registre correspondant (N / 32)
    index = N & 0x1F;          // Bit à activer dans le registre
    value = 0x1 << index;
    address = 0xFFFED100 + reg_offset;
    *(volatile int *)address |= value;

    // Configurer ICDIPTRn (Interrupt Processor Target Registers)
    reg_offset = (N & 0xFFFFFFFC); // Registre correspondant (N / 4)
    index = N & 0x3;              // Byte à configurer dans le registre
    address = 0xFFFED800 + reg_offset + index;
    *(volatile char *)address = (char)CPU_target;
}


