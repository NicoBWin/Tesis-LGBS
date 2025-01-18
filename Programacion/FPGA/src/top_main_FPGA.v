/*
    Recibe por los 2 SPIs los valores de las 3 señales. Manda por UART que 
    transistores prender de cada modulo y envia al final un pulso de shoot.
*/

`include "./src/macros.vh"
`include "./src/UART/UART.vh"
`include "./src/SPI/SPI.vh"
`include "./src/timer/timer.vh"

module top(

    //TODO: Revisar pines para dejarlo como el final

    // UART 1
    input wire gpio_23,
    output wire gpio_10,

    // UART 2
    input wire gpio_26,
    output wire gpio_27,

    // UART 3
    input wire gpio_32,
    output wire gpio_35,

    // UART 4
    input wire gpio_31,
    output wire gpio_2,

    // UART 5
    input wire gpio_42,
    output wire gpio_38,

    // UART 6
    input wire gpio_28,
    output wire gpio_12,

    // UART 7
    input wire gpio_21,
    output wire gpio_13,

    // UART 8
    input wire gpio_9,
    output wire gpio_6,

    // UART 9
    input wire gpio_19,
    output wire gpio_18,

    //Signal from SPI
    output wire gpio_37,
    output wire gpio_34,
    input wire gpio_43,
    output wire gpio_36,

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

    `UART_MAP(1, gpio_23, gpio_10)
    `UART_MAP(2, gpio_26, gpio_27)
    `UART_MAP(3, gpio_32, gpio_35)
    `UART_MAP(4, gpio_31, gpio_2)
    `UART_MAP(5, gpio_42, gpio_38)
    `UART_MAP(6, gpio_28, gpio_12)
    `UART_MAP(7, gpio_21, gpio_13)
    `UART_MAP(8, gpio_9, gpio_6)
    `UART_MAP(9, gpio_19, gpio_18)

    wire shoot = gpio_25;
    wire spi_clk = gpio_37;
    wire mosi = gpio_34;
    wire miso = gpio_43;
    wire cs = gpio_36;

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
    SB_HFOSC  #(.CLKHF_DIV("0b00")) hf_osc (
        .CLKHFPU(1'b1), 
        .CLKHFEN(1'b1), 
        .CLKHF(clk)
    ); // 48 MHz / div (0b00=1, 0b01=2, 0b10=4, 0b11=8)

/*
*************************************
*   External Modules Variables      *
*************************************
*/

    // General purpose
    genvar i, j;
    reg reset = 0;
    reg is_code_received = 0;
    reg [$clog2(`NUM_OF_MODULES)-1:0] debug_uart_index = 0;
    reg [7:0] spi_to_uart_id, spi_to_uart_code;
    wire [15:0] sin_index;
    reg [7:0] sin_value;

    // Timers
    reg start_1_sec = 0;
    reg start_5_sec = 0;
    wire done_1_sec;
    wire done_5_sec;

    localparam INIT         = 3'b000;
    localparam IDLE         = 3'b001;
    localparam DEBUG_MODE   = 3'b010;
    localparam NORMAL_MODE  = 3'b100;
    localparam PIPE_MODE    = 3'b110;
    reg [2:0] state = INIT;

    //Pipe mode
    localparam IDLE_PIPE        = 2'b00;
    localparam SEND_PIPE        = 2'b01;
    localparam RECEIVE_PIPE     = 2'b10;
    localparam RETRANSMIT_PIPE  = 2'b11;
    reg [1:0] pipe_state = IDLE_PIPE;

    // UART
    reg [`NUM_OF_MODULES-1:0] start_tx; // One start_tx signal for each UART
    reg [7:0] data_to_tx[`NUM_OF_MODULES-1:0]; // Data to transmit for each UART
    wire [7:0] data_received[`NUM_OF_MODULES-1:0]; // Data received from each UART
    wire [`NUM_OF_MODULES-1:0] tx_busy; // TX busy signal for each UART
    wire [`NUM_OF_MODULES-1:0] rx_done; // RX done signal for each UART
    wire [`NUM_OF_MODULES-1:0] parity_error; // Parity error signal for each UART
    wire [`NUM_OF_MODULES-1:0] tx; // TX wire for each UART
    wire [`NUM_OF_MODULES-1:0] rx; // RX wire for each UART

    //SPI
    reg tx_rx_spi;
    reg [15:0] to_tx_spi;
    wire [15:0] received_from_spi;
    wire transfer_done_spi;

/*
*************************************
*        Functions declarations     *
*************************************
*/

task check_condition;
    input logic [15:0] code;

    begin
        is_code_received = (transfer_done_spi == 1 && received_from_spi == code) ? 1 : 0;
    end
endtask

task sin_value_send;
    wire [15:0] sin_index = i * `MODULE_OFFSET + j * `PHASE_OFFSET; 

    begin
        for (i = 0; i < `NUM_OF_MODULES; i = i + 1) begin
            for (j = 0; j < `NUM_OF_PHASES; j = j + 1) begin
                data_to_tx[i] = sin_value;
                start_tx = 1;
                wait(tx_busy == 0);
                start_tx = 0;
            end
        end
    end
endtask

/*
*************************************
*   External Modules declarations   *
*************************************
*/
    
    generate
        for (i = 0; i < `NUM_OF_MODULES; i = i + 1) begin : uart_modules

            // UART TX module
            uart_tx to_modules_tx(
                .clk(clk),
                .reset(reset),
                .data_to_tx(data_to_tx[i]), 
                .start_tx(start_tx[i]), 
                .tx(tx[i]), 
                .tx_busy(tx_busy[i])
            );

            // UART RX module
            uart_rx from_modules_rx(
                .clk(clk),
                .reset(reset),
                .rx(rx[i]),
                .data_received(data_received[i]), 
                .rx_done(rx_done[i]), 
                .parity_error(parity_error[i])
            );
        end
    endgenerate

    SPI from_uC_spi(
        .clk(clk),
        .reset(reset),
        .start_transfer(tx_rx_spi),
        .transfer_done(transfer_done_spi),
        .data_to_tx(to_tx_spi),
        .data_rx(received_from_spi),
        .sclk(spi_clk),
        .mosi(mosi),
        .miso(miso),
        .cs(cs)
    );

    timer #(`SEC_1) timer_1(
        .clk(clk),
        .reset(reset),
        .start(start_1_sec),
        .done(done_1_sec)
    );

    timer #(`SEC_5) timer_2(
        .clk(clk),
        .reset(reset),
        .start(start_5_sec),
        .done(done_5_sec)
    );

    RAM ram (
        .address(sin_index),
        .data(sin_value)
    );

/*
******************
*   Statements   *
******************
*/
    
    always @(posedge clk) begin
        case (state)
            INIT: begin
                reset <= 1;
                start_5_sec <= 1;
                tx_rx_spi <= 1;
                state <= IDLE;
            end

            IDLE: begin
                is_code_received = check_condition(`PIPE_MODE_SPI);
                reset <= 0;

                //Si termino la transferencia y se recibio modo pipe
                if (is_code_received) begin
                    //Entramos al modo pipe del inverter
                    state <= PIPE_MODE;
                    pipe_state <= IDLE_PIPE;
                    led_b <= ON;
                end
                else if(done_5_sec == 1) begin
                    //Entramos al modo normal de funcionamiento del inverter
                    state <= NORMAL_MODE;
                    led_g <= ON;
                end
            end

            PIPE_MODE: begin
                case (pipe_state)
                    IDLE_PIPE: begin
                        if (transfer_done_spi) begin
                            spi_to_uart_id = received_from_spi[15:8];
                            spi_to_uart_code = received_from_spi[7:0];
                            data_to_tx[spi_to_uart_id] = spi_to_uart_code;
                            pipe_state <= SEND_PIPE;
                        end
                    end
                    
                    SEND_PIPE: begin
                        if (!tx_busy[spi_to_uart_id]) begin
                            start_tx[spi_to_uart_id] = 1;
                            pipe_state <= RECEIVE_PIPE;
                        end
                    end

                    RECEIVE_PIPE: begin
                        if (!rx_busy[spi_to_uart_id]) begin
                            start_tx[spi_to_uart_id] = 1;
                            pipe_state <= RECEIVE_PIPE;
                        end
                    end
                endcase
            end

            NORMAL_MODE: begin
                sin_value_pick();
            end
        endcase
    end

endmodule