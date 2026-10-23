# Feature Implementation Spec: Metadatos Open Graph y Twitter Card

## Source Feature

- `id`: `open-graph-metadata`
- `area`: `sharing`
- `depends_on`: `["page-shell"]` (satisfied: `accepted`)
- `status`: `not_started` (at planning time; this spec does not change it)
- `source`: `feature_list.json`
- `notes`: `DESIGN.md` → `Existing Design Assets`, `Open Design Questions`; `docs/technical-discovery.md` → `Data and Storage`, `Constraints`; `docs/risks-and-open-questions.md` → `Blocking Next Phase`.

## Blocker Summary (read first)

1. **`assets/og-image.jpg` no existe.** El repositorio solo contiene `assets/avatar.jpg`. Este agente no puede generar ni leer imágenes (`DESIGN.md`, `docs/technical-discovery.md`). El implementador **no debe** crear, reutilizar el avatar, redimensionar ni sustituir un binario. La imagen 1200×630 JPEG debe producirla otra herramienta/persona.
2. **La URL pública final de Cloudflare Pages no está definida** (`docs/risks-and-open-questions.md`). No se debe inventar un dominio ni usar `example.com`. Por eso `og:url` y `<link rel="canonical">` **se omiten en esta feature** y quedan para `deploy-cloudflare-pages`.
3. Consecuencia: la feature puede implementar y verificar el contrato de etiquetas, pero **no se considera `accepted`** hasta que existan la imagen y la URL, se absoluticen `og:image`/`twitter:image` y se valide la vista previa real tras publicar. La parte implementable no debe bloquear `./init.sh` (la ausencia del asset se reporta como `[warn]`, no como fallo).

## Goal

Añadir en `<head>` un bloque estable de metadatos Open Graph y Twitter Card, con título, descripción, tipo `profile`, imagen 1200×630, dimensiones, texto alternativo y `twitter:card=summary_large_image`, coherente con el contenido del Perfil definido en `docs/build-brief.md` y con el `<title>` actual (`Fahed Hermoza — Tarjeta digital`).

El objetivo verificable en esta feature es el contrato HTML/gate; la vista previa real al compartir queda condicionada a los dos bloqueos externos y se cierra en `deploy-cloudflare-pages`.

## Non-Goals

- No generar, editar, recortar ni sustituir `assets/og-image.jpg`; no crear placeholders de imagen ni usar `assets/avatar.jpg` como imagen social.
- No definir ni inventar `og:url`, `<link rel="canonical">`, dominio de Cloudflare Pages ni URLs absolutas de producción.
- No añadir `meta name="description"`, `robots`, JSON-LD, `theme-color`, favicon nuevo, `og:audio`/`og:video` ni otras familias de metadatos.
- No cambiar el layout, `styles.css`, tokens, contenido visible, la demo de `link-button-component` ni features de Perfil/Enlaces/Pie.
- No añadir frameworks, bundlers, JS, dependencias, archivos de producto nuevos ni pasos de build.
- No implementar `deploy-cloudflare-pages` ni verificar el preview en WhatsApp/Facebook en esta feature.

## Job Story

When alguien comparte la Tarjeta digital por WhatsApp, redes o mensajería,
I want that the enlace muestre un título, una descripción y una imagen representativos de Fahed,
so the recipient entiende de quién es el enlace antes de abrirlo y la Tarjeta se ve profesional.

## Users And Permissions

- Visitante anónimo: no ve cambios en la página; se beneficia de la vista previa al recibir el enlace.
- Implementador/agente: edita `<head>`, amplía el gate de `init.sh` y registra evidencia y bloqueos.
- Validador: comprueba el contrato de etiquetas, la no regresión de navegador y que no se haya inventado URL ni imagen.

## Acceptance Scenarios

### Scenario 1: Metadatos presentes y coherentes

Given `index.html` servido en `http://localhost:3101`,
When se inspecciona el `<head>` o se leen las etiquetas con DevTools,
Then existen exactamente las etiquetas del contrato (ver `Technical Approach`) con `og:type=profile`, `twitter:card=summary_large_image`, dimensiones `1200`×`630`, `og:title` igual al `<title>` y descripción en español coherente con el Perfil.

### Scenario 2: Política de URL provisional

Given que la URL pública aún no existe,
When se revisa el `<head>`,
Then no hay `og:url`, no hay `<link rel="canonical">` y no aparece ningún dominio inventado; existe un comentario HTML que indica que ambos se añaden en `deploy-cloudflare-pages`. `og:image`/`twitter:image` usan la ruta relativa `assets/og-image.jpg`, documentada como provisional.

### Scenario 3: Imagen social ausente (bloqueo externo)

Given que `assets/og-image.jpg` no existe,
When se carga la página en el navegador y se pide el asset directamente,
Then la página **no** solicita `og-image.jpg` al renderizar (los metadatos no se descargan), no hay errores de consola ni peticiones fallidas atribuibles a la página, `GET /assets/og-image.jpg` responde `404`, `./init.sh` lo reporta como `[warn]` y el bloqueo queda registrado sin crear ningún binario.

### Scenario 4: El gate detecta metadatos rotos

Given una copia temporal de `index.html` sin `og:type`, sin `twitter:card` o con dimensiones distintas de 1200×630,
When se ejecuta `./init.sh`,
Then sale con código distinto de `0`, imprime el check fallido en stderr y no arranca ningún servidor.

### Scenario 5: Sin regresión visual ni de red

Given viewports 390×844 y 1280×800,
When se carga la página con los metadatos nuevos,
Then la geometría de `.card` y el layout no cambian, `scrollWidth == clientWidth`, la consola tiene 0 mensajes y las peticiones siguen siendo las esperadas (`/`, `styles.css`, Google Fonts CSS/WOFF2), sin `/favicon.ico` ni `/assets/og-image.jpg`.

## Repository Research

### Files Inspected

- `AGENTS.md`, `PROGRESS.md`, `feature_list.json` — Definition of Done, estado `page-shell` `accepted`, metadata de `open-graph-metadata` y bloqueos ya registrados.
- `index.html` — `<head>` actual: charset, viewport, `<title>Fahed Hermoza — Tarjeta digital</title>`, `<link rel="icon" href="data:,">`, Google Fonts y `styles.css`; sin ninguna etiqueta OG/Twitter/canonical.
- `styles.css` — 51 tokens y reglas `.page`/`.card`/`.link-button`; esta feature no la modifica.
- `init.sh` — gate acumulativo (`set -euo pipefail`), checks de bootstrap, tokens, componente y page shell; servidor solo con `RUN_SERVE_COMMAND=1` en el puerto 3101.
- `assets/` — solo `avatar.jpg` (460×460); **no existe `og-image.jpg`**.
- `DESIGN.md` — imagen OG 1200×630 `pending`; no hay artefacto de diseño de la imagen; el agente no genera imágenes.
- `docs/build-brief.md`, `docs/domain-model.md`, `CONTEXT.md` — Nombre, Handle, Tagline, contenido en español y una sola vista.
- `docs/technical-discovery.md` — assets esperados, restricción de no generar imágenes y URL pública indefinida.
- `docs/risks-and-open-questions.md` — bloqueo de URL pública, `og-image` pendiente y riesgo de vista previa deficiente.
- `docs/specs/page-shell.md` y `docs/validations/page-shell.md` — formato de spec, gate por `grep`/`awk` y evidencia de no regresión.

### Current State

- No hay metadatos de compartición, ni descripción, ni imagen social.
- `./init.sh` pasa con `page-shell` aceptado y no arranca servidor.
- No existe harness E2E, linter, `package.json` ni build; la verificación es gate + navegador.
- El navegador ya no pide `/favicon.ico` gracias a `<link rel="icon" href="data:,">`.

### Existing Patterns To Follow

- Edición directa de HTML estático, sin scripts ni dependencias.
- Gate no bloqueante en `init.sh`, checks acumulativos, fallo a stderr y sin servidor por defecto.
- Evidencia durable en `feature_list.json` + `PROGRESS.md`; specs y validaciones en `docs/`.
- Puertos de verificación del worktree: 3101.

### Current Gaps

- No hay contrato de metadatos ni gate que detecte `og:*`/`twitter:*` rotos.
- No existe la imagen 1200×630 ni una URL pública para `og:url`/canonical.
- Los crawlers sociales suelen exigir URLs **absolutas** para `og:image`/`twitter:image`; la ruta relativa es una etapa provisional, no una solución final.

## Technical Approach

1. **Insertar el bloque de metadatos en `index.html`**, dentro de `<head>`, después de `<title>` y antes de `<link rel="icon" …>`. Valores exactos (el `&` de la descripción se escribe como `&amp;` para HTML válido; el valor renderizado es `&`):

   ```html
   <!-- Vista previa al compartir. Provisional: og:image/twitter:image son relativas y og:url/canonical se añaden en deploy-cloudflare-pages con la URL pública final. -->
   <meta property="og:title" content="Fahed Hermoza — Tarjeta digital">
   <meta property="og:description" content="Software Engineer &amp; Speaker &amp; Builder. Todos los enlaces de contacto de Fahed en un solo lugar.">
   <meta property="og:type" content="profile">
   <meta property="og:site_name" content="Fahed Hermoza">
   <meta property="og:image" content="assets/og-image.jpg">
   <meta property="og:image:type" content="image/jpeg">
   <meta property="og:image:width" content="1200">
   <meta property="og:image:height" content="630">
   <meta property="og:image:alt" content="Tarjeta digital de Fahed Hermoza">
   <meta name="twitter:card" content="summary_large_image">
   <meta name="twitter:title" content="Fahed Hermoza — Tarjeta digital">
   <meta name="twitter:description" content="Software Engineer &amp; Speaker &amp; Builder. Todos los enlaces de contacto de Fahed en un solo lugar.">
   <meta name="twitter:image" content="assets/og-image.jpg">
   <meta name="twitter:image:alt" content="Tarjeta digital de Fahed Hermoza">
   ```

   - Mantener el orden de atributos `property`/`name` antes de `content` para que el gate pueda usar regex simples.
   - `og:title` replica el `<title>`; no se crea un segundo título distinto.
   - No añadir `og:url` ni canonical: la URL final no existe. Tampoco añadir `twitter:site`/`twitter:creator` (no hay handle de X definido; el Handle del proyecto es de Instagram).
   - No incluir `assets/og-image.jpg` en el HTML como `<img>`; es solo metadato (no genera petición desde la página).

2. **Ampliar `init.sh`** con una sección `Sharing metadata checks:` después de los checks de page shell y antes del comando de servido. Usar `grep -qE` con orden fijo de atributos y estas comprobaciones bloqueantes:
   - `og:title` y `og:description` presentes con contenido no vacío.
   - `og:type` con `content="profile"`.
   - `og:site_name` con contenido no vacío.
   - `og:image` y `twitter:image` con `content` que termine en `assets/og-image.jpg` (regex `content="([^"]*/)?assets/og-image\.jpg"`), de modo que el futuro cambio a URL absoluta no rompa el gate.
   - `og:image:type=image/jpeg`, `og:image:width=1200`, `og:image:height=630`.
   - `og:image:alt`, `twitter:image:alt` con contenido no vacío.
   - `twitter:card=summary_large_image`.
   - `twitter:title` y `twitter:description` con contenido no vacío.
   - Salida agregada esperada: `[ok] sharing metadata contract (14/14)`; si falta algo, imprimir cada clave faltante en stderr y terminar con `Harness status: FAILED - sharing metadata contract is missing N of 14 required tags`, exit `1`, sin servidor.

3. **Añadir avisos no bloqueantes (nunca `exit 1`)** inmediatamente después del contrato:
   - `[ok] assets/og-image.jpg exists` si existe; si no, `[warn] assets/og-image.jpg is missing (link preview image blocker; produce it with an external tool)`.
   - `[warn] og:image/twitter:image use a relative path (must be absolute after deploy)` si el `content` no empieza por `http`.
   - `[warn] og:url/canonical pending public URL (deploy-cloudflare-pages)` si no existen; `[ok] og:url and canonical declared` si existen.
   - Estos avisos documentan los bloqueos sin impedir que otras features sigan usando `./init.sh`.

4. **No tocar `styles.css`**, tokens, `DESIGN.md` ni el contenido visible.

5. **Registrar evidencia y bloqueos** en `feature_list.json`, `PROGRESS.md` y `docs/risks-and-open-questions.md` (ver `Evidence To Capture`).

## Expected File Changes

- `index.html` — modificar; insertar el bloque de 14 metadatos y un comentario de provisionalidad en `<head>`.
- `init.sh` — modificar; añadir `Sharing metadata checks:` bloqueantes y avisos no bloqueantes; conservar todos los checks previos y el servidor bajo `RUN_SERVE_COMMAND=1` en 3101.
- `feature_list.json` — modificar; evidencia del implementador y estado (ver `Acceptance Criteria`); sin tocar otras features.
- `PROGRESS.md` — modificar; estado verificado, sesión y bloqueos vigentes.
- `docs/risks-and-open-questions.md` — modificar; documentar que `og:image`/`twitter:image` relativas son provisionales y que el preview queda bloqueado por asset + URL.
- `docs/specs/open-graph-metadata.md` — crear; este spec (planner).
- **No** se crean ni modifican `assets/*`, `styles.css`, `DESIGN.md` ni otros docs de discovery.

## Visual Design Impact

- UI involved: no visual layout change. Afecta a la tarjeta de vista previa (unfurl) al compartir el enlace.
- Design source: `DESIGN.md` (`Existing Design Assets`, `Open Design Questions`) para el requisito 1200×630 y la identidad; el contenido de la imagen no está diseñado todavía.
- Screens or states affected: única vista, sin cambios; estado externo de vista previa al compartir.
- New design artifact required: **sí, externo a esta feature** — `assets/og-image.jpg` (JPEG 1200×630). Debe producirlo otra herramienta/persona, coherente con Nombre/Handle/Tagline y la paleta de `DESIGN.md`. No se inventa ni se genera aquí.

## Durable Documentation Impact

- `ARCHITECTURE.md`: not needed — no cambian stack, capas ni boundaries; sigue siendo HTML/CSS estáticos.
- `CONSTRAINTS.md`: not needed — no se introduce una regla MUST/MUST NOT nueva; la prohibición de inventar URL/imagen ya está en `docs/risks-and-open-questions.md` y `docs/technical-discovery.md`.
- `AGENTS.md`: not needed — el camino de arranque y las reglas operativas no cambian; solo se amplía el gate.
- Other docs:
  - `docs/risks-and-open-questions.md` — update; dejar constancia de la etapa relativa y del bloqueo de preview.
  - `docs/technical-discovery.md` — not needed; la lista de assets no cambia (la imagen sigue pendiente).
  - `DESIGN.md` — not needed; el estado de la `og-image` sigue siendo `pending` hasta que exista el binario.

## Implementation Plan

1. Insertar el bloque exacto de metadatos en `index.html` y el comentario de provisionalidad.
2. Ampliar `init.sh` con los checks bloqueantes y los tres avisos no bloqueantes.
3. Probar sintaxis, gate correcto y casos negativos en copias temporales fuera del repo.
4. Servir en 3101 y verificar HTML estático, navegador 390×844/1280×800, ausencia de peticiones de `og-image` y estado 404 del asset como bloqueo conocido.
5. Registrar evidencia, bloqueos y estado en `feature_list.json`, `PROGRESS.md` y `docs/risks-and-open-questions.md`.

## Implementation Tasks

- [ ] Añadir las 14 etiquetas OG/Twitter con los valores exactos y el comentario de provisionalidad.
- [ ] Confirmar que no se añaden `og:url`, canonical, dominios inventados, `meta description` ni otros metadatos fuera de alcance.
- [ ] Añadir `Sharing metadata checks:` a `init.sh` con contrato 14/14 y mensajes de fallo en stderr.
- [ ] Añadir los avisos no bloqueantes de asset ausente, imagen relativa y URL pública pendiente.
- [ ] Probar `bash -n init.sh` y `./init.sh` (exit `0`, checks previos intactos, sin servidor).
- [ ] Probar los tres casos negativos en copia temporal: sin `og:type`, sin `twitter:card`, ancho `1000`.
- [ ] Verificar en navegador 390×844 y 1280×800 sin regresión, sin errores de consola y sin peticiones de `og-image`/`favicon.ico`.
- [ ] Comprobar `GET /assets/og-image.jpg` → `404` y registrar el bloqueo sin crear el archivo.
- [ ] Actualizar `feature_list.json`, `PROGRESS.md` y `docs/risks-and-open-questions.md`.

## Verification Plan

### Gate

- `bash -n init.sh` → sintaxis OK.
- `./init.sh` → `Harness status: bootstrapped`, checks previos `[ok]`, `[ok] sharing metadata contract (14/14)`, avisos `[warn]` esperados (asset ausente, imagen relativa, URL pendiente), exit `0`, sin servidor.
- Casos negativos en copia temporal (repo intacto; eliminar la copia al terminar):
  - quitar `og:type` → exit `1`, stderr con la clave faltante y `FAILED - sharing metadata contract is missing 1 of 14 required tags`.
  - quitar `twitter:card` → exit `1` con el mismo patrón.
  - cambiar `og:image:width` de `1200` a `1000` → exit `1`.
  - cada caso sin listener en 3101.
- `lsof -nP -iTCP:3101 -sTCP:LISTEN` no debe mostrar procesos al terminar.

### Static HTML

- `python3 -m http.server 3101 --directory .` y `curl -s http://localhost:3101/` deben devolver las 14 etiquetas con los valores del contrato.
- Verificar que no aparecen `property="og:url"`, `rel="canonical"`, `example.com` ni dominios inventados.
- Verificar `GET /assets/og-image.jpg` → `404` **hoy** (bloqueo conocido), sin crear el archivo.
- Cuando el asset exista (fuera de esta feature): `sips -g pixelWidth -g pixelHeight assets/og-image.jpg` (macOS) o `file` debe confirmar JPEG 1200×630 y `curl -sI` debe responder `200 image/jpeg`.

### Browser

- `python3 -m http.server 3101 --directory .` (detener al terminar) y abrir `http://localhost:3101`.
- 390×844: consola con 0 mensajes; red esperada (`/`, `styles.css`, Google Fonts CSS/WOFF2), sin `/favicon.ico` ni `/assets/og-image.jpg`; sin scroll horizontal; `.card` conserva ancho 358px y posición x=16.
- 1280×800: consola con 0 mensajes; red esperada; `.card` conserva 400px y centrado (x=440), sin scroll horizontal.
- Leer los metadatos con `document.querySelector` para confirmar el contenido renderizado (`&amp;` se lee como `&`).
- E2E: no aplica — no existe harness E2E y añadirlo introduciría dependencias prohibidas. La cobertura es gate no bloqueante + verificación estática + navegador.

### `init.sh` Contract

- Sigue ejecutando el gate no bloqueante y **no** arranca servidores salvo `RUN_SERVE_COMMAND=1`.
- No elimina ni debilita checks previos (bootstrap, tokens, componente, page shell).
- Los bloqueos externos se reportan como `[warn]` y no cambian el exit code.

## Evidence To Capture

- Salida de `./init.sh` correcto (exit `0`, contrato 14/14 y `[warn]` de asset/URL) y de los tres casos negativos con exit `1`.
- Extracto del `<head>` servido con las 14 etiquetas y confirmación de ausencia de `og:url`/canonical/dominios inventados.
- Resultado de navegador 390×844 y 1280×800: consola 0 mensajes, lista de peticiones sin `og-image` ni favicon, geometría de `.card` y `scrollWidth == clientWidth`.
- `GET /assets/og-image.jpg` → `404` y texto del `[warn]`; confirmación explícita de que no se creó ni sustituyó ningún binario.
- Estado de `feature_list.json` (evidencia + bloqueo), sesión en `PROGRESS.md` y nota en `docs/risks-and-open-questions.md`.
- `feature_list.json` no debe marcar `accepted` mientras falten `assets/og-image.jpg` y la URL pública; si el implementador deja la parte de markup verificada, usar `passing` y dejar el bloqueo escrito.

## Risks And Mitigations

- **`og:image`/`twitter:image` relativas:** los crawlers sociales suelen requerir URL absoluta; el preview puede no mostrar imagen aunque el HTML sea correcto. Mitigación: comentario HTML, `[warn]` en `init.sh`, nota en riesgos y tarea explícita en `deploy-cloudflare-pages` para absolutizar.
- **Asset ausente:** `assets/og-image.jpg` no existe y no puede generarse aquí. Mitigación: `[warn]` no bloqueante, prohibición de placeholders, bloqueo registrado y aceptación condicionada.
- **URL pública indefinida:** no se puede añadir `og:url`/canonical ni probar el unfurl real. Mitigación: omitirlos, no inventar dominios y cerrarlos en `deploy-cloudflare-pages`.
- **Duplicación de copy:** título/descripción podrían divergir del contenido visible futuro. Mitigación: `og:title` replica el `<title>` y la descripción resume el Perfil de `docs/build-brief.md`; el gate exige presencia, la evidencia fija los valores.
- **Falsa sensación de preview validado:** un HTML correcto no prueba la vista previa real. Mitigación: el spec separa contrato (esta feature) de unfurl real (deploy).
- **Ampliación del gate demasiado rígida:** un futuro dominio rompería checks. Mitigación: regex de imagen que acepta ruta relativa o absoluta terminada en `assets/og-image.jpg`; `og:url`/canonical solo se avisan.

## Acceptance Criteria

- [ ] `index.html` contiene las 14 etiquetas exactas, sin `og:url`, canonical, dominios inventados ni metadatos fuera de alcance.
- [ ] `og:title` coincide con el `<title>`; descripción en español coherente con el Perfil; `og:type=profile`; `twitter:card=summary_large_image`.
- [ ] `og:image`/`twitter:image` referencian `assets/og-image.jpg`; dimensiones `1200`×`630`; tipo `image/jpeg`; alt no vacío.
- [ ] `./init.sh` detecta metadatos rotos (exit `1`, stderr, sin servidor) y en estado correcto sale `0` con `[ok] sharing metadata contract (14/14)` y `[warn]` esperados.
- [ ] Navegador 390×844 y 1280×800 sin errores de consola, sin peticiones fallidas de la página, sin petición de `og-image`/favicon y sin regresión de layout.
- [ ] No se crea ni modifica ningún binario; `assets/og-image.jpg` sigue ausente y el bloqueo está registrado.
- [ ] `feature_list.json`, `PROGRESS.md` y `docs/risks-and-open-questions.md` reflejan evidencia y bloqueos.
- [ ] La feature **no** se marca `accepted` mientras falten imagen y URL pública (salvo decisión explícita del orquestador de diferir el unfurl a `deploy-cloudflare-pages`).

## Validator Checklist

- [ ] Implementation stays within this feature's scope (only `<head>` metadata + gate/evidence).
- [ ] Acceptance scenarios 1, 2, 4 and 5 pass; scenario 3 passes as a documented blocker without binary creation.
- [ ] Verification evidence is present, including `./init.sh`, negative cases and both browser viewports.
- [ ] Persistent E2E coverage was added/updated when an E2E harness exists, or the spec explains why it is not needed (no harness exists).
- [ ] `feature_list.json` and `PROGRESS.md` were updated correctly and do not overstate acceptance.
- [ ] No unrelated product behavior or extra feature work was added (`styles.css`, tokens, visible content, demo, design docs intact).
- [ ] No invented public URL, no `og:url`/canonical, no placeholder/absolute fake domain.
- [ ] No generated or substituted image; `assets/og-image.jpg` blocker remains explicit.
- [ ] Gate remains non-blocking for external blockers, preserves previous checks and does not start servers by default.

## Assumptions And Open Questions

### Assumptions

- Los navegadores objetivo no descargan `og:image` al renderizar; por eso el asset ausente no genera una petición fallida de la página.
- El contenido del Perfil seguirá siendo Nombre "Fahed Hermoza", Handle "@fahedhermoza" y Tagline "Software Engineer & Speaker & Builder" (`docs/build-brief.md`).
- Cloudflare Pages servirá el sitio desde la raíz, por lo que `/assets/og-image.jpg` será la ruta final del asset.
- `1rem = 16px` y los viewports de verificación son 390×844 y 1280×800.

### Open Questions

- **Bloqueante:** ¿quién y con qué herramienta produce `assets/og-image.jpg` 1200×630, y cuál es su contenido visual definitivo? (`DESIGN.md` lo deja `pending`).
- **Bloqueante:** ¿cuál es la URL pública final de Cloudflare Pages? Sin ella no se añaden `og:url`/canonical ni se absolutizan las imágenes.
- ¿Se añadirá `twitter:site`/`twitter:creator` si Fahed define un handle de X? No aplica al MVP actual.
- ¿Se mantendrá `og:type=profile` o se cambiará a `website`? Se elige `profile` por representar a una persona; no bloquea.
- ¿Se acepta el unfurl real como criterio de `deploy-cloudflare-pages` o se exige antes de aceptar esta feature? El spec recomienda cerrarlo en deploy y no marcar `accepted` antes.
