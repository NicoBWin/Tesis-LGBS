module modulator #(parameter MODULE_ID = 0) (
    input wire clk,
    input wire reset,
    input wire shoot,
    input wire [11:0] angle,   // Angle of the sine wave
    output wire g1_a,   // Gate 1 of the phase A
    output wire g2_a,   // Gate 2 of the phase A
    output wire g1_b,   // Gate 1 of the phase B
    output wire g2_b,   // Gate 2 of the phase B
    output wire g1_c,   // Gate 1 of the phase C
    output wire g2_c   // Gate 2 of the phase C
);  

    // Triangular wave generator outputs
    wire [6:0] tri_wave;
    wire [6:0] sine_value_A;
    wire [6:0] sine_value_B;
    wire [6:0] sine_value_C;
    wire [5:0] glitched_g;
    wire [5:0] deglitched_g;
    wire raw_phase_a_pwm;
    wire raw_phase_b_pwm;
    wire raw_phase_c_pwm;

    // Instantiate the triangular wave generator

    triangular_gen #(.INITIAL_T(`TRIAG_T/`NUM_OF_MODULES * `MODULE_ID), .MAX_A(`MAX_SIN_VALUE), .MAX_T(`TRIAG_T)) triangular_A (
        .clk(clk),
        .reset(reset),
        .step(1'b1),
        .value(tri_wave)
    );

    PRAM sine_wave(
        .address(angle),
        .sine_A(sine_value_A),
        .sine_B(sine_value_B),
        .sine_C(sine_value_C)
    );

    assign raw_phase_a_pwm = reset ? 1'b0 : (sine_value_A >= tri_wave);
    assign raw_phase_b_pwm = reset ? 1'b0 : (sine_value_B >= tri_wave);
    assign raw_phase_c_pwm = reset ? 1'b0 : (sine_value_C >= tri_wave);


    system_output sys_out(
        .va(sine_value_A),
        .vb(sine_value_B),
        .vc(sine_value_C),
        .tri_wave(tri_wave),
        .reset(reset),
        .shoot(shoot),
        .transistor_out(glitched_g)
    );
    
    glitch_filter #(
        .DATA_WIDTH(6),
        .N(10)  // 10 cycles of 48MHz -> 208.33ns
    ) glitch_filter_U (
        .clk(clk),
        .reset(reset),
        .in_signal(glitched_g),
        .out_signal({g1_a, g1_b, g1_c, g2_a, g2_b, g2_c})
    );

    // dead_time_inv #(
    //     .DT(2)
    // ) dead_time_inv_U (
    //     .clk(clk),
    //     .rst(reset),
    //     .g_in(deglitched_g),
    //     .g_out()
    // );
    

endmodule
