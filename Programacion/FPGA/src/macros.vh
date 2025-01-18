
`define NUM_OF_MODULES 9
`define NUM_OF_PHASES 3
`define SIN_SIZE 65536
`define MODULE_OFFSET (`SIN_SIZE / `NUM_OF_MODULES)
`define PHASE_OFFSET (`SIN_SIZE / `NUM_OF_PHASES)

/*
    legs distribution in modules
    1A 1B 1C
    2A 2B 2C
*/


// SPI codes
`define PIPE_MODE_SPI 16'hB0CA
`define IDLE_SPI 16'h0001

`define UART_MAP(uart_id, rx_gpio, tx_gpio) \
    wire tx_mod_``uart_id`` = tx_gpio;      \
    wire rx_mod_``uart_id`` = rx_gpio;
