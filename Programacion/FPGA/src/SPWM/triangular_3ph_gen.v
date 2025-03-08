module triangular_3ph #(parameter MODULE_ID = 0, parameter MAX_A = 128, parameter MAX_T = 4096) (
    input wire clk,
    input wire reset,
    output wire [$clog2(MAX_A)-1:0] value_a,
    output wire [$clog2(MAX_A)-1:0] value_b,
    output wire [$clog2(MAX_A)-1:0] value_c
);

    localparam PHASE_SHIFT_A =                  MAX_T * MODULE_ID / `NUM_OF_MODULES; // 120-degree phase shift + module phase shift
    localparam PHASE_SHIFT_B = MAX_T / 3     +  MAX_T * MODULE_ID / `NUM_OF_MODULES; // 120-degree phase shift + module phase shift
    localparam PHASE_SHIFT_C = 2 * MAX_T / 3 +  MAX_T * MODULE_ID / `NUM_OF_MODULES; // 120-degree phase shift + module phase shift

    // First triangular wave (phase A)
    triangular_gen #(.INITIAL_T(PHASE_SHIFT_A), .MAX_A(MAX_A), .MAX_T(MAX_T)) triangular_A (
        .clk(clk),
        .reset(reset),
        .step(1'b1),
        .value(value_a)
    );

    // Second triangular wave (phase B), phase-shifted by 120 degrees
    triangular_gen #(.INITIAL_T(PHASE_SHIFT_B), .MAX_A(MAX_A), .MAX_T(MAX_T)) triangular_B (
        .clk(clk),
        .reset(reset),
        .step(1'b1),
        .value(value_b)
    );

    // Third triangular wave (phase C), phase-shifted by 240 degrees
    triangular_gen #(.INITIAL_T(PHASE_SHIFT_C), .MAX_A(MAX_A), .MAX_T(MAX_T)) triangular_C (
        .clk(clk),
        .reset(reset),
        .step(1'b1),
        .value(value_c)
    );

endmodule
