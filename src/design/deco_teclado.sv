//detector de la tecla/boton presionado

module deco_teclado (
    input  logic       clk_fpga,
    input  logic       reset_B,
    input  logic [3:0] f_listas, // filas de modulo de rebote
    input  logic [3:0] ubic_c,
    output logic [4:0] b_presionado,
    output logic       s_aviso   // indica que hay una tecla valida presionada, señal de ingreso de dato
);

    logic t_detec;
    logic t_ant;

    always_comb begin 
        b_presionado = 5'b10000;
        t_detec = 1'b0;

        case (ubic_c)
            4'b1110: begin // si la columa es 0, los botones puede ser 1,4,7,*
                if      (f_listas == 4'b1110) begin b_presionado = 5'd1;  t_detec = 1'b1; end
                else if (f_listas == 4'b1101) begin b_presionado = 5'd4;  t_detec = 1'b1; end
                else if (f_listas == 4'b1011) begin b_presionado = 5'd7;  t_detec = 1'b1; end
                else if (f_listas == 4'b0111) begin b_presionado = 5'd14; t_detec = 1'b1; end
            end

            4'b1101: begin // si la columa es 1, los botones puede ser 2,5,8,0
                if      (f_listas == 4'b1110) begin b_presionado = 5'd2;  t_detec = 1'b1; end 
                else if (f_listas == 4'b1101) begin b_presionado = 5'd5;  t_detec = 1'b1; end 
                else if (f_listas == 4'b1011) begin b_presionado = 5'd8;  t_detec = 1'b1; end 
                else if (f_listas == 4'b0111) begin b_presionado = 5'd0;  t_detec = 1'b1; end 
            end

            4'b1011: begin // si la columa es 2, los botones puede ser 3,6,9,#
                if      (f_listas == 4'b1110) begin b_presionado = 5'd3;  t_detec = 1'b1; end 
                else if (f_listas == 4'b1101) begin b_presionado = 5'd6;  t_detec = 1'b1; end 
                else if (f_listas == 4'b1011) begin b_presionado = 5'd9;  t_detec = 1'b1; end 
                else if (f_listas == 4'b0111) begin b_presionado = 5'd15; t_detec = 1'b1; end 
            end

            4'b0111: begin // si la columa es 3, los botones puede ser A,B,C,D
                if      (f_listas == 4'b1110) begin b_presionado = 5'd10; t_detec = 1'b1; end 
                else if (f_listas == 4'b1101) begin b_presionado = 5'd11; t_detec = 1'b1; end 
                else if (f_listas == 4'b1011) begin b_presionado = 5'd12; t_detec = 1'b1; end 
                else if (f_listas == 4'b0111) begin b_presionado = 5'd13; t_detec = 1'b1; end 
            end

            default: begin b_presionado = 5'b10000; t_detec = 1'b0; end
        endcase
    end 


    always_ff @(posedge clk_fpga or negedge reset_B) begin
        if (reset_B == 1'b0) begin
            t_ant <= 1'b0;
        end
        else begin
            t_ant <= t_detec;
        end
    end
    
    assign s_aviso = (t_detec == 1'b1 && t_ant == 1'b0) ? 1'b1 : 1'b0; // tecla valida presionada

endmodule
