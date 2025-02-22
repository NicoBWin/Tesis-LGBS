`timescale 10ns/10ns

module SPI_tb;

    /*
    *******************
    *   Clock setup   *
    *******************
    */
    reg clk = 0;
    always #1 clk = ~clk;

    /*
    *****************************
    *   Variable declarations   *
    *****************************
    */
    reg reset;
    reg start_transfer;
    reg [15:0] data_to_tx;
    wire [15:0] data_rx;
    wire sclk;
    wire cs;
    wire mosi;

    /*
    *************************************
    *   External Modules declarations   *
    *************************************
    */
    SPI spi_instance (
        .clk(clk),
        .reset(reset),
        .start_transfer(start_transfer),
        .data_to_tx(data_to_tx),
        .data_rx(data_rx),
        .sclk(sclk),
        .miso(mosi),
        .mosi(mosi),
        .cs(cs)
    );

    /*
    ********************************
    *   Initial simulation setup   *
    ********************************
    */
    initial begin
        $dumpfile("SPI_tb.vcd");
        $dumpvars(0, SPI_tb);

        // Initialize signals
        reset <= 1;
        start_transfer <= 0;
        data_to_tx <= 16'h0000;

        #10 reset <= 0;  // Release reset

        // Test case 1: Send and receive data
        data_to_tx <= 16'hA5A5;  // Transmit pattern 10100101 
        start_transfer <= 1;
        #20
        start_transfer <= 0;

        #829

        data_to_tx <= 16'h1234;
        start_transfer <= 1;
        #37
        start_transfer <= 0;

        #799
        $finish;
    end

    /*
    ************************
    *   Monitoring output  *
    ************************
    */
    always @(negedge sclk) begin
        $display("Time=%0t | MOSI=%b | MISO=%b | Received Data=%h", $time, mosi, mosi, data_rx);
    end

endmodule
