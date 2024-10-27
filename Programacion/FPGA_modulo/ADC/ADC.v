`define "ADC/ADC.vh"

module ADC(
    input wire clk,            
    input wire reset,
    input wire read,
    input wire recalibrate,

    // Control reg
    input wire sdo,
    output wire cs,
    output wire sclk,

    output reg [11:0] value
);

    // Config
    parameter CLK_FREQ = 24000000;
    parameter COMM_RATE = `SAMPLE1M2;
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
    reg inner_clk;
    reg calibrate_reset;
    reg receive_reset;

    wire[$clog2(RECEIVE_COUNT)-1:0] r_counter;
    wire[$clog2(CALIBRATE_COUNT)-1:0] c_counter;

    // Modules
    clk_divider inner_freq #(BAUD_DIV=COMM_RATE)(
        .clk_in(clk),
        .clk_out(inner_clk)
    );

    up_counter receive_counter #(MAX_COUNT=RECEIVE_COUNT)(
        .clk(inner_clk),
        .reset(receive_reset),
        .counter(r_counter)
    );

    up_counter calibrate_counter #(MAX_COUNT=CALIBRATE_COUNT)(
        .clk(inner_clk),
        .reset(calibrate_reset),
        .counter(c_counter)
    );

    assign sclk = inner_clk;

    always @(negedge inner_clk)
        begin
            if(reset) begin
                state <= INIT;
            end
            else begin
                case (state)
                    INIT: begin
                        value <= 12'b0;
                        cs <= 1;
                        calibrate_reset <= 1; //Mantenemos el contador de calibracion en 0
                        receive_reset <= 1;
                        state <= CALIBRATE;
                    end

                    CALIBRATE: begin
                        calibrate_reset <= 0;
                        cs <= 0;
                        if (c_counter >= CALIBRATE_COUNT-1) begin
                            state <= IDLE;  //Calibration done
                        end
                    end

                    IDLE: begin
                        if (read) begin
                            state <= RECEIVE;
                        end
                        else if (recalibrate) begin
                            state <= CALIBRATE;
                        end
                    end

                    RECEIVE: begin
                        cs <= 0;
                        receive_reset <= 0;
                        if (r_counter > 2) begin    
                            signal_val <= {signal_val[10:0], sdo};
                            if (r_counter >= RECEIVE_COUNT-1) begin
                                state <= IDLE;
                                value <= signal_val;
                            end
                        end
                    end
            
                endcase
            end
        end
endmodule