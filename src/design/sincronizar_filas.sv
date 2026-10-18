//metaestabilidad de las filas, sincronizar las filas con el reloj de la FPGA

//metaestabilidad de las filas, sincronizar las filas con el reloj de la FPGA

module sincronizar_filas (
    input  logic       clk_fpga,
    input  logic       reset_B,
    input  logic [3:0] f_tecl,
    output logic [3:0] f_sinc // filas sincronizadas con el clock de la fpga
);

    // cable interno
    logic [3:0] f_etapa1; // conexion a los 4 primero flip flops

    
    always_ff @(posedge clk_fpga or negedge reset_B) begin
        if (reset_B == 1'b0) begin
            f_etapa1 <= 4'b1111; // CORREGIDO: antes era 4'b0000. Las filas son activas en bajo, el reposo (sin tecla) es 1111
            f_sinc   <= 4'b1111; // CORREGIDO: con 0000 el reset parecia "todas las teclas presionadas"

        end
        else begin
            f_etapa1 <= f_tecl;  // los primeros flip flops toman el valor de las señales en las filas del teclado
            f_sinc   <= f_etapa1; // los segundos flip flops aseguran los datos, sincronizadas.
        end
    end

endmodule

        