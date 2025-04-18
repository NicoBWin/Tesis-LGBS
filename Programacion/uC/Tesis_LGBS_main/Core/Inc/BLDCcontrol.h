
/*size_t
 * BLDCcontrol.h
 *
 *  Created on: Feb 28, 2025
 *      Author: gullino18
 */

#ifndef BLDCCONTORL_H_
#define BLDCCONTORL_H_
#include "stdint.h"
#include "CurrentControl.h"

#define Kp 0.3
#define Ki 0.001
#define SATURATION_INT (MAX_CURR*SENS_SENSITIVITY)

#define HALL_PORT GPIOA
#define HALL_A GPIO_PIN_8
#define HALL_B GPIO_PIN_9
#define HALL_C GPIO_PIN_10

float get_speed_meas(void);
float get_speed(void);
void set_speed(float value);
#endif /* INC_BLDCCONTROL_H_ */
