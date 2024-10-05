/*
    Este module se encarga de generar las señales de SPWM que se enviaran 
    a cada uno de los submodulos FPGA_modulo. Tambien enviara la señal de disparo para
    sincronizarlos.  
*/

module top(
    input wire gpio_23,

    output wire led_green,
    output wire gpio_25,
    output wire gpio_26,
    output wire gpio_27,
    output wire gpio_32
);

/*
*******************
*   Ports setup   *
*******************
*/

    wire tx;
    wire rx;
    wire tx_busy;
    wire rx_done;
    wire parity_error;
    
    assign tx = gpio_23;
    assign rx = gpio_25;
    assign tx_busy = gpio_26;
    assign rx_done = gpio_27;
    assign parity_error = gpio_32;
/*
*********************
*   HFClock setup   *
*********************
*/  
    wire clk;
    SB_HFOSC  #(.CLKHF_DIV("0b11") // 6 MHz = ~48 MHz / 8 (0b00=1, 0b01=2, 0b10=4, 0b11=8)
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

    wire [7:0] data_received;
    reg [7:0] data_to_tx = toggle;

    reg reset = 0;
    wire start_tx;
    assign start_tx = 1;

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

    reg led;
    reg[31:0] counter = 0;
    assign led_green = led; 

    always @(posedge clk) begin

        if (counter == 0)
            reset <= 1;
        else if(counter == 5)
            reset <= 0;

        if (rx_done) begin
            if (data_received == toggle)
                if (counter >= 12000000)
                    begin
                        if (led == OFF)
                            led <= ON;
                        else
                            led <= OFF;

                        counter <= 0;
                    end
                    
                else
                    counter <= counter + 1;
        end
    end

endmodule