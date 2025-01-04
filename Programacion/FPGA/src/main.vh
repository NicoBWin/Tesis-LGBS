
`define NUM_OF_MODULES 9

// UART codes
`define TR_00 5'00000
`define TR_01 5'00001
`define TR_10 5'00010
`define TR_11 5'00011
`define TR_20 5'00100
`define TR_21 5'00101

`define ACK 5'11101
`define PIPE 5'11110 //Permite forwardear todo lo que venga por UART hacia 1 solo modulo

`define GET_ADC 5'11111

// SPI codes
`define PIPE_MODE 16'hB0CA

`define UART_MAP(uart_id, rx_gpio, tx_gpio) \
    wire tx_mod_``uart_id`` = tx_gpio;      \
    wire rx_mod_``uart_id`` = rx_gpio;
