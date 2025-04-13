
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
    output wire gpio_2,
    output wire gpio_28,
    output wire gpio_38,
    output wire gpio_42,

    // Debugging
    output wire gpio_25 
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
    localparam WAIT_SHOOT = 3'b100;
    localparam WAIT_VALUE_1 = 3'b001;
    localparam WAIT_VALUE_2 = 3'b010;
    localparam DELAY = 3'b011;
    localparam RX_ERROR = 3'b111;
    
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

    assign gpio_46 = g1_c;
    assign gpio_45 = g1_b;
    assign gpio_3 = g1_a;
    assign gpio_2 = g2_c;
    assign gpio_47 = g2_b;
    assign gpio_48 = g2_a;

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
    reg [2:0]state = INIT;
    reg reset = 0;
    reg [15:0] uart_msg = 16'h0000;
    assign {gpio_28, gpio_38, gpio_42} = uart_msg[2:0]; //TODO: Me
    // UART
    reg start_tx;
    reg [7:0] data_to_tx;
    wire [7:0] data_received; 
    wire tx_busy; 
    wire rx_done; 
    wire parity_error; assign gpio_25 = parity_error; //TODO: Borrar
    wire tx = tx_uart_1; 
    wire rx = rx_uart_1; 

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
    timer timer_u(
        .clk(clk24),
        .reset(1'b0),
        .start(start_1_sec),
        .done(done_1_sec)
    );
    clk_divider #(.BAUD_DIV(1)) clk_div_u
    (   
        .clk_in(clk),       // Input clock
        .reset(1'b0),
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

    modulator modulator_u
    (
        .clk(clk),
        .clk24(clk24),
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
    
    always @(posedge clk24) begin
        case (state)
            INIT: begin
                if (done_1_sec) begin
                    if (shoot) begin
                        reset <= 0;
                        start_1_sec <= 0;
                        led_b <= ON;
                        state <= WAIT_VALUE_1;
                    end
                end
                else begin
                    reset <= 1;
                    start_1_sec <= 1;
                end
            end
            WAIT_SHOOT: begin
                if (shoot) begin
                    state <= WAIT_VALUE_1;
                end
            end
            WAIT_VALUE_1: begin
                if (rx_done) begin
                    if (!parity_error) begin
                        uart_msg[15:8] <= data_received;
                        state <= DELAY;
                    end
                    else begin
                        state <= DELAY;
                    end 
                end
            end
            DELAY: begin
                
                state <= WAIT_VALUE_2;
                
            end
            WAIT_VALUE_2: begin
                if (rx_done) begin
                    if (!parity_error) begin
                        uart_msg[7:0] <= data_received;
                        state <= WAIT_SHOOT;
                    end
                    else begin
                        state <= WAIT_SHOOT;
                    end 
                end
            end

            RX_ERROR: begin
                
            end

        endcase
    end

endmodule