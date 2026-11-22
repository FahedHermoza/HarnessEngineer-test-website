# Validation: redesign-footer-contact (post-passing adjustment, 2026-11-22)

- Date: 2026-11-22
- Validator: independent `feature-validator` execution
- Spec: `docs/specs/redesign-footer-contact.md` (§ "Alcance de este ajuste (post-passing, 2026-11-22)")
- Worktree: `feature/redesign-footer-contact` (isolated port 3610)
- Input status: `passing` (base footer slice already independently validated in a
  prior round; this round validates only the 3 owner-approved adjustments)
- Verdict: **accept** (technical, scoped to the 3 adjustments). The sole remaining
  gate is the spec's external condition — the owner's dated final visual approval
  (mobile + desktop) for the feature as a whole — which is NOT a technical defect
  and is collected separately by the orchestrator.
- Recommended status: keep `passing` until the owner's full visual approval is
  recorded, then `accepted`. No product change required before acceptance of this
  adjustment.

## Scope Of This Round

This note supersedes the prior validation entry in this same file (which described
the footer *before* the 2026-11-22 adjustment: underlined link, `·` separator
present, 10 decorative SVGs). That prior entry is now stale and has been replaced
here. Nothing about the base footer slice (WhatsApp invitation text, Guardar
contacto contract, vCard, anchor count) was reopened; only the 3 adjustments fixed
in `DESIGN.md` lines 522-537 were validated.

## Verdict Basis

1. **Bold, no-underline link.** `styles.css` `.page-footer__link` now reads
   `text-decoration: none;` + `font-weight: var(--text-button-label-font-weight);`
   (reuses the existing `800` Enlace-label token, no new token), keeping
   `color: var(--color-accent);` and an untouched `.page-footer__link:focus-visible`
   (`outline: 2px solid var(--color-accent); outline-offset: 2px;`). Confirmed no
   other CSS rule targets `.page-footer__link` (`grep -n "page-footer__link"
   styles.css` → exactly 2 rules, accent + focus-visible), so there is no cascade
   override. Confirmed visually via a fresh headless-Chrome screenshot at both
   390×1400 and 1280×1100: the link renders bold and without underline in both
   viewports.
2. **"Tarjeta NFC & QR" in its own block, separator fully removed.** `index.html`
   now has two sibling `<p>` elements inside `<footer class="page-footer">`: the
   invitation paragraph (ending at "...escríbeme directamente</a>") and a new
   `<p class="page-footer__nfc">` below it containing the new `<svg>` + the text
   "Tarjeta NFC &amp; QR". `grep -rn "page-footer__separator" index.html styles.css`
   returns **no matches** — the element and its CSS rule are both gone, not merely
   hidden. `--dump-dom` against the live served page reproduces this exact
   structure with no separator anywhere in the document.
3. **New decorative SVG.** The new `<svg class="page-footer__nfc-icon"
   viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor"
   stroke-width="2" stroke-linecap="round" stroke-linejoin="round"
   aria-hidden="true" focusable="false">` sits to the left of the text, with a
   simple card/chip-outline geometry (`<rect x="2" y="5" width="20" height="14"
   rx="2"/><rect x="6" y="9" width="6" height="6" rx="1"/>`). Its attribute
   signature (`viewBox`, `fill="none"`, `stroke="currentColor"`, `stroke-width="2"`,
   `stroke-linecap/linejoin="round"`, `aria-hidden="true"`, `focusable="false"`,
   18×18) is identical to every other decorative icon already accepted in the
   document (NFC label, external-link, quick-action, link-button, save-contact
   icons) — confirmed with `grep -n "<svg" index.html`. No icon library, no new
   file under `assets/`, no new color token.

`DESIGN.md` was independently confirmed untouched by the implementer:
`git diff -- DESIGN.md` shows exactly 17 insertions, 0 deletions — the single
addendum block "### Pie — decisión de diseño aprobada (`redesign-footer-contact`,
2026-11-22)" (the same block already present in the working tree before this
implementation session, per the task's own starting `git status`). No other line
of `DESIGN.md` changed, and the file stays internally consistent (no stale
ramp/layout description left contradicting the implemented behavior).

Scope discipline confirmed: `git diff --numstat -- index.html` → 8 insertions /
3 deletions (the footer hunk only); Guardar contacto, Acciones rápidas, the five
Enlaces, the ornamental header, `assets/fahedhermoza.vcf` and Open Graph metadata
are byte-identical (confirmed via `git diff --stat` showing no changes to
`assets/`, and via the unchanged `init.sh` gates for those sections all still
printing `[ok]`).

## Checks Rerun (reproduced independently)

### Gate — `bash -n init.sh && ./init.sh`
- `bash -n init.sh` → exit 0 (no syntax errors).
- `./init.sh` → exit 0, `Harness status: bootstrapped`, no server started. Key
  lines reproduced, confirming both the unchanged invariants and the two counts
  this adjustment changes:
  - `[ok] page footer destinations (WhatsApp invitation + "Tarjeta NFC & QR" closing, no mailto/Instagram/separator)`
  - `[ok] page footer contract (5/5)`, `[ok] page footer link accent`, `[ok] page footer focus-visible`
  - `[ok] 9 real anchor controls (5 link buttons + 2 quick actions + 1 save contact button + 1 footer link)` — **unchanged**, as required.
  - `[ok] 11 decorative SVG icons are hidden from assistive technology` — **10 → 11**, as required, with no leftover separator-specific check (verified the old coupled `if` block checking `.page-footer__separator` was fully removed from `init.sh`, not just its message).
  - `[ok] accessibility contrast contract (15/15)`, `[ok] accessibility contrast token values (8/8)` — unchanged.
  - `[ok] save contact markup, label, icon and static href/download`, `[ok] vCard asset contract (UTF-8, CRLF, VCARD 3.0, canonical fields, 390 bytes)` — unchanged.

### Independent negative mutations (temp copies outside the repo, deleted after; no listener left on 3601/3610)
| # | Mutation | Result |
|---|----------|--------|
| N1 | Reintroduce `text-decoration: underline;` on `.page-footer__link`, drop `font-weight` | exit 1 — `.page-footer__link base rule missing declaration: text-decoration: none;` + `... font-weight: var(--text-button-label-font-weight);` |
| N2 | Reinsert `<span class="page-footer__separator" aria-hidden="true">·</span>` back into the `<footer>` | exit 1 — `index.html footer must not contain the retired .page-footer__separator element` |
| N3 | Strip `aria-hidden="true"` from the new `.page-footer__nfc-icon` `<svg>` | exit 1 — `SVG is missing aria-hidden="true": ...` + `accessibility SVG contract is missing 1 required attributes` |

All three fail with exit 1, a concrete stderr message, and no server listener on
either port before/after.

### Browser (headless Chrome, served via `python3 -m http.server 3610 --directory .`, stopped after; no Chrome DevTools MCP tool was available in this validator session, same limitation the implementer already disclosed)
- Fresh screenshots at 390×1400 and 1280×1100 visually confirm: "escríbeme
  directamente" renders bold and without underline in the accent color; "Tarjeta
  NFC & QR" sits on its own line below the invitation paragraph with the new
  card/chip icon immediately to its left; no `·` glyph appears anywhere in the
  footer, in either viewport.
- `--dump-dom` on the live served document reproduces the exact expected markup
  (two sibling `<p>` elements, no `page-footer__separator` anywhere in the
  document).
- Server access log during this session shows only `200` responses for `/`,
  `/styles.css`, `/assets/avatar.jpg`; no `404`, no `/favicon.ico`.
- **Not independently rerun in this session** (no CDP/browser-automation tool
  available, consistent with the implementer's disclosed gap): `getComputedStyle`
  / `scrollWidth` runtime assertions across the eight-width matrix, console-error
  enumeration via DevTools, and a fresh mobile Lighthouse accessibility run. These
  were already run and recorded by the implementer's prior session (Session 067)
  for the base footer and are structurally unaffected by this adjustment (no new
  fixed-width element, no new script, same card width/padding); the CSS-cascade
  check above (no other rule overrides `.page-footer__link`) and the gate's own
  computed-value-independent contract checks cover the residual risk. If a Chrome
  DevTools MCP tool becomes available, repeating the eight-width
  `scrollWidth===clientWidth` check and a fresh Lighthouse run is recommended
  before publishing, but is not required to accept this adjustment.

## Scope / Security / Docs
- Scope: only the footer interior changed in `index.html`/`styles.css`/`init.sh`.
  Header, Acciones rápidas, the five Enlaces, Guardar contacto, `<head>`/metadata
  and `assets/fahedhermoza.vcf` are byte-unchanged. No new tokens, colors, fonts,
  frameworks, JS, dependencies, or assets under `assets/`.
- Security: static site, no new network surface, no scripts, no Blob/`data:`
  URIs. No issue found specific to this adjustment.
- Docs: `CONSTRAINTS.md` updated to "exactly 11 decorative SVG icons" and the
  footer-separator mention fully removed (not just reworded); the 9-anchor
  breakdown and the WCAG 2.5.8 note are unchanged, as required.
  `docs/risks-and-open-questions.md` gained a new "Resuelto — Ajuste post-passing
  del pie" entry describing the 3 changes without altering the prior entries.
  `DESIGN.md` confirmed untouched beyond the pre-existing addendum (see above).
  `AGENTS.md`/`ARCHITECTURE.md` correctly untouched.

## Remaining External Condition (not a defect)
Owner's full visual approval (mobile + desktop) for the feature as a whole is
still `pending` per `feature_list.json`/`PROGRESS.md`, and must be collected by
the orchestrator before status flips to `accepted`. The structural approval for
these 3 specific adjustments was already given via the `DESIGN.md` addendum and
is satisfied by this validation.
