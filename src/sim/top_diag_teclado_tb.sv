`timescale 1ns/1ps
// Prueba de top_diag_teclado: 1 2 3 A 4 D B
module top_diag_teclado_tb;

    logic clk, resetn;
    logic [3:0] row;
    wire  [3:0] col, sel;
    wire  [6:0] seg;
    wire  [5:0] led;
    int errors = 0;

    top_diag_teclado dut (.clk(clk), .resetn(resetn), .row(row), .col(col), .seg(seg), .sel(sel), .led(led));

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

    task tecla (input int r, input int c, input int esperado, input string nombre);
        key_r = r; key_c = c;
        key_down = 1; wait_cycles(135000);
        if (led[0] !== 1'b0 || led[1] !== 1'b0) begin
            $display("ERROR tecla %s: los LED 0 y 1 deben estar encendidos (en 0) con la tecla presionada", nombre);
            errors++;
        end
        key_down = 0; wait_cycles(60000);
        if (dut.valor !== esperado || led[0] !== 1'b1 || led[1] !== 1'b1) begin
            $display("ERROR tecla %s: valor %0d (esperado %0d), led = %b", nombre, dut.valor, esperado, led);
            errors++;
        end
        else $display("OK    tecla %s -> %0d   led = %b", nombre, dut.valor, led);
    endtask

    initial begin
        key_down = 0; key_r = 0; key_c = 0; resetn = 0;
        wait_cycles(10); resetn = 1; wait_cycles(10000);

        tecla(0, 0, 101, "1");  tecla(0, 1, 102, "2");  tecla(0, 2, 103, "3");
        tecla(0, 3, 210, "A");  tecla(1, 0, 204, "4");  tecla(3, 3, 313, "D");
        tecla(1, 3, 111, "B");

        if (errors == 0) $display("top_diag_teclado_tb: TODO OK");
        else             $display("top_diag_teclado_tb: %0d ERRORES", errors);
        $finish;
    end

endmodule
