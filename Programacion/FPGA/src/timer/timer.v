`include "./src/timer/timer.vh"

/* 
 * Este módulo implementa un temporizador que cuenta hasta un valor máximo definido por el parámetro MAX_COUNT.
 * Utiliza una señal de reloj, una señal de reset y una señal de inicio para controlar el temporizador.
 * Cuando el contador alcanza el valor máximo, la señal done se activa. La señal done se activa durante
 * un unico ciclo de reloj y se desactiva en el siguiente. Para comenzar nuevamente el temporizador, la señal
 * la señal de inicio debe ser puesta en alto durante al menos 1 ciclo de reloj.
 */

module timer #(parameter MAX_COUNT = `SEC_1)
(
    input wire clk,         // Reloj de entrada
    input wire reset,       // Señal de reset
    input wire start,       // Señal de inicio
    output reg done         // Señal de finalización
);

    reg [$clog2(MAX_COUNT)-1:0] counter = 0; // Contador

    always @(posedge clk) begin
        if (reset) begin // Reiniciar el temporizador
            done <= 0;
            counter <= 0;
        end 
        else if (start) begin // Comenzar el temporizador
            if (done == 1) begin
                done <= 0;
                counter <= 0;
            end 
            else if (counter < MAX_COUNT - 1) begin // Contar hasta MAX_COUNT
                counter <= counter + 1;
            end 
            else begin // Contador alcanzó MAX_COUNT
                done <= 1;
                counter <= 0;
            end
        end
    end

endmodule