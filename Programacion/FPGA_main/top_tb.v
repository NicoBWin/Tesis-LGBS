`timescale 1ns/1ns

module top_tb;

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
    reg rx;
    wire[7:0] data_received;
    wire rx_done;
    wire parity_error;

    reg[7:0] data_to_tx;
    reg start_tx;
    wire tx;
    wire tx_busy;
/*
*************************************
*   External Modules declarations   *
*************************************
*/
    uart_rx receiver(
        .clk(clk), 
        .reset(reset), 
        .rx(rx),
        .data_received(data_received), 
        .rx_done(rx_done), 
        .parity_error(parity_error)
    );

    uart_tx transmitter(
        .clk(clk), 
        .reset(reset), 
        .data_to_tx(data_to_tx), 
        .start_tx(start_tx), 
        .tx(tx), 
        .tx_busy(tx_busy)
    );
/*
********************************
*   Initial simulation setup   *
********************************
*/
initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);   // module to dump
        // Space for variable modification in simulation of module

        reset <= 1; 
        #10
        reset <= 0;
        #10
        data_to_tx <= 8'b01100110;
        start_tx <= 1;
        #100
        data_to_tx <= 8'b10101010;
        #24000000

        $finish;
    end
/*
************************
*   Other statements   *
************************
*/
endmodule