
`include "../UART/baudgen.vh"

module top(
    output wire gpio_28,
    output wire gpio_12,
    output wire gpio_21,
    output wire gpio_13,

    output wire led_red,
    output wire led_green,
    output wire led_blue
);

/*
*******************
*   Ports setup   *
*******************
*/

    wire tx;
    wire cs_1;
    wire sdo_1;
    wire sclk_1;

    assign tx = gpio_28;
    assign cs_1 = gpio_12;
    assign sdo_1 = gpio_21;
    assign sclk_1 = gpio_13;

/*
*********************
*   HFClock setup   *
*********************
*/  
    wire clk;
    SB_HFOSC  #(.CLKHF_DIV("0b01") // 24 MHz / div (0b00=1, 0b01=2, 0b10=4, 0b11=8)
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

    // ADC
    reg read_adc = 0;
    reg recalibrate = 0;
    wire [11:0] adc_value_1;

    
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

    defparam transmitter.PARITY = 0;
    defparam transmitter.BAUD_RATE = `BAUD8M_CLK24M;

/*
******************
*   Statements   *
******************
*/

    parameter INIT  = 3'b000; 
    parameter READ_ADC = 3'b001;
    parameter WAIT_ADC = 3'b010;
    parameter SEND_BACK = 3'b101;

    reg[2:0] state = INIT;
    reg curr_pack = 0;

    always @(posedge clk) begin
        case (state)
            INIT: begin
                reset   <= 1;
                counter <= counter + 1;

                // 1 sec
                if (counter >= 48000000) begin
                    reset <= 0;
                    counter <= 0;
                    read_adc <= 1;
                    state <= WAIT_ADC;
                    led_g <= ON;
                end
            end

            WAIT_ADC: begin
                if (cs_1 == 1) begin
                    state <= SEND_BACK;
                    led_g <= OFF;
                    led_b <= ON;
                end
            end

            SEND_BACK: begin
                
                if (!tx_busy) begin
                    if (curr_pack == 0) begin
                        data_to_tx <= {5'b0, adc_value_1[11:8]};
                        curr_pack <= 1;
                    end
                    else begin
                        data_to_tx <= adc_value_1[7:0];
                        curr_pack <= 0;
                    end

                    start_tx <= 1;
                end
                else begin
                    start_tx <= 0;
                end
            end

        endcase
    end

endmodule