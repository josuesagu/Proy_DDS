// Prueba del teclado en la placa, sin la FSM ni la resta.
// Muestra en los displays el codigo de la ULTIMA tecla detectada (0 a 15, en decimal):
//   1 2 3 A      ->   1  2  3 10
//   4 5 6 B      ->   4  5  6 11
//   7 8 9 C      ->   7  8  9 12
//   * 0 # D      ->  14  0 15 13
// El signo "-" (digito izquierdo) se enciende mientras alguna fila del teclado esta en 0, es decir,
// mientras la FPGA "ve" una tecla presionada, aunque el codigo no cambie.
// Usa los mismos pines que el proyecto (proyecto2.cst): make all TOP_DESIGN=top_prueba_teclado

module top_prueba_teclado (
    input  logic       clk,
    input  logic       resetn,
    input  logic [3:0] row,
    output logic [3:0] col,
    output logic [6:0] seg,
    output logic [3:0] sel
);

    logic [3:0] f_sinc;      // filas sincronizadas
    logic [3:0] f_listas;    // filas filtradas por el DeBounce del profesor
    logic       TK_C;        // tick de 1 ms para avanzar de columna
    logic [4:0] b_presionado;
    logic       s_aviso;
    logic [4:0] ultima;      // codigo de la ultima tecla detectada
    logic       neg;

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

    // guarda el codigo de la ultima tecla valida
    always_ff @(posedge clk or negedge resetn) begin
        if (resetn == 1'b0) ultima <= 5'd0;
        else if (s_aviso == 1'b1) ultima <= b_presionado;
    end

    assign neg = (f_sinc != 4'b1111);   // 1 mientras alguna fila este en 0

    display_subsystem pantalla (
        .clk   (clk),
        .reset (~resetn),
        .value ({5'b0, ultima}),
        .neg   (neg),
        .seg   (seg),
        .sel   (sel)
    );

endmodule
