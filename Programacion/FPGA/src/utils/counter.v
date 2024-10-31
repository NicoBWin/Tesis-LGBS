module counter (
    input clk,                // Clock signal
    input reset,              // Reset signal (active high)
    input enable,             // Enable signal to increment the counter
    input [WIDTH-1:0] max_count,  // Maximum count value
    output reg [WIDTH-1:0] count  // Counter output
);
    parameter WIDTH = 8;       // Width of the counter (default 8 bits)

    always @(posedge clk) begin
        if (reset) begin
            count <= 0;        // Reset the counter to 0
        end else if (enable) begin
            if (count == max_count)
                count <= 0;    // Reset the counter when max_count is reached
            else
                count <= count + 1;  // Increment the counter
        end
    end
endmodule