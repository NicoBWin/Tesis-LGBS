

module generator #(parameter SIGNAL_SAMPLE_BITS = 8)(
    input wire clk,                                     // Clock signal
    input wire reset,                                   // Reset signal
    input wire [25:0] frecuency,                        // Signal frequency (max: 1MHz)
    input wire [2047:0] signal,                         // signal to reproduce
    input wire [SIGNAL_SAMPLE_BITS-1:0] initial_phase,

    output wire[SIGNAL_SAMPLE_BITS-1:0] current_value    // Current signal value
);

    // Config
    parameter CLK_FREQ = 24000000;
    parameter FIXED_POINT_SCALE = 65536;

    wire [47:0] scaled_sample_count = CLK_FREQ * FIXED_POINT_SCALE / (frecuency * 256);
    wire [31:0] next_sample_count = scaled_sample_count[47:16];     //Tomamos lo que vendria a ser la parte entera

    reg [SIGNAL_SAMPLE_BITS-1:0] signal_index;
    reg [31:0] clk_counter = 0;
    
    assign current_value = signal[(signal_index*8) +: 8];

    always @(posedge clk) begin
        if (reset) begin
            signal_index <= initial_phase;
            clk_counter <= 0;
        end
        else if (clk_counter >= next_sample_count) begin
            signal_index <= signal_index + 1;
            clk_counter <= 0;
        end
        else begin
            clk_counter <= clk_counter + 1;
        end
    end

endmodule
