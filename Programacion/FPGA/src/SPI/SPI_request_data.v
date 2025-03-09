module SPI_request_data (
    input wire clk,                 // Main clock
    input wire reset,               // Reset signal
    input wire start_transfer,
    input wire miso_1,              // SPI MISO (Master In Slave Out)
    output wire spi_clk_1,          // SPI Clock
    output wire cs_1,               // Chip Select

    output reg data_valid,
    output wire [11:0] sin_index,        // 12 bits for Sin Index (MSB)
    output wire [3:0] uart_id           // 4 bits for UART ID (LSB)
);

    // State machine states
    parameter INIT = 2'b00;
    parameter TRANSF_1_WAITING = 2'b01;
    parameter TRANSF_2_WAITING = 2'b10;
    parameter TRANSF_RESET = 2'b11;

    // Registers for state machine
    reg [1:0] state = INIT;
    reg [15:0] data_rx = 0;         // To store received SPI data (16 bits)
    reg start_transfer_a;
    
    // SPI transfer signals
    wire transfer_done;
    wire [7:0] data_received;

    // Extract sin_index (12 MSB) and uart_id (4 LSB)
    assign sin_index = data_rx[15:4]; // 12-bit sin_index
    assign uart_id = data_rx[3:0];    // 4-bit uart_id

    // SPI Master instantiation (no TX used here)
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
    
    //TODO: revisar sensibilidad del reset
    always @(posedge clk) begin
        if (reset) begin
            state <= INIT;
            data_valid <= 0;
            data_rx <= 0;
        end else begin
            case (state)
                INIT: begin
                    data_valid <= 0; 
                    start_transfer_a <= 0;
                    if(start_transfer) begin
                        state <= TRANSF_1_WAITING;
                        start_transfer_a <=1;
                    end
                end

                TRANSF_1_WAITING: begin
                    start_transfer_a <= 0;
                    if (transfer_done) begin
                        state <= TRANSF_2_WAITING;
                        data_rx[15:8] <= data_received;   // Store first byte
                        start_transfer_a <= 1;
                    end
                end

                TRANSF_2_WAITING: begin
                    start_transfer_a <= 0;
                    if (transfer_done) begin
                        state <= TRANSF_RESET;
                        data_rx[7:0] <= data_received;    // Store second byte
                        data_valid <= 1;

                    end
                end

                TRANSF_RESET: begin
                    if (cs_1) begin
                        state <= INIT;
                    end
                    
                end
            endcase
        end
    end

endmodule
