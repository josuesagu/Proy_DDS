//insercion de los datos

//insercion de los datos

module fsm_insercion (
    input  logic       clk_fpga,
    input  logic       reset_B,
    input  logic       s_aviso,
    input  logic [4:0] b_presionado,
    output logic       d1, // habilita carga de dato 1
    output logic       d2, // carga de dato 2
    output logic       R   // resultado
);

    // estados de la maquina de estados
    localparam state_S0 = 2'b00; // se esta ingresando el dato 1
    localparam state_S1 = 2'b01; // se esta ingresando el dato 2
    localparam state_S2 = 2'b10; // se esta calculando el resultado

    // flip flops
    logic [1:0] cs; // S1 S0
    logic [1:0] ns; // S'1 S'0

    always_ff @(posedge clk_fpga or negedge reset_B) begin
        if (reset_B == 1'b0) begin
            cs <= state_S0;
        end
        else begin
            cs <= ns;
        end
    end

    // next state logic
    always_comb begin
        ns = cs; // se mantiene en el mismo estado hasta que entre el input q habilita segun sea el caso
        case (cs)
            state_S0: begin
                if (s_aviso == 1'b1 && b_presionado == 5'd10) begin // cuando se presiona la A "operando" se pasa de ingresar el d1 al d2
                    ns = state_S1;
                end
            end

            state_S1: begin
                if (s_aviso == 1'b1 && b_presionado == 5'd13) begin // cuando se presiona la D "igual" se pasa de ingresar el d2 a calcular
                    ns = state_S2;
                end
            end

            state_S2: begin
                // NUEVO: segun el diagrama de estados, de S2 se vuelve a S0 al presionar B (reset de la operacion).
                // Antes S2 no tenia salida y solo se podia salir con el boton reset de la placa.
                if (s_aviso == 1'b1 && b_presionado == 5'd11) begin // cuando se presiona la B "reset" se vuelve a ingresar el d1
                    ns = state_S0;
                end
            end
            
            default: ns = state_S0; 
        endcase
    end

    // output logic
    always_comb begin
        d1 = 1'b0;
        d2 = 1'b0;
        R  = 1'b0;

        case(cs)
            state_S0: d1 = 1'b1;
            state_S1: d2 = 1'b1;
            state_S2: R  = 1'b1;
            default: begin d1 = 1'b0; d2 = 1'b0; R = 1'b0; end 
        endcase
    end

endmodule


