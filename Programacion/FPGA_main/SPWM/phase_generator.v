module phase_generator #(parameter SIGNAL_SAMPLE_BITS = 8)(
    input wire clk,                                    
    input wire reset,                                  
    input wire [19:0] sine_freq,
    input wire [19:0] triangular_freq,

    output reg phase_a,
    output reg phase_b,
    output reg phase_c
);

    reg[7:0] current_triangular_value;
    reg[7:0] current_sine_a_value;
    reg[7:0] current_sine_b_value;
    reg[7:0] current_sine_c_value;

    localparam [7:0] sine_lookup [255:0] = {128, 131, 134, 137, 140, 143, 146, 149,
                                            152, 156, 159, 162, 165, 168, 171, 174,
                                            176, 179, 182, 185, 188, 191, 193, 196,
                                            199, 201, 204, 206, 209, 211, 213, 216,
                                            218, 220, 222, 224, 226, 228, 230, 232,
                                            234, 235, 237, 239, 240, 242, 243, 244,
                                            246, 247, 248, 249, 250, 251, 251, 252,
                                            253, 253, 254, 254, 254, 255, 255, 255,
                                            255, 255, 255, 255, 254, 254, 253, 253,
                                            252, 252, 251, 250, 249, 248, 247, 246,
                                            245, 244, 242, 241, 239, 238, 236, 235,
                                            233, 231, 229, 227, 225, 223, 221, 219,
                                            217, 215, 212, 210, 207, 205, 202, 200,
                                            197, 195, 192, 189, 186, 184, 181, 178,
                                            175, 172, 169, 166, 163, 160, 157, 154,
                                            151, 148, 145, 142, 138, 135, 132, 129,
                                            126, 123, 120, 117, 113, 110, 107, 104,
                                            101, 98, 95, 92, 89, 86, 83, 80,
                                            77, 74, 71, 69, 66, 63, 60, 58,
                                            55, 53, 50, 48, 45, 43, 40, 38,
                                            36, 34, 32, 30, 28, 26, 24, 22,
                                            20, 19, 17, 16, 14, 13, 11, 10,
                                            9, 8, 7, 6, 5, 4, 3, 3,
                                            2, 2, 1, 1, 0, 0, 0, 0,
                                            0, 0, 0, 1, 1, 1, 2, 2,
                                            3, 4, 4, 5, 6, 7, 8, 9,
                                            11, 12, 13, 15, 16, 18, 20, 21,
                                            23, 25, 27, 29, 31, 33, 35, 37,
                                            39, 42, 44, 46, 49, 51, 54, 56,
                                            59, 62, 64, 67, 70, 73, 76, 79,
                                            81, 84, 87, 90, 93, 96, 99, 103,
                                            106, 109, 112, 115, 118, 121, 124};

    localparam [7:0] triangular_lookup [255:0] = {  2, 4, 6, 8, 10, 12, 14, 16,
                                                    18, 20, 22, 24, 26, 28, 30, 32,
                                                    34, 36, 38, 40, 42, 44, 46, 48,
                                                    50, 52, 54, 56, 58, 60, 62, 64,
                                                    66, 68, 70, 72, 74, 76, 78, 80,
                                                    82, 84, 86, 88, 90, 92, 94, 96,
                                                    98, 100, 102, 104, 106, 108, 110, 112,
                                                    114, 116, 118, 120, 122, 124, 126, 128,
                                                    130, 132, 134, 136, 138, 140, 142, 144,
                                                    146, 148, 150, 152, 154, 156, 158, 160,
                                                    162, 164, 166, 168, 170, 172, 174, 176,
                                                    178, 180, 182, 184, 186, 188, 190, 192,
                                                    194, 196, 198, 200, 202, 204, 206, 208,
                                                    210, 212, 214, 216, 218, 220, 222, 224,
                                                    226, 228, 230, 232, 234, 236, 238, 240,
                                                    242, 244, 246, 248, 250, 252, 254, 255,
                                                    254, 252, 250, 248, 246, 244, 242, 240,
                                                    238, 236, 234, 232, 230, 228, 226, 224,
                                                    222, 220, 218, 216, 214, 212, 210, 208,
                                                    206, 204, 202, 200, 198, 196, 194, 192,
                                                    190, 188, 186, 184, 182, 180, 178, 176,
                                                    174, 172, 170, 168, 166, 164, 162, 160,
                                                    158, 156, 154, 152, 150, 148, 146, 144,
                                                    142, 140, 138, 136, 134, 132, 130, 128,
                                                    126, 124, 122, 120, 118, 116, 114, 112,
                                                    110, 108, 106, 104, 102, 100, 98, 96,
                                                    94, 92, 90, 88, 86, 84, 82, 80,
                                                    78, 76, 74, 72, 70, 68, 66, 64,
                                                    62, 60, 58, 56, 54, 52, 50, 48,
                                                    46, 44, 42, 40, 38, 36, 34, 32,
                                                    30, 28, 26, 24, 22, 20, 18, 16,
                                                    14, 12, 10, 8, 6, 4, 2, 0};

    generator #(.SIGNAL_SAMPLE_BITS(SIGNAL_SAMPLE_BITS)) triangular_gen(
        .clk(clk),
        .reset(reset),
        .signal(triangular_lookup),
        .frecuency(triangular_freq),
        .current_value(current_triangular_value),
        .initial_phase(0)
    );

    generator #(.SIGNAL_SAMPLE_BITS(SIGNAL_SAMPLE_BITS)) phase_a_gen(
        .clk(clk),
        .reset(reset),
        .signal(sine_lookup),
        .frecuency(sine_freq),
        .current_value(current_sine_a_value),
        .initial_phase(0)
    );

    generator #(.SIGNAL_SAMPLE_BITS(SIGNAL_SAMPLE_BITS)) phase_b_gen(
        .clk(clk),
        .reset(reset),
        .signal(sine_lookup),
        .frecuency(sine_freq),
        .current_value(current_sine_b_value),
        .initial_phase(85)
    );

    generator #(.SIGNAL_SAMPLE_BITS(SIGNAL_SAMPLE_BITS)) phase_c_gen(
        .clk(clk),
        .reset(reset),
        .signal(sine_lookup),
        .frecuency(sine_freq),
        .current_value(current_sine_c_value),
        .initial_phase(170)
    );

    always @(posedge clk) begin
            if (reset) begin
                spwm <= 0;
            end
            else begin
                if (current_sine_a_value > triangular)
                    spwm <= 1;
                else 
                    spwm <= 0;

                if (current_sine_b_value > triangular)
                    spwm <= 1;
                else 
                    spwm <= 0;

                if (current_sine_c_value > triangular)
                    spwm <= 1;
                else 
                    spwm <= 0;
            end
        end

endmodule