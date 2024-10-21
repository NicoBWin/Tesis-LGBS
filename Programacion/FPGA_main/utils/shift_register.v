module shift_registers_piso (
    input clk,                // Clock signal
    input enable,              // Clock enable signal
    input load,               // Parallel load enable
    input [WIDTH-1:0] PI,     // Parallel input data
    output SO                 // Serial output
);
    parameter WIDTH = 32;      // Shift register width

    reg [WIDTH-1:0] shreg;     // Shift register storage

    always @(posedge clk) begin
        if (enable) begin
            if (load) 
                shreg = PI;    // Load parallel data into shift register
            else
                shreg = {shreg[WIDTH-2:0], 1'b0};  // Shift right, serial out
        end
    end

    assign SO = shreg[WIDTH-1]; // Serial output (MSB of the shift register)

endmodule