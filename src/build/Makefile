#Makefile del Proyecto 2. Basado en el de los ejemplos del curso (Yosys, nextpnr, iverilog, gtkwave y openFPGALoader).
#Cambios respecto al del curso, cada uno con su motivo:
# 1. SOURCES: primero, en orden, los archivos del profesor (seven_seg_defs define los macros SS_x que usan
#    disp_hex_mux e invsseg); despues todos los modulos propios con wildcard.
# 2. synth usa "read_verilog -sv -defer": sin -defer, Yosys 0.33 falla buscando el archivo "dataFile" de rom_reg.
# 3. test compila SOURCES antes del testbench y el testbench se elige con TB:  make test TB=display_subsystem
# 4. Se agrega 'clean'.

#FPGA a utilizar... Esto no se debe modificar para efectos del curso.
BOARD  = tangnano9k
FAMILY = GW1N-9C
DEVICE = GW1NR-LV9QN88PC6/I5

#Nombre del proyecto
PROYECT = proyecto2

#Fuentes de diseno
#Archivos del profesor, sin modificar (el orden importa: los macros primero)
PROFE = ../design/profesor
SOURCES_PROFE = $(PROFE)/seven_seg_defs.sv $(PROFE)/rom_reg.sv $(PROFE)/bcd_converter.sv $(PROFE)/disp_hex_mux.sv $(PROFE)/DeBounce_v.v
#Modulos propios: todos los .sv que estan en design (no entra la subcarpeta profesor)
SOURCES := $(SOURCES_PROFE) $(wildcard ../design/*.sv)

#Simulacion: make test TB=nombre_del_archivo_sin_extension (ej. TB=tb_fsm_insercion); el modulo del tb debe llamarse igual
TB ?= top_tb
TESTBENCH = ../sim/$(TB).sv
TOP_TB    = $(TB)
VCD_FILE  = $(TB).vcd

# Constraints para el proyecto
CONSTRAINTS = ../constr/proyecto2.cst

#el top se indica sin la extension .sv, esto hace referencia al nombre del modulo y no al del archivo.
#Mientras no exista top.sv se puede sintetizar un subsistema:  make synth TOP_DESIGN=display_subsystem
TOP_DESIGN ?= top


all: synth pnr bitstream load

# Synthesis
synth: ${SOURCES}
	@echo "Ejecutando la sintesis..."
	@yosys -p "read_verilog -sv -defer ${SOURCES}; synth_gowin -top ${TOP_DESIGN} -json ${PROYECT}.json" > synthesis_${BOARD}.log 2>&1 
	@echo "COMPLETADO (revisar synthesis_${BOARD}.log)"

# Place and Route
pnr: ${PROYECT}.json
	@echo "Ejecutando el pnr..."
	@nextpnr-gowin --json ${PROYECT}.json --write ${PROYECT}_pnr.json --freq 27 --device ${DEVICE} --family ${FAMILY} --cst ${CONSTRAINTS} > pnr_${BOARD}.log 2>&1 
	@echo "COMPLETADO (revisar pnr_${BOARD}.log)"

# Generar el Bitstream
bitstream: ${PROYECT}_pnr.json
	@echo "Generando ${PROYECT}_${BOARD}.fs"
	@gowin_pack -d ${FAMILY} -o ${PROYECT}_${BOARD}.fs ${PROYECT}_pnr.json
	@echo "COMPLETADO"

#Generar vcd con icarus verilog
test: ${SOURCES} ${TESTBENCH}
	@iverilog -o ${TB}_test.o -s ${TOP_TB} -g2005-sv ${SOURCES} ${TESTBENCH}
	@vvp ${TB}_test.o 

#Visualizar los diagramas de tiempo con GTKWave
wv: ${VCD_FILE}
	gtkwave ${VCD_FILE} 

# Cargar el bitstream en la FPGA
load: ${PROYECT}_${BOARD}.fs
	openFPGALoader -b ${BOARD} ${PROYECT}_${BOARD}.fs 

# Borrar lo que genera el flujo (no borra bcdtable.txt ni el Makefile)
clean:
	rm -f *.json *.fs *.log *.o *.vcd

.PHONY: load wv clean
.INTERMEDIATE: ${PROYECT}_pnr.json ${PROYECT}.json
