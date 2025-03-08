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
static float i_ref_float = 0.0;
static int16_t i_ref_int = 0;
static int16_t i_offset = 0;
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

float get_I()
{
	return i_ref_float;
}

void set_I(float i)
{
	if (i > MAX_CURR || i < 0.0)
	{
		return;
	}
	i_ref_float = i;
	i_ref_int = i * SENS_SENSITIVITY + i_offset;
}


void HAL_ADC_ConvCpltCallback(ADC_HandleTypeDef* hadc)
{
	adc_value = HAL_ADC_GetValue(hadc);
	if (!calibrated)
	{
		i_offset = adc_value;
		calibrated = true;
	}
	else
	{
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
