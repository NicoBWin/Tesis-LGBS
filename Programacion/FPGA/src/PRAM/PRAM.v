module PRAM (
    input wire [11:0] address, // 12-bit address line
    output reg [6:0] data     // 7-bit data output
);

    // Declare the RAM content
    reg [6:0] memory [4095:0];

    // Initialize the RAM with data
    initial begin
        $readmemh("./src/PRAM/sine_wave.hex", memory); // Load data from a hex file
    end

    // Read operation
    always @(address) begin
        data <= memory[address];
    end

endmodule