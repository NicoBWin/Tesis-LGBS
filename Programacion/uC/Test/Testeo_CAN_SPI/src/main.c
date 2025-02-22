#include "main.h"
#include "usb_device.h"
/* Variables globales ---------------------------------------------------------*/
SPI_HandleTypeDef hspi1;
DMA_HandleTypeDef hdma_spi1_tx;

#define LUT_SIZE 4
uint16_t LUT[LUT_SIZE] = {0x1234, 0xABCD, 0xFFFF, 0x0000};
uint8_t TxBuffer[] = "Hello World! From STM32 USB CDC Device To Virtual COM Port\r\n";
uint8_t TxBufferLen = sizeof(TxBuffer);
int main(void)
{
    /* Inicialización del HAL, Reloj del sistema y GPIO */
    HAL_Init();
    SystemClock_Config();
    MX_GPIO_Init();
    // MX_DMA_Init();
    HAL_StatusTypeDef status = 0;
    /* Habilitar el remapeo de SPI1 */
    __HAL_AFIO_REMAP_SPI1_ENABLE();

    MX_SPI1_Init();
    MX_USB_DEVICE_Init();

    /* Iniciar la transmisión por DMA en modo esclavo */
    // Queremos que el SPI esté listo para enviar datos. En modo esclavo, la transferencia comienza
    // cuando el maestro baja NSS y genera el reloj.
    // HAL_SPI_Transmit_DMA() cargará el dato inicial al shift register cuando el maestro genere el reloj.
    // HAL_SPI_Transmit_DMA(&hspi1, (uint8_t *)LUT, LUT_SIZE);

    while (1)
    {
        // El SPI en modo esclavo enviará datos según el reloj del maestro.
        // El DMA en modo circular se encargará de rotar por la LUT.
        if (HAL_GPIO_ReadPin(GPIOA, GPIO_PIN_15) == GPIO_PIN_RESET)
        {
            status = HAL_SPI_Transmit(&hspi1, LUT, 1, 1000);
            CDC_Transmit_FS(TxBuffer, TxBufferLen);
        }
    }
}

/**
 * @brief Configuración de SPI1 en modo esclavo, 16 bits, etc.
 */
void MX_SPI1_Init(void)
{
    __HAL_RCC_SPI1_CLK_ENABLE();
    hspi1.Instance = SPI1;
    hspi1.Init.Mode = SPI_MODE_SLAVE;
    hspi1.Init.Direction = SPI_DIRECTION_1LINE;
    hspi1.Init.DataSize = SPI_DATASIZE_16BIT;               // Palabra de 16 bits
    hspi1.Init.CLKPolarity = SPI_POLARITY_LOW;              // Ajustar según necesidades
    hspi1.Init.CLKPhase = SPI_PHASE_1EDGE;                  // Ajustar según necesidades
    hspi1.Init.NSS = SPI_NSS_HARD_INPUT;                    // NSS controlado externamente por el maestro (PA15)
    hspi1.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_2; // No muy relevante en esclavo, depende del maestro
    hspi1.Init.FirstBit = SPI_FIRSTBIT_MSB;
    hspi1.Init.TIMode = SPI_TIMODE_DISABLE;
    hspi1.Init.CRCCalculation = SPI_CRCCALCULATION_DISABLE;
    hspi1.Init.CRCPolynomial = 7;

    if (HAL_SPI_Init(&hspi1) != HAL_OK)
    {
        // Error Handler
        Error_Handler();
    }
}

/**
 * @brief Configuración del DMA para SPI1_TX
 */
void MX_DMA_Init(void)
{
    /* Habilitar el reloj del DMA */
    __HAL_RCC_DMA1_CLK_ENABLE();

    /* Configurar DMA para SPI1 TX */
    hdma_spi1_tx.Instance = DMA1_Channel3; // Depende del mapeo del MCU. En STM32F103C8, SPI1_TX suele estar en Channel3
    hdma_spi1_tx.Init.Direction = DMA_MEMORY_TO_PERIPH;
    hdma_spi1_tx.Init.PeriphInc = DMA_PINC_DISABLE;
    hdma_spi1_tx.Init.MemInc = DMA_MINC_ENABLE;                      // Incremento de memoria para avanzar por la LUT
    hdma_spi1_tx.Init.PeriphDataAlignment = DMA_PDATAALIGN_HALFWORD; // Alineación 16 bits
    hdma_spi1_tx.Init.MemDataAlignment = DMA_MDATAALIGN_HALFWORD;    // Alineación 16 bits
    hdma_spi1_tx.Init.Mode = DMA_CIRCULAR;                           // Modo circular para repetir la LUT
    hdma_spi1_tx.Init.Priority = DMA_PRIORITY_LOW;

    if (HAL_DMA_Init(&hdma_spi1_tx) != HAL_OK)
    {
        // Error Handler
        Error_Handler();
    }

    /* Asociar el DMA al handle del SPI */
    __HAL_LINKDMA(&hspi1, hdmatx, hdma_spi1_tx);
}

/**
 * @brief Configuración del Reloj del Sistema
 */
void SystemClock_Config(void)
{
    RCC_OscInitTypeDef RCC_OscInitStruct = {0};
    RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

    /** Initializes the RCC Oscillators according to the specified parameters
     * in the RCC_OscInitTypeDef structure.
     */
    RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
    RCC_OscInitStruct.HSEState = RCC_HSE_ON;
    RCC_OscInitStruct.HSEPredivValue = RCC_HSE_PREDIV_DIV1;
    RCC_OscInitStruct.HSIState = RCC_HSI_ON;
    RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
    RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
    RCC_OscInitStruct.PLL.PLLMUL = RCC_PLL_MUL9;
    if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
    {
        Error_Handler();
    }

    /** Initializes the CPU, AHB and APB buses clocks
     */
    RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK | RCC_CLOCKTYPE_SYSCLK | RCC_CLOCKTYPE_PCLK1 | RCC_CLOCKTYPE_PCLK2;
    RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
    RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
    RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV2;
    RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;

    if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_2) != HAL_OK)
    {
        Error_Handler();
    }
}

/**
 * @brief Configuración de GPIO para SPI remapeado
 */
void MX_GPIO_Init(void)
{
    GPIO_InitTypeDef GPIO_InitStruct = {0};

    /* Habilitar reloj de GPIOA y GPIOB */
    __HAL_RCC_GPIOA_CLK_ENABLE();
    __HAL_RCC_GPIOB_CLK_ENABLE();

    // PA15 (NSS), PB3 (SCK), PB4 (MISO), PB5 (MOSI)
    // Como esclavo:
    // NSS -> Input con pull-up si se desea
    // SCK -> Input (el maestro genera el clock)
    // MISO -> Alternate function push-pull
    // MOSI -> Input (recibimos datos del maestro si fuera full-duplex)

    // NSS (PA15) como input (el maestro controla)
    GPIO_InitStruct.Pin = GPIO_PIN_15;
    GPIO_InitStruct.Mode = GPIO_MODE_AF_INPUT;
    GPIO_InitStruct.Pull = GPIO_NOPULL;
    HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

    // SCK (PB3) como input (reloj desde el maestro)
    GPIO_InitStruct.Pin = GPIO_PIN_3;
    GPIO_InitStruct.Mode = GPIO_MODE_AF_INPUT;
    GPIO_InitStruct.Pull = GPIO_NOPULL;
    HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

    // MISO (PB4) como alternate function push-pull
    GPIO_InitStruct.Pin = GPIO_PIN_4;
    GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_HIGH;
    HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

    // MOSI (PB5) como input si lo necesitamos. Si solo necesitamos transmitir, igual se deja como input AF.
    GPIO_InitStruct.Pin = GPIO_PIN_5;
    GPIO_InitStruct.Mode = GPIO_MODE_AF_INPUT;
    GPIO_InitStruct.Pull = GPIO_NOPULL;
    HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);

    // Configuración adicional si fuera necesaria
}

void Error_Handler(void)
{
    // Implementar manejo de error
    while (1)
    {
    }
}

void SysTick_Handler(void)
{
    HAL_IncTick();
}

void NMI_Handler(void)
{
}

void HardFault_Handler(void)
{
    while (1)
    {
    }
}

void MemManage_Handler(void)
{
    while (1)
    {
    }
}

void BusFault_Handler(void)
{
    while (1)
    {
    }
}

void UsageFault_Handler(void)
{
    while (1)
    {
    }
}

void SVC_Handler(void)
{
}

void DebugMon_Handler(void)
{
}

void PendSV_Handler(void)
{
}
