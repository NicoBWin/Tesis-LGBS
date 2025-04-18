/*
 * potentiometer.h
 *
 *  Created on: Apr 17, 2025
 *      Author: Gonzalo
 */

#ifndef SRC_POTENTIOMETER_H_
#define SRC_POTENTIOMETER_H_

#include <stdint.h>
#include <stdbool.h>
#include "stm32f1xx_hal.h"

uint16_t read_pote(ADC_HandleTypeDef *hadc1);

#endif /* SRC_POTENTIOMETER_H_ */
