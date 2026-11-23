# Constraints

## Diseño — fuente de verdad (`DESIGN.md`)

Estas reglas son durables: todo cambio con UI debe preservarlas.

- **MUST** tratar `DESIGN.md` como la fuente de verdad del diseño y como **de solo
  lectura durante la implementación**: el código (HTML/CSS) se ajusta a `DESIGN.md`.
- **MUST NOT** editar `DESIGN.md` para que describa lo que ya se codeó. Un cambio de
  diseño (valor de token, color, tono, geometría, layout, conteo de componentes) se
  decide **antes** de implementar, con el propietario/planner, y se refleja primero en
  `DESIGN.md`; solo entonces se implementa.
- **MUST** mantener coherentes los colores del front-matter `colors:` de `DESIGN.md` con
  los tokens `--color-<name>` de `styles.css`. El gate `Design conformance checks:` de
  `./init.sh` falla (`exit 1`) ante cualquier deriva en cualquier dirección; no se debe
  debilitar ni eliminar ese check.
- **MUST** mantener `DESIGN.md` internamente consistente: si una feature reasigna o retira
  el uso de un token/componente (p. ej. mover Enlaces a Acciones rápidas), actualizar la
  sección narrativa afectada en la misma decisión de diseño, no dejarla describiendo el
  estado anterior.

## Accessibility Baseline (AA)

These rules are durable: every future change to the Tarjeta digital must preserve them.
`./init.sh` enforces the technically checkable subset; do not remove, weaken or reorder
its `Accessibility checks:`.

- **MUST** keep every control that has its own navigation destination a real `<a>` with a
  non-empty `href`, with three explicit scoped exceptions (below) for non-anchor
  `<button>` controls: exactly 11 anchors today (5 `.link-button` + 3 `.quick-action`
  + 1 `.save-contact-button` + 1 `.page-footer__link` + 1 `.qr-panel__save`). The three
  anchor `.quick-action` controls are the icon-only Celular (`href="tel:+51955116562"`),
  Correo (`href="mailto:fahedhermoza@gmail.com"`) and QR (`href="assets/qr.png"`, the
  no-JS fallback to the static PNG) in the `.quick-actions` row; each gets its accessible
  name from `aria-label`, not visible text. `.qr-panel__save` ("Guardar PNG") is a real
  anchor with `href="assets/qr.png"` and `download="fahed-hermoza-card-qr.png"`.
- **MUST** allow exactly 3 non-anchor controls, and no more: `<button type="button"
  class="qr-panel__close">` and `<button type="button" class="qr-panel__copy">` (in-page
  actions inside the `<dialog class="qr-panel">`: close the dialog; copy the canonical
  URL to the clipboard), plus `<button type="button" class="quick-action quick-action--share">`
  (Compartir, a fourth `.quick-actions` control with no navigation destination of its
  own — it uses the Web Share API or falls back to clipboard copy). A semantic `<button>`
  is native, keyboard-operable and reported correctly to assistive tech without extra
  ARIA. This is the complete, explicit, scoped relaxation of the "every control is an
  `<a>`" rule; it does **not** extend to any other control, and every other interactive
  element MUST stay a real `<a>`. None of the three count toward the anchor total above,
  and none carry `href`; each handler is bound with `addEventListener` in a real script
  file, never an inline attribute.
- **MUST NOT** use `role="button"`, inline `onclick`/`onkeydown`/`onkeypress`,
  `href="#"` or `href=""` for controls — including the three buttons above.
- **MUST** keep a visible keyboard focus on every control:
  `outline: 2px solid var(--color-accent);` and `outline-offset: 2px;` on
  `.link-button:focus-visible`, `.quick-action:focus-visible`,
  `.save-contact-button:focus-visible`, `.page-footer__link:focus-visible` and
  `.qr-panel__close:focus-visible` / `.qr-panel__copy:focus-visible` /
  `.qr-panel__save:focus-visible`.
- **MUST NOT** declare `outline: none` or `outline: 0` in `styles.css`.
- **MUST** keep text and icon contrast at or above 4.5:1, including the hover/focus
  `filter: brightness(1.03)` state. Current pinned values:
  `--color-gradient-1` `#5a67d1`, `-2` `#645fcc`, `-3` `#705aca`, `-4` `#8055c8`,
  `-5` `#9252c5`, `--color-on-surface-variant` `#6b7280`,
  `--color-primary` `#484dc4`, `--color-surface-container-low` `#f1f4fa`.
- **MUST NOT** change a contrast token without recalculating rest and hover/focus
  ratios, updating `DESIGN.md`, and keeping the `./init.sh` contrast gate green.
- **MUST** keep `.link-button` labels and icons `#ffffff`; if contrast fails, darken the
  background token, not the label color or the `button-label` scale. The neutral
  `.save-contact-button` keeps `#484dc4` text/icon on `#f1f4fa` (6.082:1 rest,
  6.456:1 with `brightness(1.03)`). The two `.quick-action` circles reuse that same
  pinned neutral pair — `--color-primary` icon on `--color-surface-container-low` surface
  (same 6.082:1 rest / 6.456:1 hover ratios, already covered by the 15/15 contrast gate);
  they are NOT gradient chips. Do not give them white-on-gradient tones or new colors.
- **MUST** keep every decorative `<svg>` with both `aria-hidden="true"` and
  `focusable="false"`: exactly 13 decorative SVG icons today (5 Enlaces + 3 quick-action
  icons (Celular, Correo, QR) + 1 quick-action Share icon + the save contact icon +
  2 header icons: NFC label and open + 1 footer NFC/QR closing icon). The
  `<img class="qr-panel__code">` inside the QR panel is content, not decoration, and does
  not count toward this total.
- **MUST** keep the static QR asset `assets/qr.png`: a real PNG (magic bytes
  `\x89PNG\r\n\x1a\n`), non-empty, pre-generated **offline** (no runtime/client-side QR
  generation, no QR library shipped to the browser) and committed as a binary like
  `assets/og-image.jpg`/`assets/avatar.jpg`. It encodes the exact canonical production
  URL (byte-identical to `PRODUCTION_URL`); confirm with a real-device scan before
  calling the feature accepted — `./init.sh` cannot decode PNG content, only its
  existence/format.
- **MUST** keep the Contacto vCard as the static `assets/fahedhermoza.vcf`: UTF-8
  without BOM, CRLF line endings (including the final `END:VCARD`), VCARD 3.0 with the
  canonical name, title, phone, email and five external URLs, at most 4096 bytes.
  The save contact control MUST stay a real anchor with
  `href="assets/fahedhermoza.vcf"` and `download="fahedhermoza.vcf"`. The prohibition on
  `data:text/vcard`, Blob, a `<script>` or an inline handler applies specifically to this
  vCard mechanism (the `.save-contact` block): it MUST NOT ever be regenerated or invoked
  via Blob, `data:` URI, inline handler or any `<script>` inside that block. This does not
  forbid the QR panel's own `<script>` (`scripts.js`) or Compartir's `share.js` elsewhere
  on the page — both are separate, explicitly allowed exceptions for unrelated, non-vCard
  interactions and must not be grepped against as if they were a vCard violation (scope
  any such check to the save-contact block, not the whole document); neither script may
  ever construct the vCard via Blob or `data:text/vcard`.
- **MUST** keep the Share control (`.quick-action--share`) as mejora progresiva: it is
  `hidden` by default in the static HTML, CSS MUST hide `[hidden]` explicitly
  (`.quick-action[hidden], .share-status[hidden] { display: none; }`, because
  `.quick-action { display: flex }` alone would override the UA default), and only
  `share.js` (or an equivalent inline script, loaded with `defer`) may remove `hidden`
  after detecting `navigator.share` or `navigator.clipboard.writeText` support. Without
  JavaScript, or without either API, the control MUST stay absent — never an inert,
  unclickable button.
- **MUST** always use the production canonical URL
  (`document.querySelector('link[rel="canonical"]').href`) as the Compartir/QR share
  target: never `location.href`, never a query string (`?utm`, `?debug` or similar), never
  an alternate domain.
- **MUST** keep the avatar `alt` descriptive and non-empty.
- **MUST** keep `<html lang="es">` and mark the English Tagline with `lang="en"`
  (WCAG 3.1.2, Language of Parts).
- **MUST** keep the viewport zoomable: no `user-scalable=no` and no `maximum-scale`.
- **MUST** keep `@media (prefers-reduced-motion: reduce)` disabling `transition` and
  `transform` for `.link-button`, `.save-contact-button`, `.quick-action` and
  `.qr-panel__close`/`.qr-panel__copy`/`.qr-panel__save`, plus `animation: none;` for the
  `<dialog class="qr-panel">` open animation; do not add other animations.
- **MUST** keep each `.quick-action` circle a tap target of at least 44×44 (diameter
  `width`/`height` >= 44px; currently 48×48) at every audited width; it is an icon-only
  control and the 44×44 target applies (it is not covered by the inline-link exception).
  `.qr-panel__close` is the same fixed 44×44 circle. `.qr-panel__copy`/`.qr-panel__save`
  share a flexible row (`flex: 1 1 0%`, `height: 48px`) inside a dialog capped at
  `min(320px, calc(100vw - 2rem))`; their height is statically asserted, their rendered
  width (always well above 44px for a two-button row) is verified in the browser.
- **MUST NOT** add JavaScript, frameworks, bundlers, dependencies or generated assets
  to satisfy accessibility rules (see `docs/technical-discovery.md`), **except** the two
  explicitly scoped exceptions below for the QR panel interaction and for Compartir.
  Neither exists to patch an accessibility gap — the AA baseline holds with JavaScript
  disabled in both cases (see the no-JS degradation paths below and the mejora
  progresiva rule above).
- **MUST** keep the QR panel's JavaScript minimal, dependency-free and scoped only to
  opening/closing the `<dialog class="qr-panel">` and copying the canonical URL to the
  clipboard: a single `<script>` (inline or `scripts.js`) using only `addEventListener`
  (no inline `onclick`/`onkeydown`/`onkeypress`, no `.onclick =`-style assignment, no
  third-party/CDN script `src`). It MUST declare a `CANONICAL_URL` constant
  byte-identical to `PRODUCTION_URL`, and MUST NOT be used as a crutch for base
  accessibility (focus order, labeling, contrast) that HTML/CSS already provide.
- **MUST** keep a no-JS degradation path for the QR action: without JavaScript (or
  without `HTMLDialogElement`/`showModal` support), the QR quick action and
  `.qr-panel__save` stay real anchors to the static `assets/qr.png`; they must never
  become inert controls.
- **MUST** keep Compartir's `share.js` minimal and dependency-free (see the mejora
  progresiva rule above for its no-JS degradation path: the control simply stays absent).

The one inline footer link (WhatsApp) is shorter than 44px; it stays covered by the
WCAG 2.5.8 inline/link-in-text exception. Re-evaluate that exception if the footer
layout changes.

## Responsive Baseline

These rules are durable: the Tarjeta must render complete and without horizontal scroll across
the 320–1280px range. `./init.sh` enforces the checkable subset in `Responsive checks:`; do not
remove, weaken or reorder it.

- **MUST** keep `documentElement.scrollWidth === clientWidth` and
  `body.scrollWidth === clientWidth` at every audited width (320, 360, 375, 390, 480, 736, 768
  and 1280 CSS px), with only vertical overflow when content is taller than the viewport.
- **MUST** keep the single fluid card formula `width: min(400px, calc(100vw - 2rem))` with
  `max-width: 100%`, inside `.page` padding using `var(--space-gutter)` (16px per side) and the
  universal `box-sizing: border-box`.
- **MUST** keep every Enlace full width with `height: 48px` and
  `min(rect.width, rect.height) >= 44px` at every audited width; keep labels untruncated by
  preserving the `.link-button__label` shrink guard (`min-width: 0`, `overflow: hidden`,
  `white-space: nowrap`, `text-overflow: ellipsis`).
- **MUST NOT** mask horizontal overflow with `overflow-x: hidden/clip`, `overflow: hidden/clip`
  on `html`/`body`/`.page`, or a `width: 100vw` element. Fix the layout instead. The ellipsis
  `overflow: hidden` on `.link-button__label` is intentional and excluded from this rule.
- **MUST NOT** add width breakpoints outside the `DESIGN.md` audit set `360px`, `480px` and
  `736px`; if a future width breakpoint touches `.link-button`, its declared `height` must stay
  at or above 44px.
- **MUST** re-run the eight-width browser matrix and the `Responsive checks:` gate after any
  change to layout, typography, card width, Enlace button or footer; the runtime proof cannot
  be replaced by static grep alone.
- The one inline footer link (WhatsApp) stays under the WCAG 2.5.8 inline/link-in-text
  exception; do not evaluate it against the 44×44 target unless the footer layout changes.

## Publicación (Cloudflare Workers static assets)

These rules are durable: the production identity and social preview must stay exact.
`./init.sh` enforces the checkable subset in `Sharing metadata production checks:`; do not
remove, weaken or reorder it.

- **MUST** keep one production origin only:
  `https://fahed-hermoza-card.fahedhermoza.workers.dev`, declared once in `init.sh` as
  `PRODUCTION_ORIGIN`, with `PRODUCTION_URL` (trailing slash) and `PRODUCTION_IMAGE_URL`
  derived from it.
- **MUST** keep `canonical` and `og:url` byte-identical to `PRODUCTION_URL`
  (`https://fahed-hermoza-card.fahedhermoza.workers.dev/`) and `og:image`/`twitter:image`
  byte-identical to `PRODUCTION_IMAGE_URL`
  (`https://fahed-hermoza-card.fahedhermoza.workers.dev/assets/og-image.jpg`). No relative
  paths, `/index.html`, query strings, `www`, `http://` or invented domains in these tags.
- **MUST** keep `assets/og-image.jpg` a real JPEG 1200×630, at most 307 200 bytes, distinct
  from `assets/avatar.jpg`, and never rendered as an `<img>` of the page.
- **MUST** update `index.html` and the three `init.sh` constants together in one change if
  the origin changes; never mix origins.
- **MUST NOT** add HTTP calls or start a server from the gate to prove production; the gate
  stays local and static, and live verification is a separate `curl` step after the
  owner's manual redeploy.
- The platform is **Cloudflare Workers static assets**. The historical feature id
  `deploy-cloudflare-pages` does not authorize creating a Cloudflare Pages project or
  asserting one exists.
- **MUST** keep the redeploy and the unfurl as explicit human checks: a green gate does not
  prove the live deployment, and correct tags do not guarantee a social unfurl.
