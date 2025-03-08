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

#endif /* INC_LUT_COMMS_H_ */
