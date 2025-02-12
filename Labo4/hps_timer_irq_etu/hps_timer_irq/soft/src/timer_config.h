#include "address_map_arm.h"    
#include <stdint.h>

#define TIMER_REG(_x_)   *(volatile uint32_t *)(OSC1_TIMER0_BASE + _x_) // _x_ is an offset with respect to the base address

// Timer registers
#define T1_LOAD_COUNT_REG       TIMER_REG(T1_LOAD_COUNT_OFFSET)
#define T1_CURRENT_VALUE_REG    TIMER_REG(T1_CURRENT_VALUE_OFFSET)
#define T1_CONTROL_REG          TIMER_REG(T1_CONTROL_REG_OFFSET)
#define T1_EOI_REG              TIMER_REG(T1_EOI_OFFSET)
#define T1_INTERRUPT_STAT_REG   TIMER_REG(T1_INTERRUPT_STAT_OFFSET)
#define TS_INTERRUPT_STAT_REG   TIMER_REG(TS_INTERRUPT_STAT_OFFSET)
#define TS_EOI_REG              TIMER_REG(TS_EOI_OFFSET)
#define TS_RAW_INT_STAT_REG     TIMER_REG(TS_RAW_INT_STAT_OFFSET)
#define TS_COMP_VERSION_REG     TIMER_REG(TS_COMP_VERSION_OFFSET)


typedef enum
{
    FREE_RUNNING = 0,
    USER = 1
} timer_mode_t;

typedef enum
{
    NOT_MASK = 0,
    MASK = 1
} interr_t;

/**
 * @brief Initialize the timer
 */
void init_timer(void);

/**
 * @brief Enable the timer
 */
void enable_timer(void);

/**
 * @brief Disable the timer
 */
void disable_timer(void);

/**
 * @brief Resume the timer -> it will call enable timer
 */
void resume_timer(void);

/**
 * @brief Pause the timer -> it will call disable timer
 */
void pause_timer(void);

/**
 * @brief Set the mode of the timer
 * @param mode Mode to set
 * mode 0 = FREE_RUNNING 
 * mode 1 = USER
 */
void set_mode(timer_mode_t mode);

/**
 * @brief Set the interrupt mask
 * @param interr Interrupt to set
 * interr 0 = NOT_MASK
 * interr 1 = MASK
 */
void set_interrupt_mask(interr_t interr);

/**
 * @brief Load the timer with a value
 * @param value Value to load
 */
void timer_load(uint32_t value);

/**
 * @brief Clear the interrupt
 */
void clear_interrupt(void);


