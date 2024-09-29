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
    wire tx_pin = gpio_22;
    wire rx_pin = gpio_23;
/*
*********************
*   HFClock setup   *
*********************
*/
    SB_HFOSC  #(
    .CLKHF_DIV("0b10")  // 12 MHz = ~48 MHz / 4 (0b00=1, 0b01=2, 0b10=4, 0b11=8)
    ) hf_osc (.CLKHFPU(1'b1),
    .CLKHFEN(1'b1), .CLKHF(clk));

/*
*****************************
*   Variables declaration   *
*****************************
*/            
    reg reset = 0;   
    reg [7:0] data_in = 0;
    reg [7:0] data_out = 8'b10101100;
    reg start_tx = 1;

    wire tx_busy;
    wire rx_done;        // Indicates data reception is complete
    wire parity_error;   // Indicates a parity error occurred

/*
*************************************
*   External Modules declarations   *
*************************************
*/
    uart_tx transmitter(
        .clk(clk), 
        .reset(reset), 
        .data_in(data_in), 
        .start_tx(start_tx), 
        .tx(tx_pin), 
        .tx_busy(tx_busy)
    );

    uart_rx receiver(
        .clk(clk), 
        .reset(reset), 
        .rx(rx_pin),
        .data_out(data_out), 
        .rx_done(rx_done), 
        .parity_error(parity_error)
    );

/*
******************
*   Statements   *
******************
*/

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_in <= 8'b10101100; // Example data to transmit
            start_tx <= 0;
        end
        else if (rx_done) begin
            // Check received data
            if (data_out == data_in) begin
                // Handle successful reception
                // Here, you can toggle an LED or take other actions to indicate success
            end
            else if (parity_error) begin
                // Handle parity error
            end
            else begin
                // Handle reception mismatch
            end
            
            // Prepare data for the next transmission
            data_in <= data_out; // Echo the received data for the next transmission
            start_tx <= 1;       // Start transmission of the received data
        end
    end

endmodule