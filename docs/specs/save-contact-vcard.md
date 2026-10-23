# Feature Implementation Spec: Botón Guardar contacto descarga la vCard

## Source Feature

- `id`: `save-contact-vcard` · `area`: `contact` · `status`: `not_started`
- `depends_on`: `profile-identity`, `links-order-gradient` (both `accepted`)
- `source`: `feature_list.json`; resuelve la decisión `.vcf` estático vs `data:text/vcard` de `docs/risks-and-open-questions.md`.

## Goal

Añadir el control **Guardar contacto** entre los siete Enlaces y el pie, con la forma de un Enlace pero tratamiento neutro (`#f1f4fa` fondo, `#484dc4` texto). Al pulsarlo debe ofrecer/descargar una Contacto vCard estática con nombre, teléfono, correo y los cinco Enlaces externos, importable por iOS/Android, sin JavaScript ni dependencias.

Termina cuando el botón, `assets/fahedhermoza.vcf`, el gate y los docs durables están implementados; `./init.sh` pasa con los nuevos conteos; y la descarga se validó por HTTP/navegador en 390×844 y 1280×800. La importación real en agenda es manual de dispositivo y debe registrarse sin fabricarla.

## Non-Goals

- No cambiar los siete Enlaces (orden, tonos, URLs, iconos), el pie, el perfil ni Open Graph.
- No usar `data:text/vcard`, Blob, `<script>`, generación en cliente ni JavaScript nuevo.
- No añadir `_headers`, `Content-Disposition` personalizado ni trabajo de despliegue.
- No añadir foto/avatar, `ORG`, `REV`, analítica, QR, modo oscuro ni responsive breakpoints.
- No añadir tokens, fuentes, frameworks, bundlers, npm ni dependencias.
- No debilitar `init.sh`: sigue siendo no bloqueante y no arranca servidor por defecto.
- No marcar `accepted`; el implementador deja `passing` y el validador acepta.

## Job Story

When conozco a Fahed y quiero conservar sus datos,
I want pulsar un solo botón y guardar su contacto completo en mi agenda,
so I can volver a escribirle o llamarle sin copiar enlaces uno por uno.

## Users And Permissions

- Visitante anónimo: descarga/importa la vCard; sin autenticación, estado ni permisos.
- Propietario/agente: mantiene el `.vcf`, el botón y sus docs editando archivos estáticos.
- Implementador/validador: extiende el gate, verifica en navegador y registra evidencia; no implementa otras features.

## Acceptance Scenarios

### Scenario 1: Posición, tamaño y orden vertical

Given la Tarjeta digital en 390×844 o 1280×800,
When se inspeccionan los hijos de `article.card`,
Then el orden es Perfil → `<nav class="links">` → `.save-contact` → `<footer class="page-footer">`; el botón mide 48px de alto, 308px de ancho en móvil y 350px en escritorio, radio 6px, 12px tras el último Enlace y sin scroll horizontal.

### Scenario 2: Tratamiento neutro fuera de la rampa

Given el botón renderizado,
When se leen sus estilos computados,
Then fondo `rgb(241, 244, 250)`, texto/icono `rgb(72, 77, 196)`, etiqueta `button-label` 11px/800 mayúsculas, icono 18×18 a la derecha y sin degradado; contraste 6.082:1 en reposo y 6.456:1 con `filter: brightness(1.03)`.

### Scenario 3: Descarga same-origin sin JavaScript

Given el botón con `href="assets/fahedhermoza.vcf"` y `download="fahedhermoza.vcf"`,
When se pulsa con ratón o `Enter` (también con JavaScript deshabilitado),
Then el navegador solicita/descarga el archivo con 200 y lo ofrece como `fahedhermoza.vcf`; no hay `data:`, Blob, `<script>` ni manejadores inline.

### Scenario 4: Contenido y codificación de la vCard

Given `assets/fahedhermoza.vcf`,
When se inspeccionan sus bytes,
Then es UTF-8 sin BOM, todas las líneas terminan en CRLF (incluida `END:VCARD`), pesa ≤4096 bytes y contiene `BEGIN:VCARD`, `VERSION:3.0`, `N:Hermoza;Fahed;;;`, `FN:Fahed Hermoza`, `TITLE:Software Engineer & Speaker & Builder`, `TEL;TYPE=CELL:+51955116562`, `EMAIL;TYPE=INTERNET:fahedhermoza@gmail.com`, los cinco `URL:` externos y `END:VCARD`.

### Scenario 5: Accesibilidad, teclado y movimiento reducido

Given la página cargada,
When se recorre con `Tab` y se emula `prefers-reduced-motion: reduce`,
Then hay 10 anclas reales (7 `.link-button` + 1 `.save-contact-button` + 2 `.page-footer__link`) y 8 SVG decorativos; el botón se llama `Guardar contacto`, tiene `href` no vacío, su icono lleva `aria-hidden="true"`/`focusable="false"`, muestra `outline: 2px solid var(--color-accent); outline-offset: 2px;` y con movimiento reducido usa `transition: none`/`transform: none` sin animaciones nuevas.

### Scenario 6: El gate detecta regresiones

Given una copia temporal con el `.vcf` ausente, CRLF cambiados a LF, `download`/`href` alterado, el botón fuera de posición, el foco eliminado, reduced motion roto o el contraste neutro cambiado,
When se ejecuta `./init.sh`,
Then sale con código 1, imprime el check concreto en stderr y no arranca ningún servidor.

### Scenario 7: Consola, red y Lighthouse

Given la página servida manualmente en `http://localhost:3501`,
When se carga en 390×844/1280×800 y se ejecuta Lighthouse móvil de accesibilidad,
Then consola con 0 mensajes, peticiones 2xx/3xx sin `/favicon.ico`, sin scroll horizontal, y accesibilidad ≥95 sin auditorías `critical`/`serious`.

## Repository Research

### Files Inspected

- `AGENTS.md`, `PROGRESS.md`, `feature_list.json` — DoD, validación 390×844/1280×800, estado: la feature es la siguiente lista; el gate real cuenta 9 anclas (7 `.link-button` + 2 pie) y 7 SVG.
- `CONTEXT.md`, `docs/build-brief.md`, `docs/domain-model.md` — la Contacto (vCard) resume Perfil, Celular/Correo e incluye los Enlaces; el botón va después de los Enlaces.
- `DESIGN.md` — Perfil → Enlaces → Guardar contacto → Pie; misma forma que `.link-button` (48px, `rounded.md`, icono 18px derecha) con `#f1f4fa`/`#484dc4`; la pregunta “neutro vs degradado” sigue abierta.
- `CONSTRAINTS.md`, `docs/technical-discovery.md` — conservan conteos **obsoletos** 14 anclas/12 SVG (incluían la demo retirada); deben corregirse a 10/8. El segundo deja abierto “`.vcf` o `data:` URI”.
- `docs/risks-and-open-questions.md`, `docs/specs/accessibility-baseline.md`, `docs/specs/links-order-gradient.md` — decisión vCard pendiente, diferencia iOS/Android, `_headers` fuera de MVP y patrón de gate/evidencia.
- `index.html`, `styles.css` — 7 Enlaces (51–97) y pie (98–104); `.link-button` (48px, padding 20px, radio 6px), `.links` padding `0 1.5rem`, hover/foco/reduced motion; 51 tokens, sin tokens nuevos.
- `init.sh`, `assets/` — baseline verde (`exit 0`), `Accessibility checks:` 9 anclas/7 SVG y contraste 13/13; solo `avatar.jpg`/`.DS_Store`, sin `.vcf` ni `og-image.jpg`.

### Existing Patterns To Follow

- HTML estático, CSS plano, BEM-ish y valores derivados de tokens; assets en `assets/`.
- Gate aditivo con `awk`/`grep`, `FAILED - …` a stderr, `exit 1`, sin servidor por defecto.
- Evidencia en `feature_list.json`/`PROGRESS.md`; el validador crea `docs/validations/save-contact-vcard.md`. Sin E2E persistente: añadirlo introduciría dependencias prohibidas.

### Current Gaps

- No existen el asset vCard ni el botón; el `.vcf` es la única forma de “guardar contacto” sin JS.
- Los conteos 14/12 de `CONSTRAINTS.md`/`technical-discovery.md` están desfasados respecto al gate real 9/7.
- `DESIGN.md` no detalla hover/foco del botón neutro y mantiene abierta la decisión; no hay dispositivo iOS/Android en el entorno.

## Technical Approach

### Decisión: `.vcf` estático (recomendado)

Se elige `assets/fahedhermoza.vcf`: funciona sin JS, es cacheable, se valida byte a byte y no depende de MIME generado en cliente. Se descarta `data:text/vcard` porque Android bloquea la navegación `data:` de nivel superior y iOS es inconsistente; Blob exige JavaScript y viola las restricciones del stack.

- Nombre: `assets/fahedhermoza.vcf`; `download="fahedhermoza.vcf"`.
- MIME local: Python 3.14 resuelve `.vcf` como `text/x-vcard` (medido; también con `mime.types` de macOS). Es legacy pero reconocido por iOS/Android.
- Cloudflare Pages: sin `_headers`, puede servir `text/vcard` u `octet-stream`; `download` garantiza descarga y `.vcf` permite importar. No se depende de una cabecera; en `deploy-cloudflare-pages` podrá preferirse `text/vcard; charset=utf-8` + `Content-Disposition`.

### Contenido exacto (cada línea termina en CRLF, incluida la última)

```text
BEGIN:VCARD
VERSION:3.0
N:Hermoza;Fahed;;;
FN:Fahed Hermoza
TITLE:Software Engineer & Speaker & Builder
TEL;TYPE=CELL:+51955116562
EMAIL;TYPE=INTERNET:fahedhermoza@gmail.com
URL:https://www.instagram.com/fahedhermoza/
URL:https://www.facebook.com/fahed19
URL:https://wa.me/51955116562
URL:https://www.linkedin.com/in/fahedhermoza/
URL:https://fahedhermoza.github.io/
END:VCARD
```

UTF-8 sin BOM; contenido ASCII, `&` literal (no `&amp;`). Sin `PHOTO`, `ORG`, `REV` ni `UID` para evitar datos inventados y mantenimiento extra. Tamaño esperado ≪4096 bytes.

### Markup exacto (entre `</nav>` y `<footer class="page-footer">`)

```html
<div class="save-contact">
  <a class="save-contact-button" href="assets/fahedhermoza.vcf" download="fahedhermoza.vcf">
    <span class="save-contact-button__label">Guardar contacto</span>
    <svg class="save-contact-button__icon" viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true" focusable="false">
      <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/>
      <circle cx="9" cy="7" r="4"/>
      <line x1="19" y1="8" x2="19" y2="14"/>
      <line x1="22" y1="11" x2="16" y2="11"/>
    </svg>
  </a>
</div>
```

No se reutiliza `.link-button`: los 7 Enlaces y sus gates de orden/tono quedan intactos y el botón no entra en la rampa. El nombre accesible sale del texto visible; no hace falta `aria-label`.

### CSS

- `.save-contact { padding: var(--space-sm) var(--space-lg) 0; }` para alinear con `.links` y dejar 12px tras el último Enlace.
- `.save-contact-button`: mismas medidas que `.link-button` (`width:100%`, `height:48px`, `padding:0 1.25rem`, `border-radius:var(--radius-md)`, `justify-content:space-between`, `text-transform:uppercase`, `button-label`), pero `background: var(--color-surface-container-low); color: var(--color-primary);`.
- Sombra neutra con los rgba ya usados por `.card`: `0 2px 6px rgba(25,30,48,0.08)`; hover/foco `0 8px 18px rgba(25,30,48,0.12)`, `translateY(-1.5px)`, `filter: brightness(1.03)` y `outline: 2px solid var(--color-accent); outline-offset: 2px;` en `:focus-visible`.
- Añadir `.save-contact-button` y sus estados al bloque `@media (prefers-reduced-motion: reduce)` existente (`transition: none`, `transform: none`); no crear animaciones nuevas.

### Cambios en `init.sh` (sin debilitar nada)

Añadir `Save contact checks:` antes de `Accessibility checks:`:

1. `.vcf` existe, no vacío, ≤4096 bytes; validación byte a byte con Python 3 (sin BOM, UTF-8, CRLF-only, `BEGIN/END`, campos y 5 `URL:` exactos).
2. Coherencia: los 5 `URL:` coinciden con los `href` de Instagram, Facebook, WhatsApp, LinkedIn y Portafolio; `TEL`/`EMAIL` coinciden con Celular/Correo.
3. Markup: un único `.save-contact` con exactamente un `<a class="save-contact-button" href="assets/fahedhermoza.vcf" download="fahedhermoza.vcf">`, etiqueta `Guardar contacto`, icono 18×18 decorativo; posición tras `</nav>` y antes del pie; sin `data:text/vcard`.
4. Componente: regla `.save-contact-button` con las 6 declaraciones de forma y colores neutros; `:focus-visible` con outline/offset; presencia en reduced motion.
5. Conteos: 10 anclas (7 `.link-button` + 1 `.save-contact-button` + 2 pie) y 8 SVG; actualizar el mensaje `[ok] 10 real anchor controls …`.
6. Contraste: añadir `--color-primary|#484dc4` y `--color-surface-container-low|#f1f4fa` a `CONTRAST_TOKENS` (8/8) y dos checks calculados (neutro en reposo y con `brightness(1.03)`); el total pasa de 13/13 a 15/15.
7. Mantener checks previos, hint 3413 y servidor opt-in (`RUN_SERVE_COMMAND=1`).

## Expected File Changes

- `assets/fahedhermoza.vcf` — crear; vCard 3.0 estática.
- `index.html` — insertar `.save-contact` entre nav y pie.
- `styles.css` — componente neutro, foco y reduced motion.
- `init.sh` — `Save contact checks:`, conteos 10/8 y contraste 15/15.
- `CONSTRAINTS.md`, `docs/technical-discovery.md`, `DESIGN.md`, `docs/risks-and-open-questions.md` — actualizar según abajo.
- `feature_list.json`, `PROGRESS.md` — `passing` + evidencia y sesión.
- `docs/validations/save-contact-vcard.md` — crear solo en la validación independiente.
- `docs/specs/save-contact-vcard.md` — este spec; no es código de producto.

## Visual Design Impact

- UI involved: yes. Design source: `DESIGN.md` (`colors`, `components/button-link`, `Core Screens`).
- Estados: única Tarjeta digital; reposo, hover, `:focus-visible` y reduced motion del botón; 390×844 y 1280×800.
- New design artifact required: no — usa tokens existentes y las sombras de `.card`; no crea colores ni tipografías.

## Durable Documentation Impact

- `ARCHITECTURE.md`, `AGENTS.md`, `CONTEXT.md`, `docs/domain-model.md`: not needed — no nuevo layer/surface/dependencia, workflow intacto, vocabulario y edge case ya documentados; verificado que `AGENTS.md` no contiene conteos.
- `CONSTRAINTS.md`: update — sustituir “14 anchors / 12 SVG” por **10 / 8**, añadir `.save-contact-button:focus-visible` y reduced motion, pinear `#484dc4`/`#f1f4fa` y exigir vCard 3.0 UTF-8/CRLF con datos canónicos.
- `DESIGN.md`: update — marcar resuelta la pregunta “neutro vs degradado” y documentar forma, colores, icono y estados.
- `docs/technical-discovery.md`: update — resolver `.vcf` estático, corregir 14/12 a 10/8 y añadir la verificación de la vCard.
- `docs/risks-and-open-questions.md`: update — cerrar el mecanismo; mantener iOS/Android como prueba manual.
- `feature_list.json`/`PROGRESS.md`: update por el implementador; `docs/validations/save-contact-vcard.md` por el validador.

## Implementation Plan

1. Confirmar baseline con `bash -n init.sh && ./init.sh` y crear `assets/fahedhermoza.vcf` (CRLF, UTF-8 sin BOM).
2. Insertar el markup entre `</nav>` y el pie y añadir el CSS neutro, hover/foco y reduced motion.
3. Extender `init.sh` con asset, coherencia, markup, posición, componente, conteos 10/8 y contraste 15/15.
4. Actualizar los cuatro docs durables.
5. Verificar gate, casos negativos, navegador 390×844/1280×800 y Lighthouse; registrar `passing`.

## Implementation Tasks

- [ ] Confirmar baseline y crear `assets/fahedhermoza.vcf` (VCARD 3.0, CRLF, UTF-8 sin BOM, ≤4096 bytes).
- [ ] Insertar `.save-contact` con ancla, `download`, etiqueta e icono decorativo, y añadir `.save-contact`/botón/label/icon/hover/focus/reduced motion.
- [ ] Añadir `Save contact checks:` (asset, coherencia, markup, posición, componente) y actualizar conteos a 10/8 y contraste 8/8/15/15.
- [ ] Actualizar `DESIGN.md`, `CONSTRAINTS.md`, `docs/technical-discovery.md` y `docs/risks-and-open-questions.md`.
- [ ] Ejecutar casos negativos y verificar 390×844/1280×800, descarga, teclado y Lighthouse.
- [ ] Registrar `passing` + evidencia en `feature_list.json` y `PROGRESS.md`.

## Verification Plan

- `bash -n init.sh` → sin errores; `./init.sh` → exit 0, sin servidor, con `[ok] save contact …`, `[ok] 10 real anchor controls …`, `[ok] 8 decorative SVG …` y `[ok] accessibility contrast contract (15/15)`.
- Servidor manual solo por implementador/validador: `python3 -m http.server 3501 --directory .`, detenerlo y dejar 3501 libre. El planner no arranca servidores. No cambiar el hint estándar 3413 de `init.sh`.
- `curl -sI http://localhost:3501/assets/fahedhermoza.vcf` → 200, `Content-Type: text/x-vcard`, `Content-Length` >0; `curl -s … | od -c`/`file` → CRLF y sin BOM.
- Navegador 390×844/1280×800: consola 0; red 2xx/3xx sin `/favicon.ico`; sin scroll horizontal; botón 308×48/350×48, gap 12px, fondo/texto neutros, icono 18×18; `Tab` recorre 10 controles en orden y el outline se ve; hover `translateY(-1.5px)` + sombra + `brightness(1.03)`; reduced motion `none`/`0s`; al pulsar, petición 200 a `assets/fahedhermoza.vcf` y oferta/descarga de `fahedhermoza.vcf`. No activar destinos externos.
- Lighthouse móvil (`chrome-devtools_lighthouse_audit`, device mobile, navigation, `http://localhost:3501/`): accesibilidad ≥95, sin fallos `critical`/`serious`.
- Casos negativos en copias temporales fuera del repo (borrar después, sin listener): `.vcf` ausente; LF en vez de CRLF; URL del `.vcf` distinta; `download`/`href` eliminado; botón fuera de posición; `:focus-visible` sin outline; reduced motion sin `.save-contact-button`; token neutro alterado.
- iOS/Android reales: pulsar y confirmar vista previa/importación. Si no hay dispositivo, registrarlo como pendiente manual; no afirmar que se probó.
- E2E: no existe harness persistente y añadirlo introduciría dependencias prohibidas; cobertura = `init.sh` + navegador + Lighthouse.

## Evidence To Capture

- Salida de `bash -n init.sh` y `./init.sh` (todos los `[ok]`, 10/8, 15/15, exit 0, sin servidor) y cabeceras/tamaño/bytes del `.vcf` (`curl -I`, `od -c`/`file`).
- Tabla de navegador 390×844/1280×800 (geometría, colores, foco, hover, reduced motion, consola, red, petición del `.vcf`) y Lighthouse móvil en 3501.
- Stderr de cada caso negativo sin listener; `feature_list.json` + `PROGRESS.md`; `docs/validations/save-contact-vcard.md` en la validación.
- Nota explícita sobre la prueba iOS/Android (realizada o pendiente manual).

## Validator Checklist

- [ ] El botón está entre Enlaces y pie, mide 48px, usa el neutro exacto y el `.vcf` es estático, VCARD 3.0, CRLF, UTF-8 sin BOM, ≤4096 bytes con nombre, teléfono, correo y los 5 Enlaces.
- [ ] El ancla descarga `fahedhermoza.vcf` sin JS, sin `data:` ni manejadores inline.
- [ ] Accesibilidad: 10 anclas, 8 SVG, nombre accesible, foco visible, reduced motion y contraste 15/15; navegador 390×844/1280×800 y Lighthouse móvil ≥95 sin `critical`/`serious`.
- [ ] `./init.sh` sale 0 sin servidor y detecta todos los casos negativos.
- [ ] Docs durables con conteos 10/8 (no 14/12) y decisión vCard cerrada.
- [ ] `feature_list.json`/`PROGRESS.md` actualizados; prueba iOS/Android registrada con honestidad.
- [ ] Sin cambios fuera de alcance: 7 Enlaces, pie, perfil, metadatos, tokens, JS y dependencias intactos.

## Risks And Open Questions

- **MIME variable:** `python3 -m http.server` sirve `text/x-vcard`, pero Cloudflare Pages puede usar `text/vcard` u `octet-stream`; sin `_headers` no se controla. Mitigación: `download` + extensión `.vcf`; validar en `deploy-cloudflare-pages`.
- **Importación iOS/Android no automatizable:** sin dispositivos, la prueba real es manual y debe registrarse como pendiente si no se ejecuta; un 200 y un MIME correcto no prueban la agenda.
- **`download` en iOS:** algunas versiones guardan en Archivos y otras muestran vista previa; ambas cumplen “ofrece/descarga”. Si se exige preview directo, reevaluar en una feature posterior.
- **Deriva HTML/vCard:** los datos están duplicados; el gate compara los 5 `URL:`, `TEL` y `EMAIL` para detectar desincronización.
- **Duplicación CSS y contraste congelado:** `.save-contact-button` repite la forma de `.link-button` para no tocar el gate de los 7 Enlaces; `#484dc4` sobre `#f1f4fa` (6.082/6.456) entra en el gate y cambiarlo exige recalcular y actualizar `DESIGN.md`.
- **Docs obsoletos, sin bloqueos:** `CONSTRAINTS.md`/`technical-discovery.md` dicen 14/12; el gate real es 9/7 hoy y 10/8 tras esta feature. Corregirlos es parte del alcance y la decisión de mecanismo queda cerrada con `.vcf` estático.
