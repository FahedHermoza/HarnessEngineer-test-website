# Validation Record: accessibility-baseline

- Feature id: `accessibility-baseline`
- Spec: `docs/specs/accessibility-baseline.md`
- Validator: `feature-validator` (independent validator, not the implementer)
- Date: 2026-10-23
- Verdict: **accept**
- Recommended state update: the orchestrator may set `accessibility-baseline` from `passing` to `accepted` and append concise acceptance evidence.

## Review Target

- Claimed status before validation: `passing` (not `accepted`); both dependencies (`page-shell`, `link-button-component`) are `accepted`.
- Product diff reviewed:
  - `styles.css`: exactly six token values changed (`--color-gradient-1..5` and `--color-on-surface-variant`); no other rule changed.
  - `index.html`: exactly one attribute added (`lang="en"` on the existing Tagline); no structural or content change.
- Harness/docs reviewed: `init.sh`, `DESIGN.md`, new `CONSTRAINTS.md`, `AGENTS.md`, `docs/technical-discovery.md`, `docs/risks-and-open-questions.md`, `feature_list.json`, `PROGRESS.md`, and the planner spec.
- The validator modified no product code, committed nothing, left `feature_list.json` at `passing`, and created only this validation record.

## Checks Ran And Observed Results

### Scope and static audit

- `styles.css` diff: `6` insertions / `6` deletions; values are exactly `#5a67d1`, `#645fcc`, `#705aca`, `#8055c8`, `#9252c5` and `#6b7280`.
- `index.html` diff: `1` insertion / `1` deletion, only `lang="en"` on `<p class="profile-identity__tagline">`.
- `:root` still contains 51 custom properties; the property-like names outside `:root` are the pre-existing internal `.link-button` variables/assignments.
- `0` `<script>` elements; no product JS, framework, bundler, lockfile, dependency, new asset, or new external destination. The temporary five-button demo is preserved.
- All prior `init.sh` checks remain present; the diff deletes only the three old 3301 serving lines and adds the accessibility section plus 3413 serving lines.
- `git diff --check` -> clean.
- Independent contrast calculation in Python reproduced all 13 values: rest `4.889/5.184/5.244/5.184/4.958`, hover/focus `4.658/4.936/4.993/4.920/4.743`, Tagline/Handle `4.834`, footer links `5.151`, body text `13.044`.
- DOM parse: 14 anchors (12 `.link-button` + 2 `.page-footer__link`), 12 SVGs all with `aria-hidden="true"` and `focusable="false"`, one `h1`, `<html lang="es">`, Tagline `lang="en"`, avatar `alt="Retrato de Fahed Hermoza"`.

### Harness gate

- `bash -n init.sh` -> exit `0`.
- `./init.sh` -> exit `0`; all prior checks `[ok]`, the three expected metadata `[warn]`s, and:
  - `[ok] accessible document language and zoomable viewport`
  - `[ok] tagline language of parts (lang="en")`
  - `[ok] avatar alt is descriptive and non-empty`
  - `[ok] 14 real anchor controls (12 link buttons + 2 footer links)`
  - `[ok] decorative icons and footer separator are hidden from assistive technology`
  - `[ok] visible focus contract`
  - `[ok] reduced motion contract`
  - `[ok] accessibility contrast token values (6/6)`
  - `[ok] accessibility contrast contract (13/13)`
  - `[ok] link button contrast wiring`
- The run was repeated after stopping the browser server; port 3413 remained free afterwards. The script executes checks, fails non-zero, and does not start a server by default.

### Independent negative cases

Nine temporary copies (repo untouched; copies deleted) each exited `1`, printed the expected stderr, and left 3413 without a listener:

1. `--color-gradient-1` reverted -> `FAILED - styles.css token --color-gradient-1 must be #5a67d1 (found #6876f0)` + `Harness status: FAILED - accessibility contrast tokens are missing 1 of 6 required values`.
2. `--color-on-surface-variant` reverted -> `FAILED - ... must be #6b7280 (found #717886)` + the same token failure.
3. One SVG lost `aria-hidden` -> `FAILED - SVG is missing aria-hidden="true"` + `Harness status: FAILED - accessibility SVG contract is missing 1 required attributes`.
4. Avatar `alt=""` -> `Harness status: FAILED - index.html is missing the profile avatar markup (...)`.
5. `.link-button:focus-visible` lost `outline` -> `Harness status: FAILED - styles.css .link-button:focus-visible must declare outline: 2px solid var(--color-accent); and outline-offset: 2px;`.
6. Reduced-motion block lost `transition: none;` -> `Harness status: FAILED - styles.css reduced-motion block must set transition: none; and transform: none; for .link-button`.
7. First anchor changed from `href` to `data-href` -> `FAILED - anchor without a non-empty href: ...` + `Harness status: FAILED - accessibility control contract is missing 1 of 14 anchors`.
8. Viewport changed to `user-scalable=no` -> `Harness status: FAILED - index.html must not disable zoom (user-scalable=no or maximum-scale)`.
9. Fake `<div class="link-button">` added -> `Harness status: FAILED - a non-anchor element uses class link-button (or an anchor duplicates the class)`.

### Browser: 390x844 mobile

Single server `python3 -m http.server 3413 --directory .` inside the worktree; mobile/touch emulation at 390x844, DPR 3; fresh cache-bypassing navigation; server stopped afterwards.

- Network: 5/5 `200` (`/`, Google Fonts CSS, `styles.css`, `assets/avatar.jpg`, WOFF2). No `/favicon.ico`, no 4xx/5xx page request.
- Console: **0 messages**.
- Layout: `innerWidth=390`, `scrollWidth=clientWidth=390` for document and body; card `358x1177` at `x=16`; no horizontal overflow.
- Semantics: one `h1`; 14 anchors; 12 decorative SVGs; avatar `complete=true`, natural size `460x460`, non-empty descriptive alt.
- Keyboard: real `Tab` from the document produced all 14 controls in DOM order: Instagram, Facebook, WhatsApp, Portafolio, LinkedIn, Correo, Celular, Enlace uno..cinco, footer email, footer handle. Real `Shift+Tab` traversed the exact reverse order. Every entry had `:focus-visible=true`, `outline: rgb(88, 92, 229) solid 2px`, and `outline-offset: 2px`.
- Activation: `Enter` on the first demo anchor navigated only to `http://localhost:3413/#link-button-demo`; no external destination and no new console messages/network failures.
- Reduced motion: `matchMedia(...).matches=true`; `.link-button` computed `transition-property:none`, `transition-duration:0s`, `transform:none`; focus outline remained visible; `0` animated/transitioning elements remained.
- Computed contrast: buttons `4.889`..`5.244`; Tagline/Handle `4.834`; Name/footer text `13.044`; footer links `5.151`.

### Browser: 1280x800 desktop

Fresh cache-bypassing navigation on the same server before it was stopped.

- Network: 5/5 `200`; no `/favicon.ico`; console **0 messages**.
- Layout: `innerWidth=1280`, `clientWidth=scrollWidth=1265` because of the classic vertical scrollbar; card `400x1177` centered at `x=432.5`; no horizontal overflow.
- Keyboard: real `Tab` produced the same 14 controls in DOM order with `:focus-visible=true`, outline `rgb(88, 92, 229) solid 2px`, offset `2px`. Real `Shift+Tab` produced the reverse order (an additional 15th press wrapped back to the final control).
- Hover on Enlace cinco: `transform:matrix(1, 0, 0, 1, 0, -1.5)`, hover shadow, `filter:brightness(1.03)`, `transition-duration:0.18s`; computed hover contrast `4.743`.
- Reduced motion: hover and focus had `transition-property:none`/`transition-duration:0s`, `transform:none`, visible focus outline, and `0` animated elements.

### Lighthouse mobile accessibility

- `chrome-devtools_lighthouse_audit`, `device: mobile`, `mode: navigation`, `http://localhost:3413/`.
- **Accessibility: 100**; Best Practices: 100; Agentic Browsing: 100; SEO: 91.
- 45 audits passed; 0 accessibility failures. No `critical`/`serious` accessibility finding. The only failed audit is SEO `meta-description`, explicitly outside this feature's scope.
- Reports: `/var/folders/nn/pfw3yqwx4wsdch14n5z5wpkh0000gn/T/opencode/ab-validator-lighthouse/report.json` and `report.html` (temporary, not committed).
- The server log contains `404`s only for Lighthouse's own `/robots.txt`, `/llms.txt`, and `/.well-known/ai-catalog.json` probes; page resources were `200` and `/favicon.ico` was never requested.

## Findings

### Blocking findings

- None.

### Notes (non-blocking)

- **Low - textual harness:** the HTML checks use `grep`/`awk` over source text and assume the repository's current one-line attribute style. They are backed by runtime DOM checks in this validation (14 anchors, 12 hidden SVGs, unique H1, `lang`, alt, and focus behavior), so this is not a correctness gap for the current feature.
- **Low - intentional current-count coupling:** the gate hardcodes 14 anchors / 12 link buttons / 5 demo anchors. This is correct for the current accepted page and spec, but `links-order-gradient` and `save-contact-vcard` will need to update those counts deliberately rather than weaken the gate.
- **Low - inline footer targets:** the two footer links are 16px tall. They are inline controls within a text sentence, covered by the WCAG 2.5.8 exception already documented in `CONSTRAINTS.md` and `docs/risks-and-open-questions.md`; no new action for this feature.
- **Low - Lighthouse probes:** Lighthouse's own auxiliary requests (`/robots.txt`, `/llms.txt`, `/.well-known/ai-catalog.json`) produced 404s in the Python access log. They are not page network requests and did not affect the 5/5 `200` page load, console, or accessibility score.

## Security Assessment

Feature-scoped security review found no relevant issues:

- No secrets, credentials, authentication, permissions, user input, persistence, uploads, or server-side code in the diff.
- No JavaScript, new dependency, new external call, redirect, or user-controlled sink.
- Existing fixed external destinations and the Google Fonts request are unchanged; no `target="_blank"`/reverse-tabnabbing surface was introduced.
- The new shell checks operate on repository files only; no untrusted external input is executed.

## Documentation And Handoff

- `feature_list.json`: `accessibility-baseline` is `passing` with seven evidence entries that match the independently reproduced behavior; no other status changed.
- `PROGRESS.md`: current state and Session 040 accurately record implementation, verification, the remaining OG blocker, and the next step.
- `CONSTRAINTS.md` exists and states operational MUST/MUST NOT accessibility rules.
- `DESIGN.md` reflects the six new tokens and the AA decision; `AGENTS.md` routes to `CONSTRAINTS.md` and adds the AA rule/DoD; `docs/technical-discovery.md` documents the gate, 3413 and Lighthouse/no-E2E; `docs/risks-and-open-questions.md` closes both inherited contrast risks and records the inline-target exception.
- `ARCHITECTURE.md` was correctly not created: no architecture/runtime boundary changed.
- No persistent E2E harness exists, and the spec explicitly justifies `init.sh` + Chrome DevTools + Lighthouse instead of adding forbidden dependencies.
- The repository is restartable: `./init.sh` exits 0 after the browser server is stopped, and port 3413 is free.

## Verdict Rationale

All acceptance scenarios were reproduced independently: the two token groups now meet AA in rest and hover/focus; Tagline/Handle and footer colors pass; 14 real anchors keep visible focus in both orders on mobile and were traversed on desktop; language-of-parts, alt text, decorative SVGs and reduced motion are correct; the eight required regression cases (plus a fake-control variant) fail the gate with exit 1 and no server; browser console/network are clean for page resources; and Lighthouse mobile accessibility is 100 with no critical/serious failures. Scope is exactly the six product tokens, the Tagline `lang`, the accessibility gate, and the documented durable docs. **Accept.**
