module phase_generator #(parameter SIGNAL_SAMPLE_BITS = 8'd8)(
    input wire clk,                                    
    input wire reset,                                  
    input wire [25:0] sine_freq,
    input wire [25:0] triangular_freq,

    output reg phase_a,
    output reg phase_b,
    output reg phase_c
);

endmodule