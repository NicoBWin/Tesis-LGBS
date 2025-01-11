module up_counter #(parameter MAX_COUNT = 16)
(
    input wire clk,         // Input clock
    input wire reset,          // Reset signal
    output reg [$clog2(MAX_COUNT)-1:0] counter // Counter output
);

    always @(posedge clk) begin
        if (reset) begin
            counter <= 0; // Reset counter to 0
        end else begin
            if (counter < MAX_COUNT - 1)
                counter <= counter + 1; // Count up
            else
                counter <= 0; // Wrap around to 0 on reaching MAX_COUNT
        end
    end

endmodule