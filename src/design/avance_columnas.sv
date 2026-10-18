//avanza en las columnas cada que TK_C se levanta

module avance_columnas (
    input  logic       clk_fpga,
    input  logic       reset_B,
    input  logic       TK_C, 
    output logic [3:0] ubic_c // ubicacion de la columna activa, 4 flip flops
);

    always_ff @(posedge clk_fpga or negedge reset_B) begin
        if (reset_B == 1'b0) begin
            ubic_c <= 4'b1110; // primer columna
        end
        else begin
            if (TK_C == 1'b1) begin
                case (ubic_c) // multiplexor 4:1 conectado a los flip flops
                    4'b1110: ubic_c <= 4'b1101; // c0 a c1
                    4'b1101: ubic_c <= 4'b1011; // c1 a c2
                    4'b1011: ubic_c <= 4'b0111; // c2 a c3
                    4'b0111: ubic_c <= 4'b1110; // c3 a c0
                    default: ubic_c <= 4'b1110; // proteccion por corrupcion de ruido
                endcase
            end
            else begin
                ubic_c <= ubic_c; // mientras no se levante TK_C sigue en la misma columna (Corregido: sangrado y nivel del if)
            end
        end
    end

endmodule


