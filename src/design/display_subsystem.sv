// Subsistema de despliegue: número de 0 a 999 con signo en 4 displays de cátodo común
// Autor: (nombre)
//
// Usa, sin modificar, los módulos del profesor:
//   bcd_converter (OBL-3): binario -> BCD
//   disp_hex_mux  (OBL-2): multiplexado de 4 dígitos y decodificación a 7 segmentos
//
// El disp_hex_mux del profesor entrega las señales activas en BAJO (an y sseg).
// Con displays de cátodo común hace falta activo en ALTO, así que aquí se invierten.
// Además disp_hex_mux solo muestra dígitos 0-F, así que el signo menos del dígito
// de la izquierda se pone aquí (solo segmento g) o se apaga ese dígito.
//
// Orden de bits de seg: {a, b, c, d, e, f, g} (bit 6 = a ... bit 0 = g)
module display_subsystem (
    input  logic       clk, reset,
    input  logic [9:0] value,     // número a mostrar (0 a 999)
    input  logic       neg,       // 1 = mostrar signo menos, 0 = dígito de signo apagado
    output logic [6:0] seg,       // segmentos a-g, activos en alto
    output logic [3:0] sel        // dígito activo, activo en alto (base del transistor NPN)
);

    logic [11:0] bcd;             // {centenas, decenas, unidades}
    logic [3:0]  an;              // salida de disp_hex_mux (activa en bajo)
    logic [7:0]  sseg;            // salida de disp_hex_mux (activa en bajo)
    logic [7:0]  sseg_sign;       // sseg con el dígito de signo corregido

    // binario -> BCD (código del profesor)
    bcd_converter #(.N(10), .M(12)) bcd_unit (
        .input_bin(value),
        .output_bcd(bcd)
    );

    // multiplexado y decodificación a 7 segmentos (código del profesor)
    disp_hex_mux mux_unit (
        .clk(clk),
        .reset(reset),
        .hex3(4'h0),              // este dígito lo reemplaza el signo (abajo)
        .hex2(bcd[11:8]),
        .hex1(bcd[7:4]),
        .hex0(bcd[3:0]),
        .dp_in(4'b1111),          // puntos decimales apagados
        .an(an),
        .sseg(sseg)
    );

    // Dígito de la izquierda (an = 0111): signo menos o apagado (activo en bajo)
    always_comb begin
        sseg_sign = sseg;                          // por defecto: lo que entrega disp_hex_mux
        if (an == 4'b0111) begin
            if (neg) sseg_sign = 8'b1111_1110;     // solo segmento g
            else     sseg_sign = 8'b1111_1111;     // todo apagado
        end
    end

    // Salidas registradas, ya invertidas a activo en alto
    always_ff @(posedge clk, posedge reset)
        if (reset) begin
            seg <= 7'b000_0000;
            sel <= 4'b0000;
        end
        else begin
            seg <= ~sseg_sign[6:0];
            sel <= ~an;
        end

endmodule
