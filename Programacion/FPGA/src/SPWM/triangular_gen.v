
module triangular_gen #(parameter MAX_COUNT = 16)
(
    input wire clk,             // Input clock
    input wire reset,           // Reset signal
    input wire step,
    output reg[$clog2(MAX_COUNT)-1:0] value // value output
);

    localparam UP = 1;
    localparam DOWN = 0;

    reg up_down = UP;

    always @(posedge clk) begin
        if (reset) begin
            up_down <= UP;
            value <= 0;
        end else if (up_down == UP) begin
            if (value < MAX_COUNT - step)
                value <= value + step; // Count up
            else 
                up_down <= DOWN; // Count down
        end else begin
            if (value > 0)
                value <= value - step; // Count down
            else
                up_down <= UP; // Count up
        end
    end

endmodule