
`include "./src/config/config.vh"
`include "./src/UART/UART.vh"
`include "./src/timer/timer.vh"

module top(

    // UART
    input wire gpio_23,
    output wire gpio_12,

    //LEDs
    output wire led_red,
    output wire led_green,
    output wire led_blue,

    //Shoot
    input wire gpio_26,

    // Gates de los transistores
    output wire gpio_3,
    output wire gpio_48,
    output wire gpio_45,
    output wire gpio_47,
    output wire gpio_46,
    output wire gpio_2
);

/*
*****************************
*   Variables declaration   *
*****************************
*/   

    localparam OFF = 1;
    localparam ON = 0;
    localparam TR_ON = 1;
    localparam TR_OFF = 0;

    localparam INIT = 3'b000;
    localparam WAIT_VALUE_1 = 3'b001;
    localparam WAIT_VALUE_2 = 3'b010;
    localparam RX_ERROR = 3'b011;
    
/*
*******************
*   Ports setup   *
*******************
*/  

    //UART_MAP: uart_id/rx_gpio/tx_gpio
    `UART_MAP(1, gpio_23, gpio_12)

    reg led_r = OFF;
    reg led_g = OFF;
    reg led_b = OFF;

    wire g1_a;
    wire g1_b;
    wire g2_a;
    wire g2_b;
    wire g3_a;
    wire g3_b;
    wire clk24;

    wire shoot = gpio_26;

    assign gpio_46 = g1_a;
    assign gpio_45 = g1_b;
    assign gpio_3 = g1_c;
    assign gpio_2 = g2_a;
    assign gpio_47 = g2_b;
    assign gpio_48 = g2_c;

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
*************************************
*   External Modules Variables      *
*************************************
*/
    // General purpose
    reg state = INIT;
    reg reset = 0;
    reg [15:0] uart_msg = 16'h0000;

    // UART
    reg start_tx;
    reg [7:0] data_to_tx;
    wire [7:0] data_received; 
    wire tx_busy; 
    wire rx_done; 
    wire parity_error; 
    wire tx; 
    wire rx; 

    // Timers
    reg start_1_sec = 0;
    wire done_1_sec;

/*
*************************************
*        Functions declarations     *
*************************************
*/

/*
*************************************
*   External Modules declarations   *
*************************************
*/
    // timer timer_u(
    //     .clk(clk),
    //     .reset(1'b0),
    //     .start(start_1_sec),
    //     .done(done_1_sec)
    // );
    clk_divider #(.BAUD_DIV(2)) clk_div_u
    (   
        .clk_in(clk),       // Input clock
        .reset(reset),
        .clk_out(clk24)       // Output divided clock
    );

    // UART TX module
    uart_tx to_modules_tx(
        .clk(clk24),
        .reset(reset),
        .data_to_tx(data_to_tx), 
        .start_tx(start_tx), 
        .tx(tx), 
        .tx_busy(tx_busy)
    );

    // UART RX module
    uart_rx from_modules_rx(
        .clk(clk24),
        .reset(reset),
        .rx(rx),
        .data_received(data_received), 
        .rx_done(rx_done), 
        .parity_error(parity_error)
    );


    rgb_color_selector color_selector(
        .color_index(`MODULE_ID),
        .led_red(led_red),
        .led_green(led_green),
        .led_blue(led_blue)
    );

    modulator #(.MODULE_ID(`MODULE_ID))
    modulator_u
    (
        .clk(clk),
        .reset(reset),
        .shoot(shoot),
        .angle(uart_msg[11:0]),
        .g1_a(g1_a),
        .g2_a(g2_a),
        .g1_b(g1_b),
        .g2_b(g2_b),
        .g1_c(g1_c),
        .g2_c(g2_c)
    );

/*
******************
*   Statements   *
******************
*/
    
    always @(posedge clk) begin
        case (state)
            INIT: begin
                if (done_1_sec) begin
                    reset <= 0;
                    start_1_sec <= 0;
                    led_b <= ON;
                    state <= WAIT_VALUE_1;
                end
                else begin
                    reset <= 1;
                    start_1_sec <= 1;
                end
            end

            WAIT_VALUE_1: begin
                if (rx_done) begin
                    if (!parity_error) begin
                        uart_msg[15:8] <= data_received;
                        state <= WAIT_VALUE_2;
                    end
                    else begin
                        state <= RX_ERROR;
                    end 
                end
            end

            WAIT_VALUE_2: begin
                if (rx_done) begin
                    if (!parity_error) begin
                        uart_msg[7:0] <= data_received;
                        state <= WAIT_VALUE_1;
                    end
                    else begin
                        state <= RX_ERROR;
                    end 
                end
            end

            RX_ERROR: begin
                
            end

        endcase
    end

endmodule