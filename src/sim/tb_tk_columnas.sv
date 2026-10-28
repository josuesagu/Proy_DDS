`timescale 1ns/1ps

module tb_tk_columnas(); 
    logic clk;
    logic rst_n;
    logic TK_C;

    tk_columnas uut (
        .clk_fpga(clk),
        .reset_B(rst_n),
        .TK_C(TK_C)
    );

    always #18.5 clk = ~clk;

    // avisa cada vez que TK_C sube, para ver cada cuanto tiempo ocurre
    always @(posedge TK_C) $display("TK_C sube en t = %0t ns (cada ~1 ms)", $time/1000);

    initial begin
        $dumpfile("resultados_sim.vcd");  // para poder ver las formas de onda con make wv
        $dumpvars(0, tb_tk_columnas);

        clk = 0;
        rst_n = 0;
        #40;
        rst_n = 1;
        
        // CORREGIDO: antes se esperaban solo 300 ns, el tick tarda ~1 ms (27000 ciclos).
        // Se esperan 2.1 ms para ver dos pulsos de TK_C.
        #2100000;
        $finish;
    end
endmodule
