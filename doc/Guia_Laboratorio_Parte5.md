# Guía de laboratorio — Parte 5 (analizador lógico)

Proyecto corto 2, EL-3307 Diseño Lógico. Ejercicios 5.1, 5.2 y 5.3.
Siga los pasos en orden. Después de cada medición, **anote en la bitácora** lo que se indica en el recuadro "Bitácora".

> Los números de pin de los chips (74LS163, 74HC74, 74HC283, 74HC00) los verifiqué contra las hojas de datos o las figuras del enunciado, pero **compárelos con la hoja de datos que tengan a mano antes de energizar**. Un pin mal puesto es la falla más común y la más difícil de ver.

---

## 0. Preparación (una sola vez)

### 0.1 Reglas de voltaje (lea esto antes de alambrar)

| Chip | Alimentación | Por qué |
|---|---|---|
| 74LS163 | **5 V** (pin 5V de la placa) | Así lo muestra la Fig. 2 del enunciado. La FPGA le da 3.3 V al reloj y el LS lo acepta como "1" (necesita ≥ 2 V). |
| 74HC74, 74HC283, 74HC00 | **3.3 V** (pin 3V3 de la placa) | Son seguros con 3.3 V y se llevan bien con la FPGA. |

- **Ninguna salida de un chip alimentado a 5 V se conecta a un pin de la FPGA.** Las salidas de los 74LS163 van **solo** al osciloscopio.
- Todas las tierras deben ir unidas: GND de la placa, GND de la protoboard, GND de las puntas del osciloscopio.
- Ponga un capacitor de 100 nF entre VCC y GND, **cerca de cada chip**.
- Los pines de entrada que no se usen **no se dejan flotando**: se conectan a VCC o a GND como indica cada ejercicio.
- Alambre siempre **con la placa desconectada del USB**. Energice solo cuando termine y revise.

### 0.2 Generar el reloj de 1.8432 MHz con la FPGA

Los tres ejercicios usan el mismo reloj. Está en `src/design/top_lab.sv`.

1. Copie `top_lab.sv` a `src/design/`, `lab.cst` a `src/constr/` y `top_lab_tb.sv` a `src/sim/` del repo.
2. (Opcional) Compruebe en simulación, en `src/build`: `make test TB=top_lab_tb`. Debe decir `18432` flancos en 10 ms y `TODO OK`.
3. Compile y cargue, desde una terminal que tenga OSS CAD Suite en el PATH:
   ```
   make all TOP_DESIGN=top_lab CONSTRAINTS=../constr/lab.cst
   ```
4. La señal sale por el **pin 25** de la placa (header izquierdo, 3.3 V). Ese pin es `CLK` en todos los circuitos.
5. Mídala con el osciloscopio (canal analógico 1, punta en 10x y la tierra de la punta en GND).

**Qué debe ver:** una onda cuadrada de **1.8432 MHz promedio**. Como 27 MHz / 1.8432 MHz = 14.65 (no es entero), cada periodo mide 518.5 ns o 555.6 ns y el semiperiodo alterna entre 7 y 8 ciclos de 27 MHz. El osciloscopio mostrará un poco de *jitter* en el flanco, y una lectura instantánea de frecuencia entre 1.80 y 1.93 MHz. Para leer la frecuencia promedio use `Measure → Frequency` con estadísticas (promedio) o el contador de frecuencia del osciloscopio. Si el promedio da 1.8432 MHz ± 0.1 %, está bien.

**Bitácora:** frecuencia promedio medida, foto/captura de la señal, y una frase explicando por qué hay jitter.

### 0.3 Configuración del osciloscopio como analizador lógico

El enunciado indica el manual (p. 89 para el analizador lógico, p. 162 para captura de fallas). Los nombres de las teclas pueden variar un poco según el firmware; busque el equivalente.

1. Conecte el cable del juego de puntas digitales al conector **Digital Channels** del osciloscopio (apagado). Encienda.
2. Cada punta digital (D0 a D7) tiene su pinza; use la **tierra** del cable digital conectada a GND del circuito.
3. Tecla `Digital`: encienda D0 a D7 (o los que use) y póngales nombre con `Labels` si el menú lo permite.
4. **Umbral (`Thresholds`):**
   - circuitos a 3.3 V (74HC): `User` = **1.65 V**.
   - circuitos a 5 V (74LS163): `TTL` (1.4 V).
   - Si mezcla ambos en una misma captura, use 1.4 V (sirve para los dos).
5. **Disparo (`Trigger`)**: tipo `Edge`, fuente = el canal digital indicado en cada ejercicio, flanco de subida.
6. Base de tiempo: 1 µs/div para ver un ciclo completo de cuenta de 16 estados; 20 a 50 ns/div para ver retardos.
7. Para guardar imágenes: `Save/Recall → Save → Format: PNG` y guárdelas en una memoria USB. Nómbrelas `5_1_cuenta.png`, etc., y cópielas después a `doc/mediciones/` del repo.

---

## 1. Ejercicio 5.1 — Contadores sincrónicos 74LS163 en cascada

**Objetivo:** armar un contador de 8 bits con dos 74LS163 (Fig. 2) y verificar su operación.

### 1.1 Materiales
2 × 74LS163, 2 × capacitor 100 nF, jumpers, FPGA con `top_lab`, osciloscopio con puntas digitales.

### 1.2 Pines del 74LS163 (DIP-16)

| Pin | Señal | Pin | Señal |
|---|---|---|---|
| 1 | CLR (activo en bajo, sincrónico) | 9 | LD (activo en bajo) |
| 2 | CLK | 10 | T (ENT) |
| 3 | A | 11 | Qd (MSB) |
| 4 | B | 12 | Qc |
| 5 | C | 13 | Qb |
| 6 | D | 14 | Qa (LSB) |
| 7 | P (ENP) | 15 | RCO |
| 8 | GND | 16 | VCC |

### 1.3 Alambrado (placa desconectada)

| Conexión | Contador 1 (LSB) | Contador 2 (MSB) |
|---|---|---|
| VCC (pin 16) | +5 V | +5 V |
| GND (pin 8) | GND | GND |
| CLR (pin 1) | +5 V | +5 V |
| LD (pin 9) | +5 V | +5 V |
| P (pin 7) | +5 V | +5 V |
| T (pin 10) | +5 V | **RCO del contador 1 (pin 15 del 1)** |
| CLK (pin 2) | FPGA pin 25 (`clk_out`) | FPGA pin 25 (`clk_out`) |
| A, B, C, D (pines 3 a 6) | GND (no se usan) | GND (no se usan) |

100 nF entre los pines 16 y 8 de cada chip. El RCO del contador 2 (pin 15) queda sin conectar a nada (puede medirse).

**Revise tres cosas antes de energizar:** (1) que el único cable entre la FPGA y los chips sea el reloj, que va **de** la FPGA **hacia** los chips (ninguna salida de los 74LS163 llega a la FPGA); (2) que CLR y LD estén en +5 V (en bajo borran o cargan el contador); (3) que el pin 10 del contador 2 vaya al pin 15 del contador 1.

### 1.4 Conexión al osciloscopio

| Canal | Señal |
|---|---|
| D0, D1, D2, D3 | Qa, Qb, Qc, Qd del contador 1 (pines 14, 13, 12, 11) |
| D4, D5, D6, D7 | Qa, Qb, Qc, Qd del contador 2 |
| Analógico 1 | RCO del contador 1 (pin 15 del contador 1) |
| Analógico 2 | CLK |

Disparo: `Edge`, fuente **D7** (el MSB), flanco de subida.

### 1.5 Pasos

1. Cargue `top_lab` en la FPGA. Energice el circuito (5 V y GND de la placa; el reloj ya sale por el pin 25).
2. Configure el osciloscopio como en 0.3 y dispare con D7.
3. Con 1 µs/div debe ver una cuenta binaria que sube en D0 a D3 (el contador 1). Con 50 µs/div debe ver el contador 2 (D4 a D7) subiendo, y D7 (el MSB) como una onda de unos 7.2 kHz (periodo ≈ 139 µs).
4. **Verifique las frecuencias** (con la frecuencia del reloj de 1.8432 MHz):

| Bit | Frecuencia esperada |
|---|---|
| Qa del contador 1 | 921.6 kHz (CLK / 2) |
| Qd del contador 1 | 115.2 kHz (CLK / 16) |
| Qa del contador 2 | 57.6 kHz (CLK / 32) |
| Qd del contador 2 (MSB) | **7.2 kHz** (CLK / 256) |

5. **RCO del contador 1:** debe ser un pulso en alto que dura un periodo de reloj, una vez cada 16 ciclos (cada ≈ 8.7 µs).
6. Cambie el modo del osciloscopio de 8 bits (digital) a un solo canal analógico en Qd del contador 2 para comparar la forma de onda.

**Bitácora:** tabla de frecuencias esperadas contra medidas, captura de la cuenta (D0 a D7 con disparo en D7), captura de RCO.

### 1.6 Preguntas del enunciado, con pistas para responderlas

Responda con sus palabras y compruebe con la hoja de datos y con su medición. En el oral se las preguntan.

**a) ¿Qué hace la salida RCO?**
Es el "acarreo" (*ripple carry out*): sube a 1 cuando el contador llega a 1111 (y T está en 1). Avisa que el próximo flanco de reloj hará que el contador vuelva a 0000. Sirve para encadenar contadores.

**b) ¿Por qué RCO y T están conectadas entre los dos contadores?**
El contador 2 solo debe contar cuando el 1 desborda. T es la habilitación de cuenta: con T = 0 el contador 2 se queda quieto, con T = 1 cuenta en el siguiente flanco de reloj. Al conectar RCO del 1 a T del 2, el contador 2 sube 1 una vez cada 16 relojes. Resultado: un contador de 8 bits, con **un solo reloj** para ambos (por eso es sincrónico).

**c) ¿Diferencia entre T y P (ENT y ENP)?**
Los dos habilitan la cuenta (ambos deben estar en 1 para contar). La diferencia es que **T también habilita la salida RCO** (RCO = T · Qa · Qb · Qc · Qd), mientras que P no afecta a RCO. Por eso en cascada el acarreo se pasa por T.

**d) ¿Cuánto tarda un flip-flop en cambiar tras el flanco positivo de reloj? ¿Importa qué bit?**
Mida con los canales analógicos: canal 1 = CLK, canal 2 = Qa del contador 1, 10 a 20 ns/div, de 50 % a 50 % del flanco. Debe dar unas decenas de ns. Repita con Qb, Qc y Qd (disparando donde sí cambian en ese ciclo). Compare con el valor típico de la hoja de datos. Hay pequeñas diferencias entre bits (distinta carga y distinta lógica interna de cada bit), pero el orden de magnitud es el mismo; escoja el bit que cambia en cada flanco (Qa) para tener referencia.

**e) Fallas (glitches) en RCO.**
RCO es una compuerta AND combinacional de T y las cuatro salidas. En un instante de transición, las salidas no cambian exactamente a la vez; si un bit sube antes de que otros bajen, el AND puede ver momentáneamente 1111 y generar un pulso muy corto.
- **Cuándo es esperable:** en transiciones donde cambian varios bits y el estado intermedio puede ser 1111, por ejemplo 0111 → 1000 (el caso más probable), 1011 → 1100 y 1101 → 1110.
- **Cómo buscarla:** `Trigger → Type: Glitch` (hoja p. 162 del manual), fuente = canal analógico 1 (RCO), `Less than` ≈ 10 ns, polaridad positiva. Active `Display → Persistence: Infinite` (o `Acquire → Peak detect`) y deje correr varios segundos. Primero en el analizador lógico, luego en analógico.
- Puede ser que no vea ninguna (son muy cortas y no siempre ocurren). **Si no la ve, anótelo así** y explique en qué casos se espera.
- **¿Es peligrosa?** Ocurre poco después del flanco de reloj, mucho antes del siguiente (a 1.8432 MHz hay 542 ns). La señal se estabiliza antes de que el contador 2 la muestree, así que en un diseño sincrónico no causa errores.

---

## 2. Ejercicio 5.2 — Contadores de 4 bits: asincrónico y sincrónico

**Objetivo:** construir con 74HC74 y 74HC283 un contador asincrónico y uno sincrónico, con una señal que indique que se pasó por el máximo (1111), y comparar.

### 2.1 Materiales
2 × 74HC74 (4 flip-flops D), 1 × 74HC283, 3 × 100 nF, jumpers. **Alimente todo a 3.3 V.**

### 2.2 Pines

**74HC74 (DIP-14), dos flip-flops D con preset y clear activos en bajo:**

| Pin | Señal | Pin | Señal |
|---|---|---|---|
| 1 | 1CLR | 8 | 2Q̄ |
| 2 | 1D | 9 | 2Q |
| 3 | 1CLK | 10 | 2PRE |
| 4 | 1PRE | 11 | 2CLK |
| 5 | 1Q | 12 | 2D |
| 6 | 1Q̄ | 13 | 2CLR |
| 7 | GND | 14 | VCC |

**74HC283 (DIP-16), sumador de 4 bits:**

| Pin | Señal | Pin | Señal |
|---|---|---|---|
| 1 | S2 | 9 | **C4** (acarreo de salida) |
| 2 | B2 | 10 | S4 |
| 3 | A2 | 11 | B4 |
| 4 | S1 | 12 | A4 |
| 5 | A1 | 13 | S3 |
| 6 | B1 | 14 | A3 |
| 7 | **C0** (acarreo de entrada) | 15 | B3 |
| 8 | GND | 16 | VCC |

Nombres de los cuatro flip-flops: **FF0** = 1er flip-flop del chip A (LSB), **FF1** = 2.º del chip A, **FF2** = 1.º del chip B, **FF3** = 2.º del chip B (MSB). Q0 a Q3 son sus salidas Q.

| FF | Pines (CLK, D, Q, Q̄) |
|---|---|
| FF0 (chip A, 1.º) | CLK 3, D 2, Q 5, Q̄ 6 |
| FF1 (chip A, 2.º) | CLK 11, D 12, Q 9, Q̄ 8 |
| FF2 (chip B, 1.º) | CLK 3, D 2, Q 5, Q̄ 6 |
| FF3 (chip B, 2.º) | CLK 11, D 12, Q 9, Q̄ 8 |

En **todos** los flip-flops: PRE (pines 4 y 10) y CLR (pines 1 y 13) a **3.3 V** (inactivos). Para reiniciar a 0000 al inicio, toque un instante con un jumper los CLR de los cuatro a GND y suéltelos (opcional: el contador cuenta bien aunque arranque en cualquier valor).

### 2.3 Parte A: contador asincrónico (rizado)

Idea: cada flip-flop **conmuta** (D = Q̄) y el reloj del siguiente es la salida **Q̄** del anterior.

| Conexión | A |
|---|---|
| FF0 CLK (pin 3, chip A) | FPGA pin 25 (`clk_out`) |
| FF0 D (pin 2) | FF0 Q̄ (pin 6) |
| FF1 CLK (pin 11) | FF0 Q̄ (pin 6) |
| FF1 D (pin 12) | FF1 Q̄ (pin 8) |
| FF2 CLK (pin 3, chip B) | FF1 Q̄ (pin 8, chip A) |
| FF2 D (pin 2, chip B) | FF2 Q̄ (pin 6, chip B) |
| FF3 CLK (pin 11, chip B) | FF2 Q̄ (pin 6, chip B) |
| FF3 D (pin 12, chip B) | FF3 Q̄ (pin 8, chip B) |

(Si en vez de Q̄ usara Q para el reloj del siguiente, el contador contaría hacia atrás. Con Q̄ cuenta hacia arriba.)

**Señal de máximo (MAX) con el 74HC283:** el sumador calcula Q + 1. Su acarreo de salida C4 vale 1 solo cuando Q = 1111, o sea justo cuando se pasa por el máximo.

| Conexión del 74HC283 | A |
|---|---|
| A1, A2, A3, A4 (pines 5, 3, 14, 12) | Q0, Q1, Q2, Q3 |
| B1 (pin 6) | **3.3 V** |
| B2, B3, B4 (pines 2, 15, 11) | GND |
| C0 (pin 7) | GND |
| VCC (16) / GND (8) | 3.3 V / GND, con 100 nF |
| C4 (pin 9) | **MAX** (a medir) |
| S1 a S4 | sin conectar en esta parte |

**Osciloscopio:** D0 a D3 = Q0 a Q3, D4 = MAX (C4), D5 = CLK. Analógico 1 = CLK, analógico 2 = Q3 (para ver los retardos). Disparo: `Edge`, **D3 subida**. Umbral 1.65 V.

**Qué debe ver:**
1. 1 µs/div: la cuenta 0 a 15, repetida cada ≈ 8.7 µs.
2. MAX en alto durante el estado 1111.
3. Acérquese a la transición 0111 → 1000 (50 ns/div, o el zoom del osciloscopio): los bits **no cambian a la vez**. Q0 cambia primero, luego Q1, Q2 y por último Q3, cada uno con el retardo del anterior. Entre medio aparecen estados intermedios incorrectos (por ejemplo 0111 → 0110 → 0100 → 0000 → 1000).
4. Esos estados intermedios pueden producir pulsos cortos en MAX (C4).

**Bitácora:** captura de la cuenta completa, captura con zoom de la transición 0111 → 1000 (con los estados intermedios), retardo total medido entre CLK y Q3.

### 2.4 Parte B: contador sincrónico

Idea: **todos** los flip-flops comparten el reloj; el sumador calcula el siguiente valor (Q + 1) y lo entrega a las entradas D. **Modifique el circuito de la parte A** (puede dejarlo armado y cambiar solo estos cables):

| Cambio | B |
|---|---|
| CLK de FF0, FF1, FF2 y FF3 | todos a FPGA pin 25 (`clk_out`) |
| D de FF0 (pin 2, chip A) | S1 (pin 4 del 74HC283) |
| D de FF1 (pin 12, chip A) | S2 (pin 1) |
| D de FF2 (pin 2, chip B) | S3 (pin 13) |
| D de FF3 (pin 12, chip B) | S4 (pin 10) |
| Sumador | igual que en A (A = Q, B = 0001, C0 = GND); C4 = MAX |

Quite las conexiones D = Q̄ y las de reloj por Q̄ de la parte A.

**Osciloscopio:** igual que en A (D0 a D3 = Q0 a Q3, D4 = MAX, D5 = CLK, disparo D3 subida).

**Qué debe ver:**
1. La misma cuenta 0 a 15.
2. En la transición 0111 → 1000 los cuatro bits cambian **casi simultáneamente** (todos medidos desde el mismo flanco de reloj, diferencia de pocos ns), sin estados intermedios largos.
3. MAX = 1 cuando el valor es 1111.

**Bitácora:** captura de la cuenta, captura con zoom de la transición 0111 → 1000 para comparar con la parte A, retardos medidos.

### 2.5 Preguntas del enunciado

**a) ¿Diferencias en las salidas de ambas estructuras?**
Compare con sus capturas:
- *Asincrónico:* cada bit cambia con un retardo acumulado; hay estados intermedios erróneos; el tiempo total para estabilizarse crece con el número de bits; los bits no están alineados con el reloj.
- *Sincrónico:* todos los bits cambian justo después del mismo flanco; salidas alineadas con pocos ns de diferencia; estados limpios.

**b) ¿Problemas de la opción asincrónica?**
Retardo acumulado (limita la frecuencia máxima de reloj); estados transitorios erróneos que producen *glitches* al decodificar las salidas (por ejemplo en MAX); y es difícil de analizar en tiempo porque los flip-flops no comparten reloj. Para usar sus salidas dentro de un sistema sincrónico habría que esperar a que se estabilicen.

---

## 3. Ejercicio 5.3 — Cerrojo SR con NAND y cerrojo D

**Objetivo:** construir un cerrojo SR con reloj usando NAND 74HC00 (Fig. 3), demostrar su tabla de verdad y transformarlo en un cerrojo D.

### 3.1 Materiales
1 o 2 × 74HC00 (el cerrojo D necesita una compuerta más: use un segundo chip), 1 DIP switch, 2 × 4.7 kΩ, 2 × 100 nF. **Alimente a 3.3 V.**

### 3.2 Pines del 74HC00 (DIP-14, cuatro NAND)

| Compuerta | Entradas | Salida |
|---|---|---|
| N1 | 1 y 2 | 3 |
| N2 | 4 y 5 | 6 |
| N3 | 9 y 10 | 8 |
| N4 | 12 y 13 | 11 |
| VCC = 14, GND = 7 | | |

### 3.3 Circuito

```
 S ───┐
      N1 (NAND) ── X ──┐
 CLK ─┤                 N3 (NAND) ── Q
      │             ┌───┘      ▲
 CLK ─┤             │          │ (Q̄ y Q se cruzan)
      N2 (NAND) ── Y ──┐       │
 R ───┘              N4 (NAND) ── Q̄
```

Conexiones a hacer:
- **N1:** entradas S y CLK; salida X.
- **N2:** entradas R y CLK; salida Y.
- **N3:** entradas X y Q̄; salida **Q**.
- **N4:** entradas Y y Q; salida **Q̄**.

Es decir: Q = NAND(X, Q̄) y Q̄ = NAND(Y, Q): las dos NAND de salida están realimentadas entre sí.

**Entradas S y R (Fig. 3):** cada una lleva una resistencia de 4.7 kΩ a 3.3 V y un interruptor del DIP a GND.
- **Interruptor abierto (OFF)** → la línea vale **1**.
- **Interruptor cerrado (ON)** → la línea vale **0**.
- Así, **con ambos interruptores en ON, S = R = 0: el cerrojo mantiene su valor.**

**CLK:** FPGA pin 25.

**Osciloscopio:** D0 = CLK, D1 = S, D2 = R, D3 = Q, D4 = Q̄. Umbral 1.65 V. Disparo: `Edge`, fuente D1 o D2 (la que vaya a mover), flanco de subida, modo **Single** (disparo único) para capturar el cambio.

### 3.4 Pasos y tabla de verdad

Mueva los interruptores uno a la vez y observe Q y Q̄:

| S | R | CLK | Resultado esperado |
|---|---|---|---|
| 0 | 0 | 1 | Mantiene (memoria) |
| 1 | 0 | 1 | **Set:** Q = 1, Q̄ = 0 |
| 0 | 1 | 1 | **Reset:** Q = 0, Q̄ = 1 |
| 1 | 1 | 1 | **Inválido:** Q = Q̄ = 1 |
| x | x | 0 | Mantiene (el reloj bloquea S y R) |

Nota: el enunciado dice en el reset "Q debe estar en alto"; parece errata. En el reset, Q queda en 0 y Q̄ en 1.

**Bitácora:** el circuito final dibujado, la tabla de verdad con lo que midió, y una captura de cada caso (set, reset, mantener).

### 3.5 Transformación en cerrojo D

Agregue una compuerta como **inversor** (NAND con las dos entradas juntas):
- **S = D**
- **R = NOT D** = salida de una NAND cuyas dos entradas son D (use una compuerta libre del segundo 74HC00).
- Quite el interruptor y la resistencia de R; use solo el interruptor de S como entrada D.

Así S y R nunca valen 1 a la vez. Con CLK = 1, Q = D (el cerrojo es "transparente"); con CLK = 0 mantiene.

**Cómo demostrarlo:** captura única (*Single*) disparando en el flanco de D (canal D1). Verá que Q cambia **solo mientras CLK está en alto**: si D cambia con CLK en 0, Q espera hasta el siguiente semiciclo alto (máximo 542 ns). El interruptor DIP rebota unos milisegundos, así que verá varios cambios rápidos de D y Q los sigue: es otra muestra de la transparencia.

**Bitácora:** el circuito de cerrojo D, tabla de verdad (D, CLK → Q) y captura de Q siguiendo a D solo con CLK en alto.

### 3.6 Preguntas del enunciado

**a) ¿Cómo funciona el cerrojo SR, para qué sirve y se necesita CLK?**
Las dos NAND de salida, realimentadas, guardan un bit: una vez puesto Q en 1 o 0, se mantiene mientras S y R no pidan lo contrario. Las dos NAND de entrada dejan pasar S y R solo cuando CLK = 1, por eso el cambio ocurre solo con el reloj en alto. Sirve como celda de memoria de 1 bit, y es el bloque con el que se construyen los flip-flops. Sobre el reloj: el núcleo (las dos NAND cruzadas) funciona sin reloj, pero **este cerrojo con reloj sí lo necesita** para que S y R tengan efecto.

**b) ¿Qué pasa si S y R están en alto?**
Con CLK = 1, las dos NAND de entrada dan 0, y las dos de salida dan Q = 1 y Q̄ = 1 a la vez: estado inválido (no son complementarias). Cuando CLK baja, ambas salidas de entrada vuelven a 1 y el cerrojo cae en un estado impredecible (depende de cuál compuerta sea más rápida). Por eso S = R = 1 está prohibido.

**c) ¿Cómo se transforma en cerrojo D?**
Con un inversor entre S y R (S = D, R = D̄): ya no existe la combinación prohibida y Q sigue a D cuando CLK = 1.

---

## 4. Cierre: lista de entregables de la Parte 5

- [ ] Bitácora con fecha, mediciones y capturas de cada ejercicio (cada uno en su cuaderno).
- [ ] Capturas guardadas en `doc/mediciones/` del repo (`5_0_reloj.png`, `5_1_cuenta.png`, `5_1_rco.png`, `5_2_asincrono.png`, `5_2_sincrono.png`, `5_3_sr.png`, `5_3_d.png`).
- [ ] Respuestas a las preguntas de los tres ejercicios, **con sus palabras** (para el oral).
- [ ] Circuitos funcionando para mostrarlos al profesor.

## 5. Si algo no funciona

| Síntoma | Qué revisar |
|---|---|
| No aparece el reloj | `top_lab` cargado; pin 25; punta en 10x; tierra de la punta conectada |
| El contador no cuenta | VCC y GND de cada chip; en el 74LS163: CLR, LD, P y T en +5 V; reloj llegando al pin 2 |
| El contador cuenta con saltos raros | Falta un 100 nF cerca del chip; pines de entrada flotando; mala tierra del osciloscopio |
| El contador 2 no cambia | Pin 10 del contador 2 conectado al pin 15 del contador 1 |
| El osciloscopio no dispara estable | Umbral digital mal puesto (3.3 V: 1.65 V; 5 V: 1.4 V); disparo en D7 (MSB) |
| Circuito 74HC "raro" | Recuerde alimentarlo a 3.3 V, no a 5 V, y pines de PRE y CLR en 3.3 V |
| Chip se calienta | Apague. VCC y GND invertidos o cortocircuito |
