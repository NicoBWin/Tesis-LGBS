/*
    Recibe por UART que gate debe prender y cual apagar en un codigo unico de 
    8 bits (5 bits de datos + 3 bits de ECC). Debe reflejar los valores en 
    los gates cuando recibe la señal de shoot. 

    HACER ESTO DESPUES
    Ademas, cada X ms debe enviar por las lectura de los ADC a traves 
    de UART (Siempre en la ventana de tiempo que no se requiere enviar 
    informacion desde FPGA main hacia FPGA modulo). 
*/

`include "./src/macros.vh"
`include "./src/UART/UART.vh"
`include "./src/timer/timer.vh"
`include "./src/ADC/ADC.vh"

module top(

    //Revisado segun la version final de la placa

    // UART
    input wire gpio_23,
    output wire gpio_12,

    //LEDs
    output wire led_red,
    output wire led_green,
    output wire led_blue,

    //Shoot
    input wire gpio_26,

    //ADCs
    output wire gpio_11,
    input wire gpio_9,
    output wire gpio_6,

    output wire gpio_13,
    input wire gpio_19,
    output wire gpio_18

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

    localparam INIT = 2'b00;
    localparam IDLE = 2'b01;
    localparam RX_ERROR = 2'b10;
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

    reg g1_a = TR_OFF;
    reg g1_b = TR_OFF;
    reg g2_a = TR_OFF;
    reg g2_b = TR_OFF;
    reg g3_a = TR_OFF;
    reg g3_b = TR_OFF;

    wire shoot = gpio_26;
    
    assign led_red = led_r;
    assign led_green = led_g;
    assign led_blue = led_b;

    wire sdo_1 = gpio_9;
    wire cs_1 = gpio_11;
    wire sclk_1 = gpio_6;
    wire sdo_2 = gpio_19;
    wire cs_2 = gpio_13;
    wire sclk_2 = gpio_18;

    assign gpio_46 = g1_a;
    assign gpio_45 = g1_b;
    assign gpio_3 = g1_c;
    assign gpio_2 = g2_a;
    assign gpio_47 = g2_b;
    assign gpio_48 = g2_c;

    wire code_received;
    wire uart_code;

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
    reg reset = 0;

    // UART
    reg start_tx;
    reg [7:0] data_to_tx;
    wire [7:0] data_received; 
    wire tx_busy; 
    wire rx_done; 
    wire parity_error; 
    wire tx; 
    wire rx; 
    assign uart_code = data_received[6:3];

    // Timers
    reg start_1_sec = 0;
    wire done_1_sec;

    // Signals for ADC 1
    wire adc_1_read;
    wire adc_1_recalibrate;
    wire [11:0] adc_1_value;
    wire adc_1_done;

    // Signals for ADC 2
    wire adc_2_read;
    wire adc_2_recalibrate;
    wire [11:0] adc_2_value;
    wire adc_2_done;
/*
*************************************
*        Functions declarations     *
*************************************
*/

task uart_code_received(input logic [3:0] code);
    begin
        code_received = (rx_done && uart_code == code) ? 1 : 0;
    end
endtask

/*
*************************************
*   External Modules declarations   *
*************************************
*/
    
    // UART TX module
    uart_tx to_modules_tx(
        .clk(clk),
        .reset(reset),
        .data_to_tx(data_to_tx), 
        .start_tx(start_tx), 
        .tx(tx), 
        .tx_busy(tx_busy)
    );

    // UART RX module
    uart_rx from_modules_rx(
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .data_received(data_received), 
        .rx_done(rx_done), 
        .parity_error(parity_error)
    );

    ADC #(.COMM_RATE(`SAMPLE2M4_CLK48M)) adc_1 (
        .clk(clk),
        .reset(reset),
        .read(adc_1_read),
        .recalibrate(adc_1_recalibrate),
        .sdo(sdo_1),
        .cs(cs_1),
        .sclk(sclk_1),
        .value(adc_1_value),
        .read_done(adc_1_done)
    );

    ADC #(.COMM_RATE(`SAMPLE2M4_CLK48M)) adc_2 (
        .clk(clk),
        .reset(reset),
        .read(adc_2_read),
        .recalibrate(adc_2_recalibrate),
        .sdo(sdo_2),
        .cs(cs_2),
        .sclk(sclk_2),
        .value(adc_2_value),
        .read_done(adc_2_done)
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
                    state <= IDLE;
                end
                else begin
                    reset <= 1;
                    start_1_sec <= 1;
                end
            end

            IDLE: begin
                if (rx_done) begin
                    if (!parity_error) begin
                        
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