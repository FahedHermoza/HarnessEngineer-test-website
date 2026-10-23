# Feature Implementation Spec: Nombre, Handle y Tagline del Perfil

## Source Feature

- `id`: `profile-identity`
- `area`: `profile`
- `depends_on`: `["page-shell"]` (satisfied: `accepted`)
- `status`: `not_started` (at planning time; this spec does not change it)
- `source`: `feature_list.json`
- `notes`: `DESIGN.md` → `Colors`, `Typography`, `Layout`, `Components/Perfil`; `docs/build-brief.md` → MVP Slice; `CONTEXT.md` → Perfil, Handle, Tagline.

## Goal

Mostrar bajo el avatar (cuando exista) el bloque de identidad del Perfil con los tres textos exactos: Nombre **"Fahed Hermoza"**, Handle **"@fahedhermoza"** y Tagline **"Software Engineer & Speaker & Builder"**, usando la jerarquía tipográfica de `DESIGN.md` y los tokens ya existentes en `styles.css`.

El bloque se inserta dentro de la tarjeta actual (`<article class="card">`) sin redefinir el page shell. El avatar, los Enlaces, la vCard y el pie son features posteriores; esta feature solo añade el texto de identidad.

## Non-Goals

- No añadir avatar, `<img>`, placeholder de avatar, `.profile-avatar`, halo, fallback "FH" ni `assets/avatar.jpg` (feature `profile-avatar` / `avatar-fallback`).
- No crear un contenedor `.profile` completo ni mover/reestructurar `.page` o `.card`; el page shell aceptado se conserva.
- No añadir Enlaces, botones, demo nueva, vCard, pie, Open Graph, favicon, `theme-color`, modo oscuro ni i18n.
- No modificar la demo temporal `#link-button-demo[data-demo="link-button"]` ni su CSS `[data-demo="link-button"]`; debe quedar intacta.
- No añadir tokens, colores, tamaños ni pesos nuevos; no tocar el bloque `:root` (51 tokens) ni `body`.
- No añadir frameworks, bundlers, JavaScript, npm, dependencias ni archivos nuevos de producto.
- No resolver aquí el contraste AA de `#717886` sobre blanco; se registra como riesgo heredado para `accessibility-baseline`.

## Job Story

When abro la Tarjeta digital desde el móvil o el escritorio,
I want to leer de inmediato quién es Fahed, su identificador público y qué hace,
so I can reconocer su identidad sin ayuda y decidir si contactarlo.

## Users And Permissions

- Visitante anónimo: ve el bloque de identidad; no hay autenticación, roles ni estado.
- Implementador/agente: inserta el markup, el CSS del bloque y el gate no bloqueante de `init.sh`; registra evidencia.
- Validador: reproduce el gate, las mediciones en 390×844 y 1280×800 y comprueba que la demo y el page shell siguen intactos.

## Acceptance Scenarios

### Scenario 1: Identidad visible en móvil

Given la página servida en `http://localhost:3202` con viewport 390×844,
When se carga la tarjeta,
Then se leen, en este orden, "Fahed Hermoza", "@fahedhermoza" y "Software Engineer & Speaker & Builder", centrados dentro de la tarjeta, sin scroll horizontal y sin errores de consola.

### Scenario 2: Jerarquía tipográfica exacta

Given el bloque renderizado,
When se inspeccionan los estilos computados,
Then Nombre y Handle usan `--text-headline-lg-*` (26px / 600 / 34px / -0.52px), la Tagline usa `--text-body-md-*` (13px / 400 / 20px, sin `letter-spacing`), el Nombre es `#2d3139` y Handle/Tagline son `#717886`.

### Scenario 3: Escritorio

Given viewport 1280×800,
When se carga la página,
Then la tarjeta conserva 400px de ancho centrada (`x = 440`), el bloque de identidad respeta el padding interno y los tres textos permanecen centrados y legibles, sin scroll horizontal.

### Scenario 4: Pantalla estrecha

Given viewport 320×844 (edge case de la baseline responsive),
When se carga la página,
Then la Tagline puede ocupar dos líneas, el Nombre y el Handle no se cortan ni provocan overflow, y `document.documentElement.scrollWidth === clientWidth`.

### Scenario 5: Gate detecta identidad rota

Given una copia temporal con el Nombre eliminado, o con la Tagline sin escapar (`&` en lugar de `&amp;`), o con la Tagline usando tokens de `headline-lg`,
When se ejecuta `./init.sh`,
Then sale con código distinto de `0`, imprime el check fallido en stderr y no arranca ningún servidor.

### Scenario 6: Sin daño colateral

Given la implementación terminada,
When se revisa el diff,
Then `.page` / `.card`, los 51 tokens, `body` y la demo `#link-button-demo` no cambiaron, y no hay avatar, Enlaces, vCard, pie ni dependencias nuevas.

## Repository Research

### Files Inspected

- `AGENTS.md`, `PROGRESS.md`, `feature_list.json` — Definition of Done, estado (`page-shell` y `link-button-component` en `accepted`) y metadata de `profile-identity`; sin bloqueos de dependencia.
- `index.html` — `<main class="page"><article class="card">` con la demo temporal `#link-button-demo` dentro de `.card`; `<head>` ya enlaza `styles.css` y Google Fonts.
- `styles.css` — 51 tokens en `:root`, reglas `.page` y `.card`, componente `.link-button` y CSS temporal de la demo; el demo tiene su propio padding/margen.
- `init.sh` — gate no bloqueante con `set -euo pipefail`; checks de bootstrap, tokens, componente de botón y page shell; no arranca servidor salvo `RUN_SERVE_COMMAND=1`.
- `DESIGN.md` — `Nombre / Handle: headline-lg`, `Tagline: body-md`, color secundario `#717886` para handle/tagline, Perfil con margen `space-xl` arriba/abajo y nombre a 1.25rem del avatar.
- `docs/build-brief.md`, `CONTEXT.md`, `docs/domain-model.md`, `docs/technical-discovery.md` — textos exactos, vocabulario Perfil/Handle/Tagline, stack estático sin build ni JS y verificación manual en navegador.
- `docs/specs/page-shell.md`, `docs/specs/link-button-component.md` — formato de spec y contratos aceptados que esta feature no debe romper.

### Existing Patterns To Follow

- Una única hoja `styles.css`; tokens como custom properties en `:root`; valores de componente fuera de `:root`.
- Convención existente de tokens: `--color-*`, `--text-*-font-size/weight/line-height/letter-spacing`, `--space-*`.
- Clases BEM-ish ya usadas por `.link-button` (`__label`, `__icon`, modificadores).
- `init.sh` reporta fallos a stderr con `FAILED - ...`, exit `1`, y no inicia servidores.
- Evidencia durable en `feature_list.json` (`status` + `evidence`) y `PROGRESS.md`.

### Current Gaps

- No existe markup de Perfil ni avatar; la tarjeta contiene solo la demo temporal de botones.
- No hay framework de tests, linter ni comando E2E; la verificación es `init.sh` + navegador (Chrome DevTools) según `docs/technical-discovery.md`.
- `DESIGN.md` asigna `#717886` a la Tagline; sobre blanco mide ≈4.43:1, ligeramente por debajo de AA 4.5:1 para texto normal de 13px. No se corrige en esta feature.

## Technical Approach

### 1. Markup contract

Insertar el bloque como primer hijo de `<article class="card">`, antes del comentario y de la demo existente. No añadir avatar ni contenedor adicional.

```html
<header class="profile-identity">
  <h1 class="profile-identity__name">Fahed Hermoza</h1>
  <p class="profile-identity__handle">@fahedhermoza</p>
  <p class="profile-identity__tagline">Software Engineer &amp; Speaker &amp; Builder</p>
</header>
```

- `<header>` agrupa el contenido introductorio de la tarjeta sin crear un landmark global (está anidado en `<article>`).
- `<h1>` es el único encabezado de la página y da el nombre accesible del documento; no se usa `aria-label` porque el texto visible ya es el nombre.
- Handle y Tagline son `<p>` no interactivos; el Handle no es enlace en esta feature (`page-footer` lo enlazará después).
- La Tagline debe usar `&amp;` en el HTML; el texto renderizado debe ser exactamente `Software Engineer & Speaker & Builder`.
- No se añaden `id`, clases extra, `data-*` ni estilos inline.

### 2. CSS contract

Añadir una sección en `styles.css` después de `.card` y antes de `/* Components — Link button ... */`, con este contrato exacto (se permiten comentarios de sección):

```css
/* Profile — Identity (DESIGN.md > typography, colors, components/profile) */
.profile-identity {
  padding: var(--space-xl) var(--space-lg);
  text-align: center;
}

.profile-identity__name {
  margin: 0;
  color: var(--color-on-surface);
  font-family: var(--font-family-base);
  font-size: var(--text-headline-lg-font-size);
  font-weight: var(--text-headline-lg-font-weight);
  line-height: var(--text-headline-lg-line-height);
  letter-spacing: var(--text-headline-lg-letter-spacing);
}

.profile-identity__handle {
  margin: var(--space-xs) 0 0;
  color: var(--color-on-surface-variant);
  font-family: var(--font-family-base);
  font-size: var(--text-headline-lg-font-size);
  font-weight: var(--text-headline-lg-font-weight);
  line-height: var(--text-headline-lg-line-height);
  letter-spacing: var(--text-headline-lg-letter-spacing);
}

.profile-identity__tagline {
  margin: var(--space-sm) 0 0;
  color: var(--color-on-surface-variant);
  font-family: var(--font-family-base);
  font-size: var(--text-body-md-font-size);
  font-weight: var(--text-body-md-font-weight);
  line-height: var(--text-body-md-line-height);
}
```

Decisiones y rationale:

- **Handle en `headline-lg`**: `DESIGN.md > Typography` agrupa explícitamente "Nombre / Handle" bajo `headline-lg` (26px / 600 / 34px / -0.02em). Se usa esa escala para ambos. La alternativa `body-md` se descarta porque contradiría esa agrupación.
- **Diferenciación por color**: el Nombre usa `--color-on-surface` (`#2d3139`); Handle y Tagline usan `--color-on-surface-variant` (`#717886`), porque `DESIGN.md > Colors` asigna `#717886` a handle/tagline.
- **Tagline en `body-md`**: 13px / 400 / 20px. No existe token `--text-body-md-letter-spacing`; no se declara `letter-spacing` (queda `normal`). No inventar el token.
- **Espaciado**: `--space-xl` (36px) vertical y `--space-lg` (24px) horizontal para el bloque, coherente con "Perfil con margen space-xl arriba y abajo". Nombre→Handle `--space-xs` (6px); Handle→Tagline `--space-sm` (12px). No se añaden tokens de espaciado.
- **Centrado**: `text-align: center`, coherente con la tarjeta de columna única centrada. No se añade `display:flex` ni `max-width`; el ancho lo fija el padding del bloque.
- No se modifica `.card` (sigue sin padding interno); el bloque aporta su propio padding. No se usa `overflow: hidden` ni `white-space: nowrap`.

### 3. Harness contract (`init.sh`)

Ampliar `init.sh` con una sección `Profile identity checks:` después de `Page shell checks:` y antes del comando de servido. Debe ser no bloqueante y no iniciar servidor. Checks mínimos:

- Markup: `class="profile-identity"` presente en `index.html`; `<h1 class="profile-identity__name">Fahed Hermoza</h1>` presente.
- Textos exactos: `>Fahed Hermoza<`, `>@fahedhermoza<` y `>Software Engineer &amp; Speaker &amp; Builder<` presentes.
- CSS: reglas `.profile-identity`, `.profile-identity__name`, `.profile-identity__handle` y `.profile-identity__tagline` existen.
- Contrato `.profile-identity`: contiene `padding: var(--space-xl) var(--space-lg);` y `text-align: center;`.
- Contrato Nombre: contiene `font-size: var(--text-headline-lg-font-size);`, `font-weight: var(--text-headline-lg-font-weight);`, `line-height: var(--text-headline-lg-line-height);`, `letter-spacing: var(--text-headline-lg-letter-spacing);` y `color: var(--color-on-surface);`.
- Contrato Handle: los cuatro tokens de `headline-lg` y `color: var(--color-on-surface-variant);`.
- Contrato Tagline: `font-size: var(--text-body-md-font-size);`, `font-weight: var(--text-body-md-font-weight);`, `line-height: var(--text-body-md-line-height);`, `color: var(--color-on-surface-variant);` y **sin** declaración `letter-spacing`.
- Cada fallo imprime `FAILED - ...` en stderr y termina con exit `1`; los checks existentes de bootstrap, tokens, botón y page shell se conservan.
- `./init.sh` sigue sin arrancar procesos largos. El puerto de verificación manual de esta feature es **3202**; no es necesario cambiar el texto de sugerencia existente de `init.sh`, pero la verificación en navegador usa 3202.

Sugerencia de implementación del extractor de reglas: reutilizar el patrón `awk` que ya usa el check de `.link-button`, o una función equivalente que aísle el bloque de cada selector para no confundir `.profile-identity__name` con `.profile-identity`.

## Expected File Changes

- `index.html` — modify; insertar `<header class="profile-identity">...</header>` como primer hijo de `.card`, antes de la demo. No tocar la demo ni `<head>`.
- `styles.css` — modify; añadir las cuatro reglas de `.profile-identity` y sus elementos después de `.card`. No tocar `:root`, `body`, `.page`, `.card`, `.link-button` ni `[data-demo="link-button"]`.
- `init.sh` — modify; añadir `Profile identity checks:` no bloqueantes. No cambiar checks existentes ni arrancar servidor.
- `feature_list.json` — update; el implementador pasa `profile-identity` a `passing` con evidencia; el validador la mueve a `accepted`.
- `PROGRESS.md` — update; estado verificado, sesión, comandos y resultados.
- `docs/risks-and-open-questions.md` — update; registrar el contraste ≈4.43:1 de `#717886` sobre blanco para la Tagline de 13px como riesgo heredado de `accessibility-baseline`.
- No se crean archivos nuevos de producto.

## Visual Design Impact

- UI involved: yes.
- Design source: `DESIGN.md` (`Colors`, `Typography`, `Layout`, `Components/Perfil`).
- Screens or states affected: única vista de la Tarjeta digital, estado normal; el avatar aún no existe, por lo que el bloque aparece como primer contenido de la tarjeta.
- New design artifact required: no — todos los valores salen de tokens existentes y de `DESIGN.md`; no se inventan colores, tamaños ni pesos.
- Estados hover/focus/transición: no aplican porque el bloque es texto no interactivo.
- El `text-align: center` y los espacios nombre→handle→tagline son decisiones de composición dentro de las reglas de `DESIGN.md`; no requieren un mockup nuevo.

## Durable Documentation Impact

- `ARCHITECTURE.md`: not needed — no hay nueva capa, ruta, dominio ni dependencia; sigue siendo HTML/CSS estático.
- `CONSTRAINTS.md`: not needed — no se introduce una regla MUST/MUST NOT nueva más allá de las ya registradas en `AGENTS.md`/`DESIGN.md`.
- `AGENTS.md`: not needed — no cambia el workflow, el arranque ni las reglas operativas del repo.
- `DESIGN.md`: not needed — ya define la jerarquía y los colores usados; la interpretación de Handle se documenta en este spec.
- `docs/risks-and-open-questions.md`: update — registrar el contraste de la Tagline como riesgo heredado para `accessibility-baseline`.
- `CONTEXT.md`, `docs/domain-model.md`, `docs/build-brief.md`, `docs/technical-discovery.md`: not needed — los textos y el vocabulario no cambian.

## Implementation Plan

1. Insertar el bloque `<header class="profile-identity">` con Nombre, Handle y Tagline escapada como primer hijo de `.card`, sin tocar la demo.
2. Añadir las cuatro reglas CSS con los tokens exactos y sin modificar `:root`, `body`, `.page`, `.card` ni el componente de botón.
3. Ampliar `init.sh` con los checks de markup, textos y contrato CSS, conservando los checks existentes y el comportamiento no bloqueante.
4. Ejecutar `bash -n init.sh` y `./init.sh`; probar al menos un caso negativo en una copia temporal fuera del repo.
5. Servir en 3202 y verificar en navegador 390×844 y 1280×800: textos, estilos computados, geometría, consola y red.
6. Registrar evidencia en `feature_list.json` y `PROGRESS.md`; actualizar el riesgo de contraste.

## Implementation Tasks

- [ ] Añadir el markup de identidad dentro de `.card` antes de la demo, con `h1`/`p` y `&amp;`.
- [ ] Añadir `.profile-identity`, `__name`, `__handle` y `__tagline` en `styles.css` usando solo tokens existentes.
- [ ] Verificar que Handle usa `headline-lg` + `--color-on-surface-variant` y Tagline usa `body-md` + `--color-on-surface-variant`.
- [ ] Añadir los checks de `Profile identity checks:` en `init.sh` sin alterar los checks previos.
- [ ] Ejecutar el caso negativo (Nombre eliminado, `&` sin escapar o Tagline con `headline-lg`) y confirmar exit `1` sin servidor.
- [ ] Verificar en navegador 390×844 y 1280×800, incluida la demo intacta y la ausencia de scroll horizontal.
- [ ] Registrar evidencia y el riesgo de contraste en los artefactos durables.

## Verification Plan

- `bash -n init.sh` → sin errores de sintaxis.
- `./init.sh` → `Harness status: bootstrapped (static site detected)`; checks previos `[ok]`; nuevos checks de identidad `[ok]`; exit `0`; sin servidor iniciado.
- Caso negativo en copia temporal fuera del repo (una variante basta; idealmente dos): quitar `>Fahed Hermoza<` → exit `1` con `FAILED - ...`; usar `&` en la Tagline → exit `1`; cambiar la Tagline a `--text-headline-lg-*` → exit `1`. Eliminar la copia y confirmar que el repo no cambió.
- Servir con `python3 -m http.server 3202 --directory .` (único servidor de la sesión). Detenerlo al terminar; no detener servidores ajenos.
- `curl -sI http://localhost:3202/` → `200 text/html`; `curl -sI http://localhost:3202/styles.css` → `200 text/css`.
- Navegador 390×844:
  - Textos exactos y en orden; `h1` único; `&` renderizado correctamente.
  - Computed: Name 26px/600/34px/-0.52px `rgb(45, 49, 57)`; Handle 26px/600/34px/-0.52px `rgb(113, 120, 134)`; Tagline 13px/400/20px `normal` `rgb(113, 120, 134)`; `text-align: center`.
  - Tarjeta 358px en `x=16`; bloque 358px de ancho con padding `36px 24px`; sin scroll horizontal (`scrollWidth === clientWidth`).
  - Consola: 0 mensajes. Red: documento, `styles.css`, Google Fonts CSS y WOFF2 sin fallos; sin `/favicon.ico` (ya existe `<link rel="icon" href="data:,">`); ninguna petición 4xx/5xx.
- Navegador 1280×800: mismas comprobaciones; tarjeta 400px en `x=440`, centrada, sin scroll horizontal, consola 0 mensajes y red sin fallos.
- Edge case 320×844: Tagline puede envolver a dos líneas; sin overflow horizontal; Name/Handle completos.
- Scope guard: comprobar en el diff que `#link-button-demo` y `[data-demo="link-button"]` no cambiaron, que `:root` sigue con 51 tokens y que no hay `<script>`, `package.json`, bundler ni dependencias.
- No existe comando E2E persistente (no hay framework ni `package.json`); la verificación es `init.sh` + DevTools, tal como define `docs/technical-discovery.md`. No se añade E2E porque introduciría dependencias prohibidas.

## Evidence To Capture

- Salida de `bash -n init.sh` y de `./init.sh` con los nuevos checks `[ok]` y exit `0` sin servidor.
- Salida del caso negativo con el mensaje `FAILED - ...` en stderr, exit `1` y confirmación de que no se abrió ningún listener; copia temporal eliminada.
- Resultado de `curl -sI` para `/` y `/styles.css`.
- Valores de `getComputedStyle()` y `getBoundingClientRect()` de los tres textos y del bloque en 390×844 y 1280×800 (tamaños, pesos, line-height, letter-spacing, colores, padding, ancho y posición).
- Confirmación de consola con 0 mensajes y lista de peticiones de red sin fallos ni `/favicon.ico` en ambos viewports.
- Confirmación de que la demo de cinco botones sigue presente y con su geometría/estilos intactos, y de que el diff no toca tokens, page shell ni componente de botón.
- Entrada de evidencia en `feature_list.json` y sesión en `PROGRESS.md`; riesgo de contraste ≈4.43:1 registrado en `docs/risks-and-open-questions.md`.

## Validator Checklist

- [ ] La implementación se limita al bloque de identidad; no hay avatar, Enlaces, vCard, pie, metadatos ni dependencias nuevas.
- [ ] Los tres textos son exactos y la Tagline usa `&amp;` en el HTML.
- [ ] Nombre y Handle usan `headline-lg`; Tagline usa `body-md`; colores `--color-on-surface` / `--color-on-surface-variant` según el spec.
- [ ] El markup usa `header > h1 + p + p` con las clases `profile-identity*` y no añade `aria-label` redundante.
- [ ] `.card` y `.page` no se redefinieron; la demo temporal y su CSS están intactos.
- [ ] `:root` conserva exactamente 51 tokens y no se añadieron frameworks, JS, bundlers ni archivos de producto.
- [ ] `bash -n init.sh` y `./init.sh` pasan con exit `0` sin arrancar servidor; el caso negativo falla con exit `1` y stderr.
- [ ] 390×844 y 1280×800: textos, estilos computados, geometría, consola 0 mensajes, red sin fallos y sin scroll horizontal.
- [ ] La evidencia está registrada en `feature_list.json` y `PROGRESS.md`, y el riesgo de contraste quedó documentado.
- [ ] No se añadió trabajo de `accessibility-baseline` ni se cambiaron colores para “arreglar” el contraste.
