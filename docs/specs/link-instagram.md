# Feature Implementation Spec: Enlace a Instagram

## Source Feature

- `id`: `link-instagram`
- `area`: `links`
- `depends_on`: `["link-button-component"]` (satisfied: `accepted`)
- `status`: `not_started` (at planning time; this spec does not change it)
- `source`: `feature_list.json`
- `notes`: URL confirmada en `docs/technical-discovery.md` (integraciones); aspecto tomado de `DESIGN.md` > `components.button-link`, `layout`, `colors`, `typography` y `Accessibility Baseline`; icono SVG inline según `docs/technical-discovery.md`.

## Goal

Añadir a la Tarjeta digital **un único Enlace real de Instagram** dentro de una nueva región de Enlaces de la tarjeta existente. El Enlace reutiliza el componente `.link-button` ya aceptado, muestra la etiqueta legible `Instagram` a la izquierda y un icono SVG inline de Instagram de 18×18 a la derecha, y navega a `https://www.instagram.com/fahedhermoza/` en la misma pestaña.

El Enlace se inserta después del bloque de identidad del Perfil y antes de la demo temporal `[data-demo="link-button"]`. La demo, el resto de la página, el pie, el `<head>`, los tokens y `DESIGN.md` permanecen intactos. El alcance termina cuando el Enlace es verificable en móvil (390×844) y escritorio (1280×800), `init.sh` lo comprueba de forma no bloqueante y la evidencia queda registrada.

**Precisión de alcance:** “exactamente un Enlace” significa un único `<a class="link-button">` nuevo dentro de la región `.links`. El pie ya contiene un enlace al Handle con la misma URL de Instagram desde `page-footer`; ese enlace pertenece a otra feature aceptada, **no se cuenta** y **no se modifica**.

## Non-Goals

- No implementar Facebook, WhatsApp, LinkedIn, Portafolio, Correo ni Celular (`link-facebook`, `link-whatsapp`, `link-linkedin`, `link-portafolio`, `link-correo`, `link-celular`).
- No implementar el orden final de los siete Enlaces, la asignación de tonos del degradado ni la separación vertical entre Enlaces: pertenecen a `links-order-gradient`.
- No retirar la demo temporal `[data-demo="link-button"]` ni su bloque CSS. Debe conservarse íntegra; su retirada queda diferida a una feature posterior.
- No modificar el enlace de Instagram del pie, el avatar, la identidad, el page shell, el `<head>`, los metadatos Open Graph ni el favicon.
- No modificar `.link-button` ni sus estados (hover, focus, reduced motion): este feature solo consume el componente.
- No añadir `target="_blank"`, `rel`, `aria-label` al enlace, `data-*` de producto ni JavaScript.
- No añadir frameworks, bundlers, preprocessors, npm, dependencias, hojas extra, assets ni iconos externos.
- No añadir ni modificar tokens de `:root` (51 tokens) ni reglas de `body`, `.page` o `.card`.
- No resolver el contraste AA de las etiquetas de Enlace (3.86–4.13:1); es un riesgo heredado ya registrado para `accessibility-baseline`.
- No implementar “Guardar contacto”, vCard, analítica, modo oscuro, `theme-color` ni otras features.
- No modificar `DESIGN.md`.

## Job Story

When estoy viendo la Tarjeta digital después del Perfil,
I want to pulsar el botón de Instagram y abrir el perfil de Fahed,
so I can seguirle o contactarle sin tener que dictar o escribir su Handle.

## Users And Permissions

- **Visitante anónimo:** ve y pulsa el Enlace; la página no tiene autenticación, sesión, roles ni datos de usuario.
- **Implementador/agente:** añade el markup del Enlace, una regla CSS mínima de contenedor, el check del harness y la evidencia; no implementa otras features.
- **Validador:** reproduce el gate, los casos negativos y las mediciones de navegador de forma independiente.
- **Sistema operativo/navegador:** decide si la URL de Instagram se abre en la app o en el navegador; la página no puede forzarlo.

## Acceptance Scenarios

### Scenario 1: Enlace visible dentro de la región de Enlaces

Given la página servida en `http://localhost:3301` con viewport 390×844 o 1280×800,
When se inspecciona la tarjeta después del bloque de identidad,
Then existe `<nav class="links" aria-label="Enlaces de contacto">` con exactamente un `<a class="link-button">` que mide 48px de alto y ocupa el 100% del ancho interior del nav, con la etiqueta visible `Instagram` a la izquierda y el icono a la derecha; el nav aparece antes de la demo y el pie sigue siendo el último hijo de `.card`.

### Scenario 2: Destino y nombre accesible

Given el Enlace renderizado,
When se inspecciona el DOM y el árbol de accesibilidad,
Then su `href` es exactamente `https://www.instagram.com/fahedhermoza/`, no tiene `target` ni `rel`, su nombre accesible contiene `Instagram` a partir de la etiqueta visible, y el icono es decorativo (`aria-hidden="true"`, `focusable="false"`).

### Scenario 3: Reutilización del componente y del tono base

Given el componente `.link-button` aceptado,
When se inspecciona el Enlace real,
Then usa `class="link-button"` sin ningún modificador `link-button--gradient-*`, y por tanto toma el fondo por defecto del componente (`--color-gradient-1`, `#6876f0`) con texto e icono blancos; no se añaden estilos nuevos al componente ni se decide la progresión de los siete Enlaces.

### Scenario 4: Icono SVG inline correcto

Given el markup del Enlace,
When se inspecciona el SVG,
Then tiene `class="link-button__icon"`, `viewBox="0 0 24 24"`, `width="18"`, `height="18"`, pintado con `currentColor` (trazo), `aria-hidden="true"` y `focusable="false"`, es el glifo de Instagram y no genera ninguna petición de red.

### Scenario 5: Demo y resto de la página intactos

Given el estado actual de `index.html` y `styles.css`,
When se compara con la implementación,
Then la demo `[data-demo="link-button"]` conserva sus cinco anclas, sus etiquetas `Enlace uno`…`Enlace cinco`, sus `href="#link-button-demo"` y su bloque CSS; el pie, la identidad, el avatar, el `<head>`, `.page`, `.card`, `body` y los 51 tokens no cambian.

### Scenario 6: Estados heredados del componente

Given el Enlace real en escritorio,
When se fuerza hover o se navega con `Tab` hasta él,
Then hereda exactamente los estados del componente: hover con `translateY(-1.5px)`, sombra de hover y `brightness(1.03)`; foco de teclado con `outline: 2px solid #585ce5` y offset 2px; con `prefers-reduced-motion: reduce`, transición `0s` y `transform: none`. No se activa el enlace real durante la automatización.

### Scenario 7: Gate anclado a la región de Enlaces

Given una copia temporal con el nav de Enlaces eliminado, el `href` del Enlace real alterado, la etiqueta `Instagram` cambiada, un atributo del icono eliminado, un modificador de gradiente añadido al Enlace real, la demo eliminada o el padding de `.links` eliminado,
When se ejecuta `./init.sh`,
Then sale con código distinto de `0`, imprime el check fallido en stderr y no arranca ningún servidor.

### Scenario 8: Sin errores de consola ni peticiones fallidas

Given la página servida en el puerto 3301,
When se carga en 390×844 y 1280×800,
Then la consola muestra 0 mensajes/errores, la red no contiene peticiones 4xx/5xx, no se solicita `/favicon.ico` y no hay scroll horizontal. Las peticiones esperadas son las ya existentes (documento, Google Fonts CSS, `styles.css`, WOFF2 y `assets/avatar.jpg`); el Enlace no añade peticiones.

### Scenario 9: Contraste heredado, sin regresión

Given la etiqueta blanca sobre el fondo base del Enlace (`#6876f0`),
When se calcula el contraste,
Then se registra `3.86:1`, el mismo valor ya documentado como riesgo heredado para `accessibility-baseline`; este feature no cambia tokens, colores ni tamaño de etiqueta para corregirlo.

## Repository Research

### Files Inspected

- `AGENTS.md` — workflow de arranque, alcance por feature, Definition of Done y validación obligatoria en móvil 390×844 y escritorio 1280×800.
- `PROGRESS.md` — `link-button-component`, `page-shell`, `profile-avatar`, `profile-identity`, `page-footer` y `open-graph-metadata` en `accepted`; la demo temporal sigue vigente; el siguiente paso es planificar features de Enlaces.
- `feature_list.json` — metadata de `link-instagram`, dependencia `link-button-component` aceptada, verificación y nota de la URL.
- `DESIGN.md` — `components.button-link` (48px, `rounded.md`, texto `on-primary`), `layout` (columna única, botones de ancho completo, `space-sm` entre botones), `colors` (degradado 1–5, texto/icono blancos), `typography.button-label` y `Accessibility Baseline`.
- `docs/technical-discovery.md` — Instagram `https://www.instagram.com/fahedhermoza/`; iconos SVG inline; sin framework, bundler ni build.
- `docs/build-brief.md` — orden del MVP: Instagram primero; los Enlaces son botones de ancho completo; contenido en español.
- `docs/domain-model.md` — el Enlace tiene tipo, etiqueta, icono, URL y orden; la Tarjeta contiene una lista ordenada de Enlaces.
- `CONTEXT.md` — glosario: Enlace = botón accionable que abre un canal externo; orden del MVP con Instagram primero.
- `docs/risks-and-open-questions.md` — riesgo heredado de contraste de etiquetas de Enlace (3.86–4.13:1) para `accessibility-baseline`.
- `docs/specs/link-button-component.md` — markup del componente, contrato CSS, icono 18×18 con `currentColor`, estados y convención de gate.
- `docs/specs/page-footer.md` — estilo de spec, contrato de `.page-footer`, convención de checks negativos y puerto único de sesión.
- `index.html` — `<main class="page"><article class="card">` con avatar, identidad, demo temporal de cinco anclas, pie y metadatos; el pie ya contiene `href="https://www.instagram.com/fahedhermoza/"` con `aria-label="@fahedhermoza en Instagram"`.
- `styles.css` — 51 tokens en `:root`, reset, `body`, `.page`, `.card`, avatar, identidad, `.link-button` con sus modificadores, pie y bloque temporal `[data-demo="link-button"]`.
- `init.sh` — gate no bloqueante: bootstrap, tokens, componente, page shell, avatar, pie, identidad y metadatos; imprime 3201 y solo sirve con `RUN_SERVE_COMMAND=1`; no hay checks de Enlaces reales.
- `docs/validations/` — existen registros de aceptación de los prerrequisitos; no existe harness E2E ni framework de tests.
- `lsof -nP -iTCP:3301 -sTCP:LISTEN` — sin listener; el puerto 3301 está libre en este worktree. `git status` limpio.

### Current State

- Todos los prerrequisitos están aceptados: page shell, tokens, componente de botón, avatar, identidad y pie.
- No existe ningún Enlace real ni una región de Enlaces de producto.
- La demo temporal de cinco botones sigue dentro de `.card`, entre la identidad y el pie.
- El pie ya enlaza a Instagram con la URL exacta del feature; sirve como destino del Handle, no como Enlace de la lista.
- No existen `ARCHITECTURE.md` ni `CONSTRAINTS.md`.

### Existing Patterns To Follow

- HTML estático y una única hoja `styles.css`, sin build ni imports.
- Clases BEM-ish y valores derivados de tokens; los valores internos del componente viven en `.link-button`, no en `:root`.
- `init.sh` con `set -euo pipefail`, checks acumulativos, mensajes a stderr, `exit 1`, sin servidor por defecto.
- Los checks extraen bloques CSS con `awk` y comprueban declaraciones textuales; no hay framework de tests.
- Evidencia durable en `feature_list.json` (`status` + `evidence`) y `PROGRESS.md`; el validador crea `docs/validations/<feature>.md`.
- En este repo, “check no bloqueante” significa que no arranca servidores ni procesos de larga duración; los checks estructurales fallan con `exit 1` como los existentes.

### Current Gaps

- No hay markup ni CSS para la región de Enlaces reales.
- No hay check de harness para el Enlace de Instagram.
- El `href` de Instagram ya aparece en el pie, así que un `grep` global daría un falso positivo si el Enlace real desaparece.
- La demo también usa `.link-button`, así que un conteo global de botones daría seis en lugar de uno.
- `init.sh` sugiere el puerto 3201; esta feature debe verificarse en 3301.

## Technical Approach

### 1. Markup exacto y ubicación

Insertar dentro de `<article class="card">`, después del cierre de `<header class="profile-identity">` y antes del comentario/bloque de la demo temporal:

```html
<nav class="links" aria-label="Enlaces de contacto">
  <a class="link-button" href="https://www.instagram.com/fahedhermoza/">
    <span class="link-button__label">Instagram</span>
    <svg class="link-button__icon" viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false">
      <rect x="2" y="2" width="20" height="20" rx="5" ry="5"/>
      <path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z"/>
      <line x1="17.5" y1="6.5" x2="17.51" y2="6.5"/>
    </svg>
  </a>
</nav>
```

- `nav` con `aria-label="Enlaces de contacto"` agrupa los Enlaces y ofrece un landmark navegable; con un solo hijo sigue siendo válido.
- El enlace es un `<a href>` real, sin `target` ni `rel`: navega en la misma pestaña y deja que el sistema decida abrir la app de Instagram.
- La etiqueta visible es `Instagram`; no se añade `aria-label` al `<a>`. El nombre accesible se deriva del texto visible. El navegador puede exponerlo como `INSTAGRAM` por `text-transform: uppercase`; se acepta y se comprueba sin distinguir mayúsculas.
- El SVG es decorativo y no aporta nombre accesible. `currentColor` hereda el blanco de `.link-button`.
- No se usa ningún modificador `link-button--gradient-*` en este Enlace. El fondo proviene del fallback del componente (`--color-gradient-1`). La asignación de tonos y el orden de los siete Enlaces quedan para `links-order-gradient`.
- La demo y el pie no se mueven ni se editan; el pie sigue siendo el último hijo de `.card`.

### 2. CSS exacto

Añadir una única sección nueva en `styles.css`, después del bloque del componente `.link-button` (incluido su `prefers-reduced-motion`) y antes de la sección del pie:

```css
/* Links — Enlaces (DESIGN.md > layout, components/button-link) */
.links {
  padding: 0 var(--space-lg);
}
```

- El padding horizontal de 24px (`space-lg`) alinea el Enlace con el ritmo interno de `.profile-identity` y `.page-footer` (ambos usan 24px), y evita que el botón toque el borde de la tarjeta.
- No se añade `display: flex`, `gap`, orden ni tonos: la pila de varios Enlaces, su separación `space-sm` y la progresión del degradado pertenecen a `links-order-gradient`. Con un solo Enlace no hay separación observable.
- No se toca `:root`, `body`, `.page`, `.card`, `.link-button`, el pie ni la demo. `box-sizing: border-box` ya está cubierto por el reset universal.
- Anchos esperados del Enlace (ancho interior del nav): 308px en 390×844 (tarjeta 358, borde 1px por lado, padding 24px por lado) y 350px en 1280×800 (tarjeta 400, borde 1px, padding 24px). A 320px: 238px.

### 3. Reutilización del componente y estados

- No se duplica ni se sobreescribe ninguna regla de `.link-button`. El Enlace hereda `display:flex`, 48px de alto, radio 6px, padding `0 20px`, `space-between`, tipografía `button-label` en mayúsculas, sombra, hover, `:focus-visible` y `prefers-reduced-motion`.
- El tono base es `#6876f0` (`--color-gradient-1`), con etiqueta e icono `#ffffff`.
- No se añade `:active`, hover nuevo ni transición nueva.

### 4. Icono de Instagram

- SVG inline con el glifo de Instagram (rectángulo redondeado, círculo y punto) dibujado con trazo `currentColor`, `stroke-width="2"` y uniones redondeadas.
- `width="18" height="18"` y `viewBox="0 0 24 24"`; la clase `.link-button__icon` ya fija `flex: 0 0 18px` y el tamaño, por lo que el icono queda a la derecha.
- `aria-hidden="true"` y `focusable="false"`; no hay `<title>`, archivo externo ni petición de red.

### 5. Accesibilidad

- Enlace real con nombre accesible desde la etiqueta visible `Instagram`; icono decorativo.
- Área táctil de 48px de alto por el ancho del contenido del nav, por encima de 44×44px.
- Foco visible heredado: outline de acento `#585ce5` de 2px con offset 2px.
- La región tiene un nombre accesible (`Enlaces de contacto`) y no duplica el `aria-label` del pie.
- Contraste: blanco sobre `#6876f0` = 3.86:1, ya registrado como riesgo heredado de `link-button-component`; no se corrige aquí ni se inventan colores.
- No se activa el enlace externo durante la verificación automatizada: se comprueba el `href` en el DOM para no generar tráfico a Instagram ni abrir apps del sistema.

### 6. Harness / `init.sh`

Añadir una sección `Instagram link checks:` después de los checks existentes (por ejemplo, al final, antes del comando de servido), sin eliminar ni debilitar bootstrap, tokens, componente, page shell, avatar, pie, identidad o metadatos.

Comprobaciones durables:

1. **Bloque de Enlaces:** extraer con `awk` el bloque desde `<nav class="links"` hasta `</nav>` en `index.html` y exigir que no esté vacío; si falta, fallar con un mensaje que mencione la región de Enlaces.
2. **Enlace real:** dentro de ese bloque, exigir exactamente un `class="link-button"` (sin contar `.link-button__label` ni `.link-button__icon`), el `href="https://www.instagram.com/fahedhermoza/"` exacto y la etiqueta `>Instagram<`.
3. **Sin modificador de degradado:** el bloque de Enlaces no debe contener `link-button--gradient-`; la asignación de tonos no pertenece a esta feature.
4. **Icono:** dentro del bloque, exigir `class="link-button__icon"`, `width="18"`, `height="18"`, `stroke="currentColor"`, `aria-hidden="true"` y `focusable="false"`.
5. **Contenedor:** extraer la regla `.links { … }` con `awk` y exigir `padding: 0 var(--space-lg);`.
6. **Demo preservada:** exigir `data-demo="link-button"` y las cinco etiquetas `Enlace uno`…`Enlace cinco` (o los cinco `href="#link-button-demo"`); si falta la demo, fallar. Esto protege la restricción de no retirarla.
7. **Anclaje al nav:** no usar una búsqueda global del `href` de Instagram, porque el pie ya contiene la misma URL y el check pasaría con el Enlace real eliminado. El check debe evaluar únicamente el bloque extraído del nav.

Salidas esperadas (nombres orientativos, consistentes con el estilo actual):

- `[ok] links navigation block exists`
- `[ok] Instagram Enlace markup`
- `[ok] Instagram Enlace destination https://www.instagram.com/fahedhermoza/`
- `[ok] Instagram Enlace icon contract`
- `[ok] .links layout rule`
- `[ok] link button demo preserved`

En fallo: mensaje a stderr con el check concreto y `Harness status: FAILED - ...`, `exit 1`, sin arrancar servidor. Mantener el comportamiento no bloqueante (sin servidor por defecto).

Cambiar el comando de servido impreso y el destino de `RUN_SERVE_COMMAND` de 3201 a **3301**:

```text
Serving command: python3 -m http.server 3301 --directory .
```

Actualizar la pista manual para indicar 390×844 (móvil) y 1280×800 (escritorio), manteniendo el modo `RUN_SERVE_COMMAND=1` sin arrancar servidor por defecto.

### 7. Cierre

- Registrar evidencia en `feature_list.json` (`status: passing` + `evidence`) y en `PROGRESS.md` (estado verificado y sesión).
- No marcar `link-instagram` como `accepted`; eso corresponde al validador.
- No cambiar el estado de otras features.
- No actualizar `docs/risks-and-open-questions.md` salvo que aparezca un riesgo nuevo: el contraste 3.86:1 ya está registrado. La URL de Instagram ya está en `docs/technical-discovery.md`.
- Registrar en `feature_list.json` (evidencia/nota de `link-instagram`) que la demo se conserva a propósito y que su retirada se difiere a una feature posterior, porque las notas previas de `link-button-component` decían retirarla al integrar los Enlaces. No cambiar notas ni estados de otras features.

## Expected File Changes

- `index.html` — modificar; añadir `<nav class="links">` con el Enlace de Instagram entre `</header>` de `.profile-identity` y la demo. No tocar `<head>`, avatar, identidad, demo, pie ni metadatos.
- `styles.css` — modificar; añadir solo la regla `.links { padding: 0 var(--space-lg); }`. No tocar tokens, componente, page shell, pie ni demo.
- `init.sh` — modificar; añadir `Instagram link checks:` con extracción del nav, contrato del Enlace/icono, gate de demo y regla `.links`; cambiar el puerto sugerido/`RUN_SERVE_COMMAND` a 3301. Conservar todos los checks previos.
- `feature_list.json` — modificar; `link-instagram` a `passing` con evidencia (implementador).
- `PROGRESS.md` — modificar; estado verificado y sesión (implementador).
- `docs/specs/link-instagram.md` — crear; este spec (planner).
- `docs/validations/link-instagram.md` — crear; lo genera el validador, no el implementador.
- No se crean assets, dependencias ni archivos de producto nuevos.

## Visual Design Impact

- UI involved: yes.
- Design source: `DESIGN.md` > `components.button-link`, `layout`, `colors` (degradado 1–5, texto/icono blancos), `typography.button-label`, `Components > Botón de Enlace` y `Accessibility Baseline`.
- Screens or states affected: única vista; un nuevo botón real en la columna de Enlaces; estados normal, hover (escritorio), `:focus-visible` y `prefers-reduced-motion` heredados del componente. La demo temporal de cinco botones sigue visible debajo.
- New design artifact required: no — el Enlace usa el componente y el token de degradado existentes; no se inventan colores, tipografías ni medidas. La única decisión nueva es el padding horizontal de 24px del contenedor, alineado con la identidad y el pie.

## Durable Documentation Impact

- `ARCHITECTURE.md`: not needed — no cambian stack, capas, dominios ni boundaries; sigue siendo un sitio estático de una hoja CSS.
- `CONSTRAINTS.md`: not needed — no se introduce una regla MUST/MUST NOT nueva; se aplican las existentes (tokens, sin dependencias, foco visible, SVG inline).
- `AGENTS.md`: not needed — el camino de arranque sigue siendo `./init.sh`; solo se añaden checks y se actualiza el puerto sugerido.
- `docs/technical-discovery.md`: not needed — ya documenta la URL de Instagram y los iconos SVG inline.
- `docs/risks-and-open-questions.md`: not needed — el contraste 3.86–4.13:1 ya está registrado como riesgo heredado para `accessibility-baseline`.
- `DESIGN.md`: not needed — es fuente de verdad y no se modifica.
- `feature_list.json` y `PROGRESS.md`: update — son los artefactos durables de estado y evidencia de la feature.

## Implementation Plan

1. Insertar el `<nav class="links">` con el Enlace de Instagram y su SVG entre la identidad y la demo, conservando el resto del documento.
2. Añadir la regla `.links` en `styles.css` sin tocar el componente ni los tokens.
3. Extender `init.sh` con los checks anclados al nav, la comprobación de demo y la regla `.links`; cambiar el puerto a 3301 sin debilitar checks previos.
4. Ejecutar `bash -n init.sh`, `./init.sh` y los casos negativos en copias temporales; servir en 3301 y verificar en navegador 390×844 y 1280×800.
5. Registrar evidencia en `feature_list.json` y `PROGRESS.md`; dejar `link-instagram` en `passing`.

## Implementation Tasks

- [ ] Añadir `<nav class="links" aria-label="Enlaces de contacto">` después de `</header>` de `.profile-identity` y antes de la demo.
- [ ] Añadir el `<a class="link-button" href="https://www.instagram.com/fahedhermoza/">` con la etiqueta `Instagram` y el SVG inline de Instagram.
- [ ] Verificar que el Enlace no usa modificador `link-button--gradient-*` y que el icono tiene `18×18`, `currentColor`, `aria-hidden="true"` y `focusable="false"`.
- [ ] Añadir `.links { padding: 0 var(--space-lg); }` en `styles.css`.
- [ ] Conservar la demo `[data-demo="link-button"]` con sus cinco anclas y su CSS; no tocar el pie, la identidad, el avatar ni el `<head>`.
- [ ] Ampliar `init.sh` con la sección `Instagram link checks:` usando extracción del nav, sin búsquedas globales del `href` ni conteos globales de `.link-button`.
- [ ] Cambiar el comando de servido y `RUN_SERVE_COMMAND` a 3301; mantener el script sin servidor por defecto.
- [ ] Ejecutar `bash -n init.sh` y `./init.sh` (exit `0`, checks previos intactos, checks nuevos `[ok]`).
- [ ] Ejecutar los casos negativos en copias temporales fuera del repo y confirmar `exit 1`, stderr correcto y sin listener en 3301.
- [ ] Verificar en navegador 390×844 y 1280×800: geometría, estilos computados, icono, nombre accesible, foco, hover, reduced motion, consola y red.
- [ ] Registrar evidencia en `feature_list.json` (`status: passing`) y `PROGRESS.md`; incluir que la demo se conserva a propósito y que su retirada se difiere; no marcar `accepted`.

## Verification Plan

### Gate

- `bash -n init.sh` — sin errores de sintaxis.
- `./init.sh` — `Harness status: bootstrapped`, todos los checks previos `[ok]`, los checks nuevos `[ok]`, `exit 0`, sin servidor y sin listener en 3301.
- Casos negativos en una copia temporal fuera del repo (nunca sobre el worktree):
  1. Eliminar el `<nav class="links">…</nav>` dejando el enlace de Instagram del pie → `exit 1`, stderr del bloque de Enlaces faltante (prueba de que el check no se satisface con el pie).
  2. Cambiar el `href` del Enlace real por otro destino → `exit 1`, stderr del destino esperado.
  3. Cambiar la etiqueta `Instagram` por otra → `exit 1`, stderr de etiqueta faltante.
  4. Eliminar `aria-hidden="true"`, `focusable="false"`, `width="18"`, `height="18"` o `stroke="currentColor"` del SVG → `exit 1`, stderr del contrato de icono.
  5. Añadir `link-button--gradient-1` (o cualquier modificador) al Enlace real → `exit 1`, stderr del alcance de tonos.
  6. Eliminar `data-demo="link-button"` o una de las cinco etiquetas de demo → `exit 1`, stderr de demo no preservada.
  7. Eliminar `padding: 0 var(--space-lg);` de `.links` → `exit 1`, stderr del contrato del contenedor.
- En todos los casos: `lsof -nP -iTCP:3301 -sTCP:LISTEN` vacío; copia temporal eliminada; repo intacto.

### Browser

- Comprobar con `lsof -nP -iTCP:3301 -sTCP:LISTEN` que el puerto está libre; arrancar un único `python3 -m http.server 3301 --directory .` (o `RUN_SERVE_COMMAND=1 ./init.sh`) y detener solo ese proceso al terminar.
- `curl -sI http://localhost:3301/` → `200 text/html`; `curl -sI http://localhost:3301/styles.css` → `200 text/css`; `curl -sI http://localhost:3301/assets/avatar.jpg` → `200 image/jpeg`; Google Fonts `200`/`304`.
- **390×844 (móvil):**
  - Consola con **0 mensajes/errores**; red sin 4xx/5xx y sin `/favicon.ico`; las peticiones esperadas son documento, Google Fonts CSS, `styles.css`, WOFF2 y `assets/avatar.jpg` (puede haber más de un WOFF2), sin peticiones nuevas del Enlace; sin scroll horizontal (`scrollWidth == clientWidth == 390`).
  - DOM: `.links` antes de `[data-demo="link-button"]`; la demo sigue entre el nav y el pie; el pie sigue siendo el último hijo de `.card`; exactamente un `.link-button` dentro de `.links`.
  - Geometría: tarjeta 358px en `x=16`; nav 356px en `x=17`; Enlace 308×48px en `x=41`.
  - La demo sigue intacta: cinco botones; el primero mide 324×48px en `x=33`, con su radio, tipografía e icono sin cambios.
  - Computed del Enlace: `display:flex`, `height:48px`, `padding:0px 20px`, `border-radius:6px`, `justify-content:space-between`, `font-size:11px`, `font-weight:800`, `line-height:16px`, `letter-spacing:1.98px`, `text-transform:uppercase`, `color:rgb(255,255,255)`, `background-color:rgb(104,118,240)`, sombra normal del componente.
  - Etiqueta a la izquierda; SVG 18×18 a la derecha, a 20px del borde derecho; `aria-hidden="true"` y `focusable="false"`.
  - `href` exacto; sin `target`; nombre accesible contiene `Instagram` (sin distinguir mayúsculas).
  - `Tab` hasta el Enlace → `:focus-visible=true`, outline `rgb(88, 92, 229) solid 2px`, `outline-offset:2px`; no pulsar `Enter` para no abrir Instagram.
  - **No activar** el Enlace externo; comprobar el `href` en el DOM.
- **1280×800 (escritorio):**
  - Consola con 0 mensajes; red sin fallos; sin `/favicon.ico`; sin scroll horizontal (`scrollWidth == clientWidth == 1280`).
  - Tarjeta 400px en `x=440`; nav 398px en `x=441`; Enlace 350×48px en `x=465`; mismos estilos computados y mismo icono.
  - La demo sigue intacta: cinco botones; el primero mide 366×48px en `x=457`, sin cambios.
  - Hover con puntero fino: `transform: matrix(1, 0, 0, 1, 0, -1.5)` (o `translateY(-1.5px)`), `box-shadow` de hover y `filter: brightness(1.03)`.
  - `Tab` → outline de foco visible; no pulsar `Enter` sobre el Enlace real.
- **320×844 (extra recomendado):** nav 286px en `x=17`; Enlace 238×48px en `x=41`; etiqueta e icono completos; `scrollWidth == clientWidth == 320`; consola y red limpias.
- **Reduced motion:** emular `prefers-reduced-motion: reduce`; el Enlace real mantiene `transition-duration:0s` y `transform:none` en hover/foco; el bloque del componente sigue activo.
- **Contraste:** registrar `3.86:1` para `#ffffff` sobre `#6876f0`; no corregir con colores fuera de la paleta; queda para `accessibility-baseline`.
- E2E: no aplica; no existe harness E2E ni framework de tests y añadirlo introduciría dependencias prohibidas por `docs/technical-discovery.md`. La verificación es gate + navegador.

## Evidence To Capture

- Salida de `./init.sh` correcto (exit `0`, checks previos y nuevos) y de los siete casos negativos (exit `1`, stderr correcto, sin listener en 3301).
- `curl -sI` de `/`, `/styles.css` y `/assets/avatar.jpg`; estado de Google Fonts.
- Geometría y estilos computados del nav y del Enlace en 390×844 y 1280×800 (ancho, alto, padding, radio, tipografía, color, fondo, icono).
- Resultado del árbol de accesibilidad: nombre accesible del Enlace y del nav; icono oculto.
- Resultado de `Tab`/`:focus-visible` y hover; resultado de `prefers-reduced-motion`.
- Consola y red de ambos viewports: 0 errores/mensajes, 0 peticiones fallidas, sin `/favicon.ico`, sin scroll horizontal.
- Confirmación de que la demo, el pie, la identidad, el avatar, el `<head>`, `.page`, `.card`, `body`, los 51 tokens y `DESIGN.md` no cambiaron.
- Ratio de contraste 3.86:1 registrado como riesgo heredado.
- Screenshots opcionales de móvil y escritorio.
- `feature_list.json` (`status: passing`, `evidence`) y `PROGRESS.md` actualizados; ninguna otra feature modificada.

## Risks And Mitigations

- **Falso positivo por el enlace del pie:** el pie ya contiene `https://www.instagram.com/fahedhermoza/`. Mitigación: el gate extrae y evalúa solo `<nav class="links">`; nunca usa un `grep` global del `href`.
- **Falso positivo por los cinco botones de demo:** la demo también usa `.link-button`. Mitigación: contar los `.link-button` solo dentro del nav y verificar la demo por separado.
- **Demo eliminada por error:** la restricción explícita de esta feature exige conservarla, aunque notas previas de `link-button-component` pedían retirarla al integrar los Enlaces. Mitigación: check de demo preservada + comparación con `HEAD` en el navegador/validator + nota en la evidencia de `link-instagram` indicando que la retirada se difiere.
- **Gate textual (`grep`/`awk`):** puede dar falsos positivos si se comentan declaraciones. Mitigación: mantener el patrón existente y validar el comportamiento real en navegador; el validator debe revisar también el DOM.
- **El Enlace real abre un sitio externo:** activarlo en la automatización generaría tráfico y abriría apps. Mitigación: verificar `href`, `target` y nombre accesible en el DOM; no pulsar `Enter`/click sobre el Enlace real.
- **Contraste AA heredado:** blanco sobre `#6876f0` mide 3.86:1. Mitigación: no cambiar tokens ni colores en esta feature; el riesgo ya está asignado a `accessibility-baseline`.
- **Diferencia de padding con la demo:** `.links` usa 24px y la demo temporal usa 16px. Mitigación: es intencional para alinear con identidad y pie; la demo es temporal y su retirada no cambia el contrato del Enlace.
- **Puerto 3301 ocupado:** puede haber un listener previo. Mitigación: comprobar con `lsof`; usar 3301 si está libre y detener solo el proceso propio; no cambiar de puerto en silencio.
- **Nombre accesible en mayúsculas:** `text-transform: uppercase` puede hacer que el árbol de accesibilidad exponga `INSTAGRAM`. Mitigación: comprobar el nombre sin distinguir mayúsculas; no añadir `aria-label` innecesario.
- **Alcance del degradado:** usar el tono base por defecto podría confundirse con la asignación final. Mitigación: documentar que `links-order-gradient` posee la asignación de tonos y el orden; este feature no añade modificadores.

## Acceptance Criteria

- [ ] Existe `<nav class="links" aria-label="Enlaces de contacto">` dentro de `.card`, después de la identidad y antes de la demo, con exactamente un Enlace real de Instagram.
- [ ] El Enlace usa `class="link-button"` sin modificador de gradiente, mide 48px, ocupa el ancho interior del nav y muestra `Instagram` a la izquierda y el SVG de Instagram 18×18 a la derecha.
- [ ] El `href` es exactamente `https://www.instagram.com/fahedhermoza/`; no hay `target` ni `rel`; el nombre accesible contiene `Instagram`.
- [ ] El SVG tiene `currentColor`, `width="18"`, `height="18"`, `aria-hidden="true"` y `focusable="false"`; no genera peticiones.
- [ ] La demo `[data-demo="link-button"]` conserva sus cinco anclas y su CSS; el pie, la identidad, el avatar, el `<head>`, `.page`, `.card`, `body` y los 51 tokens no cambian.
- [ ] `.links` solo añade `padding: 0 var(--space-lg);`; no se decide el orden ni la progresión de los siete Enlaces.
- [ ] `./init.sh` pasa (exit `0`), conserva todos los checks previos y añade los checks del Enlace y de la demo; los siete casos negativos fallan con exit `1` y sin servidor.
- [ ] Navegador 390×844 y 1280×800: 0 errores/mensajes de consola, 0 peticiones fallidas, sin `/favicon.ico`, sin scroll horizontal; geometría y estilos computados coinciden.
- [ ] Foco visible y hover heredados del componente; reduced motion desactiva transición y transformación; no se activa el enlace externo.
- [ ] Contraste 3.86:1 registrado como riesgo heredado; no se modifican tokens ni `DESIGN.md`.
- [ ] `feature_list.json` queda en `passing` con evidencia y `PROGRESS.md` actualizado; `link-instagram` no se marca `accepted`.
- [ ] No se implementó ninguna otra feature, asset, dependencia, JavaScript ni archivo de producto nuevo.

## Validator Checklist

- [ ] El implementador se limitó a `link-instagram`; no implementó los otros Enlaces, el orden, el degradado global, la vCard ni retiró la demo.
- [ ] El Enlace está dentro de `.links`, después de la identidad y antes de la demo; el pie sigue siendo el último hijo de `.card`.
- [ ] El `href` y la etiqueta `Instagram` son los esperados; el nombre accesible contiene `Instagram`.
- [ ] El Enlace usa el componente `.link-button` sin modificador y el SVG cumple `18×18`, `currentColor`, `aria-hidden="true"` y `focusable="false"`.
- [ ] La demo, el pie, la identidad, el avatar, el `<head>`, `.page`, `.card`, `body`, los 51 tokens y `DESIGN.md` están intactos.
- [ ] `./init.sh` pasa, conserva los checks previos y falla ante los siete casos negativos sin arrancar servidor.
- [ ] El check está anclado al nav y no se satisface con el enlace de Instagram del pie.
- [ ] La verificación en navegador 390×844 y 1280×800 se ejecutó en el puerto 3301, con 0 errores de consola, 0 peticiones fallidas, sin `/favicon.ico` y sin scroll horizontal.
- [ ] La geometría, los estilos computados, el foco, el hover y `prefers-reduced-motion` coinciden con el contrato.
- [ ] No se activó el enlace externo durante la automatización.
- [ ] El contraste 3.86:1 está registrado como riesgo heredado y no se introdujeron colores fuera de la paleta.
- [ ] `feature_list.json` y `PROGRESS.md` están actualizados correctamente; `docs/validations/link-instagram.md` se crea solo en la validación.

## Assumptions And Open Questions

### Assumptions

- **Un solo Enlace nuevo:** la región `.links` contiene un único `<a class="link-button">`; el enlace del pie no cuenta y no se modifica.
- **Ubicación:** el nav se coloca después de `.profile-identity` y antes de la demo; así el Enlace ocupa la posición prevista del bloque de Enlaces y la demo temporal queda debajo.
- **Etiqueta:** el texto visible es `Instagram`, coherente con `docs/build-brief.md` y `CONTEXT.md`.
- **Tono:** el Enlace usa el fallback del componente (`--color-gradient-1`) sin modificador; la asignación de tonos y el orden de los siete Enlaces son de `links-order-gradient`.
- **Contenedor:** `.links` con padding horizontal `var(--space-lg)` (24px) para alinear con identidad y pie; no se implementa flex/gap.
- **Demo:** se conserva íntegra por restricción explícita de esta feature; la nota previa que pedía retirarla al integrar los Enlaces queda superada y la retirada se difiere a una feature posterior.
- **Puerto:** 3301 está libre en este worktree; si está ocupado, se comprueba con `lsof` y se decide sin cambiar de puerto en silencio.
- `1rem = 16px`; por eso `space-lg = 24px` y `space-sm = 12px`.
- No se activa el enlace externo en la automatización; la corrección se comprueba por `href` y árbol de accesibilidad.
- No hay E2E ni framework de tests; añadirlo introduciría dependencias prohibidas.

### Open Questions

- **Orden y tono finales:** ¿el Enlace de Instagram conservará el tono base o recibirá un modificador concreto? Lo decide `links-order-gradient`; no bloquea este feature.
- **Retirada de la demo:** la restricción actual exige conservarla; queda pendiente definir en qué feature posterior se retira junto con su CSS. No bloquea.
- **Contraste AA:** el 3.86:1 de la etiqueta blanca sobre `#6876f0` sigue siendo un riesgo heredado de `accessibility-baseline`; este feature no lo corrige.
- **Duplicidad con el pie:** el pie mantiene otro enlace a Instagram con la misma URL. Es intencional (destino del Handle) y no se modifica; si el propietario quiere evitar la duplicidad, se decide en otra feature.
