//convertir los datos ingresados por el teclado a BCD

module conv_BCD (
    input  logic        clk_fpga,
    input  logic        reset_B,
    input  logic        s_aviso,
    input  logic [4:0]  b_presionado,
    input  logic        d1,
    input  logic        d2,
    output logic [11:0] BCD_d1, // dato 1 pero en BCD
    output logic [11:0] BCD_d2  // dato 2 en BCD
);

    always_ff @(posedge clk_fpga or negedge reset_B) begin
        if (reset_B == 1'b0) begin
            BCD_d1 <= 12'b0; // d1 volverá a 0
        end
        else begin
            if (d1 == 1'b1 && s_aviso == 1'b1 && b_presionado < 5'd10) begin
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
            if (d2 == 1'b1 && s_aviso == 1'b1 && b_presionado < 5'd10) begin
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


