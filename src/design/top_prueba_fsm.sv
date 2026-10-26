// Prueba de la FSM de insercion en la placa (sin la resta).
// Los displays muestran tres digitos "E a b":
//   E = estado de la FSM:  1 = ingresando dato 1,  2 = ingresando dato 2,  3 = resultado (tecla D)
//   a = ultimo digito escrito en el dato 1
//   b = ultimo digito escrito en el dato 2
// Ejemplo: se teclea 1 2 3  ->  130.  Se presiona A -> 230.  Se teclea 4 -> 234.  Se presiona D -> 334.
// Se presiona B (estando en el resultado) -> 100.
// Usa los mismos pines que el proyecto (proyecto2.cst): make all TOP_DESIGN=top_prueba_fsm

module top_prueba_fsm (
    input  logic       clk,
    input  logic       resetn,
    input  logic [3:0] row,
    output logic [3:0] col,
    output logic [6:0] seg,
    output logic [3:0] sel
);

    logic [11:0] BCD_d1, BCD_d2;
    logic        d1, d2, R;
    logic [9:0]  valor;
    logic [9:0]  estado;   // 1, 2 o 3

    insercion_top teclado (
        .clk_fpga (clk),
        .reset_B  (resetn),
        .f_tecl   (row),
        .ubic_c   (col),
        .BCD_d1   (BCD_d1),
        .BCD_d2   (BCD_d2),
        .R        (R),
        .d1       (d1),
        .d2       (d2)
    );

    always_comb begin
        estado = 10'd1;
        if (d2 == 1'b1) estado = 10'd2;
        if (R  == 1'b1) estado = 10'd3;
    end

    // E*100 + a*10 + b  (a y b son los ultimos digitos BCD de cada dato)
    assign valor = (estado << 6) + (estado << 5) + (estado << 2)
                 + ({6'b0, BCD_d1[3:0]} << 3) + ({6'b0, BCD_d1[3:0]} << 1)
                 + {6'b0, BCD_d2[3:0]};

    display_subsystem pantalla (
        .clk   (clk),
        .reset (~resetn),
        .value (valor),
        .neg   (1'b0),
        .seg   (seg),
        .sel   (sel)
    );

endmodule
