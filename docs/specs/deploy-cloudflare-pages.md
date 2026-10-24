# Feature Implementation Spec: Publicación pública en Cloudflare Workers (static assets)

## Source Feature

- `id`: `deploy-cloudflare-pages`
- `area`: `operations`
- `depends_on`: `["save-contact-vcard", "page-footer", "open-graph-metadata", "accessibility-baseline", "responsive-baseline"]` — todas `accepted`.
- `status`: `not_started` (al planificar; este spec no lo cambia).
- `source`: `feature_list.json`

## Decisión durable: plataforma y nombre

El propietario ya publicó manualmente en **Cloudflare Workers con static assets**
(`https://fahed-hermoza-card.fahedhermoza.workers.dev/`), no en Cloudflare Pages. Decisión:

1. **Se conserva el `id` `deploy-cloudflare-pages`** por trazabilidad histórica
   (`open-graph-metadata`, `PROGRESS.md`, `feature_list.json`).
2. **Se re-scopea el título** a `Publicación pública en Cloudflare Workers (static assets)` y se
   actualizan `title`, `user_visible_behavior` y `notes` en `feature_list.json`.
3. En documentación durable nueva o actualizada se usa **Cloudflare Workers (static assets)**;
   "Cloudflare Pages" solo queda como nombre histórico del id o en specs/validaciones cerradas.
   No se crea un proyecto Pages ni se afirma que exista.
4. No se inventa otro dominio, proyecto, cuenta ni URL.

## Precondiciones y límites

- Live verificado (2026-10-23): `/`, `/styles.css`, `/assets/avatar.jpg` y
  `/assets/fahedhermoza.vcf` → 200; `/assets/og-image.jpg` → 404; HTTPS válido; `http://` raíz
  también 200 (sin redirección forzada); `/index.html` → 307 a `/`.
- El HTML live es byte-idéntico a `index.html` (`145b2028…`); avatar (`b73575ae…`) y vCard
  (`910aa368…`) también coinciden. Falta contenido local (metadatos + imagen) y redeploy.
- No se conoce en el repo el método exacto del despliegue manual (dashboard vs `wrangler`): no
  hay `wrangler.toml`, CI ni `package.json`. El redeploy lo hace el propietario; el implementador
  verifica el resultado y no inventa credenciales, configuración ni pipeline.
- La imagen OG requiere aprobación visual humana; el agente no interpreta imágenes.
- El unfurl real no se puede garantizar desde el repo: se registra como comprobación manual.

## Goal

La Tarjeta queda publicada en su URL real de Workers con HTTPS y sin build, y esa URL queda
cableada en `canonical`, `og:url` y en las URLs absolutas de `og:image`/`twitter:image`.
`assets/og-image.jpg` existe como JPEG 1200×630 públicamente servido, y `init.sh` detecta
cualquier regresión de URL, asset o plataforma.

## Non-Goals

- No migrar a Cloudflare Pages, crear un proyecto Pages, añadir dominio/DNS/TLS ni cambiar
  "Always Use HTTPS" desde el repo (solo se recomienda).
- No añadir CI, GitHub Actions, `wrangler.toml`, tokens, secretos, `package.json` ni dependencias.
- No añadir `_headers`, `_redirects`, 404, `robots.txt`, `sitemap.xml`, JSON-LD, `meta
  description`, analítica, `theme-color` ni favicon nuevo.
- No cambiar `styles.css`, tokens, layout, contenido visible, vCard, avatar, JS, frameworks ni
  bundlers.
- No garantizar el unfurl de una app concreta ni probar la importación de la vCard.
- No reescribir specs/validaciones históricas que mencionan "Cloudflare Pages".

## Job Story

When Fahed comparte la Tarjeta por NFC, QR o mensaje,
I want que la URL pública real y la imagen social estén cableadas y disponibles,
so the link abre correctamente y la vista previa identifica a Fahed sin metadatos provisionales.

**Usuarios:** visitante anónimo (abre por HTTPS, sin permisos); propietario (redeploya y aprueba
la imagen); implementador (edita `<head>`, asset, gate y docs); validador (reproduce gate y live).

## Acceptance Scenarios

### 1. Metadatos de producción exactos

Given `index.html` con la URL pública real,
When se inspecciona el `<head>`,
Then `canonical` y `og:url` son exactamente `https://fahed-hermoza-card.fahedhermoza.workers.dev/`
y `og:image`/`twitter:image` son
`https://fahed-hermoza-card.fahedhermoza.workers.dev/assets/og-image.jpg`; no quedan rutas
relativas ni comentarios de "provisional".

### 2. Gate local sin regresión

Given el repo correcto,
When se ejecuta `bash -n init.sh && ./init.sh`,
Then sale `0`, conserva los checks previos y añade `[ok] production URL metadata (4/4)` y
`[ok] assets/og-image.jpg exists (JPEG 1200x630, …)`; no arranca servidor.

### 3. Gate detecta regresiones

Given copias temporales fuera del repo,
When se rompe `canonical`, `og:url`, una imagen absoluta o el JPEG 1200×630,
Then `./init.sh` sale `1`, imprime la causa en stderr y no arranca listener.

### 4. Asset OG válido y público

Given `assets/og-image.jpg`,
When se valida localmente y se pide en la URL pública,
Then es JPEG real 1200×630 (objetivo ≤300 KiB) y responde `200 image/jpeg` con los mismos bytes.

### 5. Live HTTPS y assets completos

Given el redeploy,
When se piden `/`, `/styles.css`, `/assets/avatar.jpg`, `/assets/og-image.jpg` y
`/assets/fahedhermoza.vcf`,
Then todos responden 200 por HTTPS; HTML y assets coinciden byte a byte con local; la vCard
conserva `text/x-vcard`/`text/vcard` y su cuerpo íntegro.

### 6. Unfurl declarado con límites

Given la URL y la imagen publicadas,
When se intenta una vista previa manual en WhatsApp/Facebook,
Then el resultado se registra tal cual y no se afirma éxito sin observación real.

## Repository Research

### Files Inspected

- `feature_list.json` — `deploy-cloudflare-pages` en `not_started`, dependencias `accepted`;
  `open-graph-metadata` aceptada con el unfurl diferido aquí.
- `PROGRESS.md` — 105 `[ok]` + 3 `[warn]` heredados; bloqueos de `og-image` y URL.
- `index.html` — 14 etiquetas OG/Twitter, imágenes relativas, sin `og:url`/canonical.
- `init.sh` — 1946 líneas; `Sharing metadata checks:` 14/14 + 3 `[warn]`; servidor solo con
  `RUN_SERVE_COMMAND=1`; hint en 3502.
- `assets/` — `avatar.jpg` (JPEG 460×460) y `fahedhermoza.vcf`; no existe `og-image.jpg`.
- `CONSTRAINTS.md` — base AA, vCard estática y baseline responsive que no deben debilitarse.
- `docs/specs/open-graph-metadata.md`, `docs/validations/open-graph-metadata.md` — contrato
  aceptado y bloqueos diferidos explícitamente.
- `docs/technical-discovery.md`, `docs/risks-and-open-questions.md`, `docs/build-brief.md`,
  `docs/domain-model.md`, `DESIGN.md` — despliegue, assets y nomenclatura.

### Patterns And Gaps

- HTML estático sin build; gate acumulativo con fallo a stderr, `exit 1` y sin servidor.
- Evidencia durable en `feature_list.json` + `PROGRESS.md`; no hay harness E2E.
- Gaps: sin `canonical`/`og:url`; imágenes relativas; asset ausente; los 3 `[warn]` no bloquean;
  documentación aún dice "Cloudflare Pages" y "URL indefinida".

## Technical Approach

### A. Identidad de producción

Una sola base, sin variantes:

- Origen: `https://fahed-hermoza-card.fahedhermoza.workers.dev`
- Raíz: `https://fahed-hermoza-card.fahedhermoza.workers.dev/` (slash final)
- Imagen: `https://fahed-hermoza-card.fahedhermoza.workers.dev/assets/og-image.jpg`

`canonical` y `og:url` deben ser idénticos y con slash final. No usar `/index.html`, query
strings, `www`, `http://` ni otro dominio. `init.sh` declara `PRODUCTION_ORIGIN`,
`PRODUCTION_URL` y `PRODUCTION_IMAGE_URL`; un cambio de dominio actualiza HTML y gate juntos.

### B. Bloque exacto de `<head>`

Sustituir el comentario provisional y el bloque actual por (orden `property`/`name` antes de
`content`):

```html
    <link rel="canonical" href="https://fahed-hermoza-card.fahedhermoza.workers.dev/">
    <!-- Vista previa al compartir. Producción: Cloudflare Workers static assets; canonical, og:url e imágenes usan la URL pública real. -->
    <meta property="og:title" content="Fahed Hermoza — Tarjeta digital">
    <meta property="og:description" content="Software Engineer &amp; Speaker &amp; Builder. Todos los enlaces de contacto de Fahed en un solo lugar.">
    <meta property="og:type" content="profile">
    <meta property="og:site_name" content="Fahed Hermoza">
    <meta property="og:url" content="https://fahed-hermoza-card.fahedhermoza.workers.dev/">
    <meta property="og:image" content="https://fahed-hermoza-card.fahedhermoza.workers.dev/assets/og-image.jpg">
    <meta property="og:image:type" content="image/jpeg">
    <meta property="og:image:width" content="1200">
    <meta property="og:image:height" content="630">
    <meta property="og:image:alt" content="Tarjeta digital de Fahed Hermoza">
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="Fahed Hermoza — Tarjeta digital">
    <meta name="twitter:description" content="Software Engineer &amp; Speaker &amp; Builder. Todos los enlaces de contacto de Fahed en un solo lugar.">
    <meta name="twitter:image" content="https://fahed-hermoza-card.fahedhermoza.workers.dev/assets/og-image.jpg">
    <meta name="twitter:image:alt" content="Tarjeta digital de Fahed Hermoza">
```

No añadir `twitter:site`/`twitter:creator`, `og:image:secure_url`, `og:locale`, `meta
description` ni JSON-LD. `og:image` no se usa como `<img>` de la página.

### C. Producción y validación de `assets/og-image.jpg`

**Preferido:** el propietario aporta un JPEG 1200×630 aprobado, creado con su herramienta
(Figma/Canva/Pencil) usando tokens de `DESIGN.md`.

**Receta reproducible sin dependencias de runtime** (Chrome DevTools ya usado + `sips` macOS):

1. Crear un HTML temporal **no commiteado** en `/tmp/og-image.html` con
   `html, body { width: 1200px; height: 630px; margin: 0; overflow: hidden; }`.
2. Composición: fondo `#f7f9ff`; tarjeta blanca 880×440 centrada, radio 24px, borde
   `1px solid rgba(0,0,0,0.04)` y sombra
   `0 18px 45px -10px rgba(25,30,48,0.08), 0 8px 16px -6px rgba(25,30,48,0.03)`; avatar
   opcional 128×128 circular; Nombre 64px/600 `#2d3139`; Handle 30px/400 `#6b7280`; Tagline
   26px/400 `#6b7280`. Textos exactos: `Fahed Hermoza`, `@fahedhermoza`,
   `Software Engineer & Speaker & Builder` (en HTML, `&amp;`). Plus Jakarta Sans o fallback del
   sistema. No usar el avatar como imagen completa ni colores/tipografías fuera de `DESIGN.md`.
3. Abrir en Chrome, emular viewport `1200x630x1`, capturar JPEG calidad ~90 sin `fullPage` y
   guardar en `assets/og-image.jpg`. Si no mide 1200×630, corregir viewport/DPR y repetir.
4. Validar: `sips -g pixelWidth -g pixelHeight -g format assets/og-image.jpg` → `1200`, `630`,
   `jpeg`; `file assets/og-image.jpg` → `JPEG image data, ... 1200x630`; `wc -c` → objetivo
   ≤307200 bytes; `shasum -a 256` → registrar y confirmar que no es idéntico a `avatar.jpg`.
5. Aprobación visual humana antes de commitear; no se acepta placeholder ni captura de la página.

### D. Gate sin debilitar checks

En `init.sh`, después de `[ok] sharing metadata contract (14/14)` y antes de
`Instagram link checks:`:

1. **Conservar intacto** el array de 14 patrones y su mensaje 14/14.
2. Añadir `Sharing metadata production checks:` con 4 comprobaciones exactas (`grep -qF`) desde
   las constantes:
   - `<link rel="canonical" href="${PRODUCTION_URL}">`
   - `<meta property="og:url" content="${PRODUCTION_URL}">`
   - `<meta property="og:image" content="${PRODUCTION_IMAGE_URL}">`
   - `<meta name="twitter:image" content="${PRODUCTION_IMAGE_URL}">`

   Salida: `[ok] production URL metadata (4/4)`; si falta, stderr con la clave y
   `fail "production URL metadata is missing N of 4 required tags"`. Construir los patrones con
   comillas dobles para que `${PRODUCTION_URL}` y `${PRODUCTION_IMAGE_URL}` se expandan; no usar
   comillas simples.
3. Sustituir los 3 `[warn]` heredados por checks bloqueantes:
   - `[ok] assets/og-image.jpg exists (JPEG 1200x630, N bytes)` con `file -b` +
     `grep -qE 'JPEG image data'` + `grep -qE '1200x630'`; si falta, está vacío, no es JPEG o no
     mide 1200×630, `fail`. Mantener `[warn]` solo si supera 307200 bytes.
   - `[ok] og:image/twitter:image use the production absolute URL`.
   - `[ok] og:url and canonical declared`.
   - `command -v file >/dev/null 2>&1 || fail "the 'file' command is required for the og-image gate"`.
   - `cmp -s assets/og-image.jpg assets/avatar.jpg` → `fail` (no reutilizar el avatar).
4. El gate sigue local y estático: no hace HTTP, no arranca servidor salvo
   `RUN_SERVE_COMMAND=1`, conserva el hint 3502.

### E. Redeploy y verificación live

El propietario redeploya con su método manual actual; el implementador deja `./init.sh` verde y
el asset listo antes. Después:

```bash
BASE="https://fahed-hermoza-card.fahedhermoza.workers.dev"

curl -sS -o /dev/null -w '%{http_code} %{content_type}\n' "$BASE/"
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "$BASE/index.html"  # 307 -> $BASE/
curl -sS -o /dev/null -w '%{http_code} %{redirect_url}\n' "http://fahed-hermoza-card.fahedhermoza.workers.dev/"

curl -sS "$BASE/" | grep -nE 'rel="canonical"|og:url|og:image|twitter:image'

for p in / /styles.css /assets/avatar.jpg /assets/og-image.jpg /assets/fahedhermoza.vcf; do
  printf '%s ' "$p"; curl -sS -o /dev/null -w '%{http_code} %{content_type} %{size_download}\n' "$BASE$p"
done

for f in index.html styles.css assets/avatar.jpg assets/og-image.jpg assets/fahedhermoza.vcf; do
  local=$(shasum -a 256 "$f" | awk '{print $1}')
  [ "$f" = "index.html" ] && url="$BASE/" || url="$BASE/$f"
  remote=$(curl -sS "$url" | shasum -a 256 | awk '{print $1}')
  printf '%s local=%s remote=%s\n' "$f" "$local" "$remote"
done
```

Criterios: `/` 200 `text/html`; cinco assets 200; `og-image` `image/jpeg` con hash idéntico;
vCard `text/x-vcard`/`text/vcard` con hash idéntico; HTML live con las 16 etiquetas y hash
idéntico. Usar `?cb=$(date +%s)` solo para saltar caché de verificación; nunca en
`canonical`/`og:url`. `cf-cache-status: HIT` y `cache-control: public, max-age=0,
must-revalidate` no son errores.

### F. Límites del unfurl real

Se puede probar: HTML público con tags exactos, `og:image` público 200 `image/jpeg`, HTTPS y sin
autenticación. **No** se puede garantizar que WhatsApp/Facebook/iMessage rendericen la tarjeta:
cachean por URL y aplican políticas propias. Prueba manual: Facebook Sharing Debugger sobre
`$BASE/` y un mensaje de prueba de WhatsApp (si hace falta, `?v=timestamp` solo para refrescar).
Registrar el resultado; si falla, diagnosticar tags/imagen y no afirmar "unfurl verificado" sin
evidencia. Un gate verde no demuestra unfurl.

## Expected File Changes

| Archivo | Acción | Motivo |
|---|---|---|
| `index.html` | modificar | canonical, `og:url`, URLs absolutas, retirar comentario provisional |
| `assets/og-image.jpg` | crear | JPEG 1200×630 aprobado |
| `init.sh` | modificar | constantes, 4 checks exactos, asset bloqueante, sin debilitar checks |
| `feature_list.json` | modificar | re-scope de título/notes, `verification`, `status`, evidencia |
| `PROGRESS.md` | modificar | estado live, URL, sesión, bloqueos resueltos |
| `docs/technical-discovery.md` | actualizar | Workers, assets, receta OG, verificación live |
| `docs/risks-and-open-questions.md` | actualizar | resolver bloqueos; riesgos de caché/MIME/HTTP/unfurl |
| `docs/domain-model.md`, `docs/build-brief.md` | actualizar | "Publicada" en Workers; criterio de publicación |
| `DESIGN.md` | actualizar | asset OG disponible + composición |
| `CONSTRAINTS.md` | actualizar | origen único, URL absolutas, imagen 1200×630, no inventar dominio |
| `docs/specs/deploy-cloudflare-pages.md` | crear | este spec |

No se modifican `styles.css`, tokens, layout, contenido visible, `avatar.jpg`,
`fahedhermoza.vcf` ni `AGENTS.md`; no se crean `wrangler.toml`, `_headers`, `_redirects`, CI,
`package.json` ni dependencias. `ARCHITECTURE.md` no es necesario (sin cambio de capas/runtime).

## Visual And Documentation Impact

- UI: no cambia la página visible; se añade la tarjeta de unfurl externa.
- Diseño: `DESIGN.md`; nuevo `assets/og-image.jpg` con la composición de la sección C, aprobación
  humana y sin colores/tipografías fuera de la paleta.
- Docs durables: `CONSTRAINTS.md` (nueva sección de publicación), `DESIGN.md`, los cuatro docs de
  discovery y `PROGRESS.md`. `AGENTS.md` no cambia (arranque/DoD intactos). Specs históricas no
  se reescriben; este spec explica la correspondencia Pages → Workers.

## Implementation Plan And Tasks

1. Confirmar URL y método de redeploy; registrar que la plataforma es Workers static assets.
2. Producir/aprobar `assets/og-image.jpg` y validarlo.
3. Actualizar `index.html` con el bloque de la sección B.
4. Fortalecer `init.sh` (sección D).
5. Ejecutar gate, negativos, navegador 390×844/1280×800 y Lighthouse móvil.
6. Pedir redeploy y verificar live (sección E).
7. Intentar unfurl y registrar límites (sección F).
8. Actualizar docs, `feature_list.json` (`passing`, no `accepted`) y `PROGRESS.md`.

- [ ] Re-scopear `feature_list.json` y registrar la URL real.
- [ ] Crear/aprobar `assets/og-image.jpg` 1200×630.
- [ ] Actualizar `<head>` con canonical/`og:url`/imágenes absolutas.
- [ ] Añadir constantes, `production URL metadata (4/4)` y checks de asset a `init.sh`.
- [ ] Probar `bash -n init.sh`, `./init.sh` sin servidor y negativos (canonical, `og:url`,
      imagen relativa, 1000×630, asset ausente) con exit 1 y sin listener.
- [ ] Verificar 390×844/1280×800 sin errores de consola/red, sin scroll horizontal, `og-image`
      no solicitada por la página; Lighthouse móvil ≥95 sin `critical`/`serious`.
- [ ] Redeploy y verificación live (HTTPS, 5 assets, hashes, MIME, `/index.html` 307).
- [ ] Intentar unfurl y registrar resultado/límites.
- [ ] Actualizar docs durables y dejar evidencia en `feature_list.json`/`PROGRESS.md`.

## Verification Plan

- `bash -n init.sh` → sin errores.
- `./init.sh` → exit `0`, checks previos `[ok]`, 14/14 + 4/4 + asset, sin los 3 `[warn]`
  heredados, sin servidor.
- Negativos en copias temporales fuera del repo (eliminar al terminar): cada mutación → exit 1,
  stderr concreto y sin listener en 3502.
- Local: `python3 -m http.server 3502 --directory .`; 390×844 y 1280×800 con recarga fresca,
  consola 0, red esperada, `scrollWidth == clientWidth`, `.card` sin cambios; leer
  `document.querySelector` para confirmar las 16 etiquetas.
- Live: bloque de la sección E; registrar `cache-control`, `cf-cache-status` y el status de
  `http://`. No ejecutar `./init.sh` contra la URL live.
- E2E: no aplica; no existe harness y añadirlo introduciría dependencias prohibidas por
  `docs/technical-discovery.md`. Cobertura = gate + Chrome DevTools + Lighthouse + `curl` live.

## Edge Cases

- **Trailing slash:** canonical/`og:url` con `/` final; `/index.html` ya redirige 307 a `/`. No
  canonicalizar a `/index.html` ni añadir `_redirects`.
- **Query strings:** sin query en canonical/`og:url`; `?cb=`/`?v=` solo para verificación/refresco.
- **Caché:** HTML/assets `max-age=0, must-revalidate`; `cf-cache-status: HIT` puede aparecer.
  Tras el redeploy, verificar con cache-busting; el unfurl social tiene caché propia no purgable.
- **Plataforma:** Workers static assets ≠ Pages; el id histórico no autoriza a crear Pages.
- **Cambio de dominio:** actualizar `PRODUCTION_ORIGIN` y las 4 URLs en el mismo cambio; no
  mezclar orígenes.
- **Asset OG:** 404, MIME distinto de `image/jpeg`, dimensiones distintas, tamaño excesivo o
  copia del avatar deben fallar el gate; el navegador no solicita `og-image` al renderizar.
- **vCard MIME:** hoy `text/x-vcard`; `text/vcard` aceptable. No añadir `_headers` ni JS;
  `download` + `.vcf` sigue siendo el mecanismo.
- **HTTPS:** funciona; `http://` hoy responde 200. "Always Use HTTPS" es ajuste de Cloudflare,
  recomendado pero no exigido para aceptar.
- **Unfurl:** puede fallar por caché/política aunque el HTML sea correcto; no declarar éxito sin
  observación.
- **Local vs live:** gate verde no prueba redeploy; la verificación live es obligatoria.

## Evidence To Capture

- `./init.sh` correcto (exit 0, 14/14 + 4/4 + asset) y negativos con exit 1 y sin listener.
- `sips`/`file`/`wc -c`/`shasum` de `assets/og-image.jpg`.
- `<head>` local y live con las 16 etiquetas; sin rutas relativas, `http://`, `example.com` ni
  comentarios de "provisional".
- Navegador 390×844/1280×800: consola 0, red esperada, sin scroll horizontal, geometría intacta.
- Live: códigos/MIME de los 5 paths, hashes local/live, `/index.html` 307, `cache-control`,
  `cf-cache-status`, `http://` status.
- Resultado manual del unfurl (o "no verificado") y sus límites.
- `feature_list.json` en `passing` con evidencia; `PROGRESS.md` y docs actualizados; confirmación
  de que `avatar.jpg`/`.vcf`/`styles.css`/tokens/contenido visible no cambiaron.

## Acceptance Criteria

- [ ] `index.html` con canonical/`og:url` exactos e imágenes absolutas en la URL de Workers; sin
      provisionalidad.
- [ ] `assets/og-image.jpg` JPEG 1200×630, ≤300 KiB objetivo, no copia del avatar, aprobado.
- [ ] `./init.sh` pasa con 14/14 + 4/4 + asset, conserva checks previos, falla ante regresiones y
      no arranca servidor.
- [ ] Live HTTPS con `/` y los 5 assets 200; `og-image` `image/jpeg`; HTML/assets byte-idénticos;
      vCard MIME registrado y cuerpo íntegro.
- [ ] Sin regresión visual/red en 390×844 y 1280×800; Lighthouse móvil ≥95 sin
      `critical`/`serious`.
- [ ] Unfurl manual intentado y registrado con límites, sin sobreafirmar.
- [ ] Docs actualizados, nomenclatura Workers coherente e id histórico explicado.
- [ ] Sin cambios fuera de alcance.

## Validator Checklist

- [ ] Implementación limitada a `<head>`, `assets/og-image.jpg`, `init.sh` y docs/evidencia.
- [ ] Escenarios 1–6 pasan; el 6 se acepta como observación manual, no garantía.
- [ ] Gate conserva checks previos y añade 4/4 + asset sin debilitar AA/responsive.
- [ ] No se inventó plataforma, dominio, Pages ni unfurl.
- [ ] Live verificado con `curl` y hashes; vCard MIME registrado.
- [ ] `feature_list.json`/`PROGRESS.md` no sobreafirman; `status` es `passing` hasta aceptación.
- [ ] No E2E persistente; el spec justifica por qué no aplica.
- [ ] Sin cambios en `styles.css`, tokens, contenido visible, `avatar.jpg`, `.vcf`, `AGENTS.md`
      ni dependencias/configuración de despliegue.

## Risks, Open Questions And Out Of Scope

**Riesgos:** URL de Workers puede cambiar (mitigación: constantes únicas + 4 URLs juntas); caché
social/unfurl (manual, sin garantías); imagen rechazada/mal dimensionada (receta + gate);
tamaño >300 KiB (recomprimir); MIME de vCard variable (registrar, no forzar); `http://` sin
redirección (recomendar "Always Use HTTPS"); gate local no prueba live (verificación live
obligatoria); despliegue manual no reproducible desde el repo (registrar el método real).

**Preguntas abiertas:** ¿el redeploy manual fue por dashboard o `wrangler`? (bloqueante para
redeploy, no para código); ¿el propietario aprueba la composición OG o aporta su JPEG?; ¿se
habilitará "Always Use HTTPS"?; ¿habrá dominio propio? (si sí, actualizar constantes y 4 URLs en
un solo cambio); ¿se añadirá `meta description`/`_headers` después? (fuera de alcance).

**Fuera de alcance:** migrar/crear Pages, dominio/DNS/TLS, CI/CD, `wrangler.toml`, tokens,
`_headers`, `_redirects`, 404, `robots.txt`, `sitemap.xml`, `meta description`, JSON-LD,
analítica, `theme-color`, favicon, cambios de CSS/tokens/layout/contenido, vCard/avatar,
garantizar unfurl o importación real de la vCard, y grabar la Tarjeta NFC/QR.
