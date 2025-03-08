`include "./src/SPI/SPI.vh"
`include "./src/UART/UART.vh"
`include "./src/macros.vh"


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
    output wire gpio_6,

    //Signal from SPI 2
    output wire gpio_11,
    output wire gpio_9,
    input wire gpio_18,
    output wire gpio_4,


    //LEDs
    output wire led_red,
    output wire led_green,
    output wire led_blue,

    //Shoot
    output wire gpio_25
);

/*
*******************
*   Ports setup   *
*******************
*/  
    // //UART_MAP: uart_id/rx_gpio/tx_gpio
    // `UART_MAP(1, gpio_26, gpio_27)
    // `UART_MAP(2, gpio_32, gpio_35)
    // `UART_MAP(3, gpio_31, gpio_37)
    // `UART_MAP(4, gpio_34, gpio_43)
    // `UART_MAP(5, gpio_36, gpio_42)
    // `UART_MAP(6, gpio_38, gpio_28)
    // `UART_MAP(7, gpio_3, gpio_48)
    // `UART_MAP(8, gpio_45, gpio_47)
    // `UART_MAP(9, gpio_46, gpio_2)


    wire spi_clk_1 = gpio_13;
    wire mosi_1 = gpio_6; // not used
    wire miso_1 = gpio_21;
    wire cs_1 = gpio_19;
    
    //wire spi_clk_2 = gpio_11;
    //wire mosi_2 = gpio_4; // not used
    //wire miso_2 = gpio_18;
    //wire cs_2 = gpio_9;
    wire gpio_11 = 0;
    // wire gpio_4 = 0; // not used
    wire miso_2 = gpio_18;
    wire gpio_9 = 0;

    reg led_r = 1;
    reg led_g = 1;
    reg led_b = 1;
    
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
    wire transfer_done, transfer_ready;
    wire [7:0] data_received;
    wire [1:0] byte_received;
    wire [1:0]debug = {gpio_18, spi_clk_2};
    assign gpio_4 = data_rx[1];
/*
*************************************
*   External Modules declarations   *
*************************************
*/

    // SPI spi_i (
    //     .clk(clk),
    //     .reset(reset),
    //     .start_transfer(start_transfer),
    //     .data_to_tx(data_to_tx),
    //     .data_rx(data_rx),
    //     .transfer_done(transfer_done),
    //     .transfer_busy(transfer_busy),  
    //     .sclk(sclk),
    //     .miso(miso),
    //     .mosi(mosi),
    //     .cs(cs)
    // );

    //defparam spi_i.COMM_RATE = `RATE6M_CLK24M;

    SPI_Master_With_Single_CS u_spi (
    .i_Rst_L(reset),     // FPGA Reset
    .i_Clk(clk),       // FPGA Clock
    .i_TX_Count(2),  // # bytes per CS low
    .i_TX_Byte(33),       // Byte to transmit on MOSI
    .i_TX_DV(start_transfer),         // Data Valid Pulse with i_TX_Byte
    .o_TX_Ready(transfer_ready),      // Transmit Ready for next byte
    .o_RX_Count(byte_received),  // Index RX byte
    .o_RX_DV(transfer_done),     // Data Valid pulse (1 clock cycle)
    .o_RX_Byte(data_received),   // Byte received on MISO
    .o_SPI_Clk(spi_clk_1),
    .i_SPI_MISO(miso_1),
    .o_SPI_MOSI(mosi_1),
    .o_SPI_CS_n(cs_1)
    );

/*
******************
*   Statements   *
******************
*/

    parameter INIT  = 3'b001; 
    parameter TRANSF_1 = 3'b010;
    parameter TRANSF_1_WAITING = 3'b011;  
    parameter TRANSF_2_WAITING = 3'b111;
    parameter TRANSF_RESET = 3'b000;

    reg [2:0] state = INIT;
    reg [31:0] counter = 0;

    reg [10:0] delay_time = 0;
    reg error_pin = 0;


/*
******************
*      Main      *
******************
*/

    always @(posedge clk) begin
        case (state)
            INIT: begin
                if (counter >= 480) begin
                    reset <= 1;
                    state <= TRANSF_1;
                    led_b <= ON;
                    led_r <= ON;
                    counter <= 0; // Reset the counter at the same time
                end
                else begin
                    reset <= 1;
                    start_transfer <= 0;
                    led_r <= 1;
                    led_g <= 1;
                    led_b <= 1;
                    counter <= counter + 1;
                end
            end

            TRANSF_1: begin
                state <= TRANSF_1_WAITING;
                start_transfer <= 1;
            end

            TRANSF_1_WAITING: begin
                start_transfer <= 0; 
                if (transfer_done) begin
                    state <= TRANSF_2_WAITING;
                    start_transfer <= 1;
                    data_rx[15:8] <= data_received;
                end
            end

            TRANSF_2_WAITING: begin
                start_transfer <= 0;
                if (transfer_done) begin
                    state <= TRANSF_RESET;
                    data_rx[7:0] <= data_received;

                end
            end

            TRANSF_RESET: begin
                state <= INIT;
            end
        endcase
    end

endmodule
