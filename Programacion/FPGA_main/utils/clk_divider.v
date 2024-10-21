module clk_divider #(parameter BAUD_DIV = 16)
(
    input wire clk_in,       // Input clock
    output reg clk_out       // Output divided clock
);

    reg [$clog2(BAUD_DIV)-1:0] counter = 0; // Counter to divide the clock

    always @(posedge clk_in) begin
        if (counter == 0) begin
            clk_out <= 1'b0;   // Initialize clk_out to a known state
        end
        else if (counter >= BAUD_DIV - 1) begin
            counter <= 0;
            clk_out <= ~clk_out;
        end 
        else begin
            counter <= counter + 1;
        end
    end

endmodule