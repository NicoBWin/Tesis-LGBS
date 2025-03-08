module PRAM (
    input wire [11:0] address, // 12-bit address line
    output reg [6:0] sine_A,     // 7-bit data output
    output reg [6:0] sine_B,     // 7-bit data output
    output reg [6:0] sine_C     // 7-bit data output
);

    // Declare the RAM content
    reg [6:0] memory [(`SIN_SIZE - 1):0];

    // Initialize the RAM with data
    initial begin
        $readmemh("./src/PRAM/sine_wave.hex", memory); // Load data from a hex file
    end

    // Read operation
    always @(address) begin
        sine_A <= memory[address];
        sine_B <= memory[address + `SIN_SIZE / 3];
        sine_C <= memory[address + 2 * `SIN_SIZE / 3];
    end

endmodule