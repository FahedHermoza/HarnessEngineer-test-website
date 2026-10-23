# Validation Record: link-instagram

- Feature id: `link-instagram`
- Spec: `docs/specs/link-instagram.md`
- Validator: `feature-validator` (independent validator, not the implementer)
- Date: 2026-10-23
- Rounds: 1
- Verdict: **accept**
- Recommended state update: orchestrator may set `link-instagram` from `passing` to `accepted` and append concise acceptance evidence.

## Review Target

- Claimed status before this validation: `passing`.
- Implementation diff reviewed against `HEAD` (`96dd53b`): `index.html` (+12 lines, no deletions), `styles.css` (+5 lines, no deletions), `init.sh` (+125/-3, only the serving-command/port lines removed), `feature_list.json`, `PROGRESS.md`; planner spec `docs/specs/link-instagram.md` (untracked).
- Scope of this run: full independent validation of the feature, not a re-validation.
- Repository was not modified by the validator. The validation server (own process, port 3301) and all temporary copies outside the repo were stopped/deleted.

## Checks Ran And Observed Results

### Harness gate

- `bash -n init.sh` -> syntax OK, exit `0`.
- `./init.sh` -> exit `0`, no server started and no listener on 3301 before/after:
  - `Harness status: bootstrapped (static site detected)`
  - All previous sections `[ok]`: bootstrap 3/3, tokens 51/51, component 6/6 + reduced motion, page shell 3/3, avatar 5/5, footer 5/5, identity (2/2, 5/5, 5/5, 4/4, no letter-spacing), sharing metadata 14/14 (+3 expected `[warn]`).
  - `Instagram link checks:` `[ok]` for: links navigation block, links navigation label, base tone (no gradient modifier), exactly one `class="link-button"` in the nav, exact Instagram destination, `>Instagram<` label, icon contract 6/6, `.links` layout rule, demo preserved, demo labels 5/5.
  - Printed serving command and `RUN_SERVE_COMMAND` target are 3301; manual hint lists 390×844 and 1280×800.
- Gate still executes checks (does not merely print commands) and does not start a long-running server by default.

### Independent negative cases (12, temp copies outside the repo, all deleted)

Each copy contained `index.html`, `styles.css`, `init.sh` and `assets/avatar.jpg`; every mutation exited `1`, wrote the specific failure to stderr, and left no listener on 3301.

| Mutation | Observed stderr |
| --- | --- |
| `<nav class="links">…</nav>` removed (footer Instagram link kept) | `Harness status: FAILED - index.html is missing the links navigation block (<nav class="links">)` |
| Real `href` changed | `Harness status: FAILED - index.html is missing the Instagram Enlace destination https://www.instagram.com/fahedhermoza/` |
| Visible label changed to `Insta` | `Harness status: FAILED - index.html is missing the Instagram Enlace label >Instagram<` |
| `aria-hidden="true"` removed from icon | `FAILED - Instagram Enlace icon missing attribute: aria-hidden="true"` + `… icon contract is missing 1 of 6 …` |
| `focusable="false"` removed | same pattern with `focusable="false"` |
| `width="18"` removed | same pattern with `width="18"` |
| `height="18"` removed | same pattern with `height="18"` |
| `stroke="currentColor"` removed | same pattern with `stroke="currentColor"` |
| `link-button--gradient-1` added to the real Enlace | `Harness status: FAILED - the Instagram Enlace must not use a link-button--gradient-* modifier …` |
| `data-demo="link-button"` removed | `Harness status: FAILED - index.html is missing the temporary link button demo …` |
| Demo label `Enlace tres` altered | `Harness status: FAILED - index.html is missing the temporary link button demo label: >Enlace tres<` |
| `.links` padding removed | `Harness status: FAILED - styles.css .links layout rule is missing declaration: padding: 0 var(--space-lg);` |

The nav-removal case proves the gate is anchored to `<nav class="links">` and is not satisfied by the pre-existing Instagram link in the footer.

### Static and scope audit

- `index.html` diff vs `HEAD` is additive only: one `<nav class="links" aria-label="Enlaces de contacto">` with exactly one `<a class="link-button">` and its inline Instagram SVG, inserted after `</header>` of `.profile-identity` and before the demo. No deleted lines.
- Removing the new nav from the working copy leaves the rest of `index.html` identical to `HEAD` except one blank line.
- Demo intact: `data-demo="link-button"`, 5 demo anchors, 5 `href="#link-button-demo"`, labels `Enlace uno`…`Enlace cinco`; `[data-demo="link-button"]` CSS block identical to `HEAD`.
- `styles.css` diff is additive only: one `.links { padding: 0 var(--space-lg); }` rule between the component/reduced-motion block and the footer. `:root` block identical with exactly 51 tokens; `body`, `.page`, `.card`, `.link-button` and `[data-demo="link-button"]` blocks identical to `HEAD`.
- `<head>`, avatar markup, identity, footer and `DESIGN.md` unchanged (`git diff HEAD -- DESIGN.md` empty).
- 0 `<script>`; only one real `.link-button` in the nav and 6 in the document (5 belong to the demo); no `target`, `rel` or `aria-label` on the real Enlace; no `link-button--gradient-*` inside the nav; no new ordering/gap/gradient CSS.
- No `package.json`, lockfile, `node_modules`, framework, bundler, dependency or new product asset; no E2E harness exists, which matches the spec and `docs/technical-discovery.md`.

### Browser (own server only, `python3 -m http.server 3301 --directory .`, PID 2631, stopped; 3301 free afterwards)

`curl -sI` -> `/` 200 `text/html`, `/styles.css` 200 `text/css`, `/assets/avatar.jpg` 200 `image/jpeg`; server log contains no 4xx/5xx and no `favicon` line.

**390×844 (mobile emulation, cache ignored):**

- Console: 0 messages. Network: 5/5 `200` (document, Google Fonts CSS, `styles.css`, `avatar.jpg`, WOFF2); no `/favicon.ico` and no Enlace-triggered request. `scrollWidth == clientWidth == 390`.
- Card 358px at `x=16`; nav 356px at `x=17` (height 48); Enlace 308×48 at `x=41`; demo first anchor 324×48 at `x=33`; `FOOTER.page-footer` is the last child of `.card`; nav precedes the demo; exactly 1 `.link-button` inside the nav.
- Computed Enlace: `display:flex`, `height:48px`, `padding:0px 20px`, `border-radius:6px`, `justify-content:space-between`, `font-size:11px`, `font-weight:800`, `line-height:16px`, `letter-spacing:1.98px`, `text-transform:uppercase`, `color:rgb(255, 255, 255)`, `background-color:rgb(104, 118, 240)`, base shadow `rgba(108, 114, 234, 0.15) 0px 2px 6px 0px`.
- Icon 18×18 at 20px from the Enlace's right edge; `class="link-button__icon"`, `viewBox="0 0 24 24"`, `width/height="18"`, `fill="none"`, `stroke="currentColor"`, `aria-hidden="true"`, `focusable="false"`, 3 glyph shapes; not exposed in the accessibility tree.
- `href` exactly `https://www.instagram.com/fahedhermoza/`; no `target`, `rel` or `aria-label`; text `Instagram` (`innerText` `INSTAGRAM`). Accessibility tree: `navigation "Enlaces de contacto"` -> `link "INSTAGRAM"`; demo links and footer links unchanged.
- `Tab` -> real Enlace focused: `:focus-visible=true`, `outline: rgb(88, 92, 229) solid 2px`, `outline-offset:2px`. `Enter` was not pressed on the external Enlace.

**1280×800 (desktop emulation, cache ignored):**

- Console: 0 messages. Network: 5/5 `200`; no `/favicon.ico`. `scrollWidth == clientWidth == 1265` (1280 viewport minus the 15px vertical scrollbar), i.e. no horizontal overflow.
- Card 400px at `x=432.5` (centered in the 1265px content area); nav 398px at `x=433.5`; Enlace 350×48 at `x=457.5`; demo first anchor 366×48 at `x=449.5`; icon 18×18 with 20px right gap; same computed contract as mobile.
- Real hover: `transform: matrix(1, 0, 0, 1, 0, -1.5)`, `box-shadow: rgba(108, 114, 234, 0.28) 0px 8px 18px 0px`, `filter: brightness(1.03)`, `transition-duration: 0.18s`.
- `prefers-reduced-motion: reduce` emulated with hover: `matchMedia=true`, `transition-property:none`, `transition-duration:0s`, `transform:none`. Console remained empty.
- `Tab` focus is visible with `rgb(88, 92, 229) solid 2px` offset 2px (same rule as mobile). The external Enlace was not activated.

**320×844 (extra):**

- Console 0 messages, 5/5 `200`, no `/favicon.ico`, `scrollWidth == clientWidth == 320`; card 288px at `x=16`, nav 286px at `x=17`, Enlace 238×48 at `x=41`, full `INSTAGRAM` label and icon.

### Accessibility and contrast

- The Enlace name comes from the visible label (`Instagram`, exposed uppercase by `text-transform`), accepted by the spec; the icon is decorative and the nav landmark is named `Enlaces de contacto` (distinct from the footer's `@fahedhermoza en Instagram`).
- Touch target 48px tall across the nav content width.
- White on `#6876f0` remains `3.86:1`, the already-recorded inherited risk for `accessibility-baseline`; this feature does not change tokens, colors or label size.

### Security assessment

- No secrets, credentials, user input, storage, auth/session, server/client boundary, uploads or server calls are introduced.
- The only external navigation is a hard-coded trusted HTTPS URL with no `target` (therefore no tabnabbing surface) and no `rel` needed; the page remains static with no JavaScript.
- Security checklist: no relevant issues; no blocking findings.

### Documentation and handoff

- `feature_list.json` sets `link-instagram` to `passing` (not `accepted`), with evidence and the note that the demo is intentionally preserved and its removal deferred.
- `PROGRESS.md` current state and Session 019 match the reproduced results (gate, 12 negative cases, 3301 browser measurements, scope guard, inherited contrast risk, scrollbar note).
- `docs/specs/link-instagram.md` exists; no other durable doc needed changes per the spec's Durable Documentation Impact; `AGENTS.md`, `DESIGN.md`, `docs/technical-discovery.md` and `docs/risks-and-open-questions.md` were not modified.
- Status evidence accuracy: the implementer's reported numbers, failure messages and viewport measurements were reproduced; no contradiction found.

## Findings

No Critical, High or Medium findings.

### Note: textual gate scope

- Severity: Low
- Evidence: `init.sh` extracts `<nav class="links">…</nav>` with `awk` and checks the icon attributes with substring matching inside that block; the demo-label check is a global `grep` over `index.html`.
- Why it matters: a future edit could satisfy a textual check without the attribute being on the icon element, or satisfy demo labels with text outside the demo.
- Required change: none for this feature; the browser/DOM checks in this record confirm the real markup.
- Suggested follow-up (optional): scope the icon attribute checks to the `<svg …>` tag and the demo-label checks to the demo block when the harness is next extended.

### Note: desktop geometry differs from the nominal spec values

- Severity: Low
- Evidence: measured card `x=432.5` and `clientWidth=1265` at 1280×800, versus the spec's nominal `x=440` and 1280.
- Why it matters: none functionally; the difference is the 15px vertical scrollbar, not horizontal overflow. `scrollWidth == clientWidth` and the card is centered in the content area.
- Required change: none; the implementer documented the cause in `feature_list.json` and `PROGRESS.md`.

## Verdict

**accept** — all acceptance scenarios and acceptance criteria are satisfied, the required gate and negative cases behave as specified without starting a server, browser verification is clean at 390×844 and 1280×800 (plus 320×844), scope discipline holds, and durable state/evidence match the reproduced results. No Critical/High/Medium findings; only two Low notes above.
