`include "./src/SPI/SPI.vh"

/*
    Nota: El slave tiene que muestrear los bits en el flanco descendente del sclk
*/

module SPI(
    input wire clk,            // System clock
    input wire reset,          // System reset
    input wire start_transfer,

    input wire [15:0] data_to_tx,
    output reg [15:0] data_rx,
    output reg transfer_done,
    output reg transfer_busy,

    output wire sclk,     // SPI clock
    output wire mosi,
    input wire miso,     // Master-In Slave-Out
    output reg cs        // Chip select
);

    localparam IDLE     = 2'b00;
    localparam SELECT   = 2'b01;
    localparam TRANSFER = 2'b10;
    localparam DONE = 2'b11;

    // Internal signals
    reg sclk_en;
    reg [1:0] state;
    reg [15:0] shift_reg;       // Shift register for SPI communication
    reg [3:0] bit_counter;      // Counter for tracking bits
    wire inner_clk;

    parameter COMM_RATE = `RATE2M4_CLK24M;
    parameter CS_ACTIVE = 1'b0; // 0 active low
    parameter CPOL = 1'b0; // idle state

    assign mosi = shift_reg[0];
    assign sclk = CPOL ? (inner_clk | ~sclk_en) : (inner_clk & sclk_en);

    clk_divider #(COMM_RATE) baudrate_gen(
        .clk_in(clk),
        .reset(reset),
        .clk_out(inner_clk)
    );

    always @(negedge inner_clk) begin
        if (bit_counter == 0 && state == TRANSFER) begin
            sclk_en <= 0;
        end
    end

    always @(posedge inner_clk or posedge reset) begin
        if (reset) 
        begin
            state <= IDLE;
            data_rx <= 15'b0;
            sclk_en <= 0;
            transfer_done <= 0;
            transfer_busy <= 0;
            cs <= !CS_ACTIVE;
        end
        else begin
            case (state)
                IDLE: 
                begin
                    transfer_done <= 0;
                    if (start_transfer) begin
                        bit_counter <= 15;
                        data_rx <= 15'b0;
                        transfer_busy <= 1;
                        cs <= CS_ACTIVE;
                        shift_reg <= data_to_tx;
                        state <= SELECT;
                    end
                end

                SELECT: 
                begin
                    sclk_en <= 1;
                    state <= TRANSFER;
                end

                TRANSFER: 
                begin
                    shift_reg <= {1'b0, shift_reg[15:1]};
                    data_rx <= {miso, data_rx[15:1]};

                    if (bit_counter == 0) begin
                        cs <= !CS_ACTIVE;
                        state <= DONE;
                    end else begin
                        bit_counter <= 6;
                        //bit_counter <= bit_counter - 1;
                    end
                end

                DONE: 
                begin
                    transfer_done <= 1;
                    transfer_busy <= 0;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
