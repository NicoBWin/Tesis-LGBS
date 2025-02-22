`include "./src/timer/timer.vh"

module timer #(parameter MAX_COUNT = `SEC_1)
(
    input wire clk,         // Input clock
    input wire reset,       // Reset signal
    input wire start,       // Start signal
    output reg done         // Done signal
);

    reg [$clog2(MAX_COUNT)-1:0] counter; // Counter

    always @(posedge clk) begin
        if (reset) begin
            // Reset everything
            done <= 0;
            counter <= 0;
        end 
        else if (start) begin
            if (done == 1) begin
                done <= 0;
                counter <= 0;
            end 
            else if (counter < MAX_COUNT - 1) begin
                counter <= counter + 1;
            end 
            else begin
                done <= 1;
                counter <= 0;
            end
        end
    end

endmodule