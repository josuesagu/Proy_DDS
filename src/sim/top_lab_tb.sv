`timescale 1ns/1ps
// Prueba del generador de 1.8432 MHz: cuenta flancos de subida de clk_out en 10 ms.
// Esperado: 18432 flancos (1.8432 MHz * 10 ms), con una tolerancia de +-1.
module top_lab_tb;

    logic clk, resetn;
    wire  clk_out;
    int   flancos = 0;
    int   errors  = 0;
    time  t_ini, t_fin;
    time  periodo_min = 1000000, periodo_max = 0, t_prev = 0;

    top_lab dut (.clk(clk), .resetn(resetn), .clk_out(clk_out));

    initial begin clk = 0; forever #18.5185 clk = ~clk; end   // 27 MHz

    always @(posedge clk_out) begin
        flancos = flancos + 1;
        if (t_prev != 0) begin
            if ($time - t_prev < periodo_min) periodo_min = $time - t_prev;
            if ($time - t_prev > periodo_max) periodo_max = $time - t_prev;
        end
        t_prev = $time;
    end

    initial begin
        $dumpfile("top_lab_tb.vcd");
        $dumpvars(0, top_lab_tb);
        resetn = 0; #100; resetn = 1;
        flancos = 0;
        #10_000_000;   // 10 ms
        $display("flancos en 10 ms = %0d (esperado 18432)", flancos);
        $display("periodo minimo = %0t ps, maximo = %0t ps (promedio esperado 542.5 ns)", periodo_min, periodo_max);
        if (flancos < 18431 || flancos > 18433) begin
            $display("ERROR: frecuencia fuera de tolerancia");
            errors++;
        end
        else $display("OK    frecuencia correcta");
        if (errors == 0) $display("top_lab_tb: TODO OK");
        $finish;
    end

endmodule
