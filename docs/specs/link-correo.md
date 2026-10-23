# Feature Implementation Spec: Enlace de Correo

## Source Feature

- `id`: `link-correo`
- `area`: `links`
- `depends_on`: `["link-button-component"]` (accepted)
- `status`: `not_started`
- `source`: `feature_list.json`
- `notes`: URL de `docs/technical-discovery.md` (Integrations): `mailto:fahedhermoza@gmail.com`. El sistema elige la app de correo (`docs/domain-model.md`).

## Goal

Añadir el primer Enlace real de producto, **Correo**, reutilizando el componente `.link-button` ya aceptado. El botón debe ser un `<a href="mailto:fahedhermoza@gmail.com">` con etiqueta visible "Correo", nombre accesible explícito, icono SVG inline de sobre (18×18, decorativo) y el mismo contrato visual de 48px del componente.

El alcance termina cuando el botón real convive con la demo temporal `[data-demo="link-button"]` y el resto de la página sin alterarlos, y `./init.sh` valida de forma no bloqueante el markup y el mínimo layout del Enlace.

## Non-Goals

- No implementar el orden de los siete Enlaces ni la progresión de color (`links-order-gradient`).
- No añadir los otros seis Enlaces (`link-instagram`, `link-facebook`, `link-whatsapp`, `link-linkedin`, `link-portafolio`, `link-celular`).
- No eliminar ni modificar la demo temporal `[data-demo="link-button"]` ni su CSS.
- No modificar Perfil, avatar, identidad, pie, metadatos, page shell ni tokens `:root`.
- No elegir el tono final del botón Correo (en el orden final es el 6.º Enlace); la asignación de tono pertenece a `links-order-gradient`.
- No añadir `target`, `rel`, JS, frameworks, bundlers, preprocesadores, npm ni dependencias.
- No crear assets, iconos de archivo, ni cambiar `DESIGN.md`.
- No implementar la vCard ni la validación de apertura real de una app de correo en dispositivo (queda como comprobación manual).

## Job Story

When un visitante ve la Tarjeta digital en su teléfono y quiere escribir a Fahed,
I want to pulsar un botón claro de "Correo" que abra su app de correo con el destinatario ya escrito,
so I can contactarlo sin copiar ni dictar la dirección.

## Users And Permissions

- Visitante: pulsa el Enlace; el sistema operativo decide la app de correo (`docs/domain-model.md`).
- Propietario/implementador: mantiene la URL en el markup; no hay panel ni autenticación.
- No aplica autorización, sesión ni persistencia.

## Acceptance Scenarios

### Scenario 1: Enlace Correo real y accesible

Given la página servida,
When se inspecciona el primer Enlace de producto,
Then es un `<a class="link-button">` dentro de `<nav class="links" aria-label="Enlaces">`, con `href="mailto:fahedhermoza@gmail.com"`, etiqueta visible `Correo`, `aria-label="Correo a fahedhermoza@gmail.com"` e icono SVG decorativo (`aria-hidden="true"`, `focusable="false"`).

### Scenario 2: Contrato visual del componente

Given el Enlace Correo renderizado,
When se leen sus estilos computados,
Then mide 48px de alto, ocupa el 100% del ancho interior de `.links`, usa `border-radius: 6px`, `padding: 0px 20px`, flex `space-between`, etiqueta 11px/800 en mayúsculas con tracking 1.98px e icono de 18×18 a la derecha.

### Scenario 3: Sin decisión de orden ni degradado

Given que solo existe el Enlace Correo,
When se revisa el markup y el CSS,
Then el ancla no declara ningún modificador `link-button--gradient-*`; usa el fondo por defecto del componente (`--color-gradient-1`) y no se añadió ningún orden, separación entre siete Enlaces ni interpolación de tonos.

### Scenario 4: Demo y página intactas

Given el estado actual aceptado,
When se compara el resultado con `HEAD`,
Then la demo de cinco anclas y su bloque CSS `[data-demo="link-button"]` siguen intactos, y Perfil, identidad, pie, metadatos, `.page`, `.card`, `body` y los 51 tokens no cambian.

### Scenario 5: Harness y navegador

Given una copia limpia del worktree,
When se ejecuta `./init.sh` y se sirve la página,
Then el script sale `0` con los checks del Enlace, y en 390×844 y 1280×800 no hay errores de consola, ni peticiones fallidas, ni scroll horizontal; el nombre accesible y el `href` son correctos.

## Repository Research

### Files Inspected

- `AGENTS.md` — una feature a la vez, validación móvil/escritorio, DoD y `./init.sh` como camino estándar.
- `PROGRESS.md` — `link-button-component`, `page-shell`, `profile-avatar`, `profile-identity`, `page-footer` y `open-graph-metadata` en `accepted`; no hay ningún Enlace real todavía.
- `feature_list.json` — metadata y verificación de `link-correo`; `link-button-component` aceptado satisface la dependencia.
- `docs/build-brief.md` — siete Enlaces; Correo es el 6.º.
- `docs/domain-model.md` — el sistema decide la app de `mailto:`; la página no puede forzarla.
- `docs/technical-discovery.md` — `mailto:fahedhermoza@gmail.com`, SVG inline y cero dependencias.
- `DESIGN.md` — `components.button-link`, `button-label`, `rounded.md`, iconos blancos y baseline de accesibilidad.
- `docs/specs/link-button-component.md` — markup, contrato CSS y nota de que cada `link-*` aporta su SVG real de 18×18.
- `index.html` — `.card` con avatar, identidad, demo temporal, pie; `<head>` con metadatos y `rel="icon"` `data:,`.
- `styles.css` — 51 tokens, `.page`, `.card`, identidad, `.link-button`, pie y demo; sin sección de lista de Enlaces.
- `init.sh` — gate no bloqueante con checks textuales/`awk`, exit `1` a stderr, sin servidor por defecto (`RUN_SERVE_COMMAND=1`).
- `assets/` — solo `avatar.jpg`; no se requieren assets para este feature.

### Existing Patterns To Follow

- Un único `styles.css` raíz, sin imports ni build.
- Markup con clases BEM-ish (`link-button__label`, `link-button__icon`) y SVG inline `currentColor`.
- Gate de `init.sh` con `grep -qF`/`awk` para markup y declaraciones exactas; un bloque por feature, sin debilitar los anteriores.
- Evidencia durable en `feature_list.json` y `PROGRESS.md`; el validator crea `docs/validations/link-correo.md`.
- Servidor único por sesión en un puerto libre; se detiene al terminar.

### Current Gaps

- No existe ningún Enlace real ni contenedor de Enlaces en `.card`; solo la demo.
- No hay harness E2E ni framework de tests; la verificación es `init.sh` + navegador.
- El tono final y el orden de Correo no están decididos hasta `links-order-gradient`.
- La apertura real de una app de correo no es automatizable en este entorno.

## Technical Approach

### 1. Markup del Enlace

Insertar un único `<nav class="links" aria-label="Enlaces">` como hijo de `.card`, **después de** `</header>` de `.profile-identity` y **antes** del comentario/demo temporal. Dentro, un solo ancla con esta forma exacta (una línea para la apertura, para que el gate pueda extraerla):

```html
<nav class="links" aria-label="Enlaces">
  <a class="link-button" href="mailto:fahedhermoza@gmail.com" aria-label="Correo a fahedhermoza@gmail.com">
    <span class="link-button__label">Correo</span>
    <svg class="link-button__icon" viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false">
      <rect x="3" y="5" width="18" height="14" rx="2"/>
      <path d="m3 7 9 6 9-6"/>
    </svg>
  </a>
</nav>
```

- Sin modificador `link-button--gradient-*`: el componente aplica su fallback `--color-gradient-1` hasta que `links-order-gradient` asigne la progresión. Esto evita decidir el tono del 6.º Enlace en esta feature.
- Sin `target` ni `rel`: `mailto:` se abre en la app del sistema.
- `aria-label` justificado: el destino del correo no es visible en el botón. Incluye la palabra visible "Correo" para cumplir WCAG 2.5.3 (Label in Name), aunque el componente normalmente use la etiqueta visible como nombre accesible.
- El SVG es decorativo; el nombre accesible viene del `aria-label`.

### 2. CSS mínimo del contenedor

Añadir en `styles.css`, antes del bloque de demo, una sección corta:

```css
/* Components — Links list (un solo Enlace; orden/degradado en links-order-gradient) */
.links {
  padding: 0 var(--space-gutter);
}
```

- Solo aporta el inset horizontal para que el botón no toque el borde de la tarjeta. No añade `gap`, orden, flex de lista ni tonos: eso pertenece a `links-order-gradient`.
- El ancla mide 48px y ocupa el 100% del ancho interior de `.links` (324px en 390×844; 366px en 1280×800, igual que los botones de la demo).
- No se toca el bloque `.link-button`, `.profile-identity`, `.page`, `.card`, `body`, `:root` ni `[data-demo="link-button"]`.

### 3. Preservación de la demo

La demo `[data-demo="link-button"]` y su CSS se mantienen sin cambios y siguen visibles después del Enlace Correo. Su retirada no es parte de esta feature; queda para `links-order-gradient` o una feature explícita que la justifique. No se renombra, no se oculta y no se le cambian los `href` de fragmento.

### 4. Harness (`init.sh`)

Añadir un bloque `Link Correo checks:` después de los checks de identidad y antes de los de metadatos, sin quitar ni debilitar checks previos:

- Extraer el ancla real con `awk` usando la línea de apertura exacta (no debe coincidir con la demo, que usa `class="link-button link-button--gradient-N" href="#link-button-demo"`).
- Si no se encuentra, `fail` con stderr y exit `1`.
- Validar el contrato del ancla (todas presentes o fallo acumulado):
  `class="link-button"`, `href="mailto:fahedhermoza@gmail.com"`, `aria-label="Correo a fahedhermoza@gmail.com"`, `<span class="link-button__label">Correo</span>`, `class="link-button__icon"`, `aria-hidden="true"`, `focusable="false"`.
- Validar el contenedor: existe `<nav class="links" aria-label="Enlaces">` y la regla `.links` contiene `padding: 0 var(--space-gutter);`.
- Imprimir `[ok] link Correo contract (N/N)` y `[ok] links list rule`; en fallo, mensaje a stderr con el elemento/declaración que falta.
- No comprobar la demo, el orden, el tono ni URLs de otros Enlaces.
- Mantener el comportamiento no bloqueante: sin servidor salvo `RUN_SERVE_COMMAND=1`; ningún camino de fallo debe abrir un listener.

## Expected File Changes

- `index.html` — modificar; añadir `<nav class="links">` con el ancla Correo entre identidad y demo.
- `styles.css` — modificar; añadir la regla `.links` (padding lateral) antes del bloque de demo.
- `init.sh` — modificar; añadir `Link Correo checks:` sin alterar los checks existentes.
- `feature_list.json` — modificar; `status: passing` + evidencia (implementador).
- `PROGRESS.md` — modificar; estado verificado + bitácora (implementador).
- `docs/specs/link-correo.md` — crear; este spec.
- `docs/validations/link-correo.md` — crear; lo genera el validator.

## Visual Design Impact

- UI involved: yes.
- Design source: `DESIGN.md` > `components.button-link`, `colors` (on-primary, gradient-1), `typography.button-label`, `rounded.md`, `spacing.gutter`, `Accessibility Baseline`.
- Screens or states affected: una sola vista; estado normal del botón Correo (48px, blanco sobre tono 1), hover/focus heredados del componente. No se crean estados nuevos.
- New design artifact required: no — se reutiliza el componente y sus tokens; el tono final queda pendiente de `links-order-gradient`.

## Durable Documentation Impact

- `ARCHITECTURE.md`: not needed — no cambian capas, dominios ni superficies; sigue siendo un sitio estático de una hoja CSS.
- `CONSTRAINTS.md`: not needed — no se introduce una regla MUST/MUST NOT nueva; se aplican las de `DESIGN.md` y `AGENTS.md`.
- `AGENTS.md`: not needed — el flujo de arranque y las reglas de operación no cambian.
- `docs/technical-discovery.md`: not needed — `mailto:` y los SVG inline ya están documentados.
- `docs/risks-and-open-questions.md`: not needed — el contraste blanco sobre `gradient-1` (3.86:1) ya está registrado para `accessibility-baseline`; no se añade riesgo nuevo.
- `DESIGN.md`: not needed — es fuente de verdad y este feature no la modifica.
- `PROGRESS.md` y `feature_list.json`: update — evidencia y estado de la feature.

## Implementation Plan

1. Añadir el `<nav class="links">` con el ancla Correo y su SVG de sobre en `index.html`, entre identidad y demo.
2. Añadir la regla `.links` en `styles.css` antes del bloque de demo, sin tocar estilos existentes.
3. Extender `init.sh` con el bloque `Link Correo checks:` (ancla + contenedor) y conservar todos los checks previos.
4. Ejecutar `bash -n init.sh` y `./init.sh`; probar casos negativos en copias temporales.
5. Servir en un puerto libre (p. ej. 3205) y verificar 390×844 y 1280×800; detener el servidor.
6. Registrar evidencia en `feature_list.json` y `PROGRESS.md`; el validator crea `docs/validations/link-correo.md`.

## Implementation Tasks

- [ ] Añadir `<nav class="links" aria-label="Enlaces">` como hijo de `.card`, después de `.profile-identity` y antes de la demo.
- [ ] Añadir el ancla `<a class="link-button" href="mailto:fahedhermoza@gmail.com" aria-label="Correo a fahedhermoza@gmail.com">` sin modificador de gradiente.
- [ ] Añadir `<span class="link-button__label">Correo</span>` y el SVG de sobre 18×18 con `aria-hidden="true"` y `focusable="false"`.
- [ ] Añadir la regla `.links { padding: 0 var(--space-gutter); }` en `styles.css` con comentario de sección.
- [ ] Confirmar que demo, pie, perfil, identidad, metadatos, `:root` y `.link-button` no cambian.
- [ ] Añadir `Link Correo checks:` en `init.sh` (ancla + `.links`), sin debilitar checks previos.
- [ ] Verificar `./init.sh` exit `0` y casos negativos (href cambiado, sin `aria-label`, sin etiqueta, sin icono, sin padding) → exit `1`.
- [ ] Verificar en navegador 390×844 y 1280×800: href, nombre accesible, geometría, teclado, consola y red.
- [ ] Registrar evidencia en `feature_list.json` y `PROGRESS.md`.

## Verification Plan

- `bash -n init.sh` — sin errores de sintaxis.
- `./init.sh` — estado bootstrapped, checks previos `[ok]`, `[ok] link Correo contract (N/N)` y `[ok] links list rule`, exit `0`, sin servidor.
- Caso negativo (copias temporales fuera del repo, eliminadas después; repo intacto): cambiar el `href`, quitar `aria-label`, quitar el `<span>` de etiqueta, quitar el `<svg>` o quitar el `padding` de `.links` → exit `1` con stderr del check correspondiente y sin listener.
- Servir con `python3 -m http.server 3205 --directory .` (confirmar puerto libre antes; detener solo ese proceso al terminar; puerto libre después). No usar un puerto ya ocupado por otro proceso.
- **390×844 (móvil):** consola con 0 mensajes; peticiones de la página sin fallos (sin `/favicon.ico`); `scrollWidth == clientWidth == 390`; el ancla Correo mide 324×48 en x=33 (mismo inset que la demo), `border-radius: 6px`, `padding: 0px 20px`, icono 18×18 a la derecha; nombre accesible `Correo a fahedhermoza@gmail.com`; `href` resuelto `mailto:fahedhermoza@gmail.com`.
- **1280×800 (escritorio):** consola con 0 mensajes; peticiones sin fallos; `scrollWidth == clientWidth == 1280`; el ancla mide 366×48 dentro de `.links` (padding 16px por lado), centrada con la tarjeta de 400px; `Tab` produce `:focus-visible` con outline `rgb(88, 92, 229) solid 2px` offset 2px; hover heredado del componente.
- **Accesibilidad:** el nombre accesible es el `aria-label` y contiene la etiqueta visible "Correo"; el SVG no aporta nombre; área táctil 48px de alto por ancho completo.
- **Demo intacta:** 5 anclas con `href="#link-button-demo"` y clase `link-button link-button--gradient-N`; bloque CSS `[data-demo="link-button"]` idéntico a `HEAD`.
- **Integridad:** 0 `<script>`, sin `package.json`/frameworks/bundlers/dependencias nuevas; `:root` con 51 tokens; `git diff --check` limpio.
- **Apertura real de la app de correo:** no es automatizable con seguridad en Chrome DevTools (protocolo externo). Verificar `href` y nombre accesible en navegador; la comprobación en un teléfono real se registra como manual/deferida, coherente con `docs/domain-model.md`.
- E2E: no aplica; el repositorio no tiene harness E2E y añadirlo introduciría dependencias prohibidas.

## Evidence To Capture

- Salida de `bash -n init.sh` y `./init.sh` (exit `0`, checks del Enlace, sin servidor).
- Salida de cada caso negativo (exit `1`, declaración/elemento faltante, sin listener).
- Valores computados del ancla en 390×844 y 1280×800 (rect, padding, radio, tipografía, icono, contenedor).
- Nombre accesible y `href` leídos en el navegador; resultado de consola y red en ambos viewports.
- Confirmación de demo y página intactas (5 anclas, bloque CSS, `:root` 51 tokens, sin JS/dependencias).
- `feature_list.json` (`status: passing`, evidencia) y `PROGRESS.md` actualizados.
- Screenshots opcionales de móvil y escritorio.

## Validator Checklist

- [ ] Existe exactamente un Enlace real Correo, dentro de `<nav class="links">`, con `href="mailto:fahedhermoza@gmail.com"`.
- [ ] La etiqueta visible es "Correo" y el nombre accesible es explícito y la contiene.
- [ ] El SVG es inline, 18×18, `currentColor`, decorativo (`aria-hidden`, `focusable="false"`).
- [ ] El ancla usa `.link-button`, mide 48px, ocupa el 100% del contenedor y hereda el contrato visual sin reimplementarlo.
- [ ] No se añadió ningún modificador de gradiente, orden ni progresión entre Enlaces.
- [ ] La demo `[data-demo="link-button"]` y su CSS siguen intactos; el resto de la página no cambió.
- [ ] `:root` conserva 51 tokens; no hay JS, frameworks, bundlers, dependencias ni assets nuevos.
- [ ] `./init.sh` sale `0` con los checks nuevos y falla correctamente en los casos negativos, sin arrancar servidor.
- [ ] Navegador 390×844 y 1280×800: sin errores de consola, sin peticiones fallidas y sin scroll horizontal.
- [ ] `feature_list.json` y `PROGRESS.md` están actualizados; `docs/validations/link-correo.md` se crea en la validación.
- [ ] No se implementó ninguna otra feature.

## Assumptions And Open Questions

### Assumptions

- **Tono provisional:** el ancla no lleva modificador; el componente aplica `--color-gradient-1`. `links-order-gradient` asignará el tono definitivo (Correo es el 6.º Enlace) y la separación entre botones.
- **Contenedor mínimo:** `.links` se introduce ahora solo para el inset horizontal; no implementa el `gap` ni el orden de la lista final.
- **`aria-label` con destino:** el correo no se muestra dentro del botón; exponerlo en el nombre accesible es útil y cumple Label in Name.
- El puerto 3205 es solo una sugerencia para esta verificación; el mensaje genérico de `init.sh` puede seguir mostrando 3201.

### Open Questions

- **Apertura real de la app:** depende del sistema operativo/dispositivo y no se puede validar de forma fiable en el navegador automatizado. ¿Se acepta la comprobación manual en un teléfono como evidencia complementaria?
- **Retirada de la demo:** sigue pendiente y se decide en `links-order-gradient` o en una feature que la justifique; esta feature la conserva por restricción explícita.
