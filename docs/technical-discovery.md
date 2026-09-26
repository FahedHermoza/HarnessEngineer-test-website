# Technical Discovery

## Product Surface

Sitio web estático de una sola página, móvil-first, sin estado ni sesión. Se abre desde navegador móvil tras un Escaneo NFC/QR.

## Candidate Stack

- HTML5 semántico + CSS moderno (custom properties, flexbox, grid mínimo).
- JavaScript mínimo: solo si hace falta para el fallback del avatar o la descarga de la vCard.
- Sin framework, sin bundler, sin build step.
- Tipografía Plus Jakarta Sans vía Google Fonts con pila de respaldo del sistema.
- Iconos como SVG inline (evita dependencias y peticiones extra).

## Data and Storage

- Sin base de datos ni almacenamiento.
- Contenido hardcodeado en `index.html`.
- Assets estáticos:
  - `assets/avatar.jpg` — foto de perfil (presente en el repositorio).
  - `assets/og-image.jpg` — imagen Open Graph 1200×630 (a crear).
  - `assets/fahedhermoza.vcf` — Contacto vCard descargable (o generada como `data:` URI).

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

- Pruebas manuales en iOS y Android de cada Enlace y de la vCard.
- Viewports 320 / 375 / 768 px y escritorio.
- Lighthouse móvil (rendimiento, accesibilidad, SEO).
- Validador de Open Graph (p. ej. depurador de enlaces) tras el despliegue.
- Comprobación de enlaces con un chequeador simple antes de publicar.

## Observability

Fuera del alcance del MVP. Sin analítica ni logs. Se reevalúa en `docs/risks-and-open-questions.md`.

## Constraints

- Este agente no puede leer ni generar imágenes: el avatar ya está en el repo y la `og-image` debe producirse con otra herramienta.
- La URL pública final (proyecto/dominio en Cloudflare Pages) aún no está definida.
- Presupuesto: cero costo; solo servicios gratuitos (GitHub + Cloudflare Pages + Google Fonts).
