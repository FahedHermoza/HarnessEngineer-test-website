# Validation Record: redesign-qr-panel

- Validator: `feature-validator` (independent run, 2026-11-23)
- Spec: `docs/specs/redesign-qr-panel.md`
- Feature status before this validation: `passing` (set by Session 070 implementer, extended by Session 071 orchestrator browser verification)
- Verdict: **accept (technical)** — independent `accepted` state still requires two external, non-delegable steps (see "Required Follow-Up").

## Scope Of This Validation

This is a genuinely independent re-run, not a re-statement of `PROGRESS.md`/`feature_list.json` evidence. Checks actually re-executed by this validator session:

- Read `AGENTS.md`, `PROGRESS.md` (Sessions 070/071), `feature_list.json` entry, `CONSTRAINTS.md`, `docs/specs/redesign-qr-panel.md`, `DESIGN.md` §§ "Vista QR y estados de interacción" / "Tipografía, assets y límites".
- `git diff` of every touched file (`index.html`, `styles.css`, `init.sh`, `CONSTRAINTS.md`, `docs/risks-and-open-questions.md`, `feature_list.json`, `PROGRESS.md`) plus `git diff -- DESIGN.md` (empty — confirmed untouched).
- `bash -n init.sh` and a fresh `./init.sh` run from scratch.
- 7 independent negative-case reproductions in disposable `mktemp -d` copies outside the repo (not copy-pasted from the implementer's list, re-derived from the spec's Scenario 8 / Verification Plan): CANONICAL_URL mismatch, `assets/qr.png` not a real PNG, `assets/qr.png` empty, `role="button"` on `.qr-panel__copy`, `href="#"` on `.qr-panel__save`, inline `onclick` on `.qr-panel__copy`, `.qr-panel__close` button removed, `<script>` inside `.save-contact`, QR quick action moved to first position, `outline` stripped from the dialog's `:focus-visible` block.
- Static inspection of the two bugs Session 071 claims to have fixed (title/close overlap; reduced-motion cascade order) by reading the actual `styles.css` rule order and the `padding-right` declaration, not by trusting the narrative.
- Served the site on `python3 -m http.server 3620 --directory .` (the isolated port named in the spec), `curl -sI` on `/`, `/styles.css`, `/scripts.js`, `/assets/qr.png`, `/assets/fahedhermoza.vcf` (all 200) and `/favicon.ico` (404, expected — the page never requests it because of `<link rel="icon" href="data:,">`); confirmed the server log has no unexpected 4xx/5xx; stopped the server and confirmed port 3620 is free again.
- Headless Chrome DOM dump sanity check (`--headless=new --dump-dom`) confirming the page renders and the `qr-panel` markup is present in the live DOM when served.
- Verified `scripts.js` end to end: only `addEventListener`, no inline handlers, no third-party `src`, `CANONICAL_URL` literal is byte-identical to `PRODUCTION_URL` in `init.sh`.
- Verified `assets/qr.png` magic bytes (`89 50 4e 47 0d 0a 1a 0a`) and that `file` reports real PNG image data (410×410, 1-bit, 590 bytes).
- Counted anchors (11), `<button>` elements (2), decorative `<svg>` (12) directly with `grep`, independent of the gate's own counters, and cross-checked against `CONSTRAINTS.md`'s declared breakdown (5+3+1+1+1 anchors, 12 SVG, 2 in-page buttons) — all match.
- Confirmed the `<script>`/Blob/`data:text/vcard` gate in `init.sh` is scoped to the `awk`-extracted `SAVE_CONTACT_BLOCK`, not the whole document (the spec's stated blocker was correctly fixed).
- Confirmed scope discipline via `git diff -- index.html` and `git diff -- styles.css`: the only changes are the third `.quick-action` anchor, the `<dialog class="qr-panel">` block, the `<script src="scripts.js" defer>` tag, and the new CSS rules/animation/reduced-motion additions. Header, Enlaces grandes, `.save-contact`, `<footer class="page-footer">`, metadata and the vCard are byte-for-byte untouched by this feature.

### Not re-executed (tool/environment limitation, stated honestly)

This validator session has no `chrome-devtools` MCP tool, and no Selenium/Playwright is installed in this environment (checked: not present). I could **not** independently reproduce the fully interactive browser protocol that Session 071 reports: real click/keyboard/Escape/backdrop dialog open-close with focus return, `navigator.clipboard` grant/deny behavior, computed-style reduced-motion assertion via `matchMedia` emulation, the eight-width interactive matrix, or a Lighthouse run. I verified the **code-level preconditions** for all of those claims (correct markup, correct JS logic, correct CSS cascade order) and did a basic headless-Chrome DOM sanity check, but I am reporting Session 071's interactive-browser narrative as *plausible and internally consistent with the code*, not as independently reproduced by this validator. This is a tooling gap in this validator session, not a finding against the implementation.

No QR decoder (`zbarimg`/`pyzbar`/`zxingcpp`/`cv2`) is installed in this environment either; I did not install one (would add a dependency to the verification environment for a single check and is explicitly deferred to the real-device scan by the spec itself). I independently confirmed `assets/qr.png` is a real, non-empty PNG and that `CANONICAL_URL` matches `PRODUCTION_URL` byte-for-byte, which is the strongest check possible without decoding pixels or a physical scanner.

## Findings

### Low — `docs/risks-and-open-questions.md` understates what Session 071 completed

- Evidence: the entry "Resuelto (técnicamente) — Vista QR (2026-11-22/23, `redesign-qr-panel`)" added by Session 070 still lists as pending item "(3) verificación real en navegador (consola/red, apertura/cierre, retorno de foco, Copiar, Lighthouse) — esta sesión no tuvo una herramienta de automatización de navegador disponible, solo `curl`/`init.sh`." Session 071's own entry in `PROGRESS.md` and in `feature_list.json`'s evidence array states this verification *was* performed with chrome-devtools MCP, including the two CSS bugs found and fixed as a direct result. Session 071's "Files or artifacts updated" list (`styles.css`, `feature_list.json`, `PROGRESS.md`) does not include `docs/risks-and-open-questions.md`, so that file was never revised to drop item (3) from the pending list.
- Why it matters: this is a durable-documentation/source-of-truth file; as written today it tells a future reader that browser verification is still an open risk, when in fact it is the two remaining items — (1) real-device QR scan and (2) owner's dated visual approval — that are genuinely open. This is an understatement (safer direction) rather than an overclaim, and does not affect runtime behavior, security or accessibility.
- Required change: edit `docs/risks-and-open-questions.md`'s QR-panel entry to remove/correct item (3), replacing it with a short note that real-browser verification was completed in Session 071 (chrome-devtools MCP) and that only the real-device scan and the owner's dated visual approval remain open.
- Verification after fix: re-read the entry and confirm it lists exactly two pending items, matching `feature_list.json`'s own "Estado honesto de aceptación" paragraph.

No Critical/High/Medium findings. No security-relevant findings (see below).

## Security Assessment (feature-scoped)

- New client-side JavaScript surface (`scripts.js`) is the first `<script>` in this repository — reviewed specifically for injection/XSS risk: it only calls `document.querySelector`, `addEventListener`, `dialog.showModal()/close()`, `navigator.clipboard.writeText()` with a hardcoded string constant, and `textContent` assignment (not `innerHTML`) for the status message. No use of `eval`, `innerHTML`, `document.write`, dynamic script injection, or user-controlled input anywhere in the script. No third-party script `src`, no CDN, no analytics/tracking added.
- `CANONICAL_URL` is a hardcoded literal, not derived from `location.href` or any URL parameter, so there is no open-redirect or URL-spoofing surface in the copy/QR flow.
- The relaxation of "every control must be a real `<a>`" is scoped exactly to two `<button type="button">` elements with no `href`-like injection vector, and `CONSTRAINTS.md`/`init.sh` both keep `role="button"`, `href="#"`/`href=""` and inline handlers explicitly prohibited everywhere else, including on these two buttons.
- `assets/qr.png` is a static, offline-generated, committed binary — no runtime QR generation, no client-side QR library, no dependency added to the page's attack surface.
- No new data collection, no new third-party requests, no change to the vCard mechanism or its gate scoping.
- Checklist result: no relevant issues found; no blocking findings.

## Documentation / Harness State Assessment

- `CONSTRAINTS.md`: updated coherently and verified against the live HTML/CSS/`init.sh` counts (11 anchors = 5+3+1+1+1, 12 decorative SVG, exactly 2 non-anchor in-page buttons, JS exception scoped and worded to not weaken the vCard's `<script>`/Blob prohibition). MUST/MUST NOT phrasing stays operational, not vague.
- `init.sh`: all new gates (`QR quick action`, `QR panel dialog`, `QR asset`, `QR panel script`, extended focus/reduced-motion/tap checks) are additive and none of the pre-existing checks were weakened, reordered or removed; confirmed by a clean full run (135 `[ok]`, 0 `FAILED`, exit 0, no server started) plus 7 independently reproduced negative cases, each failing with the specific, correct `FAILED - ...` message and leaving no listener on 3620/3601.
- `DESIGN.md`: confirmed untouched (`git diff -- DESIGN.md` is empty) and already sanctions the QR view's structure/behavior exactly as implemented; no rewrite-to-match-code pattern detected.
- `feature_list.json`: evidence is detailed, internally consistent between the two sessions, and honestly scoped — it explicitly keeps `status: passing` (not `accepted`) and lists the real-device scan and the owner's visual approval as the only two pending items, with no invented evidence for either.
- `PROGRESS.md`: Session 070 and 071 entries are consistent with each other and with the current code; the only drift found is the stale item (3) in `docs/risks-and-open-questions.md` noted above (Low, non-blocking).
- `docs/risks-and-open-questions.md`: one Low finding above; otherwise consistent.

## Required Follow-Up

This feature cannot move to `accepted` purely by further agent work. Two steps require a human with physical access, and neither can be substituted by any automated session, including this one:

1. **Real-device QR scan**: scan the displayed QR and open the downloaded `assets/qr.png` on an actual phone, and confirm both resolve to exactly `https://fahed-hermoza-card.fahedhermoza.workers.dev/` (trailing slash, no `www`, no `http://`, no query string). No QR decoder is installed in this (or the implementer's) environment, and none should be added just to avoid this manual step.
2. **Owner's dated visual review** of the QR panel in both mobile and desktop viewports, following the same protocol already used for `redesign-card-profile` and `redesign-footer-contact` in this repo (explicit dated response recorded, with or without screenshots).

Until both are recorded, `redesign-qr-panel` should remain `status: passing`, not `accepted`, even though the technical implementation, the harness gate, and the (code-level-verified) interactive behavior are correct.

## Owner Final Acceptance (2026-11-23)

Both external conditions above are now closed:

1. **Real-device QR scan**: Fahed Hermoza confirmed in chat that scanning the displayed QR
   and/or the downloaded `assets/qr.png` on a real phone resolves to exactly
   `https://fahed-hermoza-card.fahedhermoza.workers.dev/` (canonical URL, no `www`,
   no `http://`, no query string).
2. **Owner's dated visual review**: Fahed Hermoza reviewed fresh renders of the live page
   (isolated server, port 3620) in both required viewports, both panel-closed and
   panel-open states, and approved the feature as a whole in chat. Screenshots captured via
   Chrome DevTools MCP (`take_screenshot`, `fullPage: true`) and committed as durable
   evidence:
   - `docs/validations/redesign-qr-panel-owner-approval-mobile-closed.png` — 390×844.
   - `docs/validations/redesign-qr-panel-owner-approval-mobile-open.png` — 390×844, QR dialog open.
   - `docs/validations/redesign-qr-panel-owner-approval-desktop-closed.png` — 1280×800.
   - `docs/validations/redesign-qr-panel-owner-approval-desktop-open.png` — 1280×800, QR dialog open.

With both conditions closed, the feature moves from `passing` to `accepted`.

## Repair Brief (Low, optional before next session)

1. Edit `docs/risks-and-open-questions.md`'s "Resuelto (técnicamente) — Vista QR" entry: remove item (3) from the pending list (browser verification is done per Session 071) and replace with a one-line note that only the real-device scan and the owner's dated visual approval remain. No code change required; no re-run of `./init.sh` needed (text-only doc edit).
