`timescale 1ns/1ps

module tb_conv_BCD();
    logic        clk;
    logic        rst_n;
    logic        s_aviso;
    logic [4:0]  b_presionado;
    logic        d1;
    logic        d2;
    logic        R;
    logic [11:0] BCD_d1;
    logic [11:0] BCD_d2;

    conv_BCD uut (
        .clk_fpga(clk),
        .reset_B(rst_n),
        .s_aviso(s_aviso),
        .b_presionado(b_presionado),
        .d1(d1),
        .d2(d2),
        .R(R),
        .BCD_d1(BCD_d1),
        .BCD_d2(BCD_d2)
    );

    always #18.5 clk = ~clk;

    initial begin
        $dumpfile("resultados_sim.vcd");
        $dumpvars(0, tb_conv_BCD);

        clk = 0;
        rst_n = 0;
        s_aviso = 0;
        b_presionado = 5'b10000;
        d1 = 1; d2 = 0; R = 0; // estado S0: se esta ingresando el dato 1
        #40;
        rst_n = 1;
        #40;

        // Dato 1: se teclea 1, 2, 3
        b_presionado = 5'd1; s_aviso = 1; @(posedge clk); #5 s_aviso = 0; #35; // s_aviso se baja 5 ns despues del flanco para que el registro alcance a leerlo
        b_presionado = 5'd2; s_aviso = 1; @(posedge clk); #5 s_aviso = 0; #35; // s_aviso se baja 5 ns despues del flanco para que el registro alcance a leerlo
        b_presionado = 5'd3; s_aviso = 1; @(posedge clk); #5 s_aviso = 0; #35; // s_aviso se baja 5 ns despues del flanco para que el registro alcance a leerlo
        $display("dato 1: BCD_d1 = %h (esperado 123)", BCD_d1);

        // La tecla A (10) no es un digito, no se debe guardar
        b_presionado = 5'd10; s_aviso = 1; @(posedge clk); #5 s_aviso = 0; #35; // s_aviso se baja 5 ns despues del flanco para que el registro alcance a leerlo
        $display("tecla A: BCD_d1 = %h (esperado 123)", BCD_d1);

        // Dato 2: la FSM pasa a S1, se teclea 4, 5
        d1 = 0; d2 = 1;
        b_presionado = 5'd4; s_aviso = 1; @(posedge clk); #5 s_aviso = 0; #35; // s_aviso se baja 5 ns despues del flanco para que el registro alcance a leerlo
        b_presionado = 5'd5; s_aviso = 1; @(posedge clk); #5 s_aviso = 0; #35; // s_aviso se baja 5 ns despues del flanco para que el registro alcance a leerlo
        $display("dato 2: BCD_d2 = %h (esperado 045), BCD_d1 = %h (esperado 123)", BCD_d2, BCD_d1);

        // Resultado: la FSM pasa a S2 (R = 1), se presiona B y se limpian los dos datos
        d2 = 0; R = 1;
        b_presionado = 5'd11; s_aviso = 1; @(posedge clk); #5 s_aviso = 0; #35; // s_aviso se baja 5 ns despues del flanco para que el registro alcance a leerlo
        $display("tecla B: BCD_d1 = %h, BCD_d2 = %h (esperado 000 y 000)", BCD_d1, BCD_d2);

        $finish;
    end
endmodule