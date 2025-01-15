
`define NUM_OF_MODULES 9

/*
    legs distribution in modules
    1A 1B 1C
    2A 2B 2C
*/

// UART codes
`define IDLE 4'd0
`define ON1A2B 4'd1
`define ON1A2C 4'd2
`define ON1B2A 4'd3
`define ON1B2C 4'd4
`define ON1C2A 4'd5
`define ON1C2B 4'd6

`define ACK 4'd7
`define NACK 4'd8
`define START 4'd9
`define STOP 4'd10

`define ADC_TOP 4'd11
`define ADC_BOTTOM 4'd12   
`define ZERO_A 4'd13
`define ZERO_B 4'd14
`define ZERO_C 4'd15

// SPI codes
`define PIPE_MODE_SPI 16'hB0CA
`define IDLE_SPI 16'h0000

`define UART_MAP(uart_id, rx_gpio, tx_gpio) \
    wire tx_mod_``uart_id`` = tx_gpio;      \
    wire rx_mod_``uart_id`` = rx_gpio;
