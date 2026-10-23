# Risks and Open Questions

## Blocking Next Phase

- **Imagen social `assets/og-image.jpg`:** el repositorio solo contiene `assets/avatar.jpg`; la imagen JPEG 1200×630 no existe ni puede generarse con las herramientas del agente. `open-graph-metadata` implementó y verificó el contrato de etiquetas, pero esta pendiente bloquea la vista previa real. No se creó, reutilizó ni sustituyó ningún binario; debe producirla una persona/herramienta externa coherente con Nombre/Handle/Tagline y la paleta de `DESIGN.md`.
- **URL pública final:** falta definir el proyecto/dominio en Cloudflare Pages. Se necesita para `canonical` y `og:url`; hasta entonces ambos se omiten en `index.html` (sin inventar dominios). Posición provisional: usar la URL que entregue Cloudflare Pages y actualizarla antes de grabar la Tarjeta NFC.
- **Vista previa real sin validar:** `og:image`/`twitter:image` usan la ruta relativa provisional `assets/og-image.jpg`; los crawlers sociales suelen exigir URLs absolutas. Al publicar, `deploy-cloudflare-pages` debe absolutizar ambas imágenes, añadir `og:url`/canonical con la URL final y comprobar el unfurl real (WhatsApp/Facebook). Un HTML correcto no prueba por sí solo la vista previa.

## Implementation-Time Questions

- **Resuelto (2026-10-23, `link-whatsapp`):** el formato de WhatsApp es `https://wa.me/51955116562`; se descarta `api.whatsapp.com`. El handoff real a la app no se puede automatizar en este repositorio: queda como comprobación manual pendiente en un dispositivo y no bloquea el contrato de markup.
- **Resuelto (2026-10-23, `save-contact-vcard`):** la Contacto se sirve como
  `assets/fahedhermoza.vcf` estático (VCARD 3.0, UTF-8 sin BOM, CRLF-only, ≤4096 bytes) y
  se descarga con `<a href="assets/fahedhermoza.vcf" download="fahedhermoza.vcf">`. Se
  descarta `data:text/vcard` (Android bloquea la navegación `data:` de nivel superior e
  iOS es inconsistente) y Blob (exigiría JavaScript). El gate valida el asset byte a byte
  y su coherencia con los cinco Enlaces, el teléfono y el correo.
- Fuente: precarga (`preload`) y fallback para evitar salto de texto (FOUT).
- `og-image`: dimensiones fijadas en 1200×630 JPEG (`og:image:width/height/type`); quedan abiertos el texto/contenido visual y la herramienta de generación (el agente no puede generar imágenes).
- Comportamiento de `tel:` y `mailto:` según app por defecto del dispositivo.

## Later / Not MVP

- Analítica de escaneos (Cloudflare Web Analytics).
- Código QR incrustado en la página.
- Favicon con iniciales y `theme-color`.
- Modo oscuro y multi-idioma.
- Página 404 y `_headers` para Cloudflare Pages.

## Assumptions

- `assets/avatar.jpg` ya está disponible en el repositorio.
- La Tarjeta NFC se grabará con la URL final una vez publicado el sitio.
- Cloudflare Pages servirá el contenido estático sin build.
- El público objetivo usa teléfonos modernos con navegador actualizado.

## Risks

- **Resuelto — Contraste de etiquetas de Enlace (2026-10-23, `accessibility-baseline`):** blanco `#ffffff` sobre los tokens oscurecidos mide 4.889, 5.184, 5.244, 5.184 y 4.958 a 1 en reposo (gradient-1…5) y 4.658–4.993:1 con el `filter: brightness(1.03)` de hover/foco, por encima de AA 4.5:1. Valores: `#5a67d1`, `#645fcc`, `#705aca`, `#8055c8`, `#9252c5`. Las etiquetas/iconos siguen blancos y el gate `./init.sh` recalcula los ratios. Los dos intermedios de la rampa de 7 Enlaces se derivan por `color-mix` de estos tokens, por lo que heredan el cumplimiento AA.
- **Resuelto — Contraste de la Tagline (2026-10-23, `accessibility-baseline`):** `--color-on-surface-variant` pasa a `#6b7280`, que sobre blanco mide ≈4.834:1; Handle y Tagline mejoran sin cambiar su escala 13px/400 y 26px/600. `DESIGN.md` refleja el token nuevo.
- **Excepción WCAG 2.5.8 documentada:** los dos enlaces inline del pie (correo y Handle) son más bajos que 44px; quedan cubiertos por la excepción de enlaces dentro de una frase. Reevaluar si cambia el pie.
- **Lighthouse móvil es manual:** el gate `./init.sh` no ejecuta Lighthouse. Repetir la auditoría de accesibilidad en `http://localhost:3413` (móvil) tras cambios de color, foco o estructura; objetivo ≥95 sin fallos `critical`/`serious`.
- **Enlaces que envejecen:** URLs de redes o portafolio pueden cambiar; nadie lo detecta automáticamente.
- **Dependencia de Google Fonts:** una caída o bloqueo degrada la tipografía (mitigado con fallback).
- **Avatar no disponible:** sin `assets/avatar.jpg` la página se ve incompleta (mitigado con iniciales).
- **Vista previa deficiente o sin imagen:** sin `assets/og-image.jpg` válida (y sin URL absoluta tras el despliegue) el enlace compartido se ve pobre aunque las etiquetas sean correctas. Mitigación actual: comentario HTML de provisionalidad y `[warn]` no bloqueantes en `init.sh`; cierre en `deploy-cloudflare-pages`.
- **vCard: importación real pendiente y MIME variable:** el mecanismo ya está cerrado en
  un `.vcf` estático, pero la importación en la agenda de iOS y Android no se puede probar
  en este entorno. Queda como comprobación manual de dispositivo (no fabricar el resultado):
  un 200 y un `Content-Type` correcto no demuestran que la agenda importe nombre, teléfono,
  correo y Enlaces. `python3 -m http.server` sirve `text/x-vcard`; Cloudflare Pages podría
  usar `text/vcard` u `octet-stream` porque no hay `_headers` en el MVP. Mitigación:
  `download` + extensión `.vcf`; reevaluar cabeceras en `deploy-cloudflare-pages`.
  Algunas versiones de iOS guardan en Archivos y otras muestran vista previa; ambas
  cumplen «ofrece/descarga».
- **Handoff de WhatsApp no verificado:** un `href` correcto no demuestra que el dispositivo abra la app o muestre la página intermedia de `wa.me`. La comprobación final requiere un teléfono real; se mantiene como pendiente manual y no se cuenta como fallo del harness.

## Research Tasks

- Confirmar el comportamiento real de descarga/importación de la vCard en iOS y Android
  actuales (pendiente manual; no ejecutado en este entorno).
- Verificar límites de caché y rutas de assets en Cloudflare Pages.
- Definir herramienta para generar `assets/og-image.jpg` 1200×630.
