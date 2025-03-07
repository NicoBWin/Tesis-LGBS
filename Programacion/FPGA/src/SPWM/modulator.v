module modulator (
    input wire clk,
    input wire reset,
    input wire shoot,
    input [11:0] wire angle,   // Angle of the sine wave

    output reg g1_a,   // Gate 1 of the phase A
    output reg g2_a,   // Gate 2 of the phase A
    output reg g1_b,   // Gate 1 of the phase B
    output reg g2_b,   // Gate 2 of the phase B
    output reg g1_c,   // Gate 1 of the phase C
    output reg g2_c,   // Gate 2 of the phase C
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
