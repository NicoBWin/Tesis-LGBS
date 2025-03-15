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
  integer i;
  integer phase_count;

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

  initial begin
    // Initialize signals
    va       = 7'd0;
    vb       = 7'd0;
    vc       = 7'd0;
    tri_wave = 7'd0;
    shoot    = 1'b0;
    reset    = 1'b1;

    // Optional: waveform dump for visualization
    $dumpfile("tb_system_output.vcd");
    $dumpvars(0, tb_system_output);

    // Short reset pulse
    #20 reset = 1'b0;
    #10;

    // Loop over different sine-wave settings (va, vb, vc).
    // Each iteration sets new constant values, then does a full tri_wave up/down cycle.
    for (phase_count = 0; phase_count < 5; phase_count = phase_count + 1) begin

      // Pick new constant values for the 3-phase signals
      va = (phase_count * 20) % 128;
      vb = (phase_count * 50) % 128;
      vc = (phase_count * 90) % 128;

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

      // After this up/down tri_wave cycle,
      // we move to the next set of va, vb, vc.
    end

    // Finish simulation
    #50;
    $finish;
  end

endmodule