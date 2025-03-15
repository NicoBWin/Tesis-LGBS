
/*
 * Este módulo implementa un divisor de reloj. Divide la frecuencia del reloj de entrada por el valor del parámetro BAUD_DIV.
 * La salida es un reloj de frecuencia dividida segun la expresion:
 * f_out = f_in / (BAUD_DIV + 1)
 */

module clk_divider #(parameter BAUD_DIV = 16)
(   
    input wire clk_in,       // Reloj de entrada
    input wire reset,        // Señal de reset
    output reg clk_out       // Reloj de salida dividido
);

    reg [$clog2(BAUD_DIV)-1:0] counter; // Contador para dividir el reloj

    always @(posedge clk_in) begin
        if (reset) begin
            counter <= 0;
            clk_out <= 0;
        end
        else if (counter >= BAUD_DIV - 1) begin // Dividir el reloj
            counter <= 0;
            clk_out <= ~clk_out;
        end 
        else begin
            counter <= counter + 1;  
        end
    end

endmodule