module shift_registers_piso #(parameter WIDTH = 32) 
(
    input clk,                // Clock signal
    input enable,              // Clock enable signal
    input load,               // Parallel load enable
    input [WIDTH-1:0] PI,     // Parallel input data
    output SO                 // Serial output
);
    parameter FILL_VAL = 1'b1;      // Shift register width

    reg [WIDTH-1:0] shreg;     // Shift register storage

    always @(posedge clk) begin
        if (enable) begin
            if (load) 
                shreg = PI;    // Load parallel data into shift register
            else
                shreg = {FILL_VAL, shreg[WIDTH-2:0]};  // Shift right, serial out
        end
    end

    assign SO = shreg[0]; // Serial output (LSB of the shift register)

endmodule