
/*size_t
 * BLDCcontrol.h
 *
 *  Created on: Feb 28, 2025
 *      Author: gullino18
 */

#ifndef INC_COMMAND_CONTROL_H_
#define INC_COMMAND_CONTROL_H_
#include "stdint.h"
#include "CurrentControl.h"

#define Kp 0.3
#define Ki 0.001
#define SATURATION_INT (MAX_CURR*SENS_SENSITIVITY)

float get_speed(void);
void set_speed(float value);
#endif /* INC_BLDCCONTROL_H_ */
