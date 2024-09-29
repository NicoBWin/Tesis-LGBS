module uart_tx(
    input wire clk,            // Clock signal
    input wire reset,          // Reset signal
    input wire [7:0] data_in,  // 8-bit data input
    input wire start_tx,       // Start transmission
    output reg tx,             // UART transmit line
    output reg tx_busy         // Indicates transmission is in progress
);

    // Config
    parameter CLK_FREQ = 50000000;  // System clock frequency (e.g., 50 MHz)
    parameter BAUD_RATE = 9600;     // Desired baud rate
    parameter PARITY = 0;           // 0 for even parity, 1 for odd parity
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    reg [3:0] bit_index;            // Index for the bits being sent
    reg [31:0] clk_count;           // Clock counter
    reg [10:0] tx_shift_reg;        // Shift register for serializing the data

    wire parity;                    // Current parity
    assign parity = PARITY ? ~(^data_in) : ^data_in;  // XOR for even parity, inverted XOR for odd parity

    always @(posedge clk or posedge reset) 
        begin
            if (reset) 
                begin
                    tx <= 1'b1;             // UART idle state is high
                    tx_busy <= 1'b0;
                    clk_count <= 0;
                    bit_index <= 10;        // We start from the most significant which is start
                    tx_shift_reg <= 11'b11111111111;
                end 
            else if (start_tx && !tx_busy) 
                begin
                    tx_shift_reg <= {1'b0, data_in, parity, 1'b1}; 
                    tx_busy <= 1'b1;
                    clk_count <= 0;
                    bit_index <= 10;
                end
            else if (tx_busy) 
                begin
                    if (clk_count < CLKS_PER_BIT) 
                        begin
                            clk_count <= clk_count + 1;
                        end 
                    else 
                        begin
                            clk_count <= 0;
                            tx <= tx_shift_reg[bit_index];
                            bit_index <= bit_index - 1;

                            if (bit_index == 0) 
                                begin
                                    tx_busy <= 1'b0;
                                end
                        end
                end
        end
endmodule