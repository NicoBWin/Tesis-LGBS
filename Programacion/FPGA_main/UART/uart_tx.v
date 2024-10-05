/*
    Para usarlo, enviamos la informacion a transmitir a data_to_tx y ponemos start_tx en 1. 
    Automaticamente el tx_busy = 1 indicando que la transmision esta en progreso. 
    Un clk despues ya es posible cambiar el valor de data_to_tx. El bit de tx_busy se pone en 1 y 
    hasta que termine la transmision que se pone en 0.
*/

module uart_tx(
    input wire clk,            // Clock signal
    input wire reset,          // Reset signal
    input wire [7:0] data_to_tx,  // 8-bit data in
    input wire start_tx,       // Start transmission
    output reg tx,             // UART transmit line
    output reg tx_busy         // Indicates transmission is in progress
);

    // Config
    parameter CLK_FREQ = 6000000;  // System clock frequency (e.g., 50 MHz)
    parameter BAUD_RATE = 9600;     // Desired baud rate
    parameter PARITY = 0;           // 0 for even parity, 1 for odd parity
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    reg [3:0] bit_index;            // Index for the bits being sent
    reg [31:0] clk_count;           // Clock counter
    reg [10:0] tx_shift_reg;        // STOP, PARITY, DATA, START

    wire parity;                    // Current parity
    assign parity = PARITY ? ~(data_to_tx) :  data_to_tx;  // XOR for even parity, inverted XOR for odd parity

    always @(posedge clk or posedge reset) 
        begin
            if (reset) 
                begin
                    tx <= 1'b1;             // UART idle state is high
                    tx_busy <= 1'b0;
                    clk_count <= 0;
                    bit_index <= 0;        // We start from the most significant which is start
                    tx_shift_reg <= {11{1'b1}}; //Todo 1
                end 
            else if (start_tx && !tx_busy) 
                begin
                    tx_shift_reg <= {1'b1, parity, data_to_tx, 1'b0};  // STOP(1), PARITY(1), DATA(8), START(0) 
                    tx_busy <= 1'b1;
                    clk_count <= 0;
                    bit_index <= 0;
                end
            else if (tx_busy) 
                begin
                    if (clk_count > CLKS_PER_BIT)
                        begin
                            clk_count <= 0;
                            tx <= tx_shift_reg[bit_index];

                            if (bit_index < 10) 
                                begin
                                    bit_index <= bit_index + 1;
                                end
                            else
                                begin
                                    tx_busy <= 1'b0;
                                end
                        end
                    else
                        begin
                            clk_count <= clk_count + 1;
                        end 
                end
        end
endmodule