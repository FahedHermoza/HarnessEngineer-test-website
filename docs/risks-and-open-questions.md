# Risks and Open Questions

## Publication Status And Manual Checks

- **Resuelto (2026-10-23, `deploy-cloudflare-pages`) — imagen social:** `assets/og-image.jpg`
  existe como JPEG 1200×630 (37 214 bytes, SHA-256 `b7c9b694…a012a2`), distinto del avatar,
  generado con la receta reproducible del spec y validado con `sips`/`file`. La composición
  usa los tokens de `DESIGN.md`. **Aprobación visual humana pendiente**; el agente no
  interpreta imágenes y no la declara aprobada.
- **Resuelto (2026-10-23) — URL pública:** la plataforma real es **Cloudflare Workers con
  static assets**, no Pages: `https://fahed-hermoza-card.fahedhermoza.workers.dev/`.
  `canonical`, `og:url` y las imágenes absolutas ya están cableados en `index.html` y
  `init.sh` los verifica. El id histórico `deploy-cloudflare-pages` se conserva por
  trazabilidad y no autoriza a crear un proyecto Pages.
- **Pendiente — redeploy manual y verificación live:** el HTML live actual es el anterior
  (SHA-256 `145b2028…`) y `/assets/og-image.jpg` sigue en 404 hasta que el propietario
  redeploye. El método manual (dashboard vs `wrangler`) no está documentado en el repo; no se
  inventan credenciales ni pipeline. Tras el redeploy hay que repetir el bloque `curl` del
  spec (5 assets 200, MIME, hashes local/live, `/index.html` 307, `http://` status). Un gate
  verde no demuestra el redeploy.
- **Pendiente — unfurl real:** aunque el HTML y la imagen sean correctos, WhatsApp/Facebook/
  iMessage cachean por URL y aplican políticas propias. Probar con Facebook Sharing Debugger
  y un mensaje de WhatsApp, y registrar el resultado sin afirmar éxito sin observación.
- **Recomendado — "Always Use HTTPS":** hoy `http://` en la raíz responde 200 sin
  redirección. Es un ajuste de Cloudflare, fuera del repo; se recomienda activarlo, pero no
  bloquea la aceptación.

## Implementation-Time Questions

- **Resuelto (2026-10-23, `link-whatsapp`):** el formato de WhatsApp es `https://wa.me/51955116562`; se descarta `api.whatsapp.com`. El handoff real a la app no se puede automatizar en este repositorio: queda como comprobación manual pendiente en un dispositivo y no bloquea el contrato de markup.
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
  vista previa antigua o ignore las etiquetas; se comprueba manualmente después del redeploy.
- **Caché y redeploy manual:** Cloudflare sirve HTML/assets con `max-age=0,
  must-revalidate`, pero puede devolver `cf-cache-status: HIT`; tras el redeploy hay que
  verificar con cache-busting (`?cb=`) y no confundir una respuesta cacheada con el estado
  nuevo. El despliegue no es reproducible desde el repo (método manual no documentado).
- **`http://` sin redirección forzada:** la raíz `http://` responde 200. No rompe la Tarjeta
  (los enlaces y metadatos usan HTTPS), pero se recomienda "Always Use HTTPS" en Cloudflare;
  no se configura desde el repo.
- **MIME variable de la vCard:** Workers podría servir `text/vcard` u otro tipo distinto de
  `text/x-vcard` porque no hay `_headers`. Se registra el valor real tras el redeploy; el
  mecanismo `download` + `.vcf` se mantiene.
- **Unfurl no garantizado:** un HTML correcto, HTTPS y una imagen 200 no garantizan que
  WhatsApp/Facebook rendericen la tarjeta; la caché y las políticas de cada cliente mandan.
  No se declara "unfurl verificado" sin observación real.
- **vCard: importación real pendiente y MIME variable:** el mecanismo ya está cerrado en
  un `.vcf` estático, pero la importación en la agenda de iOS y Android no se puede probar
  en este entorno. Queda como comprobación manual de dispositivo (no fabricar el resultado):
  un 200 y un `Content-Type` correcto no demuestran que la agenda importe nombre, teléfono,
  correo y Enlaces. `python3 -m http.server` sirve `text/x-vcard`; Cloudflare Workers podría
  usar `text/vcard` u `octet-stream` porque no hay `_headers` en el MVP. Mitigación:
  `download` + extensión `.vcf`; reevaluar cabeceras en `deploy-cloudflare-pages`.
  Algunas versiones de iOS guardan en Archivos y otras muestran vista previa; ambas
  cumplen «ofrece/descarga».
- **Handoff de WhatsApp no verificado:** un `href` correcto no demuestra que el dispositivo abra la app o muestre la página intermedia de `wa.me`. La comprobación final requiere un teléfono real; se mantiene como pendiente manual y no se cuenta como fallo del harness.

## Research Tasks

- Confirmar el comportamiento real de descarga/importación de la vCard en iOS y Android
  actuales (pendiente manual; no ejecutado en este entorno).
- Verificar tras el redeploy los límites de caché, MIME y rutas de assets en Cloudflare
  Workers static assets.
- ~~Definir herramienta para generar `assets/og-image.jpg` 1200×630.~~ **Resuelto
  (2026-10-23):** receta HTML + Chrome + `sips`/`file`, documentada en el spec y `DESIGN.md`;
  solo falta la aprobación visual humana.
