/*
 * Este módulo implementa un contador parametrizable. El contador se incrementa en cada ciclo de reloj
 * cuando la señal de habilitación está activa. Cuando el contador alcanza el valor máximo especificado
 * por max_count, se reinicia a 0.
 */

module counter (
    input clk,               
    input reset,              
    input enable,                   // Habilitación del contador
    input [WIDTH-1:0] max_count,    // Valor máximo del contador
    output reg [WIDTH-1:0] count    // Salida del contador
);
    parameter WIDTH = 8;       // Tamaño del contador

    always @(posedge clk) begin
        if (reset) begin
            count <= 0;        
        end else if (enable) begin
            if (count == max_count)
                count <= 0;    
            else
                count <= count + 1;
        end
    end
endmodule