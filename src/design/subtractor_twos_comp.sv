// Resta A - B con signo, usando complemento a 2 y solo el operador +
// A y B son enteros de 0 a 999 (10 bits). Se trabaja con 11 bits para tener el bit de signo:
//   diff = A + (~B + 1)      el resultado va de -999 a +999
//   si diff[10] = 1 el resultado es negativo y la magnitud es ~diff + 1
// Las salidas van registradas.
module subtractor_twos_comp (
    input  logic       clk_fpga,
    input  logic       reset_B,
    input  logic [9:0] a,
    input  logic [9:0] b,
    output logic       neg,    // 1 = resultado negativo
    output logic [9:0] mag     // magnitud del resultado
);

    logic [10:0] a_ext, b_ext, b_comp, diff, diff_comp;

    assign a_ext     = {1'b0, a};
    assign b_ext     = {1'b0, b};
    assign b_comp    = ~b_ext + 11'd1;     // -B en complemento a 2
    assign diff      = a_ext + b_comp;     // A + (-B)
    assign diff_comp = ~diff + 11'd1;      // para sacar la magnitud cuando es negativo

    always_ff @(posedge clk_fpga or negedge reset_B) begin
        if (reset_B == 1'b0) begin
            neg <= 1'b0;
            mag <= 10'b0;
        end
        else begin
            neg <= diff[10];
            if (diff[10] == 1'b1) mag <= diff_comp[9:0];
            else                  mag <= diff[9:0];
        end
    end

endmodule
