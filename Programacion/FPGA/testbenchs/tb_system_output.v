`timescale 1ns/1ps

module tb_system_output;

  // Testbench signals
  reg [6:0] va;
  reg [6:0] vb;
  reg [6:0] vc;
  reg [6:0] tri_wave;
  reg       shoot;
  reg       reset;
  wire [5:0] transistor_out;

  // Integer variables for loops
  integer i, sine_index;

  // Sine wave LUT (7-bit depth, 16 samples per cycle)
  reg [6:0] sine_wave_LUT [0:15];

  // Instantiate the DUT
  system_output DUT (
    .va(va),
    .vb(vb),
    .vc(vc),
    .tri_wave(tri_wave),
    .shoot(shoot),
    .reset(reset),
    .transistor_out(transistor_out)
  );

  // LUT Initialization
  initial begin
    // 7-bit sinewave approximated over 16 samples (0-127 range)
    sine_wave_LUT[ 0] = 7'd64;  // sin(0°)   =  0
    sine_wave_LUT[ 1] = 7'd91;  // sin(22.5°)
    sine_wave_LUT[ 2] = 7'd113; // sin(45°)
    sine_wave_LUT[ 3] = 7'd126; // sin(67.5°)
    sine_wave_LUT[ 4] = 7'd127; // sin(90°)
    sine_wave_LUT[ 5] = 7'd126; // sin(112.5°)
    sine_wave_LUT[ 6] = 7'd113; // sin(135°)
    sine_wave_LUT[ 7] = 7'd91;  // sin(157.5°)
    sine_wave_LUT[ 8] = 7'd64;  // sin(180°)
    sine_wave_LUT[ 9] = 7'd36;  // sin(202.5°)
    sine_wave_LUT[10] = 7'd14;  // sin(225°)
    sine_wave_LUT[11] = 7'd1;   // sin(247.5°)
    sine_wave_LUT[12] = 7'd0;   // sin(270°)
    sine_wave_LUT[13] = 7'd1;   // sin(292.5°)
    sine_wave_LUT[14] = 7'd14;  // sin(315°)
    sine_wave_LUT[15] = 7'd36;  // sin(337.5°)
  end

  initial begin
    // Initialize signals
    tri_wave = 7'd0;
    shoot    = 1'b0;
    reset    = 1'b1;
    sine_index = 0; // Start at LUT index 0

    // Enable waveform dump for visualization
    $dumpfile("tb_system_output.vcd");
    $dumpvars(0, tb_system_output);

    // Short reset pulse
    #20 reset = 1'b0;
    #10;

    // Main test loop iterating over sine wave LUT
    for (sine_index = 0; sine_index < 16; sine_index = sine_index + 1) begin
      // Assign 3-phase sine waves with 120° phase shifts
      va = 125;                     // 0° phase
      vb = 48;          // 120° phase
      vc = 17;         // 240° phase

      // ----------------------------
      //  Tri_wave goes 0 -> 127
      // ----------------------------
      for (i = 0; i < 128; i = i + 1) begin
        tri_wave = i[6:0];  // stays within 7 bits
        // Generate a short shoot pulse
        shoot = 1'b1;
        #5 shoot = 1'b0;
        #5;
      end

      // ----------------------------
      //  Tri_wave goes 127 -> 0
      // ----------------------------
      for (i = 127; i >= 0; i = i - 1) begin
        tri_wave = i[6:0];
        // Generate a short shoot pulse
        shoot = 1'b1;
        #5 shoot = 1'b0;
        #5;
      end

      // After this up/down tri_wave cycle, move to the next sine sample
    end

    // Finish simulation
    #50;
    $finish;
  end

endmodule
