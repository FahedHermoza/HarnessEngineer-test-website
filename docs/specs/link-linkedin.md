# Feature Implementation Spec: Enlace a LinkedIn

## Source Feature

- `id`: `link-linkedin`
- `area`: `links`
- `depends_on`: `["link-button-component"]` (accepted)
- `status`: `not_started` at planning time
- `source`: `feature_list.json`
- `notes`: URL tomada de `docs/technical-discovery.md` > Integrations. El componente visual ya está aceptado en `styles.css` y su demo temporal debe conservarse.

## Goal

Añadir a la Tarjeta digital el primer Enlace real, "LinkedIn", como un `<a>` de ancho completo construido con el componente `.link-button` ya aceptado. Al pulsarlo debe navegar a `https://www.linkedin.com/in/fahedhermoza/`. El enlace debe tener nombre accesible, icono SVG inline decorativo y heredar los estados de hover/focus/movimiento reducido del componente.

El alcance termina con el markup del Enlace, un contenedor mínimo de Enlaces y un check no bloqueante en `init.sh`. La demo `[data-demo="link-button"]` y el resto de la página se mantienen intactos.

## Non-Goals

- No implementar Instagram, Facebook, WhatsApp, Portafolio, Correo ni Celular.
- No implementar orden, progresión de color, interpolación ni separación vertical entre varios Enlaces; pertenecen a `links-order-gradient`.
- No asignar un modificador `link-button--gradient-*` definitivo: este feature usa el tono base del componente y deja la progresión a `links-order-gradient`.
- No eliminar ni modificar la demo `[data-demo="link-button"]` ni su CSS.
- No usar `target="_blank"` ni añadir `rel` (navegación en la misma pestaña; el sistema puede abrir la app de LinkedIn).
- No añadir JavaScript, frameworks, bundlers, npm, dependencias, imágenes ni tokens nuevos.
- No tocar `:root`, `DESIGN.md`, el Perfil, el avatar, el pie, la vCard ni los metadatos Open Graph.
- No implementar analítica, tracking UTM ni comprobación automática de disponibilidad del destino.

## Job Story

When un visitante quiere revisar la trayectoria profesional de Fahed,
I want to pulsar un botón claro de LinkedIn en la Tarjeta digital,
so I can abrir su perfil correcto sin buscar ni escribir la URL.

## Users And Permissions

- Visitante: pulsa el Enlace y navega al perfil público; no requiere autenticación ni permisos.
- Propietario: mantiene la URL directamente en `index.html`; no hay panel ni CMS.
- Implementador/validator: añaden markup, CSS mínimo, gate y evidencia; no implementan otras features de Enlaces.

## Acceptance Scenarios

### Scenario 1: El Enlace existe y navega al perfil correcto

Given la página servida localmente,
When se inspecciona el Enlace real de LinkedIn,
Then es un `<a class="link-button">` cuyo `href` resuelve exactamente a `https://www.linkedin.com/in/fahedhermoza/`, no tiene `target` y su click inicia la navegación a ese destino.

### Scenario 2: Nombre accesible e icono decorativo

Given el markup del Enlace,
When se revisa el árbol de accesibilidad,
Then el nombre accesible se deriva del texto visible "LinkedIn" (sin `aria-label` redundante), el SVG tiene `aria-hidden="true"` y `focusable="false"`, y el control mide 48px de alto por el ancho disponible (área táctil ≥44×44px).

### Scenario 3: Consistencia visual con el componente aceptado

Given el Enlace renderizado en 390×844 y 1280×800,
When se comparan sus estilos computados con `.link-button`,
Then mide 48px de alto, radio 6px, padding horizontal 20px, etiqueta 11px/800 con tracking 1.98px y uppercase, icono de 18×18 a la derecha, fondo del tono base (`--color-gradient-1`) y texto/icono blancos, sin haber añadido un modificador de degradado.

### Scenario 4: La demo y el resto de la página no cambian

Given el `index.html` previo,
When se implementa el Enlace,
Then `[data-demo="link-button"]` sigue conteniendo sus cinco anclas de demostración, el Perfil, el avatar, el pie y los metadatos siguen intactos, y el único Enlace real dentro de `.links` es LinkedIn.

### Scenario 5: Foco, hover y movimiento reducido heredados

Given el Enlace en escritorio,
When se fuerza hover o se navega con `Tab`,
Then se aplican `translateY(-1.5px)`, la sombra de hover, `brightness(1.03)` y el outline de acento de 2px del componente; con `prefers-reduced-motion: reduce`, `transition-duration` es `0s` y `transform` es `none`.

### Scenario 6: Harness y navegador verificables

Given el estado actual del repositorio,
When se ejecuta `./init.sh` y se sirve en el puerto 3304,
Then el script sale `0` con los checks previos y los nuevos checks de LinkedIn, y la página se renderiza en 390×844 y 1280×800 sin errores de consola, sin peticiones fallidas y sin scroll horizontal.

## Repository Research

### Files Inspected

- `AGENTS.md` — una feature a la vez, alcance estricto, Definition of Done y validación móvil/escritorio.
- `PROGRESS.md` — `page-shell`, `link-button-component`, `profile-avatar`, `page-footer`, `profile-identity` y `open-graph-metadata` en `accepted`; siguiente estado y riesgos heredados.
- `feature_list.json` — metadata, dependencia aceptada y verificación de `link-linkedin`; las demás features de Enlaces siguen `not_started`.
- `CONTEXT.md` — "Enlace" como botón accionable que abre un canal externo; orden final del MVP.
- `docs/build-brief.md` — siete Enlaces, LinkedIn en cuarta posición, contenido en español.
- `docs/domain-model.md` — un Enlace tiene tipo, etiqueta, icono, URL y orden; la URL es parte de este feature, el orden no.
- `docs/technical-discovery.md` — HTML/CSS estático sin build, SVG inline y URL exacta de LinkedIn.
- `DESIGN.md` — `components.button-link`, paleta lavanda→violeta, accesibilidad y `prefers-reduced-motion`.
- `docs/risks-and-open-questions.md` — riesgo heredado de contraste 3.86–4.13:1; URLs externas pueden envejecer.
- `docs/specs/link-button-component.md` — contrato del componente, uso de `aria-label` solo si se necesita, demo temporal.
- `index.html` — `<main class="page"><article class="card">`, avatar, identidad, demo de cinco anclas y pie; no hay Enlaces reales.
- `styles.css` — tokens, `.link-button` y modificadores ya implementados; bloque temporal `[data-demo="link-button"]`.
- `init.sh` — checks de bootstrap, tokens, componente, page shell, avatar, pie, identidad y metadatos; no arranca servidor por defecto.
- `git log` / `git status` — worktree limpio sobre `feature/link-linkedin` en `96dd53b`; no existen `ARCHITECTURE.md` ni `CONSTRAINTS.md`.

### Existing Patterns To Follow

- Markup estático hardcodeado en `index.html`, contenido visible en español.
- Reutilizar `.link-button` + `.link-button__label` + `.link-button__icon`; no duplicar estilos del botón.
- SVG inline de 18×18 con `currentColor`, `aria-hidden="true"` y `focusable="false"`.
- CSS de componentes en el único `styles.css`; tokens existentes, sin valores nuevos en `:root`.
- Gates de `init.sh` con `grep`/`awk`, mensajes `[ok]`, errores a stderr y exit `1`; sin servidor por defecto.
- Evidencia durable en `feature_list.json` (`status` + `evidence`) y `PROGRESS.md`.

### Current Gaps

- No existe un contenedor de Enlaces reales ni ningún `<a>` de producto fuera de la demo y el pie.
- La demo usa el hook temporal `[data-demo="link-button"]`; no debe reutilizarse para el Enlace real.
- `init.sh` no valida ningún Enlace real todavía.
- No hay framework de tests ni comando E2E; la verificación es harness + navegador.
- El destino externo y el handoff a la app móvil de LinkedIn no son controlables desde la página.

## Technical Approach

### 1. Ubicación del markup

Insertar un contenedor de Enlaces reales dentro de `.card`, inmediatamente después del cierre de `<header class="profile-identity">` y antes del comentario/bloque de la demo:

```html
<section class="links" aria-label="Enlaces">
  <a class="link-button" href="https://www.linkedin.com/in/fahedhermoza/">
    <span class="link-button__label">LinkedIn</span>
    <svg class="link-button__icon" viewBox="0 0 24 24" width="18" height="18"
         fill="currentColor" aria-hidden="true" focusable="false">
      <path d="M4.98 3.5C4.98 4.88 3.87 6 2.5 6S0 4.88 0 3.5 1.12 1 2.5 1s2.48 1.12 2.48 2.5zM.5 8h4v15h-4V8zm7.5 0h3.8v2.05h.05c.53-1 1.83-2.05 3.77-2.05 4.03 0 4.78 2.65 4.78 6.09V23h-4v-6.41c0-1.53-.03-3.5-2.13-3.5-2.13 0-2.46 1.66-2.46 3.38V23H8V8z"/>
    </svg>
  </a>
</section>
```

- El contenedor se llama `.links` y no reutiliza `[data-demo="link-button"]`.
- El Enlace real va antes de la demo para que el contenido de producto quede por encima del material temporal; la demo se mantiene visible debajo.
- La URL debe ser exactamente `https://www.linkedin.com/in/fahedhermoza/` (con barra final), sin parámetros, UTM ni fragmentos.

### 2. Contenedor mínimo

Añadir en `styles.css`, junto a la sección del componente, solo la inserción horizontal del contenedor:

```css
/* Enlaces reales. La columna, el orden y la progresión de color se completan en links-order-gradient. */
.links {
  padding: 0 var(--space-gutter);
}
```

- No se añade `display: flex`, `gap`, orden ni tonos: pertenecen a `links-order-gradient`.
- `var(--space-gutter)` (16px) mantiene el Enlace alineado con el ancho de la demo existente mientras ambas conviven.
- Geometría esperada: 390×844 → tarjeta 358px, contenido 356px, Enlace 324×48 en `x=33`; 1280×800 → tarjeta 400px, contenido 398px, Enlace 366×48 en `x=457`.

### 3. Componente y tono

- No añadir `link-button--gradient-1`…`-5`. La regla base ya declara `--link-button-bg: var(--color-gradient-1)`, así que el Enlace único usa el tono base sin fijar una progresión.
- No modificar `.link-button`, `.link-button__label`, `.link-button__icon`, hover, focus, movimiento reducido ni la demo.
- El icono usa `fill="currentColor"`; el componente fija `color: var(--color-on-primary)` (blanco). No se fuerza `stroke`.

### 4. Nombre accesible y semántica

- El nombre accesible proviene del texto visible "LinkedIn"; no se añade `aria-label` redundante (coherente con `docs/specs/link-button-component.md`).
- El SVG es decorativo: `aria-hidden="true"` y `focusable="false"`; no lleva `<title>`.
- `target` y `rel` se omiten: la navegación ocurre en la misma pestaña y el sistema decide si abre la app.
- El foco de teclado y el área táctil los aporta `.link-button`; no se añaden estilos nuevos.

### 5. Gate de `init.sh`

Añadir una sección `LinkedIn link checks:` después de `Sharing metadata checks:` y antes del comando de servido, sin quitar ni debilitar checks existentes:

- `index.html` contiene `class="links"` → `[ok] links container markup`.
- Existe un `<a>` con `class="link-button"` y el `href` exacto → `[ok] LinkedIn link destination`.
- Extraer con `awk` el bloque del `<a>` cuyo `href` es el de LinkedIn (desde esa línea hasta `</a>`) para evitar falsos positivos de la demo; dentro de ese bloque exigir:
  - `>LinkedIn<` → `[ok] LinkedIn link label`.
  - `aria-hidden="true"` y `focusable="false"` → `[ok] LinkedIn icon is decorative`.
- La regla `.links` existe en `styles.css` y contiene `padding: 0 var(--space-gutter);` → `[ok] links container rule` (extraer la regla con `awk`, como los checks existentes).
- Cualquier fallo imprime el motivo en stderr y sale `1` con `Harness status: FAILED - ...`. No arranca servidor.
- No comprobar el orden, el degradado, las otras redes ni el contenido de la demo.

### 6. Verificación de navegación

- Comprobar `anchor.href` y `anchor.getAttribute("href")` exactos, `anchor.target === ""` y `anchor.rel === ""`.
- Pulsar el Enlace y confirmar que la navegación se inicia hacia el destino exacto; que LinkedIn responda o muestre el perfil es una dependencia externa, no un criterio bloqueante del harness. Volver a la página local después.
- La prueba física en iOS/Android del handoff a la app queda como verificación manual de producto; no se puede reproducir con el navegador de escritorio.

## Expected File Changes

- `index.html` — modify; añadir `section.links` con el Enlace real de LinkedIn antes de la demo.
- `styles.css` — modify; añadir solo la regla `.links` con padding de gutter.
- `init.sh` — modify; añadir `LinkedIn link checks:` sin alterar los checks existentes.
- `feature_list.json` — modify; `status: passing` + `evidence` (implementador) / `accepted` (validator).
- `PROGRESS.md` — modify; estado verificado y bitácora de sesión.
- `docs/specs/link-linkedin.md` — create; este spec.
- `docs/validations/link-linkedin.md` — create; lo genera el validator.
- No se crean assets, archivos JS, dependencias ni tokens.

## Visual Design Impact

- UI involved: yes.
- Design source: `DESIGN.md` > `components.button-link`, `colors.gradient-1`, `typography.button-label`, `rounded.md`, `spacing.gutter`, `Accessibility Baseline`.
- Screens or states affected: una sola vista; primer Enlace real en estado normal, hover, focus-visible y movimiento reducido; la demo de cinco botones permanece debajo.
- New design artifact required: no — se reutiliza el componente aceptado; el tono definitivo y la progresión se deciden en `links-order-gradient`.

## Durable Documentation Impact

- `ARCHITECTURE.md`: not needed — no hay capas, dominios ni boundaries nuevos; sigue siendo un sitio estático de una hoja CSS.
- `CONSTRAINTS.md`: not needed — no se introduce una regla MUST/MUST NOT nueva; se aplican las existentes de tokens y SVG inline.
- `AGENTS.md`: not needed — el camino de arranque y las reglas de trabajo no cambian.
- `DESIGN.md`: not needed — es fuente de verdad y el Enlace usa valores ya definidos.
- `docs/technical-discovery.md`: not needed — la URL de LinkedIn ya está documentada.
- `docs/risks-and-open-questions.md`: not needed — el envejecimiento de URLs externas y el contraste heredado ya están registrados; este feature no añade un riesgo durable nuevo.
- `CONTEXT.md`, `docs/domain-model.md`, `docs/build-brief.md`: not needed — el concepto y el orden de Enlaces no cambian.

## Implementation Plan

1. Insertar `section.links` con el `<a>` de LinkedIn y su SVG inline en `index.html`, antes de `[data-demo="link-button"]`.
2. Añadir la regla `.links` en `styles.css` sin tocar `.link-button`, la demo ni los tokens.
3. Extender `init.sh` con la sección `LinkedIn link checks:`.
4. Ejecutar `./init.sh`, probar el caso negativo en una copia temporal y verificar en navegador a 390×844 y 1280×800 sirviendo en el puerto 3304.
5. Registrar evidencia y actualizar `feature_list.json` y `PROGRESS.md`.

## Implementation Tasks

- [ ] Añadir `<section class="links" aria-label="Enlaces">` dentro de `.card`, después de `profile-identity` y antes de la demo.
- [ ] Añadir el `<a class="link-button" href="https://www.linkedin.com/in/fahedhermoza/">` con `span.link-button__label` "LinkedIn".
- [ ] Añadir el SVG LinkedIn inline de 18×18 con `fill="currentColor"`, `aria-hidden="true"` y `focusable="false"`; sin `<title>` ni `stroke`.
- [ ] No añadir modificador `link-button--gradient-*`, `target`, `rel`, `aria-label` ni JavaScript.
- [ ] Añadir la regla `.links { padding: 0 var(--space-gutter); }` en `styles.css` sin alterar la demo ni el componente.
- [ ] Verificar que la demo conserva sus cinco anclas y que el único `<a>` dentro de `.links` es LinkedIn.
- [ ] Extender `init.sh` con `LinkedIn link checks:` (contenedor, destino exacto, etiqueta, icono decorativo y regla `.links`).
- [ ] Ejecutar `bash -n init.sh` y `./init.sh` (exit `0`, checks nuevos `[ok]`, sin servidor).
- [ ] Probar el caso negativo en una copia temporal (URL incorrecta o etiqueta ausente → exit `1` con stderr) y eliminar la copia.
- [ ] Servir en 3304 y validar 390×844 y 1280×800: geometría, href, nombre accesible, click, foco, hover, reduced motion, consola, red y ausencia de scroll horizontal.
- [ ] Registrar evidencia en `feature_list.json` y `PROGRESS.md`.

## Verification Plan

- `bash -n init.sh` — sin errores de sintaxis.
- `./init.sh` — `Harness status: bootstrapped (static site detected)`, todos los checks previos `[ok]`, la nueva sección `LinkedIn link checks:` con sus `[ok]`, exit `0` y sin servidor.
- Caso negativo en una copia temporal fuera del repo: sustituir el `href` por `https://www.linkedin.com/` (o eliminar `>LinkedIn<`) y ejecutar `./init.sh`; debe salir `1` con el motivo en stderr. Restaurar/eliminar la copia; no dejar el repo roto.
- Servir con `python3 -m http.server 3304 --directory .` y abrir `http://localhost:3304/`; detener solo ese proceso al terminar. No usar `RUN_SERVE_COMMAND=1` (el mensaje de `init.sh` aún sugiere 3201).
- **390×844:** tarjeta 358px; Enlace 324×48 en `x=33`; sin scroll horizontal (`scrollWidth == clientWidth`); Perfil, demo (5 botones) y pie visibles; consola con 0 mensajes; sin peticiones 4xx/5xx ni `/favicon.ico`.
- **1280×800:** tarjeta 400px centrada; Enlace 366×48 en `x=457`; misma tipografía, radio y color; sin scroll horizontal; consola y red limpias; demo intacta.
- **Computed styles:** `.link-button` del Enlace → `display:flex`, `height:48px`, `padding:0px 20px`, `border-radius:6px`, `justify-content:space-between`, `font-size:11px`, `font-weight:800`, `line-height:16px`, `letter-spacing:1.98px`, `text-transform:uppercase`, `color:rgb(255,255,255)`, fondo `rgb(104,118,240)` (`gradient-1`); icono 18×18.
- **Semántica:** `a[href]` real, `getAttribute("href")` exacto, `target`/`rel` vacíos, nombre accesible coincide con "LinkedIn" sin distinguir mayúsculas, SVG `aria-hidden="true"` y `focusable="false"`, un solo `<a>` dentro de `.links`.
- **Click:** dispara navegación a `https://www.linkedin.com/in/fahedhermoza/`; volver a la página local. La disponibilidad del perfil externo no se califica.
- **Hover y foco:** hover de escritorio → `transform:matrix(1, 0, 0, 1, 0, -1.5)`, sombra hover y `filter:brightness(1.03)`; `Tab` → `:focus-visible=true` con outline `2px solid rgb(88,92,229)` y offset `2px`.
- **Movimiento reducido:** emular `prefers-reduced-motion: reduce`; `transition-duration:0s` y `transform:none` en hover/foco; outline visible.
- E2E: no aplica; el repositorio no tiene harness E2E ni framework de tests. La cobertura es `init.sh` + navegador, coherente con `docs/technical-discovery.md`.

## Evidence To Capture

- Salida de `./init.sh` con los checks previos y los nuevos `LinkedIn link checks:` (exit `0`, sin servidor).
- Salida del caso negativo (URL incorrecta o etiqueta ausente → exit `1`).
- Geometría y estilos computados del Enlace en 390×844 y 1280×800.
- Valores de `href`, `target`, `rel`, nombre accesible y atributos del SVG.
- Resultado del click/navegación y del retorno a la página local.
- Valores de hover, focus-visible y `prefers-reduced-motion`.
- Consola y red en ambos viewports (sin errores, sin 4xx/5xx, sin `/favicon.ico`).
- Confirmación de demo intacta (5 anclas) y de que no se añadieron otros Enlaces ni tonos.
- Screenshots opcionales de móvil y escritorio.
- `feature_list.json` (`status`, `evidence`) y `PROGRESS.md` actualizados.

## Validator Checklist

- [ ] Existe un único Enlace real, "LinkedIn", dentro de `section.links`.
- [ ] El `href` es exactamente `https://www.linkedin.com/in/fahedhermoza/`, sin `target`, `rel` ni parámetros.
- [ ] El Enlace usa `.link-button`, `.link-button__label` y `.link-button__icon`; no duplica estilos ni añade un modificador de degradado.
- [ ] El SVG es inline, 18×18, `fill="currentColor"`, `aria-hidden="true"` y `focusable="false"`.
- [ ] El nombre accesible se deriva de "LinkedIn"; no hay `aria-label` redundante.
- [ ] Solo se añadió la regla `.links` con padding de gutter; no se implementó orden, gap ni progresión de color.
- [ ] La demo `[data-demo="link-button"]` y su CSS siguen intactos; el resto de la página no cambió.
- [ ] No se añadieron JavaScript, frameworks, bundlers, dependencias, assets ni tokens.
- [ ] `./init.sh` sale `0` con los checks nuevos y falla si falta el destino, la etiqueta, el icono decorativo o la regla `.links`.
- [ ] Verificación en 390×844 y 1280×800 sin errores de consola, sin peticiones fallidas y sin scroll horizontal, en el puerto 3304.
- [ ] El click inicia la navegación al perfil correcto; hover, foco y movimiento reducido se comportan como el componente aceptado.
- [ ] `feature_list.json`, `PROGRESS.md` y el registro de validación están actualizados.
- [ ] No se implementó ninguna otra feature (otras redes, orden, degradado, vCard, page shell, metadatos).

## Assumptions And Open Questions

### Assumptions

- El Enlace real se coloca antes de la demo para que el contenido de producto preceda al material temporal; `links-order-gradient` moverá/ordenará los siete Enlaces y retirará la demo cuando corresponda.
- El contenedor usa `var(--space-gutter)` (16px) para coincidir con el ancho del botón de la demo mientras ambos coexisten; no es una decisión de orden ni de degradado.
- No se asigna tono explícito: el fallback `--color-gradient-1` del componente es suficiente para un único Enlace y evita fijar la progresión antes de `links-order-gradient`.
- La navegación en la misma pestaña es el comportamiento correcto; no se abre una pestaña nueva.
- El puerto 3304 es el único que usará esta sesión; el 3201 impreso por `init.sh` es una guía heredada.

### Open Questions

- **Handoff móvil:** ¿el sistema abre la app nativa de LinkedIn o el navegador? La página no puede forzarlo; se valida manualmente en iOS/Android en la fase de producto.
- **Alineación final:** si `links-order-gradient` decide otro padding/gap para la columna de Enlaces, podrá ajustar `.links` sin cambiar el destino ni la semántica de este Enlace.
- **Tono final:** la posición de LinkedIn (cuarta de siete) determinará su tono en `links-order-gradient`; este feature no lo anticipa.
- **Contraste:** el Enlace hereda la desviación AA 3.86–4.13:1 de las etiquetas blancas sobre los tonos, ya registrada para `accessibility-baseline`; no se corrige aquí.
