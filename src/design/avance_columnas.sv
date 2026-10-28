//avanza en las columnas cada que TK_C se levanta

//avanza en las columnas cada que TK_C se levanta

module avance_columnas (
    input  logic       clk_fpga,
    input  logic       reset_B,
    input  logic       TK_C, 
    //filas del teclado, para saber si hay una tecla presionada
    input  logic [3:0] f_sinc,   //filas sincronizadas (sin filtrar): detectan la tecla apenas se presiona
    input  logic [3:0] f_listas, //filas ya filtradas por el DeBounce: confirman que la tecla sigue presionada
    output logic [3:0] ubic_c // ubicacion de la columna activa, 4 flip flops
);

    // sin_tecla = 1 cuando las 4 filas estan en 1 (las filas son activas en bajo, 1 = nada presionado).
    // Se revisan las dos senales: f_sinc para frenar de inmediato al presionar, y f_listas para no
    // reanudar el barrido hasta que el DeBounce confirme que la tecla ya se solto.
    logic sin_tecla;
    assign sin_tecla = (f_sinc == 4'b1111 && f_listas == 4'b1111);

    always_ff @(posedge clk_fpga or negedge reset_B) begin
        if (reset_B == 1'b0) begin
            ubic_c <= 4'b1110; // primer columna
        end
        else begin
            // ademas de TK_C, solo avanza si no hay tecla presionada.
            // Por que: el DeBounce necesita ver la fila estable ~39 ms. Si la columna sigue rotando cada 1 ms,
            // la fila de la tecla baja solo 1 ms de cada 4, el DeBounce nunca la confirma y el teclado no responde.
            // Congelando la columna, la fila queda fija en 0 y el DeBounce la puede confirmar.
            if (TK_C == 1'b1 && sin_tecla == 1'b1) begin
                case (ubic_c) // multiplexor 4:1 conectado a los flip flops
                    4'b1110: ubic_c <= 4'b1101; // c0 a c1
                    4'b1101: ubic_c <= 4'b1011; // c1 a c2
                    4'b1011: ubic_c <= 4'b0111; // c2 a c3
                    4'b0111: ubic_c <= 4'b1110; // c3 a c0
                    default: ubic_c <= 4'b1110; // proteccion por corrupcion de ruido
                endcase
            end
            else begin
                ubic_c <= ubic_c; // mientras no se levante TK_C (o haya una tecla presionada) sigue en la misma columna (Corregido: sangrado y nivel del if)
            end
        end
    end

endmodule


