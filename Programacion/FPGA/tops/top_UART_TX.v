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

    defparam transmitter.BAUD_RATE = `BAUD6M_CLK48M;
    defparam receiver.BAUD_RATE = `BAUD6M_CLK48M;



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

    reg tx_done = 0;

    assign led_red = led_r;
    assign led_green = led_g;
    assign led_blue = led_b;

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
                if (counter == 48000000) begin
                    // Reset all values and transition to UART_SEND_ON state
                    reset <= 0;
                    state <= WAIT;
                    data_to_tx <= 0;
                    start_tx <= 1;
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

            UART_SEND_ON: begin
                data_to_tx <= data_to_tx + 1;
                start_tx <= 1;
                state <= WAIT;
            end

            WAIT: begin
                
                // Verificamos si ya handleamos el evento de que termino la transmision
                if (!tx_busy && !tx_done) begin
                    tx_done <= 1;
                    state <= UART_SEND_ON;
                end
                else if(tx_busy) begin
                    tx_done <= 0;
                    start_tx <= 0;
                end
            end
        endcase
    end

endmodule
