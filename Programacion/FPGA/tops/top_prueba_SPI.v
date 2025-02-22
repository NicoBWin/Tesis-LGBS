`include "./src/SPI/SPI.vh"

module top(

    output wire led_red,
    output wire led_green,
    output wire led_blue,

    output wire gpio_43,

    // SPI
    input wire gpio_36,
    output wire gpio_42,
    output wire gpio_38,
    output wire gpio_28,

    output wire gpio_3,
    output wire gpio_48,
    output wire gpio_45,
    output wire gpio_47,
    output wire gpio_46,
    output wire gpio_2
);

/*
*******************
*   Ports setup   *
*******************
*/

    assign led_red = led_r;
    assign led_green = led_g;
    assign led_blue = led_b;
    
    assign gpio_43 = error_pin;
    
    assign gpio_36 = miso;
    assign gpio_42 = mosi;
    assign gpio_38 = sclk;
    assign gpio_28 = cs;  //IZQ

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
    parameter ON = 0;
    parameter OFF = 1;

    reg reset = 0;
    reg start_transfer;
    reg [15:0] data_to_tx = 25;
    wire [15:0] data_rx;
    wire transfer_done, transfer_busy;
    wire sclk;
    wire mosi;
    wire miso;
    wire cs;

/*
*************************************
*   External Modules declarations   *
*************************************
*/

    SPI spi_i (
        .clk(clk),
        .reset(reset),
        .start_transfer(start_transfer),
        .data_to_tx(data_to_tx),
        .data_rx(data_rx),
        .transfer_done(transfer_done),
        .transfer_busy(transfer_busy),  
        .sclk(sclk),
        .miso(miso),
        .mosi(mosi),
        .cs(cs)
    );

    defparam spi_i.COMM_RATE = `RATE6M_CLK24M;

/*
******************
*   Statements   *
******************
*/

    parameter INIT  = 3'b001; 
    parameter TRANSF_PREP = 3'b010;
    parameter TRANSF = 3'b011;  
    parameter TRANSF_RESET = 3'b000;
    parameter TRANSF_DONE = 3'b111;

    reg led_r = OFF;
    reg led_g = OFF;
    reg led_b = OFF;
    reg [2:0] state = INIT;
    reg [31:0] counter = 0;

    reg [10:0] delay_time = 0;
    reg error_pin = 0;

    assign gpio_3 = data_rx[0];
    assign gpio_48 = data_rx[1];
    assign gpio_45 = data_rx[2];
    assign gpio_47 = data_rx[3];
    assign gpio_46 = data_rx[4];
    assign gpio_2 = data_rx[5];

/*
******************
*      Main      *
******************
*/

    always @(posedge clk) begin
        case (state)
            INIT: begin
                if (counter >= 480) begin
                    reset <= 0;
                    state <= TRANSF;
                    start_transfer <= 1;
                    led_b <= ON;
                    counter <= 0; // Reset the counter at the same time
                end
                else begin
                    reset <= 1;
                    start_transfer <= 0;
                    led_r <= OFF;
                    led_g <= OFF;
                    led_b <= OFF;
                    counter <= counter + 1;
                end
            end

            TRANSF: begin
                if (transfer_done) begin
                    state <= TRANSF_DONE;
                    start_transfer <= 0;
                end
            end

            TRANSF_DONE: begin
                state <= TRANSF_RESET;
            end

            TRANSF_RESET: begin
                start_transfer <= 1;
                if (transfer_busy) begin
                    state <= TRANSF;
                end
            end
        endcase
    end

endmodule
