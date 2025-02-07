`include "./src/SPI/SPI.vh"

module top(

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

    wire inner_clk;

    reg reset = 0;
    reg start_transfer;
    reg [7:0] data_to_tx = 0;
    wire [7:0] data_rx;
    wire sclk;
    wire mosi;
    wire miso;
    wire cs;
    
    clk_divider #(5) baudrate_gen(
        .clk_in(clk),
        .reset(reset),
        .clk_out(inner_clk)
    );

    reg i_tx_dv;
    reg o_tx_ready;
    reg o_rx_dv;


/*
*************************************
*   External Modules declarations   *
*************************************
*/

/*
    SPI spi_instance (
        .clk(clk),
        .reset(reset),
        .start_transfer(start_transfer),
        .data_to_tx(data_to_tx),
        .data_rx(data_rx),
        .sclk(sclk),
        .miso(miso),
        .mosi(mosi),
        .cs(cs)
    );
*/

    SPIController spi_instance (
        .i_clk(inner_clk),
        .i_reset_n(reset),
        .i_tx_byte(data_to_tx),
        .i_tx_dv(i_tx_dv),
        .o_tx_ready(o_tx_ready),
        .o_rx_dv(o_rx_dv),
        .o_rx_byte(data_rx),
        .o_spi_clk(sclk),
        .i_spi_cipo(miso),
        .o_spi_copi(mosi)
    );


    // spi_instance.COMM_RATE = `RATE2M4_CLK24M;

/*
******************
*   Statements   *
******************
*/

    parameter INIT  = 3'b001; 
    parameter TRANSF_PREP = 3'b010;
    parameter TRANSF = 3'b011;  
    parameter TRANSF_CHECK = 3'b000;
    parameter TRANSF_CHECK_2 = 3'b111;

    reg led_r = OFF;
    reg led_g = OFF;
    reg led_b = OFF;
    reg[2:0] state = INIT;
    reg[31:0] counter = 0;

    reg[10:0] delay_time = 0;
    reg error_pin = 0;

    assign led_red = led_r;
    assign led_green = led_g;
    assign led_blue = led_b;
    
    assign gpio_34 = start_transfer;  //DER
    assign gpio_43 = error_pin;
    assign gpio_36 = miso;
    assign gpio_42 = mosi;
    assign gpio_38 = sclk;
    assign gpio_28 = cs;  //IZQ

/*
******************
*      Main      *
******************
*/

    always @(posedge i_clk) begin
        case (state)
            INIT: begin //48000000
                if (counter == 480) begin
                    // Reset all values and transition to UART_SEND_ON state
                    reset <= 0;
                    state <= TRANSF_PREP;
                    led_b <= ON;
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

            TRANSF_PREP: begin
                data_to_tx <= data_to_tx + 1;
                delay_time <= 0;
                error_pin <= 0;
                state <= TRANSF;
            end

            TRANSF: begin
                i_tx_dv <= 1;
                start_transfer <= 1;
                state <= TRANSF_CHECK;
            end

            TRANSF_CHECK: begin
                start_transfer <= 0;
                i_tx_dv <= 1;
                delay_time <= delay_time + 1;
                if (delay_time > 1000) begin
                    state <= TRANSF_CHECK_2; 
                end
            end

            TRANSF_CHECK_2: begin
                if (data_rx != 5) begin
                    error_pin <= 1;
                end
                state <= TRANSF_PREP;
            end

        endcase
    end

endmodule
