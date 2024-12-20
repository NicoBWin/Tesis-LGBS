
module hamming_7_4_encoder (
    input wire [3:0] data_in,    // 4-bit input data
    output wire [6:0] hamming_out // 7-bit Hamming code output
);
    // Hamming code format: P1, P2, D1, P3, D2, D3, D4
    assign hamming_out[0] = data_in[0] ^ data_in[1] ^ data_in[3]; // P1
    assign hamming_out[1] = data_in[0] ^ data_in[2] ^ data_in[3]; // P2
    assign hamming_out[2] = data_in[0];                           // D1
    assign hamming_out[3] = data_in[1] ^ data_in[2] ^ data_in[3]; // P3
    assign hamming_out[4] = data_in[1];                           // D2
    assign hamming_out[5] = data_in[2];                           // D3
    assign hamming_out[6] = data_in[3];                           // D4

endmodule