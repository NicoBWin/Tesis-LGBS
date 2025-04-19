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


#define SQUARE 0
#define SINE 1

extern TIM_HandleTypeDef htim4;
uint32_t mot_speed_count = 0;
uint32_t last_mot_speed_count = 0;
uint32_t mot_speed_setpoint = 0;
uint8_t overflow_detected = 1;
uint8_t output_mode = SINE; // 0: square, 1: Sinewave
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
	static uint16_t state = 0, freq;
	static GPIO_PinState hall_A, hall_B, hall_C;

	// Speed is in the order of 100k cnts per 1/18 revolution
	// current is in the order of 500 per amp
	/*
	 * In principle an error arround 1k cnts should increase the current by less than an amp to soften the current ramp.
	 * ESTO SALIO A OJO, NO HAY MATEMATICA
	 */
	HAL_GPIO_TogglePin(GPIOB, GPIO_PIN_1);
	mot_speed_count = htim->Instance->CCR1;
	if (mot_speed_count < 2000){
		mot_speed_count = last_mot_speed_count;
	}
	hall_A = HAL_GPIO_ReadPin(HALL_PORT, HALL_A);
	hall_B = HAL_GPIO_ReadPin(HALL_PORT, HALL_B);
	hall_C = HAL_GPIO_ReadPin(HALL_PORT, HALL_C);

	state = (hall_A << 2) + (hall_B << 1) + hall_C;

	htim4.Instance->CNT = 0;
	// HAL_TIM_Base_Start(&htim4);
//	if (overflow_detected){
//		output_mode = SQUARE;
//		overflow_detected = 0;
//	}
//	else {
//		output_mode = SINE;
//	}

	switch (state) {
			case 0b001:
				set_spi_data(3072);
				break;
			case 0b101:
				set_spi_data(3755);
				break;
			case 0b100:
				set_spi_data(341);
				break;
			case 0b110:
				set_spi_data(1024);
				break;
			case 0b010:
				set_spi_data(1707);
				break;
			case 0b011:
				set_spi_data(2391);
				break;

			default:
				set_spi_data(3072);
				break;
		}
	if (output_mode == SINE){
		freq = 1000000/mot_speed_count;
		set_offset(freq/2);
	}
	else {
		set_offset(0);
		overflow_detected = 0;
	}
	last_mot_speed_count = mot_speed_count;
	mot_speed_count = 0;
}

// Overflow
void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim)
{
	HAL_TIM_Base_Stop(htim);
	overflow_detected = 1;
	HAL_GPIO_TogglePin(GPIOB, GPIO_PIN_0);
}
