`timescale 1ns/1ps

module tb_avance_columnas();
    logic       clk;
    logic       rst_n;
    logic       TK_C;
    logic [3:0] ubic_c;

    avance_columnas uut (
        .clk_fpga(clk),
        .reset_B(rst_n),
        .TK_C(TK_C),
        .ubic_c(ubic_c)
    );

    always #18.5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        TK_C = 0;
        #40;
        
        rst_n = 1; // Debe iniciar en 4'b1110
        #40;
        
        // Damos el primer silbazo (Pulso TK_C)
        @(posedge clk); TK_C = 1;
        @(posedge clk); TK_C = 0; // Debe cambiar a 4'b1101
        #40;
        
        // Segundo silbazo
        @(posedge clk); TK_C = 1;
        @(posedge clk); TK_C = 0; // Debe cambiar a 4'b1011
        #40;
        
        // Tercer silbazo
        @(posedge clk); TK_C = 1;
        @(posedge clk); TK_C = 0; // Debe cambiar a 4'b0111
        #40;

        // Cuarto silbazo (Cierre de anillo)
        @(posedge clk); TK_C = 1;
        @(posedge clk); TK_C = 0; // Debe regresar a 4'b1110
        #40;
        $finish;
    end
endmodule
