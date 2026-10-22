`timescale 1ns/1ps
// Prueba de integracion del top: teclado -> resta -> displays (modelo del teclado con rebotes)
module top_tb;

    logic clk, resetn;
    logic [3:0] row;
    wire  [3:0] col, sel;
    wire  [6:0] seg;
    int errors = 0;
    logic [6:0] visto [0:3];   // ultimo patron visto en cada digito (0 = unidades ... 3 = signo)

    top dut (.clk(clk), .resetn(resetn), .row(row), .col(col), .seg(seg), .sel(sel));

    // ventana de rebote corta para simular (en la placa N = 21)
    defparam dut.teclado.deb_f0.N = 8;
    defparam dut.teclado.deb_f1.N = 8;
    defparam dut.teclado.deb_f2.N = 8;
    defparam dut.teclado.deb_f3.N = 8;

    initial begin clk = 0; forever #18.52 clk = ~clk; end

    logic key_down;
    int key_r, key_c;
    always_comb
        for (int r = 0; r < 4; r++)
            row[r] = (key_down && key_r == r && col[key_c] == 1'b0) ? 1'b0 : 1'b1;

    // guarda lo que se ve en cada digito
    always @(negedge clk) begin
        if (sel == 4'b0001) visto[0] = seg;
        if (sel == 4'b0010) visto[1] = seg;
        if (sel == 4'b0100) visto[2] = seg;
        if (sel == 4'b1000) visto[3] = seg;
    end

    task wait_cycles (input int n); repeat (n) @(negedge clk); endtask

    // Presiona una tecla con rebotes, la mantiene 5 ms y la suelta con rebotes
    task press_key (input byte ch);
        case (ch)
            "1": begin key_r = 0; key_c = 0; end  "2": begin key_r = 0; key_c = 1; end
            "3": begin key_r = 0; key_c = 2; end  "A": begin key_r = 0; key_c = 3; end
            "4": begin key_r = 1; key_c = 0; end  "5": begin key_r = 1; key_c = 1; end
            "6": begin key_r = 1; key_c = 2; end  "B": begin key_r = 1; key_c = 3; end
            "7": begin key_r = 2; key_c = 0; end  "8": begin key_r = 2; key_c = 1; end
            "9": begin key_r = 2; key_c = 2; end  "C": begin key_r = 2; key_c = 3; end
            "*": begin key_r = 3; key_c = 0; end  "0": begin key_r = 3; key_c = 1; end
            "#": begin key_r = 3; key_c = 2; end  default: begin key_r = 3; key_c = 3; end  // "D"
        endcase
        key_down = 1; wait_cycles(20);                // rebote al presionar
        key_down = 0; wait_cycles(10);
        key_down = 1; wait_cycles(15);
        key_down = 0; wait_cycles(5);
        key_down = 1;
        wait_cycles(135000);                          // 5 ms presionada
        key_down = 0; wait_cycles(8);                 // rebote al soltar
        key_down = 1; wait_cycles(8);
        key_down = 0;
        wait_cycles(20000);
    endtask

    task type_keys (input string s);
        for (int i = 0; i < s.len(); i++) press_key(s[i]);
    endtask

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

    // revisa lo mostrado: unidades, decenas, centenas y signo
    task check_display (input int u, input int d, input int c, input bit neg, input string name);
        wait_cycles(100000);   // unos 3.7 ms: varios ciclos de refresco
        if (visto[0] !== patron(u) || visto[1] !== patron(d) || visto[2] !== patron(c) ||
            visto[3] !== (neg ? 7'b0000001 : 7'b0000000)) begin
            $display("ERROR %s: se ve %b %b %b %b", name, visto[3], visto[2], visto[1], visto[0]);
            errors++;
        end
        else $display("OK    %s", name);
    endtask

    initial begin
        $dumpfile("top_tb.vcd");
        $dumpvars(0, top_tb);
        key_down = 0; key_r = 0; key_c = 0; resetn = 0;
        wait_cycles(10); resetn = 1;
        wait_cycles(10000);

        type_keys("1234"); check_display(3, 2, 1, 0, "ingresando dato 1 (123)");
        type_keys("A");
        type_keys("456");   check_display(6, 5, 4, 0, "ingresando dato 2 (456)");
        type_keys("D");     check_display(3, 3, 3, 1, "123 - 456 = -333");
        type_keys("B");
        type_keys("5A3D");  check_display(2, 0, 0, 0, "5 - 3 = 2");
        type_keys("B");
        type_keys("999A0D"); check_display(9, 9, 9, 0, "999 - 0 = 999");
        type_keys("B");
        type_keys("0A999D"); check_display(9, 9, 9, 1, "0 - 999 = -999");

        if (errors == 0) $display("top_tb: TODO OK");
        else             $display("top_tb: %0d ERRORES", errors);
        $finish;
    end

endmodule
