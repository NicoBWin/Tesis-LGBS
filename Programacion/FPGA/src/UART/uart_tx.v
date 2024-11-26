/*
    Para usarlo, enviamos la informacion a transmitir a data_to_tx y ponemos start_tx en 1. 
    Automaticamente el tx_busy = 1 indicando que la transmision esta en progreso. 
    Un clk despues ya es posible cambiar el valor de data_to_tx. El bit de tx_busy se pone en 1 y 
    hasta que termine la transmision que se pone en 0.
*/

`include "./src/UART/baudgen.vh"

module uart_tx(
    input wire clk,            // Clock signal
    input wire reset,
    input wire [7:0] data_to_tx,  // 8-bit data in
    input wire start_tx,       // Start transmission
    output wire tx,             // UART transmit line
    output reg tx_busy         // Indicates transmission is in progress
);

    // Config
    parameter BAUD_RATE = `BAUD6M_CLK24M;      // Desired baud rate
    parameter PARITY = 0;               // 0 for even parity, 1 for odd parity

    reg [11:0] to_transmit;         // STOP(2), PARITY(1), DATA(8), START(0)
    reg [3:0] bit_index;            // Index for the bits being sent

    wire parity;                    // Current parity
    wire baud_clk;
    wire local_clk;
    
    assign tx = to_transmit[0];
    assign local_clk = tx_busy ? baud_clk : clk;
    assign parity = PARITY ? ~(^data_to_tx) :  ^data_to_tx;  // XOR for even parity, inverted XOR for odd parity

    clk_divider #(BAUD_RATE) baudrate_gen(
        .clk_in(clk),
        .reset(reset),
        .clk_out(baud_clk)
    );

    always @(posedge local_clk)
        begin
            if(reset) begin
                tx_busy <= 0;
                bit_index <= 0;
                to_transmit <= 12'b111111111111;
            end
            else if(start_tx & !tx_busy) begin
                tx_busy <= 1;
                bit_index <= 0;
                to_transmit <= {2'b11, parity, data_to_tx, 1'b0};
            end
            else if (tx_busy) begin
                to_transmit <= {1'b1, to_transmit[10:1]};
                bit_index <= bit_index + 1;

                if (bit_index >= 11) begin 
                    tx_busy <= 0;
                end
            end
        end
endmodule