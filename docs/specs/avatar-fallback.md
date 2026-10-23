# Feature Implementation Spec: Fallback de avatar con iniciales FH

## Source Feature

- `id`: `avatar-fallback`
- `area`: `profile`
- `depends_on`: `["profile-avatar"]` (satisfied: `accepted`)
- `status`: `not_started` (at planning time; this spec does not change it)
- `source`: `feature_list.json`
- `verification`: renombrar temporalmente `assets/avatar.jpg`, recargar y confirmar `FH`; restaurar y confirmar que vuelve la foto.
- `notes`: `DESIGN.md` > Core Screens (estado 2), `docs/domain-model.md` (Edge Cases) y `docs/risks-and-open-questions.md` (Avatar no disponible). `docs/technical-discovery.md` admite explícitamente "JavaScript mínimo: solo si hace falta para el fallback del avatar o la descarga de la vCard".

## Goal

Añadir el estado de respaldo del avatar ya aceptado: si `assets/avatar.jpg` falla al cargar, el mismo círculo de 88×88 muestra las iniciales **FH** en `#484dc4` (`--color-primary`) sobre `#f1f4fa` (`--color-surface-container-low`), conservando el anillo blanco de 3px, el centrado y la altura del Perfil, sin saltos de layout ni scroll horizontal.

La solución debe ser la mínima posible dentro de un sitio estático sin build: un `<span>` decorativo oculto por defecto y un `onerror` inline en el `<img>` que active el fallback. El nombre accesible del Perfil sigue siendo `Retrato de Fahed Hermoza`, tomado del `alt` del `<img>`, que permanece en el árbol de accesibilidad.

## Non-Goals

- No cambiar la URL, el contenido ni el formato de `assets/avatar.jpg`; no se generan, recortan ni reemplazan imágenes.
- No implementar detección proactiva (HEAD/fetch), reintentos automáticos, service worker ni fallback sin JavaScript.
- No añadir `alt` alternativo, `aria-label` nuevo, roles nuevos ni texto visible adicional (las iniciales son decorativas para AT).
- No modificar Nombre, Handle, Tagline, Enlaces, pie, metadatos, vCard, `:root`, `body`, `.page`, `.card`, `.profile`, `.profile-identity`, `.link-button` ni la demo temporal.
- No añadir frameworks, bundlers, preprocesadores, npm, dependencias ni archivos JS externos; el único JavaScript es el atributo `onerror` inline.
- No cambiar el comando de servido, el puerto ni las pistas manuales de `init.sh` (siguen en 3301). La validación de navegador de esta sesión usa solo el puerto 3411 indicado por el orquestador.
- No implementar `accessibility-baseline` ni corregir contrastes heredados.

## Job Story

When abro la Tarjeta digital y la foto de perfil no está disponible (red, archivo movido o despliegue incompleto),
I want a ver un círculo con las iniciales de Fahed en lugar de una imagen rota,
so I can seguir reconociendo de quién es la Tarjeta y usar los Enlaces sin que el layout se rompa.

## Users And Permissions

- Visitante anónimo: ve la foto o el fallback; no interactúa con el avatar. Sitio público, sin sesión ni permisos.
- Implementador: añade markup, CSS, checks y evidencia; manipula temporalmente el asset solo durante la prueba y lo restaura.
- Validador: reproduce el fallback de forma independiente (renombrado/restauración) y comprueba gate, accesibilidad y layout.

## Acceptance Scenarios

### Scenario 1: Imagen disponible (sin fallback visible)

Given la página servida en `http://localhost:3411/` con `assets/avatar.jpg` presente,
When se carga en 390×844 o 1280×800,
Then el `<img class="profile-avatar">` mide 88×88, está centrado, conserva `object-fit: cover`, radio completo y halo blanco de 3px, y el fallback calcula `display: none`; no se muestra "FH", no hay scroll horizontal, la consola no tiene mensajes y todas las peticiones responden 2xx/304.

### Scenario 2: Imagen fallida (fallback visible)

Given la página servida con `assets/avatar.jpg` renombrado temporalmente,
When se recarga ignorando caché,
Then se ve un círculo de 88×88 con el texto exacto `FH`, `background-color: rgb(241, 244, 250)`, `color: rgb(72, 77, 196)`, `border-radius: 9999px`, texto centrado y `box-shadow: rgb(255, 255, 255) 0px 0px 0px 3px`; el fallback sustituye visualmente a la imagen en la misma posición, el Perfil conserva su altura y la tarjeta su ancho, sin scroll horizontal.

### Scenario 3: Sin saltos de layout

Given las mediciones del estado con imagen y del estado con fallback en el mismo viewport,
When se comparan la altura de `.profile`, la posición superior de `.profile-identity` y el ancho de `.card`,
Then las tres coinciden (diferencia 0px; el halo de 3px es exterior y no altera la caja), y `scrollWidth == clientWidth` en documento y `body`.

### Scenario 4: Recuperación tras restaurar el asset

Given `assets/avatar.jpg` restaurado en su ruta original con el mismo contenido,
When se recarga ignorando caché,
Then la foto vuelve a mostrarse, el fallback calcula `display: none`, el `<img>` tiene `complete = true` y `naturalWidth = 460`, y la consola/red vuelven a estar limpias.

### Scenario 5: Accesibilidad en ambos estados

Given el estado con imagen y el estado con fallback,
When se inspecciona el árbol de accesibilidad,
Then el nodo de imagen conserva el nombre `Retrato de Fahed Hermoza` en ambos casos; el `<span>` de iniciales tiene `aria-hidden="true"` y no añade un segundo nombre ni texto leído; no hay controles nuevos ni cambios de foco.

### Scenario 6: Verificación en móvil y escritorio

Given el estado con imagen y el estado con fallback,
When se valida en 390×844 (móvil) y 1280×800 (escritorio),
Then en ambos el círculo está centrado respecto a la tarjeta y al viewport, mide 88×88, muestra "FH" en el estado fallido y no genera scroll horizontal, solapamientos ni recortes.

### Scenario 7: Red y consola durante la simulación de fallo

Given la simulación de renombrado,
When se revisan red y consola,
Then el único fallo esperado es una petición `404` (o bloqueo equivalente) de `/assets/avatar.jpg`, sin otras peticiones fallidas ni `/favicon.ico`; el navegador puede registrar el error de recurso asociado a ese 404, y no debe haber errores JavaScript. Tras restaurar, la red queda sin fallos y la consola sin mensajes.

### Scenario 8: El harness detecta la pérdida del fallback

Given copias temporales fuera del repo sin el handler `onerror`, sin el `<span>` de iniciales, sin `aria-hidden`, sin las reglas de activación o con colores/tamaño alterados,
When se ejecuta `./init.sh`,
Then cada copia sale con código distinto de `0`, imprime el check/declaración concreta en stderr y no arranca servidor; la copia limpia y el worktree real siguen saliendo `0`.

## Repository Research

### Files Inspected

- `AGENTS.md` — una feature a la vez, DoD, validación 390×844 y 1280×800, sin dependencias, `init.sh` reiniciable.
- `feature_list.json` — `avatar-fallback` es la única feature seleccionada; `profile-avatar` está `accepted`; el resto de Enlaces ya está `accepted`.
- `PROGRESS.md` — estado verificado de la Tarjeta y bitácora; no se modificó en planificación.
- `index.html` — `.card` con `<header class="profile">` (avatar directo), `.profile-identity`, `nav.links` de siete Enlaces, demo temporal y pie; sin `<script>` ni handlers.
- `styles.css` — 51 tokens; `.profile` flex column centrado con `padding-block: var(--space-xl)`; `.profile-avatar` con contrato 88×88, radio completo, `object-fit: cover` y halo blanco de 3px; demo al final.
- `init.sh` — gate no bloqueante, `fail()` a stderr + exit `1`, checks por subcadena/`awk`; `Profile checks:` ya valida markup, asset y contrato de 5 declaraciones; comando y `RUN_SERVE_COMMAND` en 3301; ejecutado en planificación → exit `0`, sin servidor.
- `assets/avatar.jpg` — JPEG baseline 460×460, 45029 bytes, SHA-256 `b73575ae31cee7ead9de09377d90b60d3cbf2079402602c217a47f02afe4aa7c`.
- `DESIGN.md` — `components.avatar` (88px, `rounded.full`), Shapes (anillo blanco 3px), Core Screens estado 2: círculo con "FH" en `#484dc4` sobre `#f1f4fa`, baseline de accesibilidad.
- `docs/technical-discovery.md` — sin framework/build; JavaScript mínimo permitido para el fallback del avatar.
- `docs/domain-model.md`, `docs/risks-and-open-questions.md` — edge case "Avatar ausente" y riesgo "Avatar no disponible" mitigado con iniciales.
- `docs/specs/profile-avatar.md`, `docs/validations/profile-avatar.md` — contrato aceptado del avatar y evidencia de gate/navegador que no debe debilitarse.
- `.github-flow/avatar-fallback.md`, `.github-flow/prompt.md` — alcance de la rama y regla de usar solo el puerto 3411 para validación de navegador.

### Existing Patterns To Follow

- Un único `styles.css` raíz y un único `index.html`; sin imports, build ni archivos JS.
- CSS con tokens `var(--…)`; valores de componente en px dentro de su regla; no se añaden tokens.
- Gate de `init.sh` con `grep -qF`, extracción de bloques con `awk`, contadores `present/total`, fallo acumulado a stderr y ningún listener en los caminos de error.
- Evidencia durable en `feature_list.json` (`status` + `evidence`), `PROGRESS.md` y `docs/validations/avatar-fallback.md` (validator).
- Una única instancia de servidor por sesión, detenida al terminar; el asset se restaura siempre.

### Current Gaps

- No existe ningún fallback: si la imagen falla, el navegador muestra una imagen rota con el `alt`.
- `init.sh` no verifica el estado de respaldo ni el handler de error.
- No hay harness E2E ni framework de tests; añadirlos introduciría dependencias prohibidas.
- `DESIGN.md` no define la escala tipográfica de las iniciales; se elige `headline-lg` (26px/600) por ser la escala del Nombre y caber en 88px sin inventar tokens.

## Technical Approach

### 1. Markup: frame superpuesto y fallback decorativo

Sustituir el contenido directo de `<header class="profile">` por un frame de 88×88 que contiene la imagen y el fallback en la misma celda. La demo, la identidad y el resto de la tarjeta no se tocan.

```html
<header class="profile">
  <span class="profile-avatar-frame">
    <img
      class="profile-avatar"
      src="assets/avatar.jpg"
      alt="Retrato de Fahed Hermoza"
      width="88"
      height="88"
      onerror="this.parentElement.classList.add('profile-avatar-frame--fallback')"
    >
    <span class="profile-avatar-fallback" aria-hidden="true">FH</span>
  </span>
</header>
```

- **Por qué JavaScript mínimo:** no existe forma CSS fiable de detectar el fallo de una `<img>` manteniendo el elemento y su `alt`; `docs/technical-discovery.md` autoriza este caso. El handler es un único atributo, idempotente (`classList.add`), sin `eval` ni estado global.
- **Handler exacto:** `onerror="this.parentElement.classList.add('profile-avatar-frame--fallback')"`. El padre directo es siempre `.profile-avatar-frame`; no depende de `closest` ni de ids.
- **`aria-hidden="true"` en el fallback:** "FH" es decorativo para AT; el nombre accesible sigue viniendo del `alt` del `<img>`, que permanece en el DOM y solo se hace transparente visualmente.
- **Sin `hidden`, `display:none` ni `aria-hidden` en la imagen:** ocultar la imagen del árbol de accesibilidad perdería el nombre accesible. El estado fallido usa `opacity: 0` sobre la imagen.
- El texto del fallback debe quedar en una sola línea con `<span class="profile-avatar-fallback" aria-hidden="true">FH</span>` para que el gate pueda extraerlo del bloque `.profile`.
- Sin `<script>`, sin archivos JS, sin `data-*`, sin roles nuevos y sin tocar el asset.

### 2. CSS: frame, fallback y activación

Añadir un bloque después de `.profile-avatar` y antes de `.profile-identity`, sin modificar reglas aceptadas:

```css
/* Components — Profile avatar fallback (DESIGN.md > Core Screens, estado Avatar ausente) */
.profile-avatar-frame {
  display: grid;
  width: 88px;
  height: 88px;
  place-items: center;
}

.profile-avatar-frame > * {
  grid-area: 1 / 1;
}

.profile-avatar-fallback {
  display: none;
  align-items: center;
  justify-content: center;
  width: 88px;
  height: 88px;
  border-radius: var(--radius-full);
  background-color: var(--color-surface-container-low);
  color: var(--color-primary);
  font-family: var(--font-family-base);
  font-size: var(--text-headline-lg-font-size);
  font-weight: var(--text-headline-lg-font-weight);
  line-height: var(--text-headline-lg-line-height);
  letter-spacing: var(--text-headline-lg-letter-spacing);
  box-shadow: 0 0 0 3px var(--color-surface);
}

.profile-avatar-frame--fallback .profile-avatar {
  opacity: 0;
}

.profile-avatar-frame--fallback .profile-avatar-fallback {
  display: flex;
}
```

- **Frame 88×88:** misma caja que la imagen; `.profile` sigue centrando el frame. La imagen conserva su rect de 88×88 y el halo exterior de 3px, por lo que el footprint visual (94×94) no altera el layout.
- **Superposición sin layout shift:** ambos hijos comparten `grid-area: 1 / 1`; solo uno es visible a la vez. La altura del Perfil no cambia entre estados.
- **Colores exactos:** `--color-surface-container-low` = `#f1f4fa` → `rgb(241, 244, 250)`; `--color-primary` = `#484dc4` → `rgb(72, 77, 196)`. No se usan valores hex literales en CSS.
- **Anillo:** el fallback repite `box-shadow: 0 0 0 3px var(--color-surface)`, el mismo halo blanco del avatar aceptado; el borde exterior queda a 94×94 sin afectar a la caja.
- **Tipografía:** tokens `headline-lg` (26px/600/34px/`-0.02em`). El texto "FH" va en mayúsculas por contenido, no por `text-transform`.
- **Modificador único:** `.profile-avatar-frame--fallback` se añade solo por el handler; no se usa `:has`, `:invalid` ni selectores dependientes del estado de carga.
- No se modifican `.profile`, `.profile-avatar`, `.page`, `.card`, `:root`, `body`, `.profile-identity`, `.link-button` ni `[data-demo]`.

### 3. Accesibilidad

- Con imagen: nombre accesible `Retrato de Fahed Hermoza`, sin cambios.
- Con fallback: la `<img>` fallida sigue en el árbol con `alt="Retrato de Fahed Hermoza"` y `opacity: 0` (no `display/visibility`), por lo que el nombre se conserva; "FH" tiene `aria-hidden="true"` y no se anuncia.
- El fallback es puramente visual: sin foco, sin interacción, sin `role="img"` ni `aria-label` adicional.
- Si el navegador eliminara la imagen fallida del árbol de accesibilidad, es una desviación que el validador debe registrar; no se acepta silenciosamente.

### 4. Harness (`init.sh`)

Añadir una sección `Avatar fallback checks:` inmediatamente después de `Profile checks:` y antes de `Page footer checks:`, **sin quitar, reordenar ni debilitar ningún check previo**:

1. Extraer el bloque `<header class="profile">…</header>` con `awk` y verificar dentro:
   `class="profile-avatar-frame"`, `class="profile-avatar-fallback"`, `>FH</span>`, `aria-hidden="true"` y el atributo `onerror="this.parentElement.classList.add('profile-avatar-frame--fallback')"`. Salida: `[ok] avatar fallback markup`.
2. Extraer con `awk` la regla `.profile-avatar-frame`; si falta → fallo `styles.css is missing the .profile-avatar-frame base rule`. Salida: `[ok] .profile-avatar-frame rule exists`.
3. Contrato del frame (3/3): `display: grid;`, `width: 88px;`, `height: 88px;` → `[ok] profile avatar frame contract (3/3)`.
4. Verificar la regla `.profile-avatar-frame > *` con `grid-area: 1 / 1;` → `[ok] avatar fallback stacking`. Sin ella, la imagen y el fallback se apilan en filas distintas.
5. Extraer la regla `.profile-avatar-fallback`; si falta → fallo. Salida: `[ok] .profile-avatar-fallback rule exists`.
6. Contrato del fallback (10/10): `display: none;`, `width: 88px;`, `height: 88px;`, `border-radius: var(--radius-full);`, `background-color: var(--color-surface-container-low);`, `color: var(--color-primary);`, `box-shadow: 0 0 0 3px var(--color-surface);`, `font-size: var(--text-headline-lg-font-size);`, `font-weight: var(--text-headline-lg-font-weight);`, `line-height: var(--text-headline-lg-line-height);` → `[ok] avatar fallback contract (10/10)`.
7. Activación: extraer las reglas `.profile-avatar-frame--fallback .profile-avatar` (debe contener `opacity: 0;`) y `.profile-avatar-frame--fallback .profile-avatar-fallback` (debe contener `display: flex;`) → `[ok] avatar fallback activation`.

Reglas del gate:

- Cada fallo imprime la declaración/elemento concreto en stderr y termina con `Harness status: FAILED - …`, exit `1`, sin listener.
- Mantener intactos los checks previos, incluido `[ok] profile avatar markup`, `[ok] avatar asset exists`, `[ok] .profile-avatar base rule exists` y `[ok] profile avatar contract (5/5)`.
- **No cambiar** las líneas `Serving command: python3 -m http.server 3301 --directory .`, la pista manual ni `RUN_SERVE_COMMAND` (3301). La validación de navegador de esta feature se hace con un servidor aparte en 3411, sin editar `init.sh` para ello.

### 5. Prueba de fallo y restauración

- Registrar `shasum -a 256 assets/avatar.jpg` (esperado `b73575ae31cee7ead9de09377d90b60d3cbf2079402602c217a47f02afe4aa7c`).
- Renombrar temporalmente el asset fuera de `assets/` (p. ej. `mv assets/avatar.jpg assets/avatar.jpg.bak`), nunca borrarlo.
- Recargar 3411 con caché ignorada y verificar el fallback; después `mv` de vuelta, comprobar el SHA-256 y recargar para verificar la restauración.
- Al terminar, `./init.sh` debe salir `0` (el asset existe) y `git status` no debe mostrar el asset modificado ni el `.bak`.
- Si la sesión se interrumpe, restaurar el asset antes de cualquier otra acción.

## Expected File Changes

- `index.html` — modificar; envolver el avatar en `.profile-avatar-frame`, añadir el `<span class="profile-avatar-fallback" aria-hidden="true">FH</span>` y el `onerror` inline.
- `styles.css` — modificar; añadir frame, apilado, fallback y reglas de activación entre `.profile-avatar` y `.profile-identity`.
- `init.sh` — modificar; añadir `Avatar fallback checks:` (7 checks) sin tocar checks, puerto ni servido.
- `feature_list.json` — modificar por el implementador/validador; `passing` y luego `accepted` con evidencia. El planner no cambia el estado.
- `PROGRESS.md` — modificar; estado verificado y bitácora.
- `docs/specs/avatar-fallback.md` — crear; este spec (planner).
- `docs/validations/avatar-fallback.md` — crear; lo genera el validator.
- `assets/avatar.jpg` — no modificar; se renombra temporalmente durante la prueba y se restaura con hash idéntico.

## Visual Design Impact

- UI involved: yes.
- Design source: `DESIGN.md` > Core Screens (estado 2: "Avatar ausente: círculo con iniciales 'FH' en `#484dc4` sobre `#f1f4fa`"), `colors.primary`, `colors.surface-container-low`, `colors.surface`, `components.avatar`, `rounded.full`, `typography.headline-lg`, Accessibility Baseline.
- Screens or states affected: única vista; nuevo estado "avatar fallido" dentro del Perfil.
- New design artifact required: no — colores, forma, halo y tamaño salen de `DESIGN.md`; solo la escala tipográfica de "FH" es una decisión derivada (`headline-lg`, 26px/600) sin tokens nuevos.
- El círculo mantiene 88×88 con halo exterior de 3px; no se añaden sombras, bordes ni colores fuera de la paleta.

## Durable Documentation Impact

- `ARCHITECTURE.md`: not needed — no existen capas ni boundaries nuevos; sigue siendo HTML/CSS estático con un handler inline.
- `CONSTRAINTS.md`: not needed — no se introduce una regla MUST/MUST NOT nueva; "sin dependencias, tokens de `DESIGN.md`, JS mínimo justificado" ya está en `docs/technical-discovery.md` y `AGENTS.md`.
- `AGENTS.md`: not needed — el camino de arranque y las reglas operativas no cambian; `./init.sh` sigue siendo el gate no bloqueante.
- `docs/technical-discovery.md`: not needed — ya autoriza JavaScript mínimo para el fallback del avatar.
- `docs/risks-and-open-questions.md`: not needed — el riesgo "Avatar no disponible" ya está registrado; la mitigación se implementa aquí.
- `DESIGN.md`: not needed — es fuente de verdad y no cambia.
- `PROGRESS.md` y `feature_list.json`: update — estado y evidencia de la feature.

## Implementation Plan

1. Envolver el avatar existente en `.profile-avatar-frame` y añadir el fallback `FH` con `aria-hidden` y el `onerror` inline en `index.html`.
2. Añadir en `styles.css` el frame grid, el apilado `grid-area: 1 / 1`, el contrato visual de `.profile-avatar-fallback` y las dos reglas de activación.
3. Extender `init.sh` con `Avatar fallback checks:` (markup, frame, stacking, fallback, activación), preservando todos los checks previos y el puerto 3301.
4. Ejecutar `bash -n init.sh` y `./init.sh`; probar los casos negativos en copias temporales fuera del repo.
5. Servir en 3411, medir el estado normal, renombrar el asset, medir el fallback, restaurar y verificar recuperación en 390×844 y 1280×800.
6. Registrar evidencia en `feature_list.json` y `PROGRESS.md`; el validator crea `docs/validations/avatar-fallback.md`.

## Implementation Tasks

- [ ] Añadir `<span class="profile-avatar-frame">` alrededor del `<img class="profile-avatar">` dentro de `<header class="profile">`.
- [ ] Añadir `<span class="profile-avatar-fallback" aria-hidden="true">FH</span>` como hijo del frame, después de la imagen.
- [ ] Añadir `onerror="this.parentElement.classList.add('profile-avatar-frame--fallback')"` al `<img>` sin cambiar `src`, `alt`, `width` ni `height`.
- [ ] Añadir `.profile-avatar-frame` (grid 88×88) y `.profile-avatar-frame > *` (`grid-area: 1 / 1;`).
- [ ] Añadir `.profile-avatar-fallback` con `display:none`, 88×88, radio completo, fondo `surface-container-low`, color `primary`, halo blanco 3px y escala `headline-lg`.
- [ ] Añadir las reglas de activación: imagen con `opacity: 0` y fallback con `display: flex`.
- [ ] Extender `init.sh` con los 7 checks nuevos sin alterar los previos ni el puerto.
- [ ] Ejecutar `bash -n init.sh`, `./init.sh` (exit `0`) y 8+ casos negativos en copias temporales.
- [ ] Validar en 3411 los estados normal/fallido/restaurado en 390×844 y 1280×800; medir layout, consola, red y accesibilidad.
- [ ] Verificar `git diff` acotado, SHA-256 del asset restaurado y ausencia de `.bak`; registrar evidencia.

## Verification Plan

### Gate

- `bash -n init.sh` → sin errores de sintaxis.
- `./init.sh` → exit `0`, sin servidor, con todos los checks previos `[ok]` y los nuevos:
  `[ok] avatar fallback markup`, `[ok] .profile-avatar-frame rule exists`, `[ok] profile avatar frame contract (3/3)`, `[ok] avatar fallback stacking`, `[ok] .profile-avatar-fallback rule exists`, `[ok] avatar fallback contract (10/10)`, `[ok] avatar fallback activation`.
- Casos negativos en copias temporales fuera del repo (nunca en el worktree real), todos exit `1`, stderr concreto, sin listener:
  - quitar el `onerror` → fallo de markup;
  - quitar el `<span>` del fallback o cambiar `FH` por `FE` → fallo de markup;
  - quitar `aria-hidden="true"` del fallback → fallo de markup;
  - renombrar `.profile-avatar-frame` o cambiar 88px por 87px → fallo de frame/contrato;
  - quitar `.profile-avatar-frame > * { grid-area: 1 / 1; }` → fallo de stacking;
  - cambiar el fondo a `var(--color-surface)` o el color a `var(--color-on-surface)` → fallo de contrato;
  - quitar `opacity: 0;` o el `display: flex;` de activación → fallo de activación;
  - copia limpia de control → exit `0`.
- Confirmar que los checks previos siguen fallando con sus mutaciones conocidas (p. ej. quitar `object-fit: cover;` o vaciar el asset) y que no se relajó ninguno.

### Navegador y servidor

- Servir **solo** con `python3 -m http.server 3411 --directory .` (comprobar el puerto antes; no usar 3101, 3201, 3301 ni 3302; detener el proceso al terminar y confirmar que el puerto queda libre).
- `curl -sI` → `/` `200 text/html`, `/styles.css` `200 text/css`, `/assets/avatar.jpg` `200 image/jpeg`; Google Fonts `200`/`304`.
- **Estado normal (390×844 y 1280×800):** `.profile-avatar` 88×88, `complete=true`, `naturalWidth=460`, `object-fit: cover`, radio `9999px`, halo `rgb(255, 255, 255) 0px 0px 0px 3px`, centrado respecto a `.card`; `.profile-avatar-fallback` con `display: none`; sin scroll horizontal; consola 0 mensajes; red sin 4xx/5xx ni `/favicon.ico`; árbol de accesibilidad con `Retrato de Fahed Hermoza`.
- **Estado fallido (renombrar el asset):** el `<img>` sigue en el DOM; frame 88×88; fallback visible 88×88, `display: flex`, `align-items/justify-content: center`, color/fondo/radio/halo exactos, texto `FH`; la imagen calcula `opacity: 0`; `.profile` y `.profile-identity.top` miden lo mismo que en el estado normal; `.card` conserva 358px (móvil) / 400px (escritorio); sin scroll horizontal; exactamente una petición fallida esperada de `/assets/avatar.jpg` y ningún otro fallo; sin errores JavaScript.
- **Estado restaurado:** repetir el estado normal tras `mv` de vuelta y recarga con caché ignorada; comparar SHA-256 con el valor inicial.
- Capturar screenshots si la herramienta puede interpretarlos; si no, usar `getBoundingClientRect()`/`getComputedStyle()` y el árbol de accesibilidad como evidencia principal.

### Accesibilidad y E2E

- Nombre accesible `Retrato de Fahed Hermoza` en ambos estados; fallback con `aria-hidden="true"`; sin controles ni foco nuevos; sin cambios de `lang="es"`.
- E2E: no aplica — no existe harness E2E ni framework de tests, y añadirlo exigiría dependencias/build prohibidos. La cobertura es gate no bloqueante + validación reproducible en navegador.

## Evidence To Capture

- Salida de `./init.sh` (exit `0`, 7 checks nuevos) y de cada caso negativo.
- SHA-256 del asset antes y después (`b73575ae…`), `git status` sin `.bak` y `git diff` acotado a `index.html`, `styles.css`, `init.sh`, `feature_list.json`, `PROGRESS.md` y este spec.
- `curl -sI` de `/`, `/styles.css` y `/assets/avatar.jpg`.
- Mediciones de ambos estados en 390×844 y 1280×800: rect del frame/fallback/imagen, colores computados, halo, altura de `.profile`, top de `.profile-identity`, ancho de `.card`, `scrollWidth`/`clientWidth`.
- Consola y red en estado normal, fallido (único 404 esperado de avatar) y restaurado; nombre accesible en ambos estados.
- `feature_list.json` (`passing` + evidencia) y `PROGRESS.md` actualizados; `docs/validations/avatar-fallback.md` por el validator.

## Risks And Mitigations

- **404 esperado en la simulación:** el navegador puede registrar un error de consola por el recurso ausente. Mitigación: se documenta como condición de la prueba; se exige que sea el único fallo y que no haya errores JS ni otras peticiones fallidas.
- **Accesibilidad del `<img>` fallido:** si un navegador retirara la imagen rota del árbol de accesibilidad, se perdería el nombre. Mitigación: se comprobó en planificación con Chrome y una página temporal (`opacity: 0` + `404`): el snapshot expone `image "Retrato de Fahed Hermoza"`; el validador debe repetirlo en el estado fallido real.
- **JS deshabilitado:** sin `onerror` se vería la imagen rota con el `alt`, no el círculo. Es una degradación aceptada; el sitio no declara soporte sin JS y el fallback justifica el JS mínimo.
- **Wrapper nuevo en `.profile`:** el `<img>` deja de ser hijo directo del header. Mitigación: el rect del `<img>`, su contrato CSS y `.profile` no cambian; el gate previo sigue pasando y se verifica la geometría.
- **Pérdida del asset durante la prueba:** mitigación con `mv` (nunca borrado), restauración inmediata y SHA-256; `./init.sh` final debe pasar.
- **Puerto 3411 ocupado:** comprobar `lsof -nP -iTCP:3411 -sTCP:LISTEN` y reportar el bloqueo; no cambiar de puerto en silencio.

## Acceptance Criteria

- [ ] Con la imagen disponible no se ve "FH" y el avatar conserva su contrato aceptado.
- [ ] Con `assets/avatar.jpg` renombrado se ve `FH` en un círculo 88×88, `rgb(72, 77, 196)` sobre `rgb(241, 244, 250)`, con halo blanco de 3px y centrado.
- [ ] El fallback no produce layout shift ni scroll horizontal en 390×844 y 1280×800.
- [ ] El nombre accesible sigue siendo `Retrato de Fahed Hermoza`; "FH" es decorativo (`aria-hidden`).
- [ ] Restaurar el asset devuelve la foto tras recargar; SHA-256 intacto.
- [ ] `./init.sh` sigue no bloqueante, pasa, añade 7 checks y no cambia el puerto 3301; los checks previos no se debilitan.
- [ ] Sin dependencias, frameworks, bundlers, archivos JS ni cambios en `:root`, `DESIGN.md` o el asset.
- [ ] `feature_list.json` y `PROGRESS.md` actualizados; el planner no cambia el estado.

## Validator Checklist

- [ ] Implementation stays within this feature's scope (fallback de avatar; sin Enlaces, identidad, vCard, pie ni accesibilidad global).
- [ ] Acceptance scenarios pass.
- [ ] Verification evidence is present.
- [ ] Persistent E2E coverage was added/updated when an E2E harness exists, or the spec explains why it is not needed (no harness exists).
- [ ] `feature_list.json` and `PROGRESS.md` were updated correctly.
- [ ] No unrelated product behavior or extra feature work was added.
- [ ] `assets/avatar.jpg` is byte-identical to `HEAD` and no `.bak` remains.
- [ ] Fallback visible only on error; colors, 88×88, 3px halo and centering measured exactly.
- [ ] No layout shift between states; no horizontal scroll at 390×844 and 1280×800.
- [ ] Accessible name preserved in both states; fallback `aria-hidden="true"`; no JS errors.
- [ ] `init.sh` old checks unchanged; 7 new checks detect each required mutation; port 3301 guidance untouched.
- [ ] Browser validation used port 3411 only and the server was stopped.

## Assumptions And Open Questions

### Assumptions

- `assets/avatar.jpg` es la fuente de verdad, mide 460×460 y se restaura byte-idéntico tras la prueba.
- Un `onerror` inline es aceptable porque `docs/technical-discovery.md` permite JavaScript mínimo para el fallback del avatar; no hay CSP en el sitio.
- `opacity: 0` mantiene la imagen fallida en el árbol de accesibilidad (comprobado en planificación con Chrome: nodo `image "Retrato de Fahed Hermoza"` tras un `404`), preservando el nombre accesible; se repite en la validación.
- La escala `headline-lg` (26px/600) es adecuada para "FH" dentro de 88px y no requiere tokens nuevos.
- El puerto 3411 está libre y es el único autorizado para la validación de navegador de esta sesión.

### Open Questions

- Ninguna bloqueante. La tipografía exacta de las iniciales no está definida en `DESIGN.md`; si el propietario del diseño prefiere otra escala (p. ej. `headline-md`), se ajustaría solo el `font-size`/`line-height` del fallback y su contrato de gate, sin cambiar colores ni geometría.
- Si en el futuro se añade una CSP que prohíba handlers inline, el mismo contrato se migraría a un `<script>` mínimo con `addEventListener`; no forma parte de esta feature.
