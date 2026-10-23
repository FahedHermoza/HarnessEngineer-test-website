# Risks and Open Questions

## Blocking Next Phase

- **Imagen social `assets/og-image.jpg`:** el repositorio solo contiene `assets/avatar.jpg`; la imagen JPEG 1200×630 no existe ni puede generarse con las herramientas del agente. `open-graph-metadata` implementó y verificó el contrato de etiquetas, pero esta pendiente bloquea la vista previa real. No se creó, reutilizó ni sustituyó ningún binario; debe producirla una persona/herramienta externa coherente con Nombre/Handle/Tagline y la paleta de `DESIGN.md`.
- **URL pública final:** falta definir el proyecto/dominio en Cloudflare Pages. Se necesita para `canonical` y `og:url`; hasta entonces ambos se omiten en `index.html` (sin inventar dominios). Posición provisional: usar la URL que entregue Cloudflare Pages y actualizarla antes de grabar la Tarjeta NFC.
- **Vista previa real sin validar:** `og:image`/`twitter:image` usan la ruta relativa provisional `assets/og-image.jpg`; los crawlers sociales suelen exigir URLs absolutas. Al publicar, `deploy-cloudflare-pages` debe absolutizar ambas imágenes, añadir `og:url`/canonical con la URL final y comprobar el unfurl real (WhatsApp/Facebook). Un HTML correcto no prueba por sí solo la vista previa.

## Implementation-Time Questions

- **Resuelto (2026-10-23, `link-whatsapp`):** el formato de WhatsApp es `https://wa.me/51955116562`; se descarta `api.whatsapp.com`. El handoff real a la app no se puede automatizar en este repositorio: queda como comprobación manual pendiente en un dispositivo y no bloquea el contrato de markup.
- vCard: archivo `.vcf` estático frente a `data:text/vcard` generado en cliente; definir nombre de archivo y codificación.
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

- **Contraste de etiquetas de Enlace (heredado):** blanco `#ffffff` sobre `gradient-1`…`gradient-5` mide 3.86, 4.10, 4.13, 4.09 y 3.91 a 1 (medido el 2026-10-23, implementación de `link-button-component`), por debajo del mínimo AA 4.5:1 para `button-label` (11px/800). No se corrige en `link-button-component` para no inventar colores fuera de la paleta ni alterar la escala tipográfica; `accessibility-baseline` debe resolverlo (ajustar tokens/tamaño de etiqueta) o aceptarlo explícitamente.
- **Contraste de la Tagline (heredado):** `#717886` (`--color-on-surface-variant`) sobre blanco `#ffffff` mide ≈4.43:1, ligeramente por debajo del mínimo AA 4.5:1 para texto normal de 13px/400. Detectado al implementar `profile-identity` (2026-10-23); no se corrige en esa feature para no cambiar tokens de `DESIGN.md` ni inventar colores. `accessibility-baseline` debe ajustar el token/color o aceptar la desviación explícitamente.
- **Enlaces que envejecen:** URLs de redes o portafolio pueden cambiar; nadie lo detecta automáticamente.
- **Dependencia de Google Fonts:** una caída o bloqueo degrada la tipografía (mitigado con fallback).
- **Avatar no disponible:** sin `assets/avatar.jpg` la página se ve incompleta (mitigado con iniciales).
- **Vista previa deficiente o sin imagen:** sin `assets/og-image.jpg` válida (y sin URL absoluta tras el despliegue) el enlace compartido se ve pobre aunque las etiquetas sean correctas. Mitigación actual: comentario HTML de provisionalidad y `[warn]` no bloqueantes en `init.sh`; cierre en `deploy-cloudflare-pages`.
- **vCard inconsistente:** diferencias de comportamiento entre iOS y Android.
- **Handoff de WhatsApp no verificado:** un `href` correcto no demuestra que el dispositivo abra la app o muestre la página intermedia de `wa.me`. La comprobación final requiere un teléfono real; se mantiene como pendiente manual y no se cuenta como fallo del harness.

## Research Tasks

- Confirmar el comportamiento real de descarga de vCard en iOS y Android actuales.
- Verificar límites de caché y rutas de assets en Cloudflare Pages.
- Definir herramienta para generar `assets/og-image.jpg` 1200×630.
