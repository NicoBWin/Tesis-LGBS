`timescale 10ns/10ns

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
    reg read;
    reg recalibrate;
    reg sdo;
    
    wire cs;
    wire sclk;
    wire [11:0] value_read;
/*
*************************************
*   External Modules declarations   *
*************************************
*/
    ADC adc(
        .clk(clk),            
        .reset(reset),
        .read(read),
        .recalibrate(recalibrate),
        .sdo(sdo),
        .cs(cs),
        .sclk(sclk),
        .value(value_read)
    );

/*
********************************
*   Initial simulation setup   *
********************************
*/
initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);   // module to dump

        //Reseteamos el driver
        reset <= 1; 
        #10
        reset <= 0;

        

        #5000
        
        $finish;
    end
/*
************************
*   Other statements   *
************************
*/
endmodule