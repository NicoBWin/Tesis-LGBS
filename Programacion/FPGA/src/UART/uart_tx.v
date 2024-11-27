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
    output reg tx,             // UART transmit line
    output reg tx_busy         // Indicates transmission is in progress
);

    // Config
    parameter BAUD_RATE = `BAUD6M_CLK24M;      // Desired baud rate
    parameter PARITY = 0;               // 0 for even parity, 1 for odd parity

    reg [10:0] to_transmit;         // STOP(1), PARITY(1), DATA(8), START(0)
    reg [3:0] bit_index;            // Index for the bits being sent

    wire parity;                    // Current parity
    wire baud_clk;
    wire local_clk;

    clk_divider #(BAUD_RATE) baudrate_gen(
        .clk_in(clk),
        .reset(reset),
        .clk_out(baud_clk)
    );
    
    //assign local_clk = tx_busy ? baud_clk : clk;
    assign parity = PARITY ? ~(data_to_tx) :  data_to_tx;  // XOR for even parity, inverted XOR for odd parity

    always @(posedge baud_clk or posedge reset) 
        begin
            if (reset) 
            begin
                tx <= 1'b1;            
                tx_busy <= 1'b0;
                bit_index <= 0;
            end 
            else if (start_tx && !tx_busy) 
                begin   
                    tx_busy <= 1'b1;
                    to_transmit <= {1'b1, parity, data_to_tx, 1'b0};
                    tx <= 0;
                    bit_index <= 1;
                end
            else if (tx_busy) 
                begin
                    tx <= to_transmit[bit_index];

                    if (bit_index < 10) 
                        begin
                            bit_index <= bit_index + 1;
                        end
                    else
                        begin
                            tx_busy <= 0;
                            bit_index <= 0;
                        end
                end
        end
endmodule