/*
 * LUT_comms.c
 *
 *  Created on: Mar 7, 2025
 *      Author: gullino18
 */


#include "LUT_comms.h"

uint16_t offset = 50;
uint16_t spi_data = 0;


void init_LUT_comms(SPI_HandleTypeDef *hspi)
{
	HAL_SPI_Transmit_DMA(hspi, &spi_data, 40);
}

void set_spi_data(uint16_t value)
{
	spi_data = value;
}

uint16_t get_spi_data(void)
{
	return spi_data;
}

void set_offset(uint16_t value)
{
	offset = value;
}

uint16_t get_offset(void)
{
	return offset;
}


void HAL_SPI_TxCpltCallback(SPI_HandleTypeDef *hspi)
{

	if (spi_data + offset > LUT_SIZE-1) {
		spi_data = spi_data + offset - (LUT_SIZE - 1);
	}
	else {
		spi_data += offset;
	}
}



