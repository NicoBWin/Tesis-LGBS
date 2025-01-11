
`define NUM_OF_MODULES 9

// UART codes
`define IDLE 4'd0
`define TR1_A 4'd1
`define TR2_A 4'd2
`define TR1_B 4'd3
`define TR2_B 4'd4
`define TR1_C 4'd5
`define TR2_C 4'd6
`define ACK 4'd7
`define NACK 4'd8
`define START 4'd9
`define STOP 4'd10
`define ADC 4'd11   // Read adc

// SPI codes
`define PIPE_MODE_SPI 16'hB0CA
`define IDLE_SPI 16'h0000

`define UART_MAP(uart_id, rx_gpio, tx_gpio) \
    wire tx_mod_``uart_id`` = tx_gpio;      \
    wire rx_mod_``uart_id`` = rx_gpio;
