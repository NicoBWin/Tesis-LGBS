// -------------------------------------------------------------
// 
// File Name: hdlsrc\SPWM_HDLCoder_MCSI2024\tabla_spwm_g2.v
// Created: 2024-12-20 19:47:54
// 
// Generated by MATLAB 9.10 and HDL Coder 3.18
// 
// -------------------------------------------------------------


// -------------------------------------------------------------
// 
// Module: tabla_spwm_g2
// Source Path: SPWM_HDLCoder_MCSI2024/SPWM_3mod_hdl/tabla_spwm_g2
// Hierarchy Level: 1
// 
// -------------------------------------------------------------

`timescale 1 ns / 1 ns

module tabla_spwm_g2
          (In2,
           In3,
           In4,
           g_out);


  input   In2;
  input   In3;
  input   In4;
  output  [5:0] g_out;  // ufix6


  wire Decoder_out2;
  wire Decoder_out3;
  wire Decoder_out4;
  wire Decoder_out5;
  wire Decoder_out6;
  wire Decoder_out7;
  wire Logical_Operator_out1;
  wire Logical_Operator1_out1;
  wire Logical_Operator4_out1;
  wire Logical_Operator5_out1;
  wire Logical_Operator6_out1;
  wire Logical_Operator7_out1;
  wire [5:0] Bit_Concat_out1;  // ufix6


  Decoder_block1 u_Decoder (.b2(In2),
                            .b1(In3),
                            .b0_LSB(In4),
                            .Out2(Decoder_out2),
                            .Out3(Decoder_out3),
                            .Out4(Decoder_out4),
                            .Out5(Decoder_out5),
                            .Out6(Decoder_out6),
                            .Out7(Decoder_out7)
                            );
  assign Logical_Operator_out1 = Decoder_out5 | Decoder_out6;


  assign Logical_Operator1_out1 = Decoder_out3 | Decoder_out7;


  assign Logical_Operator4_out1 = Decoder_out2 | Decoder_out4;


  assign Logical_Operator5_out1 = Decoder_out3 | Decoder_out4;


  assign Logical_Operator6_out1 = Decoder_out2 | Decoder_out6;


  assign Logical_Operator7_out1 = Decoder_out5 | Decoder_out7;


  assign Bit_Concat_out1 = {Logical_Operator_out1, Logical_Operator1_out1, Logical_Operator4_out1, Logical_Operator5_out1, Logical_Operator6_out1, Logical_Operator7_out1};


  assign g_out = Bit_Concat_out1;

endmodule  // tabla_spwm_g2

