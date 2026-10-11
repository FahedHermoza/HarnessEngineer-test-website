# Feature Implementation Spec: Tokens visuales de Serene Bio Card como CSS custom properties

## Source Feature

- `id`: `design-tokens`
- `area`: `design-system`
- `depends_on`: `["static-bootstrap"]`
- `status`: `not_started`
- `source`: `feature_list.json`
- `notes`: Fuente de verdad de diseño: `DESIGN.md` (secciones `colors`, `typography`, `rounded`, `spacing`).

## Goal

Instalar la capa de tokens visuales del sistema "Serene Bio Card" como variables CSS reutilizables, de modo que toda feature posterior (layout, componentes, enlaces, pie) consuma valores de diseño sin volver a `DESIGN.md` ni hardcodear colores, tipografía, radios o espaciados.

El alcance termina cuando existe una hoja de estilos con cada token de `DESIGN.md` (colores, tipografía, radios, espaciado) declarado como custom property en `:root`, el documento la enlaza, y el propio documento ya aplica los tokens de fondo, texto principal y familia tipográfica. Con esto, la comprobación "fondo y texto principal usan los colores definidos" es observable en el navegador.

## Non-Goals

- No implementar layout, tarjeta, perfil, avatar, botones, enlaces, pie ni metadatos (features posteriores: `page-shell`, `profile-*`, `link-*`, `page-footer`, `open-graph-metadata`).
- No tokenizar propiedades específicas de componentes: sombra/borde de la tarjeta (`components.card`), alto de botón 48px (`components.button-link`) ni tamaño de avatar 88px (`components.avatar`) quedan para `page-shell`, `link-button-component` y `profile-avatar` respectivamente.
- No definir estados de hover/focus, transiciones ni `prefers-reduced-motion` (features de componentes/accesibilidad).
- No introducir frameworks, bundlers, preprocesadores (Sass/Less), npm ni paso de build.
- No optimizar la carga de fuente (preload explícito, `font-display` fino, self-hosting) ni resolver FOUT: se usa `display=swap` y la pila de respaldo; el ajuste fino queda como riesgo abierto (`docs/risks-and-open-questions.md`).
- No renderizar contenido textual (el `<main>` sigue vacío); el texto visible llega en `profile-identity`.
- No modificar `DESIGN.md` ni los documentos de discovery.

## Job Story

When estoy construyendo cualquier bloque visual de la Tarjeta digital,
I want to consumir valores de diseño ya definidos como variables CSS (`--color-*`, `--font-*`, `--text-*`, `--radius-*`, `--space-*`),
so I can mantener una sola fuente de verdad, evitar valores hardcodeados y garantizar consistencia con `DESIGN.md`.

## Users And Permissions

- Implementador/agente: crea `styles.css`, lo enlaza en `index.html` y ajusta `init.sh`; no implementa componentes de producto.
- Visitante (indirecto): aún no consume contenido; solo percibe el fondo y la tipografía base aplicados al documento.
- No aplica autenticación, roles ni permisos (`docs/technical-discovery.md`).

## Acceptance Scenarios

### Scenario 1: Cada token de DESIGN.md existe como custom property

Given un repositorio con `index.html` bootstrapped y sin estilos,
When el implementador crea `styles.css` con el bloque `:root`,
Then cada color, propiedad tipográfica, radio y espaciado listado en `DESIGN.md` existe como una custom property con el valor exacto de `DESIGN.md` (lista completa en "Technical Approach").

### Scenario 2: El documento aplica los tokens (fondo, texto y familia tipográfica)

Given la página servida con `python3 -m http.server 8080 --directory .`,
When se inspecciona el `body` en el navegador,
Then `background-color` es `#f7f9ff`, `color` es `#2d3139`, y `font-family` resuelve a `"Plus Jakarta Sans"` con pila de respaldo del sistema si la fuente no está disponible.

### Scenario 3: El harness detecta tokens faltantes

Given `styles.css` con un token eliminado o con `styles.css` ausente o sin enlazar,
When se ejecuta `./init.sh`,
Then el script falla (código distinto de `0`), imprime qué token/archivo falta y no inicia ningún servidor.

### Scenario 4: Tipografía con pila de respaldo

Given que Google Fonts no responde, está bloqueado o tarda,
When el documento carga,
Then el texto (cuando exista) se renderiza con la pila de respaldo `system-ui, -apple-system, "Segoe UI", Roboto, sans-serif` sin romperse ni bloquear el render (`display=swap`).

## Repository Research

### Files Inspected

- `AGENTS.md` — workflow de arranque, reglas de alcance y Definition of Done.
- `PROGRESS.md` — estado verificado: `static-bootstrap` aceptado; siguiente feature lista `design-tokens`; sin bloqueos.
- `feature_list.json` — metadata, verificación y notas de `design-tokens`.
- `DESIGN.md` — fuente de verdad de tokens (`colors`, `typography`, `rounded`, `spacing`) y baseline de accesibilidad/responsive.
- `index.html` — esqueleto actual: `<!DOCTYPE html>`, `lang="es"`, charset, viewport, `<title>` y `<main>` vacío; sin CSS ni JS.
- `init.sh` — gate no bloqueante (`set -euo pipefail`); valida existencia, `lang="es"`, `<title>` no vacío y viewport; no inicia servidor salvo `RUN_SERVE_COMMAND=1`.
- `docs/technical-discovery.md` — stack HTML5 + CSS moderno con custom properties; Plus Jakarta Sans vía Google Fonts con pila de respaldo; iconos SVG inline; sin build ni dependencias; salida en la raíz.
- `docs/risks-and-open-questions.md` — riesgo de dependencia de Google Fonts y pregunta abierta sobre preload/FOUT.
- `docs/build-brief.md` — el sistema visual de referencia es `DESIGN.md`; contenido en español.
- `docs/specs/static-bootstrap.md` y `docs/validations/static-bootstrap.md` — formato/calidad de spec y evidencia de aceptación del prerrequisito.
- `CONTEXT.md` — vocabulario del dominio (no introduce requisitos de diseño nuevos).
- `assets/` — `assets/avatar.jpg` presente (`assets/og-image.jpg` pendiente); no se usan en esta feature.
- `git status` / `git log` — working tree sin `styles.css`; no existen `ARCHITECTURE.md` ni `CONSTRAINTS.md`.

### Existing Patterns To Follow

- Sitio estático sin build; la salida es la raíz del repositorio (`docs/technical-discovery.md`).
- CSS moderno con custom properties, sin framework ni preprocesador (`docs/technical-discovery.md`).
- `init.sh` como gate no bloqueante: `set -euo pipefail`, resolución relativa al cwd, mensajes de fallo en stderr, sin arrancar servidores por defecto (patrón de `static-bootstrap`).
- Nomenclatura de evidencia y cierre de feature: actualizar `feature_list.json` (`status` + `evidence`) y `PROGRESS.md` (patrón de la sesión 002).

### Current Gaps

- No existe `styles.css` ni ninguna hoja de estilos enlazada; el documento usa estilos por defecto del navegador.
- No existe una convención de nombres de tokens documentada en el repo (se establece en esta feature).
- La tipografía Plus Jakarta Sans no está cargada ni referenciada en `index.html`.
- No hay framework de tests, linter ni comando E2E; la verificación es script no bloqueante + inspección en navegador (`docs/technical-discovery.md`).
- `init.sh` no valida la existencia ni el contenido de los tokens.

## Technical Approach

1. **Dónde viven los tokens:** crear una hoja de estilos externa `styles.css` en la raíz del repositorio y enlazarla desde `<head>` de `index.html` con `<link rel="stylesheet" href="styles.css">`.
   - Se descarta el `<style>` inline: una feature centrada en "variables CSS reutilizables" necesita un artefacto compartido que las features posteriores (layout, componentes, pie) puedan consumir sin reescribir un bloque inline. No añade build ni dependencias.
2. **Convención de nombres** (una custom property por propiedad de `DESIGN.md`):
   - Colores: `--color-<nombre>` (incluye `gradient-1`..`gradient-5`).
   - Tipografía: `--font-family-base` (familia única) y `--text-<escala>-<propiedad>` por escala.
   - Radios: `--radius-<nombre>`.
   - Espaciado: `--space-<nombre>`.
3. **Estrategia de tipografía:** tokens granulares por propiedad (font-size / font-weight / line-height / letter-spacing), no shorthands compuestos. `letter-spacing` se define **solo** para las escalas donde `DESIGN.md` lo especifica (`headline-lg`, `headline-md`, `button-label`, `label-sm`); `body-md` y `body-sm` no llevan token de tracking y heredan `normal`. Todas las escalas comparten `--font-family-base`.
4. **Lista exacta de tokens (contrato implementador/validator):**
   - Color (16): `--color-background: #f7f9ff`, `--color-surface: #ffffff`, `--color-surface-container-low: #f1f4fa`, `--color-border: #ebeef2`, `--color-on-surface: #2d3139`, `--color-on-surface-variant: #717886`, `--color-outline: #767685`, `--color-primary: #484dc4`, `--color-on-primary: #ffffff`, `--color-accent: #585ce5`, `--color-gradient-1: #6876f0`, `--color-gradient-2: #736deb`, `--color-gradient-3: #8168e8`, `--color-gradient-4: #9362e6`, `--color-gradient-5: #a85ee2`, `--color-error: #ba1a1a`.
   - Tipografía (23): `--font-family-base: "Plus Jakarta Sans", system-ui, -apple-system, "Segoe UI", Roboto, sans-serif`; `--text-headline-lg-font-size: 26px`, `--text-headline-lg-font-weight: 600`, `--text-headline-lg-line-height: 34px`, `--text-headline-lg-letter-spacing: -0.02em`; `--text-headline-md-font-size: 20px`, `--text-headline-md-font-weight: 600`, `--text-headline-md-line-height: 28px`, `--text-headline-md-letter-spacing: -0.015em`; `--text-body-md-font-size: 13px`, `--text-body-md-font-weight: 400`, `--text-body-md-line-height: 20px`; `--text-body-sm-font-size: 12px`, `--text-body-sm-font-weight: 400`, `--text-body-sm-line-height: 18px`; `--text-button-label-font-size: 11px`, `--text-button-label-font-weight: 800`, `--text-button-label-line-height: 16px`, `--text-button-label-letter-spacing: 0.18em`; `--text-label-sm-font-size: 11px`, `--text-label-sm-font-weight: 600`, `--text-label-sm-line-height: 16px`, `--text-label-sm-letter-spacing: 0.05em`.
   - Radio (5): `--radius-sm: 0.125rem`, `--radius-md: 0.375rem`, `--radius-lg: 0.5rem`, `--radius-xl: 0.75rem`, `--radius-full: 9999px`.
   - Espaciado (7): `--space-gutter: 1rem`, `--space-margin: 1.5rem`, `--space-xs: 0.375rem`, `--space-sm: 0.75rem`, `--space-md: 1rem`, `--space-lg: 1.5rem`, `--space-xl: 2.25rem`.
5. **Aplicación observable (mínima, sin invadir layout):** en `styles.css`, tras `:root`, una regla base:
   ```css
   body {
     margin: 0;
     background-color: var(--color-background);
     color: var(--color-on-surface);
     font-family: var(--font-family-base);
   }
   ```
   No se define contenedor, ancho, tarjeta ni componentes.
6. **Carga de fuente (decisión):** se **incluye** en esta feature el enlace a Google Fonts en `<head>` (se descarta diferirlo), porque `user_visible_behavior` exige que el documento aplique "la tipografía Plus Jakarta Sans con pila de respaldo" y un token que nombra una fuente sin cargarla no la aplica realmente. Pesos necesarios según `DESIGN.md`: 400, 600 y 800. Se añaden `preconnect` a `fonts.googleapis.com` y `fonts.gstatic.com` (crossorigin) y la hoja `https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;800&display=swap`. La pila de respaldo del token es la red de seguridad si la fuente no carga; la optimización de FOUT/preload queda como no-goal.
7. **Gate en `init.sh`:** extender el gate no bloqueante de `static-bootstrap` (sin quitar sus checks) para validar los tokens:
   - `styles.css` existe.
   - `index.html` lo enlaza (`<link` con `href="styles.css"`).
   - Cada uno de los 51 tokens requeridos aparece en `styles.css` (recorrer una lista explícita de nombres de token; imprimir `[ok] design tokens present (N/N)` y, si falta alguno, `FAILED - styles.css missing token: <nombre>` en stderr con exit `1`).
   - Mantener el patrón: no arrancar servidor salvo `RUN_SERVE_COMMAND=1`.
8. Registrar evidencia y cerrar la feature actualizando `feature_list.json` y `PROGRESS.md`.

## Expected File Changes

- `styles.css` — crear; define el bloque `:root` con los 51 tokens de `DESIGN.md` y la regla base de `body`.
- `index.html` — modificar; añadir en `<head>` el `<link rel="stylesheet" href="styles.css">` y los `preconnect`/`<link>` de Google Fonts para Plus Jakarta Sans.
- `init.sh` — modificar; añadir el gate no bloqueante de existencia/enlace/presencia de tokens.
- `feature_list.json` — modificar; marcar `design-tokens` y registrar evidencia (lo hace el implementador).
- `PROGRESS.md` — modificar; actualizar estado verificado y bitácora de sesión (lo hace el implementador).
- `docs/specs/design-tokens.md` — crear; este spec.

## Visual Design Impact

- UI involved: yes (fundacional).
- Design source: `DESIGN.md` (secciones `colors`, `typography`, `rounded`, `spacing`).
- Screens or states affected: una sola vista; estado base del documento (fondo de lienzo, color de texto, familia tipográfica). No hay contenido ni componentes visibles aún.
- New design artifact required: no — los tokens se derivan literalmente de `DESIGN.md`; no se inventan valores.

## Durable Documentation Impact

- `ARCHITECTURE.md`: not needed — el stack estático y la salida desde la raíz ya están en `docs/technical-discovery.md`; no se introducen capas, dominios ni boundaries nuevos.
- `CONSTRAINTS.md`: not needed — la regla "usar los tokens de diseño" ya vive en `DESIGN.md` (Do's and Don'ts); duplicarla no añade una regla nueva.
- `AGENTS.md`: not needed — el camino de arranque sigue siendo `./init.sh` y las reglas operativas no cambian (solo se amplía el contenido de las comprobaciones).
- Other docs: `docs/technical-discovery.md` — not needed; ya compromete "CSS moderno con custom properties" y el nombre concreto del archivo es detalle de implementación registrado en este spec.

## Implementation Plan

1. Crear `styles.css` con `:root` (51 tokens exactos) y la regla base de `body`.
2. Enlazar `styles.css` y cargar Plus Jakarta Sans (400/600/800) desde `<head>` de `index.html`.
3. Extender `init.sh` con el gate no bloqueante de tokens (existencia, enlace y presencia de cada token).
4. Ejecutar `./init.sh` (exit `0`), probar el caso negativo (token eliminado) y verificar los colores aplicados en el navegador.
5. Actualizar `feature_list.json` (`status` + `evidence`) y `PROGRESS.md`.

## Implementation Tasks

- [ ] Crear `styles.css` con `:root` y los 16 tokens de color de `DESIGN.md`.
- [ ] Añadir los 23 tokens de tipografía (familia + escalas) con valores exactos.
- [ ] Añadir los 5 tokens de radio y los 7 de espaciado.
- [ ] Añadir la regla base de `body` (margin, background, color, font-family) usando los tokens.
- [ ] Enlazar `styles.css` y cargar Plus Jakarta Sans (400/600/800) con `preconnect` y `display=swap` en `index.html`.
- [ ] Extender `init.sh` con el gate no bloqueante de tokens, sin quitar los checks de `static-bootstrap`.
- [ ] Verificar `./init.sh` exit `0` y el caso negativo (token faltante → exit `1`).
- [ ] Verificar en navegador `background-color`, `color` y `font-family` computados del `body`.
- [ ] Registrar evidencia en `feature_list.json` y actualizar `PROGRESS.md`.

## Verification Plan

- `./init.sh` — debe reportar `Harness status: bootstrapped`, los checks de `static-bootstrap` y `[ok] design tokens present (51/51)`; exit `0`; sin arrancar servidor.
- Caso negativo: eliminar temporalmente un token (p. ej. `--color-primary`) de `styles.css` y confirmar que `./init.sh` falla con `FAILED - styles.css missing token: --color-primary` en stderr; restaurar después. Probar también `styles.css` ausente y `<link>` ausente.
- Inspección de `styles.css`: confirmar 1:1 cada token de `DESIGN.md` con su valor exacto (contrato de la sección "Technical Approach", punto 4).
- Navegador: `python3 -m http.server 8080 --directory .` y abrir `http://localhost:8080`; en DevTools confirmar `body` → `background-color: rgb(247, 249, 255)`, `color: rgb(45, 49, 57)` y `font-family` con `Plus Jakarta Sans` (+ fallback). Confirmar que la regla base no introduce scroll horizontal.
- Comprobación E2E: no aplica; el repositorio no tiene harness E2E ni framework de tests. La verificación es script no bloqueante + inspección en navegador, coherente con `docs/technical-discovery.md`.
- `init.sh`: debe ejecutar el gate estándar no bloqueante del estado actual, imprimir el comando de servicio como seguimiento manual y no arrancar el servidor salvo `RUN_SERVE_COMMAND=1`.

## Evidence To Capture

- Salida de `./init.sh` en estado correcto (exit `0`, `[ok] design tokens present (51/51)`).
- Salida de `./init.sh` en el caso negativo (fallo esperado con nombre del token faltante).
- Salida de la inspección 1:1 de tokens de `DESIGN.md` en `styles.css`.
- Resultado en navegador: valores computados de `background-color`, `color` y `font-family` del `body`.
- Referencias actualizadas en `feature_list.json` (`status`, `evidence`) y `PROGRESS.md`.

## Validator Checklist

- [ ] Implementation stays within this feature's scope.
- [ ] Acceptance scenarios pass.
- [ ] Verification evidence is present.
- [ ] Persistent E2E coverage was added/updated when the feature has an observable user/API flow and an E2E harness exists, or the spec explains why it is not needed.
- [ ] `feature_list.json` and `PROGRESS.md` were updated correctly.
- [ ] No unrelated product behavior or extra feature work was added.
- [ ] Los 51 tokens existen con valores exactos de `DESIGN.md` y no se añadieron tokens de componentes (sombra, alto de botón, avatar).
- [ ] El documento aplica `--color-background`, `--color-on-surface` y `--font-family-base` en `body`.

## Assumptions And Open Questions

### Assumptions

- Sin framework de tests ni E2E; la verificación es el gate de `init.sh` más inspección manual en navegador (`docs/technical-discovery.md`).
- Google Fonts es aceptable (servicio gratuito) según `docs/technical-discovery.md` y `docs/risks-and-open-questions.md`.
- `styles.css` en la raíz es la ubicación de CSS; no hay carpeta de estilos previa ni convención en conflicto.
- `python3` está disponible para servir y verificar (confirmado en `static-bootstrap`).

### Open Questions

- Preload de fuente y manejo fino de FOUT: se difiere (no-goal); ver `docs/risks-and-open-questions.md`.
- ¿Se creará un `CONSTRAINTS.md` cuando varias features futuras necesiten una regla MUST explícita de "no hardcodear valores visuales"? Por ahora la regla vive en `DESIGN.md`.
- Ubicación futura de CSS de componentes (¿mismo `styles.css` o archivos por feature?) se decidirá en `page-shell`/`link-button-component`; esta feature solo fija el archivo de tokens.
