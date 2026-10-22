# Proyecto 2 — Calculadora de resta con teclado hexadecimal y display de 7 segmentos

Curso EL-3307 Diseño Lógico, II Semestre 2026. **Tang Nano 9K** (GW1NR-LV9QN88PC6/I5), reloj único de 27 MHz.

**Integrantes:** Ariel Elizondo · Josué Sanabria

Resta dos enteros de hasta 3 dígitos digitados en un teclado hexadecimal 4×4 (Grayhill 96BB2-006-F) y muestra el resultado con signo en 4 displays de 7 segmentos de cátodo común. La Parte 5 (mediciones con analizador lógico) se documenta en `doc/mediciones/`.

## Cómo se usa la calculadora

| Tecla | Efecto |
|---|---|
| 0–9 | Agregan un dígito al número que se está ingresando (máximo 3; **un cuarto dígito se ignora**) |
| A | Termina el dato 1 y pasa al dato 2 (la operación siempre es la resta) |
| D | "Igual": muestra el resultado, con signo menos si es negativo |
| B | Desde el resultado: borra todo y vuelve a empezar |
| C, `*`, `#` | Sin función |

Los displays muestran el número que se está ingresando y, al final, el resultado (3 dígitos y el signo en el cuarto display). Los ceros a la izquierda se muestran. El botón de la placa (`resetn`) reinicia todo.

## Estructura

```
.
├── README.md
├── .gitignore
├── doc/
│   ├── interfaces.md           señales entre módulos y diagrama de bloques
│   ├── estandar_de_codigo.md   reglas de código del proyecto
│   ├── referencias.md          citas de todo lo que no es propio
│   ├── originales_profe/       código del profesor tal como se recibió
│   ├── diagramas/              diagramas de bloques, FSM y plano completo
│   ├── mediciones/             capturas del analizador lógico (Parte 5)
│   ├── bitacora/               fotos de la bitácora
│   └── Tang_Nano_9k_3672_Schematic.pdf
└── src/
    ├── build/                  Makefile y bcdtable.txt (se corre make aquí)
    ├── constr/                 proyecto2.cst (completo) y prueba_display.cst (solo displays)
    ├── design/                 código sintetizable
    │   ├── profesor/           código del profesor, sin modificar
    │   └── *.sv                módulos propios (uno por archivo)
    └── sim/                    testbenches
        └── profesor/           testbenches del profesor
```

## Cómo se corre

Se necesita Yosys, nextpnr-gowin, Apicula (`gowin_pack`), Icarus Verilog, GTKWave y openFPGALoader (el flujo del curso). Los comandos se ejecutan en `src/build`:

```
make test                         # simula top_tb (la prueba completa: teclado, resta y displays)
make test TB=display_subsystem_tb # simula otro testbench (nombre del archivo sin .sv)
make wv TB=top_tb                 # abre las formas de onda en GTKWave
make synth                        # síntesis (log en synthesis_tangnano9k.log)
make all                          # síntesis, pnr, bitstream y carga en la placa
make clean                        # borra lo que genera el flujo
```

El Makefile difiere del del curso en: lista los archivos del profesor en orden (los macros `SS_x` se definen primero), sintetiza con `read_verilog -defer` (si no, Yosys falla con `rom_reg`), elige el testbench con `TB=` y agrega `clean`.

**Windows:** ejecuten `make` desde una terminal que tenga las carpetas `bin` y `lib` de OSS CAD Suite primero en el `PATH` (la terminal de OSS CAD Suite o un perfil de VS Code que lo haga). Si no, Yosys puede cargar DLLs de otros programas (por ejemplo Strawberry Perl) y morir con el error `-1073741511`.

### Prueba de montaje en la placa, por pasos

1. **Solo displays.** `make all TOP_DESIGN=top_prueba_display CONSTRAINTS=../constr/prueba_display.cst`. Muestra 888, -123, 456 y -999, cambiando cada 1.2 s. Si un dígito sale en otra posición, se intercambian los pines `sel` en el `.cst`, no el código.
2. **Todo junto.** `make all` con el `top` y `proyecto2.cst`.

## Cómo está armado

```
teclado ─► sincronizar_filas ─► DeBounce (profesor, N=21) ─► deco_teclado ─► fsm_insercion (d1, d2, R)
tk_columnas ─► avance_columnas ─► columnas del teclado                    └► registro_nums (BCD_d1, BCD_d2)
BCD_d1, BCD_d2 ─► bcd_a_bin ─► subtractor_twos_comp ─► display_source_mux ─► display_subsystem ─► seg, sel
```

El detalle de cada señal está en `doc/interfaces.md`. Decisiones que conviene saber:
- **Barrido:** una columna en 0 cada 1 ms (`tk_columnas`); el barrido se detiene mientras haya una fila activa. Las columnas llevan 330 Ω en serie.
- **Debouncer:** `N = 21` da una ventana de 38.8 ms (el teclado rebota hasta 12 ms), así que hay que mantener cada tecla unos 40 ms.
- **Resta:** `A + (~B + 1)` en 11 bits, sin el operador `-`. El signo es el bit 10 y la magnitud sale de invertir y sumar 1 si es negativo.
- **Despliegue:** `display_subsystem` convierte el binario a BCD con `bcd_converter` + `rom_reg`, multiplexa con `disp_hex_mux` y agrega el signo (segmento g del cuarto dígito) fuera de los módulos del profesor, junto con la inversión de polaridad para el transistor NPN.
- **Reset:** el botón `resetn` es activo en bajo; `display_subsystem` usa un `reset` activo en alto (el `top` le pasa `~resetn`).

## Código del profesor (obligatorio, no se modifica)

| Archivo | Directiva | Uso |
|---|---|---|
| `design/profesor/DeBounce_v.v` | OBL-1 (antirrebote) | Una instancia por fila del teclado, dentro de `insercion_top` |
| `design/profesor/disp_hex_mux.sv` + `seven_seg_defs.sv` | OBL-2 (despliegue de 7 segmentos) | Multiplexado y decodificación; **único cambio:** `N = 16` para 27 MHz, marcado en el archivo |
| `design/profesor/bcd_converter.sv` + `rom_reg.sv` | OBL-3 (binario a BCD) | `N=10, M=12`, con la tabla `build/bcdtable.txt` (1024 líneas) |

Las copias intactas están en `doc/originales_profe/` para poder comparar.

## Estado

| Parte | Estado |
|---|---|
| Teclado, inserción, resta y despliegue (RTL) | Hecho; `top_tb` pasa con -333, 2, 999 y -999; síntesis y pnr sin errores (37 MHz con reloj de 27 MHz) |
| Montaje en placa (displays, teclado) | Pendiente |
| Medir qué pines del teclado son filas y columnas | Pendiente (la asignación de pines es provisional) |
| Parte 5 (5.1, 5.2, 5.3) | Pendiente |
| Diagramas, bitácora y reporte | Pendiente |

Actualicen esta tabla cuando algo cambie.

## Flujo de trabajo en Git

- `main` solo recibe cambios por *pull request* revisado por la otra persona.
- Una rama por módulo: `feat/<módulo>`. Commits pequeños, en español, con el módulo al inicio: `[subtractor] resta con complemento a 2`.
- Cada módulo se entrega con su testbench y pasa `make test` antes del PR.
- Etiquetas para los hitos: `H0` … `H6` y `v1.0` al congelar.
