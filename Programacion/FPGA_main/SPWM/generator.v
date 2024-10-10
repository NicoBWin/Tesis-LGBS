

module generator #(parameter SIGNAL_SAMPLE_BITS = 32)(
    input wire clk,                                     // Clock signal
    input wire reset,                                   // Reset signal
    input wire [SIGNAL_SAMPLE_BITS-1:0] signal,          // signal to reproduce
    input wire [19:0] frecuency,                         // Signal frequency (max: 1MHz)

    output reg[SIGNAL_SAMPLE_BITS-1:0] current_value    // Current signal value
);

    // Config
    parameter signal_sample_size = (2 << SIGNAL_SAMPLE_BITS) - 1;
    reg [SIGNAL_SAMPLE_BITS-1:0] clks_per_sample = signal_sample_size / frecuency

    reg [SIGNAL_SAMPLE_BITS-1:0] signal_index = 0;
    reg [SIGNAL_SAMPLE_BITS-1:0] clks_counter = 0;
    
    always @(posedge clk or posedge reset) 
        begin
            if (reset) 
            begin
                signal_index <= 0;
                clks_counter <= 0;
            end
        
        if (clks_counter >= clks_per_sample) 
        begin
            current_value <= signal[signal_index];
            if (signal_index + 1 > signal_sample_size) begin
                signal_index <= 0;
            end
            else
                signal_index <= signal_index + 1;
        end
        else
            clks_counter = clks_counter + 1;

        end

endmodule
