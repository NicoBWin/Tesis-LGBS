
//Constrantes principales del sistema

/*
    IMPORTANTE: Seleccionar el numero de modulos conectados al sistema. 
    Para cada modulo, se debe modificar en tiempo de compilacion a que modulo corresponde.
    Para ello, se debe modificar el valor de MODULE_ID en cada modulo. El valor de MODULE_ID
    cambia el color de las leds de cada modulo para verificar de forma visual que NO hayan dos
    modulos con el mismo ID. Este ID controla el desfasaje de las fases de cada modulo. Dos modulos
    con el mismo ID generarian señales en fase, lo cual no es deseado. 
*/

// NO CAMBIAR SIN LEER EN DETALLE EL FUNCIONAMIENTO DEL SISTEMA
`define NUM_OF_PHASES 3   // Declaracion de la cantidad de fases por modulo (NO cambiar)
`define SIN_SIZE 4096     // Cantidad de puntos de la tabla senoidal (2^12)
`define MAX_SIN_VALUE 128 // Valor maximo de amplitud de la tabla senoidal (2^7)
`define TRIAG_T 256       // Perido en puntos de la tabla triangular 

// CAMBIAR SEGUN LA APLICACION
`define NUM_OF_MODULES 3  // Declaracion de la cantidad de modulos conectados
`define MODULE_ID 4'd2    // ID del modulo (entre 0 y 8)

// codigos de SPI
`define PIPE_MODE_SPI 12'hB0C
`define IDLE_SPI 12'h000

// codigos de UART
`define UART_MAP(uart_id, rx_gpio, tx_gpio) \
    wire tx_uart_``uart_id`` = tx_gpio;      \
    wire rx_uart_``uart_id`` = rx_gpio;
