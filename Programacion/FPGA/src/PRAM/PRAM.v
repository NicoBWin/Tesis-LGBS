module PRAM (
    input wire [15:0] address, // 16-bit address line
    output reg [7:0] data     // 8-bit data output
);

    // Declare the RAM content
    reg [7:0] memory [65535:0];

    // Initialize the RAM with data
    initial begin
        $readmemh("sine_wave.hex", memory); // Load data from a hex file
    end

    // Read operation
    always @(address) begin
        data <= memory[address];
    end

endmodule