/* 
 * Este módulo implementa una máquina de estados para manejar la transferencia de datos a través de SPI en 16 bits
 * tal como es necesario para el funcionamiento del sistema. Utiliza un reloj principal, señales de reset y 
 * start_transfer para controlar el flujo de datos.
 *
 * La máquina de estados maneja la recepción de datos SPI y los almacena en registros internos.
 * Se usa proporcionando señales de reloj, reset, y start_transfer, y recibe datos a través de miso_1.
 * Los datos recibidos se dividen en sin_index (12 bits de indice de tabla) y uart_id (4 bits).
 */

module SPI_request_data (
    input wire clk,                 
    input wire reset,               
    input wire start_transfer,      // Señal en alto para comenzar la transferencia
    input wire miso_1,              // SPI MISO
    output wire spi_clk_1,          // SPI Clock
    output wire cs_1,               // Chip Select

    output reg data_valid,          // Señal en alto para indicar que el dato es valido
    output wire [11:0] sin_index,   // 12 bits para el indice de senoidal (MSB)
    output wire [3:0] uart_id       // 4 bits para el UART ID (LSB)
);

    // Estados de la máquina de estados
    parameter INIT = 2'b00;
    parameter TRANSF_1_WAITING = 2'b01;
    parameter TRANSF_2_WAITING = 2'b10;
    parameter TRANSF_RESET = 2'b11;

    // Registros para la máquina de estados
    reg [1:0] state = INIT;
    reg [15:0] data_rx = 0;         // Para almacenar datos SPI recibidos (16 bits)
    reg start_transfer_a;
    
    // Señales de transferencia SPI
    wire transfer_done;
    wire [7:0] data_received;

    // Extraer sin_index (12 LSB) y uart_id (4 MSB)
    assign sin_index = data_rx[11:0]; // 12-bit sin_index
    assign uart_id = data_rx[15:12];    // 4-bit uart_id

    // Instanciación del master SPI (no se usa TX aquí)
    SPI_Master_With_Single_CS u_spi (
        .i_Rst_L(~reset),              // Reset signal
        .i_Clk(clk),                  // Clock signal
        .i_TX_Count(2'd2),               // Two bytes per transfer
        .i_TX_Byte(8'd33),               // Example data to send
        .i_TX_DV(start_transfer_a),     // Data valid signal for transmission
        .o_RX_DV(transfer_done),      // Data valid signal for received data
        .o_RX_Byte(data_received),    // Received byte
        .o_SPI_Clk(spi_clk_1),        // SPI clock output
        .i_SPI_MISO(miso_1),          // MISO input
        .o_SPI_CS_n(cs_1)             // Chip Select
    );
    
    // Máquina de estados
    always @(posedge clk) begin
        if (reset) begin
            state <= INIT;
            data_valid <= 0;
            data_rx <= 0;
        end else begin
            case (state)

                // Inicialización
                INIT: begin
                    data_valid <= 0; 
                    start_transfer_a <= 0;
                    if(start_transfer) begin
                        state <= TRANSF_1_WAITING;
                        start_transfer_a <=1;
                    end
                end

                // Espera del primer byte
                TRANSF_1_WAITING: begin
                    start_transfer_a <= 0;

                    // Si se completo la transferencia
                    if (transfer_done) begin
                        state <= TRANSF_2_WAITING;
                        data_rx[15:8] <= data_received;   // Almacenar primer byte
                        start_transfer_a <= 1;
                    end
                end

                // Espera del segundo byte
                TRANSF_2_WAITING: begin
                    start_transfer_a <= 0;

                    // Si se completo la transferencia
                    if (transfer_done) begin
                        state <= TRANSF_RESET;
                        data_rx[7:0] <= data_received;    // Almacenar segundo byte
                        data_valid <= 1;

                    end
                end

                // Reinicio
                TRANSF_RESET: begin
                    if (cs_1) begin
                        state <= INIT;
                    end
                end
            endcase
        end
    end

endmodule
