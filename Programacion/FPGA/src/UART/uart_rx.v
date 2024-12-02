/*
    A cada modulo va a ir un cable ethernet que contiene el tx y rx de cada modulo. Como necesitamos
    que cada modulo trabaje a minimo 250k y son 11 bits, entonces 250k*11=2.75Mbits/seg minimo. Tener
    en cuenta que las palabras de 11 bits contienen en sus datos los bits para el ECC. Al menos 16 codigos.
    necesitamos (4bits de data).
*/

`include "./src/UART/baudgen.vh"

module uart_rx(
    input wire clk,            // Clock signal
    input wire reset,
    input wire rx,             // UART receive line
    output reg [7:0] data_received,   // 8-bit data out
    output reg rx_done,         // Indicates reception is complete
    output wire parity_error     // Flag that indicates that there was a parity error
);

    // Config
    parameter BAUD_RATE = `BAUD6M_CLK24M;     // Desired baud rate
    parameter PARITY = 0;           // 0 for even parity, 1 for odd parity
    
    // States
    localparam INIT = 2'b00;
    localparam IDLE = 2'b01;
    localparam RX   = 2'b10;

    reg [3:0] clk_counter;
    reg [8:0] rx_shift_reg;         // PARITY, DATA
    reg [3:0] bit_index;            // Index for the bits being received
    reg [1:0] state = INIT;

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
                        data_received <= {8{1'b0}};
                        state <= IDLE;
                    end

                    IDLE: begin
                        rx_done <= 0;
                        if (!rx) begin
                            bit_index <= 0; // Recibimos el start
                            state <= RX;
                        end
                    end

                    //0000 1_11 0_00 0_00

                    RX: begin
                        if (clk_counter >= BAUD_RATE+1) begin
                            if (bit_index >= 9) begin
                                state <= IDLE;
                                data_received <= rx_shift_reg[7:0];
                                rx_done <= 1;
                            end
                            else begin
                                bit_index <= bit_index + 1;
                                rx_shift_reg[bit_index] <= rx;
                            end

                            clk_counter <= 0;
                        end
                        else begin
                            clk_counter <= clk_counter + 1;
                        end
                    end
                endcase
        end
endmodule