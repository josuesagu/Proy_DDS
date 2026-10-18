`timescale 1ns/1ps

module tb_sincronizar_filas();
    logic       clk;
    logic       rst_n;
    logic [3:0] f_tecl;
    logic [3:0] f_sinc;

    // Instancia el módulo bajo prueba
    sincronizar_filas uut (
        .clk_fpga(clk),
        .reset_B(rst_n),
        .f_tecl(f_tecl),
        .f_sinc(f_sinc)
    );

    // Generador de reloj (Periodo de 37ns para simular los ~27 MHz de la FPGA)
    always #18.5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        f_tecl = 4'b1111; // Reposo (Líneas en alto por pull-up)
        #50;
        
        rst_n = 1; // Liberamos el reset
        #20;
        
        // Simulamos una pulsación asíncrona (cambio a mitad de un ciclo)
        #5; 
        f_tecl = 4'b1110; // Cae la Fila 0
        
        #100;
        $finish;
    end
endmodule
