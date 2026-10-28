`timescale 1ns/1ps

// Prueba del antirrebote del profe (DeBounce_v.v, no se modifica).
// Se usa N = 6: la ventana es 2^(N-1) = 32 ciclos (en la placa se usará N = 20 o 21).
module debounce_tb;

    logic clk, n_reset, button_in;
    logic db_out;
    int errors = 0;

    // DUT (Device Under Test)
    DeBounce #(.N(6)) dut (
        .clk(clk),
        .n_reset(n_reset),
        .button_in(button_in),
        .DB_out(db_out)
    );

    // Reloj de 27 MHz
    initial begin
        clk = 0;
        forever #18.52 clk = ~clk;
    end

    // Mantiene el botón en un valor durante 'cycles' ciclos de reloj
    task hold (input logic value, input int cycles);
        button_in = value;
        repeat (cycles) @(negedge clk);
    endtask

    // Revisa la salida; 'id' identifica la revisión en el mensaje
    task check (input logic expected, input int id);
        if (db_out !== expected) begin
            errors++;
            $display("ERROR %0d: db_out=%b expected %b", id, db_out, expected);
        end
        else
            $display("OK %0d: db_out=%b", id, db_out);
    endtask

    initial begin
        $display("Starting test...");
        n_reset = 0; button_in = 0;
        repeat (4) @(negedge clk);
        n_reset = 1;

        // DB_out no tiene reset propio: vale x hasta que el contador llega a su MSB
        hold(0, 100);
        check(0, 1);                      // reposo estable

        // Rebotes más cortos que la ventana (32 ciclos): no deben pasar
        repeat (5) begin
            hold(1, 6);
            hold(0, 6);
        end
        hold(1, 10);
        hold(0, 10);
        check(0, 2);                      // los rebotes se filtraron

        hold(1, 100);
        check(1, 3);                      // pulsación estable detectada

        repeat (4) begin                  // la suelta también rebota
            hold(0, 5);
            hold(1, 5);
        end
        hold(0, 100);
        check(0, 4);                      // suelta detectada

        $display("Test finished with %0d errors", errors);
        $finish;
    end

    initial begin
        $dumpfile("debounce_tb.vcd");
        $dumpvars(0, debounce_tb);
    end

endmodule
