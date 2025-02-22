/*
    Receptor de UART. Fue probado hasta 6Mb/s utilizando un clock de 24MHz.
    A cada modulo va a ir un cable ethernet que contiene el tx y rx de cada modulo.
*/

`include "./src/UART/UART.vh"

module uart_rx(
    input wire clk,            // Clock signal
    input wire reset,
    input wire rx,             // UART receive line
    output reg [7:0] data_received,   // 8-bit data out
    output reg rx_done,         // Indicates reception is complete
    output wire parity_error     // Flag that indicates that there was a parity error
);

    // Config
    parameter BAUD_RATE = `BAUD6M_CLK48M;     // Desired baud rate
    parameter PARITY = 0;           // 0 for even parity, 1 for odd parity
    
    // States
    localparam INIT         = 3'b000;
    localparam IDLE         = 3'b001;
    localparam START        = 3'b010;
    localparam CHECK_START  = 3'b011;
    localparam RX           = 3'b100;
    localparam RX_DONE      = 3'b101;

    wire parity_error_done;

    reg [5:0] clk_counter;          //TODO: Si ponemos celing log 2 se rompe
    reg [8:0] rx_shift_reg;         // PARITY(1), DATA(8)
    reg [3:0] bit_index;            // Index for the bits being received
    reg [2:0] state = INIT;

    reg [5:0] zero_counter = 0;
    reg [5:0] one_counter = 0;
    reg rx_desition = 0;
    
    assign parity_error_done = PARITY ? ~(^rx_shift_reg) : (^rx_shift_reg);
    assign parity_error = rx_done & parity_error_done;

    always @(posedge clk) 
        begin
            if(reset) begin
                state <= INIT;
            end
            else
                case (state)
                    INIT: begin
                        bit_index <= 0;
                        rx_done <= 0;
                        clk_counter <= 0;
                        rx_shift_reg <= {9{1'b0}};
                        state <= IDLE;
                    end

                    IDLE: begin
                        if (!rx) begin  // Se detecto el start
                            state <= CHECK_START;
                        end
                    end

                    CHECK_START: begin
                        if (!rx) begin  // Se checkeo que sea start nuevamente (2 samples)
                            state <= START; //TODO: CAMBIAR
                        end
                        else begin
                            state <= IDLE;
                        end
                    end

                    START: begin
                        if (clk_counter >= BAUD_RATE+BAUD_RATE-2) begin
                            state <= RX;
                            clk_counter <= 0;
                        end 
                        else begin
                            clk_counter <= clk_counter + 1;
                        end
                    end

                    RX: begin
                        if (rx) begin
                            one_counter <= one_counter + 1;
                        end
                        else begin
                            zero_counter <= zero_counter + 1;
                        end
                        if (zero_counter > one_counter) begin
                            rx_desition = 0;
                        end
                        else begin
                            rx_desition = 1;
                        end

                        if (clk_counter >= BAUD_RATE+BAUD_RATE-1) begin
                            clk_counter <= 0;
                            bit_index <= bit_index + 1;

                            if (bit_index >= 9) begin
                                state <= RX_DONE;
                                data_received <= rx_shift_reg[7:0];
                                rx_done <= 1;
                            end
                            else begin
                                zero_counter <= 0;
                                one_counter <= 0;
                                rx_shift_reg <= {rx_desition, rx_shift_reg[8:1]};
                            end
                        end 
                        else begin
                            clk_counter <= clk_counter + 1;
                        end
                    end

                    RX_DONE: begin
                        bit_index <= 0;     
                        clk_counter <= 0;
                        rx_done <= 0;
                        zero_counter <= 0;
                        one_counter <= 0;
                        state <= IDLE;
                    end
                endcase
        end
endmodule