/*
    Para usarlo, enviamos la informacion a transmitir a data_to_tx y ponemos start_tx en 1. 
    Automaticamente el tx_busy = 1 indicando que la transmision esta en progreso. 
    Un clk despues ya es posible cambiar el valor de data_to_tx. El bit de tx_busy se pone en 1 y 
    hasta que termine la transmision que se pone en 0.
*/

`include "UART/baudgen.vh"

module uart_tx(
    input wire clk,            // Clock signal
    input wire reset,
    input wire [7:0] data_to_tx,  // 8-bit data in
    input wire start_tx,       // Start transmission
    output wire tx,             // UART transmit line
    output reg tx_busy         // Indicates transmission is in progress
);

    // Config
    parameter BAUD_RATE = `BAUD8M;      // Desired baud rate
    parameter PARITY = 0;               // 0 for even parity, 1 for odd parity

    // States
    localparam INIT = 2'b00;
    localparam IDLE = 2'b01;
    localparam TX   = 2'b10;

    reg [10:0] to_transmit;         // STOP(1), PARITY(1), DATA(8)
    reg [3:0] bit_index;            // Index for the bits being sent
    reg [1:0] state = INIT;

    wire parity;                    // Current parity
    wire baud_clk;
    
    assign tx = to_transmit[0];
    assign parity = PARITY ? ~(^data_to_tx) :  ^data_to_tx;  // XOR for even parity, inverted XOR for odd parity

    clk_divider #(BAUD_RATE) baudrate_gen(
        .clk_in(clk),
        .reset(reset),
        .clk_out(baud_clk)
    );

    always @(posedge baud_clk)
        begin
            case (state)
                INIT: begin
                    tx_busy <= 0;
                    bit_index <= 0;
                    to_transmit <= 11'b11111111111;
                    state <= IDLE;
                end

                IDLE: begin
                    if (start_tx) begin
                        tx_busy <= 1;
                        bit_index <= 0;
                        state <= TX;
                    end
                end

                TX: begin
                    to_transmit <= {1'b1, to_transmit[10:1]};
                    if (bit_index >= 10) begin 
                        state <= INIT;
                    end
                    else begin
                        bit_index <= bit_index + 1;
                    end
                end
            endcase
        end
endmodule