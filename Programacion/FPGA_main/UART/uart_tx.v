/*
    Para usarlo, enviamos la informacion a transmitir a data_to_tx y ponemos start_tx en 1. 
    Automaticamente el tx_busy = 1 indicando que la transmision esta en progreso. 
    Un clk despues ya es posible cambiar el valor de data_to_tx. El bit de tx_busy se pone en 1 y 
    hasta que termine la transmision que se pone en 0.
*/

module uart_tx(
    input wire clk,            // Clock signal
    input wire [7:0] data_to_tx,  // 8-bit data in
    input wire start_tx,       // Start transmission
    output reg tx,             // UART transmit line
    output reg tx_busy         // Indicates transmission is in progress
);

    // Config
    parameter CLK_FREQ = 24000000;  // System clock frequency (e.g., 50 MHz)
    parameter BAUD_RATE = 8000000;     // Desired baud rate
    parameter PARITY = 0;           // 0 for even parity, 1 for odd parity

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    // States
    localparam INIT = 2'b00;
    localparam IDLE = 2'b01;
    localparam TX   = 2'b10;

    reg [3:0] bit_index;            // Index for the bits being sent
    reg [31:0] clk_count;           // Clock counter
    reg [1:0] state = INIT;

    wire parity;                    // Current parity
    wire [9:0] to_transmit;         // STOP(1), PARITY(1), DATA(8)

    assign parity = PARITY ? ~(^data_to_tx) :  ^data_to_tx;  // XOR for even parity, inverted XOR for odd parity
    assign to_transmit = {1'b1, parity, data_to_tx};   

    always @(posedge clk)
        begin
            case (state)
                INIT: begin
                    tx <= 1;
                    tx_busy <= 0;
                    clk_count <= 0;
                    bit_index <= 0;
                    state <= IDLE;
                end

                IDLE: begin
                    if (start_tx) begin
                        tx_busy <= 1;
                        bit_index <= 0;
                        clk_count <= 0;
                        tx <= 0;
                        state <= TX;
                    end
                end

                TX: begin 
                    if (clk_count >= CLKS_PER_BIT)
                        begin
                            if (bit_index >= 10) begin 
                                state <= INIT;
                            end
                            else begin
                                bit_index <= bit_index + 1;
                                tx <= to_transmit[bit_index];
                                clk_count <= 0;
                            end
                        end
                    else begin
                        clk_count <= clk_count + 1;
                    end
                end
            endcase
        end
endmodule