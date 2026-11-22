# Feature Implementation Spec: Navegación de siete canales (cinco botones grandes + Acciones rápidas)

## Source Feature

- `id`: `redesign-contact-navigation`
- `area`: `links`
- `depends_on`: `redesign-card-profile`, `links-order-gradient`, `save-contact-vcard` (los tres `accepted`)
- `status`: `not_started` (al planificar; este spec no cambia el estado)
- `source`: `feature_list.json` (`user_visible_behavior`, `verification`, `notes`); `DESIGN.md` § «Dirección del rediseño acordado (2026-11-21)».

## Goal

Reestructurar la sección de Enlaces de la Tarjeta digital: Instagram, Facebook, WhatsApp, LinkedIn y Portafolio quedan como **cinco botones grandes** dentro de `<nav class="links">`, conservando la secuencia aceptada lavanda→violeta (`gradient-1`, `-2`, `-3`, `-3-4`, `-4`). Celular y Correo salen de esa pila y pasan a una **nueva fila «Acciones rápidas»** con sus destinos intactos (`tel:+51955116562`, `mailto:fahedhermoza@gmail.com`). Los siete href canónicos y la vCard estática (teléfono, correo y cinco URLs externas) no cambian.

El slice termina cuando la estructura, los conteos/selectores de `init.sh` y `CONSTRAINTS.md`, el navegador 390×844 y 1280×800, la matriz de ocho anchos y Lighthouse móvil ≥95 están verificados y registrados. La aceptación final requiere además la **revisión visual fechada del propietario (móvil + escritorio)**: las capturas de Fahed son dirección, no una especificación pixel-perfect ni la aprobación del resultado implementado.

## Non-Goals

- **No** implementar el nuevo pie (`redesign-footer-contact`): en este slice el `<footer class="page-footer">` actual se mantiene **sin cambios** (sus dos enlaces, el separador y los gates asociados intactos).
- **No** añadir el panel QR (`redesign-qr-panel`) ni la acción Compartir (`redesign-share-action`). La fila de Acciones rápidas hospeda **solo Celular y Correo** en esta etapa; no crear controles inertes, placeholders QR/Compartir ni `role`/`aria` que finjan esas acciones.
- **No** cambiar destinos, etiquetas visibles, `aria-label`, iconos SVG ni la vCard `assets/fahedhermoza.vcf` (teléfono, correo, cinco URLs, VCARD 3.0, CRLF, UTF-8 sin BOM, ≤4096 bytes).
- **No** tocar el encabezado ornamental de `redesign-card-profile` (rótulo «NFC CONNECT», avatar local con fallback «FH», punto verde), ni los metadatos Open Graph / producción, ni `assets/og-image.jpg`.
- **No** añadir tokens, colores fuera de la paleta, fuentes, frameworks, bundlers, dependencias, assets generados ni JavaScript nuevo. Mantener un solo `<h1>`, `lang="en"` en la Tagline y el `onerror`/fallback del avatar.
- **No** debilitar silenciosamente ningún check de `init.sh` (anclas reales, iconos decorativos, foco, reduced motion, contraste AA, tamaños táctiles ≥44×44); todo ajuste de conteo/selector es explícito y equivalente o más fuerte.
- **No** marcar `accepted`: el implementador deja `passing` con evidencia; el validador independiente acepta; la aprobación visual del propietario es un paso separado.

## Job Story

When abro la Tarjeta digital en el móvil o el escritorio,
I want ver mis cinco redes principales como botones grandes y tener Celular y Correo a mano en una fila de acciones rápidas,
so I can elegir el canal correcto de un vistazo sin perder ninguno de los destinos ni la descarga de contacto.

## Users And Permissions

- Visitante anónimo: ve y activa los cinco botones grandes, las dos acciones rápidas, Guardar contacto y el pie; sin autenticación, estado ni permisos.
- Propietario/agente: mantiene estructura, orden y tono editando solo `index.html` y `styles.css`; decide la aprobación visual (móvil y escritorio).
- Implementador/validador: adapta el gate explícitamente, verifica en navegador y registra evidencia; no implementa otras features del rediseño.

## Acceptance Scenarios

### Scenario 1: Cinco botones grandes en orden y tono aceptados

Given la Tarjeta servida a 390×844 o 1280×800,
When se inspecciona `<nav class="links" aria-label="Enlaces de contacto">`,
Then contiene exactamente **5** anclas `.link-button` cuyas etiquetas en orden son `Instagram`, `Facebook`, `WhatsApp`, `LinkedIn`, `Portafolio`, con las clases `link-button--gradient-1`, `-2`, `-3`, `-3-4`, `-4`, cada botón de 48px de alto a ancho completo, progresión monótona lavanda→violeta y sin scroll horizontal.

### Scenario 2: Acciones rápidas con Celular y Correo, destinos intactos

Given la fila «Acciones rápidas» renderizada,
When se inspeccionan sus controles,
Then hay **exactamente 2** anclas reales, Celular con `href="tel:+51955116562"` y `aria-label="Celular: llamar al +51 955 116 562"`, y Correo con `href="mailto:fahedhermoza@gmail.com"` y `aria-label="Correo a fahedhermoza@gmail.com"`; cada una tiene nombre accesible, icono SVG decorativo (`aria-hidden="true"` + `focusable="false"`) y no existe ningún control QR/Compartir ni placeholder inerte.

### Scenario 3: Siete destinos y vCard preservados

Given el diff y la página servida,
When se revisan todos los controles,
Then existen los siete destinos canónicos exactos (Instagram, Facebook, WhatsApp, LinkedIn, Portafolio en los botones grandes; Celular y Correo en Acciones rápidas), el ancla de vCard `href="assets/fahedhermoza.vcf" download="fahedhermoza.vcf"` sigue entre `</nav>` y el pie, y `assets/fahedhermoza.vcf` conserva nombre, `TEL`, `EMAIL` y las cinco `URL:` sin alteración (byte a byte, ≤4096 bytes, CRLF, UTF-8 sin BOM).

### Scenario 4: Pie y encabezado sin cambios en este slice

Given el documento servido,
When se comparan el pie y el encabezado con el estado previo,
Then el `<footer class="page-footer">` conserva sus dos `.page-footer__link` (correo e Instagram) y el separador `aria-hidden="true"`; el encabezado de `redesign-card-profile` (rótulo «NFC CONNECT», avatar/fallback, punto verde, único `h1`, Tagline con `lang="en"`) queda intacto. La duplicación transitoria de Correo (Acciones rápidas + pie) es aceptable aquí y se resolverá en `redesign-footer-contact`.

### Scenario 5: Accesibilidad, foco, reduced motion y tamaño táctil

Given la página cargada y recorrida con `Tab`, con hover y `prefers-reduced-motion: reduce`,
Then hay **10 anclas reales** (5 `.link-button` + 2 acciones rápidas + 1 `.save-contact-button` + 2 `.page-footer__link`) y **10 SVG decorativos** (5 iconos de Enlace + 2 de acción rápida + 1 Guardar contacto + 2 del encabezado) con `aria-hidden`/`focusable="false"`; cada control muestra `outline: 2px solid var(--color-accent); outline-offset: 2px;` al enfocar, con movimiento reducido usa `transition: none`/`transform: none`, y cada botón grande y cada acción rápida cumple `min(rect.width, rect.height) >= 44px` en los ocho anchos auditados. Texto e iconos cumplen contraste ≥4.5:1 en reposo y en el estado `brightness(1.03)`.

### Scenario 6: El gate detecta regresiones

Given una copia temporal fuera del repo con (a) Celular o Correo devueltos a `.link-button` dentro de `.links`, (b) un botón grande fuera de orden o con tono alterado, (c) la fila de Acciones rápidas ausente o con un tercer control, (d) un destino alterado, (e) foco/reduced motion/tamaño táctil roto de una acción rápida, o (f) un token de contraste cambiado,
When se ejecuta `./init.sh`,
Then sale con código 1, imprime el check concreto en stderr y no arranca ningún servidor.

### Scenario 7: Consola, red y Lighthouse limpios

Given la página servida manualmente en `http://localhost:3602/`,
When se carga a 390×844 y 1280×800 y se ejecuta Lighthouse móvil de accesibilidad,
Then la consola muestra 0 mensajes, todas las peticiones responden 2xx/3xx sin `/favicon.ico`, no hay scroll horizontal y la accesibilidad es ≥95 sin auditorías `critical`/`serious`.

## Repository Research

### Files Inspected

- `AGENTS.md`, `CONSTRAINTS.md` — DoD, base AA/responsive; CONSTRAINTS pinea «10 anclas (7 `.link-button` + 1 `.save-contact-button` + 2 `.page-footer__link`)» y reglas de foco/reduced-motion/contraste/tap-target que deben re-expresarse, no debilitarse.
- `DESIGN.md` § rediseño 2026-11-21 — jerarquía objetivo: encabezado → fila de Acciones rápidas (Celular, Correo, +QR/Compartir en features posteriores) → cinco Enlaces grandes → pie; los 40×40 px del prototipo **no** son el objetivo (mínimo 44×44).
- `index.html` — hoy `<nav class="links">` tiene 7 `.link-button` en orden Instagram(`-1`), Facebook(`-2`), WhatsApp(`-3`), LinkedIn(`-3-4`), Portafolio(`-4`), Correo(`-4-5`), Celular(`-5`); `.save-contact` entre nav y pie; pie con dos enlaces; encabezado NFC/avatar/punto.
- `styles.css` — `.link-button` (48px, radio 6px, `justify-content:space-between`, `button-label`), modificadores `--gradient-1..5` + midpoints `-3-4`/`-4-5` vía `color-mix` con `@supports`; `.save-contact-button` neutro; bloque `@media (prefers-reduced-motion: reduce)`; sin tokens nuevos.
- `init.sh` — gates relevantes: «Link checks» (Celular markup/destino/aria, ~742-770), «link Correo contract» exige `class="link-button link-button--gradient-4-5"` (~1044), «Order and gradient checks» con `LINK_ANCHOR_COUNT`==7, `EXPECTED_LINK_LABELS` y `EXPECTED_LINK_CLASSES` de 7, reglas `color-mix` y `@supports`; conteos «10 real anchor controls» con `link_button_total`==7 (~1738-1790), «10 decorative SVG» (~1817), foco/reduced-motion, `CONTRAST_TOKENS` (8) + 15/15, «Responsive checks» (card fluida, botones 48px, tap≥44px, `.link-button__label` shrink). La coherencia vCard busca `href="tel:+51955116562"` y `href="mailto:…"` en todo `index.html` (no en `LINKS_BLOCK`), así que mover Celular/Correo no la rompe.
- `docs/specs/redesign-card-profile.md`, `links-order-gradient.md`, `save-contact-vcard.md` — contratos de encabezado, rampa de 7 tonos y botón neutro vCard sobre los que se construye este slice.

### Existing Patterns To Follow

- HTML estático, CSS plano, BEM-ish, color/tipografía/espaciado solo por tokens; iconos SVG inline; assets en `assets/`.
- Gate aditivo y no bloqueante con `awk`/`grep`, mensajes `[ok]`/`FAILED - …` a stderr, `exit 1`, sin servidor por defecto (opt-in `RUN_SERVE_COMMAND=1`).
- Verificación con `python3 -m http.server <puerto> --directory .`, Chrome DevTools a 390×844 y 1280×800, Lighthouse móvil, y casos negativos en copias temporales fuera del repo.

### Current Gaps

- No existe la fila «Acciones rápidas» ni su CSS; Celular/Correo hoy son `.link-button` en la pila.
- Los gates de orden/tono, conteo de `.link-button` (7) y «link Correo contract» (`-4-5`) codifican el estado de 7 botones y romperán al pasar a 5+2; deben adaptarse explícitamente a 5 botones grandes + 2 acciones rápidas, sin perder cobertura.
- `CONSTRAINTS.md` describe el desglose «7 `.link-button`»; debe re-expresarse como «5 `.link-button` + 2 acciones rápidas» manteniendo el total de 10 anclas.
- No hay E2E persistente; añadirlo introduciría dependencias prohibidas (`docs/technical-discovery.md`). Cobertura = `init.sh` + navegador + Lighthouse.

## Technical Approach

### Estructura HTML

1. En `<nav class="links">` dejar **solo** los cinco Enlaces grandes en orden Instagram(`link-button--gradient-1`), Facebook(`-2`), WhatsApp(`-3`), LinkedIn(`-3-4`), Portafolio(`-4`), conservando cada `href`, etiqueta visible, `aria-label` e icono SVG sin cambios.
2. Añadir una **fila de Acciones rápidas** (sugerido `<nav class="quick-actions" aria-label="Acciones rápidas">` o `<div>` con nombre accesible equivalente) con exactamente dos anclas reales: Celular (`href="tel:+51955116562"`, `aria-label` actual) y Correo (`href="mailto:fahedhermoza@gmail.com"`, `aria-label` actual), cada una con su icono SVG decorativo actual (`aria-hidden="true"` + `focusable="false"`). Sin controles QR/Compartir ni placeholders.
3. **Ubicación recomendada:** la fila de Acciones rápidas entre el encabezado de identidad y `<nav class="links">`, siguiendo el orden de `DESIGN.md`. Debe preservarse el gate de posición de `.save-contact` (sigue **después** de `</nav>` y **antes** de `<footer class="page-footer">`). El pie y el encabezado quedan intactos.

### Tono de las Acciones rápidas (decisión de diseño a fijar en `DESIGN.md`)

El contrato obliga solo a: AA ≥4.5:1 en reposo y hover/foco, foco visible, reduced motion, tap ≥44×44 y **ningún token/color nuevo**. Dos caminos válidos sin añadir tokens:

- **Recomendado (mínima fricción de gate):** reusar los tonos ya asignados y gated, Celular con `--color-gradient-5` y Correo con `--color-gradient-4-5`, como fondo de chip con etiqueta/icono blancos. Mantiene en uso los tokens y las reglas `color-mix`/`@supports` que `init.sh` ya exige, continúa la rampa lavanda→violeta y no cambia `CONTRAST_TOKENS`.
- **Alternativa neutra:** reusar el par neutro ya pineado de Guardar contacto (`--color-surface-container-low` / `--color-primary`). Si se adopta y queda sin uso la regla `color-mix` de `--gradient-4-5`, el gate de `interpolated tone rules` debe actualizarse **explícitamente** (no borrar cobertura en silencio).

El implementador fija la elección en `DESIGN.md` y la refleja en el gate y el contraste; el propietario la aprueba visualmente.

### CSS

- Añadir una regla de layout para la fila (`.quick-actions` o la clase elegida): fila horizontal, controles con área táctil `min(width,height) >= 44px` (p. ej. alto ≥44px), separación por token de espaciado existente, sin máscaras de overflow, `max-width` seguro.
- Componente de acción rápida: medidas y `button-label`/icono 18px coherentes con el sistema; `:focus-visible` con `outline: 2px solid var(--color-accent); outline-offset: 2px;`; hover/`brightness(1.03)` si aplica; y **añadir el selector de acción rápida al bloque `@media (prefers-reduced-motion: reduce)`** (`transition: none`, `transform: none`).
- No alterar la regla base `.link-button`, sus estados, `.save-contact-button`, `.links` gap/padding ni el pie salvo lo estrictamente necesario para quitar Celular/Correo de la pila.

### Cambios en `init.sh` (explícitos, sin debilitar)

1. **«Link checks» Celular:** sustituir la aserción `class="links"`/`.link-button`/label-en-nav por que Celular esté en la fila de Acciones rápidas (dentro de `.quick-actions`), conservando `href="tel:+51955116562"`, `aria-label` e icono decorativo.
2. **«link Correo contract»:** reemplazar `class="link-button link-button--gradient-4-5"` por la clase de acción rápida elegida; mantener `href="mailto:…"`, `aria-label="Correo a fahedhermoza@gmail.com"`, label `Correo` e icono decorativo.
3. **«Order and gradient checks»:** `LINK_ANCHOR_COUNT` esperado **5**; `EXPECTED_LINK_LABELS='Instagram|Facebook|WhatsApp|LinkedIn|Portafolio'`; `EXPECTED_LINK_CLASSES='link-button link-button--gradient-1|…--gradient-2|…--gradient-3|…--gradient-3-4|…--gradient-4'`. Actualizar los mensajes `(7/7)`→`(5/5)`. Mantener los gates de ausencia de la demo.
4. **Reglas `color-mix`/`@supports`:** conservarlas (LinkedIn usa `-3-4`; `-4-5` se mantiene si las Acciones rápidas reusan ese tono). Si la vía neutra deja `-4-5` sin uso y se retira su regla, actualizar el gate `interpolated tone rules` en consecuencia.
5. **Conteo de anclas:** `link_button_total` esperado **5** (no 7); añadir un check de **exactamente 2** anclas de acción rápida; `anchor_total` sigue **10**; actualizar el mensaje `[ok] 10 real anchor controls (…)` al nuevo desglose **5 link buttons + 2 quick actions + 1 save contact + 2 footer**. Añadir el equivalente de los checks «non-anchor usa la clase» para la clase de acción rápida.
6. **SVG decorativos:** el total sigue **10** (los iconos se mueven con sus anclas); verificar que las dos acciones rápidas mantienen `aria-hidden="true"` + `focusable="false"`.
7. **Foco / reduced motion:** añadir el selector `:focus-visible` de la acción rápida al gate de foco y su presencia al bloque de reduced motion.
8. **Tap target ≥44×44:** añadir una aserción estática de que el componente de acción rápida declara alto ≥44px (análoga a la de `.link-button`), y mantener la prueba runtime de ocho anchos.
9. **Contraste:** mantener `CONTRAST_TOKENS` y el total **15/15** si se reusan tonos gradient o el neutro ya pineado; si cambia cualquier token, recalcular reposo y `brightness(1.03)`, actualizar `DESIGN.md` y el gate juntos.
10. Mantener intactos los gates de pie, encabezado, metadatos, vCard (asset/coherencia/posición) y responsive; conservar el servidor opt-in. El hint del servidor en `init.sh` usa 3601; la verificación manual de esta worktree usa **3602** (ver «Verification Plan»).

## Expected File Changes

- `index.html` — modificar; dejar 5 `.link-button` en `.links`, añadir la fila de Acciones rápidas con Celular y Correo, conservar encabezado, `.save-contact` y pie.
- `styles.css` — modificar; layout y componente de Acciones rápidas (foco, hover, reduced motion, tap≥44), quitar Celular/Correo de la pila; no tocar base `.link-button`/`.save-contact-button`/pie salvo lo necesario.
- `init.sh` — modificar; adaptar conteos (5 link buttons, 2 quick actions, 10 anclas, 10 SVG), orden/tono a 5, Celular/Correo a la fila, foco/reduced-motion/tap/contraste de las acciones rápidas; no debilitar nada.
- `CONSTRAINTS.md` — actualizar; re-expresar el desglose de 10 anclas como «5 `.link-button` + 2 acciones rápidas + 1 `.save-contact-button` + 2 `.page-footer__link`», añadir el `:focus-visible`, reduced motion y tap≥44×44 de las Acciones rápidas, y mantener los pines de contraste; corregir el desglose de SVG si procede.
- `DESIGN.md` — actualizar; documentar la fila de Acciones rápidas (solo Celular/Correo en este slice), el tratamiento de tono elegido y los cinco botones grandes; diferenciar de QR/Compartir/pie posteriores.
- `feature_list.json`, `PROGRESS.md` — el implementador registra `passing` + evidencia y sesión; el validador crea `docs/validations/redesign-contact-navigation.md`.
- `docs/specs/redesign-contact-navigation.md` — este spec (no es código de producto).

## Visual Design Impact

- UI involved: yes. Design source: `DESIGN.md` § «Dirección del rediseño acordado (2026-11-21)».
- Estados afectados: única Tarjeta digital — cinco botones grandes (reposo/hover/foco/reduced motion) y la nueva fila de Acciones rápidas (reposo/hover/foco/reduced motion); 390×844, 1280×800 y los ocho anchos.
- New design artifact required: no — se reusan tokens existentes (tonos gradient ya gated o el neutro pineado); no se crean colores ni fuentes.
- Las dos capturas del propietario (Tarjeta completa y Vista QR) son **referencias externas no versionadas**: orientan jerarquía, no fijan píxeles ni constituyen aprobación. La aceptación visual (móvil + escritorio) la decide Fahed por separado.

## Durable Documentation Impact

- `ARCHITECTURE.md`: not needed — no cambia dominios, runtime ni dependencias (no existe; no crear).
- `CONSTRAINTS.md`: update — re-expresar el desglose de anclas (5+2+1+2), añadir foco/reduced-motion/tap≥44×44 de Acciones rápidas, mantener contraste AA; no debilitar ningún MUST.
- `AGENTS.md`: not needed — flujo de arranque, workflow y DoD sin cambios (verificado que no contiene conteos).
- `DESIGN.md`: update — fuente de verdad de la nueva estructura (cinco botones grandes + fila de Acciones rápidas Celular/Correo) y del tono elegido.
- `docs/technical-discovery.md`: update solo si cambia alguna medición/comando de verificación; `docs/risks-and-open-questions.md`: registrar la decisión de tono de Acciones rápidas y la aprobación visual pendiente si siguen abiertas.
- `CONTEXT.md` / `docs/domain-model.md`: not needed — Enlace, Celular y Correo ya están modelados; esta feature solo reagrupa la presentación.

## Implementation Plan

1. Confirmar baseline con `bash -n init.sh && ./init.sh` (exit 0) antes de editar.
2. En `index.html`: reducir `.links` a los cinco botones grandes y añadir la fila de Acciones rápidas con Celular y Correo (destinos, `aria-label`, iconos intactos); conservar encabezado, `.save-contact` y pie.
3. En `styles.css`: añadir layout y componente de Acciones rápidas (foco, hover, reduced motion, tap≥44), quitar Celular/Correo de la pila; fijar el tono elegido.
4. Adaptar `init.sh` (conteos 5/2/10/10, orden/tono a 5, Celular/Correo en la fila, foco/reduced-motion/tap/contraste de las acciones rápidas), sin debilitar gates.
5. Actualizar `DESIGN.md` y `CONSTRAINTS.md` (desglose de anclas y reglas AA de Acciones rápidas).
6. Ejecutar gate, casos negativos, navegador 390×844/1280×800, matriz de ocho anchos y Lighthouse; registrar `passing` + evidencia; solicitar la revisión visual del propietario.

## Implementation Tasks

- [ ] Confirmar baseline: `bash -n init.sh && ./init.sh` exit 0.
- [ ] Dejar 5 `.link-button` (Instagram→Portafolio, gradient-1..4) en `.links`; verificar orden/tono/geometría.
- [ ] Añadir la fila de Acciones rápidas con Celular (`tel:`) y Correo (`mailto:`), nombres accesibles e iconos decorativos; sin QR/Compartir.
- [ ] Añadir CSS de la fila y el componente (foco, hover, reduced motion, tap≥44×44) y fijar el tono en `DESIGN.md`.
- [ ] Adaptar `init.sh`: conteos (5 link buttons, 2 quick actions, 10 anclas, 10 SVG), orden/tono a 5, Celular/Correo en la fila, foco/reduced-motion/tap/contraste de Acciones rápidas; actualizar mensajes.
- [ ] Actualizar `CONSTRAINTS.md` (desglose 5+2+1+2 y reglas AA de Acciones rápidas) y `DESIGN.md`.
- [ ] Ejecutar casos negativos, navegador 390×844/1280×800, matriz de ocho anchos y Lighthouse; registrar `passing` + evidencia y solicitar aprobación visual.

## Verification Plan

- `bash -n init.sh` → sin errores de sintaxis.
- `./init.sh` → exit 0, `Harness status: bootstrapped`, con `[ok] links order (5/5)`, `[ok] links tone progression (5/5)`, el nuevo check de 2 acciones rápidas, `[ok] 10 real anchor controls (5 link buttons + 2 quick actions + 1 save contact button + 2 footer links)`, `[ok] 10 decorative SVG …`, foco/reduced-motion/tap/contraste verdes; **sin** arrancar servidor.
- Casos negativos en copias temporales fuera del repo (borrar después; sin listener): (1) Celular/Correo devueltos a `.link-button` en `.links` → conteo/orden `exit 1`; (2) un botón grande fuera de orden o con tono alterado → orden/tono `exit 1`; (3) fila de Acciones rápidas ausente o con un 3.º control → quick-actions `exit 1`; (4) `tel:`/`mailto:` alterado → destino/coherencia vCard `exit 1`; (5) `:focus-visible`/reduced motion/alto<44 de una acción rápida roto → gate correspondiente `exit 1`; (6) token de contraste cambiado → contraste `exit 1`. Cada fallo con mensaje `FAILED - …` concreto y sin servidor.
- Servido manual (solo implementador/validador, worktree aislada): `python3 -m http.server 3602 --directory .`; detener y dejar 3602 libre al terminar. El planner no arranca servidores. `curl -sI http://localhost:3602/` y `/styles.css` → 200; `/assets/fahedhermoza.vcf` → 200; log sin 4xx/5xx ni `/favicon.ico`.
- Navegador 390×844 y 1280×800 (recarga fresca): consola 0; peticiones 2xx/3xx incl. Google Fonts/avatar/WOFF2 sin `/favicon.ico`; `documentElement`/`body` `scrollWidth === clientWidth`; 5 botones grandes en orden con tonos de la rampa y 2 acciones rápidas con destinos correctos; foco visible por `Tab` en los 10 controles; hover y `prefers-reduced-motion: reduce` correctos; `min(rect.width, rect.height) >= 44px` en botones grandes y acciones rápidas.
- Matriz de ocho anchos (320, 360, 375, 390, 480, 736, 768, 1280 CSS px, alto 844 móvil / 800 escritorio): sin scroll horizontal, texto sin recorte, tap ≥44×44 en botones grandes y acciones rápidas.
- Lighthouse móvil en `http://localhost:3602/`: Accessibility ≥95, sin fallos `critical`/`serious`; auditar contraste de los tonos usados por las Acciones rápidas en reposo y `brightness(1.03)`.
- Dispositivo real: confirmar que Celular abre el marcador y Correo el cliente de correo con el destino esperado; registrar con honestidad (si solo se emuló Chrome, declararlo, no afirmar prueba en dispositivo real).
- E2E: no existe harness persistente y añadirlo introduciría dependencias prohibidas; cobertura = `init.sh` + navegador + Lighthouse.
- `./init.sh` ejecuta el gate estándar no bloqueante; **no** arranca procesos de larga duración y puede imprimir comandos manuales tras pasar los checks.

## Evidence To Capture

- Salida de `bash -n init.sh` y `./init.sh` (todos los `[ok]`, conteos 5/2/10/10, 15/15 de contraste, exit 0, sin servidor).
- Stderr de cada caso negativo sin listener en 3602.
- Tablas de navegador 390×844 y 1280×800 (orden/tonos de los 5 grandes, destinos de las 2 acciones rápidas, geometría, foco, hover, reduced motion, tap≥44, consola/red limpias) y Lighthouse móvil.
- Diff que prueba siete href y vCard intactos; pie y encabezado sin cambios.
- Registro honesto de la prueba en dispositivo real (realizada o pendiente manual) y de la **solicitud de aprobación visual del propietario** (fecha, contexto móvil/escritorio, respuesta); si falta, dejar `owner visual review: pending` y **no** marcar `accepted`.

## Validator Checklist

- [ ] Solo este slice: cinco botones grandes (Instagram→Portafolio, gradient-1..4) en `.links` y exactamente dos Acciones rápidas (Celular, Correo) con destinos intactos; sin QR/Compartir ni placeholders inertes.
- [ ] Siete href canónicos y vCard (teléfono, correo, cinco URLs, VCARD 3.0/CRLF/UTF-8 sin BOM/≤4096 bytes) intactos; pie y encabezado de `redesign-card-profile` sin cambios.
- [ ] 10 anclas reales (5+2+1+2) y 10 SVG decorativos; foco visible, reduced motion y tap ≥44×44 en botones grandes y acciones rápidas; contraste AA en reposo y hover/foco.
- [ ] `init.sh` y `CONSTRAINTS.md` adaptados **explícitamente** (desglose 5+2+1+2, orden/tono a 5, Celular/Correo en la fila) sin debilitar anclas, iconos, foco, reduced motion, contraste ni tap≥44.
- [ ] `./init.sh` sale 0 sin servidor y detecta todos los casos negativos; navegador 390×844/1280×800 y ocho anchos sin scroll horizontal; Lighthouse móvil ≥95 sin `critical`/`serious`.
- [ ] `DESIGN.md` documenta la nueva estructura y el tono elegido; `feature_list.json`/`PROGRESS.md` con evidencia real.
- [ ] Aprobación visual del propietario (móvil + escritorio) solicitada y registrada; si falta, no declarar `accepted`. Sin tokens/colores/fuentes/JS/dependencias nuevos.

## Risks And Open Questions

- **Tono de las Acciones rápidas (decisión de diseño):** reusar `--gradient-5`/`--gradient-4-5` (continúa la rampa, cero churn de gate) o el neutro pineado de Guardar contacto. Debe fijarse en `DESIGN.md` y mantener AA; si se retira la regla `color-mix` de `-4-5`, actualizar su gate explícitamente. **No** introducir tokens nuevos.
- **Ubicación de la fila:** recomendada entre identidad y `.links` (orden de `DESIGN.md`); cualquiera que sea, debe conservar el gate de posición de `.save-contact` (después de `</nav>`, antes del pie).
- **Duplicación transitoria de Correo:** Correo aparece en Acciones rápidas y en el pie hasta `redesign-footer-contact`; aceptable en este slice, no se publica así.
- **Capturas no versionadas:** bloquean la comparación visual concluyente y la aceptación final hasta que el propietario revise móvil y escritorio; no bloquean implementar ni probar el slice localmente.
- **Puerto 3602 vs hint 3601 de `init.sh`:** la verificación manual de esta worktree usa 3602 (asignado); el hint interno de `init.sh` permanece en 3601 y no es parte del alcance cambiarlo. Sin bloqueos.
</content>
</invoke>
