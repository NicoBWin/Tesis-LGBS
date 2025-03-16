`timescale 1ns/1ns

module top_modulacion_tb;

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
    localparam STEP = 10;

    integer i;

    reg reset = 0;
    reg shoot = 0;
    reg [11:0] angle = 0;

    wire g1_a;   // Gate 1 of the phase A
    wire g2_a;   // Gate 2 of the phase A
    wire g1_b;   // Gate 1 of the phase B
    wire g2_b;   // Gate 2 of the phase B
    wire g1_c;   // Gate 1 of the phase C
    wire g2_c;   // Gate 2 of the phase C

/*
*************************************
*   External Modules declarations   *
*************************************
*/
    modulator #( .MODULE_ID(0) ) modulacion (
        .clk(clk),
        .reset(reset),
        .shoot(shoot),
        .angle(angle),
        .g1_a(g1_a),
        .g2_a(g2_a),
        .g1_b(g1_b),
        .g2_b(g2_b),
        .g1_c(g1_c),
        .g2_c(g2_c)
    );
/*
********************************
*   Initial simulation setup   *
********************************
*/
initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_modulacion_tb);   // module to dump

        //Transmit
        reset <= 1; 
        #10;
        reset <= 0;
        #10;

        // verificamos que no se muestre a la salida la modulacion a menos que se produzca el shoot
        angle <= 12'h999;
        #100;
        shoot <= 1;
        #100;
        shoot <= 0;
        
        // probamos recorer la tabla
        for (i = 0; i < 4095; i = i + STEP) begin
            angle <= i;
            shoot <= 1;
            #100;
            shoot <= 0;
            #100;
        end
        
        
        $finish;
    end
/*
************************
*   Other statements   *
************************
*/
endmodule