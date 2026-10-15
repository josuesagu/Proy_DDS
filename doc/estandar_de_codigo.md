# Estándar de código del Proyecto 2 (fijo para todo el proyecto)

Estas reglas salen de lo que pidió el usuario y de los archivos del profesor (BlinkyLed, Seven_seg, lcd_spi, debouncer y diapositivas *Useful Circuits*). **Todo módulo nuevo se escribe y se revisa contra esta lista.** Si una regla estorba, se cambia aquí primero, de común acuerdo.

## 1. Reglas fijas

1. **Código del profesor obligatorio y sin modificar.** Debouncer (OBL-1), `disp_hex_mux` + `seven_seg_defs` para el display (OBL-2), `bcd_converter` + `rom_reg` (OBL-3). Se instancian tal cual. Lo único que se cambia son los **parámetros** al instanciar, más el `N` de refresco de `disp_hex_mux` (que el propio archivo indica cambiar), documentado en el archivo. Cualquier adaptación (polaridad, signo) se hace **fuera** de esos módulos.
2. **Sencillo y legible por encima de todo.** Un módulo hace una cosa y cabe en una pantalla o dos. Si existe una forma simple y una "elegante", se usa la simple.
3. **Estilo del profesor**, es decir, solo construcciones que aparecen en sus archivos:
   - `logic` para todo (no `reg`/`wire` en código nuevo).
   - `assign` para lógica combinacional de una línea.
   - `always_comb` + `case` para tablas y decodificadores; `always_ff` para registros.
   - `localparam` para constantes y estados, `parameter` en la cabecera `#(...)`.
   - Puertos con nombre en las instancias (`.clk(clk)`), nunca por posición.
4. **No se usan:** `typedef enum`, `struct`, `package`, `interface`, `generate`, `function` en diseño (sí en testbench), operadores `-`, `/`, `%` en el RTL. Los contadores usan `+ 1`. La resta del proyecto usa `+` con complemento a 2.
5. **Un solo reloj** (`clk`, 27 MHz). Ningún `always_ff` usa otra señal como reloj; los tiempos lentos se hacen con un `tick` de 1 ciclo.
6. **Reset** interno activo en alto y asíncrono, como en el debouncer del profesor: `always_ff @(posedge clk, posedge reset)`. El `top` lo genera a partir del botón (activo en bajo, pin 4).
   **Excepción:** el `DeBounce_v.v` del profesor (en Verilog, no se modifica) usa `n_reset` **activo en bajo y síncrono**. El `top` conecta `resetn` (el botón) directo ahí y `reset = ~resetn` al resto. `DB_out` no tiene reset propio: en simulación es `x` hasta que el contador llega a su MSB por primera vez.
7. **Sin latches:** toda salida de un `always_comb` tiene valor por defecto al inicio y todo `case` lleva `default`.
8. **Asignaciones:** `<=` en `always_ff`, `=` en `always_comb`. Nunca mezclarlas.
9. **Entradas externas** (filas del teclado, botones) pasan por 2 flip-flops y por el debouncer antes de usarse. Salidas de cada subsistema **registradas**.

## 2. Nombres y formato

| Elemento | Regla | Ejemplo |
|---|---|---|
| Módulos y señales | `snake_case`, en inglés | `display_subsystem`, `key_valid` |
| Parámetros y `localparam` | `MAYÚSCULAS` | `REFRESH_N`, `IDLE` |
| Registro / siguiente valor | sufijos `_reg` / `_next` (como el debouncer) | `state_reg`, `state_next` |
| Señal activa en bajo | sufijo `_n` | `resetn` |
| Pulso de 1 ciclo | sufijo `_tick` o `_valid`/`_we` | `db_tick`, `digit_we` |
| Comentarios | en español; explican el *por qué* | `// por defecto: mismo estado` |
| Archivos | un módulo por archivo, mismo nombre | `design/display_subsystem.sv` |
| Testbench | `sim/<módulo>_tb.sv`, módulo `<módulo>_tb`, VCD `<módulo>_tb.vcd` | `display_subsystem_tb` |
| Encabezado | 2–4 líneas: qué hace, autor, notas de codificación | ver §3 |

Indentación de 4 espacios. Bloque de puertos alineado. Un puerto por línea.

**Carpetas:** `design/` solo con lo que se sintetiza (el Makefile del curso toma **todos** los `.sv` de esa carpeta; nada de testbenches ahí), `sim/`, `constr/`, `build/` (con `bcdtable.txt` y el Makefile), `docs/`.

## 3. Plantillas

### Combinacional (tabla o decodificador)
Ver el bloque `always_comb` con `if` y valores por defecto de `proyecto2/src/design/display_subsystem.sv`.

### Secuencial simple

```systemverilog
module contador #(parameter N = 4) (
    input  logic         clk, reset,
    output logic [N-1:0] count
);

    always_ff @(posedge clk, posedge reset)
        if (reset) count <= 0;
        else       count <= count + 1;

endmodule
```

### FSM (formato del debouncer del profesor: registro de estado + siguiente estado y salidas)

```systemverilog
module ejemplo_fsm (
    input  logic clk, reset,
    input  logic start,
    output logic busy
);

    // Estados (declaración simbólica, como en el debouncer del profesor)
    localparam [1:0] IDLE = 2'b00,
                     WORK = 2'b01,
                     DONE = 2'b10;

    logic [1:0] state_reg, state_next;

    // Registro de estado
    always_ff @(posedge clk, posedge reset)
        if (reset) state_reg <= IDLE;
        else       state_reg <= state_next;

    // Lógica de siguiente estado y salidas
    always_comb begin
        state_next = state_reg;      // por defecto: se queda en el mismo estado
        busy       = 1'b0;           // por defecto: salidas en 0
        case (state_reg)
            IDLE: begin
                if (start) state_next = WORK;
            end
            WORK: begin
                busy       = 1'b1;
                state_next = DONE;
            end
            DONE: begin
                state_next = IDLE;
            end
            default: state_next = IDLE;
        endcase
    end

endmodule
```

Las FSM se dibujan **primero** (diagrama de estados) y luego se codifican. Las señales de control salen de la FSM; los datos los mueve el datapath, nunca la FSM directamente.

### Testbench (formato de `Seven_seg/top_tb.sv`)
Ver `proyecto2/src/sim/display_subsystem_tb.sv`: `timescale`, señales `logic`, DUT con puertos con nombre, `function expected`, ciclo `for`, mensajes `OK`/`ERROR`, contador de errores, `$finish`, y `$dumpfile`/`$dumpvars` al final. Para relojes, semiperiodo `#18.52` (27 MHz), como en `lcd_spi`.

## 4. Lista de revisión antes de cada pull request

- [ ] ¿Cumple las reglas de la sección 1?
- [ ] ¿Cabe en una o dos pantallas y se entiende sin explicación?
- [ ] ¿Todos los `case` tienen `default` y todas las salidas de `always_comb` valor por defecto?
- [ ] ¿Sin `-`, `/`, `%` ni otro reloj?
- [ ] ¿Tiene testbench con auto-chequeo (`OK`/`ERROR`) y pasa con `make test`?
- [ ] ¿Sintetiza con Yosys sin errores (`make synth`) y sin *latches* en el log?
- [ ] ¿Encabezado con autor y comentarios en español?
- [ ] ¿El otro integrante lo entendió al revisarlo? (si no, se simplifica)
