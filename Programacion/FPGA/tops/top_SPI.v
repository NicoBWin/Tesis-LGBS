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
    
    reg reset;
    reg start_transfer;
    reg [15:0] data_to_tx;
    wire [15:0] data_rx;
    wire sclk;
    wire mosi;
    wire miso;
    wire cs;
    
/*
*************************************
*   External Modules declarations   *
*************************************
*/

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

    spi_instance.COMM_RATE = ``RATE2M4_CLK24M;

/*
******************
*   Statements   *
******************
*/

    parameter INIT  = 3'b001; 
    parameter UART_CHECK = 3'b010;
    parameter WAIT = 3'b011;  

    reg led_r = OFF;
    reg led_g = OFF;
    reg led_b = OFF;
    reg[2:0] state = INIT;
    reg[31:0] counter = 0;

    assign led_red = led_r;
    assign led_green = led_g;
    assign led_blue = led_b;
    
    //assign gpio_34 = data_received[5];
    wire error_pin = gpio_34;
    // assign gpio_43 = data_received[4];
    assign rx = gpio_43;
    // assign gpio_36 = data_received[3];
    assign gpio_36 = parity_error;
    assign gpio_42 = data_received[2];
    // assign gpio_42 = tx;
    assign gpio_38 = data_received[1];
    // assign gpio_38 = rx_done;
    assign gpio_28 = data_received[0];

    reg error_pin;
    reg [7:0] comp_data;

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

            WAIT: begin
                error_pin = 0;
                if (rx_done) begin
                    state <= UART_CHECK;
                end
            end

            UART_CHECK: begin
                if (comp_data != data_received)begin
                    error_pin <= 1;
                end
                comp_data <= data_received + 1;
                state <= WAIT;
            end

        endcase
    end

endmodule
