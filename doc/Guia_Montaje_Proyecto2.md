# Guía de montaje del Proyecto 2 (calculadora de resta)

Ariel Elizondo · Josué Sanabria — EL-3307 Diseño Lógico, II Sem 2026
Coincide con `src/constr/proyecto2.cst` del repo. Si cambian un pin, cambien el `.cst` **y** esta guía.

---

## 0. Idea general (leer primero)

```
                 ┌────────────── Tang Nano 9K ───────────────┐
 TECLADO         │                                           │        DISPLAYS (cátodo común)
 col0..col3 ◄─[330Ω]─ salidas  25,30,27,28                   │
 row0..row3 ───────►  entradas 29,37,33,34 (pull-up interno)  │
                 │                                           │
                 │  segmentos a..g: 35,40,41,42,51,53,54 ─[220Ω]─► a..g (los 4 dígitos en paralelo)
                 │  selectores:     55,56,57,36 ─[470Ω]─► base de 4 NPN
                 │                                           │        colector → cátodo del dígito
                 │  botón reset: pin 4 (ya está en la placa) │        emisor   → GND
                 └───────────────────────────────────────────┘
```

Todo funciona a **3.3 V**. No se usa ninguna fuente externa: la alimentación sale del USB de la placa.
**Nada de 5 V hacia pines de la FPGA.**

Orden de trabajo recomendado (cada etapa se prueba antes de pasar a la siguiente):

1. Medir el teclado con el multímetro (sin conectar nada).
2. Montar y probar **solo los displays**.
3. Montar el teclado.
4. Cargar el diseño completo y probar.

---

## 1. Materiales para el proyecto

| Cantidad | Elemento | Para qué |
|---|---|---|
| 1 | Tang Nano 9K + cable USB-C | |
| 1 | Protoboard (idealmente grande, o dos) | |
| 1 | Teclado matricial 4x4 (Grayhill 96BB2-006-F) | entrada |
| 4 | Displays de 7 segmentos **cátodo común** (o 1 módulo de 4 dígitos) | salida |
| 4 | Transistores NPN 2N3904 / BC547 / 2N2222A | activar cada dígito |
| 7 | Resistencias 220 Ω | una por segmento |
| 4 | Resistencias 470 Ω | base de cada NPN |
| 4 | Resistencias 330 Ω | en serie con las columnas del teclado |
| varios | Cables dupont/jumper macho-macho (unos 30) y cable sólido para puentes | |
| 1 | Multímetro | medir teclado y verificar |

Resistencias ±10 % no importan. Si no tienen 220 Ω, cualquier valor entre 180 y 330 Ω sirve (más alto = menos brillo).

---

## 2. Pines de la placa (del mapa que ya tienen)

Header **izquierdo**, de arriba hacia abajo, es este orden físico (¡ojo que el 40 va antes que el 35!):

`38, 37, 36, 39, 25, 26, 27, 28, 29, 30, 33, 34, 40, 35, 41, 42, 51, 53, 54, 55, 56, 57, 68, 69`

Header **derecho** relevante: `5V`, **`GND`** (un solo pin, abajo) y `3V3` (el último).

Asignación del proyecto:

| Señal | Pin | Va conectado a |
|---|---|---|
| col[0] | 25 | 330 Ω → columna 0 del teclado |
| col[1] | 30 | 330 Ω → columna 1 |
| col[2] | 27 | 330 Ω → columna 2 |
| col[3] | 28 | 330 Ω → columna 3 |
| row[0] | 29 | fila 0 (directo) |
| row[1] | 37 | fila 1 (directo) |
| row[2] | 33 | fila 2 (directo) |
| row[3] | 34 | fila 3 (directo) |
| seg[6] (a) | 35 | 220 Ω → segmento a |
| seg[5] (b) | 40 | 220 Ω → b |
| seg[4] (c) | 41 | 220 Ω → c |
| seg[3] (d) | 42 | 220 Ω → d |
| seg[2] (e) | 51 | 220 Ω → e |
| seg[1] (f) | 53 | 220 Ω → f |
| seg[0] (g) | 54 | 220 Ω → g |
| sel[0] unidades | 55 | 470 Ω → base NPN 0 |
| sel[1] decenas | 56 | 470 Ω → base NPN 1 |
| sel[2] centenas | 57 | 470 Ω → base NPN 2 |
| sel[3] signo | 36 | 470 Ω → base NPN 3 |
| clk | 52 | interno (no se cablea) |
| resetn | 4 | botón de la placa (no se cablea) |

Notas importantes:
- Los pines 33–35, 40–42, 51–57 también llegan al conector del LCD y el 36/37 al lector de tarjeta SD. **No pongan nada en esos conectores** y no hay problema.
- **El pin 37 (row[1]) no está verificado.** Si al probar el teclado la fila 1 (4, 5, 6, B) no responde, cámbienlo por otro pin libre del header (por ejemplo 26, que quedó libre al mover col[1] al 30) y actualicen el `.cst`.
- Solo hay **un pin GND** en los headers. Llévenlo a un riel de la protoboard con un cable y de ahí reparten tierra a todo (emisores de los 4 NPN y, si el teclado lo necesita, nada más). **Todo GND debe ser común.**

---

## 3. Paso 0 — Medir el teclado (sin conectar nada)

El teclado tiene 8 pines (4 filas + 4 columnas), pero **no sabemos cuál es cuál**. Con el multímetro en continuidad (el del pitido):

1. Numeren los pines del teclado 1 a 8 con un marcador o cinta (de izquierda a derecha, viéndolo de frente con el conector hacia abajo; apúntenlo igual en la bitácora).
2. Presionen y mantengan la tecla **1** y busquen qué dos pines pitan. Anótenlos.
3. Repitan con las teclas **2, 3, A, 4, 7, \*** (basta con estas; las demás salen por deducción, pero verifiquen alguna más).
4. Regla para clasificar:
   - Las teclas **1, 2, 3, A** comparten **un mismo pin** → ese es la **fila 0**.
   - Las teclas **1, 4, 7, \*** comparten **otro mismo pin** → ese es la **columna 0**.
   - Del mismo modo: 4,5,6,B → fila 1; 7,8,9,C → fila 2; \*,0,#,D → fila 3; 2,5,8,0 → columna 1; 3,6,9,# → columna 2; A,B,C,D → columna 3.

Llenen esta tabla (y péguenla en la bitácora):

| Función | Pin del teclado (1–8) |
|---|---|
| Fila 0 (1 2 3 A) | |
| Fila 1 (4 5 6 B) | |
| Fila 2 (7 8 9 C) | |
| Fila 3 (\* 0 # D) | |
| Columna 0 (1 4 7 \*) | |
| Columna 1 (2 5 8 0) | |
| Columna 2 (3 6 9 #) | |
| Columna 3 (A B C D) | |

Si algún pin del teclado no pita con nada, revisen el contacto de la punta. Si sale que no es una matriz estándar, avísenme con la tabla de pares medidos y se ajusta el decodificador.

> Verificación extra: el teclado no tiene resistencias ni diodos internos, así que **sin presionar** no debe haber continuidad entre ningún par de pines.

---

## 4. Paso 1 — Montar los displays

### 4.1 Cómo saber qué pin es cuál

Hay que identificar en el display (de **cátodo común**) cuál es cada segmento y el pin común. Consulten el datasheet del modelo que tengan o usen la prueba rápida:

- Con el display en la protoboard, conecten el pin 3V3 de la placa a una resistencia de 220 Ω (nunca directo al display). Prueben un pin del display como cátodo común (a GND) y toquen los demás pines con el otro extremo de la resistencia: el segmento que encienda les dice su letra. Si no enciende nada, prueben otro pin como común.
- Hagan su tabla: pin del display → segmento (a–g, dp) y pin común. Anótenla en la bitácora.

Si el display es un **módulo de 4 dígitos** (un solo componente con 12 pines), los 4 dígitos ya comparten los segmentos y tendrán 4 pines comunes (uno por dígito). Es justo lo que necesitamos: lo único que cambia es que no hay que unir segmentos a mano.

Si son **4 displays sueltos**: los pines de cada segmento (a con a, b con b…) de los 4 displays se unen entre sí con la protoboard; cada dígito conserva su cátodo común separado.

### 4.2 Conexiones

**Segmentos (una resistencia por segmento, compartida por los 4 dígitos):**

```
pin 35 ──[220Ω]──► segmento a ─┐
pin 40 ──[220Ω]──► segmento b ─┤
pin 41 ──[220Ω]──► segmento c ─┤   (cada línea va a los 4 displays en paralelo)
pin 42 ──[220Ω]──► segmento d ─┤
pin 51 ──[220Ω]──► segmento e ─┤
pin 53 ──[220Ω]──► segmento f ─┤
pin 54 ──[220Ω]──► segmento g ─┘
```

El punto decimal (dp) **no se conecta**.

**Selección de dígito (un transistor por dígito).** Para el 2N3904 visto desde el lado plano (patas hacia abajo) el orden es E-B-C, **pero verifiquen el de su transistor con el datasheet o con el multímetro en modo diodo**; el BC547 y el 2N2222 tienen distinto orden.

```
 pin 55 ──[470Ω]──► BASE   ─ NPN 0:  COLECTOR ──► cátodo común del dígito de unidades
 pin 56 ──[470Ω]──► BASE   ─ NPN 1:  COLECTOR ──► cátodo común del dígito de decenas
 pin 57 ──[470Ω]──► BASE   ─ NPN 2:  COLECTOR ──► cátodo común del dígito de centenas
 pin 36 ──[470Ω]──► BASE   ─ NPN 3:  COLECTOR ──► cátodo común del dígito del signo
 EMISOR de los 4 NPN ──► GND
```

Orden físico recomendado en la protoboard, de izquierda a derecha: **signo, centenas, decenas, unidades** (así se lee un número como `-123`). Solo importa que cada cátodo vaya a su transistor correcto.

El dígito de **signo** solo usa el segmento g (guion), así que no hace falta nada especial: el código ya lo maneja.

### 4.3 Prueba de los displays (aún sin teclado)

1. Con el cable USB desconectado, repasen cada conexión contra la tabla.
2. Conecten el USB. Carguen el diseño de prueba:
   ```
   cd src/build
   make all TOP_DESIGN=top_prueba_display CONSTRAINTS=../constr/prueba_display.cst
   ```
3. Deben ver, cambiando cada ~1.2 s: `888`, `-123`, `456`, `-999`.

| Síntoma | Causa probable |
|---|---|
| Un segmento nunca prende en **todos** los dígitos | resistencia o cable de ese segmento suelto / pin equivocado |
| Un dígito no prende nunca | su NPN mal orientado (E y C invertidos) o su cátodo mal conectado |
| Todo prende tenue / un dígito aparece en otro | emisor sin GND, o dos cátodos tocándose |
| Segmentos cruzados (el 8 se ve mal) | letras de segmento equivocadas: revisen la tabla del paso 4.1 |
| Se ve parpadeo | mala conexión: el refresco es de ~400 Hz, no debería parpadear |
| `-` aparece en un dígito equivocado | el dígito de signo es sel[3] (pin 36), el más a la izquierda |

No sigan hasta que los cuatro dígitos muestren bien `888` y los otros números.

---

## 5. Paso 2 — Montar el teclado

```
col[0] pin 25 ──[330Ω]──► pin "columna 0" del teclado
col[1] pin 30 ──[330Ω]──► pin "columna 1"
col[2] pin 27 ──[330Ω]──► pin "columna 2"
col[3] pin 28 ──[330Ω]──► pin "columna 3"
row[0] pin 29 ───────────► pin "fila 0"
row[1] pin 37 ───────────► pin "fila 1"
row[2] pin 33 ───────────► pin "fila 2"
row[3] pin 34 ───────────► pin "fila 3"
```

- **No hay resistencias pull-up externas**: las filas usan el pull-up interno de la FPGA (`PULL_MODE=UP` en el `.cst`).
- El **teclado se conecta a la protoboard** con sus 8 pines (2.54 mm) o con cables; fíjenlo bien porque los contactos flojos dan teclas fantasma.
- Los 330 Ω sirven de protección: si se presionaran dos teclas de la misma fila, dos pines no pelean directamente.
- Para el teclado no hace falta ni 3V3 ni GND.

**Cómo funciona (para la oral):** la FPGA pone una columna en 0 y las otras en 1, una a una (cada 1 ms). Las filas están en 1 por el pull-up. Si presionas una tecla, esa fila baja a 0 solo cuando su columna es la activa; así se sabe fila + columna. Cada fila pasa por un `DeBounce` (la tecla debe mantenerse unos 40 ms para contar).

---

## 6. Paso 3 — Cargar el diseño completo

1. Desconecten el USB. Revisen la lista de verificación de la sección 8.
2. Conecten el USB y ejecuten, desde `src/build`:
   ```
   make all
   ```
   (el `.cst` y el top por defecto ya son los del proyecto).
3. Si `openFPGALoader` falla con "usb bulk write failed": cambien de puerto USB y, si hace falta, **desconecten momentáneamente la protoboard de la placa** (los cables de pines) para cargar, y reconéctenla después.
4. Recuerden: la configuración va a SRAM, así que **se pierde al quitar la alimentación**. Cada vez que reconecten el USB hay que cargar otra vez (o usar el flash si el equipo prefiere).

### Pruebas funcionales

| Prueba | Acción | Resultado esperado |
|---|---|---|
| 1 | Reset (botón de la placa, pin 4) | queda en el estado inicial (`0000`) |
| 2 | Teclear `1` `2` `3` | se van viendo los dígitos |
| 3 | `A` | pasa al segundo número |
| 4 | `4` `5` `6` | se ve el segundo número |
| 5 | `D` | muestra el resultado: `-333` |
| 6 | `B` | borra todo y reinicia |
| 7 | `999` `A` `0` `D` | `999` |
| 8 | `0` `A` `999` `D` | `-999` |
| 9 | Un 4.º dígito | se ignora |

Si una **fila completa** no responde, revisen ese cable y su pin (sospechoso: el 37). Si una **columna completa** no responde, revisen su 330 Ω.

---

## 7. Solución de problemas

| Problema | Qué revisar |
|---|---|
| No pasa nada al cargar | ¿LED de la placa encendido? ¿Terminó el `make all` sin error? |
| Se pierde el diseño | normal al quitar USB (SRAM) |
| Teclas equivocadas (da 2 cuando pulsas 4) | filas/columnas invertidas: revisen la tabla del paso 0 |
| Una tecla "se repite" | rebote o cable flojo; mantengan el cable firme |
| Teclas fantasma | pines de teclado flojos en la protoboard |
| Display muy tenue | resistencias de 220 Ω muy altas o sin cátodo a GND |
| La placa se calienta | corto: desconecten y revisen que 3V3 y GND no se toquen |
| Hace falta cambiar un pin | edite el `.cst`, `make all`, y actualicen esta tabla |

---

## 8. Lista de verificación antes de energizar

- [ ] Tabla de pines del teclado medida y anotada en la bitácora
- [ ] Tabla de segmentos del display anotada en la bitácora
- [ ] GND de la placa unido al riel de la protoboard y a los emisores de los 4 NPN
- [ ] Ningún cable de 5 V conectado a pines de la FPGA
- [ ] 4 resistencias de 330 Ω en las columnas (y **ninguna** en las filas)
- [ ] 7 resistencias de 220 Ω en los segmentos
- [ ] 4 resistencias de 470 Ω en las bases
- [ ] Orientación E-B-C de los 4 transistores verificada
- [ ] Nada conectado en los conectores LCD/SD de la placa
- [ ] Pines coinciden con `proyecto2.cst`

## 9. Qué anotar en la bitácora

Fecha, esquema de conexiones (dibujado a mano), las dos tablas medidas (teclado y display), el resultado de cada prueba de las secciones 4.3 y 6, y los problemas encontrados con su solución.
