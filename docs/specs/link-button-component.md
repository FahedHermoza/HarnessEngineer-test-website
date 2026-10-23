# Feature Implementation Spec: Componente visual de botón de Enlace

## Source Feature

- `id`: `link-button-component`
- `area`: `components`
- `depends_on`: `["design-tokens"]` (accepted)
- `status`: `not_started`
- `source`: `feature_list.json`
- `notes`: Fuente visual: `DESIGN.md` > `components.button-link`. Iconos SVG inline sin dependencias (`docs/technical-discovery.md`).

## Goal

Definir el componente visual reutilizable de botón de Enlace: un control interactivo real, de ancho completo, 48px de alto, esquinas `rounded.md` (6px), etiqueta en mayúsculas con tracking `0.18em` a la izquierda e icono SVG inline de 18px a la derecha, con estados hover/focus visibles y respeto a `prefers-reduced-motion`.

El alcance termina cuando el componente existe como CSS reutilizable en `styles.css`, hay un bloque de demostración temporal en `index.html` que permite verificarlo en el navegador sin URLs reales, y el harness valida de forma no bloqueante la presencia del contrato CSS.

## Non-Goals

- No implementar la lista real de Enlaces, sus etiquetas definitivas, sus URLs ni su orden/progresión (`link-instagram`, `link-whatsapp`, `links-order-gradient`, etc.).
- No implementar el page shell, la tarjeta, el avatar, el Perfil, el pie, la vCard ni Open Graph.
- No definir la variante neutra de "Guardar contacto" ni el tratamiento del degradado para 7–8 botones: pertenecen a `save-contact-vcard` y `links-order-gradient`.
- No crear iconos de marca; la demo usa un chevron genérico. Los iconos reales llegarán con cada feature `link-*`.
- No añadir JavaScript, frameworks, bundlers, preprocesadores, npm ni dependencias.
- No añadir ni modificar tokens de `:root` (el contrato de 51 tokens queda intacto). Las variables internas del componente se declaran en `.link-button`, no en `:root`.
- No implementar estados `:active`, modo oscuro, `forced-colors` ni analítica.
- No eliminar el bloque de demo en esta feature; su retirada se transfiere a `page-shell` (ver "Demo harness").
- No modificar `DESIGN.md`.

## Job Story

When estoy construyendo cualquiera de los Enlaces de la Tarjeta digital,
I want to reutilizar un único componente de botón con el aspecto, las medidas y los estados de `DESIGN.md`,
so I can añadir Enlaces sin reimplementar estilos ni romper la consistencia visual o la accesibilidad.

## Users And Permissions

- Implementador/agente: añade CSS, markup de demo, gate de harness y evidencia; no implementa URLs ni la lista final.
- Visitante (indirecto): verá botones de 48px, con etiqueta legible e icono, navegables con teclado.
- No aplica autenticación, roles ni permisos (`docs/technical-discovery.md`).

## Acceptance Scenarios

### Scenario 1: Contrato visual exacto

Given la página servida en el puerto 3102,
When se inspecciona cualquiera de los botones de demo,
Then su caja mide exactamente 48px de alto, ocupa el 100% del ancho de su contenedor, tiene `border-radius: 6px`, `padding: 0px 20px`, `display: flex`, `justify-content: space-between`, etiqueta `text-transform: uppercase` a 11px/800 con `letter-spacing: 1.98px` y un SVG de 18×18 alineado a la derecha.

### Scenario 2: Asignación reutilizable del degradado

Given el componente base y sus cinco modificadores de tono,
When se renderizan cinco instancias con `link-button--gradient-1`…`--gradient-5`,
Then cada instancia usa el token de color correspondiente (`--color-gradient-1`…`--color-gradient-5`) y ninguna instancia requiere editar la regla base ni hardcodear un color.

### Scenario 3: Hover y foco visibles

Given un botón en escritorio con puntero fino,
When se fuerza `:hover`, o se navega con `Tab` hasta el botón,
Then se aplica `translateY(-1.5px)`, la sombra de hover `0 8px 18px rgba(108,114,234,0.28)` y `filter: brightness(1.03)` con transición de 180ms ease; en foco de teclado además aparece un outline de 2px `--color-accent` con offset 2px.

### Scenario 4: Movimiento reducido

Given `prefers-reduced-motion: reduce` emulado,
When se inspecciona un botón y se fuerza hover/foco,
Then `transition-duration` es `0s` y `transform` es `none`; la sombra y el brillo pueden cambiar instantáneamente, sin animación.

### Scenario 5: Accesibilidad del control

Given el markup del componente,
When se revisa el árbol de accesibilidad,
Then el control es un `<a>` real (o `<button type="button">` si se usa como acción), tiene nombre accesible desde su etiqueta visible, el SVG es decorativo (`aria-hidden="true"`), el foco de teclado es visible y el área táctil es de 48px de alto por todo el ancho.

### Scenario 6: Contraste medido y desviación registrada

Given la etiqueta blanca sobre los cinco tonos,
When se calculan los ratios de contraste,
Then se registran `3.86`, `4.10`, `4.13`, `4.09` y `3.91` a `1`; la desviación respecto a AA 4.5:1 se documenta como riesgo heredado para `accessibility-baseline`, sin inventar colores fuera de la paleta.

### Scenario 7: Harness y demo verificables

Given el estado actual del repositorio,
When se ejecuta `./init.sh` y se sirve con `python3 -m http.server 3102 --directory .`,
Then el script sale `0` con el check del componente, y la demo se renderiza en 390×844 y 1280×800 sin errores de consola ni peticiones fallidas.

## Repository Research

### Files Inspected

- `AGENTS.md` — workflow de arranque, alcance por feature, Definition of Done y validación móvil/escritorio.
- `PROGRESS.md` — `static-bootstrap` y `design-tokens` en `accepted`; siguiente feature lista `page-shell`; este feature también es dependency-ready.
- `feature_list.json` — metadata, dependencia `design-tokens`, verificación y notas de `link-button-component`.
- `DESIGN.md` — `components.button-link` (48px, `rounded.md`, texto `on-primary`, fuente `button-label`) y baseline de accesibilidad (foco visible, `aria-hidden`, `prefers-reduced-motion`).
- `docs/technical-discovery.md` — HTML5 + CSS moderno, sin build, iconos SVG inline, sin dependencias.
- `docs/build-brief.md` — los Enlaces son botones de ancho completo; contenido en español.
- `docs/domain-model.md` — el Enlace tiene tipo, etiqueta, icono, URL y orden (la URL/orden quedan fuera de este feature).
- `docs/specs/design-tokens.md` — convención de tokens y nota de que la ubicación del CSS de componentes se decidiría aquí.
- `docs/specs/static-bootstrap.md`, `docs/validations/design-tokens.md` — estilo de spec, verificación y evidencia esperada.
- `styles.css` — 51 tokens en `:root` + regla base de `body`; sin reglas de componentes.
- `index.html` — `<main>` vacío, `lang="es"`, `<title>`, viewport, Google Fonts Plus Jakarta Sans (400/600/800) y `styles.css`.
- `init.sh` — gate no bloqueante: bootstrap + 51 tokens; no arranca servidor salvo `RUN_SERVE_COMMAND=1`.
- `assets/avatar.jpg` — presente; no se usa en este feature.
- `git status` / `git log` — worktree limpio en `feature/link-button-component`; no existen `ARCHITECTURE.md` ni `CONSTRAINTS.md`.

### Existing Patterns To Follow

- Un único `styles.css` raíz enlazado desde `index.html`; sin build ni imports CSS.
- Tokens como custom properties; los valores de componente no se añaden a `:root`.
- Convención de nombres de tokens existente: `--color-*`, `--text-button-label-*`, `--radius-*`, `--space-*`.
- `init.sh` con `set -euo pipefail`, fallos a stderr, exit `1`, sin servidor por defecto.
- Evidencia durable en `feature_list.json` (`status` + `evidence`) y `PROGRESS.md`.

### Current Gaps

- No existe ningún componente CSS ni markup de producto; `index.html` solo tiene `<main>` vacío.
- No existe `page-shell`, así que no hay contenedor/tarjeta donde montar la demo.
- No hay framework de tests, linter ni comando E2E; la verificación es harness + navegador (`docs/technical-discovery.md`).
- `DESIGN.md` declara AA para etiquetas de botón, pero el blanco sobre los cinco tonos mide 3.86–4.13:1; el conflicto no está registrado en `docs/risks-and-open-questions.md`.

## Technical Approach

### 1. Ubicación del CSS y nombres

- Añadir el componente al final de `styles.css`, bajo un comentario de sección `/* Components — Link button (DESIGN.md > components/button-link) */`.
- Motivo: ya existe una única hoja enlazada, el archivo es pequeño y no hay build/imports; un archivo aparte añadiría una petición y un orden de carga que hoy no se necesita. Si los componentes crecen, se podrá dividir en una feature posterior.
- Clases BEM-ish:
  - `.link-button` — raíz del componente (funciona en `<a>` y `<button>`).
  - `.link-button__label` — etiqueta textual.
  - `.link-button__icon` — SVG decorativo de 18×18.
  - `.link-button--gradient-1` … `.link-button--gradient-5` — asignación de tono.
- Variables internas, declaradas en `.link-button` (no en `:root`): `--link-button-bg`, `--link-button-shadow`, `--link-button-shadow-hover`.
- La demo usa el hook temporal `[data-demo="link-button"]`; no es una clase de producto.

### 2. Markup contract

```html
<a class="link-button link-button--gradient-1" href="#link-button-demo">
  <span class="link-button__label">Enlace uno</span>
  <svg class="link-button__icon" viewBox="0 0 24 24" width="18" height="18"
       fill="none" stroke="currentColor" stroke-width="2"
       stroke-linecap="round" stroke-linejoin="round"
       aria-hidden="true" focusable="false">
    <path d="M9 18l6-6-6-6"/>
  </svg>
</a>
```

- El control real puede ser `<a>` (Enlaces) o `<button type="button" class="link-button">` (acciones futuras); ambos comparten la misma clase.
- El SVG debe pintarse con `currentColor`; el componente fija `color: var(--color-on-primary)` y no fuerza `fill`/`stroke` para permitir iconos de marca.
- La etiqueta visible es el nombre accesible; no se usa `aria-label` salvo que un futuro consumidor lo necesite.

### 3. Contrato visual exacto

| Propiedad | Valor esperado |
| --- | --- |
| `display` | `flex` |
| `width` | `100%` del contenedor (demo: 358px en 390×844; 388px en 1280×800) |
| `height` / rect | `48px` exactos |
| `box-sizing` | `border-box` |
| `padding` | `0px 20px` (`0 1.25rem`) |
| `align-items` | `center` |
| `justify-content` | `space-between` |
| `gap` | `12px` (`--space-sm`) |
| `border` | `0` |
| `border-radius` | `6px` (`var(--radius-md)`) |
| `background` | `var(--link-button-bg)`; por defecto tono 1 |
| `color` | `rgb(255, 255, 255)` (`--color-on-primary`) |
| `font-family` | `--font-family-base` (Plus Jakarta Sans + fallback) |
| `font-size` | `11px` (`--text-button-label-font-size`) |
| `font-weight` | `800` (`--text-button-label-font-weight`) |
| `line-height` | `16px` (`--text-button-label-line-height`) |
| `letter-spacing` | `1.98px` (`--text-button-label-letter-spacing`, 0.18em × 11px) |
| `text-transform` | `uppercase` |
| `text-decoration` | `none` |
| `box-shadow` | `rgba(108, 114, 234, 0.15) 0px 2px 6px 0px` |
| `transition` | `transform 180ms ease, box-shadow 180ms ease, filter 180ms ease` |
| Icono | `18×18`, `flex: 0 0 18px`, borde derecho alineado al padding derecho |
| Etiqueta | borde izquierdo alineado al padding izquierdo; una línea con ellipsis si no cabe |

### 4. Estrategia del degradado

- El componente no decide el orden de los Enlaces ni el degradado global; solo acepta un fondo mediante `--link-button-bg`.
- La regla base usa `--color-gradient-1` como fallback seguro; los cinco modificadores asignan los tokens `--color-gradient-1`…`--color-gradient-5`.
- `background: var(--link-button-bg)` acepta tanto un color sólido (los cinco modificadores actuales) como un gradiente futuro; así `links-order-gradient` puede repetir, interpolar o reasignar tonos sin tocar la regla base.
- La progresión de 7 Enlaces, la repetición de los 5 tonos y cualquier interpolación pertenecen a `links-order-gradient`. Este feature solo demuestra los cinco tonos.
- No se añaden tokens globales nuevos; los valores de sombra y alto son propiedades de componente tomadas literalmente de `DESIGN.md`.

### 5. Estados e interacción

- Hover solo en dispositivos con hover real: `@media (hover: hover)`; evita hover pegajoso en táctil.
- Hover y `:focus-visible` comparten: `transform: translateY(-1.5px)`, `box-shadow: var(--link-button-shadow-hover)`, `filter: brightness(1.03)`.
- `:focus-visible` añade `outline: 2px solid var(--color-accent)` y `outline-offset: 2px`. El outline debe quedar fuera de la caja; no usar `overflow: hidden` en el contenedor inmediato.
- No se define `:active` en este feature.

### 6. Movimiento reducido

- En `@media (prefers-reduced-motion: reduce)`: `transition: none` en `.link-button` y `transform: none` en `:hover`/`:focus-visible`.
- La sombra y el brillo pueden cambiar de forma instantánea (no son movimiento); lo que se elimina es la animación y el desplazamiento.

### 7. Demo harness

- `index.html` mantiene `<main>` y añade un bloque temporal antes de que exista `page-shell`:

```html
<main>
  <!-- Demo temporal de link-button-component. Retirar con page-shell. -->
  <section id="link-button-demo" data-demo="link-button"
           aria-label="Demostración del componente de Enlace">
    <!-- 5 anclas: Enlace uno…Enlace cinco, tonos 1…5, href="#link-button-demo" -->
  </section>
</main>
```

- Etiquetas de demo: "Enlace uno"…"Enlace cinco". No son la lista real, no usan las URLs de `docs/technical-discovery.md` y no representan el orden de 7 Enlaces.
- `href="#link-button-demo"` es un fragmento local; no navega a un destino externo.
- CSS de demo, al final de `styles.css`, agrupado y marcado como temporal:

```css
[data-demo="link-button"] {
  display: flex;
  flex-direction: column;
  gap: var(--space-sm);
  max-width: 420px;
  margin: var(--space-xl) auto;
  padding: 0 var(--space-gutter);
  box-sizing: border-box;
}
```

- El `<head>` debe declarar `<link rel="icon" href="data:,">` (añadido en la reparación de validación) para que Chrome no solicite implícitamente `/favicon.ico`, que el servidor estático responde 404 y produce un error de consola. No requiere archivos ni dependencias.
- El wrapper no es una tarjeta ni un page shell: no tiene fondo de superficie, cabecera, pie ni layout de producto; solo limita el ancho para verificar el botón a ~388px en escritorio y ~358px en móvil.
- **Decisión:** la demo se mantiene al terminar esta feature para que el validator pueda reproducir la verificación. `page-shell` debe reemplazar el contenido de `<main>` y retirar tanto el markup `[data-demo="link-button"]` como su bloque CSS. No se retira antes de la aceptación.

### 8. Accesibilidad

- Control interactivo real (`<a href>` en la demo; `<button type="button">` soportado por CSS).
- Foco de teclado visible con `:focus-visible`; outline de acento `#585ce5` (5.15:1 sobre blanco, 4.89:1 sobre el canvas).
- Icono decorativo: `aria-hidden="true"` y `focusable="false"`; no aporta nombre accesible.
- Área táctil: 48px de alto y ancho completo del contenedor, por encima del mínimo 44×44px.
- La etiqueta se escribe en caja normal en el DOM y se transforma a mayúsculas con CSS; el nombre accesible sigue siendo el texto legible.
- **Contraste (conflicto conocido):** blanco `#ffffff` sobre `gradient-1`…`gradient-5` mide 3.86, 4.10, 4.13, 4.09 y 3.91 a 1. Para texto de 11px/800 el umbral AA es 4.5:1, por lo que no se cumple. Este feature **no** inventa colores fuera de la paleta ni cambia la escala `button-label`; registra la medición y la desviación como riesgo heredado para `accessibility-baseline` (que depende de este componente). Si se exige AA en este feature, hace falta una decisión de diseño sobre los tokens o el tamaño de etiqueta, fuera de alcance.

### 9. Harness / `init.sh`

- Extender `init.sh` con una sección `Component checks:` después de los checks de tokens, sin quitar ni debilitar los existentes.
- Comprobaciones durables (no dependen de la demo, que es temporal):
  - Existe una regla base independiente `.link-button { … }` en `styles.css`.
  - Esa regla contiene: `width: 100%;`, `height: 48px;`, `padding: 0 1.25rem;`, `border-radius: var(--radius-md);`, `justify-content: space-between;`, `text-transform: uppercase;`.
  - `styles.css` contiene `@media (prefers-reduced-motion: reduce)`.
- Imprimir `[ok] link button component contract (N/N)`; en fallo, mensaje a stderr con la declaración que falta y exit `1`. No arrancar servidor.
- No comprobar markup de demo, URLs ni orden de Enlaces en `init.sh`.
- Mantener el modo `RUN_SERVE_COMMAND=1` y el mensaje genérico de servicio. Para la verificación de este feature se usa el puerto único **3102**, no el 8080 del mensaje.

### 10. Cierre

- Registrar evidencia en `feature_list.json` (`status: passing` + `evidence`) y `PROGRESS.md`.
- Añadir a `docs/risks-and-open-questions.md` una línea sobre el contraste 3.86–4.13:1 y su resolución en `accessibility-baseline`.
- El validator crea `docs/validations/link-button-component.md` con su veredicto.

## Expected File Changes

- `styles.css` — modificar; añadir la sección de componente y el bloque CSS temporal de demo.
- `index.html` — modificar; añadir el bloque de demo de cinco anclas dentro de `<main>` y `<link rel="icon" href="data:,">` en `<head>` (evita el 404 implícito de `/favicon.ico`).
- `init.sh` — modificar; añadir el check durable del contrato CSS del componente.
- `feature_list.json` — modificar; `status` + `evidence` (implementador).
- `PROGRESS.md` — modificar; estado verificado + bitácora (implementador).
- `docs/risks-and-open-questions.md` — modificar; registrar el riesgo de contraste.
- `docs/specs/link-button-component.md` — crear; este spec.
- `docs/validations/link-button-component.md` — crear; lo genera el validator.

## Visual Design Impact

- UI involved: yes.
- Design source: `DESIGN.md` > `components.button-link`, `colors`, `typography.button-label`, `rounded.md`, `Components > Botón de Enlace`, `Accessibility Baseline`.
- Screens or states affected: una sola vista; demo de cinco botones en cinco tonos, estados normal, hover, focus-visible y movimiento reducido.
- New design artifact required: no — todos los valores se derivan de `DESIGN.md`; no se inventan colores ni tipografías.

## Durable Documentation Impact

- `ARCHITECTURE.md`: not needed — no se crean capas, dominios ni boundaries nuevos; sigue siendo un sitio estático de una hoja CSS.
- `CONSTRAINTS.md`: not needed — la regla "usar tokens y no colores fuera de paleta" ya vive en `DESIGN.md`; este feature la aplica, no la cambia.
- `AGENTS.md`: not needed — el camino de arranque sigue siendo `./init.sh`; solo se añade un check no bloqueante.
- `docs/technical-discovery.md`: not needed — ya documenta SVG inline y CSS moderno sin dependencias.
- `docs/risks-and-open-questions.md`: update — registrar la desviación de contraste como riesgo heredado.
- `DESIGN.md`: not needed — es fuente de verdad; no se modifica.

## Implementation Plan

1. Añadir la sección del componente en `styles.css` con la regla base, variables internas, modificadores de tono, label, icono, hover/focus y `prefers-reduced-motion`.
2. Añadir el bloque de demo temporal en `index.html` dentro de `<main>` y su CSS `[data-demo="link-button"]`.
3. Extender `init.sh` con el check durable del contrato CSS.
4. Ejecutar `./init.sh` (exit `0`), probar el caso negativo en una copia temporal y verificar en navegador en 390×844 y 1280×800 con el puerto 3102.
5. Registrar evidencia, actualizar `feature_list.json`, `PROGRESS.md` y `docs/risks-and-open-questions.md`.

## Implementation Tasks

- [ ] Añadir `.link-button` en `styles.css` con `width: 100%`, `height: 48px`, `padding: 0 1.25rem`, `border-radius: var(--radius-md)`, flex `space-between`, tipografía `button-label`, uppercase y color `on-primary`.
- [ ] Añadir `.link-button__label` (una línea, ellipsis) y `.link-button__icon` (18×18, `flex: 0 0 18px`, `currentColor`).
- [ ] Añadir `--link-button-bg` con fallback `--color-gradient-1` y los modificadores `--gradient-1`…`--gradient-5`.
- [ ] Añadir sombra normal/hover, transición 180ms ease y estados `@media (hover: hover)` + `:focus-visible` con outline de acento.
- [ ] Añadir `@media (prefers-reduced-motion: reduce)` con `transition: none` y `transform: none`.
- [ ] Añadir el bloque de demo de cinco anclas en `index.html` (labels "Enlace uno"…"Enlace cinco", href `#link-button-demo`, icono chevron `aria-hidden`) y `<link rel="icon" href="data:,">` en `<head>`.
- [ ] Añadir el CSS temporal `[data-demo="link-button"]` (max-width 420px, padding de gutter, gap `space-sm`).
- [ ] Extender `init.sh` con el check del contrato CSS y conservar los checks de bootstrap/tokens.
- [ ] Verificar `./init.sh` exit `0` y el caso negativo (declaración faltante → exit `1`).
- [ ] Verificar en navegador 390×844 y 1280×800: medidas, estados, teclado, reduced motion, consola y red.
- [ ] Registrar ratios de contraste y actualizar `docs/risks-and-open-questions.md`.
- [ ] Registrar evidencia en `feature_list.json` y `PROGRESS.md`.

## Verification Plan

- `bash -n init.sh` — sin errores de sintaxis.
- `./init.sh` — `Harness status: bootstrapped`, checks de bootstrap y tokens `[ok]`, `[ok] link button component contract (N/N)`, exit `0`, sin servidor.
- Caso negativo: en una copia temporal del worktree, eliminar `height: 48px;` de `.link-button` y ejecutar `./init.sh`; debe fallar con mensaje en stderr y exit `1`. Restaurar/eliminar la copia; no dejar el repo roto.
- Servir con `python3 -m http.server 3102 --directory .` y abrir `http://localhost:3102/`; detener solo ese proceso al terminar.
- **390×844 (móvil):** sin scroll horizontal (`scrollWidth <= clientWidth`), cinco botones visibles, altura 48px, ancho 358px, etiqueta a la izquierda e icono 18×18 a la derecha; sin errores de consola; sin peticiones 4xx/5xx (incluida la hoja de Google Fonts).
- **1280×800 (escritorio):** wrapper centrado a 420px, botones de 388px, misma altura/radio/tipografía; sin errores de consola ni peticiones fallidas.
- **Computed styles (DevTools o script de sonda):** `display:flex`, `height:48px`, `padding:0px 20px`, `border-radius:6px`, `justify-content:space-between`, `font-size:11px`, `font-weight:800`, `line-height:16px`, `letter-spacing:1.98px`, `text-transform:uppercase`, `color:rgb(255,255,255)`, `box-shadow` normal, `transition-duration:0.18s`.
- **Hover (desktop):** forzar `:hover`; `transform` serializado como `matrix(1, 0, 0, 1, 0, -1.5)` (o `translateY(-1.5px)`), sombra hover y `filter:brightness(1.03)`.
- **Teclado:** `Tab` hasta cada ancla; outline `2px solid rgb(88, 92, 229)` con offset `2px`; `Enter` activa el fragmento sin errores.
- **Reduced motion:** emular `prefers-reduced-motion: reduce`; `transition-duration:0s` y `transform:none` en hover/foco.
- **Accesibilidad:** el SVG tiene `aria-hidden="true"`; el nombre accesible coincide con la etiqueta; el área táctil es 48px de alto.
- **Contraste:** registrar los ratios de la sección 8; no corregir con colores fuera de paleta.
- E2E: no aplica; el repositorio no tiene harness E2E ni framework de tests. La verificación es `init.sh` + navegador, coherente con `docs/technical-discovery.md`.

## Evidence To Capture

- Salida de `./init.sh` en estado correcto (exit `0`, check del componente).
- Salida del caso negativo (declaración faltante → exit `1`).
- Valores computados de un botón en 390×844 y 1280×800 (alto, ancho, padding, radio, tipografía, tracking, icono).
- Valores computados de hover, focus-visible y `prefers-reduced-motion`.
- Resultado de consola y red en ambos viewports (sin errores, sin 4xx/5xx).
- Ratios de contraste y la nota de riesgo en `docs/risks-and-open-questions.md`.
- Screenshots opcionales de móvil y escritorio.
- `feature_list.json` (`status`, `evidence`) y `PROGRESS.md` actualizados.

## Validator Checklist

- [ ] El componente está en `styles.css` con las clases `.link-button`, `.link-button__label`, `.link-button__icon` y `.link-button--gradient-1`…`-5`.
- [ ] No se añadieron tokens a `:root` ni dependencias, frameworks, bundlers o JavaScript.
- [ ] La regla base mide 48px, ocupa el 100% del contenedor, usa `radius-md`, padding 20px, flex `space-between`, uppercase y tracking 0.18em.
- [ ] El icono mide 18×18, está a la derecha, usa `currentColor` y es `aria-hidden`.
- [ ] La asignación de tono es reutilizable y no implementa el orden/progresión de 7 Enlaces.
- [ ] Hover/focus aplican `translateY(-1.5px)`, sombra hover y `brightness(1.03)` con transición 180ms ease.
- [ ] `prefers-reduced-motion` desactiva transición y transformación.
- [ ] El control es un `<a>`/`<button>` real, con foco de teclado visible y área táctil ≥44×44px.
- [ ] La demo existe, está marcada como temporal, no usa URLs reales y se mantiene hasta la aceptación.
- [ ] `page-shell` queda documentado como responsable de retirar la demo.
- [ ] `./init.sh` sale `0` con el check del componente y falla si falta una declaración del contrato.
- [ ] Verificación en 390×844 y 1280×800 sin errores de consola ni peticiones fallidas, en el puerto 3102.
- [ ] Los ratios de contraste están registrados y la desviación AA está documentada como riesgo heredado.
- [ ] `feature_list.json`, `PROGRESS.md` y `docs/risks-and-open-questions.md` están actualizados.
- [ ] No se implementó ninguna otra feature (URLs, lista, orden, page shell, avatar, vCard, Open Graph).

## Assumptions And Open Questions

### Assumptions

- **Interpretación del degradado:** los cinco valores `gradient-1`…`gradient-5` son tonos por botón que forman una progresión descendente en la pila; no son cinco paradas dentro de un mismo botón. Esta lectura se apoya en "secuencia descendente en la pila de Enlaces" y en la repetición de 5 tonos para 7–8 botones.
- La demo puede vivir en `index.html` porque es la superficie real de verificación y `page-shell` la reemplazará; no se crea una página de demo separada.
- El puerto 3102 es el único usado por esta sesión; el 8080 impreso por `init.sh` es solo una guía genérica.
- No hay E2E ni framework de tests; la verificación es harness + navegador.

### Open Questions

- **Contraste AA:** blanco sobre los cinco tonos mide 3.86–4.13:1, por debajo de 4.5:1. ¿Se resuelve en `accessibility-baseline` ajustando tokens/tamaño de etiqueta o se acepta como excepción visual? Este feature no lo decide ni improvisa colores.
- **Retirada de la demo:** confirmar que `page-shell` reemplaza `<main>` y elimina `[data-demo="link-button"]` y su CSS; hasta entonces la demo queda visible.
- **Iconos de marca:** cada feature `link-*` aportará su SVG inline de 18×18 con `currentColor`; este feature solo valida el contenedor y el chevron genérico.
