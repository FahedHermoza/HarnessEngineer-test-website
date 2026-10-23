# Feature Implementation Spec: Lienzo y tarjeta flotante centrada

## Source Feature

- `id`: `page-shell`
- `area`: `layout`
- `depends_on`: `["design-tokens"]` (satisfied: `accepted`)
- `status`: `not_started` (at planning time; this spec does not change it)
- `source`: `feature_list.json`
- `notes`: `DESIGN.md` → `Layout`, `Shapes`, `components.card`, `Responsive Baseline`.

## Goal

Establecer el esqueleto visual de la Tarjeta digital: un lienzo `#f7f9ff` que ocupa el viewport y una tarjeta blanca flotante, centrada horizontal y verticalmente en escritorio, con ancho máximo de 400px, ancho `calc(100vw - 2rem)` en móvil y los márgenes seguros de `DESIGN.md`.

La tarjeta queda **vacía a propósito** al terminar esta feature. El objetivo es que su geometría, superficie, radio, borde, sombra y centrado sean observables en el navegador, de modo que `profile-*`, `link-*` y `page-footer` inserten contenido sin redefinir el contenedor.

## Non-Goals

- No renderizar Perfil, avatar, Nombre, Handle, Tagline, Enlaces, botones, vCard, pie ni placeholders textuales.
- No definir padding interno, divisores, ritmo vertical entre secciones, estados hover/focus, transiciones ni `prefers-reduced-motion` (features posteriores).
- No tocar los 51 tokens, `DESIGN.md` ni los docs de discovery; no añadir frameworks, JS, npm, dependencias, favicon, `theme-color`, Open Graph, modo oscuro ni i18n.
- No usar `overflow-x: hidden`; el layout debe ajustarse por construcción.
- No modificar `feature_list.json` más allá del registro de evidencia del implementador/validador.

## Job Story

When abro la Tarjeta digital desde el móvil o el escritorio,
I want to ver una única tarjeta blanca flotante, legible y centrada sobre el lienzo,
so I can percibir una composición ordenada y tener un contenedor estable donde aparecerán el Perfil y los Enlaces.

## Users And Permissions

- Visitante anónimo: ve el lienzo y la tarjeta; no hay autenticación, roles ni estado.
- Implementador/agente: crea el markup y CSS del shell, amplía el gate de `init.sh` y registra evidencia.
- Validador: reproduce las mediciones en navegador y el gate de `init.sh` de forma independiente.

## Acceptance Scenarios

### Scenario 1: Tarjeta centrada en escritorio

Given la página servida en `http://localhost:3101` con viewport 1280×800,
When se inspecciona la tarjeta,
Then mide 400px de ancho, está centrada horizontal y verticalmente (`x = 440`, `y = 240` con `min-height` provisional de 320px), tiene fondo `#ffffff`, radio 12px, borde 1px `rgba(0,0,0,0.04)` y la sombra de `DESIGN.md`.

### Scenario 2: Ancho móvil y centrado

Given viewports de 390×844, 375×844 y 320×844,
When se carga la página,
Then el ancho de la tarjeta es `390−32 = 358px`, `375−32 = 343px` y `320−32 = 288px` respectivamente, con 16px de separación a cada lado, centrada verticalmente y sin scroll horizontal.

### Scenario 3: Viewports intermedios sin scroll horizontal

Given viewports de 768×800 y 1280×800,
When se carga la página,
Then la tarjeta está limitada a 400px, centrada (`x = 184` y `x = 440`) y `document.documentElement.scrollWidth <= clientWidth` en todos los casos.

### Scenario 4: Contenido más alto que el viewport no se recorta

Given una tarjeta temporalmente más alta que el área disponible (p. ej. override `min-height: 1200px` en DevTools) y viewport 390×600,
When se hace scroll,
Then el borde superior de la tarjeta sigue siendo accesible (no queda por encima de `scrollTop = 0`) porque el centrado usa márgenes automáticos, no `justify-content: center`.

### Scenario 5: El gate detecta un shell roto

Given `index.html` sin `class="page"`/`class="card"`, o `styles.css` sin la regla `.card` o sin el contrato de ancho,
When se ejecuta `./init.sh`,
Then sale con código distinto de `0`, imprime el check fallido en stderr y no arranca ningún servidor.

## Repository Research

### Files Inspected

- `AGENTS.md`, `PROGRESS.md`, `feature_list.json` — alcance, Definition of Done, estado (`design-tokens` `accepted`) y metadata de `page-shell`; sin bloqueos.
- `DESIGN.md` — layout (380–420px, `calc(100vw - 2rem)`), shapes (12–16px), `components.card`, responsive y accesibilidad.
- `docs/technical-discovery.md`, `docs/build-brief.md`, `docs/domain-model.md`, `docs/risks-and-open-questions.md`, `CONTEXT.md` — stack estático sin build, una sola vista móvil-first, contenedor de Perfil/Enlaces y límites del MVP.
- `index.html`, `styles.css`, `init.sh` — `lang="es"`, Google Fonts, `<main>` vacío; 51 tokens + `body`; gate no bloqueante que sugiere 8080.
- `docs/specs/design-tokens.md`, `docs/validations/design-tokens.md` — formato de spec y evidencia aceptada del prerrequisito.

### Current State

- El `body` ya aplica `#f7f9ff`, `#2d3139` y Plus Jakarta Sans con fallback; `./init.sh` pasa (exit `0`, 51/51 tokens).
- `<main>` está vacío y sin clases: no hay tarjeta ni altura de viewport, ni reset de `box-sizing`.
- No existe contenedor de página, tarjeta, borde ni sombra; tampoco framework de tests, linter o E2E.

### Existing Patterns To Follow

- Sitio estático sin build; CSS plano con custom properties y salida desde la raíz.
- Un único `styles.css`; los tokens se consumen con `var(--…)` sin duplicar valores globales.
- `init.sh` con `set -euo pipefail`, checks acumulativos, fallo a stderr, sin servidor por defecto y evidencia en `feature_list.json`/`PROGRESS.md`.

### Current Gaps

- No hay contenedor que ocupe el viewport ni centrado vertical, ni convención de clases para el shell (esta feature fija `.page` y `.card`).
- No hay tarjeta visible con la superficie, radio, borde y sombra de `DESIGN.md`.
- `init.sh` no comprueba markup/layout y sugiere 8080 en lugar del puerto único 3101 de este worktree.

## Technical Approach

1. **Markup semántico mínimo** en `index.html`:
   ```html
   <main class="page">
     <article class="card"></article>
   </main>
   ```
   `<main>` es el lienzo/contenedor de centrado; `<article class="card">` es la Tarjeta digital y queda vacío. No se añade texto, imagen ni placeholder.
2. **Reset de box-sizing** al inicio de `styles.css` (después de `:root`, antes de `body`):
   ```css
   *,
   *::before,
   *::after {
     box-sizing: border-box;
   }
   ```
   Necesario para que `min-height` del lienzo incluya su padding y no genere scroll vertical artificial.
3. **Lienzo** (`.page`): ocupa al menos el viewport y aplica los márgenes seguros de `DESIGN.md` (`--space-margin` vertical = 1.5rem, `--space-gutter` horizontal = 1rem):
   ```css
   .page {
     display: flex;
     flex-direction: column;
     align-items: center;
     min-height: 100vh;
     min-height: 100dvh;
     padding: var(--space-margin) var(--space-gutter);
   }
   ```
   `100vh` es fallback para navegadores sin `dvh`. No se fija `height`, para permitir que la página crezca con contenido futuro.
4. **Tarjeta** (`.card`):
   ```css
   .card {
     flex-shrink: 0;
     width: min(400px, calc(100vw - 2rem));
     max-width: 100%;
     min-height: 20rem;
     margin-block: auto;
     background-color: var(--color-surface);
     border: 1px solid rgba(0, 0, 0, 0.04);
     border-radius: var(--radius-xl);
     box-shadow:
       0 18px 45px -10px rgba(25, 30, 48, 0.08),
       0 8px 16px -6px rgba(25, 30, 48, 0.03);
   }
   ```
   - `min(400px, calc(100vw - 2rem))` cumple a la vez el máximo 380–420px (se elige 400px) y el ancho móvil exacto `calc(100vw - 2rem)`; `max-width: 100%` evita desbordamiento si un scrollbar clásico reduce el ancho útil.
   - `min-height: 20rem` (320px) es un **piso provisional de visibilidad** porque la tarjeta está vacía; no es un valor de `DESIGN.md` ni un token. Cualquier contenido futuro superará esa altura y puede eliminarse entonces.
   - `margin-block: auto` centra verticalmente cuando hay espacio y colapsa a `0` cuando la tarjeta es más alta que el viewport, evitando el recorte superior típico de `justify-content: center`.
   - Sombra y borde son literales de `DESIGN.md > components.card`; no se crean tokens globales nuevos. No se define padding interno ni divisores: pertenecen a las features de contenido.
5. **Gate no bloqueante en `init.sh`** (sin quitar checks existentes):
   - `index.html` contiene `class="page"` y `class="card"`.
   - `styles.css` define selectores `.page` y `.card` al inicio de línea.
   - `styles.css` contiene el contrato `min(400px, calc(100vw - 2rem))`.
   - Salida esperada: `[ok] page shell markup`, `[ok] page shell styles`, `[ok] card width contract`.
   - Cambiar el comando de servido impreso y `RUN_SERVE_COMMAND` a `python3 -m http.server 3101 --directory .`.
6. Registrar evidencia en `feature_list.json` y `PROGRESS.md`.

## Expected File Changes

- `index.html` — modificar; añadir `class="page"` a `<main>` e insertar `<article class="card">` vacío.
- `styles.css` — modificar; añadir reset de `box-sizing`, reglas `.page` y `.card`; no tocar `:root` ni la regla `body`.
- `init.sh` — modificar; añadir checks del shell, probar casos negativos y usar el puerto 3101 en el comando sugerido.
- `feature_list.json` — modificar; `page-shell` a `passing` con evidencia (implementador).
- `PROGRESS.md` — modificar; estado verificado y sesión (implementador).
- `docs/specs/page-shell.md` — crear; este spec (planner).
- No se crean archivos nuevos de producto ni assets.

## Visual Design Impact

- UI involved: yes.
- Design source: `DESIGN.md` (`Layout`, `Shapes`, `components.card`, `Responsive Baseline`).
- Screens or states affected: única vista; estado shell vacío en móvil y escritorio.
- New design artifact required: no — los valores salen de `DESIGN.md`; el único valor no derivado es el piso provisional de 320px, documentado arriba.

## Durable Documentation Impact

- `ARCHITECTURE.md`: not needed — no cambian stack, capas ni boundaries; sigue siendo HTML/CSS estáticos.
- `CONSTRAINTS.md`: not needed — no se introduce una regla MUST/MUST NOT nueva más allá de usar tokens y no añadir dependencias, ya cubierto por `DESIGN.md` y `docs/technical-discovery.md`.
- `AGENTS.md`: not needed — el camino de arranque sigue siendo `./init.sh`; solo se amplían sus checks.
- Other docs: `docs/technical-discovery.md` — not needed; no cambia stack ni despliegue. `docs/risks-and-open-questions.md` — not needed; los riesgos de esta feature se documentan aquí.

## Implementation Plan

1. Añadir `<main class="page"><article class="card"></article></main>` en `index.html`.
2. Añadir reset de `box-sizing` y reglas `.page`/`.card` en `styles.css` con los valores exactos del contrato.
3. Ampliar `init.sh` con los checks del shell y el puerto 3101; probar casos negativos en copia temporal.
4. Servir en 3101, verificar navegador 320/375/390/768/1280 y registrar evidencia en `feature_list.json` y `PROGRESS.md`.

## Implementation Tasks

- [ ] Sustituir `<main></main>` por `<main class="page">` con `<article class="card">` vacío.
- [ ] Añadir reset universal de `box-sizing` sin alterar `:root` ni `body`.
- [ ] Implementar `.page` con flex column, `min-height: 100vh`/`100dvh` y padding de tokens.
- [ ] Implementar `.card` con `width: min(400px, calc(100vw - 2rem))`, `max-width: 100%`, piso `20rem`, `margin-block: auto`, superficie, borde, radio y sombra exactos.
- [ ] Ampliar `init.sh` con checks de markup, selectores y contrato de ancho; cambiar el servido a 3101; mantenerlo no bloqueante.
- [ ] Probar `bash -n init.sh`, `./init.sh` (exit `0`) y los casos negativos del gate en copia temporal.
- [ ] Verificar en navegador 390×844 y 1280×800, 320/375/768 sin scroll horizontal y el caso de tarjeta más alta que el viewport.
- [ ] Registrar evidencia en `feature_list.json` y `PROGRESS.md`.

## Verification Plan

### Gate

- `bash -n init.sh` → sintaxis OK.
- `./init.sh` → `Harness status: bootstrapped`, checks previos `[ok]`, `[ok] page shell markup`, `[ok] page shell styles`, `[ok] card width contract`; exit `0`; sin servidor.
- Casos negativos en copia temporal (no tocar el repo): quitar `class="card"` de `index.html`; renombrar `.card` en `styles.css`; quitar `min(400px, calc(100vw - 2rem))`. Cada uno debe salir `1`, imprimir el check fallido y no arrancar servidor.

### Browser

- `python3 -m http.server 3101 --directory .` (o `RUN_SERVE_COMMAND=1 ./init.sh`) y abrir `http://localhost:3101`.
- Confirmar con `curl -sI` que `/` y `/styles.css` responden `200`; la fuente de Google Fonts responde `200` o no se registra como petición fallida.
- Medir con `getBoundingClientRect()` y `getComputedStyle()`:

  | Viewport | Ancho tarjeta | `x` | `y` | Scroll horizontal |
  | --- | --- | --- | --- | --- |
  | 320×844 | 288px | 16 | 262 | no |
  | 375×844 | 343px | 16 | 262 | no |
  | 390×844 | 358px | 16 | 262 | no |
  | 768×800 | 400px | 184 | 240 | no |
  | 1280×800 | 400px | 440 | 240 | no |

  `y` asume el piso provisional `20rem` (320px) y el padding vertical de 24px: `24 + (altoViewport − 48 − 320) / 2`. El validador debe comprobar además que el espacio superior e inferior son iguales (centrado), no solo el número.
- Comprobar estilos computados de `.card`: `background-color: rgb(255, 255, 255)`, `border-radius: 12px`, `border-top-width: 1px`, `border-top-color: rgba(0, 0, 0, 0.04)`, `box-shadow` distinto de `none`; `body` conserva `rgb(247, 249, 255)`.
- Comprobar `document.documentElement.scrollWidth <= document.documentElement.clientWidth` y `document.body.scrollWidth <= clientWidth` en 320, 375, 390, 768 y 1280.
- Consola sin errores y red sin peticiones fallidas de `index.html`, `styles.css` ni la fuente.
- Resistencia a contenido alto: en DevTools aplicar temporalmente `.card { min-height: 1200px }` a 390×600, confirmar que la tarjeta empieza en `y = 24` (no negativa) y que se puede hacer scroll hasta el final; retirar el override.
- E2E: no aplica; no existe harness E2E y añadir uno introduciría dependencias prohibidas por `docs/technical-discovery.md`. La verificación es gate no bloqueante + navegador.
- `init.sh` debe seguir ejecutando el gate no bloqueante, no iniciar servidores salvo `RUN_SERVE_COMMAND=1` e imprimir el comando de servido en 3101.

## Evidence To Capture

- Salida de `./init.sh` en estado correcto (exit `0`) y de los tres casos negativos.
- `curl -sI` de `/` y `/styles.css`; consola sin errores y red sin fallos.
- Tabla de geometría (ancho, `x`, `y`, scroll horizontal) en 320/375/390/768/1280, estilos computados de `.card`/`body` y resultado del override de tarjeta alta a 390×600.
- Screenshots 390×844 y 1280×800 si se guardan (no obligatorio) y `feature_list.json`/`PROGRESS.md` actualizados.

## Risks And Mitigations

- **Piso de 320px inventado para una tarjeta vacía:** podría confundirse con la altura final. Mitigación: documentado como provisional, no es token y el contenido futuro lo superará.
- **Recorte superior al crecer la tarjeta:** `justify-content: center` recorta el inicio cuando el hijo excede el viewport. Mitigación: `margin-block: auto` (Scenario 4).
- **Scroll horizontal por `100vw` con scrollbar clásico:** `100vw` incluye el scrollbar. Mitigación: `max-width: 100%`.
- **Unidades de viewport en móvil:** `100vh` cambia con la barra del navegador. Mitigación: fallback `100vh` + `100dvh`.
- **`box-sizing` global y puerto 3101:** afectan a futuro CSS/entorno. Mitigación: reset estándar sin reglas previas en conflicto y comprobar `lsof -nP -iTCP:3101 -sTCP:LISTEN` sin cambiar de puerto en silencio.
- **Sin E2E automatizado:** cobertura manual; se compensa con el gate y mediciones reproducibles.

## Acceptance Criteria

- [ ] `<main class="page">` contiene una `<article class="card">` vacía; no hay contenido de Perfil, Enlaces ni Pie.
- [ ] La tarjeta mide 400px como máximo en escritorio y `calc(100vw - 2rem)` en móvil (288/343/358px en 320/375/390), centrada horizontal y verticalmente en 1280×800 y 390×844.
- [ ] Fondo `#ffffff`, radio `12px`, borde `1px rgba(0,0,0,0.04)` y sombra exacta de `DESIGN.md`; el lienzo conserva `#f7f9ff`.
- [ ] Márgenes seguros `1.5rem` vertical / `1rem` horizontal y sin scroll horizontal en 320, 375, 390, 768 y 1280.
- [ ] Una tarjeta más alta que el viewport no queda recortada por arriba.
- [ ] `./init.sh` sigue siendo no bloqueante, pasa en estado correcto, detecta shell roto y usa 3101 en el comando sugerido.
- [ ] Consola sin errores, red sin peticiones fallidas, evidencia registrada y sin frameworks, JS, dependencias, tokens nuevos ni cambios en `DESIGN.md`.

## Validator Checklist

- [ ] Implementation stays within this feature's scope (shell only, no content).
- [ ] Acceptance scenarios pass.
- [ ] Verification evidence is present.
- [ ] Persistent E2E coverage was added/updated when an E2E harness exists, or the spec explains why it is not needed (no harness exists).
- [ ] `feature_list.json` and `PROGRESS.md` were updated correctly.
- [ ] No unrelated product behavior or extra feature work was added.
- [ ] `.page` and `.card` match the exact contract; `:root`, tokens and `body` were not altered.
- [ ] The card is visible while empty and the provisional `20rem` floor is documented, not treated as a final design token.

## Assumptions And Open Questions

### Assumptions

- `1rem = 16px` en el navegador de verificación; por eso `20rem = 320px`.
- Los navegadores objetivo soportan `min()`, `dvh` y custom properties (navegadores modernos según `docs/risks-and-open-questions.md`).
- El puerto 3101 está libre en este worktree.
- La tarjeta vacía es un estado intermedio aceptable; el contenido llega en features posteriores.

### Open Questions

- Padding interno definitivo de la tarjeta y ancho exacto entre 380–420px: se difieren a las features de contenido; 400px es la elección de esta feature.
- ¿Se elimina el piso `min-height: 20rem` cuando el contenido real supere 320px? Decisión para la feature que complete el contenido; no bloquea este shell.
