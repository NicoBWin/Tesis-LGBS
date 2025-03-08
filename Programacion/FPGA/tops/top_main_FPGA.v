/*
    Recibe por los 2 SPIs los valores de las 3 señales. Manda por UART que 
    transistores prender de cada modulo y envia al final un pulso de shoot.
*/

`include "./src/config/config.vh"
`include "./src/UART/UART.vh"
`include "./src/SPI/SPI.vh"
`include "./src/timer/timer.vh"

module top(

    //Revisado segun la version final de la placa

    // UART 1
    input wire gpio_26,
    output wire gpio_27,

    // UART 2
    input wire gpio_32,
    output wire gpio_35,

    // UART 3
    input wire gpio_31,
    output wire gpio_37,

    // UART 4
    input wire gpio_34,
    output wire gpio_43,

    // UART 5
    input wire gpio_36,
    output wire gpio_42,

    // UART 6
    input wire gpio_38,
    output wire gpio_28,

    // UART 7
    input wire gpio_3,
    output wire gpio_48,

    // UART 8
    input wire gpio_45,
    output wire gpio_47,

    // UART 9
    input wire gpio_46,
    output wire gpio_2,

    //Signal from SPI 1
    output wire gpio_13,
    output wire gpio_19,
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
    //UART_MAP: uart_id/rx_gpio/tx_gpio
    `UART_MAP(1, gpio_26, gpio_27)
    `UART_MAP(2, gpio_32, gpio_35)
    `UART_MAP(3, gpio_31, gpio_37)
    `UART_MAP(4, gpio_34, gpio_43)
    `UART_MAP(5, gpio_36, gpio_42)
    `UART_MAP(6, gpio_38, gpio_28)
    `UART_MAP(7, gpio_3, gpio_48)
    `UART_MAP(8, gpio_45, gpio_47)
    `UART_MAP(9, gpio_46, gpio_2)

    wire shoot = gpio_44;

    wire spi_clk_1 = gpio_13;
    wire mosi_1 = gpio_6;
    wire miso_1 = gpio_21;
    wire cs_1 = gpio_19;

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
    SB_HFOSC  #(.CLKHF_DIV("0b01")) hf_osc (
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

    wire [11:0] sin_index;
    wire [3:0] uart_id;

    // Timers
    reg start_1_sec = 0;
    reg start_5_sec = 0;
    wire done_1_sec;
    wire done_5_sec;

    localparam INIT         = 3'b000;
    localparam REQUEST_SINE = 3'b001;
    localparam DEBUG_MODE   = 3'b010;
    localparam NORMAL_MODE  = 3'b100;

    localparam STARTUP      = 3'b101;
    localparam PIPE_MODE    = 3'b110;
    localparam IDLE = 3'b111;
    reg [2:0] state = INIT;

    //Pipe mode
    localparam IDLE_PIPE        = 2'b00;
    localparam SEND_PIPE        = 2'b01;
    localparam RECEIVE_PIPE     = 2'b10;
    localparam RETRANSMIT_PIPE  = 2'b11;
    reg [1:0] pipe_state = IDLE_PIPE;

    //Normal mode
    localparam REQUEST_NORMAL  = 2'b00;
    localparam PROCESS_NORMAL  = 2'b01;
    localparam SEND_NORMAL     = 2'b10;
    reg [1:0] normal_state = REQUEST_NORMAL;

    // UART
    reg [`NUM_OF_MODULES-1:0] start_tx; // One start_tx signal for each UART
    reg [7:0] data_to_tx[`NUM_OF_MODULES-1:0]; // Data to transmit for each UART
    wire [7:0] data_received[`NUM_OF_MODULES-1:0]; // Data received from each UART
    wire [`NUM_OF_MODULES-1:0] tx_busy; // TX busy signal for each UART
    wire [`NUM_OF_MODULES-1:0] rx_done; // RX done signal for each UART
    wire [`NUM_OF_MODULES-1:0] parity_error; // Parity error signal for each UART
    wire [`NUM_OF_MODULES-1:0] tx; // TX wire for each UART
    wire [`NUM_OF_MODULES-1:0] rx; // RX wire for each UART

    //SPI 1
    reg tx_rx_spi_1;
    reg [15:0] to_tx_spi_1;
    wire [15:0] received_from_spi_1;
    wire transfer_done_spi_1;
    wire data_valid_spi_1;

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

    SPI_request_data spi_1(
        .clk(clk),
        .reset(reset),
        .start_transfer(tx_rx_spi_1),
        .miso_1(miso_1),
        .spi_clk_1(spi_clk_1),
        .cs_1(cs_1),
        .data_valid(data_valid_spi_1),
        .sin_index(sin_index),
        .uart_id(uart_id)
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

/*
******************
*   Statements   *
******************
*/
    
    always @(posedge clk) begin
        case (state)
            INIT: begin
                if (done_1_sec == 1) begin
                    reset <= 0;
                    tx_rx_spi_1 <= 1;
                    state <= STARTUP;
                end
                else begin
                    reset <= 1;
                    start_1_sec <= 1;
                    start_5_sec <= 1;
                    tx_rx_spi_1 <= 0;
                end
            end

            STARTUP: begin
                state <= 
            end

            IDLE: begin
                
                tx_rx_spi_1 <= 0;
                //Si termino la transferencia y se recibio modo pipe
                if (data_valid_spi_1 & sin_index == `PIPE_MODE_SPI) begin
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
                       
                    end
                endcase
            end

            NORMAL_MODE: begin
                case (normal_state)
                    REQUEST_NORMAL: begin
                        
                        if (data_valid_spi_1) begin
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
                    
                    PROCESS_NORMAL: begin

                    end

                    RETRANSMIT_NORMAL: begin
                        
                    end
                endcase
            end
        endcase
    end

endmodule