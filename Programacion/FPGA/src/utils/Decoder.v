/*
 * Este módulo implementa un decodificador de 3 a 8. Toma tres bits de entrada y genera un 1 en una unica salida.
 * Cada salida corresponde a una combinación única de las entradas.
 */

module Decoder(
  input wire b2,
  input wire b1,
  input wire b0_LSB,
  output wire Out1,
  output wire Out2,
  output wire Out3,
  output wire Out4,
  output wire Out5,
  output wire Out6,
  output wire Out7,
  output wire Out8
);

  wire Logical_Operator8_out1;
  wire Logical_Operator9_out1;
  wire Logical_Operator10_out1;
  wire Logical_Operator_out1;
  wire Logical_Operator1_out1;
  wire Logical_Operator2_out1;
  wire Logical_Operator3_out1;
  wire Logical_Operator4_out1;
  wire Logical_Operator5_out1;
  wire Logical_Operator6_out1;
  wire Logical_Operator7_out1;

  // LSB


  assign Logical_Operator8_out1 =  ~ b0_LSB;
  assign Logical_Operator9_out1 =  ~ b1;
  assign Logical_Operator10_out1 =  ~ b2;
  assign Logical_Operator_out1 = Logical_Operator10_out1 & (Logical_Operator8_out1 & Logical_Operator9_out1);

  assign Out1 = Logical_Operator_out1;
  assign Logical_Operator1_out1 = Logical_Operator10_out1 & (b0_LSB & Logical_Operator9_out1);

  assign Out2 = Logical_Operator1_out1;
  assign Logical_Operator2_out1 = Logical_Operator10_out1 & (Logical_Operator8_out1 & b1);

  assign Out3 = Logical_Operator2_out1;
  assign Logical_Operator3_out1 = Logical_Operator10_out1 & (b0_LSB & b1);

  assign Out4 = Logical_Operator3_out1;
  assign Logical_Operator4_out1 = b2 & (Logical_Operator8_out1 & Logical_Operator9_out1);

  assign Out5 = Logical_Operator4_out1;
  assign Logical_Operator5_out1 = b2 & (b0_LSB & Logical_Operator9_out1);

  assign Out6 = Logical_Operator5_out1;
  assign Logical_Operator6_out1 = b2 & (Logical_Operator8_out1 & b1);

  assign Out7 = Logical_Operator6_out1;
  assign Logical_Operator7_out1 = b2 & (b0_LSB & b1);

  assign Out8 = Logical_Operator7_out1;

endmodule  // Decoder

