
module insercion_top (
    input  logic        clk_fpga,     // (Pin 52 - 27 MHz)
    input  logic        reset_B,      // Reset Global (Botón físico B)
    input  logic [3:0]  f_tecl,       // Pines de Filas del teclado
    output logic [3:0]  ubic_c,       // Pines de Columnas del teclado 
    output logic [11:0] BCD_d1,       // Registro BCD estable del Número 1
    output logic [11:0] BCD_d2,       // Registro BCD estable del Número 2
    output logic        R,            // Cable de Moore que ordena ejecutar la resta
    output logic        d1,           // se esta ingresando el dato 1 (estado S0), para elegir que se muestra
    output logic        d2            // se esta ingresando el dato 2 (estado S1), para elegir que se muestra
);

    logic [3:0] cable_f_sinc;         // Conecta sincronizar_filas ➔ DeBounce del profe
    logic [3:0] cable_f_listas;       // Conecta DeBounce del profe ➔ deco_teclado
    logic       cable_TK_C;           // Conecta tk_columnas ➔ avance_columnas
    logic       cable_s_aviso;        // Conecta deco_teclado ➔ fsm_insercion y registro_nums
    logic [4:0] cable_b_presionado;   // Conecta deco_teclado ➔ fsm_insercion y registro_nums
    logic       cable_d1;             // Conecta fsm_insercion ➔ registro_nums
    logic       cable_d2;             // Conecta fsm_insercion ➔ registro_nums


    // 1. Antimetaestabilidad para las 4 filas
    sincronizar_filas bloque_sinc (
        .clk_fpga (clk_fpga),
        .reset_B  (reset_B),
        .f_tecl   (f_tecl),
        .f_sinc   (cable_f_sinc)
    );

    // 2. USO OBLIGATORIO
    // código 'DeBounce' del profesor por cada fila.
    // N=21 para el teclado físico (39ms de retardo mecánico).
    DeBounce #(.N(21)) deb_f0 (.clk(clk_fpga), .n_reset(reset_B), .button_in(cable_f_sinc[0]), .DB_out(cable_f_listas[0]));
    DeBounce #(.N(21)) deb_f1 (.clk(clk_fpga), .n_reset(reset_B), .button_in(cable_f_sinc[1]), .DB_out(cable_f_listas[1]));
    DeBounce #(.N(21)) deb_f2 (.clk(clk_fpga), .n_reset(reset_B), .button_in(cable_f_sinc[2]), .DB_out(cable_f_listas[2]));
    DeBounce #(.N(21)) deb_f3 (.clk(clk_fpga), .n_reset(reset_B), .button_in(cable_f_sinc[3]), .DB_out(cable_f_listas[3]));

    // 3. Tiempo Lento
    tk_columnas bloque_tick (
        .clk_fpga (clk_fpga),
        .reset_B  (reset_B),
        .TK_C     (cable_TK_C)
    );

    // 4. FSM de Escaneo (El Contador de Anillo)
    avance_columnas bloque_anillo (
        .clk_fpga (clk_fpga),
        .reset_B  (reset_B),
        .TK_C     (cable_TK_C),
        .f_sinc   (cable_f_sinc),   //filas sincronizadas, para congelar el barrido apenas se presiona una tecla
        .f_listas (cable_f_listas), //filas filtradas, para no reanudar el barrido hasta que se confirme que se solto
        .ubic_c   (ubic_c) // Se amarra directo a las patitas físicas de salida de la FPGA
    );

    // 5. Traductor de Coordenadas de Matriz Grayhill
    deco_teclado bloque_deco (
        .clk_fpga     (clk_fpga),
        .reset_B      (reset_B),
        .f_listas     (cable_f_listas),
        .ubic_c       (ubic_c),
        .b_presionado (cable_b_presionado),
        .s_aviso      (cable_s_aviso)
    );

    // 6.  Calculadora
    fsm_insercion bloque_fsm (
        .clk_fpga     (clk_fpga),
        .reset_B      (reset_B),
        .s_aviso      (cable_s_aviso),
        .b_presionado (cable_b_presionado),
        .d1           (cable_d1),
        .d2           (cable_d2),
        .R            (R) 
    );

    // 7. Tus Registros Caja Fuerte de Desplazamiento
    registro_nums bloque_memorias (
        .clk_fpga     (clk_fpga),
        .reset_B      (reset_B),
        .s_aviso      (cable_s_aviso),
        .b_presionado (cable_b_presionado),
        .d1           (cable_d1),
        .d2           (cable_d2),
        .R            (R),      // la salida R de la FSM entra a registro_nums para limpiar los datos con la tecla B
        .BCD_d1       (BCD_d1), // Se conecta a la salida maestro para dárselo a Persona A
        .BCD_d2       (BCD_d2)  // Se conecta a la salida maestro para dárselo a Persona A
    );

    //los estados de la FSM tambien salen del modulo
    assign d1 = cable_d1;
    assign d2 = cable_d2;

endmodule
