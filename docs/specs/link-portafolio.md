# Feature Implementation Spec: Enlace al Portafolio

## Source Feature

- `id`: `link-portafolio`
- `area`: `links`
- `depends_on`: `link-button-component` (`accepted`)
- `status`: `not_started` al planificar
- `source`: `feature_list.json`
- `verification` de origen: "Pulsar el botón y confirmar que abre el portafolio correcto."
- `notes` de origen: URL en `docs/technical-discovery.md` (integrations).

## Goal

Añadir a la Tarjeta digital un Enlace real **Portafolio** que abra `https://fahedhermoza.github.io/`. El Enlace debe reutilizar el componente aceptado `.link-button` y el SVG inline tipo chevron que ya usa la demo, con un nombre accesible inequívoco.

La feature añade un único Enlace de producto y el mínimo contenedor necesario para alinearlo con el diseño de la tarjeta. No retira la demo temporal, no reordena Enlaces, no asigna la progresión de tonos y no modifica el resto del page shell, el Perfil ni el pie.

## Non-Goals

- Implementar los otros seis Enlaces (Instagram, Facebook, WhatsApp, LinkedIn, Correo, Celular).
- Definir el orden final de los siete Enlaces o la progresión/reparto del degradado; eso pertenece a `links-order-gradient`.
- Añadir el botón "Guardar contacto", la vCard, metadatos, analítica o JavaScript.
- Retirar o modificar la demo temporal `[data-demo="link-button"]` o su CSS.
- Rediseñar el icono, el componente `.link-button`, los tokens de `:root` o los estados hover/focus/reduced-motion ya aceptados.
- Cambiar `target`, `rel`, el comportamiento de navegación del navegador o añadir una página intermedia.
- Crear un harness E2E, framework de tests, bundler o cualquier dependencia.

## Job Story

Cuando un visitante escanea la Tarjeta digital y quiere conocer el trabajo de Fahed,
quiero pulsar un botón de Portafolio visible y accesible,
para abrir su portafolio profesional sin dictar ni buscar la URL.

## Users And Permissions

- **Visitante:** puede ver y activar el Enlace; no hay autenticación, permisos ni datos de usuario.
- **Propietario/operador:** mantiene la URL hardcodeada en `index.html`; esta feature no crea panel ni CMS.

## Acceptance Scenarios

### Scenario 1: El Enlace abre el portafolio correcto

Given la Tarjeta digital cargada en el navegador
When el visitante pulsa el botón "Portafolio" (clic o `Enter` con teclado)
Then el navegador navega a `https://fahedhermoza.github.io/` en la misma pestaña.

### Scenario 2: Nombre accesible e icono decorativo

Given el Enlace Portafolio renderizado
When se inspecciona su árbol de accesibilidad
Then el nombre accesible del ancla es `Portafolio` a partir de su texto visible, y el SVG inline tiene `aria-hidden="true"` y `focusable="false"` sin aportar nombre.

### Scenario 3: Layout móvil y escritorio

Given la página en 390×844 o 1280×800
When se mide el Enlace
Then mide 48px de alto, ocupa el ancho disponible del contenedor `.links`, la etiqueta queda a la izquierda, el icono 18×18 a la derecha, no hay scroll horizontal y la demo de cinco botones sigue intacta debajo del nuevo Enlace.

### Scenario 4: El gate detecta un Enlace roto

Given una copia temporal del repositorio sin el `href`, sin la etiqueta `Portafolio` o sin la regla `.links`
When se ejecuta `./init.sh`
Then el script imprime un `FAILED - ...` en stderr y sale con código `1`, sin arrancar servidor.

### Scenario 5: Sin errores de consola ni peticiones fallidas

Given la página servida localmente y recargada de forma fresca en 390×844 y 1280×800
When se revisan consola y red
Then hay 0 mensajes de consola, todas las peticiones responden 2xx/3xx y no se solicita `/favicon.ico`.

## Repository Research

### Files Inspected

- `AGENTS.md` — Definition of Done, validación en navegador 390×844 y 1280×800, reglas de alcance y artefactos obligatorios.
- `CONTEXT.md` — vocabulario `Enlace`, `Portafolio`, `Perfil`, `Handle`, `Tagline`, `Contacto`; portafolio es uno de los siete Enlaces.
- `docs/build-brief.md` — el portafolio actual es `fahedhermoza.github.io`; los siete Enlaces y su orden son parte del MVP.
- `docs/domain-model.md` — un Enlace tiene tipo, etiqueta, icono, URL destino y orden; el visitante puede abrir el portafolio y volver.
- `docs/technical-discovery.md` — integración exacta `Portafolio: https://fahedhermoza.github.io/`; SVG inline, sin framework, bundler ni build.
- `DESIGN.md` — ancho completo, alto 48px, padding `0 1.25rem`, flex `space-between`, etiqueta `button-label` en mayúsculas, icono 18px a la derecha, colores por tokens.
- `PROGRESS.md` — estado verificado: `static-bootstrap`, `design-tokens`, `page-shell`, `link-button-component`, `profile-avatar`, `page-footer`, `profile-identity` y `open-graph-metadata` en `accepted`; demo de Enlaces aún temporal.
- `feature_list.json` — `link-portafolio` es `not_started`, depende de `link-button-component` (`accepted`) y su URL está en technical discovery.
- `index.html` — orden actual de hijos de `.card`: `header.profile` (avatar), `header.profile-identity`, demo `section[data-demo="link-button"]` con cinco anclas y `footer.page-footer` como último hijo.
- `styles.css` — 51 tokens en `:root`; bloques `.page`, `.card`, `.profile`, `.profile-avatar`, `.profile-identity`, `.link-button`, `.page-footer` y `[data-demo="link-button"]`; la demo usa `[data-demo]` como hook temporal.
- `init.sh` — gate no bloqueante con `set -euo pipefail`; checks de bootstrap, tokens, componente, page shell, avatar, pie, identidad y metadatos; no arranca servidor salvo `RUN_SERVE_COMMAND=1`.
- `docs/specs/link-button-component.md` — contrato del componente: la etiqueta visible es el nombre accesible; el SVG es decorativo; el componente no decide orden ni degradado global.
- `docs/specs/profile-identity.md` y `docs/specs/page-footer.md` — convenciones de markup, tokens, checks y evidencia que esta feature debe respetar.

### Existing Patterns To Follow

- HTML5 semántico y una única hoja `styles.css`; sin build, sin JS y sin dependencias.
- Tokens de color, tipografía, radio y espaciado existentes; no añadir custom properties a `:root`.
- Clases BEM-ish: `.link-button`, `.link-button__label`, `.link-button__icon`, modificadores `--gradient-N`.
- El componente `.link-button` ya aporta alto 48px, ancho 100%, tipografía, hover, `:focus-visible` y `prefers-reduced-motion`.
- `init.sh` comprueba contratos con `grep`/`awk`, reporta a stderr y nunca inicia procesos largos por defecto.
- Evidencia durable en `feature_list.json` (`status: passing` + `evidence`) y `PROGRESS.md`; el validator crea `docs/validations/link-portafolio.md`.

### Current State And Gaps

- No existe ningún Enlace real de producto; solo la demo temporal de cinco botones.
- No existe contenedor `.links` ni CSS para una lista real de Enlaces.
- `link-instagram`, `link-facebook`, `link-whatsapp` y `link-linkedin` siguen `not_started` antes que esta feature en el listado, pero no son dependencia de `link-portafolio`; esta feature se puede implementar y validar de forma aislada.
- No hay framework de tests ni comando E2E; la verificación es `init.sh` + navegador, según `docs/technical-discovery.md`.

## Technical Approach

### 1. Markup contract

Insertar el nuevo bloque dentro de `<article class="card">`, **después de `</header>` de `.profile-identity` y antes del comentario de la demo temporal**. No mover ni alterar la demo ni el pie.

```html
<nav class="links" aria-label="Enlaces">
  <a class="link-button" href="https://fahedhermoza.github.io/">
    <span class="link-button__label">Portafolio</span>
    <svg class="link-button__icon" viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false">
      <path d="M9 18l6-6-6-6"/>
    </svg>
  </a>
</nav>
```

Decisiones:

- `<nav aria-label="Enlaces">` agrupa los Enlaces accionables y da un landmark nombrado; el contenedor es reutilizable por las futuras features de Enlaces.
- El ancla usa exactamente `class="link-button"`, sin modificador `link-button--gradient-*`: la asignación del tono/posición pertenece a `links-order-gradient`. El componente usa su tono base (`--color-gradient-1`), que ya es parte del contrato aceptado.
- El texto visible `Portafolio` es el nombre accesible. No se añade `aria-label` al ancla porque duplicaría el nombre y contradice el contrato de `link-button-component`.
- El SVG reutiliza el chevron exacto de la demo; es decorativo (`aria-hidden="true"`, `focusable="false"`) y no introduce un icono nuevo.
- `href` usa la URL exacta de `docs/technical-discovery.md`, con esquema HTTPS y barra final.
- No se añaden `target`, `rel`, `id`, `title`, `data-*` ni estilos inline.

### 2. CSS contract

Añadir una sección en `styles.css` después del bloque de `.profile-identity` y antes de `/* Components — Link button ... */`:

```css
/* Components — Links list (DESIGN.md > layout, spacing) */
.links {
  display: flex;
  flex-direction: column;
  gap: var(--space-sm);
  padding: 0 var(--space-lg);
}
```

Rationale:

- `.links` alinea los botones con el padding horizontal de `.profile-identity` (`var(--space-lg)` = 24px) y deja respirar la tarjeta.
- `gap: var(--space-sm)` aplica la separación vertical de 12px que `DESIGN.md` exige entre Enlaces; con un solo Enlace no cambia nada visible, pero deja el contenedor listo para la lista real.
- No se añade `margin-top`: `.profile-identity` ya aporta `padding` inferior `var(--space-xl)`.
- No se modifica `.link-button`, `[data-demo="link-button"]`, `.card`, `.page`, `.profile*`, `.page-footer`, `body` ni `:root`.
- No se añaden reglas `:nth-child`, gradientes por posición, transiciones nuevas ni estilos de orden.

### 3. Accesibilidad

- El ancla es un `<a href>` real, activable con `Enter`, con foco visible heredado de `.link-button:focus-visible`.
- Alto de 48px y ancho completo del contenedor: área táctil ≥44×44px.
- Nombre accesible: `Portafolio` (texto visible). El icono no aporta nombre.
- El contenedor expone el landmark de navegación con nombre `Enlaces`.
- No se corrigen aquí los contrastes heredados de `.link-button` (3.86–4.13:1), que siguen asignados a `accessibility-baseline`.

### 4. Demo y page shell

- La demo `#link-button-demo` y su CSS `[data-demo="link-button"]` permanecen byte a byte sin cambios, después del nuevo `<nav class="links">`.
- El pie sigue siendo el último hijo de `.card`.
- No se retira la demo en esta feature; su retirada queda para una feature posterior de integración de Enlaces.

### 5. Harness / `init.sh`

Ampliar `init.sh` con una sección `Portfolio link checks:` (después de los checks de identidad o al final de los checks de contenido, sin quitar ni debilitar los existentes):

- `[ok] portfolio link container`: existe `<nav class="links" aria-label="Enlaces">`.
- `[ok] portfolio link markup`: existe un `<a class="link-button" href="https://fahedhermoza.github.io/">` con `<span class="link-button__label">Portafolio</span>`.
- `[ok] portfolio link icon`: el SVG del Enlace tiene `class="link-button__icon"`, `aria-hidden="true"`, `focusable="false"` y el path del chevron.
- `[ok] links container contract (4/4)`: la regla `.links` contiene `display: flex;`, `flex-direction: column;`, `gap: var(--space-sm);` y `padding: 0 var(--space-lg);`, extraída con el patrón `awk` existente.
- Cada fallo imprime `FAILED - ...` en stderr y termina con exit `1`; no se debe comprobar la demo, el orden de los siete Enlaces ni los otros Enlaces.
- `./init.sh` sigue sin arrancar servidores por defecto.

### 6. Cierre

- El implementador deja `link-portafolio` en `passing` con evidencia y actualiza `PROGRESS.md`.
- El validator independiente crea `docs/validations/link-portafolio.md` y mueve la feature a `accepted` si corresponde.

## Expected File Changes

- `index.html` — modificar; añadir `<nav class="links">` con el ancla Portafolio y su SVG entre `.profile-identity` y la demo. No tocar `<head>`, demo, pie ni Perfil.
- `styles.css` — modificar; añadir solo la regla `.links`. No tocar `:root`, `body`, `.page`, `.card`, `.profile*`, `.link-button`, `.page-footer` ni `[data-demo]`.
- `init.sh` — modificar; añadir `Portfolio link checks:` no bloqueantes y conservar todos los checks previos.
- `feature_list.json` — modificar; `link-portafolio` a `passing` + `evidence` (implementador); `accepted` (validator).
- `PROGRESS.md` — modificar; estado verificado y bitácora de la sesión.
- `docs/specs/link-portafolio.md` — crear; este spec.
- `docs/validations/link-portafolio.md` — crear; lo genera el validator.
- No se crean assets ni archivos nuevos de producto.

## Visual Design Impact

- UI involved: yes.
- Design source: `DESIGN.md` (`components.button-link`, `Colors`, `Typography.button-label`, `Layout`, `spacing`).
- Screens or states affected: única vista de la Tarjeta digital; Enlace Portafolio en estado normal, hover, focus-visible y movimiento reducido (comportamiento heredado del componente).
- New design artifact required: no — el botón reutiliza el componente aceptado y una regla de contenedor con tokens existentes. No se inventan colores, tipografías, iconos ni tonos.
- La demo de cinco botones se mantiene visible debajo del Enlace real durante esta feature.

## Durable Documentation Impact

- `ARCHITECTURE.md`: not needed — no cambia la arquitectura estática de una página y una hoja CSS.
- `CONSTRAINTS.md`: not needed — no se introduce una regla MUST/MUST NOT nueva; se aplican `DESIGN.md` y las convenciones existentes.
- `AGENTS.md`: not needed — no cambia el workflow, el arranque ni las reglas operativas.
- `DESIGN.md`: not needed — ya define el componente y el espaciado; no se cambia la fuente de verdad.
- `CONTEXT.md`, `docs/build-brief.md`, `docs/domain-model.md`, `docs/technical-discovery.md`: not needed — la URL y el vocabulario ya están documentados.
- `docs/risks-and-open-questions.md`: not needed — no hay riesgo nuevo; los contrastes heredados siguen registrados.

## Implementation Plan

1. Insertar `<nav class="links" aria-label="Enlaces">` con el ancla Portafolio entre `.profile-identity` y la demo, sin tocar el resto de `index.html`.
2. Añadir la regla `.links` en `styles.css` con tokens existentes, sin modificar el componente ni la demo.
3. Ampliar `init.sh` con `Portfolio link checks:` conservando los checks previos.
4. Ejecutar `bash -n init.sh` y `./init.sh`; probar casos negativos en copias temporales fuera del repo.
5. Servir en el puerto **3305** y verificar en navegador 390×844 y 1280×800.
6. Registrar evidencia en `feature_list.json` y `PROGRESS.md`.

## Implementation Tasks

- [ ] Añadir el `<nav class="links" aria-label="Enlaces">` con el ancla `class="link-button"` y `href="https://fahedhermoza.github.io/"` entre la identidad y la demo.
- [ ] Añadir el `<span class="link-button__label">Portafolio</span>` y el SVG chevron decorativo con `aria-hidden="true"` y `focusable="false"`.
- [ ] Añadir la regla `.links` con `display: flex`, `flex-direction: column`, `gap: var(--space-sm)` y `padding: 0 var(--space-lg)`.
- [ ] Verificar que la demo, el pie, el Perfil, `.link-button`, `.page`, `.card`, `body` y `:root` siguen intactos.
- [ ] Añadir `Portfolio link checks:` en `init.sh` sin alterar los checks previos ni arrancar servidor.
- [ ] Ejecutar `bash -n init.sh`, `./init.sh` (exit `0`) y al menos tres casos negativos (href cambiado, etiqueta eliminada, `.links` sin `gap`) con exit `1`.
- [ ] Verificar en 390×844 y 1280×800: geometría, etiqueta/icono, foco, demo intacta, consola y red limpias, sin scroll horizontal.
- [ ] Registrar evidencia en `feature_list.json` y `PROGRESS.md`; dejar `link-portafolio` en `passing`.

## Verification Plan

### Gate

- `bash -n init.sh` → sin errores de sintaxis.
- `./init.sh` → `Harness status: bootstrapped (static site detected)`, todos los checks previos `[ok]`, nuevos checks de Portafolio `[ok]`, exit `0`, sin servidor.
- Casos negativos en copias temporales fuera del repo (repo intacto):
  - URL cambiada a `https://example.com/` → exit `1` con `FAILED - ...` de destino.
  - Texto `Portafolio` eliminado → exit `1` con `FAILED - ...` de etiqueta.
  - `gap: var(--space-sm);` eliminado de `.links` → exit `1` con `FAILED - ...` de contrato.
  - Ningún caso debe arrancar un listener.

### Browser

- Servir una sola vez con `python3 -m http.server 3305 --directory .` y detener solo ese proceso al terminar.
- **390×844:** Enlace Portafolio de 48px de alto, etiqueta a la izquierda, icono 18×18 a la derecha, sin scroll horizontal (`scrollWidth === clientWidth`). Medir ancho esperado ≈308px (tarjeta 358px, borde 1px, padding 24px por lado); tolerar diferencias subpíxel.
- **1280×800:** Enlace de 48px de alto y ancho ≈350px (tarjeta 400px, borde 1px, padding 24px por lado), centrado en la tarjeta; sin scroll horizontal.
- **320×844 (extra):** sin overflow; la etiqueta y el icono caben o la etiqueta usa ellipsis sin romper el layout.
- Confirmar que la demo sigue justo debajo con sus cinco botones y que el pie sigue siendo el último hijo de `.card`.
- Confirmar que el ancla resuelve a `https://fahedhermoza.github.io/`; para la verificación de "abre el portafolio correcto", activarla y comprobar la URL de destino (si la red externa no está disponible, registrar el `href` exacto y un `curl -sI https://fahedhermoza.github.io/` como evidencia complementaria, sin marcarlo como fallo de la feature).
- Teclado: `Tab` hasta el Enlace Portafolio → `:focus-visible` con outline `2px solid rgb(88, 92, 229)` y offset 2px; `Enter` activa el destino.
- `prefers-reduced-motion: reduce`: el Enlace hereda `transition-duration: 0s` y `transform: none`.
- Consola: 0 mensajes en ambos viewports. Red: todas las peticiones 2xx/3xx, sin `/favicon.ico`.
- E2E: no aplica; el repositorio no tiene harness E2E y añadirlo introduciría dependencias prohibidas. La cobertura es `init.sh` + verificación de navegador.

## Evidence To Capture

- Salida de `./init.sh` con exit `0` y los nuevos checks `[ok]`.
- Salida de los tres casos negativos con exit `1` y el mensaje `FAILED - ...` correspondiente.
- Medidas computadas del Enlace en 390×844 y 1280×800 (alto, ancho, padding, icono, etiqueta) y ausencia de scroll horizontal.
- Resultado del árbol de accesibilidad: nombre `Portafolio`, SVG `aria-hidden="true"`/`focusable="false"`.
- `href` exacto y resultado de la activación/`curl` del destino.
- Confirmación de demo intacta (5 botones), pie último hijo, `:root` con 51 tokens, 0 `<script>`, sin dependencias nuevas.
- Resultado de consola y red en ambos viewports.
- Registro en `feature_list.json` (`status: passing` + `evidence`) y `PROGRESS.md`.

## Validator Checklist

- [ ] El implementador se limitó a `link-portafolio`; no implementó los otros Enlaces, orden, degradado, vCard, accesibilidad global ni retiró la demo.
- [ ] Existe `<nav class="links" aria-label="Enlaces">` entre `.profile-identity` y la demo, con un único ancla `class="link-button"` y `href="https://fahedhermoza.github.io/"`.
- [ ] La etiqueta visible es `Portafolio` y el nombre accesible del ancla es `Portafolio`; no hay `aria-label` redundante en el ancla.
- [ ] El SVG es el chevron inline, mide 18×18 y tiene `aria-hidden="true"` y `focusable="false"`.
- [ ] No se añadió ningún modificador `link-button--gradient-*` ni lógica de orden/progresión.
- [ ] `.links` existe con `display: flex`, `flex-direction: column`, `gap: var(--space-sm)` y `padding: 0 var(--space-lg)`, usando solo tokens existentes.
- [ ] La demo `[data-demo="link-button"]`, su CSS, el pie, el Perfil, `.link-button`, `.page`, `.card`, `body` y `:root` (51 tokens) están intactos.
- [ ] `bash -n init.sh` y `./init.sh` pasan con exit `0` sin arrancar servidor; los casos negativos fallan con exit `1` y stderr.
- [ ] Navegador 390×844 y 1280×800: 0 mensajes de consola, todas las peticiones exitosas, sin `/favicon.ico`, sin scroll horizontal; demo y pie intactos.
- [ ] El destino se verificó (activación o `curl` complementario) y la evidencia quedó registrada.
- [ ] No hay `<script>`, `package.json`, frameworks, bundlers, dependencias ni assets nuevos.
- [ ] `feature_list.json` y `PROGRESS.md` están actualizados; `docs/validations/link-portafolio.md` se crea solo en la validación.

## Assumptions And Open Questions

### Assumptions

- El nombre accesible se deriva del texto visible `Portafolio`; no se usa `aria-label` en el ancla, siguiendo el contrato de `link-button-component`.
- El tono del Enlace queda en el fallback base del componente; la secuencia de tonos y el orden de los siete Enlaces pertenecen a `links-order-gradient`.
- El Enlace abre en la misma pestaña, coherente con los enlaces externos del pie; no se añade `target="_blank"` sin una decisión de producto.
- La estructura `<nav class="links">` es el contenedor que las futuras features de Enlaces pueden reutilizar; esta feature no implementa la lista completa.
- La URL `https://fahedhermoza.github.io/` es la vigente según `docs/technical-discovery.md`; si cambia, es un cambio de un atributo.

### Open Questions

- Ninguna bloqueante para esta feature.
- Si el propietario prefiere abrir el portafolio en una pestaña nueva, sería un cambio posterior de un atributo (`target` + `rel`), fuera de este alcance.
