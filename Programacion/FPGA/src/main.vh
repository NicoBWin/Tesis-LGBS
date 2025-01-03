
// SPI codes
`define PIPE_MODE 16'hB0CA

`define UART_MAP(uart_id, rx_gpio, tx_gpio) \
    wire tx_mod_``uart_id`` = tx_gpio;      \
    wire rx_mod_``uart_id`` = rx_gpio;