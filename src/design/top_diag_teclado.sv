// Diagnostico del teclado + FSM en la placa, para ver en que punto se pierde una tecla.
// Usa los mismos pines del proyecto (proyecto2.cst) mas los 6 LED internos de la placa (diag.cst).
//
// DISPLAYS (3 digitos "E k k"):
//   E  = estado de la FSM: 1 = dato 1, 2 = dato 2, 3 = resultado
//   kk = codigo de la ultima tecla detectada (0 a 15; A=10, B=11, C=12, D=13, *=14, #=15)
//   El signo "-" se enciende mientras alguna fila del teclado esta en 0.
// LED (se encienden en 0, como todos los LED de la Tang Nano 9K):
//   led[0] = alguna fila en 0 (tecla "vista" sin filtrar)
//   led[1] = alguna fila en 0 despues del DeBounce (tecla confirmada)
//   led[2] = cambia de estado cada vez que se detecta una tecla valida (s_aviso)
//   led[3] = FSM en estado dato 1,  led[4] = dato 2,  led[5] = resultado
// Uso: make all TOP_DESIGN=top_diag_teclado CONSTRAINTS=../constr/diag.cst

module top_diag_teclado (
    input  logic       clk,
    input  logic       resetn,
    input  logic [3:0] row,
    output logic [3:0] col,
    output logic [6:0] seg,
    output logic [3:0] sel,
    output logic [5:0] led
);

    logic [3:0]  f_sinc, f_listas;
    logic        TK_C;
    logic [4:0]  b_presionado;
    logic        s_aviso;
    logic [4:0]  ultima;
    logic        d1, d2, R;
    logic [11:0] BCD_d1, BCD_d2;
    logic        evento;     // cambia con cada tecla valida
    logic [9:0]  valor;
    logic [9:0]  estado;
    logic        neg;

    sincronizar_filas bloque_sinc (.clk_fpga(clk), .reset_B(resetn), .f_tecl(row), .f_sinc(f_sinc));

    DeBounce #(.N(21)) deb_f0 (.clk(clk), .n_reset(resetn), .button_in(f_sinc[0]), .DB_out(f_listas[0]));
    DeBounce #(.N(21)) deb_f1 (.clk(clk), .n_reset(resetn), .button_in(f_sinc[1]), .DB_out(f_listas[1]));
    DeBounce #(.N(21)) deb_f2 (.clk(clk), .n_reset(resetn), .button_in(f_sinc[2]), .DB_out(f_listas[2]));
    DeBounce #(.N(21)) deb_f3 (.clk(clk), .n_reset(resetn), .button_in(f_sinc[3]), .DB_out(f_listas[3]));

    tk_columnas bloque_tick (.clk_fpga(clk), .reset_B(resetn), .TK_C(TK_C));

    avance_columnas bloque_anillo (
        .clk_fpga (clk),
        .reset_B  (resetn),
        .TK_C     (TK_C),
        .f_sinc   (f_sinc),
        .f_listas (f_listas),
        .ubic_c   (col)
    );

    deco_teclado bloque_deco (
        .clk_fpga     (clk),
        .reset_B      (resetn),
        .f_listas     (f_listas),
        .ubic_c       (col),
        .b_presionado (b_presionado),
        .s_aviso      (s_aviso)
    );

    fsm_insercion bloque_fsm (
        .clk_fpga     (clk),
        .reset_B      (resetn),
        .s_aviso      (s_aviso),
        .b_presionado (b_presionado),
        .d1           (d1),
        .d2           (d2),
        .R            (R)
    );

    registro_nums bloque_memorias (
        .clk_fpga     (clk),
        .reset_B      (resetn),
        .s_aviso      (s_aviso),
        .b_presionado (b_presionado),
        .d1           (d1),
        .d2           (d2),
        .R            (R),
        .BCD_d1       (BCD_d1),
        .BCD_d2       (BCD_d2)
    );

    always_ff @(posedge clk or negedge resetn) begin
        if (resetn == 1'b0) begin
            ultima <= 5'd0;
            evento <= 1'b0;
        end
        else if (s_aviso == 1'b1) begin
            ultima <= b_presionado;
            evento <= ~evento;
        end
    end

    always_comb begin
        estado = 10'd1;
        if (d2 == 1'b1) estado = 10'd2;
        if (R  == 1'b1) estado = 10'd3;
    end

    // valor = E*100 + kk
    assign valor = (estado << 6) + (estado << 5) + (estado << 2) + {5'b0, ultima};
    assign neg   = (f_sinc != 4'b1111);

    display_subsystem pantalla (
        .clk   (clk),
        .reset (~resetn),
        .value (valor),
        .neg   (neg),
        .seg   (seg),
        .sel   (sel)
    );

    // LED activos en bajo
    assign led[0] = ~(f_sinc   != 4'b1111);
    assign led[1] = ~(f_listas != 4'b1111);
    assign led[2] = ~evento;
    assign led[3] = ~d1;
    assign led[4] = ~d2;
    assign led[5] = ~R;

endmodule
