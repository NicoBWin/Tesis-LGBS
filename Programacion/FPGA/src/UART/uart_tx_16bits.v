module uart_tx_16bit(
    input wire clk,             // Clock signal
    input wire reset,
    input wire [15:0] data_to_tx, // 16-bit data to send
    input wire start_tx,        // Start transmission
    output wire tx,             // UART transmit line
    output reg tx_busy         // UART busy status
);

    // Internal signals for MSB and LSB
    reg [7:0] msb_data, lsb_data;
    wire msb_tx_busy, lsb_tx_busy;

    // Instantiate uart_tx for MSB
    uart_tx msb_uart_tx (
        .clk(clk),
        .reset(reset),
        .data_to_tx(msb_data),
        .start_tx(start_tx && !tx_busy),  // Only start when not busy
        .tx(tx),                         // Shared tx line
        .tx_busy(msb_tx_busy)
    );

    // Instantiate uart_tx for LSB
    uart_tx lsb_uart_tx (
        .clk(clk),
        .reset(reset),
        .data_to_tx(lsb_data),
        .start_tx(start_tx && tx_busy),  // Start LSB transmission after MSB
        .tx(tx),                         // Shared tx line
        .tx_busy(lsb_tx_busy)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tx_busy <= 0;
            msb_data <= 8'b0;
            lsb_data <= 8'b0;
        end else begin
            if (start_tx && !tx_busy) begin
                // Load MSB and LSB from 16-bit input data
                msb_data <= data_to_tx[15:8];
                lsb_data <= data_to_tx[7:0];
                tx_busy <= 1;  // Indicate that transmission is ongoing
            end

            // After MSB is transmitted, start LSB transmission
            if (msb_tx_busy && !lsb_tx_busy) begin
                tx_busy <= 1;
            end

            // Once both MSB and LSB are transmitted, mark tx as not busy
            if (!msb_tx_busy && !lsb_tx_busy) begin
                tx_busy <= 0;
            end
        end
    end

endmodule
