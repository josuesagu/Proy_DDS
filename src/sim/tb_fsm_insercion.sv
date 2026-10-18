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
        clk = 0;
        rst_n = 0;
        s_aviso = 0;
        b_presionado = 5'b10000;
        #40;
        rst_n = 1; // Debe encenderse d1 = 1
        #40;

        // Simulamos presionar una tecla numérica cualquiera (ej: el 5)
        b_presionado = 5'd5; s_aviso = 1; @(posedge clk); s_aviso = 0; // FSM debe ignorarla y seguir en S0
        #40;

        // Simulamos presionar el OPERANDO 'A' (Valor 10)
        b_presionado = 5'd10; s_aviso = 1; @(posedge clk); s_aviso = 0; // Debe saltar a S1 (d2 = 1)
        #40;

        // Simulamos presionar el IGUAL 'D' (Valor 13)
        b_presionado = 5'd13; s_aviso = 1; @(posedge clk); s_aviso = 0; // Debe saltar a S2 (R = 1)
        #80;
        
        $finish;
    end
endmodule
