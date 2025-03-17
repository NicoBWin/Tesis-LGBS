module dead_time_inv #(
    parameter integer DT = 10
)(
    input  wire        clk,
    input  wire        rst,
    input  wire [5:0]  g_in,   // [5:3] = TOP, [2:0] = BOTTOM
    output wire [5:0]  g_out   // Salida como wire
);
    // Cantidad de ciclos que dura el solapamiento
    

    //------------------------------------------------
    // Separar en top y bottom (entradas actuales)
    //------------------------------------------------
    wire [2:0] new_top_in = g_in[5:3];
    wire [2:0] new_bot_in = g_in[2:0];

    //------------------------------------------------
    // Registros internos de estado
    //------------------------------------------------
    // (Se declaran fuera del always para no requerir SystemVerilog.)
    reg [2:0] top_out_reg, bot_out_reg;
    reg [7:0] top_dt_count, bot_dt_count;
    reg       force_top_overlap, force_bot_overlap;
    reg [2:0] prev_top_in, prev_bot_in;

    //------------------------------------------------
    // Señales combinacionales (tipo wire) 
    // para detección de transiciones y unión bit a bit.
    //------------------------------------------------
    // Se definen como wire fuera del always, 
    // de modo que dentro del always solo se lean.
    //------------------------------------------------
    wire turning_on_top  = |((~prev_top_in) & new_top_in);
    wire turning_off_top = |(prev_top_in & (~new_top_in));
    wire turning_on_bot  = |((~prev_bot_in) & new_bot_in);
    wire turning_off_bot = |(prev_bot_in & (~new_bot_in));

    wire [2:0] union_top = prev_top_in | new_top_in; 
    wire [2:0] union_bot = prev_bot_in | new_bot_in;

    //------------------------------------------------
    // La salida (wire) se forma con los registros
    //------------------------------------------------
    assign g_out = {top_out_reg, bot_out_reg};

    //------------------------------------------------
    // Único bloque secuencial con reset síncrono
    // (sin declaraciones de variables locales dentro)
    //------------------------------------------------
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            // Reset síncrono
            top_out_reg       <= 3'b000;
            bot_out_reg       <= 3'b000;
            top_dt_count      <= 8'd0;
            bot_dt_count      <= 8'd0;
            force_top_overlap <= 1'b0;
            force_bot_overlap <= 1'b0;
            prev_top_in       <= 3'b000;
            prev_bot_in       <= 3'b000;
        end
        else begin
            //-------------------------------------------
            // LÓGICA PARA TOP
            //-------------------------------------------
            if (force_top_overlap) begin
                // Ya en modo solapamiento
                if (top_dt_count != 0) begin
                    top_out_reg <= union_top; 
                    top_dt_count <= top_dt_count - 1'b1;
                end
                else begin
                    // Se acabó el solapamiento
                    force_top_overlap <= 1'b0;
                    top_out_reg       <= new_top_in;
                end
            end
            else begin
                // No estábamos en overlap
                // Iniciarlo si hay apagado y encendido simultáneo
                if (turning_on_top && turning_off_top) begin
                    force_top_overlap <= 1'b1;
                    top_out_reg       <= union_top;
                    if (DT > 0) 
                        top_dt_count  <= DT - 1'b1;
                    else 
                        top_dt_count  <= 8'd0;
                end
                else begin
                    // Caso normal: copiar la nueva señal
                    top_out_reg  <= new_top_in;
                    top_dt_count <= 8'd0;
                end
            end

            //-------------------------------------------
            // LÓGICA PARA BOTTOM
            //-------------------------------------------
            if (force_bot_overlap) begin
                if (bot_dt_count != 0) begin
                    bot_out_reg <= union_bot;
                    bot_dt_count <= bot_dt_count - 1'b1;
                end
                else begin
                    force_bot_overlap <= 1'b0;
                    bot_out_reg       <= new_bot_in;
                end
            end
            else begin
                if (turning_on_bot && turning_off_bot) begin
                    force_bot_overlap <= 1'b1;
                    bot_out_reg       <= union_bot;
                    if (DT > 0)
                        bot_dt_count  <= DT - 1'b1;
                    else
                        bot_dt_count  <= 8'd0;
                end
                else begin
                    bot_out_reg  <= new_bot_in;
                    bot_dt_count <= 8'd0;
                end
            end

            //-------------------------------------------
            // Actualizar entradas previas para el siguiente ciclo
            //-------------------------------------------
            prev_top_in <= new_top_in;
            prev_bot_in <= new_bot_in;
        end
    end

endmodule