# Feature Implementation Spec: Avatar circular con halo

## Source Feature

- `id`: `profile-avatar`
- `area`: `profile`
- `depends_on`: `["page-shell"]` (satisfied: `accepted`)
- `status`: `not_started` (at planning time; this spec does not change it)
- `source`: `feature_list.json`
- `notes`: `DESIGN.md` > `components.avatar`, `Shapes`, `Components > Perfil`, `Accessibility Baseline`. `assets/avatar.jpg` ya existe; no se genera ni reemplaza.

## Goal

Mostrar `assets/avatar.jpg` como avatar circular dentro de la tarjeta de `page-shell`: imagen de 88×88, `object-fit: cover`, anillo blanco de 3px y `alt` descriptivo en español.

El bloque del Perfil queda preparado para que `profile-identity` añada Nombre, Handle y Tagline, pero esta feature no implementa esos textos, el fallback de iniciales ni otro contenido.

## Non-Goals

- No implementar Nombre, Handle ni Tagline (`profile-identity`), ni el fallback "FH" (`avatar-fallback`).
- No generar, recortar, optimizar ni reemplazar `assets/avatar.jpg`; se usa el archivo existente tal cual. No se crean assets, favicon ni metadatos Open Graph.
- No implementar Enlaces, degradado, vCard, Pie ni accesibilidad global.
- No añadir JavaScript, frameworks, bundlers, preprocesadores, npm ni dependencias de producto.
- No añadir ni modificar tokens de `:root` (el contrato de 51 tokens queda intacto). 88px y 3px son valores de componente, como los 48px de `.link-button`.
- No modificar `.page`, `.card`, `body`, `:root`, `.link-button` ni la demo temporal `[data-demo="link-button"]`; su retirada corresponde a las features de enlaces.
- No modificar `DESIGN.md` ni los docs de discovery.

## Job Story

When abro la Tarjeta digital desde el móvil o el escritorio,
I want to ver la foto de Fahed como un avatar circular nítido y bien integrado en la tarjeta,
so I can reconocer de inmediato de quién es la Tarjeta antes de leer los Enlaces.

## Users And Permissions

- Visitante anónimo: ve el avatar y su texto alternativo; no hay autenticación, roles ni estado.
- Implementador/agente: añade markup, CSS, checks del harness y evidencia; no toca el asset.
- Validador: reproduce el gate y las mediciones en navegador de forma independiente.

## Acceptance Scenarios

### Scenario 1: Avatar visible y circular en móvil

Given la página servida en `http://localhost:3201` con viewport 390×844,
When se carga la tarjeta,
Then el avatar está dentro de `.card`, mide 88×88, está centrado horizontalmente, usa `object-fit: cover`, tiene `border-radius` de círculo completo y halo blanco de 3px, sin scroll horizontal.

### Scenario 2: Avatar centrado en escritorio

Given la página servida con viewport 1280×800,
When se carga la tarjeta,
Then la tarjeta conserva 400px de ancho y el avatar mide 88×88, centrado, con el mismo `object-fit` y halo; no hay scroll horizontal.

### Scenario 3: Asset y texto alternativo

Given el avatar renderizado,
When se inspeccionan la red, la imagen y el árbol de accesibilidad,
Then `assets/avatar.jpg` responde `200 image/jpeg`, la imagen está decodificada (`naturalWidth = 460`, `naturalHeight = 460`, `complete = true`) y su nombre accesible es `Retrato de Fahed Hermoza`.

### Scenario 4: El harness detecta un avatar roto

Given una copia temporal sin `class="profile-avatar"`, sin el `alt` esperado, sin la regla `.profile-avatar`, sin `object-fit: cover;` o sin `assets/avatar.jpg`,
When se ejecuta `./init.sh`,
Then sale con código distinto de `0`, imprime el check fallido en stderr y no arranca servidor.

## Repository Research

### Files Inspected

- `AGENTS.md` — Definition of Done, validación 390×844 y 1280×800, una feature por sesión y no añadir dependencias.
- `PROGRESS.md` — cuatro features `accepted`; `profile-avatar` es la primera lista. El "Current Verified State" aún apunta al worktree `link-button-component` (dato obsoleto que el implementador debe corregir).
- `feature_list.json` — metadata, dependencia `page-shell` aceptada, comportamiento y verificación de `profile-avatar`.
- `DESIGN.md` — `components.avatar` (`size: 88px`, `rounded.full`), `Shapes` (círculo con anillo blanco de 3px), `Components > Perfil` (`object-fit: cover`, halo) y baseline de accesibilidad (`alt` descriptivo).
- `docs/build-brief.md`, `CONTEXT.md`, `docs/domain-model.md` — el Perfil incluye avatar; contenido visible en español; Perfil = avatar + Nombre + Handle + Tagline; el fallback es un edge case separado.
- `docs/technical-discovery.md`, `docs/risks-and-open-questions.md` — sitio estático sin build; `assets/avatar.jpg` presente; sin dependencias; riesgo de avatar ausente para `avatar-fallback`.
- `docs/specs/page-shell.md`, `docs/specs/link-button-component.md`, `docs/validations/page-shell.md` — contrato `.page`/`.card`, patrón de checks CSS con `awk` y evidencia previa.
- `index.html`, `styles.css` — tarjeta con la demo temporal de cinco botones; 51 tokens, `body`, `.page`, `.card`, `.link-button` y demo; no hay avatar ni reglas de Perfil.
- `init.sh` — gate no bloqueante con bootstrap, tokens, componente y page shell; no verifica el avatar; sugiere el puerto 3101. Ejecutado en esta planificación: exit `0` (bootstrap 3/3, tokens 51/51, link-button 6/6 y page shell).
- `assets/avatar.jpg` — JPEG baseline 460×460, presente y no vacío.
- `.github-flow/profile-avatar.md`, `.github-flow/run-prompt.md` — alcance, rama/worktree y puerto local 3201.
- `git status` / `git log` — worktree limpio en `feature/profile-avatar`; no existen `ARCHITECTURE.md` ni `CONSTRAINTS.md`.

### Existing Patterns To Follow

- Un único `styles.css` raíz, sin imports ni build; tokens con `var(--…)`.
- Valores de componente en px dentro de su regla; no se añaden tokens globales.
- `init.sh` con `set -euo pipefail`, checks acumulativos, fallo a stderr, sin servidor por defecto y `RUN_SERVE_COMMAND=1` para el modo manual.
- Evidencia durable en `feature_list.json` (`status` + `evidence`) y `PROGRESS.md`; un único servidor local detenido al terminar.

### Current Gaps

- `index.html` no tiene avatar ni bloque de Perfil; `styles.css` no tiene `.profile`/`.profile-avatar`.
- `init.sh` no verifica markup, `alt`, regla CSS ni asset, y su puerto impreso (3101) no coincide con el 3201 de este worktree.
- No existe harness E2E ni framework de tests.
- `PROGRESS.md` está desactualizado respecto al worktree actual.

## Technical Approach

### 1. Markup: bloque de Perfil dentro de la tarjeta

Insertar el bloque antes de la demo, dentro de `<article class="card">`; no se modifica ni elimina la demo:

```html
<article class="card">
  <header class="profile">
    <img
      class="profile-avatar"
      src="assets/avatar.jpg"
      alt="Retrato de Fahed Hermoza"
      width="88"
      height="88"
    >
  </header>

  <!-- Demo temporal de link-button-component; no se toca en esta feature. -->
  <section id="link-button-demo" data-demo="link-button" ...>
    ...
  </section>
</article>
```

- `.profile` agrupa el Perfil y es el punto de extensión para `profile-identity`.
- `<header>` es el bloque introductorio del artículo; no se añade `<h1>` todavía.
- `width`/`height` reservan la proporción 1:1 y evitan saltos de layout; el tamaño visible lo fija el CSS.
- `alt="Retrato de Fahed Hermoza"` es el valor exacto de esta feature; no usar `alt=""` ni un texto genérico.
- No se envuelve la imagen en un enlace ni se añade interacción.

### 2. CSS: Perfil y avatar

Añadir una sección propia después de `.card` y antes de `.link-button`, sin alterar reglas existentes:

```css
/* Components — Profile avatar (DESIGN.md > components.avatar) */
.profile {
  display: flex;
  flex-direction: column;
  align-items: center;
  padding-block: var(--space-xl);
}

.profile-avatar {
  display: block;
  width: 88px;
  height: 88px;
  border-radius: var(--radius-full);
  object-fit: cover;
  box-shadow: 0 0 0 3px var(--color-surface);
}
```

- **88×88:** la caja del `<img>` mide exactamente 88×88 y la foto la ocupa completa; no se reduce el contenido.
- **Anillo de 3px:** halo exterior con `box-shadow: 0 0 0 3px var(--color-surface)`. El elemento sigue midiendo 88×88 y el halo visual suma 3px por lado (footprint 94×94), sin afectar al layout ni al centrado. No se usa `border`, que reduciría la foto a 82×82.
- **Blanco:** `--color-surface` es `#ffffff`; no se inventa color ni se añade sombra decorativa.
- **Círculo:** `border-radius: var(--radius-full)` (9999px) recorta la imagen en círculo.
- **Separación:** `padding-block: var(--space-xl)` aplica el margen `space-xl` arriba y abajo del Perfil de `DESIGN.md > Layout`. No se añade padding horizontal; `profile-identity` decidirá el ancho del texto.
- No se modifica `.card` (sigue sin padding interno) ni `.page`.

### 3. Integración y harness

- La demo permanece después del Perfil con su CSS/markup intactos; el padding del Perfil y el `margin` de `[data-demo="link-button"]` dan separación vertical.
- El `min-height: 20rem` de `.card` sigue siendo un piso; el contenido real lo supera y la tarjeta crece sin recortes.
- Ampliar `init.sh` con `Profile checks:` después de `Page shell checks:`:
  - Markup: `index.html` contiene `class="profile-avatar"`, `src="assets/avatar.jpg"` y `alt="Retrato de Fahed Hermoza"`.
  - Asset: `[ -f assets/avatar.jpg ] && [ -s assets/avatar.jpg ]`.
  - Regla base extraída con `awk` (patrón de `.link-button`), sin aceptar `.profile-avatar__*`.
  - Contrato CSS (5 declaraciones): `width: 88px;`, `height: 88px;`, `border-radius: var(--radius-full);`, `object-fit: cover;`, `box-shadow: 0 0 0 3px var(--color-surface);`.
  - Salida: `[ok] profile avatar markup`, `[ok] avatar asset exists`, `[ok] .profile-avatar base rule exists`, `[ok] profile avatar contract (5/5)`.
  - En fallo: stderr con el check/declaración faltante y `Harness status: FAILED - …`, exit `1`, sin servidor.
- Cambiar el comando impreso y `RUN_SERVE_COMMAND` a `python3 -m http.server 3201 --directory .`; `./init.sh` sigue sin arrancar servidor por defecto.

### 4. Cierre

- Registrar evidencia en `feature_list.json` (`status: passing` + `evidence`) y `PROGRESS.md` (estado, sesión y corrección de la ruta obsoleta).
- El validator crea `docs/validations/profile-avatar.md`.
- No se actualizan `DESIGN.md`, `docs/technical-discovery.md` ni `docs/risks-and-open-questions.md`: no cambia stack, diseño ni riesgos de producto.

## Expected File Changes

- `index.html` — modificar; añadir `<header class="profile">` con el `<img class="profile-avatar" ...>` antes de la demo.
- `styles.css` — modificar; añadir `.profile` y `.profile-avatar`; no tocar `:root`, `body`, `.page`, `.card`, `.link-button` ni la demo.
- `init.sh` — modificar; añadir `Profile checks:` y usar 3201 en el comando sugerido/`RUN_SERVE_COMMAND`; mantener el gate no bloqueante.
- `feature_list.json` — modificar por el implementador; `profile-avatar` a `passing` con evidencia. El planner no cambia el estado.
- `PROGRESS.md` — modificar por el implementador; estado verificado, bitácora y corrección de la ruta obsoleta.
- `docs/specs/profile-avatar.md` — crear; este spec (planner).
- `docs/validations/profile-avatar.md` — crear; lo genera el validator.
- `assets/avatar.jpg` — no modificar; solo se referencia. No se crean archivos nuevos de producto ni dependencias.

## Visual Design Impact

- UI involved: yes.
- Design source: `DESIGN.md` > `components.avatar`, `Shapes`, `Components > Perfil`, `Layout`, `Accessibility Baseline`.
- Screens/states: única vista; estado normal con avatar cargado. Imagen ausente/fallback queda para `avatar-fallback`.
- New design artifact required: no — 88px, 3px, círculo y blanco salen de `DESIGN.md`; `box-shadow` es una decisión técnica para mantener la foto a 88×88.
- El anillo blanco sobre la tarjeta blanca no genera contraste de color; se verifica por estilo computado, sin añadir sombras ni colores no especificados.

## Durable Documentation Impact

- `ARCHITECTURE.md`: not needed — no cambian stack, capas ni boundaries.
- `CONSTRAINTS.md`: not needed — no se introduce una regla MUST/MUST NOT nueva; "tokens, sin dependencias, no generar imágenes" ya vive en `DESIGN.md` y `docs/technical-discovery.md`.
- `AGENTS.md`: not needed — el camino de arranque sigue siendo `./init.sh`; solo se añade un check no bloqueante y se ajusta el puerto sugerido del worktree.
- Other docs: `docs/technical-discovery.md` — not needed; ya documenta el avatar. `docs/risks-and-open-questions.md` — not needed; el riesgo de avatar ausente pertenece a `avatar-fallback`. `DESIGN.md` — not needed; es fuente de verdad. `PROGRESS.md` y `feature_list.json` — evidencia de implementación/validación.

## Implementation Plan

1. Añadir el bloque de Perfil con el `<img>` del avatar en `index.html`, antes de la demo.
2. Añadir `.profile` y `.profile-avatar` en `styles.css` con el contrato exacto.
3. Extender `init.sh` con los checks y ajustar el puerto sugerido a 3201.
4. Ejecutar gate y casos negativos; servir en 3201 y verificar 390×844 y 1280×800.
5. Registrar evidencia en `feature_list.json` y `PROGRESS.md`.

## Implementation Tasks

- [ ] Insertar `<header class="profile">` dentro de `.card`, antes de `section#link-button-demo`.
- [ ] Añadir `<img class="profile-avatar" src="assets/avatar.jpg" alt="Retrato de Fahed Hermoza" width="88" height="88">` sin modificar el asset.
- [ ] Añadir `.profile` con flex column, `align-items:center` y `padding-block:var(--space-xl)`.
- [ ] Añadir `.profile-avatar` con `display:block`, `width/height:88px`, `border-radius:var(--radius-full)`, `object-fit:cover` y `box-shadow:0 0 0 3px var(--color-surface)`.
- [ ] Verificar que `:root` conserva 51 tokens y que `.page`/`.card`/`.link-button`/demo no cambian.
- [ ] Extender `init.sh` con `Profile checks:` y el contrato de 5 declaraciones; cambiar el puerto sugerido a 3201.
- [ ] Probar `bash -n init.sh`, `./init.sh` (exit `0`) y los casos negativos en copia temporal; verificar 390×844 y 1280×800.
- [ ] Registrar evidencia en `feature_list.json` y `PROGRESS.md`.

## Verification Plan

### Gate

- `bash -n init.sh` → sin errores de sintaxis.
- `./init.sh` → `Harness status: bootstrapped (static site detected)`, checks previos `[ok]`, `[ok] profile avatar markup`, `[ok] avatar asset exists`, `[ok] .profile-avatar base rule exists`, `[ok] profile avatar contract (5/5)`; exit `0`; sin servidor.
- Casos negativos en copia temporal fuera del repo (no tocar el worktree):
  - Quitar `class="profile-avatar"`/el `alt` esperado, renombrar `.profile-avatar` o quitar `object-fit: cover;`/`box-shadow: …` → stderr del check correspondiente y exit `1`.
  - Vaciar/eliminar `assets/avatar.jpg` en la copia → stderr del asset y exit `1`.
  - Confirmar que ningún caso arranca servidor y eliminar la copia.

### Browser

- Servir con `python3 -m http.server 3201 --directory .` y abrir `http://localhost:3201/`; detener solo ese proceso. Si 3201 está ocupado, comprobar `lsof -nP -iTCP:3201 -sTCP:LISTEN` y reportar el bloqueo, sin cambiar de puerto en silencio.
- `curl -sI` → `/` `200 text/html`, `/styles.css` `200 text/css`, `/assets/avatar.jpg` `200 image/jpeg`; Google Fonts `200` o sin petición fallida.
- **390×844:** `documentElement.scrollWidth <= clientWidth` y `body.scrollWidth <= clientWidth`; `img.profile-avatar` con `complete=true`, `naturalWidth=460`, `naturalHeight=460`, rect 88×88 y centro horizontal igual al de la tarjeta/viewport; computed `display:block`, `width:88px`, `height:88px`, `object-fit:cover`, `border-radius:9999px` y `box-shadow` que incluya `rgb(255, 255, 255) 0px 0px 0px 3px`; consola con 0 mensajes; red con `/`, `styles.css`, Google Fonts, WOFF2 y `/assets/avatar.jpg` en 200/304, sin 4xx/5xx ni `/favicon.ico`.
- **1280×800:** tarjeta de 400px y avatar de 88×88 centrado, mismo `object-fit`, halo y radio; sin scroll horizontal; consola y red limpias; avatar visible y sin recorte.
- Capturar screenshots si la herramienta puede leer imágenes; si no, usar `getBoundingClientRect()`/`getComputedStyle()` como evidencia principal.

### Accesibilidad y E2E

- El `<img>` tiene `alt` no vacío y descriptivo; nombre accesible `Retrato de Fahed Hermoza`; no usar `role="presentation"` ni `alt=""`.
- No se añaden controles, foco ni cambios de contraste; no hay regresión de `lang="es"`.
- E2E: no aplica; no existe harness E2E ni framework de tests, y añadirlos introduciría un build/dependencia prohibidos por `docs/technical-discovery.md`. Cobertura: gate no bloqueante + navegador manual reproducible.

## Evidence To Capture

- Salida completa de `./init.sh` correcto (exit `0`, cuatro checks de Perfil) y de los casos negativos.
- `curl -sI` de `/`, `/styles.css` y `/assets/avatar.jpg`.
- Medidas/estilos computados del avatar en 390×844 y 1280×800; consola/red; `scrollWidth`/`clientWidth`.
- Nombre accesible y confirmación de que el asset es el original (460×460, no reemplazado).
- `feature_list.json` (`status: passing`, `evidence`) y `PROGRESS.md` actualizados; `docs/validations/profile-avatar.md` por el validator. Screenshots opcionales.

## Risks And Mitigations

- **Anillo blanco sobre tarjeta blanca:** sin contraste de color; se confirma por `box-shadow` computado y forma circular por la imagen. Mitigación: no añadir sombras ni colores fuera de `DESIGN.md`.
- **Interpretación del tamaño:** 88×88 para la caja de la imagen y halo exterior de 3px (footprint 94). Mitigación: el gate y la evidencia miden el `<img>` a 88×88 y el halo a 3px; si el diseño exigiera el anillo incluido, sería otro contrato con `border`.
- **La tarjeta cambia de altura:** la geometría de `page-shell` deja de coincidir. Mitigación: re-medir ambos viewports; el gate de ancho de tarjeta sigue intacto.
- **Asset movido/renombrado:** produciría 404. Mitigación: gate `[ -f ] && [ -s ]`, `curl -sI` y comprobación de red; el fallback no se implementa aquí y la demo temporal no se retira.
- **Puerto 3201 ocupado:** comprobar listener y reportar el bloqueo; no cambiar de puerto en silencio. Sin E2E automatizado, la cobertura manual se compensa con el gate y mediciones.

## Acceptance Criteria

- [ ] El avatar usa `assets/avatar.jpg` sin modificar el asset y sin 404.
- [ ] El `<img>` mide 88×88, usa `object-fit:cover`, `border-radius:var(--radius-full)` y halo blanco de 3px.
- [ ] El avatar está dentro de `.card`, antes de la demo, centrado y sin scroll horizontal en 390×844 y 1280×800.
- [ ] `alt="Retrato de Fahed Hermoza"` está presente; consola sin errores y red sin fallos.
- [ ] `./init.sh` sigue no bloqueante, pasa, detecta avatar roto y usa 3201; `:root` conserva 51 tokens y no hay dependencias ni cambios en `DESIGN.md`.
- [ ] `feature_list.json` y `PROGRESS.md` actualizados; el planner no cambia el estado.

## Validator Checklist

- [ ] Implementation stays within this feature's scope (avatar only; no Nombre/Handle/Tagline, fallback, Enlaces, vCard ni Pie).
- [ ] Acceptance scenarios pass.
- [ ] Verification evidence is present.
- [ ] Persistent E2E coverage was added/updated when an E2E harness exists, or the spec explains why it is not needed (no harness exists).
- [ ] `feature_list.json` and `PROGRESS.md` were updated correctly.
- [ ] No unrelated product behavior or extra feature work was added.
- [ ] `assets/avatar.jpg` is unchanged and the request returns 200.
- [ ] Contract exact: 88×88, `object-fit:cover`, `border-radius:var(--radius-full)`, 3px white halo.
- [ ] `alt` descriptive and non-empty; avatar not hidden from assistive technology.
- [ ] `.page`, `.card`, `:root`, `body`, `.link-button` and the demo were not altered.
- [ ] Profile block is inside `.card` and the demo remains after it.
- [ ] Browser validation ran at 390×844 and 1280×800 without console errors, failed requests or horizontal scroll.

## Assumptions And Open Questions

### Assumptions

- `assets/avatar.jpg` es la fuente de verdad, mide 460×460 y no se recorta ni regenera.
- `1rem = 16px`; el halo con `box-shadow` exterior mantiene la foto a 88×88, con footprint visual 94 y contrato medible de caja 88 + halo 3px.
- `.profile` con `padding-block:var(--space-xl)` satisface el margen del Perfil; padding horizontal y separación tipográfica se deciden en `profile-identity`.
- El puerto 3201 está libre; los navegadores objetivo soportan `object-fit`, custom properties, `box-shadow` con spread y `border-radius`; la demo temporal se mantiene hasta que las features de enlaces la retiren.

### Open Questions

- Ninguna bloqueante. Si el propietario del diseño confirma que los 88px deben incluir el anillo, el contrato cambiaría a `border:3px solid` con `box-sizing:border-box` (foto visible 82×82); no se implementa así.
- El texto exacto del `alt` puede ajustarse editorialmente, pero debe seguir siendo descriptivo y no vacío; `"Retrato de Fahed Hermoza"` es el valor de esta spec.
