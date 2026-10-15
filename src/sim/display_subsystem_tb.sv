`timescale 1ns/1ps

// Los macros SS_0 ... SS_9 vienen de seven_seg_defs.sv (se compila antes, ver Makefile)
module display_subsystem_tb;

    logic       clk, reset;
    logic [9:0] value;
    logic       neg;
    logic [6:0] seg;
    logic [3:0] sel;
    int errors = 0;

    // DUT (Device Under Test)
    display_subsystem dut (
        .clk(clk),
        .reset(reset),
        .value(value),
        .neg(neg),
        .seg(seg),
        .sel(sel)
    );

    // Reloj de 27 MHz
    initial begin
        clk = 0;
        forever #18.52 clk = ~clk;
    end

    // Patrón esperado de un dígito, activo en alto (los macros del profesor son activos en bajo)
    function automatic [6:0] digit_pattern (input int d);
        case (d)
            0:       digit_pattern = ~`SS_0;
            1:       digit_pattern = ~`SS_1;
            2:       digit_pattern = ~`SS_2;
            3:       digit_pattern = ~`SS_3;
            4:       digit_pattern = ~`SS_4;
            5:       digit_pattern = ~`SS_5;
            6:       digit_pattern = ~`SS_6;
            7:       digit_pattern = ~`SS_7;
            8:       digit_pattern = ~`SS_8;
            default: digit_pattern = ~`SS_9;
        endcase
    endfunction

    // Patrón esperado según el dígito seleccionado
    function automatic [6:0] expected (input [3:0] s, input int v, input logic n);
        case (s)
            4'b0001: expected = digit_pattern(v % 10);          // unidades
            4'b0010: expected = digit_pattern((v / 10) % 10);   // decenas
            4'b0100: expected = digit_pattern(v / 100);         // centenas
            default: expected = n ? 7'b000_0001 : 7'b000_0000;  // signo menos o apagado
        endcase
    endfunction

    // Muestra un valor durante dos vueltas completas del multiplexado y revisa cada ciclo
    task check_value (input [9:0] v, input logic n);
        value = v;
        neg   = n;
        repeat (3000) @(negedge clk);              // espera a que el valor se propague
        repeat (2 * 65536) begin
            @(negedge clk);
            if (sel != 4'b0001 && sel != 4'b0010 && sel != 4'b0100 && sel != 4'b1000) begin
                errors++;
                $display("ERROR value=%0d neg=%b: sel no es de un solo dígito (%b)", v, n, sel);
            end
            else if (seg != expected(sel, v, n)) begin
                errors++;
                $display("ERROR value=%0d neg=%b sel=%b: got %b expected %b",
                         v, n, sel, seg, expected(sel, v, n));
            end
        end
        $display("Valor %0d (neg=%b) revisado", v, n);
    endtask

    initial begin
        $display("Starting test...");
        reset = 1; value = 0; neg = 0;
        repeat (4) @(negedge clk);
        reset = 0;

        check_value(10'd333, 1'b1);     // -333
        check_value(10'd7,   1'b0);     //  0007
        check_value(10'd999, 1'b1);     // -999
        check_value(10'd0,   1'b0);     //  0000
        check_value(10'd120, 1'b0);     //  0120

        $display("Test finished with %0d errors", errors);
        $finish;
    end

    initial begin
        $dumpfile("display_subsystem_tb.vcd");
        $dumpvars(0, display_subsystem_tb);
    end

endmodule
