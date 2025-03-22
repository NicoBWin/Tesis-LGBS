/*
 * Este módulo implementa un receptor UART. Fue probado hasta 6Mbps utilizando un reloj de 24MHz.
 * Cada módulo se conecta mediante un cable ethernet que contiene las líneas tx y rx. La señal 
 * rx se conecta a la entrada rx de la FPGA donde se recibira la señal de UART. En el bus de 
 * salida data_received se obtiene el byte recibido y en rx_done se obtiene un pulso que indica
 * que se recibió un byte completo. En parity_error se obtiene un pulso que indica que hubo un
 * error de paridad en la recepción.
 */

`include "./src/UART/UART.vh"

module uart_rx(
    input wire clk,        
    input wire reset,
    input wire rx,                  // Linea de recepcion de UART
    output reg [7:0] data_received, // Datos de 8 bits recibidos
    output reg rx_done,             // Pulso que indica que se recibio un byte completo
    output wire parity_error        // Pulso que indica que se ocurrio un error en la paridad
);

    // Configuracion
    parameter BAUD_RATE = `BAUD6M_CLK24M;     // Tasa de bits
    parameter PARITY = 0;                     // Configuracion de la paridad (0 para paridad par, 1 para impar)
    
    // Estados de la maquina de estados
    localparam INIT         = 3'b000;
    localparam IDLE         = 3'b001;
    localparam START        = 3'b010;
    localparam CHECK_START  = 3'b011;
    localparam RX           = 3'b100;
    localparam RX_DONE      = 3'b101;

    wire parity_error_done;

    reg [5:0] clk_counter;          // Contador de recepcion de datos. IMPORTANTE: El tamaño depende de la tasa de baudios.
    reg [8:0] rx_shift_reg;         // Registros temporales para la paridad (1 bit) y el byte recibido (8 bits).
    reg [3:0] bit_index;            // Indice del bit recibido
    reg [2:0] state = INIT;

    reg [5:0] zero_counter = 0;     // Contador de bits en 0
    reg [5:0] one_counter = 0;      // Contador de bits en 1
    reg rx_decision = 0;            // Decision de bit recibido
    
    assign parity_error_done = PARITY ? ~(^rx_shift_reg) : (^rx_shift_reg); // Calculo de la paridad
    assign parity_error = rx_done & parity_error_done;                      // Señal de error de paridad

    always @(posedge clk) 
        begin
            if(reset) begin
                state <= INIT;
            end
            else
                case (state)

                    // Inicializacion
                    INIT: begin
                        bit_index <= 0;
                        rx_done <= 0;
                        clk_counter <= 0;
                        rx_shift_reg <= {9{1'b0}};
                        state <= IDLE;
                    end

                    // Espera de inicio
                    IDLE: begin
                        if (!rx) begin  // Se detecto el start
                            state <= CHECK_START;
                        end
                    end

                    // Verificacion de inicio
                    CHECK_START: begin
                        if (!rx) begin  // Se checkeo que sea start nuevamente (2 muestras)
                            state <= START; 
                        end
                        else begin
                            state <= IDLE;
                        end
                    end

                    // Recepcion del bit de start
                    START: begin
                        if (clk_counter >= BAUD_RATE+BAUD_RATE-2) begin
                            state <= RX;
                            clk_counter <= 0;
                        end 
                        else begin
                            clk_counter <= clk_counter + 1;
                        end
                    end

                    // Recepcion de datos
                    RX: begin

                        // Contador de bits
                        if (rx) begin
                            one_counter <= one_counter + 1;
                        end
                        else begin
                            zero_counter <= zero_counter + 1;
                        end
                        
                        // Regla de decision
                        if (zero_counter > one_counter) begin
                            rx_decision = 0;
                        end
                        else begin
                            rx_decision = 1;
                        end

                        // Para cada bit recibido   
                        if (clk_counter >= BAUD_RATE+BAUD_RATE-1) begin
                            clk_counter <= 0;
                            bit_index <= bit_index + 1;

                            // Si se recibieron los 8 bits
                            if (bit_index >= 9) begin
                                state <= RX_DONE;
                                data_received <= rx_shift_reg[7:0];
                                rx_done <= 1;
                            end
                            else begin
                                zero_counter <= 0;
                                one_counter <= 0;
                                rx_shift_reg <= {rx_decision, rx_shift_reg[8:1]}; // Guardar el bit recibido
                            end
                        end 
                        else begin
                            clk_counter <= clk_counter + 1; // Contar el tiempo de recepcion
                        end
                    end

                    // Recepcion completa
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