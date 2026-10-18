//modulo para crear el tick de un 1ms tiempo real, para avanzar a mapear las columnas
// 1kHz real / 27 MHz fpga = 27000 ciclos de reloj
// registro de 15 bits

//modulo para crear el tick de un 1ms tiempo real, para avanzar a mapear las columnas
// 1kHz real / 27 MHz fpga = 27000 ciclos de reloj
// registro de 15 bits

module tk_columnas (
    input  logic clk_fpga,
    input  logic reset_B,
    output logic TK_C // pulso de un ciclo en tiempo real para pasar a la siguiente columna
);

    // puede contar hasta 32768
    logic [14:0] cuenta_int;

    // 15 flip flops
    always_ff @(posedge clk_fpga or negedge reset_B) begin 
        if (reset_B == 1'b0) begin
            cuenta_int <= 15'b0;
        end
        else begin
            if (cuenta_int == 15'd26999) begin // CORREGIDO: antes 27000. Contando de 0 a 26999 son exactamente 27000 ciclos = 1 ms
                cuenta_int <= 15'b0; // para reiniciar la cuenta del reloj interno
            end
            else begin
                cuenta_int <= cuenta_int + 15'b1; // avanza la cuenta
            end
        end
    end // Cierre del always_ff en su lugar correcto

    // levanta la señal para pasar a la siguiente columna durante un ciclo
    assign TK_C = (cuenta_int == 15'd26999) ? 1'b1 : 1'b0;

endmodule
