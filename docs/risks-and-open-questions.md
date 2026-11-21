# Risks and Open Questions

## Publication Status And Manual Checks

- **Resuelto (2026-10-23, `deploy-cloudflare-pages`) — imagen social:** `assets/og-image.jpg`
  existe como JPEG 1200×630 (37 214 bytes, SHA-256 `b7c9b694…a012a2`), distinto del avatar,
  generado con la receta reproducible del spec y validado con `sips`/`file`. La composición
  usa los tokens de `DESIGN.md`. **Aprobación visual humana registrada el 2026-10-23** por el
  propietario; el agente no interpreta imágenes.
- **Resuelto (2026-10-23) — URL pública:** la plataforma real es **Cloudflare Workers con
  static assets**, no Pages: `https://fahed-hermoza-card.fahedhermoza.workers.dev/`.
  `canonical`, `og:url` y las imágenes absolutas ya están cableados en `index.html` y
  `init.sh` los verifica. El id histórico `deploy-cloudflare-pages` se conserva por
  trazabilidad y no autoriza a crear un proyecto Pages.
- **Resuelto (2026-10-24) — redeploy manual y verificación live:** el HTML live ya coincide
  con el local (`55e56730…`) y los cinco paths responden 200 (`/`, `styles.css`, avatar,
  `og-image` `image/jpeg`, vCard `text/x-vcard`); `/index.html` 307 → `/`, `http://` 200 y los
  SHA-256 local/remoto coinciden. `cache-control: public, max-age=0, must-revalidate` y
  `cf-cache-status: HIT` fueron observados. El método manual (dashboard vs `wrangler`) sigue
  sin documentarse, pero `wrangler.jsonc` es la configuración externa usada por el propietario.
- **Reportado como correcto (2026-11-21) — unfurl real:** el propietario confirmó que el
  protocolo de vistas previas en WhatsApp, Facebook e iMessage salió bien. No se recibieron
  capturas ni resultados separados por app; esta evidencia es un reporte humano, no una
  observación independiente del agente. La caché y las políticas de cada cliente siguen
  pudiendo cambiar el resultado en otra ocasión.
- **Nota de exposición (confirmada de nuevo 2026-11-21) — `wrangler.jsonc`:** su
  `assets.directory: "."` publica la raíz del repo. `/.git/config`, `/PROGRESS.md`,
  `/AGENTS.md` y `/docs/...` respondieron 200 el 2026-10-24; `curl` confirmó 200 para
  `/PROGRESS.md` y `/AGENTS.md` el 2026-11-21. No hay secretos trackeados ni `.env` público,
  pero cualquier archivo futuro en la raíz quedaría servido automáticamente.
  Recomendación para el propietario: acotar `assets.directory` a un
  directorio público o añadir exclusiones; no es un defecto de la feature.
- **Recomendado — "Always Use HTTPS":** el 2026-11-21 `http://` en la raíz respondió 200 sin
  redirección. Es un ajuste de Cloudflare, fuera del repo; se recomienda activarlo, pero no
  bloquea la aceptación.

## Implementation-Time Questions

- **Resuelto (2026-10-23, `link-whatsapp`; comprobación manual 2026-11-21):** el formato de WhatsApp es `https://wa.me/51955116562`; se descarta `api.whatsapp.com`. El propietario confirmó que la apertura del enlace en dispositivo salió bien; no se recibieron datos del dispositivo ni capturas.
- **Resuelto (2026-10-23, `save-contact-vcard`):** la Contacto se sirve como
  `assets/fahedhermoza.vcf` estático (VCARD 3.0, UTF-8 sin BOM, CRLF-only, ≤4096 bytes) y
  se descarga con `<a href="assets/fahedhermoza.vcf" download="fahedhermoza.vcf">`. Se
  descarta `data:text/vcard` (Android bloquea la navegación `data:` de nivel superior e
  iOS es inconsistente) y Blob (exigiría JavaScript). El gate valida el asset byte a byte
  y su coherencia con los cinco Enlaces, el teléfono y el correo.
- Fuente: precarga (`preload`) y fallback para evitar salto de texto (FOUT).
- **Resuelto (2026-10-23, `deploy-cloudflare-pages`):** `og-image` es un JPEG 1200×630
  generado con HTML temporal + Chrome + `sips`/`file`, con la composición documentada en
  `DESIGN.md`; no se añadió ninguna herramienta al stack. Solo queda la aprobación visual
  humana.
- Comportamiento de `tel:` y `mailto:` según app por defecto del dispositivo.

## Later / Not MVP

- Analítica de escaneos (Cloudflare Web Analytics).
- Código QR incrustado en la página.
- Favicon con iniciales y `theme-color`.
- Modo oscuro y multi-idioma.
- Página 404 y `_headers` para Cloudflare Workers static assets.

## Assumptions

- `assets/avatar.jpg` ya está disponible en el repositorio.
- La Tarjeta NFC se grabará con la URL final una vez publicado el sitio.
- Cloudflare Workers con static assets sirve el contenido estático sin build.
- El público objetivo usa teléfonos modernos con navegador actualizado.

## Risks

- **Resuelto — Contraste de etiquetas de Enlace (2026-10-23, `accessibility-baseline`):** blanco `#ffffff` sobre los tokens oscurecidos mide 4.889, 5.184, 5.244, 5.184 y 4.958 a 1 en reposo (gradient-1…5) y 4.658–4.993:1 con el `filter: brightness(1.03)` de hover/foco, por encima de AA 4.5:1. Valores: `#5a67d1`, `#645fcc`, `#705aca`, `#8055c8`, `#9252c5`. Las etiquetas/iconos siguen blancos y el gate `./init.sh` recalcula los ratios. Los dos intermedios de la rampa de 7 Enlaces se derivan por `color-mix` de estos tokens, por lo que heredan el cumplimiento AA.
- **Resuelto — Contraste de la Tagline (2026-10-23, `accessibility-baseline`):** `--color-on-surface-variant` pasa a `#6b7280`, que sobre blanco mide ≈4.834:1; Handle y Tagline mejoran sin cambiar su escala 13px/400 y 26px/600. `DESIGN.md` refleja el token nuevo.
- **Excepción WCAG 2.5.8 documentada:** los dos enlaces inline del pie (correo y Handle) son más bajos que 44px; quedan cubiertos por la excepción de enlaces dentro de una frase. Reevaluar si cambia el pie.
- **Lighthouse móvil es manual:** el gate `./init.sh` no ejecuta Lighthouse. Repetir la auditoría de accesibilidad en `http://localhost:3502` (móvil) tras cambios de color, foco o estructura; objetivo ≥95 sin fallos `critical`/`serious`.
- **Prueba responsive runtime-only:** "sin scroll horizontal" no se demuestra solo con grep. `Responsive checks:` fija los invariantes de CSS, pero la prueba real es la matriz de ocho anchos en el navegador con recarga fresca; repetirla tras cualquier cambio de layout, tipografía, tarjeta, botones o pie. No existe harness E2E persistente y añadirlo introduciría dependencias prohibidas por `docs/technical-discovery.md`.
- **Octavo botón integrado:** `save-contact-vcard` añadió un botón de ancho completo y 48px. Tras el rebase de `responsive-baseline` sobre `demo/seed` se repitió la matriz (320, 390, 768 y 1280): los ocho botones miden 48px, no hay etiquetas truncadas ni scroll horizontal; a 320 el pie sigue ocupando dos líneas sin recorte. Repetir la matriz completa si cambia el layout.
- **Enlaces que envejecen:** URLs de redes o portafolio pueden cambiar; nadie lo detecta automáticamente.
- **Dependencia de Google Fonts:** una caída o bloqueo degrada la tipografía (mitigado con fallback).
- **Avatar no disponible:** sin `assets/avatar.jpg` la página se ve incompleta (mitigado con iniciales).
- **Vista previa deficiente o sin imagen (mitigado):** el asset ya existe, es 1200×630 y las
  URLs son absolutas; `init.sh` falla ante asset ausente, no JPEG, dimensiones incorrectas,
  copia del avatar o URL no absoluta. Queda el riesgo de que el cliente social cachee una
  vista previa antigua o ignore las etiquetas; el propietario reportó una prueba correcta
  en WhatsApp, Facebook e iMessage el 2026-11-21, sin evidencia visual adjunta.
- **Caché y redeploy manual:** Cloudflare sirve HTML/assets con `max-age=0,
  must-revalidate`, pero puede devolver `cf-cache-status: HIT`; tras el redeploy hay que
  verificar con cache-busting (`?cb=`) y no confundir una respuesta cacheada con el estado
  nuevo. El despliegue no es reproducible desde el repo (método manual no documentado).
- **`http://` sin redirección forzada:** la raíz `http://` responde 200. No rompe la Tarjeta
  (los enlaces y metadatos usan HTTPS), pero se recomienda "Always Use HTTPS" en Cloudflare;
  no se configura desde el repo.
- **MIME de la vCard:** Workers sirvió `text/x-vcard` en la verificación live del
  2026-10-24. Un redeploy futuro podría cambiarlo porque no hay `_headers`; el mecanismo
  `download` + `.vcf` se mantiene y el tipo se debe comprobar tras desplegar.
- **Unfurl variable:** el propietario reportó vistas previas correctas en WhatsApp, Facebook
  e iMessage el 2026-11-21. La caché y las políticas de cada cliente pueden cambiar el
  resultado; el reporte no incluye capturas ni una observación independiente.
- **vCard: importación reportada y MIME observado:** el mecanismo usa un `.vcf` estático.
  El propietario reportó importación correcta en agendas iOS y Android el 2026-11-21 tras
  seguir el protocolo de campos; no se recibieron modelos, versiones ni capturas. El MIME
  observado en producción el 2026-10-24 fue `text/x-vcard`. El botón conserva `download`
  y la extensión `.vcf`.
- **Handoff de WhatsApp reportado:** el propietario confirmó el 2026-11-21 que el enlace
  abrió el flujo esperado en un dispositivo real. No se registró modelo, sistema ni captura.

## Research Tasks

- Descarga/importación de la vCard en iOS y Android: reportada como correcta por el
  propietario el 2026-11-21; no ejecutada ni observada por el agente.
- Límites de caché, MIME y rutas de assets en Cloudflare Workers static assets: verificados el
  2026-10-24 (cinco paths 200, `text/x-vcard`, hashes idénticos).
- ~~Definir herramienta para generar `assets/og-image.jpg` 1200×630.~~ **Resuelto
  (2026-10-23):** receta HTML + Chrome + `sips`/`file`, documentada en el spec y `DESIGN.md`;
  aprobación visual humana registrada el 2026-10-23.
