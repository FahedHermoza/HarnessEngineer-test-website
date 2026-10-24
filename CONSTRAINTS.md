# Constraints

## Accessibility Baseline (AA)

These rules are durable: every future change to the Tarjeta digital must preserve them.
`./init.sh` enforces the technically checkable subset; do not remove, weaken or reorder
its `Accessibility checks:`.

- **MUST** keep every control a real `<a>` with a non-empty `href`: exactly 10 anchors
  today (7 `.link-button` + 1 `.save-contact-button` + 2 `.page-footer__link`).
- **MUST NOT** use `role="button"`, inline `onclick`/`onkeydown`/`onkeypress`,
  `href="#"` or `href=""` for controls.
- **MUST** keep a visible keyboard focus on every control:
  `outline: 2px solid var(--color-accent);` and `outline-offset: 2px;` on
  `.link-button:focus-visible`, `.save-contact-button:focus-visible` and
  `.page-footer__link:focus-visible`.
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
  6.456:1 with `brightness(1.03)`).
- **MUST** keep every decorative `<svg>` with both `aria-hidden="true"` and
  `focusable="false"`: exactly 8 decorative SVG icons today (7 Enlaces + the save
  contact icon), and the footer separator with `aria-hidden="true"`.
- **MUST** keep the Contacto vCard as the static `assets/fahedhermoza.vcf`: UTF-8
  without BOM, CRLF line endings (including the final `END:VCARD`), VCARD 3.0 with the
  canonical name, title, phone, email and five external URLs, at most 4096 bytes.
  The save contact control MUST stay a real anchor with
  `href="assets/fahedhermoza.vcf"` and `download="fahedhermoza.vcf"`; do not replace it
  with `data:text/vcard`, Blob, a `<script>` or an inline handler.
- **MUST** keep the avatar `alt` descriptive and non-empty.
- **MUST** keep `<html lang="es">` and mark the English Tagline with `lang="en"`
  (WCAG 3.1.2, Language of Parts).
- **MUST** keep the viewport zoomable: no `user-scalable=no` and no `maximum-scale`.
- **MUST** keep `@media (prefers-reduced-motion: reduce)` disabling `transition` and
  `transform` for `.link-button` and `.save-contact-button`; do not add other animations.
- **MUST NOT** add JavaScript, frameworks, bundlers, dependencies or generated assets
  to satisfy accessibility rules (see `docs/technical-discovery.md`).

The two inline footer links are shorter than 44px; they stay covered by the WCAG 2.5.8
inline/link-in-text exception. Re-evaluate that exception if the footer layout changes.

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
- The two inline footer links stay under the WCAG 2.5.8 inline/link-in-text exception; do not
  evaluate them against the 44×44 target unless the footer layout changes.

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
