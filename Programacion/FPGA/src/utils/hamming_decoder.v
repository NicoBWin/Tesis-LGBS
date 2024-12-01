
module hamming_7_4_decoder (
    input [6:0] hamming_in,  // 7-bit Hamming code input
    output [3:0] data_out,   // 4-bit decoded data
    output reg error_detected // Error detection flag
);
    wire [2:0] syndrome; // Syndrome bits for error detection
    reg [6:0] corrected_code; // Corrected codeword (if needed)

    // Compute syndrome
    assign syndrome[0] = hamming_in[0] ^ hamming_in[2] ^ hamming_in[4] ^ hamming_in[6]; // S1
    assign syndrome[1] = hamming_in[1] ^ hamming_in[2] ^ hamming_in[5] ^ hamming_in[6]; // S2
    assign syndrome[2] = hamming_in[3] ^ hamming_in[4] ^ hamming_in[5] ^ hamming_in[6]; // S3

    always @(*) 
    begin
        // Default corrected code is the input code
        corrected_code = hamming_in;
        error_detected = (syndrome != 3'b000); // Error if syndrome is non-zero

        // If error is detected, correct it
        if (error_detected) 
        begin
            case (syndrome)
                3'b001: corrected_code[0] = ~hamming_in[0]; // Bit 0 is flipped
                3'b010: corrected_code[1] = ~hamming_in[1]; // Bit 1 is flipped
                3'b011: corrected_code[2] = ~hamming_in[2]; // Bit 2 is flipped
                3'b100: corrected_code[3] = ~hamming_in[3]; // Bit 3 is flipped
                3'b101: corrected_code[4] = ~hamming_in[4]; // Bit 4 is flipped
                3'b110: corrected_code[5] = ~hamming_in[5]; // Bit 5 is flipped
                3'b111: corrected_code[6] = ~hamming_in[6]; // Bit 6 is flipped
            endcase
        end
    end

    // Extract the original data from the corrected code
    assign data_out = {corrected_code[6], corrected_code[5], corrected_code[4], corrected_code[2]};
endmodule