// Top de los ejercicios de laboratorio (Parte 5): genera el reloj de 1.8432 MHz
// Un contador de 32 bits suma INC en cada ciclo de 27 MHz. El bit más significativo
// (acc[31]) cambia a una frecuencia de INC * 27 MHz / 2^32 = 1.8432 MHz.
//   INC = 1.8432 MHz * 2^32 / 27 MHz = 293 203 101 (redondeado)
// Como 27 / 1.8432 = 14.65 (no es entero), el semiperiodo dura 7 u 8 ciclos de 27 MHz:
// la frecuencia promedio es exacta, pero cada periodo individual mide 518.5 ns o 555.6 ns.
// Esta señal sale de la FPGA hacia los circuitos externos; no se usa como reloj dentro de la FPGA.
module top_lab (
    input  logic clk,        // 27 MHz
    input  logic resetn,     // botón, activo en bajo
    output logic clk_out     // 1.8432 MHz hacia los circuitos externos
);

    localparam [31:0] INC = 32'd293203101;

    logic [31:0] acc;

    always_ff @(posedge clk or negedge resetn) begin
        if (resetn == 1'b0) acc <= 32'b0;
        else                acc <= acc + INC;
    end

    assign clk_out = acc[31];

endmodule
