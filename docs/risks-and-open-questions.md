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

- **Enlaces que envejecen:** URLs de redes o portafolio pueden cambiar; nadie lo detecta automáticamente.
- **Dependencia de Google Fonts:** una caída o bloqueo degrada la tipografía (mitigado con fallback).
- **Avatar no disponible:** sin `assets/avatar.jpg` la página se ve incompleta (mitigado con iniciales).
- **Vista previa deficiente:** sin `og-image` válida, el enlace compartido se ve pobre.
- **vCard inconsistente:** diferencias de comportamiento entre iOS y Android.

## Research Tasks

- Confirmar el comportamiento real de descarga de vCard en iOS y Android actuales.
- Verificar límites de caché y rutas de assets en Cloudflare Pages.
- Definir herramienta para generar `assets/og-image.jpg` 1200×630.
