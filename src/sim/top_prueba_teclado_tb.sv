`timescale 1ns/1ps
// Prueba de top_prueba_teclado: presiona las 16 teclas y revisa el codigo guardado.
module top_prueba_teclado_tb;

    logic clk, resetn;
    logic [3:0] row;
    wire  [3:0] col, sel;
    wire  [6:0] seg;
    int errors = 0;

    top_prueba_teclado dut (.clk(clk), .resetn(resetn), .row(row), .col(col), .seg(seg), .sel(sel));

    // ventana de rebote corta para simular (en la placa N = 21)
    defparam dut.deb_f0.N = 8;
    defparam dut.deb_f1.N = 8;
    defparam dut.deb_f2.N = 8;
    defparam dut.deb_f3.N = 8;

    initial begin clk = 0; forever #18.52 clk = ~clk; end

    logic key_down;
    int key_r, key_c;
    always_comb
        for (int r = 0; r < 4; r++)
            row[r] = (key_down && key_r == r && col[key_c] == 1'b0) ? 1'b0 : 1'b1;

    task wait_cycles (input int n); repeat (n) @(negedge clk); endtask

    // presiona la tecla de la fila r y columna c, la suelta y compara el codigo guardado
    task probar (input int r, input int c, input int esperado, input string nombre);
        key_r = r; key_c = c;
        key_down = 1; wait_cycles(135000);   // 5 ms presionada
        if (dut.neg !== 1'b1) begin
            $display("ERROR tecla %s: el signo no se encendio con la tecla presionada", nombre);
            errors++;
        end
        key_down = 0; wait_cycles(60000);
        if (dut.ultima !== esperado) begin
            $display("ERROR tecla %s: codigo %0d, se esperaba %0d", nombre, dut.ultima, esperado);
            errors++;
        end
        else $display("OK    tecla %s -> %0d", nombre, dut.ultima);
    endtask

    initial begin
        key_down = 0; key_r = 0; key_c = 0; resetn = 0;
        wait_cycles(10); resetn = 1; wait_cycles(10000);

        probar(0, 0, 1,  "1");  probar(0, 1, 2,  "2");  probar(0, 2, 3,  "3");  probar(0, 3, 10, "A");
        probar(1, 0, 4,  "4");  probar(1, 1, 5,  "5");  probar(1, 2, 6,  "6");  probar(1, 3, 11, "B");
        probar(2, 0, 7,  "7");  probar(2, 1, 8,  "8");  probar(2, 2, 9,  "9");  probar(2, 3, 12, "C");
        probar(3, 0, 14, "*");  probar(3, 1, 0,  "0");  probar(3, 2, 15, "#");  probar(3, 3, 13, "D");

        if (errors == 0) $display("top_prueba_teclado_tb: TODO OK");
        else             $display("top_prueba_teclado_tb: %0d ERRORES", errors);
        $finish;
    end

endmodule
