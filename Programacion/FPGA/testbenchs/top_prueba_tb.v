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
    wire[7:0] data_received;
    wire rx_done;
    wire parity_error;

    reg[7:0] data_to_tx;
    reg start_tx;
    wire tx;
    wire tx_busy;

    wire phase_a;
    wire phase_b;
    wire phase_c;
/*
*************************************
*   External Modules declarations   *
*************************************
*/
    uart_tx transmitter(
        .clk(clk),  
        .data_to_tx(data_to_tx), 
        .start_tx(start_tx), 
        .tx(tx)
    );

    uart_rx receiver(
        .clk(clk), 
        .rx(tx),
        .data_received(data_received), 
        .rx_done(rx_done), 
        .parity_error(parity_error)
    );

/*
********************************
*   Initial simulation setup   *
********************************
*/
initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);   // module to dump

        //Transmit
        reset <= 1; 
        #10
        reset <= 0;
        #10
        data_to_tx <= 8'b10110011; //B2
        start_tx <= 1;
        #500
        start_tx <= 0;

        #1500

        data_to_tx <= 8'b00010010; //12
        #100
        start_tx <= 1;

        #500
        
        $finish;
    end
/*
************************
*   Other statements   *
************************
*/
endmodule