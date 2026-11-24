# Validación — redesign-social-preview

- **Fecha:** 2026-11-24
- **Rama / worktree:** `feature/redesign-social-preview` · `devexpert-project-worktrees/redesign-social-preview`
- **Base:** `demo/seed` @ `8e2eb36`
- **Verdict del `feature-validator` (independiente):** `block` — **exclusivamente por insumos del propietario, sin defecto técnico**.
- **Resolución del orquestador (github-flow):** `accepted` sobre aprobación visual del propietario, con confirmación de vistas previas reservada a post-deploy (ver abajo).
- **Confirmación post-deploy (2026-11-24):** CERRADA. Ver sección final.

## Qué cambió

Reemplazo del binario `assets/og-image.jpg` por un **JPEG 1200×630** (65 254 bytes, SHA-256 `3571ba255cb281897635caf7e50b7643f3076f4bcc834e9ac2e89d092c08adf3`, distinto del avatar) que refleja el diseño renovado de la Tarjeta. No se tocaron `og:*`/`twitter:*`/`canonical`/`og:url` de `index.html`, ni `styles.css`/`init.sh`. Docs durables actualizadas (`DESIGN.md`, `docs/technical-discovery.md`, `docs/risks-and-open-questions.md`); spec nuevo; `feature_list.json`/`PROGRESS.md`/`visual/harness-status.html` actualizados.

## Verificación ejecutada (independiente)

- `bash -n init.sh` OK; `./init.sh` → exit `0`, **142 `[ok]`, 0 `[warn]`, 0 FAILED**. `Sharing metadata production checks:` 4/4 + `assets/og-image.jpg exists (JPEG 1200x630, 65254 bytes)`; `Design conformance checks:` (espejos en sync); `Accessibility checks:` y `Responsive checks:` verdes, sin debilitar contratos.
- Binario verificado con `file`/`sips`/`wc -c`/`shasum`/`cmp`: JPEG real 1200×630, 65 254 bytes, hash exacto, distinto del avatar.
- 5 casos negativos (ausente / vacío / PNG renombrado / 1200×600 / byte-idéntico al avatar) → 5 × `exit 1` con el mensaje esperado; ninguno arrancó servidor.
- `grep` confirma que el og-image solo aparece en `og:image`/`twitter:image` (no como `<img>` dentro de la Tarjeta).
- Lighthouse móvil Accessibility **100/100** (reportado por el implementer; sin cambios en página/CSS/JS, riesgo de regresión nulo).
- Dependencias (`redesign-card-profile`, `redesign-contact-navigation`, `redesign-footer-contact`, `redesign-qr-panel`, `redesign-share-action`, `deploy-cloudflare-pages`) confirmadas `accepted`.

### No re-medido (heredado)
- `scrollWidth/clientWidth` vía CDP no estuvo disponible en el entorno; `index.html`/`styles.css`/`scripts.js`/`share.js` con diff vacío → comportamiento sin scroll horizontal heredado sin cambios.

## Hallazgos

Sin hallazgos Critical/High/Medium. Sin superficie de seguridad nueva (no JS, no inputs, no rutas nuevas).

## Base de aceptación y confirmación post-deploy

- **Cerrado antes de aceptar:** aprobación visual explícita del propietario (Fahed Hermoza, 2026-11-24, móvil y escritorio) + validación técnica independiente verde.
- **Reservado a post-deploy (no verificable antes del despliegue):** el deploy a producción se dispara en el salto `demo/seed → main`; por tanto la verificación live por HTTPS (cinco paths/MIME/hashes) y las **vistas previas reales en WhatsApp/Facebook/iMessage** del binario nuevo solo pueden comprobarse **después** de mergear a `main` y desplegar. El reporte positivo del propietario del 2026-11-21 cubría la imagen **anterior**, ya reemplazada.

## Confirmación post-deploy (2026-11-24)

Tras mergear PR #59 (`demo/seed → main`) y el deploy automático a Cloudflare Workers static assets:

- Verificación live por HTTPS sobre `https://fahed-hermoza-card.fahedhermoza.workers.dev`: los cinco paths (`/`, `/styles.css`, `/assets/avatar.jpg`, `/assets/og-image.jpg`, `/assets/fahedhermoza.vcf`) → HTTP 200 con `content-type` correcto (`text/html`, `text/css`, `image/jpeg` ×2, `text/x-vcard`).
- Hash SHA-256 **local vs live idéntico** para `og-image.jpg` (`3571ba255cb281897635caf7e50b7643f3076f4bcc834e9ac2e89d092c08adf3`), `avatar.jpg` y `fahedhermoza.vcf` — confirma que el deploy propagó el binario nuevo (no un caché stale ni comparación solo por tamaño).
- Dimensiones live del og-image: 1200×630 JPEG.
- Meta-tags `canonical`/`og:url`/`og:image`/`twitter:image` en producción apuntan a la URL pública real con el og-image nuevo.
- **El propietario (Fahed Hermoza) confirmó** vistas previas reales correctas en WhatsApp, Facebook e iMessage con el binario rediseñado.

Con esto queda **cerrada** la confirmación post-deploy. No quedan pendientes abiertos de `redesign-social-preview`.

### Nota operativa (fuera de alcance de esta feature, sin cambios)
Checks heredados observados durante la verificación live, ya documentados antes como pendientes operativos de `deploy-cloudflare-pages` (no introducidos ni agravados por esta feature): `http://` sigue respondiendo 200 sin forzar HTTPS; `/PROGRESS.md` y `/AGENTS.md` siguen públicos.
