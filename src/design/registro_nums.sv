//guarda los digitos ingreados para cada numero, un digito BCD por 4 bits
module registro_nums (
    input  logic        clk_fpga,
    input  logic        reset_B,
    input  logic        s_aviso,
    input  logic [4:0]  b_presionado,
    input  logic        d1,
    input  logic        d2,
    input  logic        R,       // NUEVO: estado de resultado de la FSM, se usa para limpiar los datos con la tecla B
    output logic [11:0] BCD_d1, // dato 1 pero en BCD
    output logic [11:0] BCD_d2  // dato 2 en BCD
);

    // NUEVO: limpiar = 1 solo un ciclo, cuando estando en el estado de resultado (R = 1) se presiona B (11).
    // Por que: la FSM vuelve a S0 con B, pero sin esto los digitos viejos seguirian guardados en d1 y d2.
    logic limpiar;
    assign limpiar = (R == 1'b1 && s_aviso == 1'b1 && b_presionado == 5'd11);

    always_ff @(posedge clk_fpga or negedge reset_B) begin
        if (reset_B == 1'b0) begin
            BCD_d1 <= 12'b0; // d1 volverá a 0
        end
        else begin
            if (limpiar == 1'b1) begin // NUEVO: B en el estado de resultado borra el dato 1
                BCD_d1 <= 12'b0;
            end
            else if (d1 == 1'b1 && s_aviso == 1'b1 && b_presionado < 5'd10) begin
                // desplazamiento de la posicion de los numeros a como se van ingresando
                BCD_d1[11:8] <= BCD_d1[7:4];
                BCD_d1[7:4]  <= BCD_d1[3:0];
                BCD_d1[3:0]  <= b_presionado[3:0];
            end
            else begin
                BCD_d1 <= BCD_d1; // si no se cumplen las condiones de insercion, se queda esperando por la insercion de digitos
            end
        end
    end

    always_ff @(posedge clk_fpga or negedge reset_B) begin
        if (reset_B == 1'b0) begin
            BCD_d2 <= 12'b0; // d2 volverá a 0
        end
        else begin
            if (limpiar == 1'b1) begin // NUEVO: B en el estado de resultado borra el dato 2
                BCD_d2 <= 12'b0;
            end
            else if (d2 == 1'b1 && s_aviso == 1'b1 && b_presionado < 5'd10) begin
                // desplazamiento de la posicion de los numeros a como se van ingresando
                BCD_d2[11:8] <= BCD_d2[7:4];
                BCD_d2[7:4]  <= BCD_d2[3:0];
                BCD_d2[3:0]  <= b_presionado[3:0];
            end
            else begin
                BCD_d2 <= BCD_d2; // si no se cumplen las condiones de insercion, se queda esperando por la insercion de digitos
            end
        end
    end

endmodule


