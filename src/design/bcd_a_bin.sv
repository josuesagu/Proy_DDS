// Convierte 3 dígitos BCD a binario (0 a 999) usando solo sumas y desplazamientos
// Autor: (nombre)
//
// binario = 100*centenas + 10*decenas + unidades
//   100 = 64 + 32 + 4   ->  (c << 6) + (c << 5) + (c << 2)
//    10 =  8 +  2       ->  (d << 3) + (d << 1)
// Se necesita porque los registros de inserción guardan BCD y la resta se hace en binario.
module bcd_a_bin (
    input  logic [11:0] bcd,   // {centenas, decenas, unidades}, cada una de 0 a 9
    output logic [9:0]  bin    // valor de 0 a 999
);

    logic [9:0] c, d, u;

    assign c = {6'b0, bcd[11:8]};
    assign d = {6'b0, bcd[7:4]};
    assign u = {6'b0, bcd[3:0]};

    assign bin = (c << 6) + (c << 5) + (c << 2) + (d << 3) + (d << 1) + u;

endmodule
