`timescale 1ns/1ps

module tb_tk_columnast();
    logic clk;
    logic rst_n;
    logic TK_C;

    tk_columnas uut (
        .clk_fpga(clk),
        .reset_B(rst_n),
        .TK_C(TK_C)
    );

    always #18.5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        #40;
        rst_n = 1;
        
        // Esperamos unos ciclos para ver cómo cuenta y levanta el tick
        #300;
        $finish;
    end
endmodule
