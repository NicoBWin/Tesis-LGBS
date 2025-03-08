module system_output (
    input  wire [6:0] va,  // 7-bit phase A
    input  wire [6:0] vb,  // 7-bit phase B
    input  wire [6:0] vc,  // 7-bit phase C
    input  wire raw_phase_a_pwm,
    input  wire raw_phase_b_pwm,
    input  wire raw_phase_c_pwm,
    input  wire shoot, 
    output reg  [5:0] transistor_out     // 6-bit output from lookup table
);

    // 1) Compute differences between phases (signed)
    wire signed [6:0] dAB = va - vb;  // Difference A-B
    wire signed [6:0] dAC = va - vc;  // Difference A-C
    wire signed [6:0] dBC = vb - vc;  // Difference B-C

    // 2) Compute absolute values of the differences
    wire [6:0] dAB_abs = (dAB[6] == 1'b1) ? (~dAB + 1'b1) : dAB;
    wire [6:0] dAC_abs = (dAC[6] == 1'b1) ? (~dAC + 1'b1) : dAC;
    wire [6:0] dBC_abs = (dBC[6] == 1'b1) ? (~dBC + 1'b1) : dBC;

    wire cAB = (dAB_abs > dAC_abs);
    wire cAC = (dAB_abs > dBC_abs);
    wire cBC = (dAC_abs > dBC_abs);

    wire [5:0] sine_triangular_out;
    wire [5:0] phase_voltage_out;

    /*TODO: Revisar orden de esto*/
    phase2transitors sine_triangular_comparison (
        .shoot(shoot),
        .in({cAB, cAC, cBC}),
        .out(sine_triangular_out)
    );

    /*TODO: Revisar orden de esto*/
    phase2transitors phase_voltage_comparison (
        .shoot(shoot),
        .in({raw_phase_a_pwm, raw_phase_b_pwm, raw_phase_c_pwm}),
        .out(phase_voltage_out)
    );

    assign transistor_out = phase_voltage_out > sine_triangular_out ? phase_voltage_out : sine_triangular_out;

endmodule
