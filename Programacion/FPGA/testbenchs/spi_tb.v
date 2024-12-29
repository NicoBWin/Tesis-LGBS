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
    reg miso;
    wire [15:0] data_to_rx;
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
        .data_to_rx(data_to_rx),
        .sclk(sclk),
        .miso(miso),
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
        data_to_tx <= 16'h0;
        miso <= 0;

        #10 reset <= 0;  // Release reset

        // Test case 1: Send and receive data
        #5
        data_to_tx <= 16'hA5A5;  // Transmit pattern
        start_transfer <= 1;

        #5 start_transfer <= 0; // Deassert start_transfer

        // Simulate incoming MISO data
        repeat (16) begin
            #2 miso <= ~miso; // Toggle MISO value
        end

        #100
        $finish;
    end

    /*
    ************************
    *   Monitoring output  *
    ************************
    */
    always @(posedge sclk) begin
        $display("Time=%0t | MOSI=%b | MISO=%b | Received Data=%h", $time, mosi, miso, data_to_rx);
    end

endmodule
