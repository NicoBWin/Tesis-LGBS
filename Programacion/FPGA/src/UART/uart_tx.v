/*
 * Este módulo implementa un transmisor UART. Fue probado hasta 6Mb/s utilizando un reloj de 24MHz.
 * Para usarlo, enviamos la información a transmitir a data_to_tx y ponemos start_tx en 1.
 * Automáticamente, tx_busy se pone en 1 indicando que la transmisión está en progreso.
 * Un ciclo de reloj después, ya es posible cambiar el valor de data_to_tx. El bit tx_busy se pone en 1
 * hasta que termine la transmisión, momento en el cual se pone en 0.
 */

`include "./src/UART/UART.vh"

module uart_tx(
    input wire clk,             
    input wire reset,
    input wire [7:0] data_to_tx, // Datos a transmitir de 8 bits
    input wire start_tx,         // Señal de inicio de transmisión
    output wire tx,              // Señal del modulo donde se envian los datos
    output reg tx_busy           // Señal que indica que la transmisión está en progreso
);

    // Configuración
    parameter BAUD_RATE = `BAUD6M_CLK24M;      // Baud rate
    parameter PARITY = 0;                      // Configuracion de la paridad (0 para paridad par, 1 para impar)
    parameter STOP_SIZE = 2;                   // Cantidad de bits de stop

    // Estados de la máquina de estados
    localparam INIT = 2'b00;
    localparam IDLE = 2'b01;
    localparam TX   = 2'b10;

    localparam PKG_SIZE = STOP_SIZE + 9;        // Tamaño del paquete a enviar

    reg [PKG_SIZE-1:0] to_transmit;             // STOP(N), PARITY(1), DATA(8), START(1)
    reg [$clog2(PKG_SIZE)-1:0] bit_index;       // Indice del bit actual
    reg [1:0] state = INIT;

    wire parity;                  
    wire baud_clk;
    
    assign tx = to_transmit[0];                             // Señal de transmisión
    assign parity = PARITY ? ~(^data_to_tx) :  ^data_to_tx; // Generacion del bit de paridad
    
    // Generacion del reloj de baudios
    clk_divider #(BAUD_RATE) baudrate_gen(
        .clk_in(clk),
        .reset(reset),
        .clk_out(baud_clk)
    );

    always @(posedge baud_clk)
        begin
            if(reset) begin
                state <= INIT;
                tx_busy <= 0;
                bit_index <= 0;
                to_transmit <= {PKG_SIZE{1'b1}};
            end
            else
                case (state)
                    // Inicializacion
                    INIT: begin
                        tx_busy <= 0;
                        bit_index <= 0;
                        to_transmit <= {PKG_SIZE{1'b1}};
                        state <= IDLE;
                    end

                    // Espera de inicio
                    IDLE: begin
                        bit_index <= 1;
                        if (start_tx) begin
                            state <= TX;
                            tx_busy <= 1;
                            to_transmit <= {{STOP_SIZE{1'b1}}, parity, data_to_tx, 1'b0};
                        end
                    end

                    // Transmision
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