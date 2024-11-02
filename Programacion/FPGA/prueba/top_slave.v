
`include "UART/baudgen.vh"

/*
    Recibe un codigo (cual disparar, 6 cod) y recibe un pulso de disparo. Cada 1 segundo,
    envia una señal de lectura al ADC y devuelve lo leido al main por UART que lo 
    refleja en 12 pines del main.
*/

module top_slave(
    input wire gpio_23,
    input wire gpio_25,

    input wire gpio_34;
    input wire gpio_43;
    input wire gpio_36;
    input wire gpio_42;
    input wire gpio_38;
    input wire gpio_28;

    output wire gpio_10;

    output wire gpio_12;
    output wire gpio_21;
    output wire gpio_13;

    output wire gpio_47;
    output wire gpio_46;
    output wire gpio_2;
);

/*
*******************
*   Ports setup   *
*******************
*/

    wire tx;
    wire rx;
    wire shoot;
    wire phase_a_top;
    wire phase_b_top;
    wire phase_c_top;
    wire phase_a_down;
    wire phase_b_down;
    wire phase_c_down;

    wire cs_1;
    wire sdo_1;
    wire sclk_1;
    wire cs_2;
    wire sdo_2;
    wire sclk_2;
    
    assign tx = gpio_10;
    assign rx = gpio_23;
    assign shoot = gpio_25;

    assign phase_a_top = gpio_34;
    assign phase_b_top = gpio_43;
    assign phase_c_top = gpio_36;
    assign phase_a_down = gpio_42;
    assign phase_b_down = gpio_38;
    assign phase_c_down = gpio_28;

    assign gpio_12 = cs_1;
    assign gpio_21 = sdo_1;
    assign gpio_13 = sclk_1;
    assign gpio_47 = cs_2;
    assign gpio_46 = sdo_2;
    assign gpio_2 = sclk_2;
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
    reg [11:0] adc_value_1;
    reg [11:0] adc_value_2;

    
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

    ADC adc_2(
        .clk(clk),            
        .reset(reset),
        .read(read_adc),
        .recalibrate(recalibrate),
        .sdo(sdo_2),
        .cs(cs_2),
        .sclk(sclk_2),
        .value(adc_value_2)
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
    parameter READ = 3'b011;
    parameter TX = 3'b100; 

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
                    read_adc <= 1;
                    led_g <= ON;
                end
            end

            IDLE: begin
                // Termino la lectura
                if(cs_1 == 1) begin
                    data_to_tx <= adc_value_1[11:4];
                    start_tx <= 1;
                    led_g <= OFF;
                    led_b <= ON;
                end
            end

            TX: begin
                counter <= counter + 1;

                // 5 sec
                if (counter >= 48000000*5) begin
                    state <= INIT;
                    led_b <= OFF;
                end
            end

        endcase
    end

endmodule