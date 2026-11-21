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
- Publicada en **Cloudflare Workers static assets** con HTTPS y accesible en
  `https://fahed-hermoza-card.fahedhermoza.workers.dev/`, sin build y con el HTML/assets
  publicados coincidiendo con el repositorio.

## Notes

- El contenido visible de la página va en español.
- La Tagline se corrigió de "Enginner" a "Engineer".
- El sistema visual de referencia es `DESIGN.md` ("Serene Bio Card"), inspirado en el Carrd Template #93.
- La URL pública está definida: `https://fahed-hermoza-card.fahedhermoza.workers.dev/`
  (Cloudflare Workers static assets, no Pages). El redeploy es manual del propietario; la
  verificación live se completó el 2026-10-24. El propietario reportó vistas previas
  correctas en WhatsApp, Facebook e iMessage el 2026-11-21; los límites de esa evidencia
  y las tareas operativas abiertas figuran en `docs/risks-and-open-questions.md`.

## Rediseño acordado (descubrimiento, 2026-11-21)

**Problema y usuarios:** la Tarjeta publicada ya reúne los canales y funciona. Fahed quiere
una presentación visual más cercana a las capturas que aportó, con acceso visible al QR y
una forma directa de compartir; los visitantes y la URL pública siguen siendo los mismos.
Este apartado define el cambio futuro y no describe el sitio actualmente publicado.

**Alcance:** mantener los siete canales, con Instagram, Facebook, WhatsApp, LinkedIn y
Portafolio como cinco Enlaces grandes, y Celular/Correo en una fila de Acciones rápidas.
La fila añade una acción QR y una única acción Compartir. El QR de la URL pública se muestra
en un cuadro sobre la Tarjeta, con cerrar, Copiar Enlace y Guardar PNG. Compartir abre el
menú nativo cuando esté disponible; si no, copia la URL e informa del resultado en pantalla.
El pie usa la invitación con enlace a WhatsApp, un control visual de Guardar contacto y el
texto «Tarjeta NFC & QR». La vCard conserva su archivo y datos actuales. La imagen social
1200×630 se alineará con el nuevo diseño antes de publicar.

**Dirección y límites:** las dos capturas adjuntas el 2026-11-21 guían jerarquía, forma y
composición; el `code.html` y el `DESIGN.md` adjuntos son referencias, no código ni tokens
para copiar literalmente. «NFC CONNECT» y el punto verde se conservan como elementos
visuales sin anunciar un estado «En línea». Se mantienen HTML/CSS, Plus Jakarta Sans,
SVG propios, despliegue estático y vCard estática. Se admite JavaScript mínimo para QR,
Compartir y Copiar; quedan fuera Tailwind CDN, Font Awesome, Inter, la vCard generada con
Blob, nuevas cuentas, backend y analítica.

**Validación del cambio:** revisión visual del propietario en móvil y escritorio; las ocho
anchuras de la matriz responsive sin scroll horizontal; controles accesibles con foco,
tamaño táctil y contraste AA, `prefers-reduced-motion` y Lighthouse móvil Accessibility ≥95
sin fallos `critical`/`serious`; QR escaneable hacia la URL canónica, descarga PNG y copia;
Compartir con y sin API nativa; siete destinos y vCard intactos; imagen social nueva
1200×630 y verificación live tras el despliegue manual. La aprobación visual de la nueva
tarjeta y de la imagen social corresponde al propietario.
