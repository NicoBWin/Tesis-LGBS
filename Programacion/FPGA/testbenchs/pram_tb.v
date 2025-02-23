`timescale 1ns / 1ps

module pram_tb;

    // Inputs
    reg [15:0] address;
    wire [7:0] data;

    // Instantiate the PRAM module
    PRAM uut (
        .address(address),
        .data(data)
    );

    initial begin
        // Initialize inputs
        address = 0;

        // Wait for the memory to be initialized
        #10;

        // Read and display data from different addresses
        address = 16'h0000;
        #10;
        $display("Address: %h, Data: %h", address, data);

        address = 16'h0001;
        #10;
        $display("Address: %h, Data: %h", address, data);

        address = 16'h0002;
        #10;
        $display("Address: %h, Data: %h", address, data);

        address = 16'h0003;
        #10;
        $display("Address: %h, Data: %h", address, data);

        address = 16'h0004;
        #10;
        $display("Address: %h, Data: %h", address, data);

        // Finish simulation
        $finish;
    end

endmodule