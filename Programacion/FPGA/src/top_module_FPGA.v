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

module top(

    //TODO: Revisar pines para dejarlo como el final

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

/*
*******************
*   Ports setup   *
*******************
*/  

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

    wire sdo_1 = gpio_13;
    wire cs_1 = gpio_19;
    wire sclk_1 = gpio_18;
    wire sdo_2 = gpio_11;
    wire cs_2 = gpio_9;
    wire sclk_2 = gpio_6;

    assign gpio_3 = g1_a;
    assign gpio_48 = g1_b;
    assign gpio_45 = g2_a;
    assign gpio_47 = g2_b;
    assign gpio_46 = g3_a;
    assign gpio_2 = g3_b;

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

    // Timers
    reg start_1_sec = 0;
    reg start_5_sec = 0;
    wire done_1_sec;
    wire done_5_sec;

    // UART
    reg start_tx; // One start_tx signal for each UART
    reg [7:0] data_to_tx; // Data to transmit for each UART
    wire [7:0] data_received; // Data received from each UART
    wire tx_busy; // TX busy signal for each UART
    wire rx_done; // RX done signal for each UART
    wire parity_error; // Parity error signal for each UART
    wire tx; // TX wire for each UART
    wire rx; // RX wire for each UART

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
                reset <= 1;
                start_5_sec <= 1;
                tx_rx_spi <= 1;
                state <= IDLE;
            end

            IDLE: begin
                logic is_code_received;
                is_code_received = check_condition(`PIPE_MODE_SPI, is_code_received);

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
                // Handle normal mode operations (non-pipe mode)
            end
        endcase
    end

endmodule