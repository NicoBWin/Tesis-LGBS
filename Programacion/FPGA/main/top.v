/*
    Este module se encarga de generar las señales de SPWM que se enviaran 
    a cada uno de los submodulos FPGA_modulo. Tambien enviara la señal de disparo para
    sincronizarlos.  
*/

`include "UART/baudgen.vh"

module top(
    input wire gpio_25,

    output wire led_green,
    output wire led_red,
    output wire led_blue,
    output wire gpio_23,
    output wire gpio_26,
    output wire gpio_27,
    output wire gpio_32,
    output wire gpio_34,

    //Error counter (5 bits)
    output wire gpio_43,
    output wire gpio_36,
    output wire gpio_42,
    output wire gpio_38,
    output wire gpio_28
);

/*
*******************
*   Ports setup   *
*******************
*/

    wire tx;
    wire rx;
    wire phase_a;
    wire phase_b;
    wire phase_c;
    
    assign tx = gpio_23;
    assign rx = gpio_25;
    assign phase_a = gpio_27;
    assign phase_b = gpio_32;
    assign phase_c = gpio_34;
/*
*********************
*   HFClock setup   *
*********************
*/  
    wire clk;
    SB_HFOSC  #(.CLKHF_DIV("0b00") // 48 MHz / div (0b00=1, 0b01=2, 0b10=4, 0b11=8)
    )
    hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));

/*
*****************************
*   Variables declaration   *
*****************************
*/  
    localparam turn_on = 8'b11101110;
    localparam turn_off = 8'b01010101;
    localparam toggle = 8'b11000011;
    localparam OFF = 1;
    localparam ON = 0;

    wire [7:0] data_received;
    wire tx_busy;
    wire rx_done;
    wire parity_error;

    reg start_tx;
    reg [7:0] data_to_tx = turn_on;
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

    defparam transmitter.BAUD_RATE = `BAUD24M;
    defparam receiver.BAUD_RATE = `BAUD24M;

/*
******************
*   Statements   *
******************
*/

    parameter INIT  = 3'b001; 
    parameter UART_SEND = 3'b010;
    parameter WAIT = 3'b011;  

    reg led_r = OFF;
    reg led_g = OFF;
    reg led_b = OFF;
    reg[2:0] state = INIT;
    reg[31:0] counter = 0;
    reg[5:0] error_counter = 0;

    assign led_red = led_r;
    assign led_green = led_g;
    assign led_blue = led_b;

    assign gpio_43 = error_counter[0];
    assign gpio_36 = error_counter[1];
    assign gpio_42 = error_counter[2];
    assign gpio_38 = error_counter[3];
    assign gpio_28 = error_counter[4];

    always @(posedge clk) begin
        case (state)
            INIT: begin
                reset   <= 1;
                led_r   <= OFF;
                led_g   <= OFF;
                led_b   <= OFF;
                counter <= counter + 1;
                error_counter <= 0;
                if (counter >= 24000000) begin
                    reset <= 0;
                    state <= UART_SEND;
                    counter <= 0;
                end
            end

            UART_SEND: begin
                start_tx <= 1;
                counter <= counter + 1;

                if (rx_done)
                    if (data_received == data_to_tx) begin
                        led_r <= ON;
                        led_b <= OFF;
                    end
                    else begin
                        error_counter <= error_counter + 1;
                        led_r <= OFF;
                        led_b <= ON;
                    end
                
                if (counter >= 96000000) begin
                    state <= WAIT;
                    counter <= 0;
                end
            end

            WAIT: begin
                led_b   <= OFF;
                start_tx <= 0;
                counter <= counter + 1;
                if (counter >= 48000000) begin
                    state <= UART_SEND;
                    counter <= 0;
                end
            end
        endcase
    end

endmodule