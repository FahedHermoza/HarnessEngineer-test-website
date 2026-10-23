# Feature Implementation Spec: Enlace a WhatsApp

## Source Feature

- `id`: `link-whatsapp`
- `area`: `links`
- `depends_on`: `["link-button-component"]` (accepted)
- `status`: `not_started`
- `source`: `feature_list.json`
- `notes`: URL confirmada por `docs/technical-discovery.md` > Integrations: `https://wa.me/51955116562`. La demo temporal `[data-demo="link-button"]` debe conservarse intacta.

## Goal

Añadir el primer Enlace real de la Tarjeta digital: un botón `WhatsApp` que use el componente existente `.link-button`, con un icono SVG inline de WhatsApp y un destino exacto `https://wa.me/51955116562`. Al pulsarlo en un móvil debe abrir WhatsApp con el chat del número `+51 955 116 562`.

El alcance termina cuando el Enlace existe dentro de la tarjeta, el componente y la demo temporal siguen intactos, `./init.sh` valida de forma no bloqueante el contrato del Enlace, y la página se verifica en navegador en móvil y escritorio sin errores de consola ni peticiones fallidas.

## Non-Goals

- No implementar el orden de los siete Enlaces ni la progresión/interpolación del degradado (`links-order-gradient`).
- No añadir los demás Enlaces (`link-instagram`, `link-facebook`, `link-linkedin`, `link-portafolio`, `link-correo`, `link-celular`).
- No retirar ni modificar la demo temporal `[data-demo="link-button"]` ni su CSS; se conserva explícitamente.
- No modificar la regla base `.link-button`, sus cinco modificadores de tono ni los 51 tokens de `:root`.
- No introducir el verde de marca de WhatsApp ni colores fuera de la paleta de `DESIGN.md`.
- No añadir JavaScript, frameworks, bundlers, preprocesadores, npm, dependencias, imágenes ni peticiones externas nuevas.
- No implementar `target="_blank"`, analítica, `rel` especial, `:active`, modo oscuro, `forced-colors` ni vCard.
- No cambiar el page shell, el avatar, el Perfil, el pie, la identidad ni los metadatos Open Graph.
- No modificar `DESIGN.md` ni `CONTEXT.md`.

## Job Story

When estoy viendo la Tarjeta digital en mi teléfono,
I want to pulsar un botón claro de WhatsApp,
so I can iniciar una conversación con Fahed en el número correcto sin copiar ni buscar el contacto.

## Users And Permissions

- Visitante: ve y pulsa el Enlace; no hay autenticación, roles ni permisos.
- Implementador/agente: añade el markup del Enlace y el contenedor mínimo, extiende el harness y registra evidencia. No implementa orden ni degradado global.
- Validator: comprueba el contrato del Enlace, la no regresión de la demo y la verificación en navegador.

## Acceptance Scenarios

### Scenario 1: El Enlace abre WhatsApp con el número correcto

Given la Tarjeta digital servida en `http://localhost:3303/`,
When el visitante inspecciona o pulsa el botón `WhatsApp`,
Then el control es un `<a>` real cuyo `href` es exactamente `https://wa.me/51955116562`, sin `target` ni JavaScript.

### Scenario 2: Etiqueta visible y nombre accesible

Given el botón renderizado,
When se revisa su árbol de accesibilidad,
Then el nombre accesible es `WhatsApp` (`aria-label="WhatsApp"`), la etiqueta visible es `WhatsApp` (renderizada en mayúsculas por CSS) y el icono es decorativo (`aria-hidden="true"`).

### Scenario 3: Reutiliza el componente existente

Given el componente `.link-button` aceptado,
When se renderiza el Enlace real,
Then usa `class="link-button link-button--gradient-1"`, conserva las medidas y estados del componente (48px de alto, ancho completo del contenedor, radio 6px, etiqueta 11px/800, icono 18×18 a la derecha) y no requiere cambios en `.link-button`.

### Scenario 4: La demo temporal sigue intacta

Given la demo `[data-demo="link-button"]` con cinco anclas,
When se implementa este feature,
Then la demo conserva sus cinco botones, sus etiquetas `Enlace uno`…`Enlace cinco`, sus tonos 1…5, sus `href="#link-button-demo"`, su icono chevron y su bloque CSS `[data-demo="link-button"]` sin cambios.

### Scenario 5: Sin regresión visual ni de layout

Given los viewports 390×844 y 1280×800,
When se carga la página,
Then no hay scroll horizontal, el Enlace real ocupa el ancho disponible dentro de la tarjeta, la consola tiene 0 mensajes y todas las peticiones de la página son exitosas (sin `/favicon.ico`).

### Scenario 6: Harness verificable

Given el repositorio en el estado actual,
When se ejecuta `./init.sh`,
Then sale `0` sin arrancar servidor, conserva todos los checks previos y añade los checks del Enlace real.

## Repository Research

### Files Inspected

- `AGENTS.md` — workflow, alcance por feature, Definition of Done y validación móvil/escritorio.
- `PROGRESS.md` — estado verificado: `static-bootstrap`, `design-tokens`, `page-shell`, `link-button-component`, `profile-avatar`, `page-footer`, `profile-identity` y `open-graph-metadata` en `accepted`; `link-whatsapp` es dependency-ready.
- `feature_list.json` — metadata, dependencia `link-button-component`, verificación y nota de URL pendiente de confirmar.
- `CONTEXT.md` — vocabulario: `Enlace`, `WhatsApp` (no "wp") y número `+51 955 116 562`.
- `DESIGN.md` — `components.button-link`, cinco tonos `gradient-1`…`gradient-5`, iconos en blanco, baseline de accesibilidad; no define un color de marca de WhatsApp.
- `docs/technical-discovery.md` — sitio estático sin build, iconos SVG inline, integración WhatsApp `https://wa.me/51955116562`.
- `docs/risks-and-open-questions.md` — pregunta abierta sobre `wa.me` vs `api.whatsapp.com`; riesgo heredado de contraste de etiquetas.
- `docs/specs/link-button-component.md` — contrato del componente, demo temporal y convención de que cada feature `link-*` aporta su SVG de marca.
- `index.html` — estructura actual: `.page` > `.card` > avatar, identidad, demo temporal y pie.
- `styles.css` — 51 tokens, page shell, perfil, `.link-button`, pie y bloque temporal `[data-demo="link-button"]`.
- `init.sh` — gate no bloqueante con checks de bootstrap, tokens, componente, page shell, avatar, pie, identidad y metadatos; puerto impreso actual `3201`.
- `git status` / `git branch` — worktree limpio en `feature/link-whatsapp`.

### Existing Patterns To Follow

- Un único `index.html` y `styles.css` raíz; sin build ni imports.
- Tokens como custom properties en `:root`; las variables internas de componente no se añaden a `:root`.
- Clases BEM-ish: `.link-button`, `.link-button__label`, `.link-button__icon`, `.link-button--gradient-N`.
- La demo temporal usa el hook `[data-demo="link-button"]`; no es una clase de producto.
- `init.sh` con `set -euo pipefail`, fallos a stderr, exit `1`, sin servidor por defecto y con `RUN_SERVE_COMMAND=1` opcional.
- Evidencia durable en `feature_list.json` (`status` + `evidence`) y `PROGRESS.md`.

### Current Gaps

- No existe ningún Enlace real ni contenedor de Enlaces; solo la demo.
- No existe una sección estable donde las futuras features `link-*` añadan sus botones.
- No hay framework de tests, linter ni comando E2E; la verificación es harness + navegador.
- La apertura real de la app WhatsApp no puede automatizarse en este repositorio ni sin un dispositivo.

## Technical Approach

### 1. Decisión de tono

`DESIGN.md` no define un tono de marca para WhatsApp y prohíbe colores fuera de la paleta. Los cinco modificadores existentes son una secuencia posicional lavanda→violeta, no colores de marca. Por tanto:

- Usar el modificador existente `link-button--gradient-1` (`--color-gradient-1`, `#6876f0`) como tono provisional y seguro por defecto.
- No usar `gradient-3` aunque WhatsApp sea el tercer Enlace del orden final: asignar el tono por posición implementaría parte de `links-order-gradient`, que está fuera de alcance.
- No añadir tokens, verde de marca ni estilos nuevos de botón. `links-order-gradient` reasignará el tono final.

### 2. Contenedor de Enlaces

Añadir un contenedor mínimo y estable para los Enlaces reales, separado de la demo temporal:

```html
<section id="links" class="links" aria-label="Enlaces">
  <!-- Enlace real de WhatsApp -->
</section>
```

- Colocarlo después del bloque `header.profile-identity` y antes del comentario de la demo temporal.
- La demo `[data-demo="link-button"]` permanece después de `.links`, sin cambios.
- `.links` es solo presentacional: no define orden, no usa `nth-child`, no asigna tonos y no contiene lógica de degradado.
- Las futuras features `link-*` deben añadir sus botones como hijos de este único `.links`; no deben crear contenedores duplicados.
- No se añade `role` ni `aria-labelledby`; `section` con `aria-label` ya expone una región accesible.

CSS nuevo, bajo un comentario de sección y antes del bloque temporal de demo:

```css
/* Components — Links section (real Enlaces; order/gradient owned by links-order-gradient) */
.links {
  display: flex;
  flex-direction: column;
  gap: var(--space-sm);
  padding: 0 var(--space-gutter);
  margin: 0;
  box-sizing: border-box;
}
```

No se modifica ninguna regla existente.

### 3. Markup exacto del Enlace

```html
<a class="link-button link-button--gradient-1" href="https://wa.me/51955116562" aria-label="WhatsApp">
  <span class="link-button__label">WhatsApp</span>
  <svg class="link-button__icon" viewBox="0 0 24 24" width="18" height="18" fill="currentColor" aria-hidden="true" focusable="false">
    <path d="M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.884-9.885 9.884m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413Z"/>
  </svg>
</a>
```

- `href` debe ser exactamente `https://wa.me/51955116562`; sin parámetros, sin `?text=`, sin `api.whatsapp.com`.
- Sin `target="_blank"`: la navegación en la misma pestaña permite el handoff a la app en móvil y evita pestañas huérfanas.
- `aria-label="WhatsApp"` fija el nombre accesible exacto; coincide con la etiqueta visible `WhatsApp` (WCAG 2.5.3 Label in Name, comparación sin distinguir mayúsculas).
- El SVG es decorativo (`aria-hidden="true"`, `focusable="false"`), usa `fill="currentColor"` (blanco heredado de `.link-button`) y un glifo estándar de WhatsApp en `viewBox="0 0 24 24"`; no se carga ninguna dependencia ni imagen.
- No se usa `title` ni texto alternativo en el SVG: el nombre accesible lo aporta el ancla.

### 4. Geometría esperada

Con `.links` y el componente existentes:

| Viewport | Tarjeta | `.links` content | Enlace real |
| --- | --- | --- | --- |
| 390×844 | 358px en x=16 | 324px en x=33 | 324×48 |
| 1280×800 | 400px en x=440 | 366px en x=457 | 366×48 |

El Enlace real debe compartir fondo `rgb(104, 118, 240)` (`gradient-1`), etiqueta blanca 11px/800 con tracking `1.98px`, icono 18×18 a la derecha y los estados hover/focus ya definidos por `.link-button`.

### 5. Harness / `init.sh`

Añadir una sección `Link checks:` después de los checks existentes, sin quitarlos ni debilitarlos:

- Comprobar el markup exacto del Enlace real: apertura `<a class="link-button link-button--gradient-1" href="https://wa.me/51955116562" aria-label="WhatsApp">` y etiqueta visible `>WhatsApp<`.
- Extraer el bloque del ancla de WhatsApp con `awk` (desde la línea que contiene `href="https://wa.me/51955116562"` hasta `</a>`) y comprobar que el icono tiene `class="link-button__icon"`, `width="18"`, `height="18"`, `fill="currentColor"`, `aria-hidden="true"` y `focusable="false"`.
- Extraer la regla base `.links` con `awk` y comprobar `display: flex;`, `flex-direction: column;`, `gap: var(--space-sm);`, `padding: 0 var(--space-gutter);`.
- Imprimir `[ok] whatsapp link markup`, `[ok] whatsapp icon contract (6/6)` y `[ok] links section contract (4/4)`; en fallo, mensaje a stderr con el dato faltante y exit `1`.
- No comprobar la demo en `init.sh`: es temporal y su retirada futura no debe romper el harness. La preservación se verifica como scope guard de esta feature.
- Actualizar el comando impreso y el `exec` bajo `RUN_SERVE_COMMAND` para usar `3303` en lugar de `3201`, de modo que el harness y la verificación de esta feature coincidan. `./init.sh` sigue sin arrancar servidor por defecto.

### 6. Cierre

- Registrar evidencia en `feature_list.json` (`status: passing` + `evidence`) y `PROGRESS.md`.
- Actualizar `docs/risks-and-open-questions.md`: marcar el formato de WhatsApp como resuelto (`wa.me`) y registrar que el handoff real a la app solo se comprueba manualmente en un dispositivo.
- El validator crea `docs/validations/link-whatsapp.md` y mueve la feature a `accepted`.

## Expected File Changes

- `index.html` — modificar; añadir `section#links.links` con el Enlace real de WhatsApp entre identidad y demo.
- `styles.css` — modificar; añadir solo la regla `.links` antes del bloque de demo. No tocar `.link-button` ni la demo.
- `init.sh` — modificar; añadir `Link checks:` y cambiar el puerto sugerido/`RUN_SERVE_COMMAND` a `3303`.
- `feature_list.json` — modificar; `status` + `evidence` (implementador).
- `PROGRESS.md` — modificar; estado verificado + bitácora (implementador).
- `docs/risks-and-open-questions.md` — modificar; resolver la pregunta de formato y anotar el límite de verificación manual.
- `docs/specs/link-whatsapp.md` — crear; este spec.
- `docs/validations/link-whatsapp.md` — crear; lo genera el validator.

## Visual Design Impact

- UI involved: yes.
- Design source: `DESIGN.md` > `components.button-link`, `colors`, `typography.button-label`, `rounded.md` y `Accessibility Baseline`.
- Screens or states affected: una sola vista; nuevo Enlace real `WhatsApp` con estados normal, hover y focus-visible; la demo temporal permanece visualmente igual.
- New design artifact required: no — se reutilizan tokens, componente y un modificador de tono existente. No se introduce el verde de WhatsApp ni un color fuera de la paleta.

## Durable Documentation Impact

- `ARCHITECTURE.md`: not needed — no se crean capas, dominios ni boundaries; sigue siendo un sitio estático de una hoja CSS.
- `CONSTRAINTS.md`: not needed — la regla de usar tokens y no colores fuera de paleta ya vive en `DESIGN.md`.
- `AGENTS.md`: not needed — el camino de arranque sigue siendo `./init.sh`; solo se añade un check no bloqueante.
- `CONTEXT.md`: not needed — el vocabulario `Enlace`/`WhatsApp` ya existe y no cambia.
- `docs/technical-discovery.md`: not needed — ya documenta `https://wa.me/51955116562` y los SVG inline.
- `docs/risks-and-open-questions.md`: update — cerrar la pregunta `wa.me` vs `api.whatsapp.com` y registrar el límite del handoff manual.
- `DESIGN.md`: not needed — es fuente de verdad; no define marca de WhatsApp y no se modifica.

## Implementation Plan

1. Añadir `section#links.links` en `index.html` después de `header.profile-identity` y antes de la demo, con el ancla y el SVG de WhatsApp exactos.
2. Añadir la regla `.links` en `styles.css` sin modificar reglas existentes.
3. Extender `init.sh` con `Link checks:` y el puerto `3303`.
4. Ejecutar `./init.sh` y casos negativos en copias temporales.
5. Servir en `3303` y verificar en navegador 390×844 y 1280×800, incluida la preservación de la demo.
6. Registrar evidencia, actualizar `feature_list.json`, `PROGRESS.md` y `docs/risks-and-open-questions.md`.

## Implementation Tasks

- [ ] Añadir `section#links.links[aria-label="Enlaces"]` como hijo de `.card`, después de la identidad y antes de la demo.
- [ ] Añadir el ancla `WhatsApp` con `class="link-button link-button--gradient-1"`, `href="https://wa.me/51955116562"` y `aria-label="WhatsApp"`.
- [ ] Añadir la etiqueta visible `WhatsApp` en `.link-button__label`.
- [ ] Añadir el SVG inline de WhatsApp 18×18, `fill="currentColor"`, `aria-hidden="true"` y `focusable="false"`.
- [ ] Añadir la regla `.links` en `styles.css` (flex column, `gap: var(--space-sm)`, `padding: 0 var(--space-gutter)`, `box-sizing: border-box`) y su comentario de sección.
- [ ] Confirmar que `.link-button`, los cinco modificadores, los 51 tokens, el page shell, el perfil, el pie y la demo quedan intactos.
- [ ] Extender `init.sh` con `Link checks:` (markup del Enlace, contrato del icono y contrato de `.links`) y cambiar el puerto a `3303`.
- [ ] Verificar `bash -n init.sh` y `./init.sh` exit `0` sin servidor.
- [ ] Ejecutar casos negativos en copias temporales: `href` incorrecto, sin `aria-label`, etiqueta visible cambiada, SVG sin `aria-hidden`, regla `.links` ausente; todos deben salir `1` con stderr. Eliminar las copias.
- [ ] Verificar en navegador 390×844 y 1280×800: geometría, nombre accesible, foco, consola 0 mensajes, peticiones exitosas y demo con cinco botones.
- [ ] Verificar el scope guard: 51 tokens, sin `<script>`, sin `package.json`, sin dependencias, sin reglas de orden/`nth-child`.
- [ ] Registrar evidencia en `feature_list.json` y `PROGRESS.md`, y actualizar `docs/risks-and-open-questions.md`.

## Verification Plan

- `bash -n init.sh` — sin errores de sintaxis.
- `./init.sh` — `Harness status: bootstrapped`, todos los checks previos `[ok]`, `[ok] whatsapp link markup`, `[ok] whatsapp icon contract (6/6)`, `[ok] links section contract (4/4)`, exit `0`, sin servidor.
- Caso negativo 1: copia temporal con `href="https://api.whatsapp.com/send?phone=51955116562"` → exit `1` y stderr del markup de WhatsApp.
- Caso negativo 2: copia temporal sin `aria-label="WhatsApp"` → exit `1`.
- Caso negativo 3: copia temporal con etiqueta visible `Whatsapp` → exit `1`.
- Caso negativo 4: copia temporal con el `aria-hidden` del SVG de WhatsApp eliminado → exit `1` con el icono faltante (la demo no debe satisfacer el check por estar fuera del bloque del ancla).
- Caso negativo 5: copia temporal sin `gap: var(--space-sm);` en `.links` → exit `1` con `links section contract is missing 1 of 4`.
- Servir con `python3 -m http.server 3303 --directory .` y abrir `http://localhost:3303/`; detener solo ese proceso al terminar y dejar el puerto libre.
- **390×844 (móvil):** sin scroll horizontal (`scrollWidth <= clientWidth`); Enlace real 324×48 en x=33; `href` exacto; nombre accesible `WhatsApp`; etiqueta visible; icono 18×18 con `aria-hidden="true"`; fondo `rgb(104, 118, 240)`; foco de teclado con outline `2px` `rgb(88, 92, 229)` y offset `2px`; demo con sus 5 botones y `href="#link-button-demo"`; consola 0 mensajes; 5 peticiones 200 (`/`, Google Fonts CSS, `styles.css`, `assets/avatar.jpg`, WOFF2); sin `/favicon.ico`; sin peticiones 4xx/5xx.
- **1280×800 (escritorio):** Enlace real 366×48 en x=457; mismos estilos, nombre accesible, foco y demo intacta; consola 0 mensajes; red sin fallos; sin scroll horizontal.
- **Conteo de scope:** exactamente 6 elementos `.link-button` en total (1 real + 5 demo); la demo sigue dentro de `[data-demo="link-button"]` y su CSS no cambia.
- **Handoff real:** pulsar en un teléfono real y confirmar que WhatsApp abre el chat de `+51 955 116 562`. No es automatizable en este repo; si no hay dispositivo, registrar la comprobación como pendiente manual, no como fallo del harness.
- **Externo `wa.me`:** no se exige una petición de red a `wa.me` desde la página; un fallo de red externo no cuenta como petición fallida de la Tarjeta digital. La aceptación verificable es el `href` exacto y el comportamiento del navegador.
- E2E: no aplica; el repositorio no tiene harness E2E ni framework de tests. La verificación es `./init.sh` + navegador, coherente con `docs/technical-discovery.md`.

## Evidence To Capture

- Salida de `./init.sh` en estado correcto (exit `0`, checks del Enlace, del icono y de `.links`).
- Salida de los cinco casos negativos (exit `1`, stderr correspondiente).
- Valores del Enlace real en 390×844 y 1280×800: rect, `href`, `aria-label`, texto visible, color de fondo, icono y foco.
- Confirmación de que la demo conserva sus cinco botones y su CSS, y de que el total de `.link-button` es 6.
- Resultado de consola y red en ambos viewports (0 mensajes, peticiones exitosas, sin `/favicon.ico`).
- Scope guard: 51 tokens, sin `<script>`, sin `package.json`, sin dependencias, sin reglas de orden/`nth-child`.
- Resultado del handoff manual en dispositivo, o nota explícita de pendiente manual.
- `feature_list.json` (`status`, `evidence`), `PROGRESS.md` y `docs/risks-and-open-questions.md` actualizados.
- `docs/validations/link-whatsapp.md` creado por el validator.

## Validator Checklist

- [ ] El Enlace es un `<a>` real con `href` exactamente `https://wa.me/51955116562`, sin `target` ni JavaScript.
- [ ] El nombre accesible es `WhatsApp` (`aria-label="WhatsApp"`) y la etiqueta visible es `WhatsApp`.
- [ ] El SVG es un WhatsApp inline de 18×18, `fill="currentColor"`, `aria-hidden="true"` y `focusable="false"`.
- [ ] Se usan `class="link-button link-button--gradient-1"` y no se modificó `.link-button`.
- [ ] No se añadieron tokens, colores de marca, dependencias, frameworks, bundlers ni JavaScript.
- [ ] `.links` es un contenedor mínimo sin orden, `nth-child` ni lógica de degradado.
- [ ] La demo temporal conserva sus cinco botones, etiquetas, tonos, `href` y CSS sin cambios.
- [ ] `./init.sh` sale `0` con los checks nuevos, conserva los previos y no arranca servidor.
- [ ] Los cinco casos negativos fallan con exit `1` y stderr correcto.
- [ ] Verificación en 390×844 y 1280×800 sin errores de consola, sin peticiones fallidas y sin scroll horizontal.
- [ ] El scope guard confirma 51 tokens, 6 `.link-button` (1 real + 5 demo), sin `<script>` y sin `package.json`.
- [ ] `feature_list.json`, `PROGRESS.md` y `docs/risks-and-open-questions.md` están actualizados.
- [ ] No se implementó orden/gradiente, otros Enlaces, vCard ni ninguna otra feature.

## Assumptions And Open Questions

### Assumptions

- `https://wa.me/51955116562` es el formato definitivo; `docs/technical-discovery.md` ya lo lista y `CONTEXT.md` fija el número `+51 955 116 562`.
- `gradient-1` es un tono provisional válido porque `DESIGN.md` no define marca de WhatsApp y el orden/tono final pertenece a `links-order-gradient`.
- La demo temporal se conserva en esta feature; su retirada sigue siendo responsabilidad de una feature posterior de Enlaces/orden, no de `link-whatsapp`.
- La navegación en la misma pestaña es el comportamiento correcto para el handoff móvil; no se necesita `target="_blank"`.
- No hay E2E ni framework de tests; harness + navegador es la verificación adecuada.

### Open Questions

- **Handoff real:** ¿el dispositivo de prueba abre WhatsApp directamente o muestra una página intermedia de `wa.me`? Se comprueba manualmente; no bloquea la aceptación del contrato de markup.
- **Tono final:** ¿`links-order-gradient` reasignará `gradient-1` a otro tono para WhatsApp? Sí, es esperado; esta feature no lo decide.
- **Retirada de la demo:** el contenedor real `.links` ya existe, así que las futuras features deben añadir botones dentro de él y no recrearlo ni tocar la demo.
