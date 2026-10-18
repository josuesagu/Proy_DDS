`timescale 1ns/1ps

module tb_fsm_insercion();
    logic       clk;
    logic       rst_n;
    logic       s_aviso;
    logic [4:0] b_presionado;
    logic       d1;
    logic       d2;
    logic       R;

    fsm_insercion uut (
        .clk_fpga(clk),
        .reset_B(rst_n),
        .s_aviso(s_aviso),
        .b_presionado(b_presionado),
        .d1(d1),
        .d2(d2),
        .R(R)
    );

    always #18.5 clk = ~clk;

    initial begin

        $dumpfile("resultados_sim.vcd");
        $dumpvars(0, tb_fsm_insercion);
        
        clk = 0;
        rst_n = 0;
        s_aviso = 0;
        b_presionado = 5'b10000;
        #40;
        rst_n = 1; // Debe encenderse d1 = 1
        #40;
        $display("inicio: d1=%b d2=%b R=%b (esperado 1 0 0)", d1, d2, R);

        // Simulamos presionar una tecla numérica cualquiera (ej: el 5)
        b_presionado = 5'd5; s_aviso = 1; @(posedge clk); s_aviso = 0; // FSM debe ignorarla y seguir en S0
        #40;
        $display("tecla 5: d1=%b d2=%b R=%b (esperado 1 0 0)", d1, d2, R);

        // Simulamos presionar el OPERANDO 'A' (Valor 10)
        b_presionado = 5'd10; s_aviso = 1; @(posedge clk); s_aviso = 0; // Debe saltar a S1 (d2 = 1)
        #40;
        $display("tecla A: d1=%b d2=%b R=%b (esperado 0 1 0)", d1, d2, R);

        // Simulamos presionar el IGUAL 'D' (Valor 13)
        b_presionado = 5'd13; s_aviso = 1; @(posedge clk); s_aviso = 0; // Debe saltar a S2 (R = 1)
        #80;
        $display("tecla D: d1=%b d2=%b R=%b (esperado 0 0 1)", d1, d2, R);

        // NUEVO: en S2 una tecla cualquiera (ej: el 5) no debe sacarnos del resultado
        b_presionado = 5'd5; s_aviso = 1; @(posedge clk); s_aviso = 0; // Debe seguir en S2
        #40;
        $display("tecla 5 en S2: d1=%b d2=%b R=%b (esperado 0 0 1)", d1, d2, R);

        // NUEVO: presionamos 'B' (Valor 11), el reset de la operacion
        b_presionado = 5'd11; s_aviso = 1; @(posedge clk); s_aviso = 0; // Debe volver a S0 (d1 = 1)
        #40;
        $display("tecla B: d1=%b d2=%b R=%b (esperado 1 0 0)", d1, d2, R);
        
        $finish;
    end
endmodule
