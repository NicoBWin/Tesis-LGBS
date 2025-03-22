module glitch_filter #(
    parameter integer DATA_WIDTH = 6,
    parameter integer N          = 25
)(
    input  wire                  clk,
    input  wire                  reset,
    input  wire [DATA_WIDTH-1:0] in_signal,
    output reg  [DATA_WIDTH-1:0] out_signal
);

    // 'stable_state' guardará el valor “estable” actual, bit a bit.
    reg [DATA_WIDTH-1:0] stable_state = 0;

    // Array de contadores, uno por cada bit,
    // para contar cuántos ciclos lleva la señal de ese bit
    // distinta de su valor estable.
    reg [3:0] counter = 0;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            // Al reset, tomamos la entrada como estado inicial.
            // (Esto puede modificarse si se desea un valor fijo en reset).
            out_signal  <= 6'b100100;
            stable_state  <= 6'b100100;
            counter <= 0;
        end else begin
            if (in_signal != stable_state) begin
                // Acumulamos ciclos
                counter <= counter + 1'b1;

                if (counter == (N - 1)) begin
                    // Aceptamos la transición
                    out_signal   <= in_signal;
                    stable_state   <= in_signal;
                    // Reiniciamos el contador para este bit
                    counter <= 0;
                end

            end 
            else begin
                // En caso de que no difiera, reseteamos el contador
                // (no hay transición que validar).
                counter <= 0;
            end
        end
    end

endmodule