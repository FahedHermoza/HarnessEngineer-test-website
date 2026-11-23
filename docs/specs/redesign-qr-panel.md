# Feature Implementation Spec: Vista QR de la Tarjeta

## Source Feature

- `id`: `redesign-qr-panel`
- `area`: `sharing`
- `depends_on`: `redesign-contact-navigation` (`accepted`)
- `status`: `not_started` (al planificar; este spec no cambia el estado en `feature_list.json`)
- `source`: `feature_list.json` (`user_visible_behavior`, `verification`, `notes`); `DESIGN.md` §§ «Vista QR y estados de interacción», «Tipografía, assets y límites», «Acciones rápidas y Enlaces grandes».

## Goal

Añadir un tercer control a la fila **Acciones rápidas** (hoy Celular y Correo): una acción **QR** que, al activarse, abre **sobre la Tarjeta** un cuadro accesible (`<dialog>`) con el Código QR de la URL pública canónica, un título, cerrar, **Copiar Enlace** y **Guardar PNG**. El QR mostrado y el PNG descargable codifican **exactamente** `https://fahed-hermoza-card.fahedhermoza.workers.dev/` (la misma URL que `canonical`, `og:url` y la vCard). Al cerrar, el visitante vuelve a la Tarjeta y el foco regresa al control que abrió el cuadro.

El sitio sigue siendo estático, sin backend ni build. Se admite por primera vez **JavaScript mínimo sin dependencias** solo para esta interacción (abrir/cerrar, trampa de foco, copia al portapapeles). El QR es un **asset estático PNG** pre-generado y commiteado; no se genera en runtime. La acción QR debe tener **degradación sin JS**: sin JavaScript sigue ofreciendo el PNG estático en vez de quedar inerte.

El slice termina cuando la estructura, los conteos/selectores de `init.sh`, `CONSTRAINTS.md` y `DESIGN.md`, el navegador 390×844 y 1280×800, la matriz de ocho anchos y Lighthouse móvil Accessibility ≥95 están verificados y registrados, y `./init.sh` sale `0`. La aceptación final requiere además la **revisión visual fechada del propietario (móvil + escritorio)** y el **escaneo del QR en un teléfono real** confirmando el destino.

## Non-Goals

- **No** implementar la acción **Compartir** (`redesign-share-action`): la fila de Acciones rápidas suma **solo** el control QR en este slice (queda en **3**: Celular, Correo, QR). No crear placeholders ni controles inertes de Compartir.
- **No** rediseñar el pie (`redesign-footer-contact`) ni la imagen social (`redesign-social-preview`); el `<footer class="page-footer">` y los metadatos Open Graph / producción quedan **sin cambios**.
- **No** tocar el encabezado ornamental, el avatar/fallback, el punto verde, los cinco Enlaces grandes, el botón Guardar contacto ni la vCard `assets/fahedhermoza.vcf`.
- **No** introducir frameworks, bundlers, dependencias de runtime, librerías de QR cargadas en el cliente, fuentes nuevas ni tokens de color nuevos. El QR se genera **offline** con una herramienta externa (igual que `assets/og-image.jpg`) y se commitea como binario estático.
- **No** usar `role="button"`, `href="#"`, `href=""` ni **manejadores inline** (`onclick`/`onkeydown`/`onkeypress`). La interacción usa `addEventListener` desde un `<script>` propio.
- **No** debilitar silenciosamente ningún check de `init.sh`: todo cambio de conteo/selector/prohibición es explícito y conserva o refuerza la cobertura (anclas reales, iconos decorativos, foco, reduced motion, contraste AA, tap ≥44×44, vCard estática).
- **No** marcar `accepted`: el implementador deja `passing` con evidencia; el validador acepta; la aprobación visual del propietario y el escaneo real son pasos separados.

## Job Story

When quiero abrir la Tarjeta digital de Fahed en otro dispositivo o mostrarla físicamente,
I want pulsar la acción QR y ver un código escaneable de la URL pública con opciones de copiar el enlace y guardar el PNG,
so I can abrir o compartir la Tarjeta sin teclear la dirección, y volver a la Tarjeta sin perder el lugar ni el foco.

## Users And Permissions

- Visitante anónimo (con JS): activa QR por ratón/toque/teclado; ve el cuadro, escanea, copia el enlace o guarda el PNG, y cierra con el botón, Escape o tocando fuera; el foco vuelve al control QR. Sin autenticación ni estado.
- Visitante sin JS: activa QR y obtiene el **PNG estático** (lo abre el navegador para ver/escanear/guardar); nunca un control inerte.
- Propietario/agente: fija la dirección visual en `DESIGN.md` (ya cubierta) y aprueba el resultado en móvil y escritorio; genera y commitea `assets/qr.png`.
- Implementador/validador: adapta `init.sh`/`CONSTRAINTS.md` explícitamente, verifica en navegador + Lighthouse + escaneo real, y registra evidencia.

## Acceptance Scenarios

### Scenario 1: Tercera Acción rápida QR con degradación sin JS

Given la Tarjeta servida a 390×844 o 1280×800,
When se inspecciona `<nav class="quick-actions">`,
Then contiene **exactamente 3** anclas `.quick-action` en orden Celular, Correo, QR; la de QR es un `<a class="quick-action">` real con `href="assets/qr.png"` (destino de fallback), nombre accesible por `aria-label` (p. ej. «Mostrar Código QR de la Tarjeta»), icono SVG decorativo (`aria-hidden="true"` + `focusable="false"`) y diámetro ≥44×44; sin JavaScript, activarla abre/descarga el PNG estático, no queda inerte.

### Scenario 2: Apertura del cuadro sobre la Tarjeta (con JS)

Given JavaScript disponible y el foco en el control QR,
When se activa con ratón, toque, Enter o Espacio,
Then se evita la navegación por defecto y se abre un `<dialog class="qr-panel">` **modal** centrado sobre la Tarjeta con fondo atenuado; el cuadro está etiquetado (`aria-labelledby` → su título), el foco entra al cuadro, el fondo queda inerte y la consola/red siguen limpias.

### Scenario 3: Contenido del cuadro — QR, Copiar Enlace, Guardar PNG, Cerrar

Given el cuadro abierto,
When se inspecciona su contenido,
Then muestra: un título visible; un `<img class="qr-panel__code" src="assets/qr.png" alt="…">` con `alt` descriptivo que referencia el Código QR de la Tarjeta/URL pública (no decorativo); un `<button type="button" class="qr-panel__close" aria-label="Cerrar">`; un `<button type="button" class="qr-panel__copy">Copiar Enlace</button>`; y un `<a class="qr-panel__save" href="assets/qr.png" download="fahed-hermoza-card-qr.png">Guardar PNG</a>`. Cada botón/enlace tiene nombre accesible, foco visible e icono SVG decorativo (si lo lleva) con `aria-hidden`/`focusable="false"`, y área táctil ≥44×44.

### Scenario 4: QR y PNG codifican exactamente la URL canónica

Given `assets/qr.png` y el QR mostrado,
When se escanea el QR en un teléfono real y se abre el PNG descargado,
Then ambos resuelven **exactamente** `https://fahed-hermoza-card.fahedhermoza.workers.dev/` (byte-idéntica a `PRODUCTION_URL`, con barra final, sin `www`, `http://`, query ni `/index.html`), y la constante de URL usada por el `<script>` para copiar coincide con esa misma cadena.

### Scenario 5: Copiar Enlace — éxito y permiso denegado

Given el cuadro abierto,
When se activa «Copiar Enlace»,
Then con permiso concedido el portapapeles recibe la URL canónica y aparece una confirmación visible y anunciada (`aria-live="polite"`, p. ej. «Enlace copiado»); con permiso denegado o `clipboard` no disponible, se muestra una respuesta comprensible (p. ej. la URL seleccionable para copiar manualmente), sin errores de consola ni estado roto.

### Scenario 6: Cierre y retorno del foco

Given el cuadro abierto,
When se cierra con el botón Cerrar, con la tecla Escape, o tocando/clicando el fondo atenuado,
Then el `<dialog>` se cierra, el visitante vuelve a la Tarjeta y el foco regresa **al control QR** que lo abrió; no queda foco atrapado ni contenido oculto accesible por lector de pantalla.

### Scenario 7: Accesibilidad, foco, reduced motion y contraste

Given la página recorrida con `Tab`, con hover y `prefers-reduced-motion: reduce`,
Then cada control nuevo (QR quick action, Cerrar, Copiar, Guardar) muestra `outline: 2px solid var(--color-accent); outline-offset: 2px;` al enfocar; con movimiento reducido la animación de apertura del cuadro y las transiciones de los controles quedan en `transition: none`/`transform: none`; el texto y los iconos del cuadro cumplen contraste ≥4.5:1 en reposo y en `brightness(1.03)`; el `<html lang="es">` y el único `<h1>` se conservan (el título del cuadro es `<h2>`/`<p>`, no un segundo `<h1>`).

### Scenario 8: El gate detecta regresiones

Given una copia temporal fuera del repo con (a) la Acción QR ausente o convertida en control inerte sin `href`, (b) el `<dialog>` o uno de sus controles (Cerrar/Copiar/Guardar) ausente, (c) `assets/qr.png` ausente/vacío o no-PNG, (d) la URL copiada distinta de `PRODUCTION_URL`, (e) un control con `role="button"`, `href="#"` o manejador inline, (f) foco/reduced-motion de un control nuevo roto, o (g) un `<script>` dentro del bloque de la vCard,
When se ejecuta `./init.sh`,
Then sale con código 1, imprime el check concreto en stderr y no arranca ningún servidor.

### Scenario 9: Consola, red, responsive y Lighthouse limpios

Given la página servida en `http://localhost:3620/`,
When se carga a 390×844 y 1280×800, se abre/cierra el cuadro y se ejecuta Lighthouse móvil de accesibilidad,
Then la consola muestra 0 mensajes, todas las peticiones responden 2xx/3xx sin `/favicon.ico`, no hay scroll horizontal en los ocho anchos auditados, y la accesibilidad es ≥95 sin auditorías `critical`/`serious`.

## Repository Research

### Files Inspected

- `AGENTS.md`, `CONSTRAINTS.md`, `DESIGN.md` — DoD; base AA/responsive/publicación; `CONSTRAINTS` pinea «exactamente 10 anclas (5 `.link-button` + 2 `.quick-action` + 1 `.save-contact-button` + 2 `.page-footer__link`)», «MUST keep every control a real `<a>`», «MUST NOT use `role="button"`, inline `onclick`…», foco/reduced-motion/contraste/tap≥44 y «MUST NOT add JavaScript…»; `DESIGN.md` §§ 463-485 ya **sancionan** la Vista QR (cuadro centrado con fondo atenuado, título, QR escaneable de la URL pública, cerrar, «Copiar Enlace», «Guardar PNG», retorno de foco, teclado, reduced-motion, AA) y el límite «QR descargable PNG, JavaScript mínimo solo para las nuevas interacciones».
- `index.html` — `<nav class="quick-actions" aria-label="Acciones rápidas">` con 2 anclas (Celular `tel:+51955116562`, Correo `mailto:…`); `.save-contact` entre `</nav>` y `<footer>`; único `<h1>`; `<link rel="icon" href="data:,">`. Hoy **cero `<script>`**.
- `styles.css` — `.quick-action` (48×48, `radius-full`, superficie `--color-surface-container-low`, icono `--color-primary`, foco acento, hover `brightness(1.03)`), bloque `@media (prefers-reduced-motion: reduce)` con `.link-button`, `.save-contact-button`, `.quick-action`; sombras por **literales rgba** (p. ej. `rgba(45, 49, 57, 0.16)`), no tokens; 16 tokens `--color-*`.
- `init.sh` — gates relevantes (números aproximados): quick-actions markup/Celular (~799-838), **Correo contract** (~1120-1152), **save-contact** con `grep -qE 'data:text/vcard|<script|new Blob' index.html styles.css` (**~1648**, escanea TODO el archivo), posición `.save-contact` (~1653-1663), conteos **`anchor_total`==10 / `link_button_total`==5 / `quick_action_total`==2** (~1813-1876), `role="button"`/inline-handlers/`href="#"` prohibidos (~1867-1874), **`svg_total`==10** decorativos con `aria-hidden`+`focusable="false"` (~1879-1913), foco `.quick-action:focus-visible` (~1929-1947), reduced-motion (~1973-1978), `CONTRAST_TOKENS`+15/15, tap `.quick-action` ≥44 (~2232-2256), `PRODUCTION_URL` = `https://fahed-hermoza-card.fahedhermoza.workers.dev/` (constante de publicación), `Design conformance checks:` (front-matter `colors:` ↔ `--color-*`).

### Existing Patterns To Follow

- HTML estático, CSS plano, BEM-ish, color/tipografía/espaciado solo por tokens existentes; iconos SVG inline decorativos; assets binarios en `assets/` generados con herramientas externas (precedente: `assets/og-image.jpg`).
- Gate aditivo no bloqueante con `awk`/`grep`, mensajes `[ok]`/`FAILED - …` a stderr, `exit 1`, sin servidor por defecto; casos negativos en copias temporales fuera del repo.
- Verificación con `python3 -m http.server <puerto> --directory .`, Chrome DevTools 390×844 y 1280×800, Lighthouse móvil, matriz de ocho anchos.

### Current Gaps

- No existe la Acción QR, el `<dialog>`, su CSS, el `<script>` de interacción ni `assets/qr.png`.
- **Bloqueador de gate:** `init.sh` (~1648) `grep`ea `<script` en **todo** `index.html`/`styles.css`; cualquier `<script>` del cuadro QR **rompe** ese check de vCard. Debe reescoparse al `SAVE_CONTACT_BLOCK`.
- Conteos pineados (10 anclas, 2 quick-action, 10 SVG) y la regla «todo control es un `<a>`» no admiten los controles `<button>` del cuadro ni los nuevos anclas; deben adaptarse explícitamente.
- `CONSTRAINTS.md` prohíbe JavaScript y pinea 10 anclas / todo-control-ancla; debe permitir **explícitamente** el JS mínimo del cuadro y los `<button type="button">` de acción in-page, conservando el fallback sin JS, el no-inline-handlers y la vCard estática.
- No hay E2E persistente; añadirlo introduciría dependencias prohibidas. Cobertura = `init.sh` + navegador + Lighthouse + escaneo real.

## Technical Approach

### Asset QR estático (`assets/qr.png`)

- Generar **offline** (herramienta externa, p. ej. `qrencode`/`python-qrcode`; **no** se añade al producto ni al repo como dependencia) un PNG que codifique **exactamente** `https://fahed-hermoza-card.fahedhermoza.workers.dev/`. Módulos negros puros sobre blanco, con zona de silencio (quiet zone) y corrección de errores suficiente para escanear en pantalla pequeña e impreso. Commitear el binario en `assets/qr.png`.
- Un **único** PNG sirve tanto para mostrar (`<img>`) como para descargar (`download`). No se requiere SVG; `DESIGN.md` exige PNG para el descargable.
- El contenido codificado **no** es verificable estáticamente sin un decodificador (dependencia prohibida): se valida por **escaneo real** y lectura del PNG en el navegador (evidencia manual honesta).

### Estructura HTML

1. **Acción QR en `.quick-actions`** (tercer control, tras Correo): `<a class="quick-action" href="assets/qr.png" aria-label="Mostrar Código QR de la Tarjeta">` con su icono SVG decorativo. El `href` al PNG es la **degradación sin JS**; el `<script>` intercepta el clic y abre el cuadro.
2. **Cuadro** como `<dialog class="qr-panel" aria-labelledby="qr-panel-title">`, ubicado como **último hijo de `<article class="card">`, después del `<footer>`** (el `<dialog>` modal se pinta en el top layer, así que su posición en el DOM no afecta el centrado visual, pero mantenerlo tras el pie **no** altera el gate de posición de `.save-contact`, que usa el primer `</nav>`/`.save-contact`/`<footer>`). Contenido:
   - `<h2 id="qr-panel-title" class="qr-panel__title">` con un título corto (p. ej. «Escanea para abrir la Tarjeta»).
   - `<img class="qr-panel__code" src="assets/qr.png" alt="Código QR que abre la Tarjeta digital de Fahed Hermoza" width="…" height="…">` (alt descriptivo, **no** decorativo; no es `<svg>`, no entra en el conteo de SVG decorativos).
   - `<button type="button" class="qr-panel__close" aria-label="Cerrar">` (× como SVG decorativo o glifo textual).
   - `<button type="button" class="qr-panel__copy">Copiar Enlace</button>` (+ icono SVG decorativo opcional).
   - `<a class="qr-panel__save" href="assets/qr.png" download="fahed-hermoza-card-qr.png">Guardar PNG</a>` (+ icono SVG decorativo opcional). Ancla real: funciona también sin JS dentro del cuadro.
   - Un elemento de estado `aria-live="polite"` para la confirmación de copia.
3. Conservar único `<h1>`, `lang="es"`, `lang="en"` en la Tagline, el `onerror` del avatar y todos los controles existentes.

### JavaScript mínimo (sin dependencias, sin manejadores inline)

- Un `<script>` propio (al final de `<body>`, o `scripts.js` enlazado con `<script src="scripts.js" defer>`), que use **solo** `addEventListener`.
- Constante `const CANONICAL_URL = 'https://fahed-hermoza-card.fahedhermoza.workers.dev/';` idéntica a `PRODUCTION_URL`.
- Abrir: en el clic del control QR, `event.preventDefault()`, guardar el opener (`event.currentTarget`), `dialog.showModal()` (trampa de foco, Escape e inert del fondo nativos), mover el foco a Cerrar o al cuadro.
- Cerrar: botón Cerrar → `dialog.close()`; clic/toque en el fondo (`dialog` recibe el click fuera de su contenido, comparar `event.target === dialog`) → `close()`; Escape lo maneja `<dialog>` nativo (escuchar el evento `close`/`cancel`). En cada cierre, **restaurar el foco al control QR** guardado.
- Copiar: `navigator.clipboard.writeText(CANONICAL_URL)` → éxito: mensaje `aria-live` «Enlace copiado»; error/denegado o API ausente: revelar la URL seleccionable + mensaje comprensible. Sin lanzar errores a consola.
- Degradación: si `window.HTMLDialogElement`/`showModal` no existe o JS no corre, el control QR y «Guardar PNG» siguen siendo anclas al PNG estático.

### CSS

- `.qr-panel` (`<dialog>`): superficie `--color-surface`, radio del sistema, padding con tokens de espaciado, `max-width` seguro para móvil estrecho (`min(…, calc(100vw - 2rem))`), centrado; `::backdrop` con **literal rgba** atenuado derivado de `--color-on-surface` (p. ej. `rgba(45, 49, 57, 0.5)`), coherente con las sombras por literal ya presentes — **sin** token de color nuevo.
- Controles del cuadro: Cerrar/Copiar/Guardar con área táctil ≥44×44, `button-label`/iconos coherentes, `:focus-visible` con `outline: 2px solid var(--color-accent); outline-offset: 2px;`, hover `brightness(1.03)` si aplica; texto/icono con pares de contraste ya pineados (neutro `--color-primary`/`--color-surface-container-low` o tono blanco-sobre-degradado existente) — **sin** colores nuevos.
- Animación de apertura breve (opacidad/escala) permitida por `DESIGN.md`; **debe** quedar anulada bajo `@media (prefers-reduced-motion: reduce)` junto con las transiciones de los controles.
- No alterar `.link-button`, `.save-contact-button`, `.quick-action` base, el pie ni los tokens.

### Cambios en `init.sh` (explícitos, sin debilitar)

1. **Reescopar el check de la vCard (~1648):** `grep -qE 'data:text/vcard|<script|new Blob'` debe aplicarse al `SAVE_CONTACT_BLOCK` (o excluir el bloque/el archivo del `<script>` del cuadro), no a todo `index.html`. Mantener la intención: el control de vCard sigue siendo `<a>` estático sin script/Blob/data-URI. **Sin este cambio, `./init.sh` no puede salir 0 con el QR panel.**
2. **Acción QR en quick-actions:** nuevo check de que existe un `<a class="quick-action" href="assets/qr.png">` con `aria-label` e icono decorativo dentro de `.quick-actions`, como tercer control tras Celular y Correo.
3. **Conteos de anclas:** `anchor_total` esperado **12** (5 link + 3 quick-action + 1 save contact + 2 footer + 1 `.qr-panel__save`); `quick_action_total` esperado **3**; `quick_action_class_total` en consecuencia; actualizar el mensaje `[ok] … real anchor controls (…)` al nuevo desglose. Mantener `link_button_total`==5.
4. **Controles no-ancla permitidos:** añadir cobertura explícita de que los únicos controles no-ancla son los `<button type="button">` del cuadro (Cerrar, Copiar) — contarlos (exactamente 2), exigir `type="button"` (no `submit`), y mantener prohibidos `role="button"`, `href="#"`/`href=""` y manejadores inline `on(click|keydown|keypress)`.
5. **SVG decorativos:** actualizar `svg_total` al nuevo total exacto (10 actuales + los iconos decorativos que añada el cuadro/trigger; el `<img>` del QR **no** cuenta) y conservar la exigencia `aria-hidden="true"` + `focusable="false"` para todos.
6. **Cuadro QR:** checks de que existe `<dialog class="qr-panel" …>` etiquetado, con `.qr-panel__code` (`<img src="assets/qr.png"` + `alt` no vacío), `.qr-panel__close` (`<button type="button"`), `.qr-panel__copy` (`<button type="button"`) y `.qr-panel__save` (`<a … href="assets/qr.png" download="fahed-hermoza-card-qr.png">`).
7. **URL canónica del QR:** check de que el `download` apunta a `assets/qr.png`, que el trigger y «Guardar PNG» referencian `assets/qr.png`, y que la constante del `<script>` (`CANONICAL_URL`) es **byte-idéntica a `PRODUCTION_URL`**.
8. **Asset:** check de que `assets/qr.png` existe, no está vacío y es un **PNG real** (magic bytes `\x89PNG`), análogo a los checks de `og-image.jpg`/`avatar.jpg`.
9. **JS mínimo:** check de que hay un `<script>` que usa `addEventListener` (no manejadores inline) y no carga dependencias externas de QR.
10. **Foco / reduced motion / tap:** añadir `.qr-panel__close:focus-visible`, `.qr-panel__copy:focus-visible`, `.qr-panel__save:focus-visible` al gate de foco; añadir el selector animado del cuadro al bloque reduced-motion; aserción estática de tap ≥44×44 para los controles del cuadro.
11. **Contraste:** mantener `CONTRAST_TOKENS` y 15/15 si el cuadro reusa los pares ya pineados; si cualquier token cambia, recalcular reposo y `brightness(1.03)` y actualizar `DESIGN.md` + gate juntos. (Recomendado: no cambiar ningún token.)
12. Mantener intactos pie, encabezado, metadatos, posición `.save-contact`, responsive y el servidor opt-in. Hint de servidor interno sin cambios; la verificación manual de esta worktree usa **3620**.

## Expected File Changes

- `index.html` — modificar; añadir la Acción QR en `.quick-actions`, el `<dialog class="qr-panel">` con QR/Cerrar/Copiar/Guardar y el estado `aria-live`, y el `<script>` (o `<script src>`). Conservar encabezado, Enlaces, `.save-contact`, pie y único `<h1>`.
- `styles.css` — modificar; reglas de `.qr-panel`, `::backdrop`, controles del cuadro (foco, hover, tap≥44, animación con guard reduced-motion); sin tokens nuevos.
- `scripts.js` — **crear (recomendado)**; JS mínimo de interacción con `addEventListener` (o inline al final de `<body>` si se prefiere un solo archivo).
- `assets/qr.png` — **crear**; PNG estático que codifica exactamente la URL canónica.
- `init.sh` — modificar; reescopar el check de `<script>` de la vCard, adaptar conteos (12 anclas, 3 quick-action, SVG), añadir checks del cuadro/asset/URL/JS/foco/reduced-motion/tap, permitir los `<button>` in-page; no debilitar nada.
- `CONSTRAINTS.md` — actualizar (ver «Durable Documentation Impact»).
- `feature_list.json`, `PROGRESS.md` — el implementador registra `passing` + evidencia y sesión; el validador crea `docs/validations/redesign-qr-panel.md`.
- `DESIGN.md` — **no editar**: ya sanciona la Vista QR (§§ 463-485). Ver nota de decisión de diseño abierta abajo.

## Visual Design Impact

- UI involved: **yes**. Design source: `DESIGN.md` §§ «Vista QR y estados de interacción» y «Tipografía, assets y límites» (ya describen el cuadro, sus controles, el PNG y las reglas AA/reduced-motion).
- Estados afectados: Acción QR (reposo/hover/foco/reduced-motion); cuadro `<dialog>` (abierto/cerrado, fondo atenuado, animación de apertura); Copiar (éxito/denegado); a 390×844, 1280×800 y los ocho anchos.
- New design artifact required: el **asset `assets/qr.png`** (generado offline). No se crean colores ni fuentes.
- **Decisión de diseño abierta (no bloqueante, para el propietario):** `DESIGN.md` dice que los colores claros de las referencias son «dirección cromática» y **no** tokens aprobados. No existe token de scrim/overlay y añadir un `--color-*` nuevo rompería el gate `Design conformance checks:` (front-matter ↔ tokens). Por eso el fondo atenuado del `::backdrop` debe ser un **literal rgba derivado de `--color-on-surface`** (patrón ya usado por las sombras), **sin** token nuevo. Si el propietario quisiera un scrim distinto que exija un token nuevo, es una decisión de diseño a resolver en `DESIGN.md` **antes** de implementar. El planner no edita `DESIGN.md` en esta corrida; la aprobación visual del scrim queda `pending`.

## Durable Documentation Impact

- `ARCHITECTURE.md`: not needed — no cambia dominios ni runtime (no existe; no crear).
- `CONSTRAINTS.md`: **update** — (a) re-expresar el desglose de anclas como «12 anclas: 5 `.link-button` + 3 `.quick-action` + 1 `.save-contact-button` + 2 `.page-footer__link` + 1 `.qr-panel__save`»; (b) **relajar explícitamente** la regla «todo control es un `<a>`» para admitir `<button type="button">` en acciones in-page del cuadro QR (Cerrar, Copiar), manteniendo prohibidos `role="button"`, `href="#"`/`""` y manejadores inline; (c) **permitir** JavaScript mínimo, sin dependencias, vía `<script>` con `addEventListener` **solo** para la interacción del cuadro y la copia, conservando el fallback sin JS (la Acción QR ofrece el PNG estático) y sin usar JS como muleta de la base AA; (d) mantener la vCard estática (sin `<script>`/Blob/data-URI en **su** control); (e) añadir `:focus-visible`, reduced-motion (incluida la animación del cuadro) y tap≥44×44 de los controles del cuadro; (f) actualizar el desglose de SVG decorativos; (g) añadir la regla del asset `assets/qr.png` (PNG estático que codifica la URL canónica; sin generación en runtime). No debilitar ningún MUST existente.
- `AGENTS.md`: not needed — workflow/DoD/arranque sin cambios (no contiene conteos).
- `DESIGN.md`: **not edited by planner** — ya cubre la dirección de la Vista QR; solo queda la decisión abierta del scrim (arriba), que no requiere editar `DESIGN.md` si se usa el literal rgba recomendado.
- `docs/technical-discovery.md`: update si cambia alguna medición/comando de verificación o para registrar la herramienta offline de generación del QR; `docs/risks-and-open-questions.md`: registrar la decisión del scrim, la aprobación visual pendiente y el escaneo real pendiente.
- `CONTEXT.md` / `docs/domain-model.md`: not needed — la URL pública ya está modelada; esta feature añade solo su presentación QR.

## Implementation Plan

1. Confirmar baseline: `bash -n init.sh && ./init.sh` → exit 0.
2. Generar `assets/qr.png` (offline, codifica exactamente la URL canónica) y commitearlo.
3. En `index.html`: añadir la Acción QR a `.quick-actions`, el `<dialog class="qr-panel">` con QR/título/Cerrar/Copiar/Guardar + estado `aria-live`, y el `<script>`.
4. En `styles.css`: añadir `.qr-panel`, `::backdrop` (literal rgba), controles del cuadro (foco, tap≥44, animación con guard reduced-motion).
5. Escribir el JS mínimo (abrir/cerrar, trampa+retorno de foco, copia con éxito/denegado), con `addEventListener` y `CANONICAL_URL` == `PRODUCTION_URL`.
6. Adaptar `init.sh`: reescopar el check de `<script>` de la vCard; conteos 12/3/SVG; checks del cuadro/asset/URL/JS/foco/reduced-motion/tap; permitir los `<button>` in-page. Sin debilitar.
7. Actualizar `CONSTRAINTS.md` (desglose de anclas, `<button>` in-page, JS permitido, foco/reduced-motion/tap, asset QR).
8. Ejecutar gate, casos negativos, navegador 390×844/1280×800, matriz de ocho anchos, Lighthouse y **escaneo en teléfono real**; registrar `passing` + evidencia; solicitar la revisión visual del propietario.

## Implementation Tasks

- [ ] Confirmar baseline `./init.sh` exit 0.
- [ ] Generar y commitear `assets/qr.png` (URL canónica exacta; negro/blanco; quiet zone; escaneo verificado).
- [ ] Añadir la Acción QR (`<a class="quick-action" href="assets/qr.png">`) como tercer control de `.quick-actions`, con `aria-label` e icono decorativo.
- [ ] Añadir el `<dialog class="qr-panel">` etiquetado con título, `<img>` del QR (alt real), Cerrar/Copiar (`<button type="button">`), Guardar PNG (`<a … download>`) y estado `aria-live`.
- [ ] Escribir el JS mínimo (`addEventListener`, `showModal`/`close`, retorno de foco, copia éxito/denegado, `CANONICAL_URL` == `PRODUCTION_URL`); degradación sin JS al PNG.
- [ ] CSS del cuadro: `.qr-panel`, `::backdrop` (literal rgba), controles (foco acento, tap≥44, hover), animación con guard reduced-motion; sin tokens nuevos.
- [ ] `init.sh`: reescopar check `<script>` de vCard; conteos 12 anclas / 3 quick-action / SVG; checks de cuadro/asset/URL/JS/foco/reduced-motion/tap; permitir `<button>` in-page; actualizar mensajes.
- [ ] `CONSTRAINTS.md`: desglose 5+3+1+2+1, `<button>` in-page, JS permitido con fallback, foco/reduced-motion/tap, asset QR.
- [ ] Casos negativos, navegador 390×844/1280×800, ocho anchos, Lighthouse, escaneo real; registrar `passing` + evidencia; solicitar aprobación visual.

## Verification Plan

- `bash -n init.sh` → sin errores de sintaxis.
- `./init.sh` → exit 0, `Harness status: bootstrapped`, con los nuevos `[ok]` (Acción QR, cuadro, `.qr-panel__save`, asset PNG, URL == `PRODUCTION_URL`, `<script>` con `addEventListener`, 12 anclas / 3 quick-action / nuevo total de SVG, foco/reduced-motion/tap), gates previos verdes; **sin** arrancar servidor.
- Casos negativos en copias temporales fuera del repo (borrar; sin listener): (1) Acción QR ausente / sin `href` → quick-action/conteo `exit 1`; (2) `<dialog>` o un control ausente → check del cuadro `exit 1`; (3) `assets/qr.png` ausente/vacío/no-PNG → asset `exit 1`; (4) URL copiada ≠ `PRODUCTION_URL` → `exit 1`; (5) `role="button"`/`href="#"`/manejador inline → `exit 1`; (6) `:focus-visible`/reduced-motion de un control nuevo roto → `exit 1`; (7) `<script>` dentro del bloque de la vCard → check de vCard `exit 1`. Cada fallo con `FAILED - …` y sin servidor.
- Servido manual (solo implementador/validador, worktree aislada): `python3 -m http.server 3620 --directory .`; detener y dejar 3620 libre al terminar. El planner no arranca servidores. `curl -sI http://localhost:3620/` y `/styles.css` → 200; `/assets/qr.png` → 200 `image/png`; `/assets/fahedhermoza.vcf` → 200; log sin 4xx/5xx ni `/favicon.ico`.
- Navegador 390×844 y 1280×800 (recarga fresca): consola 0; peticiones 2xx/3xx sin `/favicon.ico`; `documentElement`/`body` `scrollWidth === clientWidth`; abrir el cuadro con ratón/teclado/toque, verificar centrado sobre la Tarjeta, fondo atenuado, foco dentro del cuadro; cerrar con botón/Escape/fondo y confirmar retorno de foco al control QR; Copiar con permiso concedido (portapapeles = URL canónica, confirmación anunciada) y denegado (respuesta comprensible); «Guardar PNG» descarga `assets/qr.png`; hover y `prefers-reduced-motion: reduce` sin animación; tap ≥44×44 en Acción QR y controles del cuadro.
- Matriz de ocho anchos (320, 360, 375, 390, 480, 736, 768, 1280 CSS px): sin scroll horizontal con el cuadro abierto y cerrado; el cuadro usable en móvil estrecho.
- Lighthouse móvil en `http://localhost:3620/`: Accessibility ≥95, sin `critical`/`serious`; auditar el `<dialog>` etiquetado y el contraste de los controles del cuadro en reposo y `brightness(1.03)`.
- **Escaneo en teléfono real:** escanear el QR mostrado y abrir el PNG descargado; confirmar que ambos resuelven exactamente `https://fahed-hermoza-card.fahedhermoza.workers.dev/`. Registrar con honestidad (si solo se emuló, declararlo; no afirmar escaneo real que no se hizo).
- E2E: no existe harness persistente y añadirlo introduciría dependencias prohibidas; cobertura = `init.sh` + navegador + Lighthouse + escaneo real.
- `./init.sh` ejecuta el gate estándar no bloqueante; no arranca procesos de larga duración y puede imprimir comandos manuales tras pasar los checks.

## Evidence To Capture

- Salida de `bash -n init.sh` y `./init.sh` (todos los `[ok]`, conteos 12/3/SVG, 15/15 de contraste, exit 0, sin servidor).
- Stderr de cada caso negativo sin listener en 3620.
- Tablas de navegador 390×844 y 1280×800: apertura/cierre, retorno de foco al control QR, Copiar éxito/denegado, descarga del PNG, geometría/centrado, foco visible, reduced-motion, tap≥44, consola/red limpias; Lighthouse móvil.
- Prueba del asset: `assets/qr.png` es PNG real; `curl -sI /assets/qr.png` → 200 `image/png`.
- Registro honesto del **escaneo real** (hecho o pendiente) confirmando la URL, y de la **solicitud de aprobación visual del propietario** (fecha, móvil/escritorio, respuesta). Si faltan, dejar `owner visual review: pending` / `real-device scan: pending` y **no** marcar `accepted`.
- Diff que prueba que encabezado, Enlaces, `.save-contact`, pie, metadatos y vCard siguen intactos.

## Validator Checklist

- [ ] Solo este slice: tercera Acción QR + cuadro `<dialog>` con QR/Cerrar/Copiar/Guardar; sin acción Compartir, sin cambios de pie/metadatos/encabezado/Enlaces/vCard.
- [ ] El QR mostrado y `assets/qr.png` codifican exactamente la URL canónica (escaneo real registrado o pendiente honesto); `CANONICAL_URL` == `PRODUCTION_URL`.
- [ ] Degradación sin JS: la Acción QR ofrece el PNG estático; nunca inerte. Con JS: apertura/cierre por ratón/toque/teclado/Escape/fondo, retorno de foco al control QR, lectura accesible, Copiar éxito **y** denegado.
- [ ] 12 anclas reales (5+3+1+2+1) y solo los 2 `<button type="button">` in-page del cuadro como no-anclas; sin `role="button"`, `href="#"`/`""` ni manejadores inline; SVG decorativos con `aria-hidden`+`focusable="false"`; foco visible, reduced-motion (incl. animación del cuadro) y tap≥44×44 en todos los controles nuevos; contraste AA en reposo y hover/foco.
- [ ] `init.sh` y `CONSTRAINTS.md` adaptados **explícitamente** (check de `<script>` de vCard reescopado; conteos 12/3; `<button>` in-page permitidos; JS permitido con fallback; asset QR; foco/reduced-motion/tap) sin debilitar anclas, iconos, foco, reduced-motion, contraste, tap≥44 ni la vCard estática.
- [ ] `./init.sh` sale 0 sin servidor y detecta todos los casos negativos; navegador 390×844/1280×800 y ocho anchos sin scroll horizontal; Lighthouse móvil ≥95 sin `critical`/`serious`.
- [ ] Sin tokens/colores/fuentes/dependencias nuevos; `DESIGN.md` no reescrito para calzar el código; `feature_list.json`/`PROGRESS.md` con evidencia real; aprobación visual del propietario solicitada y registrada (si falta, no `accepted`).

## Risks And Open Questions

- **Check de `<script>` de la vCard (bloqueador):** `init.sh ~1648` escanea todo el archivo; debe reescoparse al `SAVE_CONTACT_BLOCK` o el `<script>` del cuadro impedirá `exit 0`. Es el primer cambio a hacer.
- **JS por primera vez:** `CONSTRAINTS.md`/`DESIGN.md` ya lo sancionan «solo para las nuevas interacciones»; mantenerlo mínimo, sin dependencias, sin manejadores inline, y con fallback sin JS.
- **Scrim/backdrop sin token:** usar literal rgba derivado de `--color-on-surface` (patrón de sombras) para no romper `Design conformance checks:`; el propietario aprueba el tono visual. No añadir `--color-*` nuevo.
- **Generación del QR offline:** herramienta externa (no dependencia de producto), igual que `og-image.jpg`; el contenido codificado se valida por escaneo real, no por el gate.
- **Compatibilidad de `<dialog>`:** `showModal`/`::backdrop` tienen amplio soporte; el fallback sin JS (ancla al PNG) cubre navegadores sin `HTMLDialogElement`.
- **Duplicación transitoria y pie:** el pie y Compartir se abordan en features posteriores; no publicar hasta completar el rediseño (`redesign-social-preview` depende de esta feature).
- **Puerto:** verificación manual de esta worktree en **3620**; el hint interno de `init.sh` no se cambia en este alcance.
- **Sizing:** feature en el extremo alto pero única (un cuadro + un control). Correctamente dimensionada para un spec; no requiere split.
