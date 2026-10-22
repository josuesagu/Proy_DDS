`timescale 1ns/1ps
// Prueba del top de prueba de displays: revisa que cada valor se vea bien
// BIT_CAMBIO = 20 para que cambie más rápido en simulación (en la placa es 25); cada paso debe durar varios refrescos completos de los 4 dígitos
module top_prueba_display_tb;

    logic clk, resetn;
    logic [6:0] seg;
    logic [3:0] sel;
    logic [6:0] visto [0:3];   // último patrón visto en cada dígito (0 = unidades ... 3 = signo)
    int errors = 0;

    top_prueba_display #(.BIT_CAMBIO(20)) dut (.clk(clk), .resetn(resetn), .seg(seg), .sel(sel));

    initial begin clk = 0; forever #18.52 clk = ~clk; end

    always @(negedge clk) begin
        if (sel == 4'b0001) visto[0] = seg;
        if (sel == 4'b0010) visto[1] = seg;
        if (sel == 4'b0100) visto[2] = seg;
        if (sel == 4'b1000) visto[3] = seg;
    end

    function [6:0] patron (input int d);   // a b c d e f g, 1 = encendido
        case (d)
            0: patron = 7'b1111110;  1: patron = 7'b0110000;
            2: patron = 7'b1101101;  3: patron = 7'b1111001;
            4: patron = 7'b0110011;  5: patron = 7'b1011011;
            6: patron = 7'b1011111;  7: patron = 7'b1110000;
            8: patron = 7'b1111111;  9: patron = 7'b1111011;
            default: patron = 7'b0;
        endcase
    endfunction

    task revisar (input int c, input int d, input int u, input bit neg, input string nombre);
        if (visto[0] !== patron(u) || visto[1] !== patron(d) || visto[2] !== patron(c) ||
            visto[3] !== (neg ? 7'b0000001 : 7'b0000000)) begin
            $display("ERROR %s: se ve %b %b %b %b", nombre, visto[3], visto[2], visto[1], visto[0]);
            errors++;
        end
        else $display("OK    %s", nombre);
    endtask

    initial begin
        $dumpfile("top_prueba_display_tb.vcd");
        $dumpvars(0, top_prueba_display_tb);
        resetn = 0; #100; resetn = 1;
        // cada paso dura 2^20 ciclos; se revisa al final de cada uno (los valores avanzan en este orden)
        repeat (2**20 - 3000)      @(negedge clk);  revisar(8, 8, 8, 0, "888");
        repeat (2**20)             @(negedge clk);  revisar(1, 2, 3, 1, "-123");
        repeat (2**20)             @(negedge clk);  revisar(4, 5, 6, 0, "456");
        repeat (2**20)             @(negedge clk);  revisar(9, 9, 9, 1, "-999");
        if (errors == 0) $display("top_prueba_display_tb: TODO OK");
        else             $display("top_prueba_display_tb: %0d ERRORES", errors);
        $finish;
    end

endmodule
