#ifndef __MAIN_H
#define __MAIN_H

#ifdef __cplusplus
extern "C"
{
#endif

#include "stm32f1xx_hal.h"

    /* Aquí puedes agregar defines para tus pines, por ejemplo:
    #define LED_PIN         GPIO_PIN_13
    #define LED_GPIO_PORT   GPIOC
    */

    /* Prototipos de funciones -----------------------------------------------*/
    void SystemClock_Config(void);
    void MX_GPIO_Init(void);
    void MX_DMA_Init(void);
    void MX_SPI1_Init(void);
    void Error_Handler(void);

#ifdef __cplusplus
}
#endif

#endif /* __MAIN_H */
