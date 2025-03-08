module rgb_color_selector (
    input wire [3:0] color_index,
    output wire led_red,
    output wire led_blue,
    output wire led_green
);

    reg [2:0] rgb_pwm;
    reg [2:0] rgb_current;

    always @(*) begin
        case (color_index)
            4'b0000: {rgb_pwm, rgb_current} = {3'b000, 3'b000}; // Apagado
            4'b0001: {rgb_pwm, rgb_current} = {3'b001, 3'b111}; // Rojo
            4'b0010: {rgb_pwm, rgb_current} = {3'b010, 3'b111}; // Verde
            4'b0011: {rgb_pwm, rgb_current} = {3'b011, 3'b111}; // Amarillo
            4'b0100: {rgb_pwm, rgb_current} = {3'b100, 3'b111}; // Azul
            4'b0101: {rgb_pwm, rgb_current} = {3'b101, 3'b111}; // Magenta
            4'b0110: {rgb_pwm, rgb_current} = {3'b110, 3'b111}; // Cian
            4'b0111: {rgb_pwm, rgb_current} = {3'b111, 3'b111}; // Blanco
            4'b1000: {rgb_pwm, rgb_current} = {3'b001, 3'b011}; // Rojo bajo
            4'b1001: {rgb_pwm, rgb_current} = {3'b010, 3'b011}; // Verde bajo
            4'b1010: {rgb_pwm, rgb_current} = {3'b011, 3'b011}; // Amarillo bajo
            4'b1011: {rgb_pwm, rgb_current} = {3'b100, 3'b011}; // Azul bajo
            4'b1100: {rgb_pwm, rgb_current} = {3'b101, 3'b011}; // Magenta bajo
            4'b1101: {rgb_pwm, rgb_current} = {3'b110, 3'b011}; // Cian bajo
            4'b1110: {rgb_pwm, rgb_current} = {3'b111, 3'b011}; // Blanco bajo
            4'b1111: {rgb_pwm, rgb_current} = {3'b000, 3'b111}; // Apagado con corriente alta
        endcase
    end

    SB_RGBA_DRV RGB_DRIVER (
        .RGBLEDEN(1'b1),
        .RGB0PWM(rgb_pwm[1]),
        .RGB1PWM(rgb_pwm[2]),
        .RGB2PWM(rgb_pwm[0]),
        .CURREN(1'b1),
        .RGB0(led_green),
        .RGB1(led_blue),
        .RGB2(led_red)
    );

    defparam RGB_DRIVER.RGB0_CURRENT = "0b010";
    defparam RGB_DRIVER.RGB1_CURRENT = "0b010";
    defparam RGB_DRIVER.RGB2_CURRENT = "0b010";

endmodule
