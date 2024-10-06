/*
    Para usarlo, leemos data_received donde esta la data cuando donde = 1 o en el rising edge.
    Si ocurre un error de paridad, parity_error = 1 por un ciclo de clk indicando que el dato 
    recibido no es valido.
*/

module uart_rx(
    input wire clk,            // Clock signal
    input wire reset,          // Reset signal
    input wire rx,             // UART receive line
    output reg [7:0] data_received,   // 8-bit data out
    output reg rx_done,         // Indicates reception is complete
    output reg parity_error     // Flag that indicates that there was a parity error
);

    // Config
    parameter CLK_FREQ = 60000000;  // System clock frequency (e.g., 50 MHz)
    parameter BAUD_RATE = 6000000;     // Desired baud rate
    parameter PARITY = 0;           // 0 for even parity, 1 for odd parity
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    reg [9:0] rx_shift_reg;         // PARITY, DATA, START
    reg [31:0] clk_count;           // Clock counter
    reg [3:0] bit_index;            // Index for the bits being received
    reg rx_busy;                    // Indicates reception is in progress
    reg parity;

    always @(posedge clk or posedge reset) 
        begin
            if (reset) 
                begin
                    rx_busy <= 0;
                    clk_count <= 0;
                    bit_index <= 0;
                    rx_done <= 0;
                    parity <= 0;
                    parity_error <= 0;
                    rx_shift_reg <= {10{1'b0}};
                    data_received <= {8{1'b0}};
                end 
            else if (!rx_busy && !rx) 
                begin
                    rx_busy <= 1;
                    rx_done <= 0;
                    clk_count <= 0;
                    bit_index <= 0;
                    parity <= 0;
                    parity_error <= 0;
                end 
            else if (rx_busy) 
                begin
                    if (clk_count >= CLKS_PER_BIT)
                        begin
                            if (bit_index > 9)
                                begin
                                    rx_done <= 1;
                                    rx_busy <= 0;
                                    if (PARITY != ^rx_shift_reg[9:1])
                                            parity_error <= 1;
                                    else 
                                        data_received <= rx_shift_reg[8:1]; 
                                end
                            else
                                bit_index <= bit_index + 1;

                            rx_shift_reg[bit_index] <= rx;
                            clk_count <= 0;
                        end
                    else 
                        begin
                            clk_count <= clk_count + 1;
                        end
                end 
        end
endmodule
