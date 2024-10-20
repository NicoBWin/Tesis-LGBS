/*
    Este module se encarga de generar las señales de SPWM que se enviaran 
    a cada uno de los submodulos FPGA_modulo. Tambien enviara la señal de disparo para
    sincronizarlos.  
*/

module top(
    input wire gpio_25,

    output wire led_green,
    output wire led_red,
    output wire led_blue,
    output wire gpio_23,
    output wire gpio_26,
    output wire gpio_27,
    output wire gpio_32,
    output wire gpio_34
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
    SB_HFOSC  #(.CLKHF_DIV("0b01") // 48 MHz / div (0b00=1, 0b01=2, 0b10=4, 0b11=8)
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
        .data_to_tx(data_to_tx), 
        .start_tx(start_tx), 
        .tx(tx), 
        .tx_busy(tx_busy)
    );

    uart_rx receiver(
        .clk(clk), 
        .rx(rx),
        .data_received(data_received), 
        .rx_done(rx_done), 
        .parity_error(parity_error)
    );

    phase_generator spwm_gen (
        .clk(clk),
        .reset(reset),
        .sine_freq(26'd24000),          // Set sine wave frequency to 10 kHz
        .triangular_freq(26'd240000),   // Set triangular wave frequency to 100 kHz
        .phase_a(phase_a),          // Connect phase_a output
        .phase_b(phase_b),          // Connect phase_b output
        .phase_c(phase_c)           // Connect phase_c output
    );

    defparam transmitter.CLK_FREQ = 24000000;
    defparam transmitter.BAUD_RATE = 8000000;
    defparam transmitter.PARITY = 0;

    defparam receiver.CLK_FREQ = 24000000;
    defparam receiver.BAUD_RATE = 8000000;
    defparam receiver.PARITY = 0;

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
                        counter <= 0;
                    end
                    else begin
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