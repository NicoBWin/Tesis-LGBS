/*
    Este module se encarga de generar las señales de SPWM que se enviaran 
    a cada uno de los submodulos FPGA_modulo. Tambien enviara la señal de disparo para
    sincronizarlos.  
*/

`include "./src/UART/baudgen.vh"

module top(
    input wire gpio_23,
    input wire gpio_25,
    output wire gpio_10,

    output wire gpio_12,
    output wire gpio_21,
    output wire gpio_13,

    output wire led_red,
    output wire led_green,
    output wire led_blue,

    output wire gpio_47,
    output wire gpio_46,
    output wire gpio_2
);

/*
*******************
*   Ports setup   *
*******************
*/

    wire tx;
    wire rx;
    wire shoot;
    wire cs_1;
    wire sdo_1;
    wire sclk_1;

    assign tx = gpio_10;
    assign rx = gpio_23;
    assign shoot = gpio_25;

    assign cs_1 = gpio_12;
    assign sdo_1 = gpio_21;
    assign sclk_1 = gpio_13;
/*
*********************
*   HFClock setup   *
*********************
*/  
    wire clk;
    SB_HFOSC  #(.CLKHF_DIV("0b01") // 24 MHz / div (0b00=1, 0b01=2, 0b10=4, 0b11=8)
    )
    hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));

/*
*****************************
*   Variables declaration   *
*****************************
*/  
    localparam turn_on = 8'b01101110; //6E
    localparam turn_off = 8'b01010101; //55
    localparam toggle = 8'b11000011; 
    localparam ack = 8'b01101011;
    localparam OFF = 1;
    localparam ON = 0;

    wire [7:0] data_received;
    wire tx_busy;
    wire rx_done;

    reg start_tx;
    reg [7:0] data_to_tx;
    reg reset = 0;
    
/*
*************************************
*   External Modules declarations   *
*************************************
*/
    
    uart_tx transmitter(
        .clk(clk),
        .reset(reset),
        .data_to_tx(data_to_tx), 
        .start_tx(start_tx), 
        .tx(tx), 
        .tx_busy(tx_busy)
    );

    uart_rx receiver(
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .data_received(data_received), 
        .rx_done(rx_done), 
        .parity_error(parity_error)
    );

    defparam transmitter.PARITY = 0;
    defparam receiver.PARITY = 0;

    defparam transmitter.BAUD_RATE = `BAUD6M_CLK24M;
    defparam receiver.BAUD_RATE = `BAUD6M_CLK24M;

/*
******************
*   Statements   *
******************
*/

    parameter INIT  = 3'b001; 
    parameter UART_SEND_ON = 3'b010;
    parameter UART_SEND_OFF = 3'b111;
    parameter WAIT = 3'b011;  

    reg led_r = OFF;
    reg led_g = OFF;
    reg led_b = OFF;
    reg[2:0] state = INIT;
    reg[31:0] counter = 0;

    assign led_red = led_r;
    assign led_green = led_g;
    assign led_blue = led_b;

    always @(posedge clk) begin
        case (state)
            INIT: begin
                reset   <= 1;
                led_r   <= OFF;
                led_g   <= OFF;
                led_b   <= OFF;
                counter <= counter + 1;
                /*  
                    Los errores de TX se estan produciendo en la transicion
                    entre el cambio de data mientras start_tx es 1.
                */
                if (counter >= 24000000) begin
                    reset <= 0;
                    state <= UART_SEND_ON;
                    data_to_tx <= turn_on;
                    counter <= 0;
                end
            end

            UART_SEND_ON: begin
                start_tx <= 1;
                counter <= counter + 1;
                led_g <= ON;
                led_r <= OFF;
                data_to_tx <= turn_on;

                if (counter >= 48000000) begin
                    state <= UART_SEND_OFF;
                    start_tx <= 0;
                    data_to_tx <= turn_off;
                    counter <= 0;
                end
            end

            UART_SEND_OFF: begin
                start_tx <= 1;
                counter <= counter + 1;
                led_g <= OFF;
                led_r <= ON;
                data_to_tx <= turn_off;

                if (counter >= 48000000) begin
                    state <= UART_SEND_ON;
                    data_to_tx <= turn_on;
                    start_tx <= 0;
                    counter <= 0;
                end
            end
            
        endcase
    end

endmodule