# Feature Implementation Spec: Pie con correo y handle

## Source Feature

- `id`: `page-footer`
- `area`: `layout`
- `depends_on`: `["page-shell"]` (satisfied: `accepted`)
- `status`: `not_started` (at planning time; this spec does not change it)
- `source`: `feature_list.json`
- `notes`: `DESIGN.md` > `components.pie`, `colors`, `typography` (pie/meta) y `Components > Pie`; contenido de `docs/build-brief.md` (punto 4) y `docs/technical-discovery.md` (integraciones).

## Goal

Añadir al final de la Tarjeta digital un pie sobrio con borde superior de 1px, texto centrado y dos enlaces acentuados: el correo (`mailto:fahedhermoza@gmail.com`) y el Handle (`@fahedhermoza`). El pie se inserta como último hijo de la tarjeta existente (`article.card`), sin alterar el page shell, los tokens, el componente de botón ni la demo temporal de `link-button-component`.

El alcance termina cuando el pie es visible y verificable en móvil (390×844) y escritorio (1280×800), el gate de `init.sh` detecta su contrato, y la evidencia queda registrada. No se implementan los Enlaces reales ni ninguna otra feature.

## Non-Goals

- No implementar la lista real de Enlaces, los botones `link-*`, su orden ni su degradado (`link-instagram`…`links-order-gradient`).
- No retirar la demo temporal `[data-demo="link-button"]` ni su CSS: su retirada pertenece a las features de enlaces.
- No implementar Perfil, avatar, Nombre, Tagline, vCard ni Open Graph.
- No modificar `.page`, `.card`, `.link-button`, `body`, `:root` ni los 51 tokens.
- No añadir JavaScript, frameworks, bundlers, preprocessors, npm, dependencias, assets, favicon ni `theme-color`.
- No añadir hover animado, transiciones, `:active` ni nuevas animaciones; por tanto no se añade un bloque nuevo de `prefers-reduced-motion`.
- No resolver el contraste global de `link-button-component` (riesgo heredado a `accessibility-baseline`).
- No navegar a destinos externos ni activar `mailto:` durante la automatización: se verifica el `href` y el nombre accesible para no generar tráfico de terceros ni abrir apps del sistema.
- No cambiar `DESIGN.md` ni la fuente de verdad de diseño.

## Job Story

When llego al final de la Tarjeta digital,
I want to ver un pie claro con el correo y el Handle enlazados,
so I can contactar a Fahed por correo o encontrar su perfil sin volver a buscar entre los botones.

## Users And Permissions

- Visitante anónimo: ve el pie, puede activar el enlace de correo o el del Handle; no hay autenticación ni estado.
- Implementador/agente: añade markup, CSS, checks de harness y evidencia; no implementa otras features.
- Validador: reproduce el gate y las mediciones de navegador de forma independiente.

## Acceptance Scenarios

### Scenario 1: Pie visible y centrado

Given la página servida en `http://localhost:3203` con viewport 390×844 o 1280×800,
When se inspecciona el final de la tarjeta,
Then existe un `<footer class="page-footer">` como último hijo de `article.card`, con borde superior de 1px `#ebeef2`, texto centrado, padding de 24px y color de texto `#2d3139`; no hay scroll horizontal.

### Scenario 2: Enlace de correo

Given el pie renderizado,
When se inspecciona el primer enlace,
Then es un `<a class="page-footer__link">` con `href="mailto:fahedhermoza@gmail.com"`, texto visible `fahedhermoza@gmail.com`, color `#585ce5` y subrayado; su nombre accesible es el correo visible.

### Scenario 3: Enlace del Handle

Given el pie renderizado,
When se inspecciona el segundo enlace,
Then tiene `href="https://www.instagram.com/fahedhermoza/"`, texto visible `@fahedhermoza`, nombre accesible `@fahedhermoza en Instagram`, color `#585ce5` y subrayado.

### Scenario 4: Foco de teclado visible

Given el pie en escritorio,
When se navega con `Tab` hasta cada enlace,
Then cada uno muestra un outline `2px solid #585ce5` con `outline-offset: 2px`, sin transiciones ni desplazamientos.

### Scenario 5: Contraste AA

Given el fondo blanco de la tarjeta,
When se calcula el contraste,
Then el texto base (`#2d3139`) mide ~13.04:1 y los enlaces (`#585ce5`) ~5.15:1; ambos superan AA 4.5:1 para texto normal. No se usa `#717886` en texto de 13px porque mide ~4.44:1 y no cumple AA.

### Scenario 6: El gate detecta un pie roto

Given una copia temporal con el pie eliminado, el `mailto:` alterado, el `href` del Handle alterado, sin `border-top`, sin el color de acento o sin el outline de foco,
When se ejecuta `./init.sh`,
Then sale con código distinto de `0`, imprime el check fallido en stderr y no arranca ningún servidor.

### Scenario 7: Sin errores de consola ni peticiones fallidas

Given la página servida en el puerto 3203,
When se carga en 390×844 y 1280×800,
Then la consola no muestra mensajes/errores y la red no contiene peticiones 4xx/5xx de la página, incluida la hoja de Google Fonts y el WOFF2; no se solicita `/favicon.ico`.

## Repository Research

### Files Inspected

- `AGENTS.md` — Definition of Done, validación obligatoria en 390×844 y 1280×800, reglas de alcance y dependencias.
- `PROGRESS.md` — `page-shell` y `link-button-component` en `accepted`; `page-footer` es dependency-ready; demo temporal vigente.
- `feature_list.json` — metadata, dependencia `page-shell`, verificación (`mailto:` + acento `#585ce5`) y notas del pie.
- `DESIGN.md` — `colors` (`border #ebeef2`, `on-surface #2d3139`, `on-surface-variant #717886`, `accent #585ce5`), `typography` (`body-md`, `body-sm`), `Layout` ("pie con space-lg"), `Components > Pie` ("borde superior 1px #ebeef2, texto centrado, correo y handle con enlaces acentuados").
- `CONTEXT.md` — Handle = `@fahedhermoza`; no define una URL propia para el Handle.
- `docs/build-brief.md` — MVP punto 4: "Pie con el correo y el handle"; contenido visible en español.
- `docs/domain-model.md` — el sistema decide la app de `mailto:`; la página no puede forzarla.
- `docs/technical-discovery.md` — `mailto:fahedhermoza@gmail.com`; Instagram `https://www.instagram.com/fahedhermoza/`; sitio estático sin build ni dependencias.
- `docs/risks-and-open-questions.md` — contraste de botones heredado a `accessibility-baseline`; comportamiento de `mailto:` según dispositivo.
- `docs/specs/page-shell.md`, `docs/specs/link-button-component.md` — formato, contrato de `.card`, convención de gate y evidencia.
- `index.html` — `<main class="page"><article class="card">` con la demo temporal de 5 botones dentro de la tarjeta; `<head>` ya declara `<link rel="icon" href="data:,">`.
- `styles.css` — 51 tokens en `:root`, `body`, `.page`, `.card`, componente `.link-button` y bloque temporal `[data-demo="link-button"]`.
- `init.sh` — gate no bloqueante: bootstrap, tokens, componente y page shell; imprime 3101 y solo sirve con `RUN_SERVE_COMMAND=1`.
- `docs/validations/*.md` — evidencia aceptada de prerrequisitos; no existe harness E2E ni framework de tests.

### Current State

- El page shell está aceptado: tarjeta blanca de hasta 400px, centrada, con radio 12px, borde y sombra de `DESIGN.md`.
- La única contenido actual es la demo temporal de botones; no hay pie ni elementos de contacto.
- El puerto 3203 está libre en este worktree; no hay listener.
- No existen `ARCHITECTURE.md` ni `CONSTRAINTS.md`.

### Existing Patterns To Follow

- HTML estático con CSS plano, una sola hoja `styles.css`, custom properties y sin build.
- Componentes con clases BEM-ish (`page-footer`, `page-footer__text`, `page-footer__link`, `page-footer__separator`) y valores derivados de tokens.
- `init.sh` con `set -euo pipefail`, checks acumulativos, errores a stderr, exit `1` y sin servidor por defecto.
- Evidencia durable en `feature_list.json` (`status` + `evidence`) y `PROGRESS.md`; el validador crea `docs/validations/page-footer.md`.

### Current Gaps

- No existe markup ni CSS de pie.
- No hay comprobación de harness para el pie ni para sus destinos.
- `init.sh` sugiere el puerto 3101, mientras esta feature debe verificarse en 3203.

## Technical Approach

### 1. Markup exacto

Insertar como último hijo de `<article class="card">`, después de `</section>` de la demo:

```html
<footer class="page-footer">
  <p class="page-footer__text">
    <a class="page-footer__link" href="mailto:fahedhermoza@gmail.com">fahedhermoza@gmail.com</a>
    <span class="page-footer__separator" aria-hidden="true">·</span>
    <a class="page-footer__link" href="https://www.instagram.com/fahedhermoza/" aria-label="@fahedhermoza en Instagram">@fahedhermoza</a>
  </p>
</footer>
```

- `<footer>` es el pie del `article`; no crea un landmark `contentinfo` global, lo cual es correcto dentro de la Tarjeta.
- El separador es decorativo (`aria-hidden="true"`) y no aporta nombre accesible.
- El nombre accesible del enlace del Handle contiene el texto visible `@fahedhermoza` (cumple label-in-name) y añade el contexto "en Instagram".
- No se usa `target="_blank"` ni `rel`: el enlace navega en la misma pestaña.
- No se añade `aria-label` al correo: el texto visible ya es su nombre accesible.

### 2. CSS exacto

Añadir al final de `styles.css`, antes del bloque temporal de demo, bajo el comentario `/* Components — Page footer (DESIGN.md > components/pie) */`:

```css
.page-footer {
  margin-top: var(--space-lg);
  padding: var(--space-lg);
  border-top: 1px solid var(--color-border);
  color: var(--color-on-surface);
  font-family: var(--font-family-base);
  font-size: var(--text-body-md-font-size);
  font-weight: var(--text-body-md-font-weight);
  line-height: var(--text-body-md-line-height);
  text-align: center;
}

.page-footer__text {
  margin: 0;
}

.page-footer__link {
  color: var(--color-accent);
  text-decoration: underline;
  text-underline-offset: 2px;
}

.page-footer__link:focus-visible {
  outline: 2px solid var(--color-accent);
  outline-offset: 2px;
}

.page-footer__separator {
  margin: 0 var(--space-xs);
}
```

- `margin-top: var(--space-lg)` da aire entre el contenido previo y el divisor; `padding: var(--space-lg)` da aire interno y separa el texto del borde inferior de la tarjeta.
- El borde usa `--color-border` (`#ebeef2`) y ocupa el ancho del content box de la tarjeta (356px en 390×844, 398px en 1280×800); el borde de 1px de la tarjeta queda fuera.
- Tipografía: `body-md` (13px/20px, peso 400) elegida sobre `body-sm` para legibilidad móvil; `DESIGN.md` permite `body-sm` o `body-md`.
- Color base: `--color-on-surface` (`#2d3139`) en lugar de `--color-on-surface-variant` (`#717886`). Motivo: `#717886` sobre blanco mide 4.44:1 y no cumple AA 4.5:1 para texto normal de 13px; `#2d3139` mide 13.04:1. La jerarquía de "meta" se mantiene por tamaño (13px) y peso (400), no por un color que incumple AA.
- Enlaces: `--color-accent` (`#585ce5`) con subrayado permanente; 5.15:1 sobre blanco, cumple AA. No se añade hover con cambio de color para no introducir estados ni transiciones no pedidos.
- No se añaden tokens nuevos ni se modifica `:root`.

### 3. Accesibilidad

- Controles reales `<a href>` con nombre accesible desde el texto visible; el Handle añade contexto con `aria-label`.
- Foco visible en ambos enlaces con outline de acento 2px y offset 2px.
- Enlaces inline: se mantiene la excepción de tamaño de objetivo de WCAG 2.5.8 para enlaces dentro de una frase; no se inflan con padding negativo ni se rompe el flujo del pie. El baseline de accesibilidad puede reevaluar el objetivo táctil.
- Contraste base 13.04:1 y enlaces 5.15:1; documentar los cálculos en la evidencia.
- El separador es decorativo y está oculto a tecnologías de asistencia.
- No hay transiciones, animaciones ni transformaciones en el pie; `prefers-reduced-motion` no requiere una regla nueva. El bloque existente de `.link-button` se conserva.

### 4. Harness / `init.sh`

Añadir una sección `Page footer checks:` después de los checks de page shell y antes del comando de servido:

- Markup: `index.html` contiene `<footer class="page-footer">` y `class="page-footer__link"`.
- Destinos: contiene exactamente `href="mailto:fahedhermoza@gmail.com"` y `href="https://www.instagram.com/fahedhermoza/"`.
- Contrato CSS: extraer la regla base `.page-footer { … }` con awk y exigir `border-top: 1px solid var(--color-border);`, `text-align: center;`, `padding: var(--space-lg);`, `font-size: var(--text-body-md-font-size);` y `color: var(--color-on-surface);`.
- Enlace: extraer `.page-footer__link { … }` y exigir `color: var(--color-accent);`, `text-decoration: underline;` y `text-underline-offset: 2px;`.
- Foco: exigir que exista `.page-footer__link:focus-visible` y `outline: 2px solid var(--color-accent);`.
- Salidas esperadas: `[ok] page footer markup`, `[ok] page footer destinations`, `[ok] page footer contract (5/5)`, `[ok] page footer link accent`, `[ok] page footer focus-visible`.
- No comprobar el contenido textual exacto del pie ni el orden visual del DOM; eso se valida en navegador.
- Cambiar el comando impreso y `RUN_SERVE_COMMAND` de 3101 a **3203**. El script sigue sin arrancar servidor por defecto; `RUN_SERVE_COMMAND=1` sirve en 3203.
- No debilitar ni eliminar los checks existentes de bootstrap, tokens, componente y page shell.

### 5. Cierre

- Registrar evidencia en `feature_list.json` (`status: passing` + `evidence`) y en `PROGRESS.md` (sesión y estado verificado).
- No marcar `page-footer` como `accepted`: eso corresponde al validador.
- No tocar el estado de otras features.

## Expected File Changes

- `index.html` — modificar; añadir el `<footer class="page-footer">` después de la demo, dentro de `.card`. Nada más.
- `styles.css` — modificar; añadir la sección del pie con las reglas exactas. No tocar `:root`, `body`, `.page`, `.card`, `.link-button` ni la demo.
- `init.sh` — modificar; añadir los checks del pie y usar 3203 en el comando impreso/`RUN_SERVE_COMMAND`.
- `feature_list.json` — modificar; `page-footer` a `passing` con evidencia (implementador).
- `PROGRESS.md` — modificar; estado verificado y sesión (implementador).
- `docs/specs/page-footer.md` — crear; este spec (planner).
- `docs/validations/page-footer.md` — crear; lo genera el validador, no el implementador.
- No se crean archivos de producto, assets ni dependencias nuevas.

## Visual Design Impact

- UI involved: yes.
- Design source: `DESIGN.md` > `components.pie`, `colors`, `typography` (`body-md`), `Components > Pie`, `Accessibility Baseline`.
- Screens or states affected: única vista; pie al final de la tarjeta en móvil y escritorio; estados normal y `:focus-visible` de los dos enlaces.
- New design artifact required: no — todos los valores salen de tokens; la única decisión derivada es el color base `on-surface` por AA, documentada arriba.

## Durable Documentation Impact

- `ARCHITECTURE.md`: not needed — no cambian stack, capas ni boundaries.
- `CONSTRAINTS.md`: not needed — no se introduce una regla MUST/MUST NOT nueva; se aplican las existentes (tokens, sin dependencias, foco visible).
- `AGENTS.md`: not needed — el camino de arranque sigue siendo `./init.sh`; solo se añaden checks y se ajusta el puerto sugerido.
- `docs/technical-discovery.md`: not needed — ya documenta las URLs de correo e Instagram.
- `docs/risks-and-open-questions.md`: not needed — la decisión de color se resuelve dentro de la paleta; no queda un riesgo nuevo sin resolver.
- `DESIGN.md`: not needed — es fuente de verdad y no se modifica.

## Implementation Plan

1. Insertar el `<footer class="page-footer">` como último hijo de `article.card`, después de la demo, con el markup exacto.
2. Añadir la sección CSS del pie antes del bloque `[data-demo="link-button"]`, sin tocar reglas existentes.
3. Extender `init.sh` con los checks del pie y cambiar el puerto sugerido a 3203; conservar el comportamiento no bloqueante.
4. Ejecutar `./init.sh` y los casos negativos en copia temporal; servir en 3203 y verificar en navegador 390×844 y 1280×800.
5. Registrar evidencia en `feature_list.json` y `PROGRESS.md`.

## Implementation Tasks

- [ ] Añadir el `<footer class="page-footer">` con `<p class="page-footer__text">`, el enlace `mailto:`, el separador `aria-hidden` y el enlace del Handle con `aria-label`.
- [ ] Añadir `.page-footer` con `margin-top`/`padding` de `space-lg`, `border-top: 1px solid var(--color-border)`, `text-align: center`, tipografía `body-md` y color `on-surface`.
- [ ] Añadir `.page-footer__text { margin: 0; }`, `.page-footer__link` con acento/subrayado/offset y `:focus-visible` con outline de acento.
- [ ] Añadir `.page-footer__separator` con margen horizontal `space-xs`.
- [ ] Ampliar `init.sh` con los cinco checks del pie y el puerto 3203, sin quitar checks previos.
- [ ] Probar `bash -n init.sh`, `./init.sh` (exit `0`) y los casos negativos en copia temporal.
- [ ] Verificar en navegador 390×844 y 1280×800: geometría, estilos computados, foco, consola y red.
- [ ] Registrar evidencia en `feature_list.json` y `PROGRESS.md`.

## Verification Plan

### Gate

- `bash -n init.sh` → sin errores de sintaxis.
- `./init.sh` → `Harness status: bootstrapped`, bootstrap `[ok]`, tokens `51/51`, componente `[ok]`, page shell `[ok]` y los cinco checks nuevos `[ok]`; exit `0`; sin servidor.
- Casos negativos en una copia temporal fuera del repo (nunca sobre el worktree):
  1. Eliminar `<footer class="page-footer">` → exit `1`, stderr con markup faltante.
  2. Cambiar `mailto:fahedhermoza@gmail.com` por otro destino → exit `1`, stderr con destino de correo faltante.
  3. Cambiar el `href` de Instagram → exit `1`, stderr con destino del Handle faltante/inesperado.
  4. Eliminar `border-top: 1px solid var(--color-border);` de `.page-footer` → exit `1`, `page footer contract is missing 1 of 5 required declarations`.
  5. Eliminar `color: var(--color-accent);` de `.page-footer__link` → exit `1`, stderr de acento faltante.
  6. Eliminar `outline: 2px solid var(--color-accent);` de `:focus-visible` → exit `1`, stderr de foco faltante.
- En todos los casos: `lsof -nP -iTCP:3203 -sTCP:LISTEN` vacío; copia temporal eliminada; repo intacto.

### Browser

- `python3 -m http.server 3203 --directory .` (o `RUN_SERVE_COMMAND=1 ./init.sh`); detener solo ese proceso al terminar.
- `curl -sI http://localhost:3203/` → `200 text/html`; `curl -sI http://localhost:3203/styles.css` → `200 text/css`; Google Fonts `200`/`304`.
- **390×844 (móvil):**
  - Consola con **0 mensajes/errores**; red sin 4xx/5xx y sin `/favicon.ico`.
  - El pie es visible (scroll si hace falta) y es el último bloque de la tarjeta.
  - Computed `.page-footer`: `border-top-width: 1px`, `border-top-style: solid`, `border-top-color: rgb(235, 238, 242)`, `text-align: center`, `padding: 24px`, `margin-top: 24px`, `font-size: 13px`, `line-height: 20px`, `font-weight: 400`, `color: rgb(45, 49, 57)`.
  - Ancho del pie = content box de la tarjeta (356px; `x = 17`), sin desbordar; `scrollWidth == clientWidth == 390`.
  - Enlaces: `color: rgb(88, 92, 229)`, `text-decoration-line: underline`, `text-underline-offset: 2px`; `href` de correo y Handle exactos; nombres accesibles `fahedhermoza@gmail.com` y `@fahedhermoza en Instagram`.
  - `Tab` por ambos enlaces → `:focus-visible=true`, outline `2px solid rgb(88, 92, 229)`, offset `2px`.
- **1280×800 (escritorio):**
  - Consola con 0 mensajes; red sin fallos; sin `/favicon.ico`.
  - Tarjeta centrada, pie visible en el primer viewport; ancho del pie = content box de la tarjeta (398px).
  - Mismos estilos computados y enlaces que en móvil; texto en una línea; `scrollWidth == clientWidth`.
- **320×844 (extra recomendado):** el pie envuelve el texto en dos líneas dentro de la tarjeta sin scroll horizontal (`scrollWidth == clientWidth == 320`); el borde y el centrado se mantienen.
- **Reduced motion:** `getComputedStyle` de `.page-footer` y `.page-footer__link` no tiene transiciones (`transition-duration: 0s`); el bloque `prefers-reduced-motion` de `.link-button` sigue presente y activo.
- **Contraste:** registrar 13.04:1 para `#2d3139` sobre `#ffffff` y 5.15:1 para `#585ce5` sobre `#ffffff`; ambas superan AA 4.5:1.
- **No activar** `mailto:` ni navegar a Instagram durante la verificación automatizada; comprobar los `href` en el DOM.
- E2E: no aplica; no existe harness E2E y añadirlo introduciría dependencias prohibidas. La verificación es gate + navegador.

## Evidence To Capture

- Salida de `./init.sh` correcto (exit `0`, cinco checks nuevos) y de los seis casos negativos (exit `1`, stderr correcto, sin listener en 3203).
- `curl -sI` de `/` y `/styles.css`; estado de Google Fonts.
- Valores computados del pie y de ambos enlaces en 390×844 y 1280×800 (borde, padding, margin, tipografía, color, ancho, alineación, subrayado y offset).
- Resultado de foco de teclado (`Tab`) y de `prefers-reduced-motion`.
- Consola y red de ambos viewports: 0 errores/mensajes y 0 peticiones fallidas, sin `/favicon.ico`.
- Ratios de contraste medidos (13.04:1 y 5.15:1).
- Resultado extra de 320×844 si se ejecuta (sin scroll horizontal).
- Screenshots opcionales (no obligatorios).
- `feature_list.json` (`status: passing`, `evidence`) y `PROGRESS.md` actualizados; ninguna otra feature modificada.

## Risks And Mitigations

- **Destino del Handle ambiguo:** los docs no definen una URL para `@fahedhermoza`. Mitigación: se elige Instagram porque es la única integración de `docs/technical-discovery.md` cuya ruta coincide exactamente con el Handle; el `href` se concentra en un solo atributo y es trivial de cambiar.
- **Color base distinto de `on-surface-variant`:** `#717886` mide 4.44:1 y no cumple AA. Mitigación: se usa `on-surface` (13.04:1) dentro de la paleta; se documenta la decisión.
- **Borde de 1px frente al borde de la tarjeta:** el borde del pie cubre el content box, no los 1px del borde de `.card`. Mitigación: se acepta como ancho completo útil; no se introducen márgenes negativos.
- **Padding futuro de la tarjeta:** hoy `.card` no tiene padding; si otra feature lo añade, el pie se estrechará. Mitigación: el pie es autónomo y no depende de padding del contenedor.
- **Demo temporal:** su margen inferior condiciona la separación visual del pie; el pie sigue siendo válido cuando la demo se retire.
- **Objetivo táctil de enlaces inline:** miden menos de 44px de alto. Mitigación: son enlaces inline (excepción de WCAG 2.5.8); `accessibility-baseline` puede reevaluar.
- **Gate basado en `grep`/`awk` textual:** puede dar falsos positivos si las declaraciones se comentan. Mitigación: se mantiene el patrón existente y el validador debe comprobar el comportamiento real en navegador.
- **Puerto 3203:** puede estar ocupado en otra sesión. Mitigación: comprobar con `lsof` y detener solo el servidor propio; no cambiar de puerto en silencio.

## Acceptance Criteria

- [ ] Existe `<footer class="page-footer">` como último hijo de `article.card`, con borde superior de 1px `#ebeef2`, texto centrado y padding/margen de `space-lg`.
- [ ] El pie muestra el correo `fahedhermoza@gmail.com` como enlace `mailto:` y el Handle `@fahedhermoza` como enlace a `https://www.instagram.com/fahedhermoza/`.
- [ ] Ambos enlaces usan `#585ce5`, subrayado y foco visible (`2px solid #585ce5`, offset 2px).
- [ ] El texto base mide 13px/20px, peso 400, color `#2d3139`; contraste 13.04:1; enlaces 5.15:1.
- [ ] El pie no genera scroll horizontal en 390×844 ni 1280×800; el texto está centrado.
- [ ] No se modifican `.page`, `.card`, `.link-button`, `body`, `:root`, la demo ni los 51 tokens.
- [ ] `./init.sh` pasa (exit `0`), conserva todos los checks previos, añade los cinco del pie y no arranca servidor por defecto; los seis casos negativos fallan con exit `1`.
- [ ] Navegador 390×844 y 1280×800: 0 errores/mensajes de consola, 0 peticiones fallidas y sin `/favicon.ico`.
- [ ] No se añaden frameworks, JavaScript, dependencias, assets ni otras features.
- [ ] `feature_list.json` y `PROGRESS.md` registran la evidencia; `page-footer` queda en `passing`, no en `accepted`.

## Validator Checklist

- [ ] El implementador se limitó a `page-footer`; no implementó Enlaces reales, Perfil, vCard, Open Graph ni retiró la demo.
- [ ] Los escenarios de aceptación pasan.
- [ ] El markup y el CSS coinciden con los contratos exactos (clases, `href`, borde, tipografía, color, padding, foco).
- [ ] El pie es el último hijo de la tarjeta y el page shell permanece intacto.
- [ ] `:root` sigue con 51 tokens; no hay `<script>`, `package.json`, bundler ni dependencias nuevas.
- [ ] `./init.sh` pasa, conserva los checks previos y falla ante cada caso negativo sin arrancar servidor.
- [ ] La verificación en navegador 390×844 y 1280×800 se ejecutó en el puerto 3203 con 0 errores de consola y 0 peticiones fallidas.
- [ ] Los valores computados del pie y de los enlaces coinciden; el foco de teclado es visible; no hay scroll horizontal.
- [ ] Los contrastes medidos (13.04:1 y 5.15:1) están registrados y cumplen AA.
- [ ] No hay transiciones nuevas; `prefers-reduced-motion` de `.link-button` sigue intacto.
- [ ] `feature_list.json` y `PROGRESS.md` están actualizados correctamente; `docs/validations/page-footer.md` se crea solo en la validación.
- [ ] El supuesto del Handle → Instagram está documentado y el validador lo acepta o lo devuelve como `revise` si hay una fuente mejor.

## Assumptions And Open Questions

### Assumptions

- **Destino del Handle:** `@fahedhermoza` enlaza a `https://www.instagram.com/fahedhermoza/`. Justificación: `CONTEXT.md` define el Handle como identificador público, pero ningún documento define su URL; `docs/technical-discovery.md` lista Instagram con la ruta exacta `fahedhermoza`, por lo que es el destino más defendible ya presente en el repo. Si el propietario prefiere otro destino, solo cambia el `href` y el `aria-label` del segundo enlace.
- `1rem = 16px`; por eso `space-lg = 24px` y `body-md = 13px/20px`.
- El navegador de verificación soporta custom properties, `min()` y `dvh`.
- El puerto 3203 está libre en este worktree.
- La demo temporal de botones sigue presente; el pie se coloca después de ella y será el último bloque al retirarla.
- No se activa `mailto:` en la automatización porque abriría una app del sistema; la corrección se comprueba por `href`.

### Open Questions

- **Handle:** confirmar si el enlace del Handle debe apuntar a Instagram, LinkedIn o a un futuro destino propio. No bloquea: se usa Instagram y el cambio es de un atributo.
- **Objetivo táctil:** ¿se exige ≥44×44px también para enlaces inline del pie? Se difiere a `accessibility-baseline`; WCAG 2.5.8 los exceptúa por ser inline.
- **Contraste de botones:** el 3.86–4.13:1 de `.link-button` sigue siendo riesgo heredado de `accessibility-baseline`; esta feature no lo modifica.
