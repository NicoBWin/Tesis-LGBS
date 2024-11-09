
`include "UART/baudgen.vh"

/*
    Recibe un codigo (cual disparar, 6 cod) y recibe un pulso de disparo. Cada 1 segundo,
    envia una señal de lectura al ADC y devuelve lo leido al main por UART que lo 
    refleja en 12 pines del main.
*/

module top_main(
    input wire gpio_23,
    input wire gpio_25,

    output wire gpio_10;
);

/*
*******************
*   Ports setup   *
*******************
*/

    wire tx;
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
    SB_HFOSC  #(.CLKHF_DIV("0b00") // 48 MHz / div (0b00=1, 0b01=2, 0b10=4, 0b11=8)
    )
    hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));

/*
*****************************
*   Variables declaration   *
*****************************
*/  
    // LEDs
    localparam OFF = 1;
    localparam ON = 0;
    reg led_r = OFF;
    reg led_g = OFF;
    reg led_b = OFF;
    assign led_red = led_r;
    assign led_green = led_g;
    assign led_blue = led_b;

    // General purpose
    reg reset = 0;
    reg[31:0] counter = 0;
    reg[11:0] adc_value = 0;
    reg local_counter = 0;

    // UART
    reg start_tx;
    reg [7:0] data_to_tx;
    wire [7:0] data_received;
    wire tx_busy;
    wire rx_done;
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

    defparam transmitter.PARITY = 0;
    defparam receiver.PARITY = 0;
    //defparam transmitter.BAUD_RATE = `BAUD24M;
    //defparam receiver.BAUD_RATE = `BAUD24M;

/*
******************
*   Statements   *
******************
*/

    parameter INIT  = 3'b001; 
    parameter IDLE = 3'b010;
    parameter TX = 3'b100;
    parameter REQ_ACK = 3'b101;
    parameter CHECK = 3'b011;

    localparam READ_ADC = 8'b10011011;
    localparam ACK = 8'b00110011;

    localparam TARGET_CURR = 12’h00F;

    reg[2:0] state = INIT;

    always @(posedge clk) begin
        case (state)
            INIT: begin
                reset   <= 1;
                counter <= counter + 1;

                // 2 sec
                if (counter >= 96000000) begin
                    reset <= 0;
                    counter <= 0;
                    state <= REQ_ACK;
                    data_to_tx <= ACK;
                    led_g <= ON;
                end
            end

            REQ_ACK: begin

                // Envio un mensaje de leer ADC
                start_tx <= 1;

                if (rx_done)
                    led_g <= OFF;
                    if(data_received == ACK) begin
                        led_b <= ON;
                        state <= TX;
                        start_tx <= 0;
                        data_to_tx <= READ_ADC; 
                    end
                    else begin
                        led_r <= ON;
                    end
            end

            TX: begin
                
                //Mandamos el codigo para recibir la lectura
                start_tx <= 1;

                if (rx_done)
                    if (local_counter == 0) begin
                        adc_value[7:0] <= data_received;
                        local_counter = local_counter + 1;
                    end
                    else begin
                        adc_value[11:8] <= data_received[3:0];
                        state <= CHECK;
                        led_b <= OFF;
                    end
            end

            CHECK: begin
                
                if (adc_value >= TARGET_CURR)
                    led_g <= ON;
                else
                    led_r <= ON;
            end

        endcase
    end

endmodule