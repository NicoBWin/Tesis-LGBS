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
    localparam precision = 9;

    reg reset;

    wire[precision-1:0] sin_a;
    wire[precision-1:0] sin_b;
    wire[precision-1:0] sin_c;

    wire out_a;
    wire out_b;
    wire out_c;
/*
*************************************
*   External Modules declarations   *
*************************************
*/
    phase_generator #(parameter BITS_PRECISION = precision) gen(
        .clk(clk)
        .reset(reset)
        .phase_a_sin(sin_a),
        .phase_b_sine(sin_b),
        .phase_c_sine(sin_c),
        .phase_a_pwm(out_a),
        .phase_b_pwm(out_b),
        .phase_c_pwm(out_c)
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
        
        #5000
        
        $finish;
    end
/*
************************
*   Other statements   *
************************
*/
endmodule