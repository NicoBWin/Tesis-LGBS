/*
    Este module se encarga de generar las señales de SPWM que se enviaran 
    a cada uno de los submodulos FPGA_modulo. Tambien enviara la señal de disparo para
    sincronizarlos.  
*/

module FPGA_main (
    
);
/*
*******************
*   Ports setup   *
*******************
*/

/*
*********************
*   HFClock setup   *
*********************
*/
    wire clk;
    SB_HFOSC  #(
    .CLKHF_DIV("0b10")  // 12 MHz = ~48 MHz / 4 (0b00=1, 0b01=2, 0b10=4, 0b11=8)
    ) hf_osc (.CLKHFPU(1'b1),
    .CLKHFEN(1'b1), .CLKHF(clk));

/*
*****************************
*   Variables declaration   *
*****************************
*/


/*
*************************************
*   External Modules declarations   *
*************************************
*/

    //Nuestro codigo va aca

/*
******************
*   Statements   *
******************
*/

endmodule