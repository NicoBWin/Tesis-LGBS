/*
 * BLDCcontrol.c
 *
 *  Created on: Apr 6, 2025
 *      Author: gullino18
 */
#include "math.h"
#include "stdlib.h"
#include "BLDCcontrol.h"
#include "LUT_comms.h"

uint32_t mot_speed_count = 0;
uint32_t last_mot_speed_count = 0;
uint32_t mot_speed_setpoint = 0;
void set_speed(float value)
{
	mot_speed_setpoint = 27.7778e3f/(value);
}

float get_speed(void)
{
	return 27.7778e3f/(float)mot_speed_setpoint;
}

float get_speed_meas(void)
{
	float res = 27.7778e3f/(float)(last_mot_speed_count);
	return res;
}
// Input compare
void HAL_TIM_IC_CaptureCallback(TIM_HandleTypeDef *htim)
{
	static int32_t p, i, aux_i, out_pi, err;
	static uint16_t state = 0;
	static GPIO_PinState hall_A, hall_B, hall_C;

	// Speed is in the order of 100k cnts per 1/18 revolution
	// current is in the order of 500 per amp
	/*
	 * In principle an error arround 1k cnts should increase the current by less than an amp to soften the current ramp.
	 * ESTO SALIO A OJO, NO HAY MATEMATICA
	 */
	HAL_GPIO_TogglePin(GPIOB, GPIO_PIN_1);
	mot_speed_count += htim->Instance->CCR1;

	hall_A = HAL_GPIO_ReadPin(HALL_PORT, HALL_A);
	hall_B = HAL_GPIO_ReadPin(HALL_PORT, HALL_B);
	hall_C = HAL_GPIO_ReadPin(HALL_PORT, HALL_C);

	state = (hall_A << 2) + (hall_B << 1) + hall_C;

	switch (state) {
		case 0b001:
			set_spi_data(LUT_SIZE/6*0-1);
			break;
		case 0b101:
			set_spi_data(LUT_SIZE/6*1-1);
			break;
		case 0b100:
			set_spi_data(LUT_SIZE/6*2-1);
			break;
		case 0b110:
			set_spi_data(LUT_SIZE/6*3-1);
			break;
		case 0b010:
			set_spi_data(LUT_SIZE/6*4-1);
			break;
		case 0b011:
			set_spi_data(LUT_SIZE/6*5-1);
			break;

		default:
			set_spi_data(LUT_SIZE/6*0-1);
			break;
	}
//	err = mot_speed_setpoint - mot_speed_count;
//
//	p = Kp * err;
//	aux_i = i + Ki * err ;
//	i = abs(aux_i) < SATURATION_INT ? aux_i : i;
//
//	out_pi = p + i;
//	set_I_int(out_pi);
	last_mot_speed_count = mot_speed_count;
	mot_speed_count = 0;
}

// Overflow
void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim)
{
	HAL_GPIO_TogglePin(GPIOB, GPIO_PIN_0);
}
