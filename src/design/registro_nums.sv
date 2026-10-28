//guarda los digitos ingreados para cada numero, un digito BCD por 4 bits
module registro_nums (
    input  logic        clk_fpga,
    input  logic        reset_B,
    input  logic        s_aviso,
    input  logic [4:0]  b_presionado,
    input  logic        d1,
    input  logic        d2,
    input  logic        R,       // ya no se usa, se deja para no tocar la instancia en insercion_top
    output logic [11:0] BCD_d1, // dato 1 pero en BCD
    output logic [11:0] BCD_d2  // dato 2 en BCD
);

    // limpiar = 1 un ciclo cuando se presiona B (11) en cualquier estado
    logic limpiar;
    assign limpiar = (s_aviso == 1'b1 && b_presionado == 5'd11);

    // es_digito = 1 si la tecla es 0 a 9.
    // Se evita "< 10" porque Yosys lo fusionaba con el "== 10" de fsm_insercion
    // y la A dejaba de funcionar.
    logic es_digito;
    assign es_digito = (b_presionado[4] == 1'b0) && !(b_presionado[3] && (b_presionado[2] || b_presionado[1]));

    always_ff @(posedge clk_fpga or negedge reset_B) begin
        if (reset_B == 1'b0) begin
            BCD_d1 <= 12'b0;
        end
        else begin
            if (limpiar == 1'b1) begin
                BCD_d1 <= 12'b0;
            end
            else if (d1 == 1'b1 && s_aviso == 1'b1 && es_digito && BCD_d1[11:8] == 4'b0) begin // se ignora un 4.o digito
                BCD_d1[11:8] <= BCD_d1[7:4];
                BCD_d1[7:4]  <= BCD_d1[3:0];
                BCD_d1[3:0]  <= b_presionado[3:0];
            end
            else begin
                BCD_d1 <= BCD_d1;
            end
        end
    end

    always_ff @(posedge clk_fpga or negedge reset_B) begin
        if (reset_B == 1'b0) begin
            BCD_d2 <= 12'b0;
        end
        else begin
            if (limpiar == 1'b1) begin
                BCD_d2 <= 12'b0;
            end
            else if (d2 == 1'b1 && s_aviso == 1'b1 && es_digito && BCD_d2[11:8] == 4'b0) begin // se ignora un 4.o digito
                BCD_d2[11:8] <= BCD_d2[7:4];
                BCD_d2[7:4]  <= BCD_d2[3:0];
                BCD_d2[3:0]  <= b_presionado[3:0];
            end
            else begin
                BCD_d2 <= BCD_d2;
            end
        end
    end

endmodule

