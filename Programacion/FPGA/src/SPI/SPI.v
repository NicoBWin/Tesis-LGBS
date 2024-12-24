`include "./src/SPI/SPI.vh"

module SPI(
    input wire clk,            // System clock
    input wire reset,          // System reset

    input wire [15:0] data_to_rx, // Data to be received from external device
    output reg [15:0] data_to_tx, // Data to be transmitted to external device

    output reg sclk,     // SPI clock
    input wire miso,     // Master-In Slave-Out
    output reg cs        // Chip select
);

    // Parameters
    parameter SCLK_FREQ = 4800000; // 4 MHz clock for SPI
    parameter SYS_FREQ = 48000000; // Assume 50 MHz system clock

    // Internal signals
    reg [15:0] shift_reg;       // Shift register for SPI communication
    reg [3:0] bit_counter;      // Counter for tracking bits
    reg sclk_en;                // Enable SCLK toggle

    // State machine for SPI
    typedef enum reg [1:0] {
        IDLE,
        SELECT,
        TRANSFER,
        DESELECT
    } spi_state_t;

    spi_state_t state;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            CS <= 2'b11; // Both devices deselected
            bit_counter <= 0;
            shift_reg <= 0;
            data_to_tx <= 16'b0;
        end else begin
            case (state)
                IDLE: begin
                    if (|data_to_rx) begin // Check if there's data to send
                        CS <= 2'b10; // Select device 0 (example)
                        state <= SELECT;
                    end
                end

                SELECT: begin
                    if (sclk_en) begin
                        shift_reg <= data_to_rx; // Load data to shift register
                        bit_counter <= 15;
                        state <= TRANSFER;
                    end
                end

                TRANSFER: begin
                    if (sclk_en) begin
                        if (SCLK == 0) begin
                            // On falling edge, capture MISO and shift data
                            shift_reg <= {shift_reg[14:0], MISO[0]};
                        end else begin
                            // On rising edge, shift out data
                            data_to_tx <= shift_reg;
                        end

                        if (bit_counter == 0) begin
                            state <= DESELECT;
                        end else begin
                            bit_counter <= bit_counter - 1;
                        end
                    end
                end

                DESELECT: begin
                    CS <= 2'b11; // Deselect all devices
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
