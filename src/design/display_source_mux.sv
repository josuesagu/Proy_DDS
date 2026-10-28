// Elige qué número se muestra en los displays, según el estado de la FSM de inserción
//
//   d1 = 1 : se está ingresando el dato 1  -> se muestra a
//   d2 = 1 : se está ingresando el dato 2  -> se muestra b
//   R  = 1 : resultado                     -> se muestra la magnitud, con signo menos si es negativo
module display_source_mux (
    input  logic       d1,
    input  logic       d2,
    input  logic       R,
    input  logic [9:0] a,
    input  logic [9:0] b,
    input  logic [9:0] res_mag,
    input  logic       res_neg,
    output logic [9:0] value,
    output logic       neg
);

    always_comb begin
        // por defecto: el dato 1, sin signo
        value = a;
        neg   = 1'b0;

        if (R == 1'b1) begin
            value = res_mag;
            neg   = res_neg;
        end
        else if (d2 == 1'b1) begin
            value = b;
        end
    end

endmodule
