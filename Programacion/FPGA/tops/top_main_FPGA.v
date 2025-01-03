
`include "../src/UART/UART.vh"
`include "../src/SPI/SPI.vh"

/*
    Recibe por los 2 SPIs los valores de las 3 señales. Manda por UART que 
    transistores prender de cada modulo y envia al final un pulso de shoot.
*/

module top(

    //UART
    input wire gpio_23,
    output wire gpio_10,
    

    //Signal
    input wire gpio_12,
    input wire gpio_21,

    //LEDs
    output wire led_red,
    output wire led_green,
    output wire led_blue,

    //Shoot
    output wire gpio_25
);

/*
*****************************
*   Variables declaration   *
*****************************
*/  
    localparam OFF = 1;
    localparam ON = 0;

/*
*******************
*   Ports setup   *
*******************
*/
    wire tx = gpio_10;
    wire rx = gpio_23;
    wire shoot = gpio_25;
    reg led_r = OFF;
    reg led_g = OFF;
    reg led_b = OFF;
    
    assign led_red = led_r;
    assign led_green = led_g;
    assign led_blue = led_b;
/*
*********************
*   HFClock setup   *
*********************
*/  
    wire clk;
    SB_HFOSC  #(.CLKHF_DIV("0b00") // 48 MHz / div (0b00=1, 0b01=2, 0b10=4, 0b11=8)
    )
    hf_osc (.CLKHFPU(1'b1), .CLKHFEN(1'b1), .CLKHF(clk));


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