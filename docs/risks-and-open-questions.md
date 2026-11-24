# Risks and Open Questions

## Publication Status And Manual Checks

- **Reabierto (2026-11-23, `redesign-social-preview`) — imagen social:** el binario anterior
  (37 214 bytes, SHA-256 `b7c9b694…a012a2`, aprobado el 2026-10-23) correspondía al diseño
  previo al rediseño del 2026-11-21 y fue **reemplazado**. `assets/og-image.jpg` ahora es un
  JPEG 1200×630 (65 254 bytes, SHA-256 `3571ba25…8adf3`) que refleja la Tarjeta rediseñada
  (header "NFC CONNECT", avatar con halo/punto, Acciones rápidas, Enlaces en gradiente),
  generado con la misma receta reproducible (HTML temporal + Chrome headless + `sips`/`file`)
  pero con los valores reales y actuales de `styles.css`/`index.html`. Validado técnicamente
  el 2026-11-23 (`./init.sh` 4/4 de `Sharing metadata production checks:`, dimensiones, tamaño
  y distinción del avatar); **no se usa como `<img>` dentro de la Tarjeta**. La aprobación
  visual humana de este nuevo binario, el redeploy manual y la observación real de vistas
  previas en WhatsApp/Facebook/iMessage quedan **pendientes** — el agente no interpreta
  imágenes ni puede fabricar estos tres insumos del propietario.
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
- **Reportado como correcto (2026-11-21) — unfurl real, binario anterior:** el propietario
  confirmó que el protocolo de vistas previas en WhatsApp, Facebook e iMessage salió bien con
  la imagen social del 2026-10-23. No se recibieron capturas ni resultados separados por app;
  esta evidencia es un reporte humano, no una observación independiente del agente. **Este
  resultado no cubre el binario regenerado el 2026-11-23** (`redesign-social-preview`): hasta
  que el propietario repita el protocolo con el nuevo `assets/og-image.jpg` tras el redeploy,
  el unfurl real del diseño rediseñado sigue sin verificar. La caché y las políticas de cada
  cliente siguen pudiendo cambiar el resultado en otra ocasión.
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

### Rediseño acordado (2026-11-21; slices en curso)

- **Contratos durables:** `CONSTRAINTS.md` y `./init.sh` todavía fijan siete botones grandes,
  diez anclas, ocho SVG decorativos y la estructura previa. El futuro cambio a cinco
  botones grandes, Acciones rápidas y una Vista QR requiere revisar conteos y selectores
  explícitamente. No se deben eliminar los checks AA ni usar la nueva estructura para
  eludirlos.
- **Contraste y tamaño táctil de las referencias:** dos fondos del `code.html` adjunto
  (`#636cf4` y `#7568eb`) dan aproximadamente 4.22:1 y 4.25:1 con texto blanco; los cinco
  tonos del `DESIGN.md` adjunto dan 3.86–4.14:1. Las Acciones rápidas del prototipo miden
  40×40 px. Se deben ajustar colores, estados hover/foco y áreas interactivas a AA y al
  mínimo táctil del proyecto, sin copiar valores literalmente.
- **Vista QR y Compartir:** confirmar en implementación el comportamiento con teclado,
  lector de pantalla, portapapeles denegado, API de compartir ausente y JavaScript
  desactivado. El PNG debe codificar la URL canónica exacta, poder descargarse y escanearse
  en un teléfono real. La vCard estática no cambia.
- **Elementos ornamentales:** «NFC CONNECT» y el punto verde son decisiones visuales del
  propietario. No deben anunciar presencia «En línea» ni presentarse como una conexión
  NFC activa. La nueva imagen Open Graph requiere aprobación visual humana y verificación
  live tras el redeploy.
- **Referencias visuales:** las capturas, `code.html` y el `DESIGN.md` adjuntos por el
  propietario el 2026-11-21 no forman parte del repositorio. `DESIGN.md` de la raíz
  conserva los tokens base AA del sitio publicado, documenta la implementación local del
  Perfil y registra la dirección pendiente del resto del rediseño; las capturas son guía
  visual, no especificación de píxeles.
- **`redesign-card-profile` (implementación local, 2026-11-21):** el lienzo, la tarjeta y el
  encabezado de Perfil se han renovado localmente; el gate, navegador y Lighthouse son
  evidencia técnica, no aprobación visual. Las capturas originales no estaban accesibles
  en el repositorio y la comparación/revisión explícita del propietario sigue pendiente.
  No implica despliegue ni aprobación de los slices posteriores.

- **Resuelto (2026-10-23, `link-whatsapp`; comprobación manual 2026-11-21):** el formato de WhatsApp es `https://wa.me/51955116562`; se descarta `api.whatsapp.com`. El propietario confirmó que la apertura del enlace en dispositivo salió bien; no se recibieron datos del dispositivo ni capturas.
- **Resuelto (2026-10-23, `save-contact-vcard`):** la Contacto se sirve como
  `assets/fahedhermoza.vcf` estático (VCARD 3.0, UTF-8 sin BOM, CRLF-only, ≤4096 bytes) y
  se descarga con `<a href="assets/fahedhermoza.vcf" download="fahedhermoza.vcf">`. Se
  descarta `data:text/vcard` (Android bloquea la navegación `data:` de nivel superior e
  iOS es inconsistente) y Blob (exigiría JavaScript). El gate valida el asset byte a byte
  y su coherencia con los cinco Enlaces, el teléfono y el correo.
- Fuente: precarga (`preload`) y fallback para evitar salto de texto (FOUT).
- **Actualizado (2026-11-23, `redesign-social-preview`):** `og-image` sigue siendo un JPEG
  1200×630 generado con HTML temporal + Chrome headless + `sips`/`file`, ahora con la
  composición rediseñada documentada en `DESIGN.md`; no se añadió ninguna herramienta al
  stack. Queda pendiente la aprobación visual humana del nuevo binario.
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
- **Excepción WCAG 2.5.8 documentada:** el único enlace inline del pie («escríbeme directamente» → WhatsApp canónico `https://wa.me/51955116562`) es más bajo que 44px; queda cubierto por la excepción de enlaces dentro de una frase. El pie ya no repite correo (vive en Acciones rápidas) ni el Handle de Instagram (vive en los Enlaces grandes). Reevaluar si cambia el pie.
- **Resuelto — Pie rediseñado (2026-11-22, `redesign-footer-contact`):** el pie pasa de «correo · Handle» a una invitación («¿Tienes un proyecto en mente?...») con «escríbeme directamente» enlazando al WhatsApp canónico, conserva el separador `·` y cierra con «Tarjeta NFC & QR» como texto descriptivo (sin iconos, sin control interactivo). Guardar contacto conserva su contrato estático (`href`/`download` a `assets/fahedhermoza.vcf`, sin Blob/script). Anclas totales 10→9 (5 Enlaces + 2 Acciones rápidas + 1 Guardar contacto + 1 enlace de pie); el conteo de SVG decorativos no cambia (10, texto solo sin iconos NFC/QR). Pendiente: aprobación visual del propietario (móvil + escritorio).
- **Resuelto — Ajuste post-passing del pie (2026-11-22, `redesign-footer-contact`):** sobre el pie anterior, el propietario aprobó (vía `DESIGN.md` líneas 522-537) 3 ajustes de estructura, ya implementados: (1) `.page-footer__link` pasa a negrita (`font-weight: var(--text-button-label-font-weight)`) y sin subrayado (`text-decoration: none`), conservando `--color-accent` y su `:focus-visible`; (2) el separador `·` (`.page-footer__separator`) se retira por completo del `<footer>` y «Tarjeta NFC & QR» pasa a su propia línea/bloque (`.page-footer__nfc`) debajo del párrafo de invitación; (3) se añade un nuevo `<svg class="page-footer__nfc-icon">` decorativo (outline tipo tarjeta/chip NFC, `aria-hidden="true"`/`focusable="false"`/`stroke="currentColor"`/`stroke-width="2"`) a la izquierda de ese texto. El conteo de SVG decorativos pasa de 10 a 11; el conteo de anclas reales no cambia (9). La aprobación visual final completa (móvil + escritorio) de la feature sigue pendiente; la feature permanece `passing`, no `accepted`.
- **Resuelto (técnicamente) — Vista QR (2026-11-22/23, `redesign-qr-panel`):** tercera Acción
  rápida QR (`<a class="quick-action" href="assets/qr.png" data-qr-trigger>`) que abre un
  `<dialog class="qr-panel">` con QR, Cerrar, Copiar Enlace y Guardar PNG; JavaScript mínimo
  (`scripts.js`, solo `addEventListener`) con degradación sin JS al PNG estático.
  `CANONICAL_URL` en `scripts.js` es byte-idéntica a `PRODUCTION_URL`. Decisión de diseño del
  scrim: `::backdrop` usa un literal `rgba(45, 49, 57, 0.5)` derivado de `--color-on-surface`
  (mismo patrón que las sombras existentes), **sin** token de color nuevo, para no romper
  `Design conformance checks:`. Anclas 9→11 (+1 `.quick-action` QR, +1 `.qr-panel__save`);
  SVG decorativos 11→12 (+1 icono QR del trigger; el `<img>` del QR no cuenta). Se añadió la
  única relajación explícita de "todo control es `<a>`": los 2 `<button type="button">`
  in-page del cuadro (Cerrar, Copiar), con `role="button"`/`href="#"`/manejadores inline
  siempre prohibidos. Verificación real en navegador completada en una sesión posterior
  (chrome-devtools MCP): consola/red limpias, apertura/cierre por ratón/teclado/Escape/backdrop
  con retorno de foco, Copiar Enlace con confirmación anunciada, 8 anchos sin scroll horizontal,
  Lighthouse móvil Accessibility 100/100; esa misma sesión encontró y corrigió dos bugs de CSS
  (solape visual título/botón Cerrar; animación de apertura no anulada bajo reduced-motion por
  orden de cascada). Validación técnica independiente también completada (`accept` técnico).
  **Resuelto (2026-11-23):** (1) escaneo real del QR en un teléfono físico confirmado por el
  propietario, resuelve exactamente `https://fahed-hermoza-card.fahedhermoza.workers.dev/`;
  (2) aprobación visual fechada del propietario en móvil y escritorio, panel cerrado y abierto,
  con capturas registradas en `docs/validations/redesign-qr-panel.md`. Feature `accepted`.
- **Lighthouse móvil es manual:** el gate `./init.sh` no ejecuta Lighthouse. Repetir la auditoría de accesibilidad en `http://localhost:3601` (móvil, puerto aislado de esta worktree) tras cambios de color, foco o estructura; objetivo ≥95 sin fallos `critical`/`serious`.
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
  aprobación visual humana registrada el 2026-10-23 (binario anterior, reemplazado el
  2026-11-23).
- **Pendiente (2026-11-23, `redesign-social-preview`):** aprobación visual del propietario
  para el nuevo `assets/og-image.jpg` (móvil y escritorio), redeploy manual y observación real
  de vistas previas en WhatsApp/Facebook/iMessage con el binario rediseñado. Ninguno de los
  tres puede ser fabricado, inferido ni simulado por el implementador o el validador.
