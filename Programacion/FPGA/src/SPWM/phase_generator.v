
module phase_generator #(parameter BITS_PRECISION = 4'd9)(
    input wire clk,                                    
    input wire reset,
                                    
    input wire [BITS_PRECISION-1:0] phase_a_sine,
    input wire [BITS_PRECISION-1:0] phase_b_sine,
    input wire [BITS_PRECISION-1:0] phase_c_sine,

    output reg phase_a_pwm,
    output reg phase_b_pwm,
    output reg phase_c_pwm
);

    parameter TRIANG_POINTS = 64;
    wire [BITS_PRECISION-1:0] curr_triang_value;

    //2 * MAX_COUNT is the period of the triangular
    triangular_gen #($pow(2, BITS_PRECISION)) triangular   
    (
        .clk(clk),               // Input clock 24MHz input clk -> 375k triang
        .reset(reset),              // Reset signal
        .step($pow(2, BITS_PRECISION) / TRIANG_POINTS),      
        .value(curr_triang_value)   // Current triangular value
    );

    always @(posedge clk) begin
        if (reset) begin
            phase_a_pwm <= 0;
            phase_b_pwm <= 0;
            phase_c_pwm <= 0;
        end
        if (phase_a_sine >= curr_triang_value)
            phase_a_pwm <= 1;
        else 
            phase_a_pwm <= 0;
        if (phase_b_sine >= curr_triang_value)
            phase_b_pwm <= 1;
        else 
            phase_b_pwm <= 0;
        if (phase_c_sine >= curr_triang_value)
            phase_c_pwm <= 1;
        else 
            phase_c_pwm <= 0;
    end

endmodule