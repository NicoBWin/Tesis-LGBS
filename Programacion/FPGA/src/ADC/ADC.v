`include "./src/ADC/ADC.vh"

module ADC(
    input wire clk,            
    input wire reset,
    input wire read,
    input wire recalibrate,

    // Control reg
    input wire sdo,
    output reg cs,
    output wire sclk,

    output wire [11:0] value,
    output reg read_done
);

    // Config
    parameter COMM_RATE = `SAMPLE2M4_CLK48M;
    
    localparam RECEIVE_COUNT = 14;
    localparam CALIBRATE_COUNT = 32;

    // States
    localparam INIT      = 2'b00;
    localparam CALIBRATE = 2'b01;
    localparam IDLE      = 2'b10;
    localparam RECEIVE   = 2'b11;

    // Local variables
    reg [1:0] state = INIT;
    reg [11:0] signal_val = 0; 
    reg calibrate_reset;
    reg receive_reset;

    wire inner_clk;
    wire[$clog2(RECEIVE_COUNT)-1:0] r_counter;
    wire[$clog2(CALIBRATE_COUNT)-1:0] c_counter;

    // Modules
    clk_divider #(COMM_RATE) inner_freq(
        .clk_in(clk),
        .reset(reset),
        .clk_out(inner_clk)
    );

    up_counter #(RECEIVE_COUNT) receive_counter (
        .clk(inner_clk),
        .reset(receive_reset),
        .counter(r_counter)
    );

    up_counter #(CALIBRATE_COUNT) calibrate_counter(
        .clk(inner_clk),
        .reset(calibrate_reset),
        .counter(c_counter)
    );

    assign sclk = inner_clk;
    assign value = signal_val;

    always @(negedge inner_clk)
        begin
            if(reset) begin
                state <= INIT;
            end
            else begin
                case (state)
                    INIT: begin
                        cs <= 1;
                        read_done <= 0;
                        calibrate_reset <= 1; //Mantenemos el contador de calibracion en 0
                        receive_reset <= 1;
                        state <= CALIBRATE;
                    end

                    CALIBRATE: begin
                        cs <= 0;
                        calibrate_reset <= 0;
                        if (c_counter >= CALIBRATE_COUNT-1) begin
                            state <= IDLE;  //Calibration done
                        end
                    end

                    IDLE: begin
                        read_done <= 0;
                        receive_reset <= 1;
                        calibrate_reset <= 1;
                        cs <= 1;
                        if (recalibrate) begin
                            state <= CALIBRATE;
                        end
                        else if (read) begin
                            state <= RECEIVE;
                        end
                    end

                    RECEIVE: begin
                        cs <= 0;
                        receive_reset <= 0;
                        if (r_counter > 2) begin    
                            signal_val <= {signal_val[10:0], sdo};
                            if (r_counter >= RECEIVE_COUNT-1) begin
                                state <= IDLE;
                                read_done <= 1;
                            end
                        end
                    end
            
                endcase
            end
        end
endmodule