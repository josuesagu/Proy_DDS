// Top de PRUEBA para el montaje: solo displays, sin teclado
// Autor: (nombre)
//
// Sirve para comprobar el cableado de los displays antes de conectar el teclado.
// Muestra, cambiando cada ~1.2 s, estos valores:
//   888  (todos los segmentos encendidos)
//   -123 (signo y orden de los dígitos)
//   456
//   -999
// Si un dígito sale en otra posición, se intercambian los pines sel en el .cst.
//
// Uso:  make all TOP_DESIGN=top_prueba_display CONSTRAINTS=../constr/prueba_display.cst
module top_prueba_display #(
    parameter BIT_CAMBIO = 25      // bit del contador que cambia el valor: 2^25 / 27 MHz = 1.2 s
) (
    input  logic       clk,
    input  logic       resetn,
    output logic [6:0] seg,
    output logic [3:0] sel
);

    logic [26:0] cuenta;           // contador libre
    logic [1:0]  paso;             // cuál de los 4 valores se muestra
    logic [9:0]  value;
    logic        neg;

    always_ff @(posedge clk or negedge resetn) begin
        if (resetn == 1'b0) cuenta <= 27'b0;
        else                cuenta <= cuenta + 27'b1;
    end

    // los 2 bits que empiezan en BIT_CAMBIO
    assign paso = cuenta >> BIT_CAMBIO;

    always_comb begin
        value = 10'd888;
        neg   = 1'b0;
        case (paso)
            2'd0:    begin value = 10'd888; neg = 1'b0; end
            2'd1:    begin value = 10'd123; neg = 1'b1; end
            2'd2:    begin value = 10'd456; neg = 1'b0; end
            2'd3:    begin value = 10'd999; neg = 1'b1; end
            default: begin value = 10'd888; neg = 1'b0; end
        endcase
    end

    // display_subsystem usa reset activo en alto
    display_subsystem pantalla (
        .clk   (clk),
        .reset (~resetn),
        .value (value),
        .neg   (neg),
        .seg   (seg),
        .sel   (sel)
    );

endmodule
