module clk_divider #(parameter BAUD_DIV = 16)
(
    input wire clk_in,       // Input clock
    output reg clk_out       // Output divided clock
);

    reg [$clog2(BAUD_DIV)-1:0] counter; // Counter to divide the clock

    always @(posedge clk_in) begin
        if (counter >= BAUD_DIV - 1) begin
            counter <= 0;
            clk_out <= ~clk_out;
        end 
        else begin
            counter <= counter + 1;
        end
    end

endmodule