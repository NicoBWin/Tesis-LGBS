module uart_rx(
    input wire clk,            // Clock signal
    input wire reset,          // Reset signal
    input wire rx,             // UART receive line
    output reg [7:0] data_out, // 8-bit data output
    output reg rx_done         // Indicates reception is complete
    output reg parity_error    // Flag that indicates that there was a parity error
);

    // Config
    parameter CLK_FREQ = 50000000;  // System clock frequency (e.g., 50 MHz)
    parameter BAUD_RATE = 9600;     // Desired baud rate
    parameter PARITY = 0;           // 0 for even parity, 1 for odd parity
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    reg [31:0] clk_count;           // Clock counter
    reg [3:0] bit_index;            // Index for the bits being received
    reg [7:0] rx_shift_reg;         // Shift register for receiving the data
    reg rx_busy;                    // Indicates reception is in progress
    
    wire parity;                    // Current parity
    assign parity = PARITY ? ~(^data_in) : ^data_in;  // XOR for even parity, inverted XOR for odd parity

    always @(posedge clk or posedge reset) 
        begin
            if (reset) 
                begin
                    rx_busy <= 1'b0;
                    clk_count <= 0;
                    bit_index <= 9;
                    rx_done <= 1'b0;
                    parity_error <= 1'b0;
                end 
            else if (!rx_busy && !rx) 
                begin
                    // Start reception on falling edge of start bit
                    rx_busy <= 1'b1;
                    clk_count <= CLKS_PER_BIT / 2;  // To sample in the middle of the bit
                    bit_index <= 9;
                    parity_error <= 1'b0;
                end 
            else if (rx_busy) 
                begin
                    if (clk_count < CLKS_PER_BIT) 
                        begin
                            clk_count <= clk_count + 1;
                        end 
                    else 
                        begin
                            clk_count <= 0;
                            if (bit_index < 8) 
                                begin
                                    rx_shift_reg[bit_index] <= rx;
                                    bit_index <= bit_index - 1;
                                end 
                            else 
                                begin
                                    data_out <= rx_shift_reg;
                                    rx_done <= 1'b1;
                                    rx_busy <= 1'b0;
                                    if (parity != ^data_out)
                                        parity_error <= 1'b1
                                end
                        end
                end 
            else 
                begin
                    rx_done <= 1'b0;
                    parity_error <= 1'b0;
                end
        end
endmodule
