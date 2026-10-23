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
  - `assets/og-image.jpg` — imagen Open Graph 1200×630 (a crear).
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
- Despliegue en Cloudflare Pages conectado al repositorio.
- Sin comando de build; directorio de salida: raíz del repositorio.
- HTTPS provisto por Cloudflare Pages.
- Mantenimiento: editar `index.html` / `assets` y hacer push.

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
- Servido manual: `python3 -m http.server 3413 --directory .` (no se arranca por defecto;
  `RUN_SERVE_COMMAND=1` lo inicia). Validación visual en 390×844 y 1280×800.
- Pruebas negativas del gate en copias temporales fuera del repositorio: token de contraste
  revertido, SVG sin `aria-hidden`, `alt` vacío, sin foco, `prefers-reduced-motion` roto,
  control no real y zoom deshabilitado deben salir con código 1 sin listener. Para la
  vCard: asset ausente, LF en vez de CRLF, URL/fecha alterada, `href`/`download` cambiados,
  botón fuera de posición, foco eliminado, reduced motion sin `.save-contact-button` y
  token neutro alterado también deben fallar sin arrancar servidor.
- Verificación manual del `.vcf`: `curl -sI http://localhost:3501/assets/fahedhermoza.vcf`
  debe devolver 200 con contenido no vacío; `od -c`/`file` debe confirmar CRLF y ausencia
  de BOM. La importación real en iOS/Android sigue siendo una prueba manual de dispositivo.
- Lighthouse móvil de accesibilidad sobre `http://localhost:3413` (device `mobile`,
  navigation): objetivo ≥95 y sin auditorías `critical`/`serious`. Es una comprobación manual,
  no forma parte de `init.sh`; repetirla tras cambios visuales o de contraste.
- Pruebas manuales en iOS y Android de cada Enlace y de la vCard.
- Viewports 320 / 375 / 768 px y escritorio.
- Validador de Open Graph (p. ej. depurador de enlaces) tras el despliegue.
- Comprobación de enlaces con un chequeador simple antes de publicar.
- No existe harness E2E persistente (`package.json`, Playwright/Cypress): añadirlo
  introduciría dependencias prohibidas por este stack. La cobertura es `init.sh` +
  Chrome DevTools + Lighthouse móvil.

## Observability

Fuera del alcance del MVP. Sin analítica ni logs. Se reevalúa en `docs/risks-and-open-questions.md`.

## Constraints

- Este agente no puede leer ni generar imágenes: el avatar ya está en el repo y la `og-image` debe producirse con otra herramienta.
- La URL pública final (proyecto/dominio en Cloudflare Pages) aún no está definida.
- Presupuesto: cero costo; solo servicios gratuitos (GitHub + Cloudflare Pages + Google Fonts).
