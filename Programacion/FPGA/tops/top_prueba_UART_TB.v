
`include "./src/UART/UART.vh"

module top(
    input wire gpio_23,
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

    assign tx = gpio_10;
    assign rx = gpio_23;

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
        //.curr_state({gpio_36, gpio_42})
    );

    defparam transmitter.PARITY = 0;
    defparam receiver.PARITY = 0;
    defparam transmitter.BAUD_RATE = `BAUD1M_CLK48M;
    defparam receiver.BAUD_RATE = `BAUD1M_CLK48M;

/*
******************
*   Statements   *
******************
*/

    parameter INIT  = 3'b000; 
    parameter IDLE = 3'b001;

    reg[5:0] current_code = 0;
    reg[2:0] state = INIT;

    assign gpio_34 = tx;
    assign gpio_43 = data_received[1];
    assign gpio_36 = data_received[2];
    assign gpio_42 = data_received[3];
    assign gpio_38 = data_received[4];
    assign gpio_28 = data_received[5];

    reg tx_done = 0;

/*
*************************************
*        Functions declarations     *
*************************************
*/

    function is_tx_done;
        input uart_tx_busy;
        input temp_tx_done;
        begin
            if (!uart_tx_busy && !temp_tx_done) begin
                is_tx_done = 1;
            end

            if (uart_tx_busy) begin
                is_tx_done = 0;
            end
        end
    endfunction

/*
******************
*      Main      *
******************
*/

    always @(posedge clk) begin
        case (state)
            INIT: begin
                reset   <= 1;
                counter <= counter + 1;

                // 1 sec
                if (counter >= 24000000) begin
                    reset <= 0;
                    counter <= 0;
                    data_to_tx <= {2'b0, current_code};
                    start_tx <= 1;
                    state <= IDLE;
                    led_b <= ON;
                end
            end

            IDLE: begin

                tx_done = is_tx_done(tx_busy, tx_done);

                if (tx_done) begin
                    current_code <= current_code + 1;
                    data_to_tx <= {2'b0, current_code};
                    start_tx <= 1;
                end
                else
                    start_tx <= 0;
            end
        endcase
    end

endmodule