/*
    Este module se encarga de generar las señales de SPWM que se enviaran 
    a cada uno de los submodulos FPGA_modulo. Tambien enviara la señal de disparo para
    sincronizarlos.  
*/

module FPGA_main (
    input wire rx,
    output wire tx,
    output wire tx_busy,
    output wire rx_done,
    output wire parity_error
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
    SB_HFOSC  #(.CLKHF_DIV("0b10") // 12 MHz = ~48 MHz / 4 (0b00=1, 0b01=2, 0b10=4, 0b11=8)
    )  
    hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));

/*
*****************************
*   Variables declaration   *
*****************************
*/  
    localparam turn_on = 8'b10101010;
    localparam turn_off = 8'b01010101;
    localparam toggle = 8'b11000011;
    localparam OFF = 1;
    localparam ON = 0;

    wire reset = 0;   
    wire [7:0] data_received = 8'b0;
    wire [7:0] data_to_tx = toggle;
    wire start_tx = 1;

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
******************
*   Statements   *
******************
*/

    always @(posedge clk) begin
        if (!rx_done) begin
            data_to_tx <= toggle;
        end
    end

endmodule