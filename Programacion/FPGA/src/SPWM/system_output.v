module system_output (
    input  wire [6:0] va,  // 7-bit phase A
    input  wire [6:0] vb,  // 7-bit phase B
    input  wire [6:0] vc,  // 7-bit phase C
    input  wire [6:0]tri_wave,
    input  wire shoot, 
    input  wire reset, 
    output reg [5:0] transistor_out     // 6-bit output from lookup table
);

    wire [5:0] g_max;
    wire [5:0] g_out;
    assign raw_phase_a_pwm = reset ? 1'b0 : (va >= tri_wave);
    assign raw_phase_b_pwm = reset ? 1'b0 : (vb >= tri_wave);
    assign raw_phase_c_pwm = reset ? 1'b0 : (vc >= tri_wave);
    
    maximum_calculator sine_max (
        .alpha3_phase_Vab0(va),
        .alpha3_phase_Vab120(vb),
        .alpha3_phase_Vab240(vc),
        .g_max(g_max));

    
    phase2transitors phase_voltage_comparison (
        .in({raw_phase_a_pwm, raw_phase_b_pwm, raw_phase_c_pwm}),
        .out(g_out)
    );
    always @(posedge shoot) begin
        transistor_out <= g_out != 0 ? g_out : g_max;
    end

endmodule
