/*
    Este module se encarga de generar las señales de SPWM que se enviaran 
    a cada uno de los submodulos FPGA_modulo. Tambien enviara la señal de disparo para
    sincronizarlos.  
*/

`include "./src/UART/UART.vh"

module top(
    input wire gpio_23,
    output wire gpio_25,
    output wire gpio_10,

    output wire led_red,
    output wire led_green,
    output wire led_blue,

    output wire gpio_34,
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
    wire shoot;

    assign tx = gpio_10;
    assign rx = gpio_23;
    assign shoot = gpio_25;
/*
*********************
*   HFClock setup   *
*********************
*/  
    wire clk;
    SB_HFOSC  #(.CLKHF_DIV("0b01") // 48 MHz / div (0b00=1, 0b01=2, 0b10=4, 0b11=8)
    )
    hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));

/*
*****************************
*   Variables declaration   *
*****************************
*/  
    localparam turn_on = 4'b0110; //6
    localparam turn_off = 4'b1101; //D
    localparam toggle = 8'b10011101; //9D
    localparam ack = 8'b00111100; //3C
    localparam OFF = 1;
    localparam ON = 0;

    wire [7:0] data_received;
    wire tx_busy;
    wire rx_done;

    reg start_tx;
    //reg [3:0] code;
    //wire [6:0] hamm_code;
    reg [7:0] data_to_tx = 0; //toggle; //= {1'b1, hamm_code};
    reg reset = 0;
    wire parity_error;
    
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
    hamming_7_4_encoder hamm74(
        .data_in(code),
        .hamming_out(hamm_code)
    );
    */

    defparam transmitter.PARITY = 0;
    defparam receiver.PARITY = 0;

    defparam transmitter.BAUD_RATE = `BAUD1M_CLK24M;
    defparam receiver.BAUD_RATE = `BAUD1M_CLK24M;

    /*
        Comentarios:

            Sin las placas del circuito
             - A 1MHz o menos anda bien.
             - A 3MHz anda pero con errores de partidad segun la digilent.
             - A 6MHz anda con aun mas errores.
    */

/*
******************
*   Statements   *
******************
*/

    parameter INIT  = 3'b001; 
    parameter UART_SEND_ON = 3'b010;
    parameter START_TX = 3'b110;
    parameter WAIT = 3'b011;
    parameter CHECK_ERROR = 3'b000;
    parameter UPDATE_TX_DATA = 3'b111;

    parameter WAITING_DELAY = 364; //@24MHz, 1Mb/s, 364 es el tope minimo del delay

    reg led_r = OFF;
    reg led_g = OFF;
    reg led_b = OFF;
    reg[2:0] state = INIT;
    reg[31:0] counter = 0;

    reg[9:0] cycle_done = 0;
    reg error_pin;


    assign led_red = led_r;
    assign led_green = led_g;
    assign led_blue = led_b;

    //assign gpio_34 = data_received[5];
    //assign rx = gpio_34;
    wire error_pin = gpio_34;
    // assign gpio_43 = data_received[4];
    assign rx = gpio_43;
    // assign gpio_36 = data_received[3];
    assign gpio_36 = parity_error;
    assign gpio_42 = data_received[2];
    assign gpio_38 = data_received[1];
    assign gpio_28 = data_received[0];


/*
*************************************
*        Tasks declarations         *
*************************************
*/


/*
******************
*      Main      *
******************
*/

    always @(posedge clk) begin
        case (state)
            INIT: begin
                if (counter >= 48000000) begin
                    // Reset all values and transition to UART_SEND_ON state
                    reset <= 0;
                    state <= START_TX;
                    led_b <= ON;
                    tx_done <= 0;
                    data_to_tx <= 0;
                    counter <= 0; // Reset the counter at the same time
                end
                else begin
                    // Continue incrementing counter and setting LED values
                    reset <= 1;
                    led_r <= OFF;
                    led_g <= OFF;
                    led_b <= OFF;
                    counter <= counter + 1;
                end
            end

            START_TX: begin
                start_tx <= 1;
                cycle_done <= 0;    //reset message delay counter
                if (tx_busy) begin  //wait til it starts sending to change state
                    state <= WAIT;
                end
            end
            
            WAIT: begin
                start_tx <= 0;
                error_pin <= 0;
                if (!tx_busy) begin
                    state <= UART_SEND_ON;
                end
            end

            UART_SEND_ON: begin
                cycle_done <= cycle_done + 1;   //I give the receiver a delay to check the message
                if (cycle_done >= WAITING_DELAY) begin
                    state <= CHECK_ERROR;
                end
            end

            CHECK_ERROR: begin
                if (data_received != data_to_tx) begin
                    error_pin <= 1;
                end
                state <= UPDATE_TX_DATA;
            end

            UPDATE_TX_DATA: begin
                data_to_tx <= data_to_tx + 1;
                state <= START_TX;
            end

        endcase
    end

endmodule