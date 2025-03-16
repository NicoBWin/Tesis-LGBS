/* 
 * Este módulo implementa una memoria RAM para almacenar y leer valores de una onda senoidal.
 * Utiliza una dirección de 12 bits para acceder a la memoria y proporciona tres salidas de datos de 7 bits.
 * La memoria se inicializa con datos de un archivo hexadecimal.
 */

module PRAM (
    input wire [11:0] address, // Línea de dirección de 12 bits
    output reg [6:0] sine_A,   // Salida de datos de 7 bits
    output reg [6:0] sine_B,   // Salida de datos de 7 bits
    output reg [6:0] sine_C    // Salida de datos de 7 bits
);

    // Declaración del contenido de la RAM
    reg [6:0] memory [0:(`SIN_SIZE - 1)];

    // Inicialización de la RAM con datos
    initial begin
        $readmemh("./src/PRAM/sine_wave.hex", memory); // Cargar datos desde un archivo hexadecimal
    end

    // Operación de lectura
    always @(address) begin
        sine_A <= memory[address];
        sine_B <= memory[(address) < `SIN_SIZE - `SIN_SIZE / 3 ? address + `SIN_SIZE / 3 :  address - (`SIN_SIZE - 1) + `SIN_SIZE / 3];
        sine_C <= memory[(address) < `SIN_SIZE - 2 * `SIN_SIZE / 3 ? address + 2 * `SIN_SIZE / 3 :  address - (`SIN_SIZE - 1) + 2 * `SIN_SIZE / 3];
    end

endmodule