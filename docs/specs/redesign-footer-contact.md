# Feature Implementation Spec: Nuevo pie de contacto

## Source Feature

- `id`: `redesign-footer-contact`
- `area`: `contact`
- `depends_on`: `redesign-contact-navigation` (accepted), `page-footer` (accepted)
- `status`: `passing` (implementación base del pie ya hecha y evidenciada; este spec cubre un **ajuste post-passing** sobre ese pie, no una planificación desde cero)
- `source`: `feature_list.json` (`user_visible_behavior`, `verification`, `notes`); `DESIGN.md` § «Dirección del rediseño acordado (2026-11-21)» (jerarquía/composición objetivo, líneas 446-461, ya implementada); `DESIGN.md` § «Pie — decisión de diseño aprobada (`redesign-footer-contact`, 2026-11-22)» (líneas 522-537) — **los 3 ajustes de este slice ya están aprobados por el propietario ahí; esa sección es de solo lectura, no se edita en este trabajo.**

## Alcance de este ajuste (post-passing, 2026-11-22)

El pie ya implementado (invitación + enlace WhatsApp + «Tarjeta NFC & QR», ver resto del spec) recibió revisión visual del propietario, quien aprobó **3 ajustes concretos** sobre esa base, fijados en `DESIGN.md` líneas 522-537 y **no** reabre nada más del pie ni del resto de la Tarjeta:

1. **Enlace «escríbeme directamente»:** pasa a **negrita** (mismo peso que las etiquetas de Enlace, es decir `font-weight: var(--text-button-label-font-weight)` = `800`, sin introducir token nuevo) y **sin subrayado** (`text-decoration: none`); conserva `color: var(--color-accent)` y `.page-footer__link:focus-visible` (`outline: 2px solid var(--color-accent); outline-offset: 2px;`) intactos.
2. **«Tarjeta NFC & QR» en línea/bloque propio:** deja de ir en el mismo `<p class="page-footer__text">` que la invitación, unido por `<span class="page-footer__separator" aria-hidden="true">·</span>`; pasa a un bloque/línea independiente debajo del párrafo de invitación. El separador `·` (`.page-footer__separator`) **se retira por completo** del pie — ya no se usa en ningún lugar del `<footer>`.
3. **Nuevo ícono SVG inline** (decorativo, `aria-hidden="true"` `focusable="false"` `stroke="currentColor"` `stroke-width="2"`, outline simple estilo tarjeta/chip NFC, mismo lenguaje visual que los demás SVG de la Tarjeta) colocado a la izquierda del texto «Tarjeta NFC & QR», en la nueva línea independiente. Sin librería de iconos externa ni asset nuevo en `assets/`: el SVG va inline en `index.html`.

Tras este ajuste la feature **permanece en `passing`**, no pasa a `accepted`: la aprobación visual final completa del propietario (móvil + escritorio) sigue pendiente aparte de estos 3 puntos ya aprobados. El implementador **no** toca `DESIGN.md` bajo ningún concepto en este ajuste; si detecta que falta una decisión de diseño adicional no cubierta por las líneas 522-537, debe **detenerse y reportar el bloqueo** en vez de inventar el detalle o editar `DESIGN.md`.

## Goal

Sustituir el contenido del pie actual (correo `mailto:` + Handle de Instagram, separados por `·`) por el pie del rediseño: una **invitación** «¿Tienes un proyecto en mente? Haz clic en mis redes o escríbeme directamente», donde el texto final **«escríbeme directamente» enlaza al WhatsApp canónico** (`https://wa.me/51955116562`); el botón **«Guardar contacto»** se mantiene como acción discreta que **sigue descargando la vCard estática** (`<a href="assets/fahedhermoza.vcf" download="fahedhermoza.vcf">`, sin Blob ni JavaScript); y el pie **cierra con «Tarjeta NFC & QR»**. Correo deja de aparecer en el pie: su destino sigue disponible en la fila de Acciones rápidas aceptada en `redesign-contact-navigation`.

El slice termina cuando la estructura, los contratos de pie/vCard de `init.sh` y `CONSTRAINTS.md`, el navegador 390×844 y 1280×800, la matriz de ocho anchos y Lighthouse móvil Accessibility ≥95 están verificados y registrados. La aceptación final requiere además la **revisión visual fechada del propietario (móvil + escritorio)**, igual que los slices anteriores del rediseño.

**Ajuste post-passing (2026-11-22):** sobre ese pie ya `passing`, el implementador aplica únicamente los 3 puntos de «Alcance de este ajuste» (negrita sin subrayado en el enlace, «Tarjeta NFC & QR» en línea propia sin separador, nuevo ícono SVG a su izquierda), re-verifica los mismos gates/navegador/Lighthouse, y deja la feature en `passing` con evidencia actualizada. No se marca `accepted` en este ajuste.

## Non-Goals

- **No** implementar el panel QR (`redesign-qr-panel`) ni la acción Compartir (`redesign-share-action`). «Tarjeta NFC & QR» es **texto descriptivo de cierre**, no un control interactivo ni un placeholder con `role`/`aria` que finja la vista QR.
- **No** cambiar la fila de Acciones rápidas, los cinco Enlaces grandes ni el encabezado ornamental aceptados en features previas; solo se reescribe el interior de `<footer class="page-footer">` (más, si una decisión de diseño lo fija, la presentación discreta de Guardar contacto).
- **No** alterar los datos de la vCard `assets/fahedhermoza.vcf` (nombre, `TEL`, `EMAIL`, cinco `URL:`, VCARD 3.0, CRLF, UTF-8 sin BOM, ≤4096 bytes) ni el mecanismo de descarga `<a download>`.
- **No** generar la vCard por Blob/`data:text/vcard`/`<script>`/handler inline; **no** convertir Guardar contacto en un control no semántico.
- **No** añadir tokens, colores fuera de la paleta pineada, fuentes, frameworks, bundlers, dependencias, assets generados ni JavaScript. Mantener un solo `<h1>` y `lang="en"` en la Tagline.
- **No** debilitar silenciosamente ningún check AA de `init.sh` (anclas reales, iconos decorativos, foco, reduced motion, contraste AA, tap≥44×44). Todo ajuste de conteo/selector es **explícito** y de cobertura equivalente o mayor.
- **No** tocar los metadatos Open Graph / producción ni `assets/og-image.jpg` (son de `redesign-social-preview`).
- **No** marcar `accepted`: el implementador deja `passing` con evidencia; el validador independiente acepta; la aprobación visual del propietario es un paso separado.
- **No** reabrir ni modificar nada fuera de los 3 ajustes de «Alcance de este ajuste» (no tocar Guardar contacto, Acciones rápidas, Enlaces, encabezado, vCard, metadatos Open Graph, ni el texto/destino de la invitación o del enlace WhatsApp).
- **No** editar `DESIGN.md` de ninguna manera (ni la sección del addendum ni ninguna otra). Si falta una decisión de diseño adicional no cubierta por las líneas 522-537, **detenerse y reportar el bloqueo**.

## Job Story

When termino de ver las redes y las acciones rápidas de la Tarjeta,
I want un pie que me invite a escribir directamente por WhatsApp, me deje guardar el contacto y me recuerde la Tarjeta NFC & QR,
so I can pasar a la conversación o guardar los datos sin perder el canal correcto ni la descarga de la vCard.

## Users And Permissions

- Visitante anónimo: lee la invitación, activa «escríbeme directamente» (WhatsApp), «Guardar contacto» (descarga vCard) y ve «Tarjeta NFC & QR»; sin autenticación ni estado.
- Propietario/agente: fija la presentación del pie editando solo `index.html`/`styles.css`; aprueba visualmente (móvil + escritorio) y las decisiones de diseño abiertas (ver «Decisiones de diseño»).
- Implementador/validador: adapta el gate explícitamente, verifica en navegador y registra evidencia; no implementa QR/Compartir/imagen social.

## Decisiones de diseño (histórico — ya resueltas; estado actual)

Esta sección documenta cómo se resolvieron las decisiones de diseño del slice original y cómo quedan tras el ajuste post-passing. **No** hay decisiones nuevas pendientes de resolver en este ajuste: las 3 de «Alcance de este ajuste» ya están aprobadas en `DESIGN.md` líneas 522-537 (de solo lectura).

1. **Presentación de «Guardar contacto».** Se conservó intacta (contrato `save-contact-vcard`: botón neutro `#f1f4fa`/`#484dc4`, 48px, ancho completo, entre Enlaces y pie). **Sin cambios en este ajuste.**
2. **«Tarjeta NFC & QR»: texto solo o con iconos.** Resuelto originalmente como texto solo (conteo de SVG decorativos quedó en **10**). El ajuste post-passing lo revierte: ahora lleva **un** ícono SVG decorativo nuevo a su izquierda (ver punto 3 de «Alcance de este ajuste»), por lo que el conteo pasa de **10 a 11**. Sigue sin ser un control interactivo ni un placeholder de la vista QR.
3. **Separador del pie.** Se implementó inicialmente conservando `<span class="page-footer__separator" aria-hidden="true">·</span>` uniendo la invitación con el cierre en el mismo `<p>`. El ajuste post-passing lo **retira por completo**: «Tarjeta NFC & QR» pasa a su propia línea/bloque y el `·` deja de usarse en cualquier parte del pie.
4. **Color del texto «Tarjeta NFC & QR».** Reusa un token ya pineado con contraste AA (`--color-on-surface` #2d3139 13.044:1 o `--color-on-surface-variant` #6b7280 ≥4.5:1). **Sin cambios en este ajuste**; no se introduce color nuevo.
5. **(Nuevo, ajuste post-passing) Estilo del enlace «escríbeme directamente».** Pasa de subrayado a negrita sin subrayado (ver punto 1 de «Alcance de este ajuste»); conserva `--color-accent` y su `:focus-visible`.

El enlace «escríbeme directamente» reusa `.page-footer__link` (`--color-accent` #585ce5, 5.15:1 AA sobre blanco), ya gated; el ajuste de negrita/sin-subrayado no requiere nueva decisión de color ni token nuevo.

## Acceptance Scenarios

### Scenario 1: Invitación con WhatsApp canónico, enlace en negrita sin subrayado

Given la Tarjeta servida a 390×844 o 1280×800,
When se inspecciona `<footer class="page-footer">`,
Then contiene el texto de invitación «¿Tienes un proyecto en mente? Haz clic en mis redes o escríbeme directamente», donde «escríbeme directamente» es un `<a class="page-footer__link" href="https://wa.me/51955116562">` real (nombre accesible que contiene el texto visible); y el pie **ya no** contiene el enlace `mailto:` de correo ni el enlace al Handle de Instagram. **(Ajuste post-passing)** El enlace se renderiza en **negrita** (`font-weight: var(--text-button-label-font-weight)` = `800`) y **sin subrayado** (`text-decoration: none`), conservando `color: var(--color-accent)` en reposo y el `outline: 2px solid var(--color-accent); outline-offset: 2px;` en `:focus-visible`.

### Scenario 2: Guardar contacto sigue descargando la vCard estática

Given la página servida,
When se inspecciona el control «Guardar contacto»,
Then sigue siendo exactamente un `<a class="save-contact-button" href="assets/fahedhermoza.vcf" download="fahedhermoza.vcf">` con su etiqueta «Guardar contacto» e icono SVG decorativo; **no** usa `data:text/vcard`, Blob, `<script>` ni handler inline; y `assets/fahedhermoza.vcf` queda byte-idéntico (nombre, `TEL`, `EMAIL`, cinco `URL:`, VCARD 3.0, CRLF, UTF-8 sin BOM, ≤4096 bytes).

### Scenario 3: Cierre «Tarjeta NFC & QR» en línea propia con ícono, sin separador `·`

Given el pie renderizado,
When se lee su contenido,
Then aparece el texto «Tarjeta NFC & QR» (`Tarjeta NFC &amp; QR` en el HTML) como cierre descriptivo, sin ser un control interactivo ni anunciar la vista QR. **(Ajuste post-passing)** «Tarjeta NFC & QR» ya **no** comparte el `<p class="page-footer__text">` de la invitación: vive en su propio bloque/línea debajo de ese párrafo, precedido por un `<svg>` decorativo nuevo (`aria-hidden="true"` `focusable="false"` `stroke="currentColor"` `stroke-width="2"`, outline tipo tarjeta/chip NFC) a su izquierda; el `<span class="page-footer__separator" aria-hidden="true">·</span>` **ya no existe** en ningún lugar del `<footer>` (ni entre la invitación y el cierre, ni en ninguna otra posición).

### Scenario 4: Resto de la Tarjeta sin cambios

Given el documento servido,
When se comparan encabezado, Acciones rápidas y Enlaces con el estado previo,
Then el encabezado ornamental, la fila `<nav class="quick-actions">` (Celular `tel:` + Correo `mailto:`) y los cinco `.link-button` (Instagram→Portafolio, gradient-1..4) quedan intactos; el único `<h1>` y la Tagline con `lang="en"` se conservan; la duplicación transitoria de Correo (pie + Acciones rápidas) **desaparece** porque el pie deja de repetir el correo.

### Scenario 5: Accesibilidad, foco, reduced motion y contraste

Given la página recorrida con `Tab`, con hover y `prefers-reduced-motion: reduce`,
Then hay **9 anclas reales** (5 `.link-button` + 2 `.quick-action` + 1 `.save-contact-button` + 1 `.page-footer__link`, **sin cambio** por este ajuste — ningún control ancla se añade/retira), todas con `href` no vacío y sin `role="button"`/handlers inline/`href="#"`; el enlace del pie y Guardar contacto muestran `outline: 2px solid var(--color-accent); outline-offset: 2px;` al enfocar; con movimiento reducido no hay `transition`/`transform` activos en los controles animados; el texto del pie cumple contraste ≥4.5:1 (enlace #585ce5 5.15:1 en negrita sin subrayado, texto #2d3139 13.044:1) en reposo y en `brightness(1.03)`. El enlace inline del pie queda bajo la excepción WCAG 2.5.8 (enlace dentro de texto); al perder el subrayado, su distinción como enlace pasa a depender de la negrita + el color de acento, ambos ya verificados contra WCAG 1.4.1 (uso de color) porque no es el único medio distintivo.

### Scenario 6: El gate detecta regresiones

Given una copia temporal fuera del repo con (a) «escríbeme directamente» sin `href` al WhatsApp canónico o apuntando a otro destino, (b) Guardar contacto convertido en Blob/`<script>`/no-anchor o con `href`/`download` roto, (c) el texto de invitación o «Tarjeta NFC & QR» ausente, (d) el conteo de anclas o de SVG decorativos alterado, (e) foco/reduced motion/contraste roto, (f) **(ajuste post-passing)** el `.page-footer__link` reaparece con `text-decoration: underline` o sin `font-weight` en negrita, (g) **(ajuste post-passing, cubierto por gate solo si el implementador añade un assert dedicado; si no, cubierto por revisión manual en navegador)** el `<span class="page-footer__separator">` reaparece en cualquier parte del `<footer>`, o (h) **(ajuste post-passing)** el nuevo `<svg>` del cierre pierde `aria-hidden="true"` o `focusable="false"`, o el conteo total de SVG decorativos no es 11,
When se ejecuta `./init.sh`,
Then sale con código 1, imprime el check concreto en stderr y no arranca ningún servidor.

### Scenario 7: Consola, red y Lighthouse limpios

Given la página servida manualmente en `http://localhost:<puerto>/`,
When se carga a 390×844 y 1280×800 y se ejecuta Lighthouse móvil de accesibilidad,
Then la consola muestra 0 mensajes, todas las peticiones responden 2xx/3xx sin `/favicon.ico`, no hay scroll horizontal en los ocho anchos y la accesibilidad es ≥95 sin auditorías `critical`/`serious`.

## Repository Research

### Files Inspected (estado actual, post-implementación base, antes del ajuste)

- `AGENTS.md`, `CONSTRAINTS.md` — `CONSTRAINTS.md` pinea hoy «exactly 9 anchors (5 `.link-button` + 2 `.quick-action` + 1 `.save-contact-button` + 1 `.page-footer__link`)» (líneas 28-32), «exactly 10 decorative SVG icons today (5 Enlaces + 2 quick-action icons + the save contact icon + 2 header icons) … and the footer separator with `aria-hidden="true"`» (líneas 54-57), y la excepción WCAG 2.5.8 de «the one inline footer link (WhatsApp)» (líneas 77-79, 106-107).
- `DESIGN.md` — § rediseño 2026-11-21 (líneas 446-461, implementada); § «Pie — decisión de diseño aprobada (`redesign-footer-contact`, 2026-11-22)» (líneas 522-537) — fuente de los 3 ajustes de este slice, **no editable**. Tokens pineados relevantes: `--color-accent` #585ce5, `--color-on-surface` #2d3139, `--text-button-label-font-weight` 800.
- `index.html` — pie actual (líneas 130-136): un único `<p class="page-footer__text">` con la invitación + `<a class="page-footer__link" href="https://wa.me/51955116562">escríbeme directamente</a>` + `<span class="page-footer__separator" aria-hidden="true">·</span>` + el texto «Tarjeta NFC &amp; QR», todo en el mismo párrafo. Guardar contacto (`.save-contact` → `.save-contact-button`) entre `</nav>` y `<footer>`, sin cambios.
- `styles.css` — `.page-footer` (línea 471), `.page-footer__text` (483), `.page-footer__link` (487: `color: var(--color-accent); text-decoration: underline; text-underline-offset: 2px;`), `.page-footer__link:focus-visible` (493), `.page-footer__separator` (498: `margin: 0 var(--space-xs);`).
- `init.sh` — gates relevantes para este ajuste: bloque `<footer>…</footer>` extraído por `awk` (líneas 686-730, «Page footer destinations»); contrato `PAGE_FOOTER_LINK_CONTRACT` en líneas 782-808 — hoy exige literalmente `'text-decoration: underline;'` entre sus 3 declaraciones obligatorias (línea 784), lo que **hay que cambiar** porque el ajuste retira el subrayado; conteo «9 real anchor controls» (línea 1902, sin cambios en este ajuste); bloque de SVG decorativos (líneas 1904-1939): `svg_total` debe ser exactamente 10 hoy (línea 1929) y el gate acopla el mensaje de éxito con la existencia de `.page-footer__separator` con `aria-hidden="true"` (líneas 1935-1939) — **ambos deben actualizarse** (conteo a 11, separador ya no existe).
- `docs/risks-and-open-questions.md` línea 104 — registra el slice original (separador conservado, SVG sin cambio); hay que actualizarlo para reflejar el ajuste.
- `docs/specs/redesign-contact-navigation.md`, `docs/specs/page-footer.md`, `docs/specs/save-contact-vcard.md` — contratos sobre los que se construyó el slice original; sin cambios por este ajuste.

### Existing Patterns To Follow

- HTML estático, CSS plano, BEM-ish, color/tipografía/espaciado solo por tokens; iconos SVG inline; assets en `assets/`.
- Gate aditivo no bloqueante con `awk`/`grep`: extraer el bloque relevante (p. ej. `<footer>`…`</footer>`) y afirmar dentro de él; mensajes `[ok]`/`FAILED - …` a stderr, `exit 1`, sin servidor por defecto (opt-in `RUN_SERVE_COMMAND=1`).
- Verificación con `python3 -m http.server <puerto> --directory .`, Chrome DevTools 390×844 y 1280×800, matriz de ocho anchos, Lighthouse móvil, y casos negativos en copias temporales fuera del repo.

### Current Gaps (específicos del ajuste post-passing)

- `PAGE_FOOTER_LINK_CONTRACT` en `init.sh` exige literalmente `'text-decoration: underline;'` (línea 784); con el ajuste el `.page-footer__link` pasa a `text-decoration: none;` + negrita, así que ese `declaration` del arreglo debe **reemplazarse** (quitar la exigencia de subrayado, añadir la exigencia de `font-weight: var(--text-button-label-font-weight);` o equivalente), o el gate fallará contra el nuevo CSS correcto.
- El gate de SVG decorativos (líneas 1904-1939) acopla el `svg_total -ne 10` con el mensaje de éxito que menciona «and footer separator» y con un `if` separado que exige `.page-footer__separator` con `aria-hidden="true"` (líneas 1935-1939). Al retirar el separador por completo y añadir un SVG nuevo, **ambas piezas deben cambiar**: `svg_total -ne 11` y eliminar/reemplazar el bloque que exige el separador (ya no existe ningún elemento que comprobar ahí).
- El gate «Page footer destinations» (líneas 686-730) ya extrae el bloque `<footer>…</footer>` y afirma el texto de invitación y «Tarjeta NFC &amp; QR» dentro de él; no depende del separador por posición de texto, pero si se añade un assert nuevo de estructura (p. ej. verificar que el nuevo `<svg>` precede al texto del cierre), debe ir dentro de este mismo bloque extraído, no sobre todo `index.html`.
- `CONSTRAINTS.md` línea 54-57 describe «10 decorative SVG icons today … and the footer separator with `aria-hidden="true"`»; debe re-expresarse a 11 SVG decorativos y retirar la mención del separador del pie (ya no existe).
- `docs/risks-and-open-questions.md` línea 104 describe el pie con separador conservado y SVG sin cambio; debe actualizarse para reflejar el ajuste (separador retirado, SVG 10→11, enlace en negrita sin subrayado).
- No hay E2E persistente; añadirlo introduciría dependencias prohibidas (`docs/technical-discovery.md`). Cobertura = `init.sh` + navegador + Lighthouse + prueba manual de WhatsApp/descarga.
- **Sin gaps de anclas:** el conteo de 9 anclas reales (5+2+1+1) no cambia por este ajuste; ningún control interactivo se añade ni se retira (el nuevo SVG es decorativo, no una ancla).

## Technical Approach

### Estructura HTML (`index.html`) — ajuste post-passing

1. En `<footer class="page-footer">`, dejar el párrafo de invitación (`<p class="page-footer__text">¿Tienes un proyecto en mente? Haz clic en mis redes o <a class="page-footer__link" href="https://wa.me/51955116562">escríbeme directamente</a></p>`) **sin** el `<span class="page-footer__separator" aria-hidden="true">·</span>` ni el texto «Tarjeta NFC &amp; QR» dentro.
2. Añadir un **segundo bloque** (p. ej. otro `<p>` con una clase nueva mínima, como `.page-footer__nfc` o similar, descriptiva y sin introducir tokens nuevos) debajo del párrafo de invitación, que contenga: el nuevo `<svg>` decorativo (`aria-hidden="true" focusable="false" stroke="currentColor" stroke-width="2"`, outline simple tipo tarjeta/chip NFC, mismo estilo que los demás `<svg>` del documento: `viewBox`, `fill="none"`, `stroke-linecap="round"`, `stroke-linejoin="round"`) seguido del texto «Tarjeta NFC &amp; QR».
3. Eliminar **toda** aparición de `<span class="page-footer__separator" aria-hidden="true">·</span>` del `<footer>` (y confirmar que no queda en ninguna otra parte del documento).
4. No tocar encabezado, Acciones rápidas, Enlaces, Guardar contacto, `<head>` ni el resto de la Tarjeta.

### CSS (`styles.css`) — ajuste post-passing

- En `.page-footer__link`: reemplazar `text-decoration: underline; text-underline-offset: 2px;` por `text-decoration: none;` y añadir `font-weight: var(--text-button-label-font-weight);` (reusa el token `800` ya pineado, sin crear uno nuevo). Conservar `color: var(--color-accent);`.
- Conservar `.page-footer__link:focus-visible` (outline acento 2px/offset 2px) sin cambios.
- Retirar la regla `.page-footer__separator` de `styles.css` (ya no hay elemento que la use); si el nuevo bloque «Tarjeta NFC & QR» necesita una regla de layout (p. ej. alinear el SVG con el texto con `display: flex`/`align-items: center`/`gap`), añadirla con una clase nueva mínima reusando espaciados pineados (`--space-xs`/`--space-sm`), sin introducir color/fuente/token nuevo.

### Cambios en `init.sh` (explícitos, sin debilitar) — ajuste post-passing

1. **«Page footer markup» / «Page footer destinations»:** sin cambios de alcance — siguen afirmando, dentro del bloque `<footer>…</footer>` extraído por `awk`, el `href` de WhatsApp, el texto de invitación y el cierre «Tarjeta NFC &amp; QR», y la ausencia de `mailto:`/`instagram.com`. Si se añade un assert de orden (SVG antes del texto), debe ir dentro de este mismo bloque.
2. **Contrato `.page-footer__link` (líneas 782-808):** en el arreglo `PAGE_FOOTER_LINK_CONTRACT`, **retirar** `'text-decoration: underline;'` y **añadir** `'font-weight: var(--text-button-label-font-weight);'` (o la declaración literal equivalente que termine usando el implementador); mantener `'color: var(--color-accent);'`. Opcionalmente añadir un assert explícito de que `text-decoration: none;` aparece en la regla, para detectar una regresión a subrayado.
3. **Conteo de anclas:** **sin cambios** — `anchor_total` sigue **9**, `footer_link_total` sigue **1**; el nuevo SVG no es una ancla.
4. **SVG decorativos (líneas 1904-1939):** cambiar `svg_total -ne 10` a `svg_total -ne 11` (línea 1929); actualizar el mensaje de fallo asociado a «index.html must contain exactly 11 decorative SVG icons». **Eliminar** el bloque `if grep -qE '<span class="page-footer__separator"...` (líneas 1935-1939) junto con su mensaje de éxito «… and footer separator are hidden from assistive technology»; reemplazarlo por un simple `echo "  [ok] 11 decorative SVG icons are hidden from assistive technology"` tras pasar los checks de `svg_total`/`svg_bad`, ya que no queda separador que verificar. El nuevo `<svg>` del cierre debe pasar el mismo loop de `aria-hidden="true"`/`focusable="false"` que los demás (no necesita lógica especial, solo contarse dentro de `SVG_TAGS`). No tocar el mensaje de anclas de la línea 1902 («9 real anchor controls…»), que es un check distinto sin cambios.
5. **Separador:** eliminar cualquier referencia a `.page-footer__separator` en `init.sh` (el check de la línea 1935-1939 arriba) ya que el elemento se retira del HTML por completo.
6. **Foco / reduced motion / contraste:** conservar `.page-footer__link:focus-visible` en el gate de foco, los bloques de reduced motion intactos y `CONTRAST_TOKENS` + 15/15 sin cambios (no hay token nuevo; la negrita no afecta contraste de color).
7. **vCard y Guardar contacto:** sin cambios — mantener intactos el contrato estático del botón, el gate de posición de `.save-contact`, y el contrato/coherencia/asset de la vCard.
8. Conservar el servidor opt-in; no cambiar los gates de encabezado, Acciones rápidas, Enlaces, metadatos ni responsive.

## Expected File Changes (ajuste post-passing)

- `index.html` — modificar; en `<footer class="page-footer">`: quitar `<span class="page-footer__separator" aria-hidden="true">·</span>` del párrafo de invitación; mover «Tarjeta NFC &amp; QR» a un bloque/línea propia con el nuevo `<svg>` decorativo a su izquierda. No tocar `.save-contact`, Acciones rápidas, Enlaces ni encabezado.
- `styles.css` — modificar; en `.page-footer__link` cambiar `text-decoration: underline;` → `text-decoration: none;` y añadir `font-weight: var(--text-button-label-font-weight);`; retirar la regla `.page-footer__separator` (ya no se usa); añadir una clase mínima nueva para el bloque «Tarjeta NFC & QR» si hace falta alinear el ícono con el texto, reusando tokens de espaciado existentes.
- `init.sh` — modificar; `PAGE_FOOTER_LINK_CONTRACT` (quitar exigencia de subrayado, añadir negrita); `svg_total -ne 11` (antes 10); eliminar el bloque que exige `.page-footer__separator` con `aria-hidden="true"` y su mensaje asociado. No tocar el conteo de anclas (sigue 9) ni los gates de foco/reduced-motion/contraste/vCard/posición.
- `CONSTRAINTS.md` — actualizar; línea 54-57: «exactly 10 decorative SVG icons» → «exactly 11 decorative SVG icons», y retirar la mención «and the footer separator with `aria-hidden="true"`» (el separador ya no existe). No tocar el desglose de 9 anclas ni la nota WCAG 2.5.8 (sin cambios por este ajuste).
- `docs/risks-and-open-questions.md` — actualizar la entrada «Resuelto — Pie rediseñado (2026-11-22, `redesign-footer-contact`)» (línea 104) para reflejar: enlace en negrita sin subrayado, separador retirado, SVG 10→11, aprobación visual completa aún pendiente.
- `DESIGN.md` — **NO se toca.** El addendum líneas 522-537 ya documenta la decisión aprobada; el implementador conforma el código a esas líneas, no al revés. Si falta algo, se detiene y reporta el bloqueo en vez de editar `DESIGN.md`.
- `feature_list.json`, `PROGRESS.md` — el implementador actualiza la entrada existente (status se mantiene `passing`) añadiendo evidencia nueva del ajuste y la sesión; el validador crea/actualiza `docs/validations/redesign-footer-contact.md`.
- `docs/specs/redesign-footer-contact.md` — este spec actualizado (artefacto de planificación, no código de producto).

## Visual Design Impact

- UI involved: yes. Design source: `DESIGN.md` § «Dirección del rediseño acordado (2026-11-21)», líneas 446-461 (dirección base, ya implementada); `DESIGN.md` § «Pie — decisión de diseño aprobada (`redesign-footer-contact`, 2026-11-22)», líneas 522-537 (los 3 ajustes de este slice, ya aprobados y de solo lectura).
- Estados afectados: única Tarjeta digital — pie (reposo/foco del enlace WhatsApp ahora en negrita sin subrayado, bloque nuevo «Tarjeta NFC & QR» con ícono, reposo/hover/foco de Guardar contacto sin cambios, reduced motion), 390×844, 1280×800 y los ocho anchos.
- New design artifact required: no. Los 3 ajustes ya están fijados en `DESIGN.md` líneas 522-537; **no se resuelve nada nuevo en `DESIGN.md` en este trabajo**. Si surge una ambigüedad no cubierta por esas líneas (p. ej. tamaño exacto del nuevo ícono, gap entre ícono y texto), el implementador elige un valor conservador reusando tokens de espaciado/tamaño ya pineados (p. ej. el mismo `width`/`height` que otros SVG decorativos de 18-24px) y lo documenta como tal en la evidencia; no inventa un token nuevo ni edita `DESIGN.md`.
- Las capturas del propietario son **referencias externas no versionadas**: orientan jerarquía, no fijan píxeles ni constituyen aprobación. La aceptación visual final completa (móvil + escritorio) la decide Fahed por separado; estos 3 ajustes ya cuentan con su aprobación de estructura, pero no cierran la aceptación final de la feature.

## Durable Documentation Impact (ajuste post-passing)

- `ARCHITECTURE.md`: not needed — no cambia dominios, runtime ni dependencias (no existe; no crear).
- `CONSTRAINTS.md`: update — conteo de SVG decorativos 10→11; retirar la mención del separador del pie (líneas 54-57). El desglose de 9 anclas y la nota WCAG 2.5.8 **no cambian** por este ajuste.
- `AGENTS.md`: not needed — flujo de arranque, workflow y DoD sin cambios (no contiene conteos).
- `DESIGN.md`: **not needed / prohibido tocar.** Los 3 ajustes ya están fijados en líneas 522-537 con aprobación del propietario; es de solo lectura en este trabajo.
- `docs/risks-and-open-questions.md`: update — actualizar la entrada «Resuelto — Pie rediseñado (2026-11-22, `redesign-footer-contact`)» (línea 104) con los 3 ajustes (negrita sin subrayado, separador retirado, SVG 11) y mantener la nota de aprobación visual final pendiente. `docs/technical-discovery.md`: update solo si cambia alguna medición/comando de verificación (no se espera).
- `CONTEXT.md` / `docs/domain-model.md`: not needed — sin cambios de dominio.

## Implementation Plan (ajuste post-passing)

1. Confirmar baseline: `bash -n init.sh && ./init.sh` (exit 0) sobre el pie ya `passing`, antes de editar código. Releer `DESIGN.md` líneas 522-537 (no editarlas).
2. En `index.html`: quitar el `<span class="page-footer__separator">` y mover «Tarjeta NFC &amp; QR» a un bloque/línea propia con el nuevo `<svg>` decorativo a su izquierda.
3. En `styles.css`: cambiar `.page-footer__link` a negrita sin subrayado (`text-decoration: none; font-weight: var(--text-button-label-font-weight);`); retirar la regla `.page-footer__separator`; añadir la clase mínima para el nuevo bloque si hace falta.
4. Adaptar `init.sh`: `PAGE_FOOTER_LINK_CONTRACT` (negrita/sin subrayado), `svg_total -ne 11`, eliminar el check del separador; no tocar anclas/foco/reduced-motion/contraste/vCard.
5. Actualizar `CONSTRAINTS.md` (SVG 10→11, retirar mención del separador) y `docs/risks-and-open-questions.md` (línea 104).
6. Ejecutar gate, casos negativos, navegador 390×844/1280×800, matriz de ocho anchos y Lighthouse; registrar evidencia nueva manteniendo `passing` (no `accepted`); recordar que la aprobación visual final completa sigue pendiente.

## Implementation Tasks (ajuste post-passing)

- [ ] Confirmar baseline: `bash -n init.sh && ./init.sh` exit 0 sobre el estado actual `passing`.
- [ ] En `index.html`: retirar `<span class="page-footer__separator" aria-hidden="true">·</span>`; mover «Tarjeta NFC &amp; QR» a su propio bloque/línea con el nuevo `<svg>` decorativo (`aria-hidden="true" focusable="false" stroke="currentColor" stroke-width="2"`) a su izquierda.
- [ ] En `styles.css`: `.page-footer__link` → `text-decoration: none;` + `font-weight: var(--text-button-label-font-weight);` (conservar `color: var(--color-accent);` y `:focus-visible`); retirar la regla `.page-footer__separator`; añadir clase mínima de layout para el nuevo bloque si hace falta, sin tokens nuevos.
- [ ] En `init.sh`: actualizar `PAGE_FOOTER_LINK_CONTRACT` (líneas 782-808); cambiar `svg_total -ne 10` a `-ne 11` (línea 1929) y el mensaje de fallo; eliminar el bloque de verificación del `.page-footer__separator` (líneas 1935-1939) y su mensaje de éxito, sustituyéndolo por un `[ok]` simple de SVG decorativos.
- [ ] Actualizar `CONSTRAINTS.md` (líneas 54-57: 10→11 SVG, retirar mención del separador del pie) y `docs/risks-and-open-questions.md` (línea 104).
- [ ] Ejecutar casos negativos (incluyendo los nuevos (f)-(h) del Scenario 6), navegador 390×844/1280×800, ocho anchos y Lighthouse; registrar evidencia nueva en `feature_list.json`/`PROGRESS.md` manteniendo `status: passing` (no `accepted`).
- [ ] Confirmar explícitamente, en la evidencia, que `DESIGN.md` no fue modificado por el implementador.

## Verification Plan (ajuste post-passing)

- `bash -n init.sh` → sin errores de sintaxis.
- `./init.sh` → exit 0, `Harness status: bootstrapped`, con el gate de pie afirmando el WhatsApp canónico y los textos, `[ok] 9 real anchor controls (5 link buttons + 2 quick actions + 1 save contact button + 1 footer link)` (sin cambio), `[ok] 11 decorative SVG icons …` (antes 10, ahora 11; **sin** mención de separador), contrato `.page-footer__link` verde con negrita/sin subrayado, Guardar contacto estático, foco/reduced-motion/contraste verdes; **sin** arrancar servidor.
- Casos negativos en copias temporales fuera del repo (borrar después; sin listener): (a) «escríbeme directamente» sin `href` WhatsApp o con otro destino → destinos del pie `exit 1`; (b) Guardar contacto a Blob/`<script>`/no-anchor o `href`/`download` roto → contrato vCard `exit 1`; (c) invitación o «Tarjeta NFC &amp; QR» ausente → gate de textos `exit 1`; (d) una ancla o un SVG de más/menos (10 u otro ≠11) → conteo `exit 1`; (e) `:focus-visible` o contraste roto → gate correspondiente `exit 1`; (f) **(nuevo)** `.page-footer__link` con `text-decoration: underline` reintroducido o sin negrita → contrato de enlace `exit 1`; (g) **(nuevo, opcional si se añade un check dedicado)** `<span class="page-footer__separator">` reintroducido en el `<footer>` → si el implementador añade un assert explícito de su ausencia dentro del gate de destinos del pie, debe fallar `exit 1`; si no añade ese assert dedicado (el gate eliminado de `init.sh` ya no lo exige positivamente, así que su reaparición no rompe nada por sí sola salvo que además altere el conteo de SVG o el texto), debe documentarse explícitamente en la evidencia como una verificación **no** cubierta por gate automático, solo por revisión manual en navegador; (h) **(nuevo)** el nuevo `<svg>` sin `aria-hidden`/`focusable="false"` → gate de SVG `exit 1`. Cada fallo con mensaje `FAILED - …` concreto y sin servidor.
- Servido manual (solo implementador/validador, worktree aislada): `python3 -m http.server <puerto> --directory .` (p. ej. 3603); detener y dejar el puerto libre al terminar. El planner no arranca servidores. `curl -sI http://localhost:<puerto>/` y `/styles.css` → 200; `/assets/fahedhermoza.vcf` → 200; log sin 4xx/5xx ni `/favicon.ico`.
- Navegador 390×844 y 1280×800 (recarga fresca): consola 0; peticiones 2xx/3xx incl. Google Fonts/avatar/WOFF2 sin `/favicon.ico`; `documentElement`/`body` `scrollWidth === clientWidth`; pie con la invitación, «escríbeme directamente» en **negrita sin subrayado** apuntando a `https://wa.me/51955116562` (nombre accesible con el texto visible); «Tarjeta NFC & QR» en su **propia línea**, con el nuevo ícono a su izquierda, **sin** el separador `·` en ningún lugar del pie; foco visible por `Tab` en el enlace del pie y en Guardar contacto; `prefers-reduced-motion: reduce` correcto; descarga de la vCard al activar Guardar contacto.
- Matriz de ocho anchos (320, 360, 375, 390, 480, 736, 768, 1280 CSS px): sin scroll horizontal; el párrafo de invitación y el nuevo bloque «Tarjeta NFC & QR» envuelven sin overflow ni solaparse con el ícono.
- Lighthouse móvil en `http://localhost:<puerto>/`: Accessibility ≥95, sin fallos `critical`/`serious`; auditar contraste del texto del pie y del enlace WhatsApp (ahora en negrita) en reposo y `brightness(1.03)`.
- Dispositivo real: confirmar que «escríbeme directamente» abre WhatsApp con el número canónico y que Guardar contacto importa la vCard; registrar con honestidad (si solo se emuló Chrome, declararlo, no afirmar prueba en dispositivo real).
- E2E: no existe harness persistente y añadirlo introduciría dependencias prohibidas; cobertura = `init.sh` + navegador + Lighthouse + prueba manual.
- `./init.sh` ejecuta el gate estándar no bloqueante; **no** arranca procesos de larga duración y puede imprimir comandos manuales tras pasar los checks.

## Evidence To Capture (ajuste post-passing)

- Salida de `bash -n init.sh` y `./init.sh` (gate de pie con WhatsApp + textos, conteo de anclas 9 sin cambio, `[ok] 11 decorative SVG icons …` sin mención de separador, contrato `.page-footer__link` verde con negrita/sin subrayado, 15/15 de contraste, exit 0, sin servidor).
- Stderr de cada caso negativo nuevo: (f) subrayado/negrita roto, (h) nuevo SVG sin `aria-hidden`/`focusable="false"` o conteo ≠11; y de los ya existentes (WhatsApp roto, Guardar contacto no semántico/`download` roto, textos ausentes) sin listener en el puerto usado.
- Tablas de navegador 390×844 y 1280×800: destino WhatsApp, enlace del pie en negrita sin subrayado (captura de `getComputedStyle` o snapshot visual), «Tarjeta NFC & QR» en línea propia con el ícono a su izquierda, ausencia confirmada del separador `·` en todo el pie, foco, reduced motion, consola/red limpias, descarga vCard; y Lighthouse móvil.
- Diff que prueba la vCard byte-idéntica, Guardar contacto estático, Acciones rápidas/Enlaces/encabezado sin cambios, y que `DESIGN.md` **no** aparece en el diff del implementador (`git diff --stat -- DESIGN.md` vacío respecto al estado previo al ajuste).
- Registro honesto de la prueba en dispositivo real (realizada o pendiente manual) y de la **solicitud de aprobación visual final del propietario** (fecha, contexto móvil/escritorio, respuesta); dado que la feature permanece `passing` (no `accepted`), dejar explícito `owner visual review: pending` salvo que el propietario confirme la aceptación final completa.

## Validator Checklist (ajuste post-passing)

- [ ] Solo este ajuste: `.page-footer__link` pasa a negrita sin subrayado (conservando `--color-accent` y `:focus-visible`); «Tarjeta NFC & QR» queda en su propia línea/bloque con un nuevo ícono SVG decorativo a su izquierda; el separador `·` desaparece de todo el pie. Nada más del pie ni del resto de la Tarjeta (Guardar contacto, Acciones rápidas, Enlaces, encabezado, vCard, metadatos) cambia.
- [ ] «escríbeme directamente» sigue abriendo `https://wa.me/51955116562`; Guardar contacto sigue `<a href="assets/fahedhermoza.vcf" download="fahedhermoza.vcf">` sin Blob/`<script>`/handler; vCard byte-idéntica (VCARD 3.0/CRLF/UTF-8 sin BOM/≤4096 bytes).
- [ ] 9 anclas reales sin cambio (5+2+1+1); conteo de SVG decorativos pasa de 10 a **11**, todos con `aria-hidden="true"` + `focusable="false"` (incluido el nuevo ícono); foco visible y reduced motion en el enlace del pie y Guardar contacto; contraste AA en reposo y hover/foco (negrita no afecta contraste).
- [ ] `init.sh` adaptado explícitamente: `PAGE_FOOTER_LINK_CONTRACT` sin exigencia de subrayado y con exigencia de negrita; `svg_total -ne 11`; el bloque que exigía `.page-footer__separator` con `aria-hidden` fue **eliminado** (no solo debilitado); sin debilitar ningún otro gate AA/vCard/anclas.
- [ ] `CONSTRAINTS.md` actualizado: SVG decorativos 10→11; sin mención del separador del pie; desglose de 9 anclas y nota WCAG 2.5.8 sin alterar.
- [ ] `./init.sh` sale 0 sin servidor y detecta los casos negativos nuevos (negrita/subrayado roto, SVG sin atributos o conteo ≠11) además de los ya existentes; navegador 390×844/1280×800 y ocho anchos sin scroll horizontal, con el pie mostrando la nueva estructura de dos bloques; Lighthouse móvil ≥95 sin `critical`/`serious`.
- [ ] **`DESIGN.md` no fue tocado por el implementador** (verificar `git diff --stat -- DESIGN.md` sin cambios nuevos atribuibles a este ajuste); `feature_list.json`/`PROGRESS.md` con evidencia real del ajuste; sin tokens/colores/fuentes/JS/dependencias/librería de iconos nuevos.
- [ ] La feature permanece `status: passing`, **no** se marca `accepted` en este ajuste; si el implementador la marcó `accepted`, revisar/rechazar.

## Risks And Open Questions

Historial del slice original (ya mitigado, implementación en `passing`):

- **Gate de destinos del pie:** ya reescrito para afirmar WhatsApp **dentro** del `<footer>`, sin `mailto`/Instagram; sin cambios por este ajuste.
- **Conteo de anclas 10 → 9:** ya reflejado de forma coherente en `CONSTRAINTS.md` e `init.sh`; sin cambios por este ajuste (el nuevo SVG no es una ancla).
- **WCAG 2.5.8:** el enlace inline del pie sigue bajo la excepción de enlace-en-texto; ya documentado en `CONSTRAINTS.md`. Al quitar el subrayado, su distinción pasa a depender de negrita + color de acento; no introduce una nueva evaluación de 44×44 (sigue bajo la excepción de enlace-en-texto, sin cambio de alcance táctil).

Riesgos y abiertos **de este ajuste post-passing**:

- **Acoplamiento SVG/separador en `init.sh` (crítico, ya identificado):** el gate actual (líneas 1904-1939) exige `svg_total==10` *y*, en un `if` separado, la existencia de `.page-footer__separator` con `aria-hidden="true"`, con un mensaje de éxito que menciona ambos juntos. Al retirar el separador y subir el conteo a 11, hay que **eliminar** ese `if` (no solo renombrar su mensaje), o el gate fallará siempre con `exit 1` porque el `grep` ya no encontrará el `<span>`.
- **Ausencia de gate dedicado para "el separador no debe reaparecer":** tras eliminar el check de `.page-footer__separator`, no queda ningún assert automático que falle si alguien reintroduce el `<span>` en el futuro (a menos que el implementador añada uno explícito dentro del gate de destinos del pie). Documentar esta brecha como aceptada o cerrarla con un assert nuevo; **no** dejarlo implícito sin mencionarlo en la evidencia.
- **Contraste/distinción del enlace sin subrayado:** al quitar `text-decoration: underline`, verificar en Lighthouse/manual que el enlace sigue siendo distinguible del texto circundante solo por color+negrita (no es un requisito WCAG automatizable por `init.sh`, pero sí observable en navegador).
- **`DESIGN.md` de solo lectura:** cualquier detalle no cubierto por las líneas 522-537 (p. ej. tamaño exacto del nuevo ícono, gap entre ícono y texto) debe resolverse con un valor conservador reusando patrones existentes, **sin** editar `DESIGN.md`; si la ambigüedad es significativa, detener el trabajo y reportar el bloqueo en vez de decidir unilateralmente.
- **Aprobación visual final pendiente:** estos 3 ajustes ya tienen aprobación de estructura del propietario, pero no sustituyen la revisión visual final completa (móvil + escritorio) de la feature; no marcar `accepted` en este ajuste.
- **Puerto:** la verificación manual de esta worktree usa un puerto aislado (p. ej. 3603 o el que esté libre); el hint interno de `init.sh` no es parte del alcance cambiarlo.
