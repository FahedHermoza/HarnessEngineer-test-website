# Feature Implementation Spec: Layout responsive sin scroll horizontal

## Source Feature

- `id`: `responsive-baseline`
- `area`: `quality`
- `depends_on`: `page-shell`, `links-order-gradient` (both `accepted`)
- `status`: `not_started` (at planning time; this spec does not change it)
- `source`: `feature_list.json`
- `notes`: `DESIGN.md` > `Responsive Baseline` (breakpoints ~736px / ~480px / ~360px) and `Layout`; `CONSTRAINTS.md` > `Accessibility Baseline`; `docs/technical-discovery.md` > `Testing and Verification`.

## Goal

Convertir el layout ya fluido en un **contrato responsive verificado**: la Tarjeta se ve completa, centrada y sin scroll horizontal en todo el rango 320–1280 px, con botones a ancho completo de al menos 44×44 px, sin texto recortado y sin enmascarar overflow. La feature no rediseña: **se decide explícitamente que no hace falta ningún cambio de CSS de producto**; el trabajo es añadir un gate durable a `./init.sh`, medir el comportamiento en ocho anchos (incluidos los tres puntos de `DESIGN.md`), documentar la decisión y registrar evidencia. Nada de JavaScript, frameworks, bundlers, dependencias ni assets.

## Non-Goals

- No cambiar `index.html` ni `styles.css`: el spec parte de que la fórmula fluida actual ya cumple y lo demuestra con mediciones. Si la implementación no lo reproduce, **detenerse y replanificar**; no añadir CSS cosmético, breakpoints nuevos ni `overflow-x: hidden`.
- No rediseñar la tarjeta, la tipografía, los tokens, el degradado, los 48 px de los botones ni el orden/contenido de los Enlaces.
- No añadir botones, enlaces, vCard, metadatos, OG, despliegue ni trabajo de otras features.
- No debilitar, reordenar ni duplicar los gates existentes, en especial `Accessibility checks:` (contraste, foco, `aria-hidden`, `alt`, idioma, reduced motion) ni sus tokens.
- No introducir JS, `<script>`, `package.json`, Playwright/Cypress, dependencias, bundlers, preprocesadores ni assets generados.
- No crear menús móviles, grids, carruseles ni variantes visuales por breakpoint.
- No usar puertos distintos de **3502** para la validación de navegador ni dejar el servidor vivo.
- No commitear desde la sesión de implementación.

## Job Story

When abro la Tarjeta digital desde un móvil pequeño, uno mediano o un escritorio,
I want ver la tarjeta completa y los botones cómodos de tocar, sin desplazamiento lateral ni texto cortado,
so I can recorrer todos los canales de contacto sin perder contenido ni pelear con el layout.

## Users And Permissions

- Visitante anónimo en móvil/tablet/escritorio: única vista, sin autenticación ni estado.
- Usuario táctil: los siete Enlaces son objetivos de 48 px de alto y ancho completo.
- Implementador/validador: reproduce el gate, la matriz de ocho anchos y las mediciones; no cambia el producto.

## Acceptance Scenarios

### Scenario 1: Suelo móvil de 320 px

Given la Tarjeta servida en 320×844,
When se carga con emulación móvil/táctil,
Then `documentElement.scrollWidth === documentElement.clientWidth`, `body.scrollWidth === body.clientWidth`, ningún elemento visible sobresale del viewport, la tarjeta mide 288×~861 en x=16 y cada Enlace 238×48 sin etiquetas truncadas.

### Scenario 2: Zonas de breakpoint 360 / 480 / 736

Given 360×844, 480×844 y 736×800,
When se miden tarjeta y botones,
Then la tarjeta sigue la fórmula `min(400px, 100% − 2rem)` (328 px a 360, 400 px a 480 y 736), los botones conservan ancho completo y 48 px de alto, y no existe ninguna media query de ancho: los breakpoints de `DESIGN.md` son **fronteras de auditoría**, no ramas de implementación.

### Scenario 3: Anchos intermedios y escritorio

Given 375×844, 390×844, 768×800 y 1280×800,
When se carga con recarga fresca,
Then no hay scroll horizontal (`scrollWidth === clientWidth` en documento y `body`), la tarjeta queda centrada dentro del gutter de 16 px, mide 343/358/400/400 px y los botones 293/308/350/350×48; en escritorio el `clientWidth` puede ser 1265 por la barra de scroll clásica y se mide contra él.

### Scenario 4: Áreas táctiles y ausencia de recorte

Given cualquiera de los ocho anchos,
When se inspeccionan los siete `.link-button` y el texto de Perfil y pie,
Then cada botón mide 48 px de alto y ≥238 px de ancho (`getBoundingClientRect`), ninguna etiqueta tiene `scrollWidth > clientWidth`, el correo y el handle del pie caben en su bloque, y no hay elementos recortados u ocultos por overflow.

### Scenario 5: Contratos AA intactos

Given la misma página en 320 y 1280,
When se enfoca el primer control con `Tab` y se emula `prefers-reduced-motion: reduce`,
Then el outline sigue siendo `rgb(88, 92, 229) solid 2px` con offset 2 px, el botón no se transforma con movimiento reducido, los ratios de contraste y el resto de `Accessibility checks:` siguen verdes.

### Scenario 6: El gate detecta regresiones responsive

Given una copia temporal con el `box-sizing` universal eliminado, `max-width: 100%` de `.card` retirado, el gutter de `.page` roto, el guard de etiquetas eliminado, `overflow-x: hidden` añadido, un breakpoint fuera de 360/480/736 o un `height` de botón <44 px dentro de una media query de ancho,
When se ejecuta `./init.sh`,
Then sale con código 1, imprime el check concreto en stderr, conserva todos los checks previos y no deja ningún listener en 3502.

### Scenario 7: Consola y red limpias

Given la página servida únicamente en `http://localhost:3502`,
When se carga en los ocho anchos,
Then la consola muestra 0 mensajes, todas las peticiones de página son 2xx/3xx, no hay `/favicon.ico` ni peticiones fallidas, y el servidor se detiene al terminar.

## Repository Research

### Files Inspected

- `AGENTS.md`, `CONSTRAINTS.md` — DoD (AA + navegador móvil/escritorio), reglas durables y excepción WCAG 2.5.8 de los enlaces inline del pie.
- `PROGRESS.md` — estado aceptado hasta `accessibility-baseline`; verificación estándar en 390×844 y 1280×800 con servidor 3413.
- `feature_list.json` — `responsive-baseline` es dependency-ready; verificación pedida: cuatro viewports y áreas táctiles ≥44 px.
- `DESIGN.md` — `Responsive Baseline` (sin scroll desde 320, botones a ancho completo, 44×44, ajustes ~736/~480/~360) y `Layout` (tarjeta 380–420 px en escritorio, `calc(100vw - 2rem)` en móvil, columna única).
- `docs/technical-discovery.md` — stack estático sin build, sin E2E; verificación manual, viewports 320/375/768/escritorio y servidor 3413.
- `index.html` — un `<main class="page">`, una `.card`, Perfil, un `<nav class="links">` con 7 Enlaces y pie; sin estructuras de ancho fijo.
- `styles.css` — 333 líneas; `box-sizing` universal, `.page` con `padding: var(--space-margin) var(--space-gutter)`, `.card` con `width: min(400px, calc(100vw - 2rem)); max-width: 100%;`, `.link-button` con `width: 100%; height: 48px;`, `.link-button__label` con `min-width:0`/`overflow:hidden`/`nowrap`/`ellipsis`; solo existen `@media (hover: hover)` y `@media (prefers-reduced-motion: reduce)`; **no hay ninguna media query de ancho**.
- `init.sh` — 1506 líneas; gate acumulativo con `set -euo pipefail`, fallos a stderr y sin servidor por defecto; ya contiene `card width contract`, el contrato de 6 declaraciones de `.link-button` (incluido `height: 48px`) y `Accessibility checks:`; el hint de servido usa 3413.
- `docs/specs/accessibility-baseline.md`, `docs/validations/accessibility-baseline.md`, `docs/specs/links-order-gradient.md` — formato de spec, estilo de gate y evidencia.

### Current Measurements (planning evidence)

Medido en este worktree con Chrome DevTools y un servidor temporal en 3502 (detenido; puerto libre después). `clientWidth` es el ancho útil (en escritorio descuenta la barra vertical clásica). Alturas de tarjeta incluyen fuentes cargadas y se registran como referencia, no como aserción rígida.

| Viewport | Emulación | clientWidth | Tarjeta (w×h, x) | Primer botón (w×h) | Etiquetas truncadas | Scroll horizontal |
| --- | --- | --- | --- | --- | --- | --- |
| 320×844 | mobile/touch | 320 | 288×861, x=16 | 238×48 | 0 | no |
| 360×844 | mobile/touch | 360 | 328×861, x=16 | 278×48 | 0 | no |
| 375×844 | mobile/touch | 375 | 343×841, x=16 | 293×48 | 0 | no |
| 390×844 | mobile/touch, DPR 3 | 390 | 358×841, x=16 | 308×48 | 0 | no |
| 480×844 | mobile/touch | 480 | 400×841, x=40 | 350×48 | 0 | no |
| 736×800 | desktop | 721 | 400×841, x=160.5 | 350×48 | 0 | no |
| 768×800 | desktop | 753 | 400×841, x=176.5 | 350×48 | 0 | no |
| 1280×800 | desktop | 1265 | 400×841, x=432.5 | 350×48 | 0 | no |

Además: a 320 el texto del pie ocupa 2 líneas (40 px) y la tarjeta crece a 861 px; a 375+ ocupa 1 línea. En los ocho anchos `documentElement.scrollWidth === clientWidth`, `body.scrollWidth === clientWidth`, no hay elementos con `left < 0` ni `right > clientWidth`, y el alto extra produce solo scroll vertical.

### Existing Patterns To Follow

- Gate bash/awk/grep acumulativo, `[ok]` por check, `fail` a stderr, sin servidor por defecto.
- Tokens y valores de layout ya existentes; nada de hex, fuentes ni medidas nuevas.
- Evidencia durable en `feature_list.json` + `PROGRESS.md`; el validador crea `docs/validations/<id>.md`.
- Navegador con Chrome DevTools, recarga ignorando caché y servidor detenido al final.

## Technical Approach

### 1. Decisión: no hay cambio de CSS de producto

La fórmula actual ya resuelve todo el rango:

- `.page` reserva 16 px por lado (`--space-gutter`) y `.card` usa `min(400px, calc(100vw - 2rem))` con `max-width: 100%`, por lo que hasta un ancho útil de 431 px la tarjeta ocupa el ancho útil menos 32 px y desde 432 px se detiene en 400 px.
- `.links`, `.profile-identity` y `.page-footer` usan padding con tokens y ninguna anchura fija; `.link-button` es `width: 100%` con `box-sizing: border-box`.
- `.link-button__label` puede encogerse (`min-width: 0`) y, si el texto no cupiera, se recortaría con ellipsis; la medición demuestra que a 320 no se activa (238 px disponibles para etiquetas de ≤95 px).
- El correo del pie es el token más largo (22 caracteres) y cabe en 238 px; el resto del texto envuelve por espacios.
- Los botones miden 48 px de alto, por encima del mínimo 44 px; los dos enlaces inline del pie siguen bajo la excepción WCAG 2.5.8 ya documentada en `CONSTRAINTS.md`.

Por tanto **no se añaden media queries ni ajustes cosméticos**. `DESIGN.md` pide ajustes “~736/~480/~360”; esta feature demuestra que el layout fluido ya cubre esas zonas y las usa como fronteras de auditoría. Si una futura necesidad real exige overrides, deberán ser mínimos, dentro del set 360/480/736 y sin reducir áreas táctiles (el gate lo vigila).

| Zona | Rango | Comportamiento medido | ¿Override? |
| --- | --- | --- | --- |
| Pequeña | 320–360 | Tarjeta 288–328 px; botones 238–278 px; pie en 2 líneas | No |
| Media | 361–431 | Tarjeta 329–399 px; botones 279–349 px | No |
| Tope | ≥432 (~480) | Tarjeta capada en 400 px | No |
| Escritorio | ≥736 | Tarjeta 400 px centrada; gutter 16 px | No |
| Ancho | 1280 | Igual; `clientWidth` 1265 por scrollbar | No |

### 2. Gate `Responsive checks:` en `init.sh`

Insertar la sección **después de `Accessibility checks:`** y antes del comando de servido. No mover, borrar ni debilitar ningún check previo. Checks nuevos (no duplican los existentes; `card width contract` y los 6 contratos de `.link-button`, incluido su alto de 48 px, siguen siendo la fuente para esas piezas):

1. **Border-box universal:** el bloque `*, *::before, *::after` contiene `box-sizing: border-box;` (impide que padding/borde sumen al ancho declarado).
2. **Gutter de página:** la regla `.page` conserva `padding:` con `var(--space-gutter)` (el gutter que la fórmula `calc(100vw - 2rem)` asume).
3. **Tope de tarjeta:** la regla `.card` conserva `max-width: 100%;` (evita que `100vw` + gutter desborde cuando hay scrollbar clásica).
4. **Guard de etiquetas:** `.link-button__label` conserva `min-width: 0;`, `overflow: hidden;`, `white-space: nowrap;` y `text-overflow: ellipsis;` (shrink seguro en 320; el runtime demuestra que la ellipsis no se activa).
5. **Sin enmascarar overflow:** falla si `styles.css` declara `overflow-x: hidden|clip` en cualquier selector, si `html`/`body`/`.page` declaran `overflow(-x): hidden|clip`, o si un elemento usa `width: 100vw;` como ancho. El `overflow: hidden` de `.link-button__label` es intencional (ellipsis) y no cuenta como máscara; el overflow se arregla, no se oculta.
6. **Inventario de breakpoints:** cada `@media` con `(min-width|max-width: Npx)` debe usar exactamente `360px`, `480px` o `736px` (set de `DESIGN.md`). Si no hay ninguna, imprime `[ok] no width breakpoints; fluid layout covers 320-1280`.
7. **Áreas táctiles dentro de breakpoints:** si una media query de ancho toca `.link-button`, cualquier `height` declarado ahí debe ser ≥44 px. Sin media queries el check pasa vacío y protege cambios futuros.

Esbozo compatible con macOS (adaptar nombres, no la semántica):

```bash
echo "Responsive checks:"

UNIVERSAL_RULE=$(awk '
  /^\*,[[:space:]]*$/ { in_rule = 1 }
  in_rule { print }
  in_rule && /^}/ { exit }
' styles.css)
if printf '%s\n' "$UNIVERSAL_RULE" | grep -qF 'box-sizing: border-box;'; then
  echo "  [ok] universal border-box"
else
  fail 'styles.css must keep *, *::before, *::after { box-sizing: border-box; }'
fi

# ... .page (var(--space-gutter)), .card (max-width: 100%) y
# .link-button__label (min-width/overflow/nowrap/ellipsis) con el mismo patrón awk.

BODY_OR_PAGE_RULES=$(awk '
  /^(html|body|\.page)[[:space:]]*\{/ { in_rule = 1 }
  in_rule { print }
  in_rule && /^}/ { in_rule = 0 }
' styles.css)

if grep -qE '^[[:space:]]*overflow-x:[[:space:]]*(hidden|clip)' styles.css \
  || printf '%s\n' "$BODY_OR_PAGE_RULES" | grep -qE 'overflow(-x)?:[[:space:]]*(hidden|clip)' \
  || grep -qE '^[[:space:]]*width:[[:space:]]*100vw[[:space:]]*;' styles.css; then
  fail 'styles.css must not mask horizontal overflow (overflow-x hidden/clip, body/page masking or width: 100vw)'
fi

WIDTH_BREAKPOINTS=$(grep -oE '\((min|max)-width:[[:space:]]*[0-9]+px' styles.css \
  | grep -oE '[0-9]+px' | sort -u || true)
# Cada valor debe pertenecer a 360px|480px|736px; si está vacío, [ok] fluido.
```

Cerrar con una línea de resumen, p. ej. `[ok] responsive contract (fluid card, full-width 48px buttons, shrink-safe labels)`.

La semántica de los siete checks se prototipó fuera del repo: **pasa con el `styles.css` actual** (`no width breakpoints; fluid layout covers 320-1280`) y **falla con las siete mutaciones** del `Verification Plan` con el stderr esperado. El implementador debe portar esa lógica a `init.sh` conservando mensajes concretos y sin tocar los checks previos.

Además, actualizar el hint final y `RUN_SERVE_COMMAND` de **3413 a 3502** (tres líneas) y listar la matriz: `Manual verification: 320×844, 360×844, 375×844, 390×844, 480×844, 736×800, 768×800 and 1280×800`. El comportamiento del script no cambia: valida y no arranca servidor salvo `RUN_SERVE_COMMAND=1`.

### 3. Documentación durable

- `DESIGN.md` > `Responsive Baseline`: registrar la decisión verificada (layout fluido sin media queries de ancho, fórmula de tarjeta, botones 48 px, guard de etiquetas, fronteras 360/480/736 auditadas) y las mediciones clave. No tocar tokens ni componentes.
- `CONSTRAINTS.md`: añadir reglas MUST/MUST NOT responsive (sin scroll horizontal 320–1280, botones ≥44×44, no `overflow-x` como parche, breakpoints solo 360/480/736 si algún día se añaden, excepción inline del pie sin cambios).
- `docs/technical-discovery.md`: documentar `Responsive checks:`, la matriz de ocho anchos y el puerto 3502.
- `docs/risks-and-open-questions.md`: una nota de que la prueba de “sin scroll horizontal” es runtime (no hay harness E2E) y que `save-contact-vcard` añadirá un octavo botón que debe re-medirse a 320.
- `AGENTS.md`: no necesario — el DoD y la regla de navegador ya exigen AA y validación; la nueva regla vive en `CONSTRAINTS.md`.

## Expected File Changes

- `init.sh` — modificar; sección `Responsive checks:` y puerto/hint 3502. Checks previos intactos.
- `DESIGN.md` — modificar; estado verificado de `Responsive Baseline`.
- `CONSTRAINTS.md` — modificar; reglas durables responsive.
- `docs/technical-discovery.md` — modificar; gate, matriz y puerto.
- `docs/risks-and-open-questions.md` — modificar; nota de verificación runtime.
- `feature_list.json` — implementador; `responsive-baseline` a `passing` con evidencia (no `accepted`).
- `PROGRESS.md` — implementador; estado verificado, puerto de arranque y sesión.
- `docs/specs/responsive-baseline.md` — este spec.
- `docs/validations/responsive-baseline.md` — solo el validador.
- `index.html` / `styles.css` — **sin cambios**. Si aparece overflow real, parar y replanificar; no improvisar CSS.

## Visual Design Impact

- UI involved: yes (verificación), pero **sin cambio visual**: no se toca markup ni CSS.
- Design source: `DESIGN.md` > `Responsive Baseline` y `Layout`.
- Estados/anchors verificados: 320, 360, 375, 390, 480, 736, 768, 1280; foco visible, hover y reduced motion heredados.
- New design artifact: no.
- Riesgo visual: ninguno esperado; el pie pasa a 2 líneas a 320–360 (ya ocurre hoy) sin recorte ni overflow.

## Implementation Plan

1. Ejecutar `bash -n init.sh && ./init.sh` y confirmar baseline verde, sin listener en 3502.
2. Reproducir **antes de editar** la tabla de mediciones en los ocho anchos con `python3 -m http.server 3502 --directory .`; si algún ancho desborda o recorta, detenerse y reportar (no añadir CSS).
3. Añadir `Responsive checks:` tras `Accessibility checks:` y actualizar el hint de servido a 3502 con la matriz.
4. `bash -n init.sh` y `./init.sh`; ejecutar los siete casos negativos en copias temporales fuera del repo y borrarlas.
5. Repetir la matriz completa con recarga fresca ignorando caché; registrar consola, red, geometría, etiquetas y tap targets.
6. Actualizar `DESIGN.md`, `CONSTRAINTS.md`, `docs/technical-discovery.md` y `docs/risks-and-open-questions.md`.
7. Registrar `passing` + evidencia en `feature_list.json` y la sesión en `PROGRESS.md`.
8. Detener el servidor, confirmar 3502 libre y `./init.sh` reiniciable. No marcar `accepted`; no commitear.

## Implementation Tasks

- [ ] Baseline `./init.sh` exit 0 y 3502 libre.
- [ ] Medir y registrar los ocho anchos antes de tocar `init.sh`.
- [ ] Añadir `Responsive checks:` (border-box, gutter, `max-width`, label guard, sin masking/`100vw`, inventario 360/480/736, tap target en breakpoints).
- [ ] Cambiar el hint/`RUN_SERVE_COMMAND` a 3502 y listar la matriz.
- [ ] Probar los siete casos negativos (exit 1, stderr concreto, sin listener).
- [ ] Verificar la matriz completa con Chrome DevTools y el servidor único en 3502.
- [ ] Comprobar foco, reduced motion y ausencia de regresiones AA.
- [ ] Actualizar `DESIGN.md`, `CONSTRAINTS.md`, `docs/technical-discovery.md`, `docs/risks-and-open-questions.md`.
- [ ] Registrar `feature_list.json` en `passing`, `PROGRESS.md` y evidencia; detener el servidor.
- [ ] Verificar que `index.html` y `styles.css` no cambiaron.

## Verification Plan

- `bash -n init.sh` → exit 0.
- `./init.sh` → exit 0, todos los checks previos `[ok]`, las 3 `[warn]` esperadas de metadatos y la nueva sección completa; sin servidor; 3502 libre antes/después.
- Casos negativos en copias temporales (cada uno exit 1, stderr concreto, sin listener; copias eliminadas):
  1. Quitar `box-sizing: border-box;` universal.
  2. Quitar `max-width: 100%;` de `.card`.
  3. Cambiar el padding de `.page` para no usar `var(--space-gutter)`.
  4. Quitar `text-overflow: ellipsis;` (o `min-width: 0;`) de `.link-button__label`.
  5. Añadir `overflow-x: hidden;` a `body`.
  6. Añadir `@media (min-width: 600px) { ... }`.
  7. Añadir `@media (max-width: 360px) { .link-button { height: 40px; } }`.
- Servidor único `python3 -m http.server 3502 --directory .` (libre antes, detenido al final). No usar 3413 para esta validación.

### Browser validation matrix

Todas las filas: recarga fresca ignorando caché, `document.fonts.ready` antes de medir, consola 0 mensajes y red sin fallos. Emulación móvil/táctil para ≤480; desktop para ≥736.

| Viewport | clientWidth esperado | Tarjeta w×h (x) | Botón w×h | Comprobaciones |
| --- | --- | --- | --- | --- |
| 320×844 | 320 | 288×≥841 (16) | 238×48 | `scrollWidth==clientWidth` doc+body; 0 overflow; 0 labels truncadas; pie 2 líneas |
| 360×844 | 360 | 328×≥841 (16) | 278×48 | ídem; frontera baja de `DESIGN.md` |
| 375×844 | 375 | 343×≥841 (16) | 293×48 | ídem |
| 390×844 (DPR 3) | 390 | 358×≥841 (16) | 308×48 | ídem; viewport de referencia del proyecto |
| 480×844 | 480 | 400×≥841 (40) | 350×48 | frontera media; tarjeta ya capada |
| 736×800 | 721 | 400×≥841 (160.5) | 350×48 | frontera alta; centrada |
| 768×800 | 753 | 400×≥841 (176.5) | 350×48 | ídem |
| 1280×800 | 1265 | 400×≥841 (432.5) | 350×48 | sin overflow con scrollbar clásica |

Aserción por fila:
- `documentElement.scrollWidth === documentElement.clientWidth` y `body.scrollWidth === body.clientWidth`; además `scrollWidth` no crece tras `Tab` al primer control.
- Ningún elemento visible con `right > clientWidth + 0.5` o `left < -0.5`.
- `card.width === Math.min(400, clientWidth - 32) ± 0.5`, centrada (`|centro − clientWidth/2| < 1`) y dentro del gutter de 16 px.
- 7 `.link-button`, todos `width === card.width − 50 ± 0.5` (borde + padding 24 px) y `height === 48`; `min(rect.width, rect.height) >= 44`.
- `label.scrollWidth <= label.clientWidth + 0.5` en las 7 etiquetas; pie y Perfil sin `scrollWidth > clientWidth`; correo/handle dentro del bloque del pie.
- Una pasada por viewport: `Tab` → `outline: rgb(88, 92, 229) solid 2px`, `outline-offset: 2px`; en una pasada, `prefers-reduced-motion: reduce` → `transition-duration: 0s` y `transform: none`.
- Consola 0; peticiones de página 2xx/3xx; sin `/favicon.ico`; no se activan destinos externos.

## Evidence To Capture

- Salida completa de `bash -n` y `./init.sh` (nuevos `[ok]`, exit 0, sin servidor).
- Salida de los siete casos negativos y confirmación de 3502 libre.
- Tabla real de los ocho anchos con `clientWidth`, `scrollWidth` doc/body, rectángulos de tarjeta y botones, etiquetas truncadas, overflow, consola y red.
- Comprobación de foco y reduced motion en 320 y 1280.
- Confirmación de `git diff --stat` sin cambios en `index.html`/`styles.css`.
- Docs actualizados; `feature_list.json` en `passing` con evidencia; `PROGRESS.md` con sesión; ruta del registro del validador.

## Validator Checklist

- [ ] `index.html` y `styles.css` no cambiaron; no hay JS, dependencias, tokens ni assets nuevos.
- [ ] `./init.sh` exit 0, checks previos intactos, `Responsive checks:` completo y sin servidor por defecto.
- [ ] Los siete casos negativos fallan con exit 1, stderr concreto y sin listener en 3502.
- [ ] Matriz de ocho anchos reproducida: sin scroll horizontal, tarjeta fluida/capada correcta, botones ≥44×44, sin texto recortado, consola 0 y red limpia.
- [ ] El pie en 2 líneas a 320–360 se registra como esperado, no como recorte.
- [ ] Foco, contraste, `aria-hidden`, `alt`, idioma y reduced motion siguen verdes.
- [ ] `DESIGN.md`, `CONSTRAINTS.md`, `docs/technical-discovery.md` y `docs/risks-and-open-questions.md` reflejan la decisión y el puerto 3502.
- [ ] `feature_list.json` en `passing` (no `accepted`) con evidencia; `PROGRESS.md` actualizado; servidor detenido.
- [ ] No hay trabajo de otras features ni cambios cosméticos inventados.

## Risks And Open Questions

- **Prueba runtime:** “sin scroll horizontal” no es demostrable solo con grep; el gate fija invariantes y la matriz es la prueba real. No existe harness E2E y añadirlo introduciría dependencias prohibidas por `docs/technical-discovery.md`.
- **Métricas de fuente:** si Google Fonts no carga, la pila de respaldo puede cambiar saltos de línea; el guard de etiquetas y los anchos fluidos evitan overflow, pero la matriz debe confirmar 0 etiquetas truncadas.
- **Scrollbar clásica:** en Chrome de escritorio `innerWidth` 736/768/1280 no coincide con `clientWidth` (721/753/1265); medir siempre contra `clientWidth`.
- **Excepción 44 px:** los dos enlaces inline del pie miden ~16–17 px de alto y siguen cubiertos por WCAG 2.5.8; no se modifican. Los siete Enlaces sí cumplen 48 px.
- **Octavo botón futuro:** `save-contact-vcard` añadirá un botón de ancho completo y 48 px; no rompe la fórmula, pero la matriz debe repetirse a 320 cuando se integre.
- **Puerto:** el cambio de hint a 3502 es deliberado para esta validación; no debe quedar ningún proceso escuchando.
- Sin incógnitas bloqueantes.
