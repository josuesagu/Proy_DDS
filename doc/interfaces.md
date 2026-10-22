# Interfaces entre módulos

Todo es síncrono al reloj `clk` de 27 MHz (en el código del equipo se llama `clk_fpga`). Este documento dice qué señales conectan cada módulo; **si se cambia una, se actualiza aquí** (fecha y motivo al final).

## Diagrama de bloques

```
 teclado (row[3:0], col[3:0])                                              seg[6:0], sel[3:0]
        │                                                                          ▲
        ▼                                                                          │
 ┌────────────── insercion_top ─────────────────────────────┐              ┌───────┴────────┐
 │ tk_columnas → avance_columnas ─► col[3:0]                │              │display_subsystem│
 │ row ► sincronizar_filas ► DeBounce(profesor) ► deco_teclado              │ bcd_converter+  │
 │                          b_presionado, s_aviso            │              │ rom_reg, disp_  │
 │                              │                            │              │ hex_mux (prof.) │
 │                              ▼                            │              └───────▲────────┘
 │ fsm_insercion (d1, d2, R) ► registro_nums                 │                      │ value[9:0], neg
 └──────────────────────┬──────────┬───────────────────────┘              display_source_mux
                  BCD_d1[11:0]  BCD_d2[11:0]  d1 d2 R ─────────────────────────────►  ▲ ▲
                        │          │                                                    │ │
                    bcd_a_bin  bcd_a_bin ─► a_bin[9:0], b_bin[9:0] ─────────────────────┘ │
                        └────────┴────► subtractor_twos_comp ► res_mag[9:0], res_neg ─────┘
```

## Señales entre módulos

| # | De → a | Señales | Notas |
|---|---|---|---|
| 1 | `top` → `insercion_top` | `clk_fpga`, `reset_B`, `f_tecl[3:0]` (filas) | `f_tecl` activo en bajo: tecla presionada = 0 |
| 2 | `insercion_top` → `top` | `ubic_c[3:0]` (columnas) | El barrido pone una columna en 0 a la vez: 1110, 1101, 1011, 0111 |
| 3 | `tk_columnas` → `avance_columnas` | `TK_C` | Pulso de 1 ciclo cada 1 ms (27000 ciclos) |
| 4 | `avance_columnas` → teclado, `deco_teclado` | `ubic_c[3:0]` | Avanza solo si las filas están en reposo (`1111`) |
| 5 | `sincronizar_filas` → 4 × `DeBounce` | `f_sinc[3:0]` | Sincronizador de 2 flip-flops por fila |
| 6 | 4 × `DeBounce` → `deco_teclado`, `avance_columnas` | `f_listas[3:0]` | Filas filtradas. Cada `DeBounce` usa `N = 21` (ventana 38.8 ms), `n_reset` activo en bajo |
| 7 | `deco_teclado` → `fsm_insercion`, `registro_nums` | `b_presionado[4:0]`, `s_aviso` | `s_aviso` es un pulso de 1 ciclo al presionar. Códigos: 0–9 = dígitos, 10 = A, 11 = B, 12 = C, 13 = D, 14 = `*`, 15 = `#` |
| 8 | `fsm_insercion` → `registro_nums`, `top` | `d1`, `d2`, `R` | Moore, solo uno vale 1. `d1` = ingresando dato 1, `d2` = dato 2, `R` = resultado |
| 9 | `registro_nums` → `top` | `BCD_d1[11:0]`, `BCD_d2[11:0]` | `{centenas, decenas, unidades}`. Un cuarto dígito se **ignora** |
| 10 | `bcd_a_bin` → subtractor, mux | `a_bin[9:0]`, `b_bin[9:0]` | Binario de 0 a 999 |
| 11 | `subtractor_twos_comp` → mux | `res_neg`, `res_mag[9:0]` | Registradas (1 ciclo de latencia). `A + (~B + 1)` en 11 bits |
| 12 | `display_source_mux` → `display_subsystem` | `value[9:0]`, `neg` | `d1` muestra A, `d2` muestra B, `R` muestra el resultado con su signo |
| 13 | `display_subsystem` → `top` | `seg[6:0]`, `sel[3:0]` | Activos en alto |

## Uso de las teclas

| Tecla | Efecto |
|---|---|
| 0–9 | Agregan un dígito al número que se está ingresando (máximo 3) |
| A | Termina el dato 1 y pasa al dato 2 (la operación es siempre la resta) |
| D | "Igual": calcula y muestra el resultado |
| B | Desde el resultado: borra todo y vuelve a empezar |
| C, `*`, `#` | Sin función |

## Polaridades

- `resetn` (botón): activo en bajo. Los módulos del equipo lo usan directo como `reset_B` (asíncrono). `display_subsystem` usa un `reset` activo en alto, por eso `top` le pasa `~resetn`.
- Filas del teclado: activas en bajo, con pull-up interno de la FPGA.
- `seg` y `sel`: activos en alto (cátodo común, transistor NPN por dígito).

## Cambios

| Fecha | Qué cambió | Motivo |
|---|---|---|
| 22-oct | Se reemplazó el contrato inicial por las interfaces reales | El diseño cambió de nombres y se agregaron `d1`/`d2` a la salida de `insercion_top` |
| 22-oct | El cuarto dígito se ignora | Antes desplazaba el registro (1234 → 234) |
