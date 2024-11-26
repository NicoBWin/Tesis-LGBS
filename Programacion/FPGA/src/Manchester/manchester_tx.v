module manchester_tx (
    input wire clk,            // Clock signal
    input wire reset,
    input wire [7:0] data_to_tx,  // 8-bit data in
    input wire start_tx,       // Start transmission
    output wire tx,             
    output reg tx_busy         // Indicates transmission is in progress
);

    reg [9:0] encoded_data;

    // Proceso principal
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            encoded_data <= 10'b0;
            manchester_out <= 10'b0;
        end else if (data_valid) begin
            // Lógica de codificación 8b/10b
            encoded_data <= encode_8b10b(data_in);
            manchester_out <= encoded_data;
        end
    end

endmodule