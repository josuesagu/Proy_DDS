`timescale 1ns/1ps

module tb_avance_columnas();
    logic       clk;
    logic       rst_n;
    logic       TK_C;
    logic [3:0] f_sinc;    // NUEVO: filas sincronizadas
    logic [3:0] f_listas;  // NUEVO: filas filtradas por el DeBounce
    logic [3:0] ubic_c;

    avance_columnas uut (
        .clk_fpga(clk),
        .reset_B(rst_n),
        .TK_C(TK_C),
        .f_sinc(f_sinc),     // NUEVO
        .f_listas(f_listas), // NUEVO
        .ubic_c(ubic_c)
    );

    always #18.5 clk = ~clk;

    initial begin
        $dumpfile("resultados_sim.vcd");   // NUEVO: para poder ver las formas de onda con make wv
        $dumpvars(0, tb_avance_columnas);

        clk = 0;
        rst_n = 0;
        TK_C = 0;
        f_sinc   = 4'b1111; // NUEVO: ninguna tecla presionada
        f_listas = 4'b1111; // NUEVO: ninguna tecla presionada
        #40;
        
        rst_n = 1; // Debe iniciar en 4'b1110
        #40;
        
        // Damos el primer silbazo (Pulso TK_C)
        @(posedge clk); TK_C = 1;
        @(posedge clk); TK_C = 0; // Debe cambiar a 4'b1101
        #40;
        $display("ubic_c = %b (esperado 1101)", ubic_c);
        
        // Segundo silbazo
        @(posedge clk); TK_C = 1;
        @(posedge clk); TK_C = 0; // Debe cambiar a 4'b1011
        #40;
        $display("ubic_c = %b (esperado 1011)", ubic_c);
        
        // Tercer silbazo
        @(posedge clk); TK_C = 1;
        @(posedge clk); TK_C = 0; // Debe cambiar a 4'b0111
        #40;
        $display("ubic_c = %b (esperado 0111)", ubic_c);

        // Cuarto silbazo (Cierre de anillo)
        @(posedge clk); TK_C = 1;
        @(posedge clk); TK_C = 0; // Debe regresar a 4'b1110
        #40;
        $display("ubic_c = %b (esperado 1110)", ubic_c);

        // NUEVO: se presiona una tecla (la fila baja en f_sinc), el barrido se debe congelar
        f_sinc = 4'b1101;
        #40;
        @(posedge clk); TK_C = 1;
        @(posedge clk); TK_C = 0; // NO debe cambiar, sigue en 4'b1110
        #40;
        $display("tecla presionada: ubic_c = %b (esperado 1110, congelado)", ubic_c);

        // NUEVO: f_sinc ya volvio a 1, pero el DeBounce todavia no confirma (f_listas sigue en 0), sigue congelado
        f_sinc   = 4'b1111;
        f_listas = 4'b1101;
        #40;
        @(posedge clk); TK_C = 1;
        @(posedge clk); TK_C = 0; // NO debe cambiar, sigue en 4'b1110
        #40;
        $display("DeBounce aun filtrando: ubic_c = %b (esperado 1110, congelado)", ubic_c);

        // NUEVO: el DeBounce confirma que se solto la tecla, el barrido se reanuda
        f_listas = 4'b1111;
        #40;
        @(posedge clk); TK_C = 1;
        @(posedge clk); TK_C = 0; // Debe cambiar a 4'b1101
        #40;
        $display("tecla soltada: ubic_c = %b (esperado 1101)", ubic_c);
        $finish;
    end
endmodule
