# Guía de laboratorio — Parte 5 (analizador lógico)

Proyecto corto 2, EL-3307 Diseño Lógico. Ejercicios 5.1, 5.2 y 5.3.
Siga los pasos en orden. Después de cada medición, **anote en la bitácora** lo que se indica en el recuadro "Bitácora".

> Los números de pin de los chips (74LS163, 74LS74, 74LS83, 74HC00) los verifiqué contra las hojas de datos o las figuras del enunciado, pero **compárelos con la hoja de datos que tengan a mano antes de energizar**. Un pin mal puesto es la falla más común y la más difícil de ver.

---

## 0. Preparación (una sola vez)

### 0.1 Reglas de voltaje (lea esto antes de alambrar)

| Chip | Alimentación | Por qué |
|---|---|---|
| 74LS163 | **5 V** (pin 5V de la placa) | Así lo muestra la Fig. 2 del enunciado. La FPGA le da 3.3 V al reloj y el LS lo acepta como "1" (necesita ≥ 2 V). |
| 74LS74 y 74LS83 (ejercicio 5.2) | **5 V** (el mismo riel de los 74LS163) | Lógica TTL, como el 5.1. El reloj de 3.3 V de la FPGA lo aceptan. |
| 74HC00 (ejercicio 5.3) | **3.3 V** (pin 3V3 de la placa) | Es seguro con 3.3 V y se lleva bien con la FPGA. |

- **Ninguna salida de un chip alimentado a 5 V se conecta a un pin de la FPGA.** Las salidas de los 74LS163 van **solo** al osciloscopio.
- Todas las tierras deben ir unidas: GND de la placa, GND de la protoboard, GND de las puntas del osciloscopio.
- Ponga un capacitor de 100 nF entre VCC y GND de **cada chip**, con las patas lo más cortas posible (ver la explicación en 0.4). Montarlo "cruzando por encima del chip", con una pata en la fila del pin VCC y la otra en la del pin GND, está bien.
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

**Qué debe ver:** una onda cuadrada de **1.8432 MHz promedio**. Como 27 MHz / 1.8432 MHz = 14.65 (no es entero), cada periodo mide 518.5 ns o 555.6 ns y el semiperiodo alterna entre 7 y 8 ciclos de 27 MHz. El osciloscopio mostrará un poco de *jitter* en el flanco, y una lectura instantánea de `[Meas] → Frequency` que salta entre 1.80 y 1.93 MHz. Para comprobar el promedio hay dos formas: (1) anotar varias lecturas y promediarlas, o (2) con los cursores medir el tiempo de muchos periodos (por ejemplo 20 periodos ≈ 10.85 µs) y dividir. Además, en el ejercicio 5.1 el MSB del contador de 8 bits promedia 256 periodos del reloj, y su frecuencia debe salir en 7.2 kHz con muy poco error: esa es la comprobación más limpia.

**Bitácora:** frecuencia promedio medida, foto/captura de la señal, y una frase explicando por qué hay jitter.

### 0.3 Configuración del osciloscopio como analizador lógico

Referencias: manual Keysight 2000 X (el que está en el proyecto), capítulo 6 "Digital Channels" (p. 89), capítulo 10 "Triggers" (p. 125), capítulo 12 "Acquisition Control" (p. 155, glitches en p. 162) y capítulo 18 "Save/Recall" (p. 229).

1. **Conectar las puntas digitales** (con el osciloscopio apagado o encendido, da igual): el cable de las puntas digitales se enchufa al conector **DIGITAL D7–D0** del panel frontal (solo entra de una manera). Conecte el **cable de tierra de cada grupo de canales** (cada "pod") con una pinza a GND del circuito. Sin esa tierra las mediciones digitales no son confiables.
2. **Encender los canales digitales:** tecla `[Digital]`. Con `[AutoScale]` el osciloscopio enciende solo los canales que tienen señal. Con las perillas multiplexadas junto a `[Digital]` puede seleccionar y mover cada canal.
3. **Umbral lógico:** `[Digital] → Thresholds → D7-D0`. Los presets son TTL = 1.4 V y CMOS = 2.5 V (este último **no sirve** para 3.3 V). Para los circuitos a 3.3 V use `User` y póngale **1.65 V** con la perilla de entrada. Para circuitos a 5 V (74LS163) sirve TTL (1.4 V). Si mezcla ambos en una captura, 1.4 V sirve para los dos.
4. **Mostrar la cuenta como número (bus):** `[Digital] → Bus` → active Bus1, elija los canales (por ejemplo D0 a D3) y `Base: Hex`. Así ve la cuenta 0 a F como número, y con los cursores en modo Hex lee el valor en cualquier punto (p. 98–99).
5. **Disparo:** tecla `[Trigger]` → `Trigger: Edge` → `Source`: el canal digital que indique cada ejercicio (D0 a D7) → `Slope`: subida. Para disparar con un patrón (por ejemplo, justo cuando la cuenta vale 0111) use `Trigger: Pattern` (p. 130).
6. **Una sola captura:** tecla `[Single]` (el disparo queda armado y se detiene al capturar). `[Run/Stop]` para correr o parar. Parado, las perillas de escala y posición horizontales sirven para hacer zoom sobre lo capturado (p. 52). También está la tecla de zoom para ver una parte de la captura con más detalle.
7. **Puntas analógicas:** el osciloscopio **no detecta** el factor de la punta; entre al menú del canal (`[1]` o `[2]`) → `Probe` y ponga **10:1** si la punta está en 10x. La pinza de tierra de la punta va a GND del circuito.
8. **Guardar capturas:** conecte una memoria USB al puerto USB frontal. `[Save/Recall] → Save → Format: 24-bit image (*.png)` → `File Name` para ponerle nombre → `Press to Save`. Con `Settings → Invert Grat` la imagen sale con fondo blanco (mejor para imprimir en la bitácora). Presione `[Save/Recall]` dos veces antes de guardar si quiere que el menú aparezca en la imagen (p. 229–232).

Las puntas digitales **reconstruyen** la señal a partir de muestras, así que **no muestran rebotes ni pulsos muy cortos** (p. 105 del manual). Para glitches y retardos de decenas de ns, use los canales analógicos.

### 0.4 ¿Por qué el capacitor va "cerca" del chip?

Sí, se refiere a que esté **físicamente lo más cerca posible** de los pines VCC y GND de ese chip, con patas cortas. Cada vez que el chip cambia de estado, consume un pico de corriente durante unos pocos nanosegundos. Si la alimentación viene por cables largos, esos cables tienen inductancia y el voltaje en el pin VCC "se hunde" un instante, lo que causa fallas intermitentes y glitches. El capacitor funciona como una pequeña reserva local de carga que entrega ese pico sin pasar por los cables.

Montarlo "cruzando por encima del chip" es justo la forma correcta en una protoboard: una pata en la fila del pin VCC y la otra en la fila del pin GND, y el cuerpo del capacitor sobre el chip. En los chips DIP los pines VCC y GND quedan en esquinas opuestas (por ejemplo, 16 y 8 en el 74LS163, o 14 y 7 en el 74LS74), así que puede quedar en diagonal: no importa, lo que importa es que las patas sean cortas y que no pase por jumpers largos ni por los rieles lejanos.

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
Esto son decenas de nanosegundos, así que use los **canales analógicos**, no los digitales:
1. Elimine el error de los cables: conecte las dos puntas analógicas **al mismo punto** (el pin CLK), entre al menú del canal 2 → `Probe → Skew` y ajuste hasta que el retardo medido entre los dos canales sea 0 (el manual, p. 69, explica que en el rango de ns pequeñas diferencias de cable alteran la medición).
2. Ponga la punta del canal 1 en CLK y la del canal 2 en Qa del contador 1. Dispare en el canal 1, flanco de subida, 20 ns/div.
3. Mida el retardo con `[Meas] → Type: Delay` (de flanco de subida del canal 1 al del canal 2, a la mitad de cada flanco), o con los cursores X1 y X2.
4. Repita con Qb, Qc y Qd. Compare con el valor típico de la hoja de datos.
Debe dar del orden de 10 a 30 ns. Hay pequeñas diferencias entre bits (distinta carga y lógica interna), pero el orden de magnitud es el mismo; escoja el bit que cambia en cada flanco (Qa) para tener referencia.

**e) Fallas (glitches) en RCO.**
RCO es una compuerta AND combinacional de T y las cuatro salidas. En un instante de transición, las salidas no cambian exactamente a la vez; si un bit sube antes de que otros bajen, el AND puede ver momentáneamente 1111 y generar un pulso muy corto.
- **Cuándo es esperable:** en transiciones donde cambian varios bits y el estado intermedio puede ser 1111, por ejemplo 0111 → 1000 (el caso más probable), 1011 → 1100 y 1101 → 1110.
- **Cómo buscarla** (en este osciloscopio el disparo por falla se llama *Pulse Width*, p. 132): `[Trigger] → Trigger: Pulse Width` → `Source`: el canal analógico donde mide RCO → polaridad positiva → calificador `<` → ancho ≈ 10 ns (el mínimo ajustable es 2 ns). Además, `[Acquire] → Acq Mode: Peak Detect` y `[Display] → Persistence: ∞ Persistence` (p. 162–164) hacen que los pulsos angostos se vean más brillantes y se acumulen. Deje correr varios segundos. Primero pruebe con los canales digitales (RCO en un canal digital, que también sirve de fuente del disparo) y luego con el canal analógico, que es el que muestra la forma real del glitch.
- Puede ser que no vea ninguna (son muy cortas y no siempre ocurren). **Si no la ve, anótelo así** y explique en qué casos se espera.
- **¿Es peligrosa?** Ocurre poco después del flanco de reloj, mucho antes del siguiente (a 1.8432 MHz hay 542 ns). La señal se estabiliza antes de que el contador 2 la muestree, así que en un diseño sincrónico no causa errores.

---

## 2. Ejercicio 5.2 — Contadores de 4 bits: asincrónico y sincrónico (lógica TTL)

**Objetivo:** construir con 74LS74 y 74LS83 un contador asincrónico y uno sincrónico, con una señal que indique que se pasó por el máximo (1111), y comparar.

> El enunciado menciona 74HC74 y 74HC283. Aquí se usan **74LS74** y un **74LS83** (sumador de 4 bits, vendido como "74LS283"): son lógica TTL, se alimentan a 5 V y tienen retardos distintos a los HC. **El 74LS83 NO tiene los mismos pines que el 74LS283** (su VCC es el pin 5 y su GND el pin 12). Use solo las tablas de esta sección. Anote en la bitácora qué chips usó realmente.

### 2.1 Materiales y alimentación

| Cant. | Chip | Alimentación |
|---|---|---|
| 2 | 74LS74 (doble flip-flop D) = 4 flip-flops. Los llamamos **chip A** y **chip B** | **5 V** |
| 1 | 74LS83 (sumador de 4 bits) | **5 V** |
| 3 | Capacitor 100 nF (uno por chip) | entre VCC y GND de cada chip |

- **Todo el circuito va a 5 V** (pin `5V` del header derecho de la placa, entre los pines 70 y 48) y GND común con la placa y el osciloscopio. Es el mismo riel que usan para el 5.1.
- **El único cable entre la FPGA y los chips es el reloj** (`clk_out`, pin 25 de la FPGA, 3.3 V). Un 74LS74 acepta 3.3 V como "1" (necesita ≥ 2 V). **Ninguna salida de estos chips va a la FPGA**: van solo al osciloscopio.
- Umbral digital del osciloscopio: **TTL (1.4 V)**.
- Los mismos chips sirven para la parte A y la B: arme el asincrónico, mida, y recablee al sincrónico.

### 2.2 Pines de los chips

**74LS74 (DIP-14), dos flip-flops D por chip. PRE y CLR son activos en bajo.**

| Pin | Señal | Pin | Señal |
|---|---|---|---|
| 1 | CLR del 1.er FF | 8 | Q̄ del 2.º FF |
| 2 | D del 1.er FF | 9 | Q del 2.º FF |
| 3 | CLK del 1.er FF | 10 | PRE del 2.º FF |
| 4 | PRE del 1.er FF | 11 | CLK del 2.º FF |
| 5 | Q del 1.er FF | 12 | D del 2.º FF |
| 6 | Q̄ del 1.er FF | 13 | CLR del 2.º FF |
| 7 | GND | 14 | VCC |

Los cuatro flip-flops: **FF0** = 1.º del chip A (bit 0, LSB), **FF1** = 2.º del chip A, **FF2** = 1.º del chip B, **FF3** = 2.º del chip B (MSB). Sus salidas Q son **Q0, Q1, Q2, Q3**:

| Salida | Pin |
|---|---|
| Q0 | chip A, pin 5 |
| Q1 | chip A, pin 9 |
| Q2 | chip B, pin 5 |
| Q3 | chip B, pin 9 |

**74LS83 (DIP-16), sumador de 4 bits (A + B + C0):**

| Pin | Señal | Pin | Señal |
|---|---|---|---|
| 1 | A4 | 9 | S1 |
| 2 | S3 | 10 | A1 |
| 3 | A3 | 11 | B1 |
| 4 | B3 | 12 | **GND** |
| 5 | **VCC (5 V)** | 13 | C0 (acarreo de entrada) |
| 6 | S2 | 14 | **C4 (acarreo de salida)** |
| 7 | B2 | 15 | S4 |
| 8 | A2 | 16 | B4 |

Fuente: [microcontrollerslab.com](https://microcontrollerslab.com/74ls83-4-bit-full-adder-pinout-examples-applications-datasheet/). **Compárelo con la hoja de datos de su chip antes de energizar.** Si el chip tiene impreso 283, use la tabla del 74LS283 de la hoja de datos, no esta.

### 2.3 Conexiones comunes (partes A y B)

**Alimentación y entradas inactivas — chip A y chip B (idéntico en los dos):**

| Pin | Va a |
|---|---|
| 14 | **5 V** |
| 7 | **GND** (y 100 nF entre el 14 y el 7, lo más cerca posible) |
| 1, 4, 10, 13 | **5 V** (CLR y PRE inactivos; si quedan flotando el flip-flop puede quedar "pegado") |

**Alimentación del 74LS83:**

| Pin | Va a |
|---|---|
| 5 | **5 V** (y 100 nF entre el 5 y el 12) |
| 12 | **GND** |

**Sumador como "Q + 1" (igual en A y B):**

| Pin del 74LS83 | Va a |
|---|---|
| 10 (A1) | Q0 = chip A, pin 5 |
| 8 (A2) | Q1 = chip A, pin 9 |
| 3 (A3) | Q2 = chip B, pin 5 |
| 1 (A4) | Q3 = chip B, pin 9 |
| 11 (B1) | **5 V** (suma 1) |
| 7 (B2), 4 (B3), **16 (B4)** | **GND** |
| 13 (C0) | **GND** |
| 14 (C4) | **MAX** (al osciloscopio, D4). Vale 1 solo cuando Q = 1111 |

Los pines **9, 6, 2 y 15** (S1 a S4, las salidas de suma) **no se conectan en la parte A**. En la parte B sí se usan, **incluido el 15**.

Opcional: para empezar en 0000, toque un instante con un jumper los pines 1 y 13 de **ambos** chips a GND y suéltelos. El contador cuenta bien aunque arranque en cualquier valor.

### 2.4 Parte A: contador asincrónico (rizado)

Idea: cada flip-flop **conmuta** (D = Q̄) y el reloj del siguiente es la salida **Q̄** del anterior.

| Chip | Pin | Va a |
|---|---|---|
| A | 3 (CLK de FF0) | **FPGA pin 25** (`clk_out`) |
| A | 2 (D de FF0) | pin 6 del mismo chip (Q̄ de FF0) |
| A | 11 (CLK de FF1) | pin 6 del mismo chip |
| A | 12 (D de FF1) | pin 8 del mismo chip (Q̄ de FF1) |
| B | 3 (CLK de FF2) | **chip A, pin 8** |
| B | 2 (D de FF2) | pin 6 del mismo chip |
| B | 11 (CLK de FF3) | pin 6 del mismo chip |
| B | 12 (D de FF3) | pin 8 del mismo chip |

(Si usara Q en vez de Q̄ para el reloj del siguiente, el contador contaría hacia atrás. Con Q̄ cuenta hacia arriba.)

Más lo de la sección 2.3 (alimentación, entradas inactivas y sumador).

**Qué conectar al osciloscopio en la parte A:**

| Qué | A dónde | Cómo |
|---|---|---|
| **Canales digitales** (pod D0 a D7) | D0 ← Q0 (chip A pin 5), D1 ← Q1 (chip A pin 9), D2 ← Q2 (chip B pin 5), D3 ← Q3 (chip B pin 9), D4 ← MAX (74LS83 pin 14), D5 ← CLK (chip A pin 3). **El cable de tierra del pod, a GND del circuito.** | Siempre. Con estos ya se ve toda la cuenta. |
| **Analógico 1** | CLK (chip A pin 3) | Solo para la medición de retardos (paso 3). **Aquí use la punta GTP-200B-4** (ver 2.6). |
| **Analógico 2** | Q3 (chip B pin 9) | Solo para la medición de retardos y para ver niveles reales. BNC regular o la segunda punta. |

Disparo: `Edge`, fuente **D3**, flanco de subida. Umbral digital **TTL (1.4 V)**.

**Qué debe ver:**
1. **Solo con los canales digitales**, a 2 µs/div: la cuenta 0 a 15 repetida cada ≈ 8.7 µs. D0 con unos 9 pulsos en 10 µs, D1 con 4–5, D2 con 2, D3 con 1. MAX (D4) en alto durante el estado 1111.
2. **Con zoom** (50 ns/div o el zoom del osciloscopio) en la transición 0111 → 1000: los bits **no cambian a la vez**. Q0 cambia primero, luego Q1, Q2 y por último Q3. Entre medio aparecen estados incorrectos (por ejemplo 0111 → 0110 → 0100 → 0000 → 1000).
3. **Aquí sí se usan los canales analógicos** (1 = CLK, 2 = Q3): mida el retardo entre el flanco de CLK y el cambio de Q3 con los cursores. Es el retardo acumulado de las cuatro etapas.
4. Esos estados intermedios pueden producir pulsos cortos en MAX (C4). Mírelos en D4 y, si hace falta, en un canal analógico.

**Bitácora:** captura de la cuenta completa, captura con zoom de la transición 0111 → 1000 (con los estados intermedios), retardo total medido entre CLK y Q3.

### 2.5 Parte B: contador sincrónico

Idea: **todos** los flip-flops comparten el reloj; el sumador calcula el siguiente valor (Q + 1) y lo entrega a las entradas D. **Modifique el circuito de la parte A**: quite estos cables y ponga estos otros.

**Quite** (de la parte A): chip A pines 2–6, 11–6 y 12–8; chip B pines 3–(chip A pin 8), 2–6, 11–6 y 12–8.

**Ponga:**

| Chip | Pin | Va a |
|---|---|---|
| A | 3 (CLK de FF0) | FPGA pin 25 (ya estaba) |
| A | 11 (CLK de FF1) | **FPGA pin 25** |
| B | 3 (CLK de FF2) | **FPGA pin 25** |
| B | 11 (CLK de FF3) | **FPGA pin 25** |
| A | 2 (D de FF0) | **74LS83 pin 9** (S1) |
| A | 12 (D de FF1) | **74LS83 pin 6** (S2) |
| B | 2 (D de FF2) | **74LS83 pin 2** (S3) |
| B | 12 (D de FF3) | **74LS83 pin 15** (S4) |

El sumador, la alimentación y las entradas inactivas quedan igual que en la parte A (sección 2.3). El pin 14 sigue dando MAX.

**Osciloscopio:** igual que en A (D0 a D3 = Q0 a Q3, D4 = MAX, D5 = CLK, disparo D3 subida, umbral TTL). Analógico 1 = CLK (con la punta), analógico 2 = Q3, solo para medir el retardo.

**Qué debe ver:**
1. La misma cuenta 0 a 15.
2. En la transición 0111 → 1000 los cuatro bits cambian **casi simultáneamente** (todos medidos desde el mismo flanco de reloj, diferencia de pocos ns), sin estados intermedios largos.
3. MAX = 1 cuando el valor es 1111.

**Bitácora:** captura de la cuenta, captura con zoom de la transición 0111 → 1000 para comparar con la parte A, retardos medidos.

### 2.6 Cuándo usar la punta GTP-200B-4 y cuándo el BNC

| Situación | Qué usar |
|---|---|
| Canales **digitales** (D0 a D7) | **Ni punta ni BNC.** Usan el pod con sus cables y su cable de tierra. |
| Analógico para el **reloj** o una señal rápida donde importa la forma del flanco | **La punta, con el interruptor en 10X.** Punta a la señal, lagarto a **GND del circuito**. En el osciloscopio, `[1]` → `Probe` → **10:1**. |
| Analógico para una señal lenta o solo para ver niveles | BNC regular: cable rojo a la señal, negro a GND. `Probe` → **1:1** (si lo deja en 10:1 verá 10 veces más voltaje, como en la foto del reloj: 32 V). |

- **Compense la punta una vez:** conéctela al terminal `Demo`/`Probe Comp` del osciloscopio (cuadrada de ~1 kHz) y gire el tornillito de la punta hasta que la cuadrada tenga esquinas rectas, sin picos ni redondeo.
- Hay que ajustar `Probe` en **cada canal** según lo que se le conectó.
- Los dos lagartos de tierra y el cable del pod van al **mismo** riel de GND.
- Si solo tiene una punta, úsela en el reloj (analógico 1) y el BNC en Q3.
- Apague el canal analógico que no esté conectado (botón `[1]` o `[2]`): un canal sin conectar capta ruido y estorba.

### 2.7 Preguntas del enunciado

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
| El osciloscopio no dispara estable | Umbral digital mal puesto (circuitos a 5 V: TTL 1.4 V; 5.3 a 3.3 V: usuario 1.65 V); disparo en el MSB |
| Contador 5.2 raro o que no cambia | Todo a 5 V (74LS74 y 74LS83); VCC del 74LS83 en el pin 5 y GND en el 12; PRE y CLR de los 74LS74 a 5 V; B1 (pin 11) del 74LS83 a 5 V y B4 (pin 16) a GND; umbral TTL |
| Circuito 74HC00 (5.3) "raro" | Recuerde alimentarlo a 3.3 V, no a 5 V |
| Chip se calienta | Apague. VCC y GND invertidos o cortocircuito |
