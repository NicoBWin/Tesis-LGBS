/*
 * BLDCcontrol.c
 *
 *  Created on: Apr 6, 2025
 *      Author: gullino18
 */
#include "math.h"
#include "BLDCcontrol.h"
uint32_t mot_speed_count = 0;
uint32_t last_mot_speed_count = 0;
uint32_t mot_speed_setpoint = 0;
void set_speed(float value)
{
	mot_speed_setpoint = (value*18*18000)/60;
}

float get_speed(void)
{
	return mot_speed_setpoint*60.0f/18.0f/18000.0f;
}

float get_speed_meas(void)
{
	float res = (float)(last_mot_speed_count)/18000.0f;
	return res;
}
// Input compare
void HAL_TIMEx_CommutCallback(TIM_HandleTypeDef *htim)
{
	static int32_t p, i, aux_i, out_pi, err;

	// Speed is in the order of 100k cnts per 1/18 revolution
	// current is in the order of 500 per amp
	/*
	 * In principle an error arround 1k cnts should increase the current by less than an amp to soften the current ramp.
	 * ESTO SALIO A OJO, NO HAY MATEMATICA
	 */
	HAL_GPIO_TogglePin(GPIOB, GPIO_PIN_1);
	mot_speed_count += htim->Instance->CCR1;

	err = mot_speed_setpoint - mot_speed_count;

	p = Kp * err;
	aux_i = i + Ki * err ;
	i = abs(aux_i) < SATURATION_INT ? aux_i : i;

	out_pi = p + i;
	set_I_int(out_pi);
	last_mot_speed_count = mot_speed_count;
	mot_speed_count = 0;
}

// Overflow
void HAL_TIM_TriggerCallback(TIM_HandleTypeDef *htim)
{
	mot_speed_count += 65536;
}
