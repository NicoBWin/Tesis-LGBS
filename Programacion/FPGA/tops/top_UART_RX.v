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
    SB_HFOSC  #(.CLKHF_DIV("0b00") // 48 MHz / div (0b00=1, 0b01=2, 0b10=4, 0b11=8)
    )
    hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));

/*
*****************************
*   Variables declaration   *
*****************************
*/  
    localparam turn_on = 8'b0110011; //6
    localparam turn_off = 8'b1100110; //D

    localparam toggle = 8'b1001101; //9D
    localparam ack = 8'b00111100; //3A
    localparam OFF = 1;
    localparam ON = 0;

    wire [7:0] data_received;
    wire [6:0] hamm_code = data_received[6:0];
    wire [3:0] code;
    wire hamming_error;
    wire tx_busy;
    wire rx_done;

    reg start_tx;
    reg [7:0] data_to_tx = 8'b0;
    reg reset = 1;
    
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

    /*
    hamming_7_4_decoder hamm74(
        .hamming_in(hamm_code),
        .data_out(code),                // 4-bit decoded data
        .error_detected(hamming_error)  // Error detection flag
    );
    */

    defparam transmitter.PARITY = 0;
    defparam receiver.PARITY = 0;

    defparam transmitter.BAUD_RATE = `BAUD6M_CLK48M;
    defparam receiver.BAUD_RATE = `BAUD6M_CLK48M;

/*
******************
*   Statements   *
******************
*/

    parameter INIT  = 3'b001; 
    parameter UART_RECEIVE = 3'b010;
    parameter CHECK = 3'b011;  

    reg led_r = OFF;
    reg led_g = OFF;
    reg led_b = OFF;
    reg[2:0] state = INIT;
    reg[31:0] counter = 0;

    assign led_red = led_r;
    assign led_green = led_g;
    assign led_blue = led_b;

    always @(posedge clk) begin
        if (reset) begin
            led_g <= OFF;
            led_r <= OFF;
            data_to_tx <= 0;
            reset <= 0;
            start_tx <= 0;
        end
        else begin
            if (rx_done) begin
                case (data_received)
                    toggle: begin
                        led_g <= OFF;
                        led_r <= ON;
                    end
                    ack: begin
                        led_g <= ON;
                        led_r <= OFF;
                    end
                    default: begin
                        data_to_tx <= data_to_tx + 1;
                        start_tx <= 1;
                        led_g <= OFF;
                        led_r <= OFF;
                    end
                endcase
            end
        end
    end

endmodule