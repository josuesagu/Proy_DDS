`timescale 1ns/1ps

module tb_deco_teclado();
    logic       clk;
    logic       rst_n;
    logic [3:0] f_listas;
    logic [3:0] ubic_c;
    logic [4:0] b_presionado;
    logic       s_aviso;

    deco_teclado uut (
        .clk_fpga(clk),
        .reset_B(rst_n),
        .f_listas(f_listas),
        .ubic_c(ubic_c),
        .b_presionado(b_presionado),
        .s_aviso(s_aviso)
    );

    always #18.5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        f_listas = 4'b1111; // Ninguna tecla
        ubic_c = 4'b1110;   // Columna 0 activa
        #40;
        rst_n = 1;
        #40;

        // Simulamos presionar el Botón 4 (Columna 0, Fila 1)
        f_listas = 4'b1101; 
        #80;
        
        // Soltamos el botón
        f_listas = 4'b1111;
        #40;

        // Cambiamos de escenario: Escaneando Columna 1 (ubic_c = 4'b1101)
        ubic_c = 4'b1101;
        #40;
        // Presionamos el Botón 8 (Columna 1, Fila 2)
        f_listas = 4'b1011; 
        #80;
        
        $finish;
    end
endmodule
