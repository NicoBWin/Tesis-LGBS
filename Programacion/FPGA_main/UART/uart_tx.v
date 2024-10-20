/*
    Para usarlo, enviamos la informacion a transmitir a data_to_tx y ponemos start_tx en 1. 
    Automaticamente el tx_busy = 1 indicando que la transmision esta en progreso. 
    Un clk despues ya es posible cambiar el valor de data_to_tx. El bit de tx_busy se pone en 1 y 
    hasta que termine la transmision que se pone en 0.
*/

`include "baudgen.vh"

module uart_tx(
    input wire clk,            // Clock signal
    input wire [7:0] data_to_tx,  // 8-bit data in
    input wire start_tx,       // Start transmission
    output wire tx,             // UART transmit line
);

    // Config
    parameter BAUD_RATE = `B8M;     // Desired baud rate
    parameter PARITY = 0;           // 0 for even parity, 1 for odd parity

    wire parity;                    // Current parity
    wire clk_baud;

    reg [10:0] to_transmit = {1'b1, parity, data_to_tx, 1'b0};
    assign parity = PARITY ? ~(^data_to_tx) :  ^data_to_tx;  // XOR for even parity, inverted XOR for odd parity
    assign tx = (start_tx) ? to_transmit[0] : 1;

    divider #(`B115200)
        BAUD0 (
            .clk_in(clk),
            .clk_out(clk_baud)
        );

    always @(posedge clk_baud)
        if (start_tx)
            to_transmit <= {to_transmit[0], to_transmit[10:1]};
        else
            to_transmit <= {1'b1, parity, data_to_tx, 1'b0};

endmodule