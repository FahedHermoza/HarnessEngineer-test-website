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
