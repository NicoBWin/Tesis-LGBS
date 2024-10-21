/*
    Para usarlo, leemos data_received donde esta la data cuando donde = 1 o en el rising edge.
    Si ocurre un error de paridad, parity_error = 1 por un ciclo de clk indicando que el dato 
    recibido no es valido.
*/

/*
    A cada modulo va a ir un cable ethernet que contiene el tx y rx de cada modulo. Como necesitamos
    que cada modulo trabaje a minimo 250k y son 11 bits, entonces 250k*11=2.75Mbits/seg minimo. Tener
    en cuenta que las palabras de 11 bits contienen en sus datos los bits para el ECC. Al menos 16 codigos.
    necesitamos (4bits de data).
*/

`include "UART/baudgen.vh"

module uart_rx(
    input wire clk,            // Clock signal
    input wire rx,             // UART receive line
    output wire [7:0] data_received,   // 8-bit data out
    output reg rx_done,         // Indicates reception is complete
    output wire parity_error     // Flag that indicates that there was a parity error
);

    // Config
    parameter CLK_FREQ = 24000000;  // System clock frequency (e.g., 50 MHz)
    parameter BAUD_RATE = `BAUD8M;     // Desired baud rate
    parameter PARITY = 0;           // 0 for even parity, 1 for odd parity
    
    // States
    localparam INIT = 2'b00;
    localparam IDLE = 2'b01;
    localparam RX   = 2'b10;

    wire baud_clk;
    reg [9:0] rx_shift_reg;         // PARITY, DATA, START
    reg [3:0] bit_index;            // Index for the bits being received
    reg [1:0] state = INIT;

    assign data_received = rx_shift_reg[8:1];
    assign parity_error = PARITY ? ~(^rx_shift_reg[9:1]) : (^rx_shift_reg[9:1]);
    
    clk_divider #(BAUD_RATE) baudrate_gen(
        .clk_in(clk),
        .clk_out(baud_clk)
    );

    always @(posedge baud_clk) 
        begin
            case (state)
                INIT: begin
                    bit_index <= 0;
                    rx_done <= 0;
                    rx_shift_reg <= {10{1'b0}};
                    state <= IDLE;
                end

                IDLE: begin
                    if (!rx) begin
                        rx_done <= 0;
                        bit_index <= 1;
                        rx_shift_reg[0] <= 0;
                        state <= RX;
                    end
                end

                RX: begin 
                    if (bit_index >= 10) begin
                        state <= IDLE;
                        rx_done <= 1;
                    end
                    else begin
                        bit_index <= bit_index + 1;
                        rx_shift_reg[bit_index] <= rx;
                    end
                end
            endcase
        end
endmodule
