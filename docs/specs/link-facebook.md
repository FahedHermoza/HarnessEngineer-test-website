# Feature Implementation Spec: Enlace a Facebook

## Source Feature

- `id`: `link-facebook`
- `area`: `links`
- `depends_on`: `["link-button-component"]` (satisfied: `accepted`)
- `status`: `not_started` (at planning time; this spec does not change it)
- `source`: `feature_list.json`
- `notes`: URL en `docs/technical-discovery.md` > `Integrations`; componente en `DESIGN.md` > `components.button-link`; contenido visible en español.

## Goal

Añadir el primer Enlace real de la Tarjeta digital: un botón **Facebook** que usa el componente existente `.link-button`, un icono SVG de Facebook inline y el destino exacto `https://www.facebook.com/fahed19`.

El Enlace se inserta dentro de la tarjeta, después del bloque de identidad y antes de la demo temporal de `link-button-component`, dentro de un contenedor mínimo `<nav class="links">`. La demo temporal, el Perfil, el pie, el page shell, los tokens y el resto de la página se conservan intactos. El alcance termina cuando el enlace es visible y verificable en móvil (390×844) y escritorio (1280×800), el gate de `init.sh` detecta su contrato y la evidencia queda registrada.

## Non-Goals

- No implementar ningún otro Enlace (`link-instagram`, `link-whatsapp`, `link-linkedin`, `link-portafolio`, `link-correo`, `link-celular`).
- No implementar el orden de los siete Enlaces, la progresión del degradado entre botones, el `gap` de la lista ni la retirada de la demo; todo eso pertenece a `links-order-gradient`.
- No retirar ni modificar la demo `[data-demo="link-button"]`, sus cinco anclas, su CSS ni su comentario temporal.
- No implementar vCard, avatar fallback, Open Graph, favicon, `theme-color`, modo oscuro ni i18n.
- No añadir tokens, colores, tipografías, sombras, radios ni espaciados nuevos; no tocar `:root` (51 tokens), `body`, `.page`, `.card`, `.link-button`, `.profile*` ni `.page-footer`.
- No añadir JavaScript, frameworks, bundlers, preprocesadores, npm, dependencias ni assets.
- No añadir `target="_blank"` ni `rel`: el enlace navega en la misma pestaña, como el resto de la página.
- No resolver el contraste AA de la etiqueta blanca sobre `gradient-1`; es un riesgo heredado de `link-button-component` para `accessibility-baseline`.
- No activar la navegación externa a Facebook durante la verificación automatizada: se comprueba el `href` y el nombre accesible en el DOM.

## Job Story

When estoy viendo la Tarjeta digital y quiero conectar con Fahed por Facebook,
I want to pulsar un botón claro con el icono y el nombre de Facebook,
so I can abrir su perfil correcto sin copiar ni buscar la URL a mano.

## Users And Permissions

- Visitante anónimo: ve el Enlace, puede activarlo con toque, ratón o teclado; no hay autenticación ni estado.
- Implementador/agente: añade markup, la regla mínima del contenedor, los checks de `init.sh` y la evidencia; no implementa otras features.
- Validador: reproduce el gate, los casos negativos y las mediciones de navegador en 390×844 y 1280×800.

## Acceptance Scenarios

### Scenario 1: Enlace visible y colocado

Given la página servida en `http://localhost:3302` con viewport 390×844,
When se carga la tarjeta,
Then existe un `<nav class="links" aria-label="Enlaces de contacto">` dentro de `article.card`, después de `header.profile-identity` y antes de `section#link-button-demo`, con exactamente un `<a>` visible cuyo texto es `Facebook`.

### Scenario 2: Destino y nombre accesible exactos

Given el Enlace renderizado,
When se inspecciona el DOM y el árbol de accesibilidad,
Then es un `<a>` real con `href="https://www.facebook.com/fahed19"`, `aria-label="Facebook de Fahed Hermoza"`, sin `target` ni `rel`; su nombre accesible contiene el texto visible `Facebook`.

### Scenario 3: Contrato visual del componente

Given el Enlace renderizado en 390×844 o 1280×800,
When se inspeccionan sus estilos computados,
Then mide `48px` de alto, ocupa el `100%` del content box de `.links`, tiene `border-radius: 6px`, `padding: 0px 20px`, `display: flex`, `justify-content: space-between`, etiqueta `11px/800` con `letter-spacing: 1.98px` y `text-transform: uppercase`, texto blanco, fondo `--color-gradient-1` (`rgb(104, 118, 240)`) e icono SVG de 18×18 alineado a la derecha.

### Scenario 4: Foco, hover y movimiento reducido

Given el Enlace en escritorio o con teclado,
When se fuerza `:hover` o se navega con `Tab` hasta el Enlace,
Then se aplican `translateY(-1.5px)`, la sombra de hover de `.link-button` y `filter: brightness(1.03)`; el foco de teclado muestra `outline: 2px solid rgb(88, 92, 229)` con `outline-offset: 2px`; con `prefers-reduced-motion: reduce`, `transition-duration` es `0s` y `transform` es `none`.

### Scenario 5: Responsive sin scroll horizontal

Given viewports 390×844, 1280×800 y el edge 320×844,
When se carga la página,
Then no hay scroll horizontal (`scrollWidth === clientWidth`), el Enlace conserva 48px de alto y el ancho completo de su contenedor, y el icono/label no se recortan.

### Scenario 6: El gate detecta un Enlace roto

Given una copia temporal con el `href` alterado, el `aria-label` eliminado, la etiqueta visible cambiada, el contenedor `.links` renombrado, el icono sin `aria-hidden`/`fill="currentColor"` o el padding de `.links` alterado,
When se ejecuta `./init.sh`,
Then sale con código distinto de `0`, imprime el check fallido en stderr y no arranca ningún servidor.

### Scenario 7: Sin daño colateral

Given la implementación terminada,
When se revisa el diff y la página,
Then la demo temporal sigue con sus cinco botones, y el Perfil, identidad, avatar, pie, page shell, `:root` (51 tokens), `body` y `.link-button` no cambiaron; no hay `<script>`, `package.json`, bundler, dependencias ni assets nuevos.

## Repository Research

### Files Inspected

- `AGENTS.md` — Definition of Done, validación obligatoria en 390×844 y 1280×800, alcance por feature y reglas de dependencias.
- `PROGRESS.md` — `link-button-component`, `page-shell`, `profile-avatar`, `profile-identity`, `page-footer` y `open-graph-metadata` en `accepted`; la demo temporal sigue vigente.
- `feature_list.json` — metadata, verificación y notas de `link-facebook`; dependencia `link-button-component` aceptada.
- `DESIGN.md` — `components.button-link` (48px, `rounded.md`, `on-primary`, `button-label`), `colors` (`gradient-1`…`gradient-5`), `Layout` (botones con separación `space-sm`, pie con `space-lg`) y baseline de accesibilidad.
- `docs/technical-discovery.md` — Facebook: `https://www.facebook.com/fahed19`; SVG inline sin dependencias; verificación manual y en viewports.
- `docs/build-brief.md` — orden de los siete Enlaces: Instagram, Facebook, WhatsApp, LinkedIn, Portafolio, Correo, Celular.
- `docs/domain-model.md` — un Enlace tiene tipo, etiqueta, icono, URL destino y orden; la URL y el orden son datos de esta feature y de `links-order-gradient` respectivamente.
- `CONTEXT.md` — vocabulario Enlace y lista MVP; no define una URL de Facebook distinta.
- `docs/risks-and-open-questions.md` — riesgo heredado de contraste de etiquetas `.link-button` (3.86–4.13:1); no se resuelve aquí.
- `docs/specs/link-button-component.md` y `docs/specs/page-footer.md` — formato de spec, contrato exacto del componente y convención de checks/evidencia.
- `index.html` — `article.card` contiene `header.profile`, `header.profile-identity`, la demo temporal `section#link-button-demo` y `footer.page-footer`; `<head>` ya declara `<link rel="icon" href="data:,">`.
- `styles.css` — 51 tokens en `:root`, `body`, `.page`, `.card`, `.profile*`, `.link-button` con sus modificadores y estados, `.page-footer` y `[data-demo="link-button"]`.
- `init.sh` — gate no bloqueante con checks acumulativos de bootstrap, tokens, componente, page shell, avatar, pie, identidad y metadatos; no arranca servidor salvo `RUN_SERVE_COMMAND=1` (puerto 3201).
- `assets/` — solo `avatar.jpg` y `.DS_Store`; no se usan en esta feature.

### Existing Patterns To Follow

- HTML estático con CSS plano, una sola hoja `styles.css`, tokens como custom properties y sin build.
- Clases BEM-ish (`link-button`, `link-button__label`, `link-button__icon`, `link-button--gradient-N`); no se inventan clases de tono nuevas.
- `init.sh` con `set -euo pipefail`, checks que imprimen `[ok]`, fallos a stderr y exit `1`, sin servidor por defecto.
- Evidencia durable en `feature_list.json` (`status` + `evidence`) y `PROGRESS.md`; el validador crea `docs/validations/link-facebook.md`.
- La demo temporal se conserva hasta que `links-order-gradient` (u otra feature de enlaces) la retire.

### Current Gaps

- No existe ningún Enlace real ni contenedor `.links` en el markup.
- La demo temporal ocupa el lugar donde vivirán los Enlaces reales; esta feature inserta el Enlace antes de ella sin retirarla.
- No hay harness E2E ni framework de tests; la verificación es `init.sh` + navegador (`docs/technical-discovery.md`).
- El contraste de la etiqueta blanca sobre `gradient-1` mide 3.86:1 y sigue por debajo de AA 4.5:1; se documenta y se difiere a `accessibility-baseline`.

## Technical Approach

### 1. Markup exacto

Insertar como hijo directo de `<article class="card">`, después del `</header>` de `.profile-identity` y antes del comentario de la demo temporal:

```html
<nav class="links" aria-label="Enlaces de contacto">
  <a class="link-button link-button--gradient-1" href="https://www.facebook.com/fahed19" aria-label="Facebook de Fahed Hermoza">
    <span class="link-button__label">Facebook</span>
    <svg class="link-button__icon" viewBox="0 0 24 24" width="18" height="18" fill="currentColor" aria-hidden="true" focusable="false">
      <path d="M9.101 23.691v-7.98H6.627v-3.667h2.474v-1.58c0-4.085 1.848-5.978 5.858-5.978.401 0 .955.042 1.468.103a8.68 8.68 0 0 1 1.141.195v3.325a8.623 8.623 0 0 0-.653-.036 26.805 26.805 0 0 0-.733-.009c-.707 0-1.259.096-1.675.309a1.686 1.686 0 0 0-.679.622c-.258.42-.374.995-.374 1.752v1.297h3.919l-.386 2.103-.287 1.564h-3.246v8.245C19.396 23.238 24 18.179 24 12.044c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.628 3.874 10.35 9.101 11.647Z"/>
    </svg>
  </a>
</nav>
```

- `<nav>` agrupa los Enlaces reales y crea un landmark navegable con nombre accesible `Enlaces de contacto`; la demo queda fuera.
- El `<a>` es el control real; no se usa `<button>` porque navega a una URL.
- La etiqueta visible es `Facebook`; `aria-label="Facebook de Fahed Hermoza"` añade contexto y contiene el texto visible (label-in-name).
- No se usa `target="_blank"` ni `rel`; no se añade `title`.
- El SVG es decorativo (`aria-hidden="true"`, `focusable="false"`), usa `fill="currentColor"` (blanco por `.link-button`) y el glifo de Facebook inline (Simple Icons, CC0; sin dependencia de runtime).
- El `<a>` se escribe con el `href`, las clases y el `aria-label` en la etiqueta de apertura para que el contrato sea legible y el gate encuentre las cadenas exactas dentro del bloque `<nav>`.

### 2. CSS exacto

Añadir en `styles.css`, entre el bloque `@media (prefers-reduced-motion: reduce)` de `.link-button` y la sección `/* Components — Page footer ... */`:

```css
/* Links — Contenedor de Enlaces reales. El orden, el gap y la progresión del degradado pertenecen a links-order-gradient. */
.links {
  padding: 0 var(--space-lg);
}
```

- Única regla nueva. No se añaden colores, tokens, sombras ni transiciones.
- El padding horizontal de 24px alinea el botón con `.profile-identity` y `.page-footer`; el botón conserva el 100% del content box de `.links`.
- No se añade `gap`, `display: flex` ni progresión de tonos: con un solo Enlace no son necesarios y `links-order-gradient` los definirá.
- `.link-button` ya aplica el fondo por defecto `--color-gradient-1`; el modificador `link-button--gradient-1` se declara de forma explícita para dejar el contrato preparado para la futura progresión.

### 3. Icono

- SVG inline de 24×24 con `width="18" height="18"`; `.link-button__icon` lo fija a 18×18 y `flex: 0 0 18px`.
- `fill="currentColor"` hereda el blanco de `.link-button`; no se usa `stroke` ni un color fuera de la paleta.
- El icono va a la derecha por el `justify-content: space-between` del componente; su borde derecho queda a 20px del borde derecho del botón.
- No se crea ningún archivo en `assets/` ni se referencia una URL externa para el icono.

### 4. Accesibilidad

- Control real `<a href>` con nombre accesible `Facebook de Fahed Hermoza`; el texto visible `Facebook` está contenido en el nombre.
- Icono decorativo con `aria-hidden="true"` y `focusable="false"`; no aporta nombre.
- Área táctil de 48px de alto por el ancho del contenedor (≥44×44px).
- Foco visible heredado de `.link-button:focus-visible` (outline de acento 2px, offset 2px).
- La etiqueta se escribe en caja normal y el CSS la transforma a mayúsculas; el nombre accesible conserva el texto legible.
- **Contraste:** blanco `#ffffff` sobre `gradient-1` `#6876f0` mide **3.86:1**, por debajo de AA 4.5:1 para `button-label` (11px/800). No se corrige aquí: cambiar tokens o el tamaño de etiqueta está fuera de alcance y corresponde a `accessibility-baseline`. Se registra en la evidencia; el icono es decorativo.

### 5. Harness / `init.sh`

Añadir una sección `Link checks:` después del bloque `Profile identity checks:` y antes de `Sharing metadata checks:`. No cambiar ni debilitar los checks existentes, y no cambiar el comando/`RUN_SERVE_COMMAND` genérico (3201): el puerto 3302 es solo para la verificación manual de esta sesión.

Checks esperados:

1. `[ok] links container` — existe exactamente `<nav class="links" aria-label="Enlaces de contacto">` en `index.html`.
2. `[ok] facebook link markup` — el bloque `<nav class="links" ...> … </nav>` contiene:
   - `href="https://www.facebook.com/fahed19"`
   - `class="link-button link-button--gradient-1"`
   - `<span class="link-button__label">Facebook</span>`
   - `aria-label="Facebook de Fahed Hermoza"`
3. `[ok] facebook link icon` — el mismo bloque contiene `class="link-button__icon"`, `fill="currentColor"`, `aria-hidden="true"` y `focusable="false"`.
4. `[ok] links container padding` — la regla `.links { … }` extraída con `awk` contiene `padding: 0 var(--space-lg);`.

Implementación sugerida del gate (adaptar nombres al estilo existente):

```bash
echo "Link checks:"

if grep -qF '<nav class="links" aria-label="Enlaces de contacto">' index.html; then
  echo "  [ok] links container"
else
  fail 'index.html is missing the links container (<nav class="links" aria-label="Enlaces de contacto">)'
fi

LINKS_BLOCK=$(awk '
  /<nav class="links"/ { in_nav = 1 }
  in_nav { print }
  in_nav && /<\/nav>/ { exit }
' index.html)

if printf '%s\n' "$LINKS_BLOCK" | grep -qF 'href="https://www.facebook.com/fahed19"' \
  && printf '%s\n' "$LINKS_BLOCK" | grep -qF 'class="link-button link-button--gradient-1"' \
  && printf '%s\n' "$LINKS_BLOCK" | grep -qF '<span class="link-button__label">Facebook</span>' \
  && printf '%s\n' "$LINKS_BLOCK" | grep -qF 'aria-label="Facebook de Fahed Hermoza"'; then
  echo "  [ok] facebook link markup"
else
  fail "index.html is missing the Facebook link markup (href, .link-button--gradient-1, visible label or accessible name)"
fi

if printf '%s\n' "$LINKS_BLOCK" | grep -qF 'class="link-button__icon"' \
  && printf '%s\n' "$LINKS_BLOCK" | grep -qF 'fill="currentColor"' \
  && printf '%s\n' "$LINKS_BLOCK" | grep -qF 'aria-hidden="true"' \
  && printf '%s\n' "$LINKS_BLOCK" | grep -qF 'focusable="false"'; then
  echo "  [ok] facebook link icon"
else
  fail "index.html is missing the decorative Facebook icon (currentColor, aria-hidden or focusable)"
fi

LINKS_RULE=$(awk '
  /^[[:space:]]*\.links[[:space:]]*\{/ { in_rule = 1 }
  in_rule { print }
  in_rule && /}/ { exit }
' styles.css)

if [ -n "$LINKS_RULE" ] && printf '%s\n' "$LINKS_RULE" | grep -qF 'padding: 0 var(--space-lg);'; then
  echo "  [ok] links container padding"
else
  fail "styles.css is missing the links container padding: 0 var(--space-lg);"
fi
```

- En cualquier fallo: mensaje a stderr, `Harness status: FAILED - ...`, exit `1` y ningún servidor.
- El gate no verifica la posición DOM del `<nav>` ni el orden de los hijos de `.card`; eso se valida en navegador.
- El gate no distingue el primer ancla de la demo porque extrae únicamente el bloque `<nav class="links">`.

### 6. Cierre

- Registrar evidencia en `feature_list.json` (`status: passing` + `evidence`) y `PROGRESS.md` (sesión y estado verificado).
- No marcar `link-facebook` como `accepted`: eso corresponde al validador.
- No tocar el estado de otras features.

## Expected File Changes

- `index.html` — modificar; añadir `<nav class="links">` con el Enlace Facebook entre `.profile-identity` y la demo. Nada más.
- `styles.css` — modificar; añadir solo la regla `.links` con `padding: 0 var(--space-lg);`.
- `init.sh` — modificar; añadir `Link checks:` con los cuatro checks, sin tocar los previos ni el puerto genérico.
- `feature_list.json` — modificar; `link-facebook` a `passing` con evidencia (implementador).
- `PROGRESS.md` — modificar; estado verificado y bitácora (implementador).
- `docs/specs/link-facebook.md` — crear; este spec (planner).
- `docs/validations/link-facebook.md` — crear; lo genera el validador, no el implementador.
- No se crean assets, dependencias ni archivos de producto nuevos.

## Visual Design Impact

- UI involved: yes.
- Design source: `DESIGN.md` > `components.button-link`, `colors` (`gradient-1`, `on-primary`), `typography.button-label`, `rounded.md`, `Layout`, `Accessibility Baseline`.
- Screens or states affected: única vista; Enlace Facebook en estado normal, hover, `:focus-visible` y `prefers-reduced-motion`, en móvil y escritorio.
- New design artifact required: no — todos los valores provienen de tokens y del componente aceptado; el icono es un SVG inline sin archivo nuevo.

## Durable Documentation Impact

- `ARCHITECTURE.md`: not needed — no cambian stack, capas ni boundaries.
- `CONSTRAINTS.md`: not needed — no se introduce un MUST/MUST NOT nuevo; se aplican tokens, componente y accesibilidad existentes.
- `AGENTS.md`: not needed — el camino de arranque sigue siendo `./init.sh`; solo se añaden checks.
- `docs/technical-discovery.md`: not needed — la URL de Facebook ya está documentada.
- `docs/risks-and-open-questions.md`: not needed — el riesgo de contraste de etiquetas `.link-button` ya está registrado y cubre este Enlace; no surge un riesgo nuevo sin resolver.
- `DESIGN.md`: not needed — es fuente de verdad y no se modifica.
- `feature_list.json` y `PROGRESS.md`: update — estado y evidencia de la implementación.

## Implementation Plan

1. Insertar el `<nav class="links">` con el Enlace Facebook exacto entre `.profile-identity` y la demo.
2. Añadir la regla `.links` en `styles.css` sin tocar las reglas existentes.
3. Extender `init.sh` con los cuatro checks de `Link checks:`.
4. Ejecutar `bash -n init.sh`, `./init.sh`, los casos negativos en copia temporal y la verificación de navegador en 390×844 y 1280×800 con el puerto 3302.
5. Registrar evidencia en `feature_list.json` y `PROGRESS.md`.

## Implementation Tasks

- [ ] Añadir `<nav class="links" aria-label="Enlaces de contacto">` como hijo de `article.card`, después de `.profile-identity` y antes de la demo.
- [ ] Añadir el `<a class="link-button link-button--gradient-1" href="https://www.facebook.com/fahed19" aria-label="Facebook de Fahed Hermoza">` con la etiqueta `Facebook` y el SVG de Facebook inline.
- [ ] Verificar que el SVG tiene 18×18, `fill="currentColor"`, `aria-hidden="true"` y `focusable="false"`.
- [ ] Añadir `.links { padding: 0 var(--space-lg); }` en `styles.css`, sin tocar `:root`, `body`, `.link-button`, `.profile*`, `.page-footer` ni la demo.
- [ ] Añadir `Link checks:` en `init.sh` con los cuatro checks y conservar todos los anteriores.
- [ ] Ejecutar `bash -n init.sh` y `./init.sh` (exit `0`, sin servidor).
- [ ] Probar los casos negativos en copias temporales fuera del repo y comprobar que no queda listener en 3302.
- [ ] Servir en 3302 y verificar 390×844 y 1280×800: geometría, estilos, foco, hover, reduced motion, consola y red.
- [ ] Comprobar que la demo, el Perfil, el pie, los 51 tokens y la ausencia de JS/dependencias/assets siguen intactos.
- [ ] Registrar evidencia en `feature_list.json` (`passing`) y `PROGRESS.md`; no cambiar el estado de otras features.

## Verification Plan

### Gate

- `bash -n init.sh` → sin errores de sintaxis.
- `./init.sh` → `Harness status: bootstrapped`, todos los checks previos `[ok]`, `[ok] links container`, `[ok] facebook link markup`, `[ok] facebook link icon`, `[ok] links container padding`; exit `0`; sin servidor.
- Casos negativos en una copia temporal fuera del repo (nunca sobre el worktree):
  1. Cambiar el `href` a `https://www.facebook.com/fahed190` → exit `1`, stderr de markup.
  2. Eliminar `aria-label="Facebook de Fahed Hermoza"` → exit `1`, stderr de markup.
  3. Cambiar la etiqueta visible a `Facebook de Fahed` → exit `1`, stderr de markup.
  4. Renombrar `<nav class="links"` a `<nav class="links-broken"` → exit `1`, stderr de contenedor.
  5. Eliminar `fill="currentColor"` o `aria-hidden="true"` del SVG → exit `1`, stderr de icono.
  6. Cambiar `.links` a `padding: 0 var(--space-md);` → exit `1`, stderr de padding.
- En todos los casos: `lsof -nP -iTCP:3302 -sTCP:LISTEN` vacío; copia temporal eliminada; repo intacto.

### Browser

- Servir solo con `python3 -m http.server 3302 --directory .`; detener ese proceso al terminar y confirmar que 3302 queda libre. No dejar servidores en segundo plano.
- `curl -sI http://localhost:3302/` → `200 text/html`; `curl -sI http://localhost:3302/styles.css` → `200 text/css`; Google Fonts `200`/`304`.
- **390×844 (móvil):**
  - Consola con **0 mensajes/errores**; red sin 4xx/5xx y sin `/favicon.ico`; no se solicita Facebook porque el enlace no se activa.
  - Orden de hijos de `article.card`: `header.profile` → `header.profile-identity` → `nav.links` → `section#link-button-demo` → `footer.page-footer`.
  - `nav.links` tiene exactamente un `<a>`; su texto es `Facebook`; su `href` y `aria-label` son exactos.
  - Rect del Enlace: 308×48 en `x=41` (tarjeta 358 en `x=16`, content box 356 en `x=17`, padding 24); `scrollWidth === clientWidth === 390`.
  - Computed: `display:flex`, `height:48px`, `box-sizing:border-box`, `padding:0px 20px`, `align-items:center`, `justify-content:space-between`, `gap:12px`, `border-radius:6px`, `color:rgb(255, 255, 255)`, `font-size:11px`, `font-weight:800`, `line-height:16px`, `letter-spacing:1.98px`, `text-transform:uppercase`, `text-decoration:none`, `background-color:rgb(104, 118, 240)`, sombra normal.
  - Icono 18×18 a la derecha, borde derecho a 20px del borde del botón; `fill` efectivo blanco; `aria-hidden="true"` y `focusable="false"`.
  - `Tab` desde la barra de direcciones lleva primero al Enlace Facebook; `:focus-visible` con outline `rgb(88, 92, 229) solid 2px` y offset 2px. No pulsar `Enter` para no navegar a Facebook.
- **1280×800 (escritorio):**
  - Consola con 0 mensajes; red sin fallos; sin `/favicon.ico`.
  - Tarjeta 400px en `x=440`; content box 398px; Enlace 350×48 en `x=465`; icono a la derecha; `scrollWidth === clientWidth === 1280`.
  - Hover real: `transform: matrix(1, 0, 0, 1, 0, -1.5)`, sombra hover `rgba(108, 114, 234, 0.28) 0px 8px 18px 0px`, `filter: brightness(1.03)`; foco de teclado con el mismo outline de acento.
- **320×844 (edge recomendado):** tarjeta 288px en `x=16`; Enlace 238×48 en `x=41`; la etiqueta `Facebook` y el icono caben sin recorte; `scrollWidth === clientWidth === 320`.
- **Reduced motion:** emular `prefers-reduced-motion: reduce`; `transition-duration: 0s` y `transform: none` en hover/foco; el outline de foco sigue visible.
- **Contraste:** registrar 3.86:1 para `#ffffff` sobre `#6876f0`; no se corrige en esta feature; el riesgo queda para `accessibility-baseline`.
- **No activar** el enlace a Facebook durante la automatización: se comprueba el `href` en el DOM. La comprobación real de que Facebook abre el perfil correcto en un teléfono queda como verificación manual del propietario.
- E2E: no aplica; no existe harness E2E y añadirlo introduciría dependencias prohibidas. La verificación es gate + navegador.

## Evidence To Capture

- Salida de `./init.sh` correcto (exit `0`, cuatro checks nuevos) y de los seis casos negativos (exit `1`, stderr correcto, sin listener en 3302).
- `curl -sI` de `/` y `/styles.css`; estado de Google Fonts.
- Orden de hijos de `article.card` y contenido exacto del `<nav class="links">`.
- Valores computados del Enlace en 390×844 y 1280×800 (rect, padding, radio, tipografía, tracking, color, fondo, icono, sombra).
- Foco de teclado, hover y `prefers-reduced-motion`.
- Consola y red de ambos viewports: 0 errores/mensajes, 0 peticiones fallidas, sin `/favicon.ico`.
- Ratio de contraste 3.86:1 y nota de riesgo heredado.
- Confirmación de que la demo (5 botones), el Perfil, la identidad, el avatar, el pie, los 51 tokens y la ausencia de JS/dependencias/assets siguen intactos.
- `feature_list.json` (`status: passing`, `evidence`) y `PROGRESS.md` actualizados; ninguna otra feature modificada.

## Risks And Mitigations

- **Navegación externa no automatizable:** abrir Facebook en la automatización ensuciaría la consola/red y generaría tráfico de terceros. Mitigación: verificar `href`, `role` y nombre accesible en el DOM; la comprobación en un teléfono real queda para el propietario.
- **Contraste AA heredado:** blanco sobre `gradient-1` mide 3.86:1. Mitigación: no se inventan colores ni se cambia el componente; se registra para `accessibility-baseline`.
- **Conflicto con otras features de enlaces:** `index.html`, `init.sh` y `PROGRESS.md` son archivos compartidos. Mitigación: diff mínimo y localizado; el contenedor `.links` se deja preparado para que `links-order-gradient` añada orden, gap y progresión.
- **Gate textual:** `grep`/`awk` pueden dar falsos positivos si el markup se comenta. Mitigación: el gate extrae solo el bloque `<nav class="links">`; el validador comprueba el DOM real.
- **`aria-label` sustituye el texto visible en el nombre accesible:** Mitigación: el nombre contiene `Facebook` (label-in-name) y añade contexto; si el producto prefiere el nombre exacto `Facebook`, se elimina el `aria-label` y se actualiza el gate.
- **Puerto 3302 ocupado:** Mitigación: comprobar con `lsof` antes de servir y detener solo el proceso propio; no cambiar de puerto en silencio.
- **Icono de marca:** el SVG inline no añade dependencias ni peticiones. Si se prefiere otro glifo, solo cambia el `<path>`; el contrato de tamaño/color no cambia.

## Rollback

- Eliminar el bloque `<nav class="links"> … </nav>` de `index.html`, la regla `.links` de `styles.css` y la sección `Link checks:` de `init.sh`.
- Revertir las entradas de `feature_list.json` (`link-facebook` a `not_started`, sin evidencia) y `PROGRESS.md`.
- No hay migraciones, datos, assets ni estado que revertir. La demo, el Perfil, el pie y el page shell quedan intactos, por lo que la página vuelve al estado previo a esta feature.
- Si otra feature de enlaces ya retiró la demo, revertir solo el bloque Facebook y su regla/checks, conservando el resto.

## Acceptance Criteria

- [ ] Existe `<nav class="links" aria-label="Enlaces de contacto">` entre `.profile-identity` y la demo, con exactamente un Enlace Facebook.
- [ ] El Enlace es un `<a>` con `href="https://www.facebook.com/fahed19"`, `class="link-button link-button--gradient-1"`, etiqueta visible `Facebook` y `aria-label="Facebook de Fahed Hermoza"`; sin `target` ni `rel`.
- [ ] El SVG es de Facebook, 18×18, `fill="currentColor"`, `aria-hidden="true"` y `focusable="false"`.
- [ ] `.links` solo añade `padding: 0 var(--space-lg);`; no se añaden tokens, colores, sombras ni transiciones.
- [ ] En 390×844 y 1280×800 el Enlace mide 48px de alto, usa el ancho completo de `.links`, radio 6px, padding 20px, tipografía 11px/800/1.98px, texto blanco y fondo `gradient-1`; no hay scroll horizontal.
- [ ] Foco visible, hover y `prefers-reduced-motion` se comportan como el componente aceptado.
- [ ] Consola con 0 mensajes y red sin 4xx/5xx ni `/favicon.ico` en ambos viewports.
- [ ] La demo temporal, el Perfil, la identidad, el avatar, el pie, el page shell y los 51 tokens siguen intactos; no hay JS, dependencias ni assets nuevos.
- [ ] `./init.sh` sale `0` con los cuatro checks nuevos y conserva todos los previos; los seis casos negativos fallan con exit `1` sin arrancar servidor.
- [ ] El contraste 3.86:1 queda registrado como riesgo heredado, sin corregirse en esta feature.
- [ ] `feature_list.json` y `PROGRESS.md` registran la evidencia; `link-facebook` queda en `passing`, no en `accepted`.

## Validator Checklist

- [ ] El implementador se limitó a `link-facebook`; no añadió otros Enlaces, orden/gradiente, vCard, avatar fallback ni otras features.
- [ ] El markup y el CSS coinciden con los contratos exactos (clases, `href`, `aria-label`, icono, padding).
- [ ] El Enlace está en el orden correcto dentro de `.card` y la demo temporal sigue presente e intacta.
- [ ] `:root` sigue con 51 tokens; no hay `<script>`, `package.json`, bundler, dependencias ni assets nuevos.
- [ ] `./init.sh` pasa, conserva los checks previos y falla ante cada caso negativo sin arrancar servidor.
- [ ] La verificación en navegador 390×844 y 1280×800 se ejecutó en el puerto 3302 con 0 errores de consola, 0 peticiones fallidas y sin `/favicon.ico`.
- [ ] Los valores computados del Enlace, el foco, el hover y `prefers-reduced-motion` coinciden; no hay scroll horizontal.
- [ ] El enlace no se activó en la automatización y el `href` exacto está verificado en el DOM.
- [ ] El contraste 3.86:1 está registrado y se acepta como riesgo heredado de `accessibility-baseline`.
- [ ] `feature_list.json` y `PROGRESS.md` están actualizados; `docs/validations/link-facebook.md` se crea solo en la validación.
- [ ] No se modificó ningún otro estado de feature.

## Assumptions And Open Questions

### Assumptions

- La URL es exactamente `https://www.facebook.com/fahed19`, sin barra final, como documenta `docs/technical-discovery.md`.
- El contenedor se llama `.links`; `links-order-gradient` podrá extenderlo (gap, orden, progresión) o renombrarlo, actualizando el gate en esa feature.
- La demo temporal se conserva después del Enlace real; esta feature no la retira.
- `1rem = 16px`; por eso `space-lg = 24px` y el content box del botón es 308px en 390×844 y 350px en 1280×800.
- El puerto 3302 está libre al planificar; si está ocupado, se reporta y no se cambia en silencio.
- El SVG de Facebook inline es el glifo de Simple Icons (CC0); no añade dependencias ni peticiones.
- No se activa la navegación externa en la automatización; la comprobación en un teléfono real es una verificación manual del propietario.

### Open Questions

- **Nombre accesible:** ¿se prefiere `Facebook de Fahed Hermoza` (contexto) o exactamente `Facebook`? Se elige el primero porque contiene el texto visible y añade claridad; cambiarlo requiere quitar el `aria-label` y ajustar el gate.
- **Pestaña:** el Enlace abre en la misma pestaña (sin `target`). Si el propietario prefiere una pestaña nueva, se añadiría `target="_blank" rel="noopener"` y se actualizaría el gate; hoy no está en alcance.
- **Contraste:** el 3.86:1 de la etiqueta sigue pendiente para `accessibility-baseline`; esta feature no lo resuelve.
