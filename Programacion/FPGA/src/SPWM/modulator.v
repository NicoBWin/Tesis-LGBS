module modulator (
    input wire clk,
    input wire reset,
    input [11:0] wire angle,   // Angle of the sine wave
);  

    // Triangular wave generator outputs
    wire [6:0] tri_wave_a;
    wire [6:0] tri_wave_b;
    wire [6:0] tri_wave_c;
    wire [6:0] sine_value;

    wire raw_phase_a_pwm;
    wire raw_phase_b_pwm;
    wire raw_phase_c_pwm;

    // Instantiate the 3-phase triangular wave generator
    triangular_3ph #(
        .MODULE_ID(1),  // Unique module identifier
        .MAX_A(`MAX_SIN_VALUE),    // Maximum amplitude
        .MAX_T(`SIN_SIZE)    // Period of the triangular wave
    ) tri_wave_gen (
        .clk(clk),
        .reset(reset),
        .value_a(tri_wave_a),
        .value_b(tri_wave_b),
        .value_c(tri_wave_c)
    );

    PRAM sine_wave(
        .address(angle),
        .data(sine_value)
    );

    

    always @(posedge clk) begin
        if (reset) begin
            raw_phase_a_pwm <= 0;
            raw_phase_b_pwm <= 0;
            raw_phase_c_pwm <= 0;
        end
        if (tri_wave_a >= sine_value)
            raw_phase_a_pwm <= 1;
        else 
            raw_phase_a_pwm <= 0;
        if (tri_wave_b >= sine_value)
            raw_phase_b_pwm <= 1;
        else 
            raw_phase_b_pwm <= 0;
        if (tri_wave_c >= sine_value)
            raw_phase_c_pwm <= 1;
        else 
            raw_phase_c_pwm <= 0;
    end

endmodule
