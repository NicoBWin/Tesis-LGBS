module system_output (
    input  wire [6:0] va,  // 7-bit phase A
    input  wire [6:0] vb,  // 7-bit phase B
    input  wire [6:0] vc,  // 7-bit phase C
    input  wire [6:0]tri_wave,
    input  wire shoot, 
    input  wire reset, 
    output [5:0] transistor_out     // 6-bit output from lookup table
);

    wire [5:0] g_max;
    wire [5:0] g_out;
    wire [5:0] g;
    reg  [6:0] va_reg = 0;
    reg  [6:0] vb_reg = 0;
    reg  [6:0] vc_reg = 0;
    assign raw_phase_a_pwm = reset ? 1'b0 : (va_reg >= tri_wave);
    assign raw_phase_b_pwm = reset ? 1'b0 : (vb_reg >= tri_wave);
    assign raw_phase_c_pwm = reset ? 1'b0 : (vc_reg >= tri_wave);
    assign transistor_out = g[5:3] == 0 || g[2:0] == 0 ? 6'b100100 : g;
    
    maximum_calculator sine_max (
        .alpha3_phase_Vab0(va_reg),
        .alpha3_phase_Vab120(vb_reg),
        .alpha3_phase_Vab240(vc_reg),
        .g_max(g_max));

    
    phase2transitors phase_voltage_comparison (
        .in({raw_phase_a_pwm, raw_phase_b_pwm, raw_phase_c_pwm}),
        .out(g_out)
    );


    always @(posedge shoot) begin
        va_reg <= va;
        vb_reg <= vb;
        vc_reg <= vc;
    end

endmodule
