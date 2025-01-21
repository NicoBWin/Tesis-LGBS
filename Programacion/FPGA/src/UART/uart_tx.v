/*
    Para usarlo, enviamos la informacion a transmitir a data_to_tx y ponemos start_tx en 1. 
    Automaticamente el tx_busy = 1 indicando que la transmision esta en progreso. 
    Un clk despues ya es posible cambiar el valor de data_to_tx. El bit de tx_busy se pone en 1 y 
    hasta que termine la transmision que se pone en 0.
*/

`include "./src/UART/UART.vh"

module uart_tx(
    input wire clk,             // Clock signal
    input wire reset,
    input wire [7:0] data_to_tx,// 8-bit data in
    input wire start_tx,        // Start transmission
    output wire tx,             // UART transmit line
    output reg tx_busy
);

    // Config
    parameter BAUD_RATE = `BAUD6M_CLK24M;      // Desired baud rate
    parameter PARITY = 0;               // 0 for even parity, 1 for odd parity

    // States
    localparam INIT = 2'b00;
    localparam IDLE = 2'b01;
    localparam TX   = 2'b10;

    localparam STOP_SIZE = 1;   //Creo que si cambiamos esto se rompe el transmisor
    localparam PKG_SIZE = STOP_SIZE + 9;

    reg [PKG_SIZE-1:0] to_transmit;         // STOP(N), PARITY(1), DATA(8), START(0)
    reg [$clog2(PKG_SIZE)-1:0] bit_index;            // Index for the bits being sent
    reg [1:0] state = INIT;

    wire parity;                    // Current parity
    wire baud_clk;
    
    assign tx = to_transmit[0];
    assign parity = PARITY ? ~(^data_to_tx) :  ^data_to_tx;  // XOR for even parity, inverted XOR for odd parity
    
    clk_divider #(BAUD_RATE) baudrate_gen(
        .clk_in(clk),
        .reset(reset),
        .clk_out(baud_clk)
    );

    always @(posedge clk)
        begin
            if(reset) begin
                state <= IDLE;
                tx_busy <= 0;
                bit_index <= 0;
                to_transmit <= {PKG_SIZE{1'b1}};
            end
            else
                case (state)
                    IDLE: begin
                        if (start_tx) begin
                            tx_busy <= 1;
                            bit_index <= 1;
                            to_transmit <= {{STOP_SIZE{1'b1}}, parity, data_to_tx, 1'b0};
                            state <= TX;
                        end
                    end

                    TX: begin
                        to_transmit <= {1'b1, to_transmit[PKG_SIZE-1:1]};
                        if (bit_index >= PKG_SIZE) begin 
                            state <= IDLE;
                            tx_busy <= 0;
                        end
                        else begin
                            bit_index <= bit_index + 1;
                        end
                    end
                endcase
        end
endmodule