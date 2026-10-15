# Contrato de interfaces

Todo síncrono a `clk` (27 MHz). Los estrobos son pulsos de 1 ciclo, activos en alto. Toda salida de subsistema va registrada. **Se cambia solo con acuerdo de ambos** (se anota la fecha y el motivo al final).

| # | De → a | Señales | Notas |
|---|---|---|---|
| 1 | Teclado (B) → `control_fsm` (A) | `key_valid` (pulso), `key_code[3:0]` (0–F) | `key_code` es válido solo cuando `key_valid = 1` |
| 2 | `control_fsm` → `operand_entry` | `clr_all`, `digit_we` (pulso), `digit[3:0]` (0–9), `sel_b` (0 = A, 1 = B) | `operand_entry` ignora dígitos si ya tiene 3 |
| 3 | `control_fsm` → `subtractor_twos_comp` | `calc_go` (pulso) | El resultado queda listo 1 ciclo después |
| 4 | `operand_entry` → subtractor y mux | `a_val[9:0]`, `b_val[9:0]` | Binario simple, 0 a 999 |
| 5 | `subtractor_twos_comp` → mux | `res_neg`, `res_mag[9:0]` | `res_neg = 0` si el resultado es 0 |
| 6 | `control_fsm` → `display_source_mux` | `show_sel[1:0]` | 00 = A, 01 = B, 10 = resultado |
| 7 | `display_source_mux` → `display_subsystem` | `value[9:0]`, `neg` | Ya implementado: `display_subsystem.sv` |
| 8 | `top` ↔ mundo | `clk`, `resetn`, `row[3:0]`, `col[3:0]`, `seg[6:0]`, `sel[3:0]` | Ver `src/constr/proyecto2.cst` |

**Polaridades:** `resetn` activo en bajo (botón). `reset` interno activo en alto (`reset = ~resetn`); el `DeBounce` usa `n_reset` activo en bajo y síncrono, así que va directo a `resetn`. `row` activo en bajo (tecla presionada = 0). `seg` y `sel` activos en alto (cátodo común, transistor NPN).

**Teclas (a confirmar al medir el teclado):** `0–9` dígitos, `A` operación, `B` igual, `C` borrar todo.

## Cambios al contrato

| Fecha | Qué cambió | Motivo |
|---|---|---|
| | | |
