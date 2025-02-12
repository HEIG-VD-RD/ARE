/*****************************************************************************************
 * HEIG-VD
 * Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
 * School of Business and Engineering in Canton de Vaud
 *****************************************************************************************
 * REDS Institute
 * Reconfigurable Embedded Digital Systems
 *****************************************************************************************
 *
 * File                 : address_map_arm.h
 * Author               : Anthony Convers
 * Date                 : 27.10.2022
 *
 * Context              : ARE lab
 *
 *****************************************************************************************
 * Brief: provides address values that exist in the ARM system
 *
 *****************************************************************************************
 * Modifications :
 * Ver    Date        Engineer      Comments
 * 0.0    27.10.2022  ACS           Initial version.
 *
*****************************************************************************************/

#define BOARD                 			"DE1-SoC"

/* Memory */
#define DDR_BASE              			0x00000000
#define DDR_END               			0x3FFFFFFF
#define A9_ONCHIP_BASE        			0xFFFF0000
#define A9_ONCHIP_END         			0xFFFFFFFF
#define SDRAM_BASE            			0xC0000000
#define SDRAM_END             			0xC3FFFFFF
#define FPGA_ONCHIP_BASE      			0xC8000000
#define FPGA_ONCHIP_END       			0xC803FFFF
#define FPGA_CHAR_BASE        			0xC9000000
#define FPGA_CHAR_END         			0xC9001FFF
