

module tb_hamming_7_4;
    reg [3:0] data_in;
    wire [6:0] hamming_out;

    hamming_7_4_encoder uut (
        .data_in(data_in),
        .hamming_out(hamming_out)
    );

    initial begin
        // Test cases
        data_in = 4'b0000; #10;
        $display("Input: %b, Output: %b", data_in, hamming_out);

        data_in = 4'b1101; #10;
        $display("Input: %b, Output: %b", data_in, hamming_out);

        data_in = 4'b1010; #10;
        $display("Input: %b, Output: %b", data_in, hamming_out);

        data_in = 4'b0111; #10;
        $display("Input: %b, Output: %b", data_in, hamming_out);

        $finish;
    end
endmodule