
`define UP 1
`define DOWN 0

module up_down_counter #(parameter MAX_COUNT = 16)
(
    input wire clk_in,         // Input clock
    input wire reset,          // Reset signal
    input wire up_down,        
    output reg [$clog2(MAX_COUNT)-1:0] counter // Counter output
);

    always @(posedge clk_in) begin
        if (reset) begin
            counter <= 0;
        end else if (up_down) begin
            if (counter < MAX_COUNT - 1)
                counter <= counter + 1; // Count up
            else
                counter <= 0; // Wrap around to 0 on reaching MAX_COUNT
        end else begin
            if (counter > 0)
                counter <= counter - 1; // Count down
            else
                counter <= MAX_COUNT - 1; // Wrap around to MAX_COUNT - 1 on underflow
        end
    end

endmodule