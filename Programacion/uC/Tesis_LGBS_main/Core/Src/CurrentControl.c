/*
 * CurrentControl.c
 *
 *  Created on: Feb 23, 2025
 *      Author: gullino18
 */
#include "CurrentControl.h"
#include "stm32f1xx_hal.h"
#include "stdbool.h"


static int16_t adc_value;
static int16_t i_ref_int = 0;
static int16_t i_offset = 0;
static int16_t max_curr = 0;
static bool calibrated = false;


void curr_control_init(ADC_HandleTypeDef *hadc, TIM_HandleTypeDef *htim)
{

	HAL_GPIO_WritePin(H_BRIDGE_GPIO_PORT, H_BRIDGE_1_A, GPIO_PIN_RESET);
	HAL_GPIO_WritePin(H_BRIDGE_GPIO_PORT, H_BRIDGE_2_A, GPIO_PIN_RESET);
	HAL_GPIO_WritePin(H_BRIDGE_GPIO_PORT, H_BRIDGE_1_B, GPIO_PIN_RESET);
	HAL_GPIO_WritePin(H_BRIDGE_GPIO_PORT, H_BRIDGE_2_B, GPIO_PIN_SET);

	if (HAL_ADCEx_Calibration_Start(hadc) != HAL_OK)
	{
		Error_Handler();
	}

	if (HAL_ADC_Start_IT(hadc) != HAL_OK)
	{
		Error_Handler();
	}

	if (HAL_TIMEx_PWMN_Start(htim, TIM_CHANNEL_1) != HAL_OK)
	{
		Error_Handler();
	}


}

float get_I_meas()
{
	return (float)(adc_value-i_offset)/(float)SENS_SENSITIVITY;
}

float get_I_float()
{
	return (float)(i_ref_int-i_offset)/(float)SENS_SENSITIVITY;
}
uint16_t get_I_int()
{
	return i_ref_int - i_offset;
}
void set_I_float(float i)
{
	if (i > MAX_CURR || i < 0.0)
	{
		i = MAX_CURR;
	}
	i_ref_int = i * SENS_SENSITIVITY + i_offset;
}

void set_I_int(uint16_t i)
{
	i_ref_int = i > SENS_SENSITIVITY * MAX_CURR ? max_curr : i + i_offset;
}
void HAL_ADC_ConvCpltCallback(ADC_HandleTypeDef* hadc)
{
	adc_value = HAL_ADC_GetValue(hadc);
	if (!calibrated)
	{
		i_offset = adc_value;
		max_curr = MAX_CURR * SENS_SENSITIVITY + i_offset;
		calibrated = true;
	}
	else
	{
		if (i_ref_int == i_offset)
		{
			HAL_GPIO_WritePin(H_BRIDGE_GPIO_PORT, H_BRIDGE_1_A, GPIO_PIN_RESET);
			HAL_GPIO_WritePin(H_BRIDGE_GPIO_PORT, H_BRIDGE_2_A, GPIO_PIN_SET);
			return;
		}
		if (adc_value > i_ref_int)
		{
			HAL_GPIO_WritePin(H_BRIDGE_GPIO_PORT, H_BRIDGE_1_A, GPIO_PIN_RESET);
			HAL_GPIO_WritePin(H_BRIDGE_GPIO_PORT, H_BRIDGE_2_A, GPIO_PIN_SET);
		}
		else
		{
			HAL_GPIO_WritePin(H_BRIDGE_GPIO_PORT, H_BRIDGE_2_A, GPIO_PIN_RESET);
			HAL_GPIO_WritePin(H_BRIDGE_GPIO_PORT, H_BRIDGE_1_A, GPIO_PIN_SET);
		}
	}
}
