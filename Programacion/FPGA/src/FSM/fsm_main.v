module debugging_fsm (
    input wire clk,
    input wire reset,
    input wire start,
    output wire done
);

    localparam IDLE    = 2'b00;
    localparam READ    = 2'b01;
    localparam PROCESS = 2'b10;
    localparam WRITE   = 2'b11;

    reg [1:0] current_state, next_state;

    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= IDLE;
        else begin
            case (current_state)
                IDLE:    next_state = start ? READ : IDLE;
                READ:    next_state = PROCESS;
                PROCESS: next_state = WRITE;
                WRITE:   next_state = IDLE;
                default: next_state = IDLE;
            endcase

            current_state <= next_state;
        end
    end

    assign done = (current_state == WRITE);

endmodule