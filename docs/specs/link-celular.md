# Feature Implementation Spec: Enlace de Celular

## Source Feature

- `id`: `link-celular`
- `area`: `links`
- `depends_on`: `["link-button-component"]` (satisfied: `accepted`)
- `status`: `not_started` (at planning time; this spec does not change it)
- `source`: `feature_list.json`
- `notes`: URL de `docs/technical-discovery.md` (integrations); comportamiento de `tel:` en `docs/domain-model.md`; diseño en `DESIGN.md` > `components/button-link`, `Colors`, `Layout`.

## Goal

Añadir el primer Enlace real de producto: un botón **Celular** que use el componente existente `.link-button` con un icono SVG inline de teléfono, `href="tel:+51955116562"` y un nombre accesible que incluya la etiqueta visible. El Enlace se integra dentro de la Tarjeta digital sin retirar ni modificar la demo temporal `[data-demo="link-button"]`, el pie, la identidad ni el page shell.

El alcance termina cuando el Enlace es visible y accionable en móvil (390×844) y escritorio (1280×800), el `href` es exacto, el gate de `init.sh` detecta su contrato, y la evidencia queda registrada. La asignación de tono/orden entre Enlaces y la retirada de la demo pertenecen a `links-order-gradient`.

## Non-Goals

- No implementar ningún otro Enlace (`link-instagram`…`link-correo`).
- No implementar el orden final de los siete Enlaces, la separación vertical entre botones, la progresión del degradado ni la retirada de la demo (`links-order-gradient`).
- No añadir modificadores `link-button--gradient-*` a este Enlace: la asignación de tono por posición es de `links-order-gradient`. Se usa el componente base sin modificador de tono.
- No modificar la demo temporal `section#link-button-demo[data-demo="link-button"]`, su CSS `[data-demo="link-button"]` ni sus cinco anclas.
- No tocar `:root` (51 tokens), `body`, `.page`, `.card`, `.profile`, `.profile-avatar`, `.profile-identity`, `.link-button` ni `.page-footer`.
- No añadir JavaScript, frameworks, bundlers, preprocesadores, npm, dependencias, assets ni fuentes nuevas.
- No añadir vCard, `Guardar contacto`, Open Graph, analítica, modo oscuro, i18n ni favicon.
- No activar `tel:` durante la verificación automatizada: abriría el manejador del sistema. Se valida el `href` y el nombre accesible en el DOM.
- No resolver el contraste heredado de `.link-button` (3.86–4.13:1); sigue asignado a `accessibility-baseline`.

## Job Story

When estoy viendo la Tarjeta digital en el móvil y quiero llamar a Fahed,
I want to pulsar un botón claro de Celular,
so I can abrir el marcador con el número correcto sin copiarlo ni buscarlo.

## Users And Permissions

- Visitante anónimo: ve el botón Celular y puede activarlo; no hay autenticación ni estado.
- Implementador/agente: añade el markup, la mínima regla CSS del contenedor, los checks de harness y la evidencia; no implementa otras features.
- Validador: reproduce el gate y las mediciones de navegador de forma independiente.

## Acceptance Scenarios

### Scenario 1: Enlace Celular real

Given la página servida en `http://localhost:3307` con viewport 390×844 o 1280×800,
When se inspecciona la sección de Enlaces,
Then existe un único `<a class="link-button">` de producto con texto visible `Celular` y `href="tel:+51955116562"`; no está dentro de `[data-demo="link-button"]`.

### Scenario 2: Nombre accesible e icono

Given el Enlace Celular renderizado,
When se revisa el árbol de accesibilidad,
Then su rol es `link`, su nombre accesible es `Celular: llamar al +51 955 116 562`, el texto visible `Celular` está incluido en el nombre (label-in-name) y el SVG de teléfono es decorativo (`aria-hidden="true"`, `focusable="false"`, 18×18, `currentColor`).

### Scenario 3: Geometría y regresión visual

Given la tarjeta existente,
When se mide el botón,
Then mide 48px de alto, ocupa el 100% del ancho interior de `.links` y conserva el contrato del componente (radio 6px, padding 20px, etiqueta mayúsculas 11px/800 con tracking 1.98px, icono a la derecha). En 390×844 el botón mide 324×48 en `x=33`; en 1280×800 mide 366×48 en `x=457`. No hay scroll horizontal.

### Scenario 4: Demo y resto de la página intactos

Given la implementación terminada,
When se compara el DOM y el CSS con el estado anterior,
Then la demo conserva sus cinco anclas y su CSS, el pie, la identidad, el avatar, el page shell y los 51 tokens no cambiaron, y no hay `<script>` ni dependencias nuevas.

### Scenario 5: Estados heredados del componente

Given el botón en escritorio,
When se fuerza `:hover` y se navega con `Tab` hasta él,
Then se aplican los estados existentes de `.link-button` (`translateY(-1.5px)`, sombra hover, `brightness(1.03)`, transición 180ms ease) y el foco de teclado muestra outline de acento de 2px con offset 2px. Con `prefers-reduced-motion: reduce`, `transition-duration` es `0s` y `transform` es `none`.

### Scenario 6: Consola y red limpias

Given la página servida en 3307,
When se carga en 390×844 y 1280×800 con recarga fresca,
Then la consola muestra 0 mensajes/errores y todas las peticiones de la página responden 2xx/3xx, incluida Google Fonts y el WOFF2; no se solicita `/favicon.ico`.

### Scenario 7: El gate detecta un Enlace roto

Given una copia temporal sin la sección `.links`, sin `href="tel:+51955116562"`, con otro destino, sin el `aria-label` esperado, sin la regla `.links` o sin su padding,
When se ejecuta `./init.sh`,
Then sale con código distinto de `0`, imprime el check fallido en stderr y no arranca ningún servidor.

## Repository Research

### Files Inspected

- `AGENTS.md` — alcance por feature, Definition of Done y validación obligatoria en 390×844 y 1280×800.
- `PROGRESS.md` — `link-button-component` y el resto de prerrequisitos en `accepted`; los siete Enlaces siguen `not_started`.
- `feature_list.json` — metadata de `link-celular`, verificación (`tel:+51955116562`) y nota de que el sistema decide la app de teléfono.
- `index.html` — `.card` con avatar, identidad, demo temporal de cinco botones y pie; la demo está dentro de `.card` y el pie es el último hijo.
- `styles.css` — 51 tokens, componente `.link-button` completo con hover/focus/reduced motion, pie y CSS temporal de la demo; no existe un contenedor de Enlaces de producto.
- `init.sh` — gate no bloqueante con `fail()`, checks de bootstrap/tokens/componente/page shell/avatar/pie/identidad/metadatos; sin E2E; sirve en 3201 solo con `RUN_SERVE_COMMAND=1`.
- `DESIGN.md` — botón de Enlace de ancho completo, 48px, `rounded.md`, etiqueta mayúsculas a la izquierda e icono 18px a la derecha; columna única y `space-sm` entre botones.
- `docs/technical-discovery.md` — `Celular: tel:+51955116562`; SVG inline; sitio estático sin build ni dependencias.
- `docs/domain-model.md` — Enlace con tipo, etiqueta, icono, URL y orden; el sistema decide la app de `tel:`.
- `CONTEXT.md` — término `Celular` para el número peruano +51 955 116 562.
- `docs/specs/link-button-component.md`, `docs/specs/page-footer.md` — convenciones de spec, contratos CSS, patrón de checks y evidencia.
- `docs/validations/link-button-component.md`, `docs/validations/page-footer.md` — evidencia independiente de los prerrequisitos.

### Existing Patterns To Follow

- HTML estático y CSS plano en una sola hoja; custom properties; sin build ni JavaScript.
- Clases BEM-ish (`link-button`, `link-button__label`, `link-button__icon`); reutilizar el componente en lugar de reestilizarlo.
- Checks de `init.sh` con `grep -qF` para markup/atributos, `awk` para extraer una regla base y listas de declaraciones requeridas; fallo a stderr con `FAILED - ...`, exit `1`, sin servidor por defecto.
- Evidencia durable en `feature_list.json` (`status` + `evidence`) y `PROGRESS.md`; el validador crea `docs/validations/link-celular.md`.

### Current Gaps

- No existe markup ni CSS de Enlaces de producto; solo la demo temporal.
- No hay comprobación de harness para un Enlace real ni para un contenedor `.links`.
- No hay framework de tests ni comando E2E; la verificación es gate + navegador.
- El puerto impreso por `init.sh` es 3201; esta verificación usa 3307.

## Technical Approach

### 1. Markup exacto

Insertar una sección de Enlaces como hijo de `<article class="card">`, **después del `</section>` de la demo y antes de `<footer class="page-footer">`**:

```html
<section class="links" aria-label="Enlaces de contacto">
  <a class="link-button" href="tel:+51955116562" aria-label="Celular: llamar al +51 955 116 562">
    <span class="link-button__label">Celular</span>
    <svg class="link-button__icon" viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false">
      <path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07 19.5 19.5 0 0 1-6-6 19.79 19.79 0 0 1-3.07-8.67A2 2 0 0 1 4.11 2h3a2 2 0 0 1 2 1.72 12.84 12.84 0 0 0 .7 2.81 2 2 0 0 1-.45 2.11L8.09 9.91a16 16 0 0 0 6 6l1.27-1.27a2 2 0 0 1 2.11-.45 12.84 12.84 0 0 0 2.81.7A2 2 0 0 1 22 16.92z"/>
    </svg>
  </a>
</section>
```

- La sección no modifica la demo; queda como bloque de producto independiente.
- El `aria-label` incluye el texto visible `Celular` y añade el número en formato legible; así se cumple label-in-name y el nombre accesible es útil.
- El SVG es decorativo y no aporta nombre accesible. Se usa `currentColor` como el resto de iconos.
- No se añade `target`, `rel`, `download`, `id`, `data-*` ni modificador de tono.
- Si al implementar ya existe un contenedor `.links` (por rebase sobre otra feature de Enlaces), añadir el ancla dentro de ese contenedor y reutilizar su CSS; no crear un segundo `.links` ni cambiar el orden de otros Enlaces.

### 2. CSS exacto

Añadir antes del bloque temporal `[data-demo="link-button"]`, bajo un comentario de sección:

```css
/* Components — Links (DESIGN.md > Layout, components/button-link) */
.links {
  padding: 0 var(--space-gutter);
}
```

- Solo aporta el gutter horizontal para alinear el botón con la identidad y la demo. No define `display`, `gap`, orden, tono ni ningún contrato de la lista de siete Enlaces: eso pertenece a `links-order-gradient`.
- No se reestiliza `.link-button`: el botón hereda el componente aceptado (incluido el fondo por defecto `--color-gradient-1` del componente, sin asignar modificador).
- No se añaden tokens ni se modifica `:root`.

### 3. Accesibilidad

- Control real `<a href>` con nombre accesible `Celular: llamar al +51 955 116 562`; el texto visible `Celular` está contenido en el nombre.
- Icono decorativo (`aria-hidden="true"`, `focusable="false"`).
- Área táctil 48px de alto por todo el ancho interior.
- Foco de teclado visible heredado de `.link-button:focus-visible`.
- El comportamiento real del marcador depende del sistema operativo; la página no puede forzarlo (`docs/domain-model.md`). La verificación automatizada no activa `tel:`.

### 4. Harness / `init.sh`

Añadir una sección `Link checks:` después de los checks del pie y antes de los de identidad, sin quitar ni debilitar checks existentes:

```bash
echo "Link checks:"

if grep -qF 'class="links"' index.html \
  && grep -qF 'class="link-button"' index.html \
  && grep -qF '<span class="link-button__label">Celular</span>' index.html; then
  echo "  [ok] celular link markup"
else
  fail "index.html is missing the Celular link markup"
fi

if grep -qF 'href="tel:+51955116562"' index.html; then
  echo "  [ok] celular link destination"
else
  fail "index.html is missing the Celular link destination tel:+51955116562"
fi

if grep -qF 'aria-label="Celular: llamar al +51 955 116 562"' index.html; then
  echo "  [ok] celular link accessible label"
else
  fail "index.html is missing the Celular link accessible label"
fi

LINKS_RULE=$(awk '
  /^[[:space:]]*\.links[[:space:]]*\{/ { in_rule = 1 }
  in_rule { print }
  in_rule && /}/ { exit }
' styles.css)

if [ -z "$LINKS_RULE" ]; then
  fail "styles.css is missing the .links base rule"
fi
echo "  [ok] .links base rule exists"

LINKS_CONTRACT=('padding: 0 var(--space-gutter);')
# Mismo patrón de acumulación, stderr y exit 1 que el resto del harness.
```

- Salidas esperadas: `[ok] celular link markup`, `[ok] celular link destination`, `[ok] celular link accessible label`, `[ok] .links base rule exists`, `[ok] links container contract (1/1)`.
- No comprobar el orden de Enlaces, el modificador de tono ni la demo en el harness.
- Cambiar el comando impreso y `RUN_SERVE_COMMAND` de 3201 a **3307**; el script sigue sin arrancar servidor por defecto.
- Mantener intactos bootstrap, tokens, componente, page shell, avatar, pie, identidad y metadatos.

### 5. Cierre

- Registrar evidencia en `feature_list.json` (`status: passing` + `evidence`) y en `PROGRESS.md` (estado verificado y sesión).
- No marcar `link-celular` como `accepted`: eso corresponde al validador.
- No modificar el estado de otras features.

## Expected File Changes

- `index.html` — modificar; añadir `section.links` con el ancla Celular entre la demo y el pie. Nada más.
- `styles.css` — modificar; añadir solo la regla `.links` con padding de gutter antes del bloque de demo.
- `init.sh` — modificar; añadir `Link checks:` y cambiar el puerto impreso/`RUN_SERVE_COMMAND` a 3307.
- `feature_list.json` — modificar; `link-celular` a `passing` con evidencia (implementador).
- `PROGRESS.md` — modificar; estado verificado y bitácora (implementador).
- `docs/specs/link-celular.md` — crear; este spec (planner).
- `docs/validations/link-celular.md` — crear; lo genera el validador.
- No se crean archivos de producto, assets ni dependencias nuevas.

## Visual Design Impact

- UI involved: yes.
- Design source: `DESIGN.md` > `components/button-link`, `Colors`, `Layout`, `Components > Botón de Enlace`.
- Screens or states affected: única vista; nuevo botón Celular en la columna, estados normal, hover (escritorio), `:focus-visible` y `prefers-reduced-motion`.
- New design artifact required: no — se reutiliza el componente y el padding de gutter; no se inventan colores, tipografías ni tonos.

## Durable Documentation Impact

- `ARCHITECTURE.md`: not needed — no cambian stack, capas ni boundaries.
- `CONSTRAINTS.md`: not needed — no se introduce una regla MUST/MUST NOT nueva; se aplican las existentes.
- `AGENTS.md`: not needed — el camino de arranque sigue siendo `./init.sh`; solo se añaden checks y se ajusta el puerto sugerido.
- `docs/technical-discovery.md`: not needed — ya documenta `tel:+51955116562` e iconos SVG inline.
- `docs/risks-and-open-questions.md`: not needed — el comportamiento del marcador según dispositivo ya está registrado; no aparece un riesgo nuevo.
- `DESIGN.md`: not needed — es fuente de verdad y no se modifica.

## Implementation Plan

1. Insertar `section.links` con el ancla Celular entre la demo y el pie, con el markup exacto.
2. Añadir la regla `.links` antes del CSS temporal de la demo, sin tocar reglas existentes.
3. Extender `init.sh` con `Link checks:` y cambiar el puerto sugerido a 3307; conservar el comportamiento no bloqueante.
4. Ejecutar `./init.sh` y los casos negativos en copia temporal; servir en 3307 y verificar en navegador 390×844 y 1280×800.
5. Registrar evidencia en `feature_list.json` y `PROGRESS.md`.

## Implementation Tasks

- [ ] Añadir `section.links[aria-label="Enlaces de contacto"]` después de la demo y antes del pie.
- [ ] Añadir el ancla `link-button` con `href="tel:+51955116562"`, `aria-label="Celular: llamar al +51 955 116 562"` y etiqueta visible `Celular`.
- [ ] Añadir el SVG de teléfono 18×18 con `currentColor`, `aria-hidden="true"` y `focusable="false"`.
- [ ] Añadir la regla `.links { padding: 0 var(--space-gutter); }` sin tocar `.link-button`, la demo ni `:root`.
- [ ] Ampliar `init.sh` con los cinco checks de Enlace/Contenedor y el puerto 3307, sin quitar checks previos.
- [ ] Probar `bash -n init.sh`, `./init.sh` (exit `0`) y los casos negativos en copia temporal.
- [ ] Verificar en navegador 390×844 y 1280×800: geometría, estilos computados, nombre accesible, foco, hover, reduced motion, consola y red.
- [ ] Registrar evidencia en `feature_list.json` y `PROGRESS.md`.

## Verification Plan

### Gate

- `bash -n init.sh` → sin errores de sintaxis.
- `./init.sh` → `Harness status: bootstrapped`, checks previos `[ok]`, los cinco checks nuevos `[ok]`, exit `0`, sin servidor.
- Casos negativos en una copia temporal fuera del repo (nunca sobre el worktree), cada uno con exit `1` y stderr específico, sin listener en 3307:
  1. Eliminar `class="links"` → markup faltante.
  2. Cambiar `href="tel:+51955116562"` por `tel:+51955116563` → destino faltante/inesperado.
  3. Eliminar el `aria-label` del ancla → nombre accesible faltante.
  4. Cambiar la etiqueta visible `Celular` por `Teléfono` → markup faltante.
  5. Eliminar la regla `.links` → `.links base rule` faltante.
  6. Eliminar `padding: 0 var(--space-gutter);` de `.links` → `links container contract is missing 1 of 1 required declarations`.
- En todos los casos: eliminar la copia temporal; no arrancar ni detener servidores.

### Browser

- Comprobar que 3307 está libre (`lsof -nP -iTCP:3307 -sTCP:LISTEN`). Si lo ocupa un proceso ajeno, no detenerlo; registrar el bloqueo. Servir con `python3 -m http.server 3307 --directory .` (o `RUN_SERVE_COMMAND=1 ./init.sh`) y **detener solo el proceso iniciado por esta sesión**.
- `curl -sI http://localhost:3307/` → `200 text/html`; `curl -sI http://localhost:3307/styles.css` → `200 text/css`.
- **390×844 (móvil):**
  - Consola con **0 mensajes/errores**; red sin 4xx/5xx y sin `/favicon.ico`.
  - `section.links` existe, es hijo de `.card` y no está dentro de `[data-demo="link-button"]`; hay 1 ancla de producto y siguen existiendo las 5 anclas de la demo.
  - `.links` mide 356px de ancho en `x=17` con padding 16px; el ancla mide 324×48 en `x=33`, `display:flex`, `height:48px`, radio 6px, `padding:0px 20px`, `justify-content:space-between`, etiqueta 11px/800/16px, `letter-spacing:1.98px`, `text-transform:uppercase`, texto blanco; icono 18×18 decorativo.
  - `href` exacto `tel:+51955116562`; rol `link`; nombre accesible `Celular: llamar al +51 955 116 562`.
  - `scrollWidth == clientWidth == 390`.
- **1280×800 (escritorio):**
  - Consola con 0 mensajes; red sin fallos; sin `/favicon.ico`.
  - `.links` mide 398px en `x=441`; el ancla mide 366×48 en `x=457`; mismos estilos y nombre accesible; texto en una línea; `scrollWidth == clientWidth == 1280`.
  - Hover real/frozado → `transform: matrix(1, 0, 0, 1, 0, -1.5)`, sombra hover `rgba(108, 114, 234, 0.28) 0px 8px 18px 0px`, `filter: brightness(1.03)`; `Tab` → `:focus-visible=true`, outline `rgb(88, 92, 229) solid 2px` con offset 2px.
- **Reduced motion:** emular `prefers-reduced-motion: reduce`; en hover/foco `transition-duration:0s` y `transform:none`, outline de foco visible.
- **No activar el enlace** (`tel:`); comprobar solo el atributo en el DOM para no abrir apps del sistema. La comprobación del marcador en un teléfono real queda como verificación manual del propietario en iOS/Android.
- **Consola/red:** registrar mensajes y peticiones de ambos viewports (documento, Google Fonts CSS, `styles.css`, WOFF2); 0 errores y 0 fallos.
- E2E: no aplica; no existe harness E2E y añadirlo introduciría dependencias prohibidas. La verificación es gate + navegador.

## Evidence To Capture

- Salida de `./init.sh` correcto (exit `0`, cinco checks nuevos) y de los seis casos negativos (exit `1`, stderr correcto, sin listener en 3307).
- `curl -sI` de `/` y `/styles.css`.
- DOM: `section.links` fuera de la demo, un ancla de producto, cinco anclas de demo intactas, `href` exacto y nombre accesible.
- Valores computados en 390×844 y 1280×800 (ancho/alto del botón y del contenedor, padding, radio, tipografía, tracking, icono, posición).
- Resultado de foco de teclado, hover y `prefers-reduced-motion`.
- Consola y red de ambos viewports: 0 errores/mensajes y 0 peticiones fallidas, sin `/favicon.ico`.
- Alcance: 51 tokens, sin `<script>`, sin modificador de tono, sin dependencias, demo y pie intactos.
- `feature_list.json` (`status: passing`, `evidence`) y `PROGRESS.md` actualizados; ninguna otra feature modificada.
- Screenshots opcionales (no obligatorios).

## Validator Checklist

- [ ] Existe exactamente un Enlace de producto `Celular` con `href="tel:+51955116562"` y nombre accesible correcto.
- [ ] El Enlace reutiliza `.link-button` sin modificador de tono ni CSS específico de botón.
- [ ] El icono SVG es inline, 18×18, `currentColor`, `aria-hidden="true"` y `focusable="false"`.
- [ ] El contenedor `.links` solo aporta el padding de gutter; no implementa orden, gap ni degradado.
- [ ] La demo temporal y sus cinco anclas, el pie, la identidad, el avatar, el page shell y los 51 tokens siguen intactos.
- [ ] No se añadieron JavaScript, frameworks, bundlers, dependencias, assets ni tokens.
- [ ] `./init.sh` sale `0` con los cinco checks nuevos y falla en los seis casos negativos.
- [ ] Verificación en 390×844 y 1280×800 sin errores de consola ni peticiones fallidas, en el puerto 3307.
- [ ] El servidor iniciado por la sesión fue detenido; ningún proceso ajeno fue detenido.
- [ ] `feature_list.json` y `PROGRESS.md` están actualizados; `link-celular` queda en `passing`, no `accepted`.
- [ ] No se implementó ninguna otra feature.

## Risks And Mitigations

- **Conflicto entre features de Enlaces:** todas tocan `index.html`, `styles.css`, `init.sh`, `feature_list.json` y `PROGRESS.md`, y comparten el contenedor `.links`. Mitigación: mantener el cambio mínimo y reutilizar `.links` si ya existe tras un rebase; el orden y la retirada de la demo quedan en `links-order-gradient`.
- **`tel:` no automatizable:** el navegador headless no tiene marcador y activar el enlace abriría el manejador del sistema. Mitigación: validar `href` exacto y nombre accesible; el propietario confirma el marcador en iOS/Android.
- **Nombre accesible sobrescrito por `aria-label`:** un `aria-label` sin el texto visible incumpliría label-in-name. Mitigación: el valor empieza por `Celular` y el validador lo comprueba en el árbol de accesibilidad.
- **Puerto 3307 ocupado:** podría pertenecer a otra sesión. Mitigación: comprobar antes de servir; no detener procesos ajenos.
- **Contraste heredado:** las etiquetas blancas sobre los tonos miden 3.86–4.13:1. Mitigación: no se altera el componente en esta feature; sigue en `accessibility-baseline`.

## Assumptions And Open Questions

### Assumptions

- El primer Enlace de producto establece un contenedor mínimo `.links`; los siguientes Enlaces se añadirán dentro y `links-order-gradient` definirá orden, separación y tonos.
- El botón usa el fondo por defecto del componente (`--color-gradient-1`) al no asignar modificador; esto no constituye la progresión de tonos.
- La verificación automatizada comprueba el `href`, no abre el marcador; la prueba en dispositivo real es manual.
- No hay E2E ni framework de tests; la verificación es `init.sh` + navegador.

### Open Questions

- Ninguna bloqueante para este slice. El orden/tono final y la retirada de la demo se resolverán en `links-order-gradient`.
