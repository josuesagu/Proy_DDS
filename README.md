# Proyecto 2 — Calculadora de resta con teclado hexadecimal y display de 7 segmentos

Curso EL-3307 Diseño Lógico, II Semestre 2026. Placa **Tang Nano 9K** (GW1NR-LV9QN88PC6/I5), reloj único de 27 MHz.

**Integrantes:** (nombre A) · (nombre B)

Resta dos enteros de hasta 3 dígitos digitados en un teclado hexadecimal 4×4 (Grayhill 96BB2-006-F) y muestra el resultado con signo en 4 displays de 7 segmentos de cátodo común. La Parte 5 (mediciones con analizador lógico) está descrita en `doc/mediciones/`.

## Estructura

```
.
├── README.md
├── .gitignore
├── doc/                    documentación (no se sintetiza)
│   ├── interfaces.md       contrato de señales entre módulos
│   ├── estandar_de_codigo.md
│   ├── referencias.md      citas de todo lo que no es propio
│   ├── originales_profe/   código del profesor tal como se recibió
│   ├── diagramas/          diagramas de bloques, FSM y plano completo
│   ├── mediciones/         capturas del analizador lógico (Parte 5)
│   ├── bitacora/           fotos de la bitácora (opcional)
│   └── Tang_Nano_9k_3672_Schematic.pdf
└── src/
    ├── build/              Makefile y bcdtable.txt (se corre make aquí)
    ├── constr/             constraints (.cst)
    ├── design/             código sintetizable
    │   ├── profesor/       código del profesor, sin modificar
    │   └── *.sv            módulos propios (uno por archivo)
    └── sim/                testbenches (<módulo>_tb.sv)
        └── profesor/       testbenches del profesor
```

## Cómo usarlo

Se necesita Yosys, nextpnr-gowin, Apicula (`gowin_pack`), Icarus Verilog, GTKWave y openFPGALoader (el flujo del curso).

```
cd src/build
make test TB=display_subsystem   # simula ../sim/display_subsystem_tb.sv
make test TB=debounce            # simula ../sim/debounce_tb.sv
make wv TB=debounce              # abre las formas de onda en GTKWave
make synth                       # síntesis (log en synthesis_tangnano9k.log)
make all                         # síntesis, pnr, bitstream y carga en la placa
make clean                       # borra lo que genera el flujo
```

Mientras no exista `top.sv`: `make synth TOP_DESIGN=display_subsystem`.

El Makefile difiere del del curso en cuatro cosas, explicadas en su primer comentario: lista los archivos del profesor en orden (los macros `SS_x` deben definirse primero), sintetiza con `read_verilog -defer`, elige el testbench con `TB=` y agrega `clean`.

## Código del profesor (obligatorio, no se modifica)

| Archivo | Directiva | Uso |
|---|---|---|
| `design/profesor/DeBounce_v.v` | OBL-1 (antirrebote) | Se instancia sobre la señal "hay tecla presionada" del teclado |
| `design/profesor/disp_hex_mux.sv` + `seven_seg_defs.sv` | OBL-2 (despliegue de 7 segmentos) | Multiplexado y decodificación; **único cambio:** `N = 16` para 27 MHz, marcado en el archivo |
| `design/profesor/bcd_converter.sv` + `rom_reg.sv` | OBL-3 (binario a BCD) | `N=10, M=12`, con la tabla `build/bcdtable.txt` (1024 líneas) |

Las copias intactas están en `doc/originales_profe/` para poder comparar.

## Estado de los módulos

| Módulo | Dueño | Estado |
|---|---|---|
| `display_subsystem` | A | hecho, simulado |
| `display_source_mux`, `operand_entry`, `subtractor_twos_comp`, `control_fsm` | A | por hacer |
| `sync_2ff`, `tick_gen`, `ring_counter`, `keypad_scanner`, `keypad_decoder`, `top` | B | por hacer |
| Parte 5 (5.1 y 5.2 / 5.3) | A / B | por hacer |

Actualicen esta tabla en cada *pull request*.

## Flujo de trabajo en Git

- `main` solo recibe cambios por *pull request* revisado por la otra persona.
- Una rama por módulo: `feat/<módulo>`. Commits pequeños, en español, con el módulo al inicio: `[subtractor] resta con complemento a 2`.
- Cada módulo se entrega con su testbench y pasa `make test` antes del PR.
- Etiquetas para los hitos: `H0` … `H6` y `v1.0` al congelar.
