# Validation: redesign-contact-navigation

- Date: 2026-11-21
- Validator: independent `feature-validator` execution
- Spec: `docs/specs/redesign-contact-navigation.md`
- Worktree: `feature/redesign-contact-navigation`
- Input status: `passing`
- Verdict: `accept` (technical). The sole remaining gate is the spec's external
  condition — the owner's dated visual approval (mobile + desktop) — which the
  orchestrator collects separately and which is NOT a technical defect.
- Recommended status: keep `passing` until the owner's visual approval is recorded,
  then `accepted`. No product change is required.

## Resolution (2026-11-21)

The external acceptance condition was resolved: the github-flow orchestrator served the
worktree on port 3602, captured the new navigation at 390x844 and 1280x800 (0 console
messages at both), and the owner (Fahed Hermoza) reviewed those captures and responded
"Apruebo, publicar" for both mobile and desktop. With the technical `accept` above, the
feature moves `passing` → `accepted`.

## Verdict Basis

The implementation satisfies the spec. The `.links` section is exactly five large
gradient buttons in the accepted order and tone ramp, a new neutral icon-only
"Acciones rápidas" row hosts Celular and Correo with their canonical destinations
and accessible labels, all seven canonical destinations and the static vCard are
intact, the ornamental header / save-contact / current footer are unchanged, and
`init.sh` + `CONSTRAINTS.md` were adapted explicitly to 5 + 2 without weakening any
AA / focus / reduced-motion / contrast / tap-target check. No defect, AA regression,
responsive regression, scope creep, or security issue was found.

## Checks Rerun (reproduced evidence)

### Gate — `bash -n init.sh && ./init.sh`
- `bash -n init.sh` → exit 0 (no syntax errors).
- `./init.sh` → exit 0. `Harness status: bootstrapped`. `Accessibility checks:` and
  `Responsive checks:` sections both present. No server started (only prints the
  opt-in `Serving command:` hint on 3601). Key lines reproduced:
  - `[ok] links order (5/5)`, `[ok] links tone progression (5/5)`,
    `[ok] interpolated tone rules (2/2)`, `[ok] link button demo removed (HTML and CSS)`
  - `[ok] celular quick action markup/destination/accessible label/decorative icon`
  - `[ok] Correo quick action contract (6/6)`
  - `[ok] 10 real anchor controls (5 link buttons + 2 quick actions + 1 save contact button + 2 footer links)`
  - `[ok] 10 decorative SVG icons and footer separator are hidden from assistive technology`
  - `[ok] visible focus contract`, `[ok] reduced motion contract`
  - `[ok] accessibility contrast contract (15/15)` (all rest + hover ratios >= 4.5:1;
    quick-action neutral pair 6.082:1 rest / 6.456:1 hover)
  - `[ok] quick action tap target >=44x44 (circular icon-only control)`
  - `[ok] vCard asset contract (... 390 bytes)`, `[ok] vCard URLs, phone and email match the page controls`,
    `[ok] save contact sits between the links navigation and the page footer`

### Negative mutations (temp copy outside the repo, no listener) — all exit 1 with specific stderr
| # | Mutation | Result |
|---|----------|--------|
| M1 | Remove Celular quick-action | exit 1 — "missing the Celular quick action (... href=tel:+51955116562) inside the quick-actions row" |
| M2 | Reorder/alter large-button tone (swap gradient-1/-2) | exit 1 — "the Instagram Enlace must use class=... link-button--gradient-1" |
| M3 | Alter `tel:` destination | exit 1 — Celular quick-action destination check |
| M4 | Alter `mailto:` destination | exit 1 — "Correo quick action anchor missing: class=quick-action" |
| M5 | Drop Correo `aria-label` | exit 1 — "Correo quick action anchor missing: aria-label=..." |
| M6 | Add a third quick-action control | exit 1 — "must contain exactly 10 anchor controls (found 11)" |
| M7 | Remove quick-action `:focus-visible` outline | exit 1 — ".quick-action:focus-visible must declare outline: 2px solid var(--color-accent); and outline-offset: 2px;" |
| M8 | Shrink quick-action to 40px | exit 1 — ".quick-action must declare width and height of at least 44px" |

No mutation started a server.

### Browser (headless Chrome 158 via CDP, served on port 3602)
- Network: `/`, `/styles.css`, `/assets/fahedhermoza.vcf`, `/assets/avatar.jpg` → 200.
- Responsive matrix (320, 360, 375, 390, 480, 736, 768, 1280; mobile 844 / desktop 800):
  at every width — `scrollWidth === clientWidth` (overflow 0), single `<h1>`, 10 real
  anchors, 10 decorative SVGs, quick-actions row before `.links`, five large buttons in
  order `Instagram, Facebook, WhatsApp, LinkedIn, Portafolio` with gradients
  `1, 2, 3, 3-4, 4`, two quick-actions `tel:+51955116562` / `mailto:fahedhermoza@gmail.com`
  with correct `aria-label`s, min tap target 48px (>= 44) on every large button and
  quick-action. 0 console messages, 0 failed requests, 0 `/favicon.ico` requests at all
  widths (verified explicitly at 390x844 and 1280x800).
- Avatar fallback: dispatching `error` on `.profile-avatar` adds
  `profile-avatar-frame--fallback` and the `FH` monogram renders. Intact.

### Lighthouse (mobile, accessibility)
- `lighthouse@11 http://localhost:3602/ --only-categories=accessibility --form-factor=mobile`
  → Accessibility = 100, zero failing audits (no critical/serious). fetchTime 2026-11-22.

## Scope / Security / Docs
- Scope: no QR panel, no Compartir/share control, no inert placeholder, no `role="button"`,
  no inline handlers, no `href="#"`. Header, `.save-contact`, and the current footer are
  byte-unchanged vs `origin/demo/seed`. vCard `assets/fahedhermoza.vcf` unchanged (390 bytes,
  phone + email + five URLs). No new tokens/colors/fonts/frameworks/JS/dependencies.
- Security: static site, no new network surface, no scripts, no user input. The two new
  anchors use canonical `tel:`/`mailto:` schemes. No issue found.
- Docs: `CONSTRAINTS.md` re-expressed as 5 `.link-button` + 2 `.quick-action` + 1
  `.save-contact-button` + 2 `.page-footer__link` (10 anchors, 10 decorative SVGs) and adds
  the quick-action `:focus-visible`, reduced-motion and >=44x44 MUSTs without weakening any
  rule. `DESIGN.md` documents the row, the neutral tone decision, and the five large buttons,
  and differentiates QR/Compartir/footer as later slices. `AGENTS.md` / `ARCHITECTURE.md`
  correctly untouched.

## Remaining External Condition (not a defect)
Owner visual approval (mobile + desktop) is still `pending` and must be collected by the
orchestrator before status flips to `accepted`, per the spec. Absence of that approval is an
acceptance gate, not a technical finding. Real-device dial/mail launch was emulated in
headless Chrome only (schemes verified), not on a physical device; the spec permits this when
declared honestly.
