/*
 * LUT_comms.h
 *
 *  Created on: Mar 7, 2025
 *      Author: gullino18
 */

#ifndef INC_LUT_COMMS_H_
#define INC_LUT_COMMS_H_
#include "stdint.h"
#include "stm32f1xx_hal.h"

#define LUT_SIZE 4096

void init_LUT_comms(SPI_HandleTypeDef *hspi);
uint16_t get_spi_data(void);
void set_spi_data(uint16_t value);
uint16_t get_offset(void);
void set_offset(uint16_t value);
#endif /* INC_LUT_COMMS_H_ */
