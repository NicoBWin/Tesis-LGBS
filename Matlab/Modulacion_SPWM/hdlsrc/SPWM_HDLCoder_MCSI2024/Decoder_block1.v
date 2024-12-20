// -------------------------------------------------------------
// 
// File Name: hdlsrc\SPWM_HDLCoder_MCSI2024\Decoder_block1.v
// Created: 2024-12-20 19:47:54
// 
// Generated by MATLAB 9.10 and HDL Coder 3.18
// 
// -------------------------------------------------------------


// -------------------------------------------------------------
// 
// Module: Decoder_block1
// Source Path: SPWM_HDLCoder_MCSI2024/SPWM_3mod_hdl/tabla_spwm_g2/Decoder
// Hierarchy Level: 2
// 
// -------------------------------------------------------------

`timescale 1 ns / 1 ns

module Decoder_block1
          (b2,
           b1,
           b0_LSB,
           Out2,
           Out3,
           Out4,
           Out5,
           Out6,
           Out7);


  input   b2;
  input   b1;
  input   b0_LSB;
  output  Out2;
  output  Out3;
  output  Out4;
  output  Out5;
  output  Out6;
  output  Out7;


  wire Logical_Operator9_out1;
  wire Logical_Operator10_out1;
  wire Logical_Operator1_out1;
  wire Logical_Operator8_out1;
  wire Logical_Operator2_out1;
  wire Logical_Operator3_out1;
  wire Logical_Operator4_out1;
  wire Logical_Operator5_out1;
  wire Logical_Operator6_out1;

  // LSB


  assign Logical_Operator9_out1 =  ~ b1;


  assign Logical_Operator10_out1 =  ~ b2;


  assign Logical_Operator1_out1 = Logical_Operator10_out1 & (b0_LSB & Logical_Operator9_out1);


  assign Out2 = Logical_Operator1_out1;

  assign Logical_Operator8_out1 =  ~ b0_LSB;


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

endmodule  // Decoder_block1

