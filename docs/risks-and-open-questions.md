# Risks and Open Questions

## Blocking Next Phase

- **URL pública final:** falta definir el proyecto/dominio en Cloudflare Pages. Se necesita para `canonical` y `og:url`. Posición provisional: usar la URL que entregue Cloudflare Pages y actualizarla antes de grabar la Tarjeta NFC.

## Implementation-Time Questions

- Formato de WhatsApp: `https://wa.me/51955116562` frente a `https://api.whatsapp.com/send?phone=51955116562`.
- vCard: archivo `.vcf` estático frente a `data:text/vcard` generado en cliente; definir nombre de archivo y codificación.
- Fuente: precarga (`preload`) y fallback para evitar salto de texto (FOUT).
- `og-image`: dimensiones exactas, texto y herramienta de generación (el agente no puede generar imágenes).
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
- **Vista previa deficiente:** sin `og-image` válida, el enlace compartido se ve pobre.
- **vCard inconsistente:** diferencias de comportamiento entre iOS y Android.

## Research Tasks

- Confirmar el comportamiento real de descarga de vCard en iOS y Android actuales.
- Verificar límites de caché y rutas de assets en Cloudflare Pages.
- Definir herramienta para generar `assets/og-image.jpg` 1200×630.
