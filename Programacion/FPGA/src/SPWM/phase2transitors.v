module phase2transitors (
    input wire shoot,
    input  wire [2:0] in,   // 3-bit input
    output reg [5:0] out   // 6-bit output
);

    wire d1, d2, d3, d4, d5, d6, d7, d8;
    wire [5:0] out_next;

    // One-hot encoding (decoder)
    assign d1 = ~in[2] & ~in[1] & ~in[0];  // 000
    assign d2 = ~in[2] & ~in[1] &  in[0];  // 001
    assign d3 = ~in[2] &  in[1] & ~in[0];  // 010
    assign d4 = ~in[2] &  in[1] &  in[0];  // 011
    assign d5 =  in[2] & ~in[1] & ~in[0];  // 100
    assign d6 =  in[2] & ~in[1] &  in[0];  // 101
    assign d7 =  in[2] &  in[1] & ~in[0];  // 110
    assign d8 =  in[2] &  in[1] &  in[0];  // 111

    // Logic operations to construct 6-bit output
    assign out_next[5] = d5 | d6;
    assign out_next[4] = d3 | d7;
    assign out_next[3] = d2 | d4;
    assign out_next[2] = d3 | d4;
    assign out_next[1] = d2 | d6;
    assign out_next[0] = d5 | d7;

    always @(posedge shoot) begin
        out <= out_next;
    end

endmodule