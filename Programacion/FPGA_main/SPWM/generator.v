
`include "SPWM/config.vh"

module triangular_generator(
    input wire clk,                    // Clock signal
    output wire [5:0] current_value    // Current signal value
);

    parameter INITIAL_VALUE = 0;
    parameter COUNT_DIR = `UP;

    wire curr_dir;
    assign curr_dir = (current_value >= 32) ? `DOWN : `UP;
    
    always @(posedge clk) begin
        if (curr_dir == `UP) begin
            current_value = current_value + 1;
        end
        else
            current_value = current_value - 1;
    end

endmodule
