`timescale 1ns/1ns

`include "./src/UART/baudgen.vh"

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
/*
*************************************
*   External Modules declarations   *
*************************************
*/
    uart_tx transmitter(
        .i_Clock(clk),
        //.reset(reset),
        .i_Tx_Byte(data_to_tx), 
        .i_Tx_DV(start_tx), 
        .o_Tx_Serial(tx), 
        .o_Tx_Active(tx_busy)
    );

    uart_rx receiver(
        .clk(clk),
        .reset(reset), 
        .rx(tx),
        .data_received(data_received), 
        .rx_done(rx_done), 
        .parity_error(parity_error)
    );

    //defparam transmitter.PARITY = 0;
    //defparam receiver.PARITY = 0;

    //defparam transmitter.BAUD_RATE = `BAUD6M_CLK24M;
    //defparam receiver.BAUD_RATE = `BAUD6M_CLK24M;

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
        data_to_tx <= 8'b10110011; //B3
        start_tx <= 1;
        #500

        data_to_tx <= 8'b00010010; //12
        #500

        data_to_tx <= 8'b00110011; //33
        #500

        data_to_tx <= 8'b10011111; //9F
        #500

        data_to_tx <= 8'b11111111; //FF
        #500

        data_to_tx <= 8'b00000000; //00
        #500
        
        $finish;
    end
/*
************************
*   Other statements   *
************************
*/
endmodule