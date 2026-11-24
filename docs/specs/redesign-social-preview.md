# Feature Implementation Spec: Imagen social de la Tarjeta renovada

## Source Feature

- `id`: `redesign-social-preview`
- `area`: `sharing`
- `depends_on`: `redesign-card-profile`, `redesign-contact-navigation`, `redesign-footer-contact`, `redesign-qr-panel`, `redesign-share-action`, `deploy-cloudflare-pages` (all `accepted`)
- `status`: `not_started` (at planning time; this spec does not change it)
- `source`: `feature_list.json`; `DESIGN.md` § "Open Graph Image (1200×630)" and § "Dirección del rediseño acordado (2026-11-21)" → "La imagen social se rediseñará para acompañar la nueva Tarjeta, seguirá siendo JPEG 1200×630 y necesitará aprobación visual de Fahed antes de publicar."

## Goal

Replace `assets/og-image.jpg` with a new JPEG 1200×630 that visually reflects the **current, already-redesigned** Tarjeta (new header with "NFC CONNECT" label, avatar frame, ornamental dot; three Acciones rápidas including Compartir; five gradient Enlaces; redesigned footer copy), while keeping the title/description metadata and the production destination (`canonical`, `og:url`, `og:image`, `twitter:image`) byte-identical to what `deploy-cloudflare-pages` already wired up. This is the last slice of the 2026-11-21 redesign: it only touches the social-preview asset and its description in durable docs, not the live page markup, layout, or metadata contract.

This feature does **not** invent new visual design. All visual decisions it depends on (header, quick actions, links order/tones, footer copy, QR) were already approved by the owner in their own feature specs and are `accepted`. The job here is representation, not design: produce an image whose composition is a faithful, static reflection of the already-approved live card — not a new creative brief.

## Non-Goals

- No change to `<head>` metadata tag names, order, or values beyond the `assets/og-image.jpg` binary itself: `og:title`, `og:description`, `og:type`, `og:site_name`, `canonical`, `og:url`, `og:image`/`twitter:image` URLs, dimensions, alt text and `twitter:card` stay exactly as `deploy-cloudflare-pages` left them (byte-identical to `PRODUCTION_URL`/`PRODUCTION_IMAGE_URL`).
- No change to `index.html` visible markup, `styles.css`, tokens, `share.js`, `scripts.js`, the QR panel, or any accepted redesign feature's behavior.
- No new production origin, domain, or deploy mechanism; `PRODUCTION_ORIGIN`/`PRODUCTION_URL`/`PRODUCTION_IMAGE_URL` in `init.sh` do not change.
- No use of `assets/og-image.jpg` as an `<img>` inside the Tarjeta; it stays a metadata-only asset.
- No reuse of `assets/avatar.jpg` or any existing asset as-is for the new image; no placeholder, screenshot-with-browser-chrome, or obviously fake composition.
- No weakening of `Sharing metadata production checks:`, `Accessibility checks:`, or `Responsive checks:` in `init.sh`; no new `[warn]`-only path for a check that is already blocking today.
- No fabricating the owner's visual approval, no fabricating real-device preview results (WhatsApp/Facebook/iMessage), and no performing the manual redeploy. These three things are explicitly out of this feature's implementable scope — see "Owner-Dependent Acceptance" below.
- No fixing the pre-existing operational risks noted in `PROGRESS.md` (HTTP not redirecting to HTTPS, `PROGRESS.md`/`AGENTS.md` publicly served) — those are tracked separately and this feature does not resolve them.

## Job Story

When alguien comparte la URL pública de la Tarjeta renovada por WhatsApp, redes o mensajería,
I want that la vista previa muestre el título y destino correctos y una imagen que se vea como la Tarjeta rediseñada que la gente verá al abrir el enlace,
so el destinatario reconoce visualmente la Tarjeta antes de abrirla y no hay una desconexión entre la vista previa y la página real.

## Users And Permissions

- Visitante anónimo: no interactúa con esta feature directamente; se beneficia de una vista previa coherente con la página real al recibir el enlace.
- Implementador/agente: produce el candidato de imagen con una receta reproducible y verificable localmente (sin build, sin runtime nuevo), actualiza `init.sh`'s existing non-negotiable checks only by satisfying them, and updates durable docs describing the new composition. Does **not** grant itself owner approval, does **not** claim real preview results, and does **not** redeploy.
- Propietario (Fahed): aprueba visualmente el nuevo `assets/og-image.jpg` (móvil y escritorio), realiza el redeploy manual, y registra vistas previas reales en WhatsApp/Facebook/iMessage. Only the owner's explicit response can close these three items; the implementer must not mark the feature `accepted` on their behalf.
- Validador: confirma que el contrato de `init.sh` sigue verde, que no se tocó nada fuera de alcance, y que la evidencia distingue claramente lo verificado localmente de lo pendiente del propietario.

## Acceptance Scenarios

### Scenario 1: Nueva imagen cumple el contrato binario existente

Given un nuevo `assets/og-image.jpg` producido para esta feature,
When se ejecuta `./init.sh`,
Then `file -b assets/og-image.jpg` reporta `JPEG image data` y `1200x630`, el archivo no está vacío, pesa ≤307 200 bytes (o el gate emite `[warn]` si lo supera, sin fallar), `cmp -s assets/og-image.jpg assets/avatar.jpg` es distinto (no es una copia del avatar), y los cuatro checks de `Sharing metadata production checks:` (canonical, `og:url`, `og:image`, `twitter:image` con `PRODUCTION_URL`/`PRODUCTION_IMAGE_URL`) siguen en verde sin ningún cambio de valor.

### Scenario 2: Metadatos de título/descripción intactos

Given el mismo `index.html` servido,
When se inspecciona `<head>`,
Then `og:title`, `og:description`, `og:type`, `og:site_name`, `twitter:card`, `twitter:title`, `twitter:description`, los `alt` de imagen y las dimensiones `1200`/`630` permanecen byte-idénticos a los valores actuales; solo el binario referenciado cambia de contenido.

### Scenario 3: La imagen no se usa dentro de la Tarjeta

Given la página cargada en el navegador,
When se inspecciona el DOM y la pestaña de red,
Then no hay ningún `<img>` que solicite `assets/og-image.jpg`; la página sigue pidiendo exactamente los recursos esperados (documento, `styles.css`, Google Fonts, `assets/avatar.jpg`, `assets/qr.png`, `share.js`/`scripts.js` si aplica), sin `/favicon.ico` ni peticiones fallidas.

### Scenario 4: El gate detecta una imagen inválida (regresión)

Given una copia temporal fuera del repo con `assets/og-image.jpg` (a) ausente, (b) vacío, (c) PNG renombrado a `.jpg`, (d) JPEG con otras dimensiones (ej. 1200×600), o (e) byte-idéntico a `assets/avatar.jpg`,
When se ejecuta `./init.sh` sobre esa copia,
Then sale con código `1`, imprime el mensaje de fallo concreto (ya existente en `init.sh`) en stderr y no arranca ningún servidor.

### Scenario 5: Sin regresión de accesibilidad ni responsive

Given viewports 390×844 y 1280×800 con el nuevo asset en su lugar,
When se recarga la página y se ejecuta Lighthouse móvil de accesibilidad,
Then la consola tiene 0 mensajes, no hay peticiones fallidas, no hay scroll horizontal, `Accessibility checks:` y `Responsive checks:` de `init.sh` siguen pasando sin cambios de contrato, y Lighthouse móvil Accessibility ≥95 sin hallazgos `critical`/`serious`.

### Scenario 6: Owner-dependent closure (cannot be simulated)

Given el candidato de imagen verificado técnicamente y el `./init.sh` verde,
When se solicita cierre de la feature,
Then la feature permanece en `status: passing` (no `accepted`) hasta que el propietario (a) apruebe visualmente la imagen en móvil y escritorio, (b) autorice/realice el redeploy manual, y (c) registre el resultado de vistas previas reales en al menos WhatsApp, Facebook e iMessage. Ninguno de estos tres pasos puede ser fabricado, inferido o simulado por el implementador o el validador.

## Repository Research

### Files Inspected

- `feature_list.json` — entrada `redesign-social-preview` (`not_started`, `depends_on` seis features, todas `accepted`; `verification` y `notes` ya citan los cuatro criterios de cierre).
- `PROGRESS.md` — historial de `open-graph-metadata`, `deploy-cloudflare-pages`, y las sesiones recientes (Session 069–073) de `redesign-footer-contact`, `redesign-qr-panel`, `redesign-share-action`: confirma que las cinco features de rediseño dependientes y `deploy-cloudflare-pages` están cerradas y que el sitio publicado todavía usa el diseño anterior salvo lo que se vaya mergeando.
- `index.html` — `<head>` actual (líneas 4–23): `<title>Fahed Hermoza — Tarjeta digital</title>`, `<link rel="canonical" href="https://fahed-hermoza-card.fahedhermoza.workers.dev/">`, 14 etiquetas OG/Twitter con `og:url`/`og:image`/`twitter:image` ya absolutas a `PRODUCTION_URL`/`PRODUCTION_IMAGE_URL`. No hay comentario de "provisional" (ya resuelto por `deploy-cloudflare-pages`).
- `assets/og-image.jpg` — JPEG real 1200×630, 37 214 bytes, SHA-256 `b7c9b694e055100f41d437d8fed261df20b90bfdca59f248ec49302aaea012a2`; distinto de `assets/avatar.jpg` (SHA-256 `b73575ae…`). Esta es la imagen **vieja** (generada para `deploy-cloudflare-pages` el 2026-10-23, antes del rediseño).
- `assets/avatar.jpg`, `assets/qr.png`, `assets/fahedhermoza.vcf` — assets existentes; ninguno se toca en esta feature.
- `init.sh` (2855 líneas) — constantes `PRODUCTION_ORIGIN`/`PRODUCTION_URL`/`PRODUCTION_IMAGE_URL` (líneas 11–13); `Sharing metadata production checks:` (línea 1583, 4/4 bloqueante sobre canonical/`og:url`/`og:image`/`twitter:image`); checks del binario `assets/og-image.jpg` (líneas 1610–1651: existencia, no vacío, `file -b` → `JPEG image data` + `1200x630`, `[warn]` si >307 200 bytes, `cmp -s` contra `avatar.jpg`); `Accessibility checks:` (línea 2167) y `Responsive checks:` (línea 2621), ambos ya verdes con el estado actual del redesign; puerto de servido sugerido por defecto `3601` (línea 2850), sin arrancar servidor salvo `RUN_SERVE_COMMAND=1`.
- `styles.css` — `.card` actual: `border-radius: 24px`, `box-shadow: 0 24px 64px -28px rgba(45, 49, 57, 0.16), 0 8px 24px -10px rgba(45, 49, 57, 0.08)` (cambiado por `redesign-card-profile`; distinto de los valores que describe hoy `DESIGN.md` § "Open Graph Image").
- `CONSTRAINTS.md` — § "Publicación (Cloudflare Workers static assets)" (líneas 177–204): fija el contrato durable de origen único, `canonical`/`og:url`/`og:image`/`twitter:image` byte-idénticos, `assets/og-image.jpg` JPEG 1200×630 ≤307 200 bytes distinto del avatar y nunca usado como `<img>`, y que el redeploy/unfurl son checks humanos explícitos. Este contrato ya cubre exactamente lo que esta feature necesita sin requerir una regla nueva.
- `DESIGN.md` § "Open Graph Image (1200×630)" (líneas 297–315) — describe la composición de la imagen **vieja**: tarjeta blanca 880×440, radio 24px, sombra histórica `0 18px 45px -10px rgba(25,30,48,0.08), 0 8px 16px -6px rgba(25,30,48,0.03)`, avatar 128×128, Nombre/Handle/Tagline sin mención del encabezado "NFC CONNECT", punto ornamental, Acciones rápidas ni pie rediseñado.
- `DESIGN.md` § "Dirección del rediseño acordado (2026-11-21)" (líneas 435–489) — confirma explícitamente: "La imagen social se rediseñará para acompañar la nueva Tarjeta, seguirá siendo JPEG 1200×630 y necesitará aprobación visual de Fahed antes de publicar."; y § "Open Design Questions" ya registra como resuelto (2026-10-23) el diseño **viejo**, dejando pendiente el nuevo.
- `docs/specs/open-graph-metadata.md`, `docs/specs/deploy-cloudflare-pages.md` — precedente operativo: la "receta reproducible" (HTML temporal no commiteado en `/tmp`, captura con Chrome DevTools emulando viewport 1200×630×1, `sips`/`file`/`wc -c`/`shasum` para validar) y el patrón de checks de `init.sh` que ya existen y no deben debilitarse.
- `docs/specs/redesign-qr-panel.md` — precedente de que un asset binario (`assets/qr.png`) se genera **offline** con una herramienta externa y se commitea como binario estático, validado por el gate solo en forma (magic bytes/dimensiones), no en contenido.
- `docs/technical-discovery.md` — confirma "el agente no interpreta imágenes: la `og-image` se genera con una receta reproducible y su aprobación es humana", y documenta el estado live verificado el 2026-10-24 (HTTPS, 5 paths, hashes).
- `docs/risks-and-open-questions.md` — riesgo "Vista previa social" ya registrado: un HTML/imagen correctos no garantizan el unfurl real de WhatsApp/Facebook/iMessage.

### Existing Patterns To Follow

- HTML/CSS estáticos; ningún build, framework ni dependencia nueva.
- Assets binarios (`avatar.jpg`, `qr.png`, `og-image.jpg`) se generan offline con una herramienta externa y se commitean; `init.sh` los valida solo en forma (tipo, dimensiones, tamaño, no-vacío, no-reutilización de otro asset), nunca en contenido visual.
- `init.sh` es un gate acumulativo y no bloqueante por defecto para el servidor: cada feature añade o satisface checks sin debilitar los anteriores; los fallos van a stderr con `fail "..."` y `exit 1`; no arranca servidor salvo `RUN_SERVE_COMMAND=1`.
- Evidencia durable en `feature_list.json` + `PROGRESS.md`; specs y validaciones en `docs/`.
- Patrón ya usado dos veces (`open-graph-metadata` → `deploy-cloudflare-pages`): una feature deja el contrato de metadatos verificable y una posterior resuelve el asset/URL reales; aquí la secuencia es la inversa pero análoga — el contrato de metadatos y URL ya está resuelto por `deploy-cloudflare-pages`, y esta feature solo resuelve el asset para que coincida con el nuevo diseño.
- Puerto aislado para servir local en este worktree: **3701** (indicado en el handoff; `init.sh` sigue imprimiendo `3601` como hint genérico heredado — no hace falta cambiarlo, basta con usar `python3 -m http.server 3701 --directory .` al verificar manualmente en esta worktree).

### Current Gaps

- `assets/og-image.jpg` existe y pasa el gate hoy, pero visualmente corresponde al diseño **anterior** a los seis slices del rediseño: no refleja el encabezado "NFC CONNECT", el avatar con marco/punto, las tres Acciones rápidas, los cinco Enlaces en gradiente ni el pie rediseñado.
- `DESIGN.md` § "Open Graph Image" describe la composición vieja (radio/sombra desactualizados respecto a `.card` real) y no menciona los elementos nuevos del encabezado/acciones/pie.
- No existe ningún artefacto, aprobación ni registro de que el propietario haya visto/aprobado una nueva composición de imagen social.
- No hay evidencia de pruebas reales de vista previa (WhatsApp/Facebook/iMessage) posteriores al rediseño; el redeploy manual tampoco se ha repetido desde que el diseño cambió.
- No hay harness E2E ni herramienta de captura de pantalla en el repo; la verificación de imagen es forma (gate) + inspección visual manual, igual que en `deploy-cloudflare-pages`.

## Technical Approach

### 1. Producir el candidato `assets/og-image.jpg` (implementable, offline, sin inventar diseño)

Reusar la receta reproducible ya documentada en `docs/specs/deploy-cloudflare-pages.md` § C, actualizándola para reflejar el diseño actual en lugar de reinventarlo:

1. Crear un HTML temporal **no commiteado** (p. ej. `/tmp/og-image-redesign.html`) de exactamente 1200×630 (`html, body { width: 1200px; height: 630px; margin: 0; overflow: hidden; }`).
2. Componer la escena **tomando los valores literales ya implementados y aceptados** en `styles.css`/`index.html` (no inventar ninguno nuevo): fondo `--color-background` `#f7f9ff`; tarjeta blanca centrada con `border-radius: 24px` y `box-shadow: 0 24px 64px -28px rgba(45, 49, 57, 0.16), 0 8px 24px -10px rgba(45, 49, 57, 0.08)` (los valores reales y actuales de `.card`, no los históricos); dentro, una representación fiel y legible a este tamaño del encabezado (avatar circular con halo, Nombre "Fahed Hermoza" en `headline-lg`/`#2d3139`, Handle "@fahedhermoza" y Tagline "Software Engineer & Speaker & Builder" con los colores/pesos actuales de `.profile-identity`), y opcionalmente una insinuación visual de la fila de Acciones rápidas o de los Enlaces en gradiente si el espacio a 1200×630 lo permite sin saturar. Tipografía Plus Jakarta Sans o su pila de respaldo. Ningún color, tono o tipografía fuera de `styles.css`.
3. Alternativa igualmente válida y más fiel: capturar directamente la Tarjeta real servida localmente (`python3 -m http.server 3701 --directory .`) con Chrome DevTools emulando un viewport ancho, recortando/escalando a 1200×630 de forma que la tarjeta rediseñada quede centrada y legible, sin cromo del navegador, sin barra de direcciones ni scrollbar visibles.
4. Exportar JPEG calidad ~90, sin `fullPage`, verificando que mide exactamente 1200×630.
5. Validar localmente antes de commitear: `sips -g pixelWidth -g pixelHeight -g format assets/og-image.jpg` → `1200`/`630`/`jpeg`; `file assets/og-image.jpg` → `JPEG image data ... 1200x630`; `wc -c` → objetivo ≤307 200 bytes (recomprimir si excede); `shasum -a 256` → registrar y confirmar que es distinto de `assets/avatar.jpg`.
6. **No** commitear el HTML temporal; **no** dejar ningún script de generación nuevo en el repo (no se introduce una dependencia de captura de pantalla); el binario resultante es el único artefacto de producto.

Esto produce un **candidato técnicamente válido** que satisface el gate y es visualmente coherente con el diseño actual. No sustituye la aprobación visual humana (ver "Owner-Dependent Acceptance").

### 2. No tocar el contrato de metadatos

`index.html` ya tiene `og:title`, `og:description`, `canonical`, `og:url`, `og:image`, `twitter:image` correctos y absolutos desde `deploy-cloudflare-pages`. Esta feature **reemplaza únicamente el binario** `assets/og-image.jpg`; no edita `<head>`.

### 3. `init.sh`: no se necesita ningún check nuevo

Los checks existentes (`Sharing metadata production checks:` 4/4 y el bloque de validación del binario en líneas ~1610–1651) ya cubren exactamente los cuatro criterios de verificación de la feature (JPEG real, 1200×630, ≤307 200 bytes como `[warn]`, distinto del avatar, URL de producción exacta). El implementador debe **satisfacerlos con el nuevo binario**, no modificarlos. Si al escribir la evidencia se detecta que algún mensaje de estos checks sigue describiendo el asset viejo (por ejemplo, un comentario con el tamaño en bytes antiguo), corregirlo como actualización menor de comentario, nunca como debilitamiento de la condición que falla.

### 4. Actualizar `DESIGN.md` § "Open Graph Image" para describir la composición real del nuevo binario

Dado que el binario cambia y `DESIGN.md` es la fuente de verdad de diseño, su sección descriptiva debe reflejar lo que realmente contiene el nuevo JPEG (radio/sombra/elementos actuales, nuevo SHA-256, nuevo tamaño en bytes, fecha). Esto **no** es una decisión de diseño nueva que requiera aprobación previa del propietario: es la documentación de un artefacto cuya composición ya deriva en su totalidad de valores ya aprobados en otras features (`redesign-card-profile`, `redesign-contact-navigation`, `redesign-footer-contact`). El implementador actualiza esta sección **después** de generar el binario, para que describa exactamente lo producido (no al revés).

### 5. Actualizar documentación de seguimiento

- `docs/technical-discovery.md` y `docs/risks-and-open-questions.md`: registrar que la imagen social ahora refleja el diseño rediseñado, con el nuevo hash, y que el redeploy/aprobación/preview real quedan como pasos pendientes del propietario (reabrir, no cerrar, el riesgo de "vista previa social" hasta que el propietario reporte resultado).
- `feature_list.json`: evidencia del implementador, `status: passing` (nunca `accepted`) hasta que el propietario cierre los tres criterios owner-dependientes.
- `PROGRESS.md`: nueva sesión con lo verificado localmente y los tres pendientes explícitos.

## Expected File Changes

- `assets/og-image.jpg` — reemplazar (binario); nuevo JPEG 1200×630 que refleja el diseño rediseñado, generado offline, ≤307 200 bytes objetivo, distinto de `assets/avatar.jpg`.
- `DESIGN.md` — modificar; actualizar § "Open Graph Image (1200×630)" con la composición, tamaño y SHA-256 reales del nuevo binario; marcar como resuelta la nota pendiente de "Dirección del rediseño acordado" sobre la imagen social.
- `docs/technical-discovery.md` — modificar; registrar el nuevo hash/estado del asset y que el redeploy/preview real están pendientes del propietario.
- `docs/risks-and-open-questions.md` — modificar; reabrir/actualizar el riesgo de "vista previa social" para el diseño nuevo hasta que el propietario reporte el resultado real.
- `feature_list.json` — modificar; evidencia del implementador, `status: passing`.
- `PROGRESS.md` — modificar; nueva sesión con estado verificado y pendientes owner-dependientes.
- `docs/specs/redesign-social-preview.md` — crear; este spec (planner).
- **No se modifican**: `index.html`, `styles.css`, `share.js`, `scripts.js`, `init.sh` (salvo que, al verificar, se descubra un comentario textual desactualizado que no cambie ninguna condición de fallo), `assets/avatar.jpg`, `assets/qr.png`, `assets/fahedhermoza.vcf`, `CONSTRAINTS.md`, `AGENTS.md`, `ARCHITECTURE.md` (no existe; no se crea).

## Visual Design Impact

- UI involved: no cambia la página visible de la Tarjeta. Afecta únicamente a la tarjeta de vista previa externa (unfurl) que ven WhatsApp/Facebook/iMessage/etc. al compartir la URL.
- Design source: `DESIGN.md` § "Open Graph Image (1200×630)" (a actualizar en esta feature con los valores reales del nuevo binario) y los valores ya aprobados en `styles.css`/`index.html` por las cinco features de rediseño dependientes.
- Screens or states affected: estado externo de vista previa al compartir; ningún estado dentro de la Tarjeta misma.
- New design artifact required: sí, el binario `assets/og-image.jpg` en sí — pero su composición **no introduce ningún valor de diseño nuevo**; reutiliza íntegramente tokens, geometría y contenido ya aprobados. Lo que sí requiere aprobación nueva del propietario es el resultado visual final del binario (ver "Owner-Dependent Acceptance"), no un token o layout nuevo.

## Durable Documentation Impact

- `ARCHITECTURE.md`: not needed — no existe en el repo y esta feature no introduce capas, dominios ni runtime nuevos.
- `CONSTRAINTS.md`: not needed — el contrato durable de § "Publicación (Cloudflare Workers static assets)" (JPEG 1200×630, ≤307 200 bytes, distinto del avatar, nunca `<img>`, URLs de producción byte-idénticas) ya cubre exactamente lo que esta feature necesita; no se introduce ninguna regla MUST/MUST NOT nueva.
- `AGENTS.md`: not needed — el flujo de arranque, puertos de verificación y reglas operativas no cambian.
- `DESIGN.md`: update — ver "Expected File Changes"; es la actualización principal de doc durable de esta feature.
- `docs/technical-discovery.md`: update — nuevo hash/estado del asset social.
- `docs/risks-and-open-questions.md`: update — reabrir el riesgo de vista previa social para el diseño nuevo hasta cierre del propietario.

## Implementation Plan

1. Confirmar baseline: `bash -n init.sh && ./init.sh` → exit `0` con el estado actual (asset viejo todavía en su lugar).
2. Producir el candidato `assets/og-image.jpg` con la receta de "Technical Approach" §1, validando forma (`sips`/`file`/`wc -c`/`shasum`) antes de tocar el repo.
3. Reemplazar `assets/og-image.jpg` en el working tree.
4. Ejecutar `./init.sh` y confirmar que el binario nuevo satisface los checks existentes sin ningún cambio de condición de fallo.
5. Probar los casos negativos de la Scenario 4 en copias temporales fuera del repo (repo intacto).
6. Verificar en navegador 390×844 y 1280×800: consola limpia, sin peticiones del asset nuevo desde la página, sin scroll horizontal; ejecutar Lighthouse móvil de accesibilidad.
7. Actualizar `DESIGN.md`, `docs/technical-discovery.md`, `docs/risks-and-open-questions.md` con los valores reales del nuevo binario.
8. Registrar evidencia en `feature_list.json` (`passing`) y `PROGRESS.md`, dejando explícitos los tres pendientes owner-dependientes (aprobación visual, redeploy, preview real).

## Implementation Tasks

- [ ] Confirmar baseline verde de `./init.sh` antes de tocar nada.
- [ ] Generar el candidato JPEG 1200×630 offline (receta reproducible, sin dependencias nuevas, sin HTML temporal commiteado).
- [ ] Validar forma localmente (`sips`/`file`/`wc -c`/`shasum`) antes de sustituir el archivo en el repo.
- [ ] Reemplazar `assets/og-image.jpg`; confirmar que `index.html` no cambia.
- [ ] `./init.sh` exit `0` con los checks existentes satisfechos por el binario nuevo (sin editar sus condiciones).
- [ ] Probar los 5 casos negativos (Scenario 4) en copias temporales fuera del repo; cada uno `exit 1`, sin servidor.
- [ ] Navegador 390×844 y 1280×800: consola 0 mensajes, sin petición del nuevo asset desde la página, sin scroll horizontal; Lighthouse móvil Accessibility ≥95 sin `critical`/`serious`.
- [ ] Confirmar que `Accessibility checks:` y `Responsive checks:` siguen pasando sin cambios de contrato.
- [ ] Actualizar `DESIGN.md` (composición/hash/tamaño reales), `docs/technical-discovery.md` y `docs/risks-and-open-questions.md`.
- [ ] Registrar evidencia en `feature_list.json` (`status: passing`, nunca `accepted`) y `PROGRESS.md`, listando explícitamente los tres pendientes owner-dependientes.
- [ ] Solicitar al propietario, sin fabricar su respuesta: (a) aprobación visual del nuevo `assets/og-image.jpg` en móvil y escritorio, (b) el redeploy manual, (c) el registro de vistas previas reales en WhatsApp/Facebook/iMessage.

## Verification Plan

### Gate

- `bash -n init.sh` → sin errores de sintaxis (no se modifica `init.sh`, pero se confirma que sigue siendo válido).
- `./init.sh` → `Harness status: bootstrapped`, todos los checks previos `[ok]`, `Sharing metadata production checks:` 4/4, `[ok] assets/og-image.jpg exists (JPEG 1200x630, N bytes)` con el nuevo tamaño/hash, exit `0`, sin servidor.
- Casos negativos en copias temporales fuera del repo (eliminar al terminar; repo intacto, sin listener en ningún puerto): asset ausente, asset vacío, PNG renombrado a `.jpg`, dimensiones distintas de 1200×630, byte-idéntico al avatar → los 5 casos `exit 1` con el mensaje de `fail` ya existente.

### Static asset

- `sips -g pixelWidth -g pixelHeight -g format assets/og-image.jpg` → `1200`/`630`/`jpeg`.
- `file assets/og-image.jpg` → `JPEG image data ... 1200x630`.
- `wc -c assets/og-image.jpg` → objetivo ≤307 200 bytes; si excede, recomprimir antes de seguir.
- `shasum -a 256 assets/og-image.jpg assets/avatar.jpg` → confirmar que son distintos; registrar ambos hashes.

### Browser

- `python3 -m http.server 3701 --directory .` (puerto aislado de este worktree; detener al terminar y confirmar puerto libre).
- 390×844 y 1280×800: consola 0 mensajes, red esperada (documento, `styles.css`, Google Fonts, `assets/avatar.jpg`, `assets/qr.png`, `share.js`/`scripts.js`), sin petición de `assets/og-image.jpg` desde la página (los metadatos no se descargan al renderizar), sin `/favicon.ico`, sin scroll horizontal.
- Lighthouse móvil de accesibilidad sobre `http://localhost:3701/` → Accessibility ≥95, sin hallazgos `critical`/`serious`.
- Leer `document.querySelector` de las etiquetas OG/Twitter para confirmar que no cambiaron.
- E2E: no aplica — no existe harness E2E persistente en el repo y añadirlo introduciría dependencias prohibidas por `docs/technical-discovery.md`. La cobertura es gate + verificación estática del binario + navegador + Lighthouse, igual que en `open-graph-metadata`/`deploy-cloudflare-pages`.

### Owner-dependent (no simulable; ver sección siguiente)

- Aprobación visual del propietario del nuevo `assets/og-image.jpg` en móvil y escritorio.
- Redeploy manual por el propietario y verificación `curl` por HTTPS de los cinco paths (`/`, `styles.css`, avatar, `og-image`, vCard), MIME y hashes local/live (mismo patrón que `docs/specs/deploy-cloudflare-pages.md` § E).
- Registro honesto de vistas previas reales en WhatsApp, Facebook e iMessage.

## Evidence To Capture

- Salida de `bash -n init.sh` y `./init.sh` correcto (exit `0`, checks existentes satisfechos) y de los 5 casos negativos (exit `1`, sin listener).
- `sips`/`file`/`wc -c`/`shasum` del nuevo `assets/og-image.jpg`, con el nuevo SHA-256 registrado en `feature_list.json`, `PROGRESS.md` y `DESIGN.md`.
- Confirmación de que `index.html` no cambió (`git diff -- index.html` vacío) y de que ningún otro archivo fuera de "Expected File Changes" se tocó.
- Resultado de navegador 390×844/1280×800 (consola, red, scroll horizontal) y de Lighthouse móvil de accesibilidad.
- Estado explícito y honesto en `feature_list.json`/`PROGRESS.md` de los tres pendientes owner-dependientes: `owner visual approval: pending`, `manual redeploy: pending`, `real preview checks (WhatsApp/Facebook/iMessage): pending` — o, si el propietario ya respondió, su respuesta literal y fecha, nunca una inferencia del agente.
- `feature_list.json` permanece en `status: passing` (no `accepted`) mientras falte cualquiera de los tres puntos anteriores.

## Owner-Dependent Acceptance (cannot be fabricated by an agent)

Esta feature tiene tres criterios de cierre que son, por diseño, insumos externos del propietario y **no pueden ser producidos, simulados ni inferidos por un agente**:

1. **Aprobación visual del nuevo `assets/og-image.jpg`** en móvil y escritorio. Un agente puede producir un candidato técnicamente válido (JPEG real 1200×630, dentro de tamaño, distinto del avatar, no usado como `<img>`), pero no puede decidir si "se ve bien" ni sustituir el juicio visual humano del propietario.
2. **Redeploy manual.** El despliegue a `https://fahed-hermoza-card.fahedhermoza.workers.dev/` lo realiza el propietario con su método actual (dashboard o `wrangler`, fuera del repo); el implementador no tiene credenciales ni ejecuta este paso. Sin redeploy, la verificación live (HTTPS, hashes, MIME de los cinco paths) no puede ejecutarse honestamente.
3. **Vistas previas reales en WhatsApp/Facebook/iMessage.** Estas plataformas cachean por URL y aplican políticas propias de unfurl (`docs/risks-and-open-questions.md`, `docs/specs/deploy-cloudflare-pages.md` § F); un HTML/imagen correctos no garantizan el resultado. Solo una observación real, hecha por una persona en esos clientes, cuenta como evidencia — nunca una afirmación del agente de que "debería funcionar".

El implementador deja estos tres puntos como **criterios de aceptación pendientes y explícitos**, no como tareas que intenta completar por su cuenta. El validador debe rechazar cualquier evidencia que afirme estos tres resultados sin una observación humana registrada (reporte del propietario, capturas, o similar), y debe rechazar cualquier intento de marcar `accepted` sin ellos. Esto es consistente con cómo se cerraron `redesign-footer-contact`, `redesign-qr-panel` y `redesign-share-action`, cuya aceptación final también quedó condicionada a la revisión visual del propietario.

## Validator Checklist

- [ ] Implementation stays within this feature's scope: solo `assets/og-image.jpg` (binario) + `DESIGN.md`/`docs/technical-discovery.md`/`docs/risks-and-open-questions.md` (descripción) + evidencia; `index.html`, `styles.css`, `init.sh` (condiciones de fallo), `share.js`, `scripts.js` y todos los demás assets intactos.
- [ ] Acceptance scenarios 1–5 pasan localmente con evidencia reproducible; scenario 6 se registra explícitamente como pendiente a menos que el propietario ya haya respondido con evidencia real.
- [ ] El nuevo `assets/og-image.jpg` es un JPEG real 1200×630, ≤307 200 bytes (o `[warn]` documentado), distinto de `assets/avatar.jpg`, y no se usa como `<img>` dentro de la Tarjeta.
- [ ] `Sharing metadata production checks:`, `Accessibility checks:` y `Responsive checks:` de `init.sh` no se debilitaron; cualquier edición a `init.sh` es solo textual/comentario, nunca una relajación de condición.
- [ ] `canonical`, `og:url`, `og:image`, `twitter:image` siguen byte-idénticos a la URL pública exacta (`PRODUCTION_URL`/`PRODUCTION_IMAGE_URL`); no se tocó el contrato de metadatos.
- [ ] `feature_list.json`/`PROGRESS.md` no sobreafirman: la feature queda en `passing`, con los tres pendientes owner-dependientes (aprobación visual, redeploy, preview real) registrados explícitamente como no cumplidos, salvo evidencia real de respuesta del propietario.
- [ ] Persistent E2E coverage: no aplica (sin harness E2E en el repo); el spec lo justifica igual que `open-graph-metadata`/`deploy-cloudflare-pages`.
- [ ] No se fabricó ninguna aprobación visual, resultado de preview real ni redeploy; no se afirmó "unfurl verificado" sin observación humana.
- [ ] `DESIGN.md` describe la composición real del binario entregado (no una composición aspiracional distinta de lo commiteado).

## Risks And Open Questions

- **Imagen desactualizada visible en producción hasta el redeploy:** el sitio publicado seguirá mostrando la imagen social antigua hasta que el propietario redeploye; esto es esperado y no bloquea el trabajo local de esta feature.
- **El agente no puede validar "se ve bien":** solo valida forma (dimensiones, tipo, tamaño, distinción del avatar). El riesgo de que la composición no convenza al propietario en la revisión visual sigue abierto hasta su respuesta.
- **Caché de crawlers sociales:** aunque el redeploy y el HTML sean correctos, WhatsApp/Facebook/iMessage pueden servir una vista previa cacheada de la imagen vieja durante un tiempo; el propietario puede necesitar forzar un refresco (p. ej. Facebook Sharing Debugger) — esto se registra como parte del paso 3 de "Owner-Dependent Acceptance", no como un fallo de esta feature.
- **Pendientes operativos previos no resueltos aquí:** `http://` sin redirección a HTTPS y `/PROGRESS.md`/`/AGENTS.md` públicamente servidos (`PROGRESS.md`, sesiones previas) siguen abiertos; esta feature no los corrige y no debe confundirse con ellos.
- **Pregunta abierta:** ¿el propietario prefiere aportar su propio JPEG (Figma/Canva) en lugar del candidato generado por receta reproducible? Si lo hace, el implementador solo necesita validarlo con el mismo gate (forma, dimensiones, tamaño, distinción del avatar) y registrar su origen; no se modifica este spec por ese cambio de autoría del binario.
