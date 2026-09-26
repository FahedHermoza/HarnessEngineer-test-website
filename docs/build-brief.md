# Build Brief

## Problem

Cuando Fahed conoce a alguien (eventos, charlas, networking) debe compartir sus canales uno por uno: dicta el Instagram, luego el WhatsApp, luego el portafolio. Es lento, propenso a errores y obliga a la otra persona a escribir o buscar cada cuenta. No existe un único punto de contacto móvil-first que agrupe todo.

## Current Workaround / Existing System

- Decir usuario por usuario o dictar el número.
- Enviar capturas de pantalla o mensajes separados.
- El portafolio actual (`fahedhermoza.github.io`) no enlaza las redes de forma clara en móvil.
- Alternativas genéricas tipo Linktree, que agregan dependencia, marca ajena y analítica no deseada.

## Target Users

- **Visitante (principal):** persona que escanea la Tarjeta NFC o el Código QR desde su teléfono: reclutadores, asistentes a charlas, clientes, colegas.
- **Propietario / operador:** Fahed Hermoza, responsable de mantener los Enlaces y de grabar la Tarjeta NFC / generar el Código QR.

## Goals

- Un solo destino (Tarjeta digital) accesible desde NFC, QR o enlace compartido.
- Experiencia móvil-first: carga rápida, botones grandes, una sola columna.
- Guardar contacto en un toque (Contacto vCard) con teléfono, correo y enlaces.
- Contenido en español, sin dependencias de backend ni frameworks.
- Fácil de mantener: editar Enlaces en un único archivo.

## Non-Goals

- Sin analítica de escaneos (por ahora).
- Sin CMS, panel de administración ni autenticación.
- Sin backend, base de datos ni formularios.
- Sin QR incrustado en la página.
- Sin modo oscuro, multi-idioma ni i18n.
- Sin blog ni secciones adicionales más allá de la Tarjeta digital.

## MVP Slice

Una página estática `index.html` que incluye:

1. Perfil: avatar circular (`assets/avatar.jpg`), Nombre "Fahed Hermoza", Handle "@fahedhermoza", Tagline "Software Engineer & Speaker & Builder".
2. Siete Enlaces en orden: Instagram, Facebook, WhatsApp, LinkedIn, Portafolio, Correo, Celular.
3. Botón extra "Guardar contacto" que descarga la Contacto (vCard).
4. Pie con el correo y el handle.
5. Metadatos Open Graph para buena vista previa al compartir.
6. Diseño responsive según `DESIGN.md`.

Criterio de slice: un visitante puede abrir la página desde un teléfono, entender quién es Fahed y contactarlo o guardarlo sin ayuda.

## Validation Plan

- Probar cada Enlace en Android e iOS: Instagram, Facebook, WhatsApp, LinkedIn, Portafolio, Correo (`mailto:`), Celular (`tel:`).
- Verificar que la Contacto (vCard) se abre y se guarda correctamente en iOS y Android.
- Revisar la vista previa de Open Graph compartiendo el enlace por WhatsApp.
- Medir con Lighthouse (móvil): rendimiento, accesibilidad, buenas prácticas y SEO.
- Probar en viewports de 320px, 375px, 768px y escritorio.
- Escanear la Tarjeta NFC y el Código QR reales una vez publicada la URL.

## Success Criteria

- La página abre en menos de 2 s en una red móvil típica.
- Los siete Enlaces y la vCard funcionan en iOS y Android sin ajustes manuales.
- La vista previa al compartir muestra título, descripción e imagen.
- Se ve correctamente sin scroll horizontal en pantallas de 320px.
- Publicada en Cloudflare Pages desde el repositorio de GitHub.

## Notes

- El contenido visible de la página va en español.
- La Tagline se corrigió de "Enginner" a "Engineer".
- El sistema visual de referencia es `DESIGN.md` ("Serene Bio Card"), inspirado en el Carrd Template #93.
- La URL pública final aún no está definida; ver `docs/risks-and-open-questions.md`.
