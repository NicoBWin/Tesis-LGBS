
`define NUM_OF_MODULES 3
`define NUM_OF_PHASES 3
`define SIN_SIZE 4096
`define TRIAG_T 256
`define MAX_SIN_VALUE 128
`define MODULE_ID 4'd1

/*
    legs distribution in modules
    1A 1B 1C
    2A 2B 2C
*/

// SPI codes
`define PIPE_MODE_SPI 12'hB0C
`define IDLE_SPI 12'h000

`define UART_MAP(uart_id, rx_gpio, tx_gpio) \
    wire tx_mod_``uart_id`` = tx_gpio;      \
    wire rx_mod_``uart_id`` = rx_gpio;
