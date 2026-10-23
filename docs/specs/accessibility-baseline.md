# Feature Implementation Spec: Base de accesibilidad AA

## Source Feature

- `id`: `accessibility-baseline`
- `area`: `quality`
- `depends_on`: `["page-shell", "link-button-component"]` (both `accepted`)
- `status`: `not_started` (at planning time; this spec does not change it)
- `source`: `feature_list.json`
- `notes`: `DESIGN.md` > `Accessibility Baseline`, `Colors`, `Components`; `docs/technical-discovery.md` > `Testing and Verification`; `docs/risks-and-open-questions.md` (two inherited contrast risks).

## Goal

Convertir la Tarjeta digital actual en una base AA verificable: todos los controles son elementos interactivos reales, cada uno tiene foco visible, el texto y los iconos alcanzan contraste AA, los iconos decorativos quedan fuera del árbol de accesibilidad, el avatar conserva su `alt`, el documento declara `lang="es"` y la página respeta `prefers-reduced-motion`.

La mayor parte de la semántica y del foco ya está implementada y aceptada. Esta feature es una **auditoría + remediación mínima**, no un rediseño. El único cambio visual es el oscurecimiento controlado de dos grupos de tokens para resolver los dos contrastes heredados; además se marca el idioma de la Tagline inglesa y se añade un gate durable a `init.sh`. No se añade JavaScript, framework, bundler ni dependencia.

## Non-Goals

- No rediseñar la tarjeta, el layout, la tipografía, los espaciados, el alto de 48px de los botones ni la escala `button-label`.
- No cambiar el color de la etiqueta/icono de los botones: siguen en `#ffffff`; se ajustan los fondos.
- No tocar los colores del pie, que ya cumplen AA (texto 13.04:1, enlaces 5.15:1).
- No retirar la demo temporal `[data-demo="link-button"]` ni asignar el orden/tono definitivo de los siete Enlaces: pertenece a `links-order-gradient`.
- No implementar vCard, botón de contacto, responsive breakpoints, despliegue, `og-image` ni metadatos nuevos.
- No traducir ni reescribir la Tagline; solo marcar su idioma.
- No añadir modo oscuro, modo de alto contraste, i18n, analítica ni animaciones.
- No añadir JavaScript, `<script>`, frameworks, bundlers, preprocessors, npm, dependencias ni assets.
- No cambiar destinos externos ni activar enlaces externos durante la automatización.
- No marcar la feature como `accepted`; el implementador deja `passing` y el validador acepta.

## Job Story

When navego la Tarjeta digital con teclado, lector de pantalla o baja visión,
I want que cada control sea alcanzable, tenga foco visible, un nombre correcto y texto legible sobre su fondo,
so I can usar todos los canales de contacto sin depender del ratón ni adivinar colores.

## Users And Permissions

- Visitante anónimo: usa la misma tarjeta; no hay autenticación, roles ni estado.
- Usuario de teclado/lector de pantalla: recorre los 14 controles en orden, oye nombres en el idioma correcto y ve un foco inequívoco.
- Implementador/agente: ajusta tokens, añade `lang="en"` a la Tagline, actualiza docs y extiende el gate; registra evidencia.
- Validador: reproduce el gate, las mediciones de navegador y Lighthouse, y comprueba que no hay regresiones de layout ni de otras features.

## Acceptance Scenarios

### Scenario 1: Contraste AA en los cinco tonos de botón

Given la tarjeta blanca renderizada con los siete Enlaces reales y la demo de cinco tonos,
When se mide blanco `#ffffff` sobre cada token `--color-gradient-1..5`,
Then el contraste es ≥4.5:1 en reposo (4.89–5.24:1) y ≥4.5:1 con el `filter: brightness(1.03)` de hover/foco (≥4.66:1); las etiquetas y los iconos siguen siendo blancos.

### Scenario 2: Contraste AA de la Tagline y del pie

Given la Tagline a 13px/400 y el Handle a 26px/600 sobre blanco,
When se inspeccionan sus colores computados,
Then ambos usan `#6b7280` y miden ≈4.83:1; el Nombre sigue en `#2d3139` (13.04:1), el texto del pie en `#2d3139` (13.04:1) y los enlaces del pie en `#585ce5` (5.15:1).

### Scenario 3: Navegación solo con teclado y foco visible

Given la página cargada en 390×844 y 1280×800,
When se pulsa `Tab` desde el documento hasta recorrer todos los controles y luego `Shift+Tab` en sentido inverso,
Then se alcanzan los 14 controles en orden DOM (7 Enlaces, 5 de la demo, 2 del pie), cada uno con `:focus-visible`, `outline: 2px solid #585ce5` y `outline-offset: 2px`, sin trampas ni controles omitidos.

### Scenario 4: Semántica, iconos y avatar

Given el documento servido,
When se inspecciona el árbol de accesibilidad y el markup,
Then `<html lang="es">`, la Tagline tiene `lang="en"`, el avatar tiene un `alt` descriptivo no vacío, los 12 SVG son decorativos (`aria-hidden="true"` y `focusable="false"`), y los 14 controles son `<a>` reales con `href` no vacío, sin `role="button"`, `onclick` ni `href="#"`.

### Scenario 5: Movimiento reducido

Given `prefers-reduced-motion: reduce` emulado,
When se hace hover y foco sobre un botón de Enlace,
Then `transition-property: none`, `transition-duration: 0s` y `transform: none`, el outline de foco sigue visible y no hay ninguna otra transición/animación en la página.

### Scenario 6: El gate detecta regresiones

Given una copia temporal con un token de contraste revertido, un SVG sin `aria-hidden`, el `alt` vacío, el outline de foco eliminado, el bloque de movimiento reducido roto, un control falso o el viewport con zoom deshabilitado,
When se ejecuta `./init.sh`,
Then sale con código distinto de `0`, imprime el check fallido en stderr y no arranca ningún servidor.

### Scenario 7: Sin errores y con Lighthouse alto

Given la página servida únicamente en `http://localhost:3413`,
When se carga en 390×844 y 1280×800 y se ejecuta Lighthouse móvil de accesibilidad,
Then la consola tiene 0 mensajes, no hay peticiones fallidas ni `/favicon.ico`, no hay scroll horizontal, y la puntuación de accesibilidad es ≥95 (objetivo 100) sin auditorías `critical`/`serious`.

## Repository Research

### Files Inspected

- `AGENTS.md` — Definition of Done, validación en 390×844 y 1280×800, reglas de alcance y reinicio con `./init.sh`.
- `PROGRESS.md` — estado aceptado de `page-shell`, `link-button-component` y las features de Enlaces; riesgos de contraste heredados pendientes.
- `feature_list.json` — metadata de `accessibility-baseline`; dependencias satisfechas; `init.sh` y Lighthouse móvil como verificación.
- `CONTEXT.md`, `docs/build-brief.md`, `docs/domain-model.md` — vocabulario, contenido fijo en español y edge cases; no cambian.
- `DESIGN.md` — tokens, regla “texto e icono siempre `#ffffff`”, baseline de accesibilidad (AA, foco, `aria-hidden`, `alt`, `lang`, reduced motion).
- `docs/technical-discovery.md` — stack estático sin build, iconos SVG inline, verificación manual y Lighthouse móvil; sin harness E2E.
- `docs/risks-and-open-questions.md` — riesgos heredados: etiquetas blancas 3.86–4.13:1 y Tagline ≈4.43:1.
- `index.html` — 14 anclas (12 `.link-button` + 2 `.page-footer__link`), 12 SVG decorativos, `alt="Retrato de Fahed Hermoza"`, `<html lang="es">`, sin `<script>`.
- `styles.css` — 51 tokens; `.link-button` con hover/focus y `transition`; `.page-footer__link:focus-visible`; bloque `@media (prefers-reduced-motion: reduce)`; Tagline y Handle con `--color-on-surface-variant`.
- `init.sh` — gate de 939 líneas con bootstrap, tokens, componente, page shell, perfil, pie, identidad, enlaces y metadatos; puerto 3301; no arranca servidor salvo `RUN_SERVE_COMMAND=1`.
- `docs/specs/*.md`, `docs/validations/*.md` — convenciones de spec, gate textual/awk, evidencia y aceptación.

### Current State

- `./init.sh` actual sale `0`; todos los checks previos pasan y hay 3 `[warn]` no bloqueantes de `og-image`/URL pública.
- Los controles ya son `<a>` reales; el foco ya existe en `.link-button` y `.page-footer__link`; los SVG ya son decorativos; el avatar ya tiene `alt`; `lang="es"` ya está; reduced motion ya desactiva el botón.
- Los fallos AA medidos son de contraste: blanco sobre los cinco tonos (3.86, 4.10, 4.13, 4.09, 3.91:1) y `#717886` sobre blanco (4.437:1). Además, la Tagline inglesa no declara `lang="en"` (WCAG 3.1.2) y los enlaces inline del pie miden <44px (excepción WCAG 2.5.8, a documentar).
- La demo temporal de cinco botones sigue presente y es la única superficie que ejercita los cinco tonos en el navegador; se conserva.
- No existen `CONSTRAINTS.md` ni `ARCHITECTURE.md`; no hay `package.json`, runner de tests ni E2E.

### Existing Patterns To Follow

- Una sola hoja `styles.css`; tokens en `:root`; valores de componente fuera de `:root`; clases BEM-ish.
- `init.sh` con `set -euo pipefail`, checks acumulativos, fallos a stderr, `exit 1`, sin servidor por defecto; extracción de reglas con `awk`.
- Evidencia durable en `feature_list.json` (`status` + `evidence`) y `PROGRESS.md`; el validador crea `docs/validations/<id>.md`.
- Verificación de navegador con Chrome DevTools en 390×844 y 1280×800, consola y red limpias; sin activar destinos externos.

### Current Gaps

- No hay un gate global de accesibilidad: el `alt` solo se comprueba exacto en `profile-avatar`, los iconos se comprueban por Enlace (no todos los SVG), el foco solo en el pie y reduced motion solo por presencia de la media query; no hay contraste, idioma de partes ni contrato completo de foco/reduced motion.
- `init.sh` sugiere el puerto 3301; esta feature exige 3413.
- `DESIGN.md` contiene valores que no cumplen AA y no documenta la decisión de remediación.
- Los dos riesgos heredados siguen abiertos en `docs/risks-and-open-questions.md`.
- La Tagline inglesa no está marcada con `lang="en"` (WCAG 3.1.2 AA).
- No hay evidencia Lighthouse móvil de accesibilidad.

## Technical Approach

### 1. Decisión de contraste: oscurecer solo los tokens necesarios

Se mantienen las etiquetas y los iconos en `#ffffff` (regla explícita de `DESIGN.md`) y se oscurecen los fondos y el token de texto secundario. No se añaden tokens, colores sueltos, filtros de texto, sombras ni tamaños nuevos.

| Token | Actual | Nuevo | Blanco en reposo | Blanco con hover/foco `brightness(1.03)` |
| --- | --- | --- | --- | --- |
| `--color-gradient-1` | `#6876f0` | `#5a67d1` | 4.889:1 | 4.658:1 |
| `--color-gradient-2` | `#736deb` | `#645fcc` | 5.184:1 | 4.936:1 |
| `--color-gradient-3` | `#8168e8` | `#705aca` | 5.244:1 | 4.993:1 |
| `--color-gradient-4` | `#9362e6` | `#8055c8` | 5.184:1 | 4.920:1 |
| `--color-gradient-5` | `#a85ee2` | `#9252c5` | 4.958:1 | 4.743:1 |
| `--color-on-surface-variant` | `#717886` | `#6b7280` | 4.834:1 | n/a |

Justificación:

- Cada canal sRGB de los cinco tonos se multiplica por ≈0.87 (redondeo al entero más cercano). Se conserva el matiz y el orden lavanda→violeta; el degradado se percibe ~13% más profundo, sin cambiar la identidad Serene Bio Card.
- El margen de hover/foco es necesario porque `.link-button:hover` y `:focus-visible` aplican `filter: brightness(1.03)`: con los tonos originales el contraste caería por debajo de 4.5:1.
- `--color-on-surface-variant` pasa a `#6b7280` (4.83:1), conservando la jerarquía secundaria frente al Nombre `#2d3139` (13.04:1). Afecta Handle y Tagline; ambos mejoran.
- El pie no cambia: `--color-on-surface` (13.04:1) y `--color-accent` (5.15:1) ya cumplen. `--color-outline` (`#767685`, 4.47:1) no se usa como texto y supera 3:1 para elementos no textuales; se deja intacto.

Alternativas rechazadas:

1. Texto oscuro sobre los degradados: rompe la regla de etiqueta/icono blancos de `DESIGN.md` y la identidad visual.
2. Subir la etiqueta a “texto grande” (≥18.66px bold) para usar 3:1: rompe la escala `button-label` 11px/800 y el componente de 48px.
3. Sombra/overlay/scrim bajo el texto: el contraste WCAG no se calcula sobre sombras y añade ruido visual.
4. Aceptar la desviación como excepción: la feature existe precisamente para cerrar la base AA.
5. Cambiar solo la Tagline con un color inline: crea un valor one-off; actualizar el token es consistente y también mejora el Handle.

### 2. Semántica, idioma y movimiento: verificar, no reescribir

- No cambiar la estructura, las clases ni los 51 tokens restantes.
- Añadir solo `lang="en"` a la Tagline existente (WCAG 3.1.2, Language of Parts): el documento sigue `lang="es"` y no se traduce el texto.
- Mantener el `alt` actual del avatar, los 12 SVG con `aria-hidden="true"`/`focusable="false"`, los `<a>` reales y los dos `:focus-visible`.
- Mantener el bloque `@media (prefers-reduced-motion: reduce)` actual; el único movimiento de la página es la transición/transformación de `.link-button`, ya desactivada. No añadir animaciones.

Markup exacto de la Tagline:

```html
<p class="profile-identity__tagline" lang="en">Software Engineer &amp; Speaker &amp; Builder</p>
```

### 3. Gate de accesibilidad en `init.sh`

Añadir una sección `Accessibility checks:` antes del comando de servido, sin debilitar ni reordenar los checks existentes. Cambiar el comando de servido y `RUN_SERVE_COMMAND=1` de 3301 a **3413**. El script sigue ejecutando checks y sale `1` con stderr ante fallo; no arranca servidor por defecto.

Checks obligatorios:

1. **Documento:** `<html lang="es">` exacto; viewport con `width=device-width` y sin `user-scalable=no` ni `maximum-scale`.
2. **Idioma de partes y `alt`:** Tagline con `class="profile-identity__tagline" lang="en"`; `<img class="profile-avatar">` con `alt` no vacío.
3. **Controles reales:** exactamente 14 `<a>`; exactamente 12 son `<a class="link-button…">` y 2 son `<a class="page-footer__link">`; todas con `href` no vacío; ninguna clase `link-button`/`page-footer__link` aparece en un elemento que no sea `<a>`; sin `role="button"`, `onclick`/`onkeydown`/`onkeypress` inline, `href="#"` ni `href=""`.
4. **Iconos decorativos:** cada tag de apertura `<svg …>` contiene `aria-hidden="true"` y `focusable="false"`; el separador del pie conserva `aria-hidden="true"`.
5. **Foco visible:** `.link-button:focus-visible` y `.page-footer__link:focus-visible` contienen `outline: 2px solid var(--color-accent);` y `outline-offset: 2px;`; no existe `outline: none` ni `outline: 0` en `styles.css`.
6. **Reduced motion:** existe `@media (prefers-reduced-motion: reduce)` y su bloque contiene `transition: none;` y `transform: none;` para `.link-button`.
7. **Contraste exacto + calculado:** exigir los seis valores de la tabla y calcular con awk:
   - blanco `--color-on-primary` contra `--color-gradient-1..5` en reposo y simulando `brightness(1.03)`;
   - `--color-on-surface-variant` contra `--color-surface`;
   - `--color-accent` contra `--color-surface`;
   - `--color-on-surface` contra `--color-surface`.
   Todos ≥4.5:1. Imprimir cada ratio y un total de 13 comprobaciones (5 tonos en reposo + 5 con hover/foco + Tagline + enlaces del pie + texto del pie), p. ej. `[ok] accessibility contrast contract (13/13)`.
8. **Cableado del componente:** `.link-button` contiene `color: var(--color-on-primary);` y `background: var(--link-button-bg);`; las cinco reglas `.link-button--gradient-N` asignan `--link-button-bg: var(--color-gradient-N);`; el hover/foco conserva `filter: brightness(1.03);`.

Implementación del cálculo: helper `token_value` con `awk`, parser hexadecimal manual (no usar `strtonum`, ausente en awk de macOS), linearización sRGB y luminancia relativa WCAG. Para el hover, multiplicar cada canal por 1.03 y limitar a 255 antes de calcular. Un fallo imprime la pareja y el ratio y termina con `Harness status: FAILED - accessibility contrast contract ...`, sin servidor.

### 4. Documentación durable

- `DESIGN.md`: actualizar los seis valores del front matter y de la sección `Colors`; añadir a `Accessibility Baseline` la tabla/justificación de contraste y la nota de que las etiquetas siguen blancas.
- `CONSTRAINTS.md`: crear reglas MUST/MUST NOT de la base AA (controles reales, foco visible, contraste en reposo/hover/foco, iconos decorativos, `alt`, idioma, reduced motion, no regresiones).
- `AGENTS.md`: añadir `CONSTRAINTS.md` a `Read First` y una regla de trabajo/DoD sobre mantener la base AA y el gate de `./init.sh`.
- `docs/technical-discovery.md`: documentar el gate de accesibilidad y la verificación con Lighthouse móvil en 3413; mantener la nota de que no hay E2E.
- `docs/risks-and-open-questions.md`: marcar resueltos los dos contrastes heredados con los nuevos valores/ratios; registrar la excepción inline de WCAG 2.5.8 para los enlaces del pie y que Lighthouse es una comprobación manual.

## Expected File Changes

- `styles.css` — modify; solo los seis valores de token de la tabla; ninguna otra regla.
- `index.html` — modify; solo `lang="en"` en la Tagline.
- `init.sh` — modify; sección `Accessibility checks:` + puerto 3413; checks previos intactos.
- `DESIGN.md` — modify; valores de tokens y nota de accesibilidad.
- `CONSTRAINTS.md` — create; reglas durables AA.
- `AGENTS.md` — modify; `Read First`, regla de trabajo y DoD de accesibilidad.
- `docs/technical-discovery.md` — modify; verificación/gate/Lighthouse.
- `docs/risks-and-open-questions.md` — modify; riesgos resueltos y excepción inline.
- `feature_list.json` — modify by implementer; `accessibility-baseline` a `passing` con evidencia (no `accepted`).
- `PROGRESS.md` — modify by implementer/validator; estado verificado y sesión.
- `docs/validations/accessibility-baseline.md` — create by validator, no por el implementador.
- No se crean assets, JS, hojas CSS, frameworks, lockfiles ni dependencias.

## Visual Design Impact

- UI involved: yes.
- Design source: `DESIGN.md` (Serene Bio Card), que se actualiza en esta misma feature.
- Screens or states affected: única tarjeta; siete Enlaces reales, cinco botones de demo, Handle, Tagline, dos enlaces del pie; estados reposo, hover y `:focus-visible`; 390×844 y 1280×800.
- New design artifact required: no — es una revisión de valores de tokens, no un layout/componente nuevo.
- Cambio visual: botones ~13% más profundos (mismo orden lavanda→violeta, etiqueta/icono blancos, misma forma/altura/tipografía); Handle/Tagline ligeramente más oscuros. Sin cambios de espaciado, tamaño, radios ni estructura.
- La demo temporal se conserva y se usa para verificar los cinco tonos; no se reestiliza ni se retira.

## Durable Documentation Impact

- `ARCHITECTURE.md`: not needed — no cambian capas, runtime, dependencias ni superficies.
- `CONSTRAINTS.md`: create — la feature establece reglas MUST/MUST NOT de accesibilidad para todo trabajo futuro.
- `AGENTS.md`: update — `CONSTRAINTS.md` en `Read First`, regla de trabajo y DoD de accesibilidad; cambia la verificación estándar.
- `DESIGN.md`: update — fuente de verdad de los tokens corregidos y de la decisión AA.
- `docs/technical-discovery.md`: update — gate de accesibilidad y Lighthouse móvil en 3413.
- `docs/risks-and-open-questions.md`: update — cerrar los dos riesgos de contraste y registrar la excepción inline.
- `CONTEXT.md`, `docs/build-brief.md`, `docs/domain-model.md`: not needed — no cambian producto, dominio ni vocabulario.
- `feature_list.json` / `PROGRESS.md`: update by implementer/validator — estado y evidencia.

## Implementation Plan

1. Ejecutar `bash -n init.sh && ./init.sh` y registrar el baseline actual (exit 0, 51 tokens, checks previos `[ok]`).
2. Actualizar en `styles.css` solo los seis valores de token de la tabla.
3. Añadir `lang="en"` a la Tagline en `index.html`.
4. Actualizar `DESIGN.md`, crear `CONSTRAINTS.md` y actualizar `AGENTS.md`, `docs/technical-discovery.md` y `docs/risks-and-open-questions.md`.
5. Extender `init.sh` con `Accessibility checks:` y cambiar el puerto de servido a 3413, preservando todos los checks previos.
6. Ejecutar `bash -n init.sh` y `./init.sh`; comprobar exit 0, nuevos `[ok]`, ningún listener en 3413 y los 3 `[warn]` preexistentes de metadatos.
7. Ejecutar los casos negativos en copias temporales fuera del repo y borrarlas.
8. Verificar en navegador 390×844 y 1280×800 con un único servidor en 3413: consola, red, geometría, teclado, reduced motion, contraste y árbol de accesibilidad.
9. Ejecutar Lighthouse móvil de accesibilidad sobre `http://localhost:3413` y registrar score/auditorías.
10. Actualizar `feature_list.json` a `passing` con evidencia y `PROGRESS.md`; detener el servidor y dejar 3413 libre. No marcar `accepted`.

## Implementation Tasks

- [ ] Registrar el baseline de `./init.sh` y confirmar los ratios actuales 3.86–4.13:1 y 4.437:1.
- [ ] Actualizar los seis tokens de `styles.css` a los valores exactos de la tabla.
- [ ] Añadir `class="profile-identity__tagline" lang="en"` en `index.html`.
- [ ] Actualizar `DESIGN.md` (front matter, `Colors`, `Accessibility Baseline`).
- [ ] Crear `CONSTRAINTS.md` y actualizar `AGENTS.md`, `docs/technical-discovery.md` y `docs/risks-and-open-questions.md`.
- [ ] Añadir `Accessibility checks:` a `init.sh` (8 checks) y cambiar el servido a 3413.
- [ ] Verificar `bash -n init.sh` y `./init.sh` con exit 0, sin servidor.
- [ ] Probar casos negativos: token revertido, SVG sin `aria-hidden`, `alt` vacío, sin outline, reduced motion roto, control falso, zoom deshabilitado.
- [ ] Verificar 390×844 y 1280×800: 0 mensajes de consola, sin peticiones fallidas/favicon, sin scroll horizontal.
- [ ] Verificar teclado: 14 controles en orden, `Shift+Tab`, outline 2px acento/offset 2px, activación del fragmento de demo sin salir de la página.
- [ ] Verificar reduced motion: `transition-property: none`, `transition-duration: 0s`, `transform: none`, outline visible.
- [ ] Medir contraste computado de los cinco tonos, Tagline, Handle y pie; comprobar árbol de accesibilidad (idioma, nombres, SVG ocultos, un `h1`).
- [ ] Ejecutar Lighthouse móvil de accesibilidad en 3413 y registrar score/auditorías.
- [ ] Scope guard: 51 tokens, sin JS/dependencias/assets, demo/layout intactos, sin trabajo de otras features.
- [ ] Actualizar `feature_list.json` a `passing` con evidencia y `PROGRESS.md`; no `accepted`.
- [ ] Detener el servidor, confirmar 3413 libre y `./init.sh` reiniciable.

## Verification Plan

- `bash -n init.sh` → exit 0.
- `./init.sh` → exit 0; checks previos `[ok]`, nuevos checks de accesibilidad `[ok]`, 3 `[warn]` de metadatos preexistentes, sin listener en 3413.
- Casos negativos en copias temporales fuera del repo (cada uno exit 1, stderr concreto, sin listener; copias eliminadas):
  1. `--color-gradient-1: #6876f0` → falla contraste.
  2. `--color-on-surface-variant: #717886` → falla contraste de Tagline.
  3. Un SVG sin `aria-hidden="true"` → falla iconos decorativos.
  4. `alt=""` en el avatar → falla `alt`.
  5. `.link-button:focus-visible` sin `outline`/`outline-offset` → falla foco visible.
  6. Bloque reduced motion sin `transition: none`/`transform: none` → falla reduced motion.
  7. `<div class="link-button">` o ancla sin `href` → falla controles reales.
  8. Viewport con `user-scalable=no` → falla viewport.
- Servidor único `python3 -m http.server 3413 --directory .` (detenido al terminar; 3413 libre antes/después). No usar 3101/3201/3301.
- **390×844:** consola 0 mensajes; sin 4xx/5xx ni `/favicon.ico`; tarjeta 358px en x=16; sin scroll horizontal; los 14 controles visibles/alcanzables; foco `outline: rgb(88, 92, 229) solid 2px`, offset 2px; hover/foco con `filter: brightness(1.03)`; reduced motion 0s/`none`; contraste medido ≥4.5.
- **1280×800:** misma limpieza de consola/red; `clientWidth` puede ser 1265 por la barra de scroll vertical, así que la tarjeta de 400px se centra en el área de contenido (x≈432.5) y no hay overflow horizontal; mismos checks de foco/contraste/reduced motion.
- **Teclado:** `Tab` desde el documento recorre 14 controles en orden DOM; `document.activeElement`, `:focus-visible`, outline y orden registrados; `Shift+Tab` invierte; `Enter` solo en el primer enlace de demo (`#link-button-demo`); no se activan destinos externos.
- **Reduced motion:** `matchMedia('(prefers-reduced-motion: reduce)').matches === true`; hover/foco sin transición/transform; outline visible; sin otras transiciones.
- **Lighthouse móvil:** `chrome-devtools_lighthouse_audit` sobre 3413, `device: "mobile"`, `mode: "navigation"`; registrar score de accesibilidad, auditorías fallidas y nodos. Gate: score ≥95 (objetivo 100), sin fallos `critical`/`serious`; cualquier fallo restante debe ser una excepción WCAG documentada (p. ej., enlaces inline del pie bajo 2.5.8) y no puede ser de contraste, nombre, rol o foco.
- **E2E:** no existe harness persistente (`package.json`, Playwright/Cypress) y añadirlo introduciría dependencias prohibidas por `docs/technical-discovery.md`. La cobertura de esta página estática se cubre con `init.sh` + Chrome DevTools + Lighthouse, como en las features aceptadas previas.

## Evidence To Capture

- Diff de `styles.css` con los seis tokens y tabla de ratios (reposo/hover) recalculada.
- Atributo `lang="en"` de la Tagline y confirmación de `<html lang="es">`.
- Salida de `./init.sh` con los nuevos `[ok]` y exit 0, sin servidor.
- Salida de los 8 casos negativos (exit 1, stderr, sin listener).
- Navegador 390×844 y 1280×800: consola 0, red sin fallos/favicon, geometría, secuencia de foco, estilos de outline, reduced motion, contraste computado y árbol de accesibilidad.
- Lighthouse móvil: score, auditorías fallidas y nodos; ruta del reporte (temporal, no binario en el repo).
- Docs actualizados: `DESIGN.md`, `CONSTRAINTS.md`, `AGENTS.md`, `docs/technical-discovery.md`, `docs/risks-and-open-questions.md`.
- `feature_list.json` `accessibility-baseline` en `passing` con evidencia; `PROGRESS.md` con sesión/estado; `docs/validations/accessibility-baseline.md` por el validador.
- Scope guard: 51 tokens, sin `<script>`, sin frameworks/dependencias/assets, demo y layout intactos, sin otras features.

## Validator Checklist

- [ ] El cambio de producto se limita a los seis tokens y al `lang="en"` de la Tagline; no hay rediseño ni cambios de layout/tipografía/pie.
- [ ] Los valores de `styles.css` coinciden con la tabla y con `DESIGN.md`; los ratios son ≥4.5:1 en reposo y hover/foco.
- [ ] `CONSTRAINTS.md`, `AGENTS.md`, `docs/technical-discovery.md` y `docs/risks-and-open-questions.md` reflejan la base AA y los riesgos resueltos.
- [ ] `./init.sh` sale 0, conserva todos los checks previos, añade los de accesibilidad y no arranca servidor; el puerto es 3413.
- [ ] Los casos negativos fallan con exit 1, stderr correcto y sin listener.
- [ ] Navegador 390×844 y 1280×800: consola 0, sin peticiones fallidas/favicon, sin scroll horizontal.
- [ ] Teclado: 14 controles en orden, foco visible 2px acento/offset 2px, `Shift+Tab`, sin trampas; solo se activa el fragmento de demo.
- [ ] Reduced motion: 0s/`none`, outline visible, sin otras transiciones.
- [ ] Semántica: `lang="es"`, Tagline `lang="en"`, `alt` del avatar, 12 SVG `aria-hidden`/`focusable="false"`, 14 anclas reales.
- [ ] Lighthouse móvil en 3413: score ≥95 (objetivo 100), sin fallos `critical`/`serious`; excepciones documentadas.
- [ ] `feature_list.json` en `passing` (no `accepted`) con evidencia; `PROGRESS.md` actualizado; servidor detenido y 3413 libre.
- [ ] No hay JS, frameworks, dependencias, assets ni trabajo de otras features; la demo temporal se conserva.
- [ ] La justificación de no añadir E2E está registrada y es coherente con el stack sin dependencias.
