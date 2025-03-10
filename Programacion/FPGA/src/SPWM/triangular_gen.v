
module triangular_gen
(
    input wire clk,             // Input clock
    input wire reset,           // Reset signal
    input wire step,
    output reg [$clog2(MAX_A)-1:0] value // value output
);
    
    parameter INITIAL_T = 0;
    parameter MAX_A = 128;
    parameter MAX_T = 4096;

    localparam UP = 1;
    localparam DOWN = 0;

    reg [$clog2(MAX_T)-1:0] slope = 2 * MAX_A / MAX_T;  // pendiente de la triangular
    reg up_down = UP;

    always @(posedge clk) begin
        if (reset) begin
            up_down <= UP;

            if (INITIAL_T < MAX_A/2 - 1) begin
                value <= slope * INITIAL_T;             //Lado creciente de la triangular
            end
            else begin
                value <= 2 * MAX_A - slope * INITIAL_T; //Lado decreciente de la triangular
            end

        end else if (up_down == UP) begin
            if (value + step < MAX_A)
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