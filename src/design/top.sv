// Top del Proyecto 2: calculadora de resta con teclado hexadecimal y displays de 7 segmentos
// Autor: (nombre)
//
// Puertos físicos (los nombres deben coincidir con src/constr/proyecto2.cst):
//   clk    reloj de 27 MHz
//   resetn botón btn2, activo en bajo
//   row    filas del teclado (entradas, tecla presionada = 0)
//   col    columnas del teclado (salidas del barrido)
//   seg    segmentos a-g de los displays, activos en alto (cátodo común)
//   sel    dígito activo, activo en alto (base del transistor NPN)
module top (
    input  logic       clk,
    input  logic       resetn,
    input  logic [3:0] row,
    output logic [3:0] col,
    output logic [6:0] seg,
    output logic [3:0] sel
);

    logic [11:0] BCD_d1, BCD_d2;   // números ingresados, en BCD
    logic        d1, d2, R;        // estado de la FSM de inserción
    logic [9:0]  a_bin, b_bin;     // números en binario
    logic [9:0]  res_mag;          // magnitud de la resta
    logic        res_neg;          // signo de la resta
    logic [9:0]  value;            // número que se muestra
    logic        neg;              // 1 = mostrar signo menos

    // Teclado y registros de inserción (DeBounce del profesor adentro)
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

    // BCD -> binario
    bcd_a_bin conv_a (.bcd(BCD_d1), .bin(a_bin));
    bcd_a_bin conv_b (.bcd(BCD_d2), .bin(b_bin));

    // Resta A - B
    subtractor_twos_comp resta (
        .clk_fpga (clk),
        .reset_B  (resetn),
        .a        (a_bin),
        .b        (b_bin),
        .neg      (res_neg),
        .mag      (res_mag)
    );

    // Qué se muestra
    display_source_mux fuente (
        .d1      (d1),
        .d2      (d2),
        .R       (R),
        .a       (a_bin),
        .b       (b_bin),
        .res_mag (res_mag),
        .res_neg (res_neg),
        .value   (value),
        .neg     (neg)
    );

    // Despliegue (binario -> BCD con el código del profesor, multiplexado, signo)
    // display_subsystem usa reset activo en alto
    display_subsystem pantalla (
        .clk   (clk),
        .reset (~resetn),
        .value (value),
        .neg   (neg),
        .seg   (seg),
        .sel   (sel)
    );

endmodule
