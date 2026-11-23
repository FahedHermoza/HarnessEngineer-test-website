# Feature Implementation Spec: Compartir Tarjeta desde una sola acción rápida

## Source Feature

- `id`: `redesign-share-action`
- `area`: `sharing`
- `depends_on`: `redesign-contact-navigation` (`accepted`)
- `status`: `not_started` (al planificar; este spec no cambia el estado)
- `source`: `feature_list.json` (`user_visible_behavior`, `verification`, `notes`); `DESIGN.md` § «Dirección del rediseño acordado (2026-11-21)» (jerarquía con «una única acción Compartir» y la regla «Compartir usa la hoja nativa… si no está disponible, copia la URL canónica y muestra confirmación visible»); `DESIGN.md` § «Compartir — decisión de diseño aprobada (`redesign-share-action`, 2026-11-23)» (valores concretos aprobados por el propietario: tratamiento de la confirmación/error, tercer control de Acciones rápidas, tratamiento visual neutro).

## Goal

Añadir **una sola** acción Compartir a la fila de Acciones rápidas. Al activarla: si el navegador expone la Web Share API (`navigator.share`), abre la hoja nativa del dispositivo con la **URL canónica de producción**; si no, copia esa URL al portapapeles (`navigator.clipboard.writeText`) y muestra una **confirmación visible**; si la copia falla, muestra un **error comprensible** con la URL para copiarla a mano. El control es **mejora progresiva**: sin JavaScript no debe existir un botón Compartir inerte.

El slice introduce el **primer JavaScript** del repositorio (mínimo, sin dependencias, sin build) y el **primer `<button>` semántico** de la página. Termina cuando la estructura, el JS, los conteos/selectores de `init.sh`, las cuatro ramas (API disponible / ausente / cancelada / portapapeles denegado), el navegador 390×844 y 1280×800, la matriz responsive y Lighthouse móvil ≥95 están verificados y registrados. La decisión de diseño de la confirmación/error, de Compartir como tercer control y de su tratamiento visual neutro **ya fue aprobada por el propietario** y está reflejada en `DESIGN.md` § «Compartir — decisión de diseño aprobada (`redesign-share-action`, 2026-11-23)»; el bloqueo de diseño previo a implementar está **resuelto**. Queda pendiente, como parte de la propia implementación (no como aprobación externa), reconciliar `CONSTRAINTS.md` con esos valores (botón semántico, SVG 11, alcance del gate de `<script>`).

## Non-Goals

- **No** añadir una segunda acción Compartir (la «acción superior duplicada de code.html» **no se incorpora**): el icono decorativo de enlace externo del encabezado (`.profile-open-icon`) sigue ornamental; el gate ya prohíbe envolverlo en un ancla (`init.sh` ~522). Exactamente **un** control Compartir, en la fila de Acciones rápidas.
- **No** implementar el panel QR (`redesign-qr-panel`) ni su «Copiar Enlace»/«Guardar PNG», aunque compartan la misma URL canónica. Esta feature solo entrega Compartir.
- **No** cambiar la vCard estática (`assets/fahedhermoza.vcf`), ni generar la vCard por Blob/`data:`, ni tocar destinos, etiquetas, `aria-label`, iconos ni tonos de Celular/Correo/los cinco Enlaces/Guardar contacto/pie/encabezado.
- **No** usar `location.href`, parámetros de prueba (`?utm`, `?debug`) ni dominios alternativos al compartir/copiar: **siempre** la URL canónica de producción.
- **No** añadir frameworks, bundlers, dependencias, CDN, tokens nuevos ni colores fuera de la paleta. JavaScript propio, mínimo, sin build.
- **No** usar `role="button"` ni manejadores inline (`onclick`/`onkeydown`/`onkeypress`): el control es un `<button type="button">` real con su handler enlazado por `addEventListener`.
- **No** debilitar silenciosamente ningún check de `init.sh` (anclas, SVG decorativos, foco, reduced motion, contraste AA, tap ≥44×44, metadatos de producción, vCard). Todo ajuste de conteo/selector es explícito y equivalente o más fuerte.
- **No** marcar `accepted`: el implementador deja `passing` con evidencia; el validador independiente acepta; la aprobación visual del propietario (incluida la prueba en dispositivo real) es un paso separado.

## Job Story

When abro la Tarjeta digital y quiero pasársela a alguien,
I want tocar una sola acción Compartir que use el menú nativo de mi teléfono o, si no existe, copie el enlace y me confirme que se copió,
so I can difundir mi tarjeta con el enlace correcto sin copiar la URL a mano ni dudar si funcionó.

## Users And Permissions

- Visitante anónimo con JS: ve el círculo Compartir junto a Celular/Correo y lo activa; obtiene hoja nativa o copia + confirmación; sin autenticación ni estado.
- Visitante anónimo sin JS (o con navegador sin `navigator.share` **ni** `navigator.clipboard`): **no** ve ningún control Compartir (permanece oculto); el resto de la Tarjeta funciona igual.
- Propietario/agente: aprueba visualmente la presentación de la confirmación/error y la prueba en dispositivo real; decide la aceptación.
- Implementador/validador: conforma el código a la decisión de diseño ya aprobada en `DESIGN.md`, reconcilia `CONSTRAINTS.md` con esos valores, adapta el gate explícitamente, verifica en navegador + ramas mockeadas + dispositivo real y registra evidencia.

## Acceptance Scenarios

### Scenario 1: Una sola acción Compartir con la URL canónica

Given la Tarjeta servida con JS habilitado,
When se inspecciona la fila de Acciones rápidas,
Then hay **exactamente un** `<button type="button">` Compartir (icono-only, `aria-label` descriptivo, SVG decorativo), dentro de `<nav class="quick-actions">`, junto a las dos anclas Celular/Correo intactas; y el JavaScript que comparte/copia usa la URL canónica `https://fahed-hermoza-card.fahedhermoza.workers.dev/` (derivada del `<link rel="canonical">`, no de `location.href`), sin parámetros de prueba ni destinos alternativos.

### Scenario 2: Web Share API disponible → hoja nativa

Given un navegador con `navigator.share`,
When el visitante activa Compartir (ratón, toque o teclado `Enter`/`Espacio`),
Then se invoca `navigator.share({ url: <canónica> })` (y título opcional) y se abre la hoja nativa; al resolverse no se muestra error ni aparecen mensajes de consola.

### Scenario 3: Web Share API ausente → copia + confirmación visible

Given un navegador sin `navigator.share` pero con `navigator.clipboard.writeText`,
When el visitante activa Compartir,
Then se copia la URL canónica al portapapeles y aparece una **confirmación visible** (región `role="status"`/`aria-live="polite"`, p. ej. «Enlace copiado»); sin errores de consola.

### Scenario 4: Compartir cancelado por el visitante

Given un navegador con `navigator.share` que rechaza con `AbortError` (el usuario cierra la hoja),
When el visitante cancela,
Then **no** se muestra error ni confirmación, **no** se cae a copiar, y la consola queda limpia (el `AbortError` se traga explícitamente, no se re-lanza).

### Scenario 5: Portapapeles denegado → error comprensible

Given un navegador sin `navigator.share` cuyo `clipboard.writeText` rechaza (`NotAllowedError`) o no existe,
When el visitante activa Compartir,
Then aparece un **mensaje comprensible** (mismo `role="status"`/`aria-live`, color `--color-error`) que explica el fallo y **muestra la URL canónica para copiarla manualmente**; sin errores de consola no controlados.

### Scenario 6: Mejora progresiva (sin JS no hay control inerte)

Given la Tarjeta cargada **sin ejecutar JavaScript** (o en un navegador sin Web Share **ni** Clipboard),
When se inspecciona la fila de Acciones rápidas,
Then **no** hay ningún control Compartir visible ni enfocable; el botón permanece oculto (`hidden` por defecto, revelado solo por JS tras detectar soporte) y la Tarjeta no muestra un botón muerto.

### Scenario 7: Accesibilidad, foco, reduced motion y tap target

Given la página con el botón revelado y recorrida con `Tab`, con hover y `prefers-reduced-motion: reduce`,
Then el botón Compartir tiene nombre accesible, `:focus-visible` con `outline: 2px solid var(--color-accent); outline-offset: 2px;`, cumple `min(rect.width, rect.height) >= 44px`, respeta reduced motion (`transition: none`/`transform: none`, reusando el selector `.quick-action`) y su icono/superficie mantienen contraste AA (reutiliza el par neutro pineado `--color-primary` sobre `--color-surface-container-low`, 6.082:1 reposo / 6.456:1 hover).

### Scenario 8: El gate detecta regresiones

Given una copia temporal fuera del repo con (a) el botón Compartir ausente, duplicado o convertido en `<a>`, (b) `role="button"`/handler inline, (c) la URL de compartir con `location.href` o parámetros de prueba, (d) el botón visible por defecto (sin `hidden`/sin control JS), (e) el conteo de SVG decorativos equivocado, o (f) un `<script>`/Blob usado por el mecanismo de vCard,
When se ejecuta `./init.sh`,
Then sale con código 1, imprime el check concreto en stderr y no arranca ningún servidor.

### Scenario 9: Consola, red y Lighthouse limpios

Given la página servida manualmente en `http://localhost:3630/`,
When se carga a 390×844 y 1280×800 y se ejecuta Lighthouse móvil de accesibilidad,
Then la consola muestra 0 mensajes en las cuatro ramas, todas las peticiones responden 2xx/3xx sin `/favicon.ico`, no hay scroll horizontal y la accesibilidad es ≥95 sin auditorías `critical`/`serious`.

## Repository Research

### Files Inspected

- `AGENTS.md`, `CONSTRAINTS.md` — DoD y base AA. `CONSTRAINTS.md` pinea «10 anclas (5 `.link-button` + 2 `.quick-action` + 1 `.save-contact-button` + 2 `.page-footer__link`)», «10 SVG decorativos», reglas de foco/reduced-motion/contraste/tap≥44 y **«MUST NOT add JavaScript… to satisfy accessibility rules»** (prohibición de JS para accesibilidad; esta feature añade JS para *comportamiento de compartir*, no para cumplir reglas AA — ver «Risks And Open Questions»). `CONSTRAINTS.md` todavía **no** refleja la decisión aprobada en `DESIGN.md` (botón semántico, SVG 11, alcance del gate de `<script>`); eso es tarea del implementador, no una decisión de diseño pendiente.
- `DESIGN.md` — § rediseño 2026-11-21 ya describe el comportamiento de Compartir (hoja nativa; si no, copia + confirmación; «respuesta comprensible cuando el portapapeles no permita copiar»; «JavaScript mínimo solo para las nuevas interacciones»). La subsección «slice implementado» de `redesign-contact-navigation` quedó **reconciliada**: ya no dice «solo dos controles»; ahora documenta que la fila hospeda Celular, Correo y, desde `redesign-share-action`, Compartir como tercer control (`<button>` semántico de mejora progresiva). Además, `DESIGN.md` § «Compartir — decisión de diseño aprobada (`redesign-share-action`, 2026-11-23)» fija los valores exactos de la confirmación/error (ver «Approved Design Decision» más abajo).
- `index.html` — `<nav class="quick-actions" aria-label="Acciones rápidas">` con dos anclas `.quick-action` (Celular `tel:`, Correo `mailto:`); `<link rel="canonical" href="https://fahed-hermoza-card.fahedhermoza.workers.dev/">`; **sin `<script>`**. Encabezado con `.profile-open-icon` decorativo.
- `styles.css` — `.quick-actions` (flex, wrap, center, gap `space-md`), `.quick-action` (48×48, `border:0`, `radius-full`, fondo `--color-surface-container-low`, color `--color-primary`, sombra, transición), `.quick-action__icon` (20×20), hover `@media (hover:hover)`, `.quick-action:focus-visible` (outline acento), bloque `@media (prefers-reduced-motion: reduce)` con `.quick-action`. `--color-error: #ba1a1a` ya existe como token.
- `init.sh` (2355 líneas) — gates relevantes, ver «Current Gaps».
- `docs/specs/redesign-contact-navigation.md` — contrato de la fila de Acciones rápidas y patrón de verificación sobre el que se construye.

### Existing Patterns To Follow

- HTML estático, CSS plano, tokens de `DESIGN.md`, SVG inline, assets en `assets/`.
- Gate aditivo no bloqueante (`awk`/`grep`), `[ok]`/`FAILED - …` a stderr, `exit 1`, sin servidor por defecto (opt-in `RUN_SERVE_COMMAND=1`).
- Verificación con `python3 -m http.server <puerto> --directory .`, Chrome DevTools 390×844 y 1280×800, Lighthouse móvil, casos negativos en copias temporales fuera del repo.
- `PRODUCTION_ORIGIN`/`PRODUCTION_URL` ya centralizan la URL canónica (`init.sh` ~11-12); `canonical`/`og:url` están pineados byte-idénticos a `PRODUCTION_URL` (gate ~1255). El JS debe tomar la URL del `<link rel="canonical">`, cerrando el círculo sin una segunda fuente de verdad.

### Current Gaps

- No existe ningún control Compartir, ningún `<button>`, ni JavaScript.
- **Bloqueador de gate (crítico):** `init.sh` ~1648 ejecuta `grep -qE 'data:text/vcard|<script|new Blob' index.html styles.css` sobre **todo** el archivo; cualquier `<script>` (inline o `<script src>`) hace `exit 1`. Debe **reencuadrarse** para prohibir `<script>`/Blob/`data:text/vcard` solo en el **mecanismo de la vCard** (bloque `.save-contact`), conservando esa protección y permitiendo el único script de Compartir.
- El gate de SVG decorativos (~1903/1910) exige **exactamente 10**; el icono del botón Compartir lo lleva a **11**.
- El gate de anclas (~1813-1876) exige 10 anclas / 2 `.quick-action` anclas: se mantiene (Compartir es `<button>`, no ancla), pero falta un check del **botón** Compartir (exactamente 1, `type="button"`, `aria-label`, `hidden` por defecto, SVG decorativo, sin `href`).
- No hay gate que ate la URL de compartir a la canónica ni que verifique la mejora progresiva (`hidden` por defecto) ni la ausencia de parámetros de prueba.
- No existe E2E persistente; añadirlo introduciría dependencias prohibidas. Cobertura = `init.sh` + navegador (incl. ramas mockeadas) + dispositivo real + Lighthouse.

## Technical Approach

### Estructura HTML (`index.html`)

1. Añadir, como **tercer** control dentro de `<nav class="quick-actions">` (después de Correo), un botón:
   `<button type="button" class="quick-action quick-action--share" aria-label="Compartir esta tarjeta" hidden>` con un SVG decorativo `class="quick-action__icon"` (`aria-hidden="true"` + `focusable="false"`, 20×20, `currentColor`). El atributo `hidden` garantiza que **sin JS no se muestra**. Sin `href`, sin `onclick`, sin `role`.
2. Añadir una **región de estado** para la confirmación/error (mejora progresiva, también `hidden` por defecto y revelada/poblada por JS), p. ej. `<p class="share-status" role="status" aria-live="polite" hidden></p>` ubicada bajo la fila de Acciones rápidas. Su tratamiento visual exacto **ya fue aprobado por el propietario** (ver «Approved Design Decision» más abajo): línea de estado inline, `role="status"` + `aria-live="polite"`, tipografía `body-sm`, color `--color-accent` (`#585ce5`) para la confirmación de éxito y `--color-error` (`#ba1a1a`) para el error, mostrando la URL canónica en texto cuando la copia falle.
3. Cargar el script de mejora: recomendado `<script src="share.js" defer></script>` al final del `<body>` (alternativa equivalente: un bloque `<script>` mínimo al final del `<body>`). No es un manejador inline; `CONSTRAINTS.md` solo prohíbe atributos de evento inline y `role="button"`, no un `<script>` que use `addEventListener`.

### JavaScript (`share.js` o bloque inline, mínimo, sin dependencias)

- Al cargar: detectar soporte. Si **no** hay `navigator.share` **ni** `navigator.clipboard?.writeText`, dejar el botón `hidden` (no revelar). Si hay al menos uno, quitar `hidden` y enlazar `click` con `addEventListener`.
- URL: `const url = document.querySelector('link[rel="canonical"]').href;` (canónica de producción; **no** `location.href`, sin parámetros).
- Al activar:
  - Si existe `navigator.share`: `await navigator.share({ title: document.title, url })`. Envolver en `try/catch`; si el error es `AbortError` (cancelación), **no hacer nada** (ni error ni fallback); otros errores pueden caer a la copia o a un error comprensible según criterio documentado.
  - Si no existe `navigator.share` pero sí `clipboard.writeText`: `await navigator.clipboard.writeText(url)` → poblar la región de estado con la confirmación visible y revelarla.
  - Si la copia rechaza o no está disponible: poblar la región con el **error comprensible** + la URL para copiar a mano (estilo `--color-error`).
- No registrar errores en consola por ramas esperadas (cancelación, denegación): capturarlas y manejarlas.
- Mantener el script < ~40 líneas, sin polyfills ni dependencias.

### Cuidado de layout: ocultar por defecto de forma robusta

El atributo `hidden` (UA `display:none`) puede ser **sobrescrito** por `.quick-action { display:flex }` (mayor especificidad). El CSS **debe** garantizar el ocultamiento por defecto, p. ej. `.quick-action[hidden], .share-status[hidden] { display: none; }` (o usar una clase `--ready` que JS añada y CSS `:not(.quick-action--ready){display:none}`). Verificar en navegador que sin JS el botón **no** ocupa espacio ni es enfocable.

### CSS (`styles.css`)

- Reusar `.quick-action` para la forma, el foco, el hover y el reduced motion (el botón lleva la clase `quick-action`, así que las reglas `.quick-action`, `.quick-action:hover`, `.quick-action:focus-visible` y la entrada de reduced motion ya lo cubren). Añadir solo `cursor: pointer;` y cualquier reset menor del `<button>` (`font: inherit;`, `appearance: none;`) que haga falta para igualar a las anclas.
- Añadir la regla de ocultamiento robusto (arriba) y la regla de la región `.share-status`: tipografía `body-sm` (token existente), color `--color-accent` (`#585ce5`) para la confirmación de éxito y `--color-error` (`#ba1a1a`) para el error — valores **fijados y aprobados** en `DESIGN.md` § «Compartir — decisión de diseño aprobada (`redesign-share-action`, 2026-11-23)», sin margen de elección para el implementador.
- No alterar `.quick-action` base, `.link-button`, `.save-contact-button`, el pie ni el encabezado salvo lo imprescindible.

### Cambios en `init.sh` (explícitos, sin debilitar)

1. **Reencuadrar el gate de `<script>`/Blob (~1648):** cambiar el `grep` global por uno acotado al bloque `.save-contact` (`$SAVE_CONTACT_BLOCK`) para `data:text/vcard|<script|new Blob`; así la vCard sigue sin JS/Blob, pero el script de Compartir queda permitido. Mantener el mensaje de fallo de la vCard.
2. **Botón Compartir (nuevo check, en «Link checks» o sección propia «Share checks»):** dentro de `$QUICK_ACTIONS_BLOCK`, exigir **exactamente un** `<button … type="button" … class="quick-action quick-action--share" …>` con `aria-label` no vacío, atributo `hidden`, sin `href`, sin `role="button"`, sin `on*=` inline, y un `<svg class="quick-action__icon" … aria-hidden="true" … focusable="false">`.
3. **Mejora progresiva:** verificar que el botón Compartir trae `hidden` en el HTML estático y que el CSS lo oculta por defecto (regla `[hidden]`/`--ready`); y que existe el script (`share.js` o bloque) que lo revela.
4. **URL canónica en el script:** verificar que el script toma la URL del `link[rel="canonical"]` (o, si se opta por literal, que es byte-idéntica a `PRODUCTION_URL`) y que **no** usa `location.href` ni cadenas con `?`/`utm`/`debug` como destino de compartir.
5. **SVG decorativos:** cambiar el total esperado **10 → 11** (~1903) y el mensaje (~1910); mantener la exigencia de `aria-hidden="true"` + `focusable="false"` en los 11.
6. **Conteo de anclas:** sin cambios (sigue 10 anclas, 2 `.quick-action` anclas, 1 save-contact, 2 footer); confirmar que el botón Compartir **no** se cuenta como ancla ni rompe `quick_action_class_total` (su clase es `quick-action quick-action--share`, que `grep -oE 'class="quick-action"'` no matchea).
7. **Foco / reduced motion / tap ≥44:** cubiertos al reusar `.quick-action` (reglas existentes); añadir, si se desea, una aserción de que el botón comparte la clase `quick-action` para heredar esos contratos.
8. **Mantener intactos** los gates de metadatos de producción, vCard (asset/coherencia/posición), encabezado, pie, orden/tono de Enlaces, contraste (15/15) y responsive. Conservar el servidor opt-in. El hint interno sigue en 3601; la verificación manual de esta worktree usa **3630**.

## Expected File Changes

- `index.html` — modificar; añadir el `<button class="quick-action quick-action--share" type="button" hidden>` + SVG, la región `.share-status`, y el `<script>`/`<script src="share.js" defer>`.
- `share.js` — crear (si se opta por externo); mejora mínima sin dependencias (detección de soporte, share/clipboard, manejo de las 4 ramas). Alternativa: bloque `<script>` inline en `index.html`.
- `styles.css` — modificar; ocultamiento robusto por defecto, reset menor del `<button>`, regla `.share-status` (según diseño aprobado); reusar `.quick-action` para forma/foco/hover/reduced-motion.
- `init.sh` — modificar; reencuadrar el gate de `<script>`/Blob a la vCard, añadir checks del botón Compartir + mejora progresiva + URL canónica, subir SVG 10→11; no debilitar nada.
- `DESIGN.md` — **no se modifica**: ya documenta la fila de Acciones rápidas con tres controles (Celular, Correo, Compartir), Compartir como `<button>` semántico (mejora progresiva) y la presentación de la confirmación/error aprobada por el propietario. El implementador **conforma el código a `DESIGN.md`**, no al revés.
- `CONSTRAINTS.md` — **actualizar (con la misma decisión)**: permitir `<button type="button">` semántico para acciones dentro de la página (manteniendo la prohibición de `role="button"` y handlers inline), re-expresar «10 SVG decorativos» → «11», acotar la prohibición de `<script>`/Blob al mecanismo de vCard, y fijar la regla «la URL de compartir es siempre la canónica de producción».
- `feature_list.json`, `PROGRESS.md` — el implementador registra `passing` + evidencia y sesión; el validador crea `docs/validations/redesign-share-action.md`.
- `docs/specs/redesign-share-action.md` — este spec (no es código de producto).

## Visual Design Impact

- UI involved: yes. Design source: `DESIGN.md` § «Dirección del rediseño acordado (2026-11-21)» y § «Social Icon Bar».
- Estados afectados: fila de Acciones rápidas (añade el círculo Compartir, mismo tratamiento neutro que Celular/Correo), y una nueva **región de estado** (confirmación/error) bajo la fila; estados reposo/hover/foco/reduced-motion; 390×844, 1280×800 y los ocho anchos.
- New design artifact required: no. El **control** reusa el par neutro pineado y la geometría de `.quick-action`, ya cubiertos por `DESIGN.md`/contraste 15/15. La **confirmación/error** tampoco requiere artefacto nuevo: su tratamiento visual quedó **fijado y aprobado por el propietario** (ver «Approved Design Decision» abajo).

## Approved Design Decision (ya resuelta; no bloquea la implementación)

`DESIGN.md` es fuente de verdad de solo lectura; el planner no inventa valores. Las tres decisiones de diseño que bloqueaban esta feature (presentación de la confirmación/error, Compartir como tercer control, tratamiento visual neutro) **ya fueron aprobadas por el propietario** y están documentadas en `DESIGN.md` § «Compartir — decisión de diseño aprobada (`redesign-share-action`, 2026-11-23)». El implementador conforma el código a esos valores, ya fijados:

1. **Presentación de la confirmación y del error de copia:** una línea de estado inline debajo de la fila de Acciones rápidas, `role="status"` + `aria-live="polite"`. Éxito en color `--color-accent` (`#585ce5`); error en `--color-error` (`#ba1a1a`). Tipografía `body-sm`. Si el portapapeles rechaza la copia, el mensaje de error muestra la URL canónica en texto para que el visitante la copie a mano. (El spec original dejaba abierto si el color de éxito era `--color-on-surface` o `--color-accent`; la decisión aprobada fija definitivamente `--color-accent`.)
2. **Compartir como tercer control de Acciones rápidas, `<button>` semántico:** mejora progresiva (no `<a>`, sin destino de navegación propio); usa la API nativa de compartir cuando existe y, si no, copia la URL canónica al portapapeles; sin JavaScript el control no debe mostrarse. `DESIGN.md` § «Acciones rápidas y Enlaces grandes — slice implementado (`redesign-contact-navigation`, 2026-11-21)» ya quedó reconciliado: ya no dice «solo dos controles»; documenta que la fila hospeda Celular, Correo y Compartir como tercer control.
3. **Tratamiento visual confirmado:** el círculo Compartir reusa el círculo neutro `.quick-action` ya usado por Celular/Correo (superficie `--color-surface-container-low` `#f1f4fa`, icono `--color-primary` `#484dc4`, 48px, `:focus-visible` acento 2px/offset 2px). No introduce color, tono de degradado ni token nuevo.

Lo único que queda pendiente, y es tarea propia del implementador (no una aprobación externa del propietario), es reconciliar `CONSTRAINTS.md` con estos valores ya aprobados: permitir `<button>` semántico para acciones en página (sin `role="button"` ni handlers inline), re-expresar el desglose de SVG decorativos (10 → 11) y acotar la prohibición de `<script>`/Blob al mecanismo de la vCard. El implementador no inventa tratamiento visual ni edita `DESIGN.md`: ese documento ya refleja la decisión aprobada y es de solo lectura para este spec.

## Durable Documentation Impact

- `ARCHITECTURE.md`: not needed — no cambia dominios/runtime/dependencias (no existe; no crear).
- `CONSTRAINTS.md`: update — permitir `<button>` semántico en acciones de página, SVG 10→11, acotar la prohibición de `<script>`/Blob a la vCard, pinear «URL de compartir = canónica de producción», mantener todos los MUST de AA/responsive/producción.
- `AGENTS.md`: not needed — el flujo de arranque, workflow y DoD no cambian (no contiene conteos).
- `DESIGN.md`: not needed — la decisión de diseño (fila de tres Acciones rápidas, Compartir como `<button>` de mejora progresiva, presentación de confirmación/error) **ya está aprobada por el propietario y documentada** en `DESIGN.md` § «Compartir — decisión de diseño aprobada (`redesign-share-action`, 2026-11-23)» y en la subsección reconciliada de `redesign-contact-navigation`. El implementador no edita `DESIGN.md`; solo conforma el código a lo ya escrito ahí.
- `docs/technical-discovery.md`: update si procede — este slice introduce el primer JavaScript del sitio (mínimo, sin dependencias, sin build); registrar que «JS mínimo para interacciones de compartir/QR» está permitido y acotado.
- `docs/risks-and-open-questions.md`: update si procede — la decisión de presentación confirmación/error ya está resuelta (ver `DESIGN.md`); lo que sigue abierto y debe registrarse es el estado de la prueba en dispositivo real y de la aprobación visual del propietario tras la implementación.
- `CONTEXT.md` / `docs/domain-model.md`: not needed — Compartir es presentación de la misma Tarjeta/URL ya modelada.

## Implementation Plan

1. **Bloqueo previo (resuelto):** las decisiones de diseño (confirmación/error, Compartir como tercer `<button>`, tratamiento visual) ya están aprobadas por el propietario y reflejadas en `DESIGN.md` § «Compartir — decisión de diseño aprobada (`redesign-share-action`, 2026-11-23)». No hay bloqueo de diseño pendiente; queda, como tarea propia de la implementación, reconciliar `CONSTRAINTS.md` con esos valores.
2. Confirmar baseline con `bash -n init.sh && ./init.sh` (exit 0) antes de editar.
3. `init.sh` primero (contrato): reencuadrar el gate de `<script>`/Blob a la vCard, añadir checks del botón Compartir + mejora progresiva + URL canónica, subir SVG 10→11.
4. `index.html`: añadir el botón Compartir (`hidden`), la región `.share-status` y el `<script>`/`share.js`.
5. `share.js` (o bloque inline): detección de soporte, share/clipboard, manejo de las 4 ramas, URL desde `link[rel="canonical"]`.
6. `styles.css`: ocultamiento robusto por defecto, reset menor del `<button>`, regla `.share-status` según diseño; reusar `.quick-action`.
7. Ejecutar gate + casos negativos; navegador 390×844/1280×800 con las 4 ramas mockeadas; matriz de ocho anchos; Lighthouse; prueba en dispositivo real. Registrar `passing` + evidencia y solicitar aprobación visual.

## Implementation Tasks

- [ ] Confirmar lectura de `DESIGN.md` § «Compartir — decisión de diseño aprobada (`redesign-share-action`, 2026-11-23)» (ya aprobada; no requiere acción) y actualizar `CONSTRAINTS.md` para reflejar esos valores (confirmación/error; Compartir `<button>` tercer control; SVG 11) como parte de esta implementación.
- [ ] Baseline: `bash -n init.sh && ./init.sh` exit 0.
- [ ] `init.sh`: acotar `<script>`/Blob a la vCard; añadir checks del botón Compartir (1, `type="button"`, `aria-label`, `hidden`, sin `href`/`role`/`on*`, SVG decorativo), mejora progresiva (CSS oculta por defecto + script presente), URL canónica (del `link[rel="canonical"]`, sin `location.href` ni parámetros), SVG 10→11.
- [ ] `index.html`: botón Compartir `hidden` + SVG decorativo dentro de `.quick-actions`; región `.share-status` `role="status"` `aria-live` `hidden`; `<script src="share.js" defer>` (o bloque inline).
- [ ] `share.js`/bloque: detección de soporte (revelar solo si hay `share` o `clipboard`), `navigator.share` con `AbortError` silencioso, fallback `clipboard.writeText` + confirmación, error comprensible con la URL; sin errores de consola en ramas esperadas.
- [ ] `styles.css`: ocultamiento robusto `[hidden]`, reset menor del `<button>` (`cursor`, `font`, `appearance`), regla `.share-status` (tokens; `--color-error` para error) según diseño; reusar `.quick-action`.
- [ ] Gate + casos negativos; navegador 390×844/1280×800 con 4 ramas mockeadas; matriz de ocho anchos; Lighthouse; dispositivo real; registrar `passing` + evidencia; solicitar aprobación visual.

## Verification Plan

- `bash -n init.sh` → sin errores de sintaxis.
- `./init.sh` → exit 0, `Harness status: bootstrapped`, con el nuevo check del botón Compartir, `[ok] … 11 decorative SVG …`, URL canónica y mejora progresiva verdes; anclas siguen 10; `Accessibility checks:` y `Responsive checks:` intactos; **sin** arrancar servidor.
- Casos negativos en copias temporales fuera del repo (borrar después; sin listener): (1) botón Compartir ausente/duplicado/convertido en `<a>` → `exit 1`; (2) `role="button"` o `onclick=` inline en el botón → `exit 1`; (3) script con `location.href` o `?utm`/`?debug` como URL de compartir → `exit 1`; (4) botón sin `hidden` o CSS que no lo oculta por defecto → `exit 1`; (5) SVG decorativos ≠ 11 o sin `aria-hidden`/`focusable` → `exit 1`; (6) `<script>`/`new Blob` dentro del bloque `.save-contact` → `exit 1`. Cada fallo con mensaje `FAILED - …` concreto y sin servidor.
- Servido manual (solo implementador/validador, worktree aislada): `python3 -m http.server 3630 --directory .`; detener y dejar 3630 libre al terminar. El planner no arranca servidores. `curl -sI http://localhost:3630/` y `/styles.css` → 200; `/share.js` → 200 (si externo); log sin 4xx/5xx ni `/favicon.ico`.
- Navegador 390×844 y 1280×800, **las cuatro ramas** (usar DevTools para mockear): 
  - **Disponible:** stub `navigator.share = () => Promise.resolve()` → activar → se invoca con la URL canónica; consola 0; sin confirmación/errores erróneos.
  - **Ausente:** `delete navigator.share` (mantener `clipboard`) → activar → URL copiada + confirmación visible; verificar portapapeles; consola 0.
  - **Cancelada:** `navigator.share = () => Promise.reject(Object.assign(new Error(), {name:'AbortError'}))` → activar → sin error/confirmación, sin fallback, consola 0.
  - **Portapapeles denegado:** sin `share`, `navigator.clipboard.writeText = () => Promise.reject(Object.assign(new Error(),{name:'NotAllowedError'}))` → activar → error comprensible con la URL, consola 0.
  - En todas: `documentElement`/`body` `scrollWidth === clientWidth`; botón con `:focus-visible` por `Tab`; `min(rect.width, rect.height) >= 44px`; reduced motion anula transform/transition.
- **Sin JS:** deshabilitar JavaScript (o servir sin ejecutar el script) → el botón Compartir **no** aparece ni es enfocable; el resto de la Tarjeta intacta; sin scroll horizontal.
- Matriz de ocho anchos (320, 360, 375, 390, 480, 736, 768, 1280 CSS px): sin scroll horizontal, tap ≥44×44 del botón revelado, sin recorte de la región de estado.
- Lighthouse móvil en `http://localhost:3630/`: Accessibility ≥95, sin `critical`/`serious`.
- **Dispositivo real:** en un móvil con Web Share (Android/iOS) confirmar que Compartir abre la hoja nativa con la URL canónica; y en un navegador de escritorio sin Web Share, que copia + confirma. Registrar con honestidad (si solo se emuló/mockeó Chrome, declararlo y dejar la prueba de dispositivo como pendiente del propietario).
- E2E: no existe harness persistente y añadirlo introduciría dependencias prohibidas; cobertura = `init.sh` + navegador (ramas mockeadas) + dispositivo real + Lighthouse.
- `./init.sh` ejecuta el gate estándar no bloqueante; **no** arranca procesos de larga duración y puede imprimir comandos manuales tras pasar los checks.

## Evidence To Capture

- Salida de `bash -n init.sh` y `./init.sh` (nuevos checks de Compartir, 11 SVG, URL canónica, mejora progresiva, exit 0, sin servidor).
- Stderr de cada caso negativo sin listener en 3630.
- Tablas de navegador 390×844 y 1280×800 para las 4 ramas (invocación con URL canónica, confirmación visible, cancelación silenciosa, error comprensible), más el caso sin JS (botón ausente); geometría, foco, tap≥44, reduced motion, consola/red limpias; Lighthouse móvil.
- Diff que prueba vCard, destinos de Celular/Correo/Enlaces, encabezado y pie intactos; una sola acción Compartir; sin segunda acción en el encabezado.
- Confirmación de que la URL compartida/copiada es byte-idéntica a `https://fahed-hermoza-card.fahedhermoza.workers.dev/` (sin parámetros).
- Registro honesto de la prueba en dispositivo real (realizada o pendiente) y de la **solicitud de aprobación visual del propietario**; si falta, `owner visual review: pending` y **no** marcar `accepted`.

## Validator Checklist

- [ ] Exactamente **una** acción Compartir, `<button type="button">` icono-only en `<nav class="quick-actions">`, sin segunda acción en el encabezado ni control inerte sin JS.
- [ ] Las cuatro ramas se comportan según spec: hoja nativa con URL canónica; fallback copia + confirmación visible; cancelación (`AbortError`) silenciosa; portapapeles denegado → error comprensible con la URL; consola 0 en todas.
- [ ] Mejora progresiva real: `hidden` por defecto + CSS que lo oculta; revelado solo tras detectar `navigator.share`/`clipboard`; sin JS no aparece.
- [ ] URL **siempre** canónica de producción (del `link[rel="canonical"]`), sin `location.href` ni parámetros; vCard estática intacta; sin tokens/colores/fuentes/dependencias nuevos.
- [ ] `init.sh`/`CONSTRAINTS.md` adaptados **explícitamente** (botón Compartir, SVG 11, `<script>`/Blob acotado a la vCard, URL canónica, mejora progresiva) sin debilitar anclas, foco, reduced motion, contraste, tap≥44, metadatos ni responsive.
- [ ] `DESIGN.md` documenta Compartir (tercer control, `<button>` de mejora progresiva) y la presentación confirmación/error, aprobadas por el propietario antes de implementar (§ «Compartir — decisión de diseño aprobada», 2026-11-23); el código implementado usa exactamente esos valores (`--color-accent` para éxito, `--color-error` para error, `body-sm`, URL canónica en el error).
- [ ] `./init.sh` sale 0 sin servidor y detecta todos los casos negativos; navegador 390×844/1280×800 + ocho anchos sin scroll horizontal; Lighthouse móvil ≥95 sin `critical`/`serious`; prueba en dispositivo real registrada; aprobación visual del propietario solicitada y, si falta, no `accepted`.

## Risks And Open Questions

- **Primer JavaScript del repo.** `CONSTRAINTS.md` prohíbe «añadir JavaScript… para satisfacer reglas de accesibilidad»; aquí el JS es para *comportamiento de compartir*, no para AA, y la base AA se mantiene sin JS. La redacción de `CONSTRAINTS.md`/`docs/technical-discovery.md` debe aclarar este límite; el implementador la actualiza como parte de la implementación (no requiere nueva aprobación del propietario: el límite ya está implícito en la decisión aprobada en `DESIGN.md`).
- **Presentación confirmación/error:** decisión de diseño **ya resuelta y aprobada** (ver «Approved Design Decision»): línea de estado inline `aria-live="polite"` con tokens existentes, `--color-accent` para éxito y `--color-error` para error. No introducir un toast con geometría/animación nuevas: eso no fue lo aprobado y además rompería reduced motion.
- **Pitfall de `[hidden]`:** `.quick-action { display:flex }` puede anular el atributo `hidden`; el CSS debe ocultar explícitamente por defecto. Verificar en navegador sin JS.
- **Pruebas de ramas:** `navigator.share`/`clipboard` dependen de contexto seguro y gesto de usuario; en `localhost` (contexto seguro) se mockean deterministamente en DevTools, pero la hoja nativa real exige dispositivo real — declarar con honestidad qué se emuló.
- **Puerto 3630 vs hint 3601 de `init.sh`:** la verificación manual de esta worktree usa 3630; el hint interno de `init.sh` permanece en 3601 y no es parte del alcance cambiarlo.
- **Aprobación visual del propietario (móvil + escritorio) y prueba en dispositivo real** bloquean la aceptación final, no la implementación/prueba local.
