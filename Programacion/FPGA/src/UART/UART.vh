
/*
    La nomenclatura de los valores de los baudios es:
    BAUDn_CLKm, donde n es el valor del baud rate y m es la frecuencia del reloj de la FPGA.
    
    Para el cálculo de los valores de los baudios se puede hacer:
    numero = m / (2 * n)
*/

// Para un reloj de 48MHz
`define BAUD6M_CLK48M 4'd4
`define BAUD3M_CLK48M 4'd8
`define BAUD2M_CLK48M 4'd12
`define BAUD1M_CLK48M 5'd24
`define BAUD115200_CLK48M 8'd208

// Para un reloj de 24MHz
`define BAUD1M_CLK24M 4'd12
`define BAUD2M_CLK24M 4'd6
`define BAUD3M_CLK24M 4'd4
`define BAUD4M_CLK24M 4'd3
`define BAUD6M_CLK24M 4'd2
`define BAUD12M_CLK24M 4'd1

// Para un reloj de 12MHz
`define BAUD6M_CLK12M 4'd1
