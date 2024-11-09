
`include "../src/UART/baudgen.vh"

/*
    Recibe un codigo (cual disparar, 6 cod) y recibe un pulso de disparo. Cada 1 segundo,
    envia una señal de lectura al ADC y devuelve lo leido al main por UART que lo 
    refleja en 12 pines del main.
*/

module top(
    input wire gpio_23,
    input wire gpio_25,

    input wire gpio_42,
    input wire gpio_38,
    input wire gpio_28,

    output wire gpio_10,

    output wire gpio_12,
    output wire gpio_21,
    output wire gpio_13,

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

    assign tx = gpio_42;
    assign rx = gpio_38;
    assign shoot = gpio_28;

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

    // UART
    reg start_tx;
    reg [7:0] data_to_tx;
    wire [7:0] data_received;
    wire tx_busy;
    wire rx_done;
    wire parity_error;

    // ADC
    reg read_adc = 0;
    reg recalibrate = 0;
    wire [11:0] adc_value_1;
    wire [11:0] adc_value_2;

    
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

    ADC adc_1(
        .clk(clk),            
        .reset(reset),
        .read(read_adc),
        .recalibrate(recalibrate),
        .sdo(sdo_1),
        .cs(cs_1),
        .sclk(sclk_1),
        .value(adc_value_1)
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

    parameter INIT  = 3'b000; 
    parameter IDLE = 3'b001;
    parameter TX = 3'b010;
    parameter SEND_ACK = 3'b011;
    parameter CHECK = 3'b100;
    parameter SEND_BACK = 3'b101;
    parameter WAITING = 3'b110;
    parameter  = 3'b110;

    localparam READ_ADC = 8'b10011011;
    localparam ACK = 8'b00110011;

    reg[2:0] state = INIT;

    always @(posedge clk) begin
        case (state)
            INIT: begin
                reset   <= 1;
                counter <= counter + 1;

                // 1 sec
                if (counter >= 48000000) begin
                    reset <= 0;
                    counter <= 0;
                    state <= IDLE;
                    led_g <= ON;
                end
            end

            IDLE: begin

                if(rx_done)
                    if(data_received == ACK) begin
                        data_to_tx <= ACK;
                        start_tx <= 1;
                        led_g <= OFF;
                        led_b <= ON;
                        state <= WAITING;
                    end
            end

            WAITING: begin
                
                if(data_received == READ_ADC) begin
                    read_adc <= 1;
                    led_b <= OFF;
                    state <= SEND_BACK;
                end
            end

            SEND_BACK: begin
                
                //Si termino la comunicacion con el ADC
                if(cs_1 == 1) begin

                end
            end



        endcase
    end

endmodule