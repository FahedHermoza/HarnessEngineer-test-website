# Technical Discovery

## Product Surface

Sitio web estático de una sola página, móvil-first, sin estado ni sesión. Se abre desde navegador móvil tras un Escaneo NFC/QR.

## Candidate Stack

- HTML5 semántico + CSS moderno (custom properties, flexbox, grid mínimo).
- JavaScript mínimo: solo el `onerror` inline del fallback del avatar; la vCard es un asset
  estático y no necesita JavaScript.
- Sin framework, sin bundler, sin build step.
- Tipografía Plus Jakarta Sans vía Google Fonts con pila de respaldo del sistema.
- Iconos como SVG inline (evita dependencias y peticiones extra).

## Data and Storage

- Sin base de datos ni almacenamiento.
- Contenido hardcodeado en `index.html`.
- Assets estáticos:
  - `assets/avatar.jpg` — foto de perfil (presente en el repositorio).
  - `assets/og-image.jpg` — imagen Open Graph JPEG 1200×630 (37 214 bytes), generada con la
    receta reproducible de `docs/specs/deploy-cloudflare-pages.md`: HTML temporal fuera del
    repo, composición con tokens de `DESIGN.md`, viewport Chrome `1200x630x1`, captura JPEG
    calidad 90 y validación con `sips`/`file`. No se commitea el HTML temporal ni se reutiliza
    el avatar. Aprobación visual humana registrada el 2026-10-23.
  - `assets/fahedhermoza.vcf` — Contacto vCard 3.0 estática, UTF-8 sin BOM y con líneas
    CRLF; se sirve same-origin y se descarga con `download="fahedhermoza.vcf"`, sin
    `data:` URI, Blob ni generación en cliente. `.gitattributes` marca `assets/*.vcf`
    con `-text` para que Git preserve los bytes CRLF también al hacer checkout.

## Integrations

- Instagram: `https://www.instagram.com/fahedhermoza/`
- Facebook: `https://www.facebook.com/fahed19`
- WhatsApp: `https://wa.me/51955116562`
- LinkedIn: `https://www.linkedin.com/in/fahedhermoza/`
- Portafolio: `https://fahedhermoza.github.io/`
- Correo: `mailto:fahedhermoza@gmail.com`
- Celular: `tel:+51955116562`
- Open Graph / Twitter Card para vistas previas al compartir.

## Authentication and Authorization

No aplica. Página pública, sin roles, sin permisos, sin datos de usuario.

## Deployment and Operations

- Repositorio en GitHub.
- Plataforma: **Cloudflare Workers con static assets** (no Cloudflare Pages). El id histórico
  `deploy-cloudflare-pages` se conserva por trazabilidad, pero no existe ni se crea un proyecto
  Pages.
- URL pública: `https://fahed-hermoza-card.fahedhermoza.workers.dev/`.
- Sin comando de build; el contenido servido es la raíz del repositorio (`index.html`,
  `styles.css`, `assets/`).
- HTTPS provisto por Cloudflare. `http://` en la raíz responde 200 (sin redirección forzada);
  se recomienda activar "Always Use HTTPS" en Cloudflare, pero el repo no lo configura.
- Despliegue manual del propietario; el método exacto (dashboard vs `wrangler`) no está
  documentado en el repo y no se inventa. No hay `wrangler.toml`, CI ni `package.json`.
  El propietario añadió `wrangler.jsonc` como configuración externa (proyecto
  `fahed-hermoza-card`, `compatibility_date` `2026-10-24`, `assets.directory: "."`); publica
  la raíz del repo, por lo que rutas internas como `/.git/config` o `/PROGRESS.md` también
  responden 200. No hay secretos trackeados, pero cualquier archivo futuro en la raíz
  quedaría público: acotar `assets.directory` o excluir rutas internas es una recomendación
  abierta para el propietario.
- Caché observada: HTML/assets con `cache-control: public, max-age=0, must-revalidate`;
  `cf-cache-status: HIT` puede aparecer y no es un error. Para verificar tras un redeploy,
  usar cache-busting (`?cb=$(date +%s)`) solo en la comprobación, nunca en
  `canonical`/`og:url`.
- Mantenimiento: editar `index.html`/`assets`, ejecutar `./init.sh` y pedir al propietario el
  redeploy manual. Un cambio de origen exige actualizar `PRODUCTION_ORIGIN`,
  `PRODUCTION_URL`, `PRODUCTION_IMAGE_URL` y las cuatro URLs del `<head>` en el mismo cambio.

## Testing and Verification

- `./init.sh` es el gate estándar no bloqueante. Antes de las comprobaciones de
  accesibilidad ejecuta `Save contact checks:`: el `.vcf` existe, pesa como máximo 4096
  bytes y se valida byte a byte (UTF-8 sin BOM, CRLF-only incluida la línea final,
  `BEGIN`/`END`, VCARD 3.0, nombre, título, teléfono, correo y exactamente cinco `URL:`);
  sus URLs, teléfono y correo coinciden con los controles de la página; hay un único
  `.save-contact` con un ancla exacta `href="assets/fahedhermoza.vcf"` +
  `download="fahedhermoza.vcf"`, etiqueta e icono 18×18 decorativo, situado entre
  `</nav>` y el pie; y existen las reglas de forma, colores neutros, foco, brillo y
  reduced motion del botón. Además, `Accessibility checks:` cubre idioma del documento y
  viewport zoomable, `lang="en"` de la Tagline, `alt` no vacío del avatar, 10 controles
  `<a>` reales (7 `.link-button` + 1 `.save-contact-button` + 2 `.page-footer__link`) con
  `href` no vacío, 8 SVG decorativos con `aria-hidden="true"`/`focusable="false"`, foco
  visible (`outline: 2px solid` + offset 2px), reduced motion
  (`transition: none`/`transform: none`) y un contraste calculado de 15 comprobaciones
  (cinco tonos en reposo y con `brightness(1.03)`, Tagline/Handle, enlaces y texto del pie,
  y el neutro `#484dc4`/`#f1f4fa` en reposo y con brillo) con la fórmula WCAG 2.x.
- `Responsive checks:` (después de accesibilidad): `box-sizing: border-box` universal, gutter
  de `.page` con `var(--space-gutter)`, `max-width: 100%` de `.card`, guard 4/4 de
  `.link-button__label`, ausencia de `overflow-x` como máscara o de `width: 100vw`,
  breakpoints de ancho solo en el set `360px`/`480px`/`736px` y altura ≥44px de `.link-button`
  dentro de cualquier media query de ancho.
- `Sharing metadata production checks:` (después del contrato 14/14): cuatro coincidencias
  exactas `grep -qF` para `canonical`, `og:url`, `og:image` y `twitter:image` construidas
  desde `PRODUCTION_URL`/`PRODUCTION_IMAGE_URL` (`[ok] production URL metadata (4/4)`), más
  checks bloqueantes de `assets/og-image.jpg` (`file` disponible, no vacío, JPEG real,
  1200×630, distinto del avatar, ≤300 KiB como objetivo con `[warn]` solo por tamaño),
  URL absoluta de ambas imágenes y `og:url`+canonical declarados. No hace HTTP ni arranca
  servidor.
- Servido manual: `python3 -m http.server 3502 --directory .` (no se arranca por defecto;
  `RUN_SERVE_COMMAND=1` lo inicia).
- Matriz responsive de ocho anchos con recarga fresca: 320×844, 360×844, 375×844, 390×844
  (DPR 3), 480×844, 736×800, 768×800 y 1280×800 (emulación móvil/táctil ≤480, desktop ≥736).
  Medir `scrollWidth` contra `clientWidth` (en escritorio la barra clásica reduce `clientWidth`
  a 721/753/1265 aunque `innerWidth` sea 736/768/1280), áreas táctiles ≥44×44, etiquetas sin
  truncar, consola 0 y red sin fallos.
- Pruebas negativas del gate en copias temporales fuera del repositorio: token de contraste
  revertido, SVG sin `aria-hidden`, `alt` vacío, sin foco, `prefers-reduced-motion` roto,
  control no real, zoom deshabilitado y las siete mutaciones responsive (`border-box`,
  `max-width`, gutter, label guard, `overflow-x`, breakpoint fuera del set, botón <44px)
  deben salir con código 1 sin listener. Para la vCard: asset ausente, LF en vez de CRLF,
  URL alterada, `href`/`download` cambiados, botón fuera de posición, foco eliminado,
  reduced motion sin `.save-contact-button` y token neutro alterado también deben fallar
  sin arrancar servidor. Para publicación: canonical roto, `og:url` roto, imagen relativa,
  JPEG 1000×630 y asset ausente deben salir con código 1, stderr concreto y sin listener
  en 3502.
- Verificación manual del `.vcf`: `curl -sI http://localhost:3501/assets/fahedhermoza.vcf`
  debe devolver 200 con contenido no vacío; `od -c`/`file` debe confirmar CRLF y ausencia
  de BOM. El puerto 3501 se usó solo para la sesión de la vCard; el hint estándar es 3502.
  La importación real en iOS/Android sigue siendo una prueba manual de dispositivo.
- Lighthouse móvil de accesibilidad sobre `http://localhost:3502` (device `mobile`,
  navigation): objetivo ≥95 y sin auditorías `critical`/`serious`. Es una comprobación manual,
  no forma parte de `init.sh`; repetirla tras cambios visuales o de contraste.
- Verificación live **después del redeploy manual** (no la ejecuta `./init.sh`), ejecutada el
  2026-10-24: cinco paths 200, `og-image` `image/jpeg`, vCard `text/x-vcard`, `/index.html`
  307, `http://` 200 y hashes local/remoto idénticos. Procedimiento reproducible:
  `curl` a `/` y a `/styles.css`, `/assets/avatar.jpg`, `/assets/og-image.jpg` y
  `/assets/fahedhermoza.vcf` debe dar 200 por HTTPS; `og-image` con `image/jpeg`; la vCard con
  `text/x-vcard`/`text/vcard` y cuerpo íntegro (observado: `text/x-vcard`); `/index.html` debe
  redirigir 307 a `/`; y los
  SHA-256 de HTML/assets deben coincidir byte a byte con local. Registrar `cache-control`,
  `cf-cache-status` y el status de `http://`. Usar `?cb=$(date +%s)` solo para saltar caché de
  verificación, nunca en `canonical`/`og:url`.
- Pruebas manuales en iOS y Android de cada Enlace y de la vCard.
- Unfurl manual (Facebook Sharing Debugger y un mensaje de prueba de WhatsApp): puede fallar
  por caché o política del cliente aunque el HTML sea correcto. No declarar "unfurl
  verificado" sin observación real; registrar el resultado tal cual.
- Comprobación de enlaces con un chequeador simple antes de publicar.
- No existe harness E2E persistente (`package.json`, Playwright/Cypress): añadirlo
  introduciría dependencias prohibidas por este stack. La cobertura es `init.sh` +
  Chrome DevTools + Lighthouse móvil.

## Observability

Fuera del alcance del MVP. Sin analítica ni logs. Se reevalúa en `docs/risks-and-open-questions.md`.

## Constraints

- El agente no interpreta imágenes: la `og-image` se genera con una receta reproducible y su
  composición fue aprobada por el propietario el 2026-10-23.
- La URL pública es única y está fijada:
  `https://fahed-hermoza-card.fahedhermoza.workers.dev/`. No se inventan otros dominios ni se
  crea un proyecto Pages.
- El redeploy es manual del propietario; el repo no contiene credenciales, `wrangler.toml` ni
  pipeline de despliegue. `wrangler.jsonc` es configuración externa del propietario, no forma
  parte del código de producto ni de la implementación de `deploy-cloudflare-pages`.
- Presupuesto: cero costo; solo servicios gratuitos (GitHub + Cloudflare Workers + Google Fonts).
