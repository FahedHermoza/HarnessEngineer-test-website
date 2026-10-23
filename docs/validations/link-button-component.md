# Validation Record: link-button-component

- Feature id: `link-button-component`
- Spec: `docs/specs/link-button-component.md`
- Validator: `feature-validator` (independent validator, not the implementer)
- Date: 2026-10-23
- Rounds: 2 (round 1 prior independent verdict `revise`; round 2 this full re-validation)
- Verdict: **accept**
- Recommended state update: orchestrator may set `link-button-component` from `passing` to `accepted` and append concise acceptance evidence.

## Review Target

- Claimed status before this validation: `passing`.
- Changed files reviewed: `styles.css`, `index.html`, `init.sh`, `feature_list.json`, `PROGRESS.md`, `docs/risks-and-open-questions.md`; planner/repair spec `docs/specs/link-button-component.md`.
- Scope of this run: full feature re-validation, not only the favicon repair.
- Repository was not modified by the validator. Validation server and temporary copies were stopped/deleted.

## Round 1 Findings And Repair

Round 1 independently returned `revise` with:

- **High:** implicit `GET /favicon.ico` returned 404 and produced a browser console error at 390x844 and 1280x800.
- **Medium:** durable evidence overstated a clean console/network result.

Repair applied by the implementer:

- Added `<link rel="icon" href="data:,">` to `index.html`.
- Corrected `feature_list.json` and `PROGRESS.md` evidence, including a retroactive correction in Session 006 and a post-repair Session 007.
- Documented the icon declaration in the spec.
- No files, JavaScript, frameworks, bundlers, or dependencies were added.
- `:root` remained at 51 custom properties.

## Checks Ran And Observed Results

### Harness gate

- `bash -n init.sh` -> syntax OK, exit `0`.
- `./init.sh` -> exit `0`, no server started:
  - `Harness status: bootstrapped (static site detected)`
  - Bootstrap checks `[ok]` x3 (`lang="es"`, non-empty title, viewport).
  - `[ok] design tokens present (51/51)`
  - `[ok] .link-button base rule exists`
  - `[ok] link button component contract (6/6)`
  - `[ok] prefers-reduced-motion media query`
- `init.sh` still executes the checks rather than merely printing commands, and it does not start a long-running server by default.

### Independent negative test

Temporary copy outside the repository; `height: 48px;` removed from the `.link-button` base rule:

- `./init.sh` -> exit `1`.
- stderr:
  - `FAILED - .link-button base rule missing declaration: height: 48px;`
  - `Harness status: FAILED - .link-button component contract is missing 1 of 6 required declarations`
- Temporary copy deleted; repository untouched.

### Static and scope audit

- `feature_list.json` parses as valid JSON; selected status is `passing`.
- `styles.css` `:root` declarations: 51 total, 51 unique.
- No `<script>` element in `index.html`.
- No project `package.json`, root `node_modules`, JS source, bundler, framework, or new dependency.
- `git diff --check` -> exit `0`.
- Changes remain within this feature plus its spec, evidence, progress log, and contrast risk-register entry.
- No real URLs, final seven-link list/order, page shell, profile, avatar, vCard, footer, or Open Graph work was introduced.
- Temporary demo remains clearly marked and assigned to `page-shell` for removal.

### Browser: 390x844 mobile

Run in a fresh isolated Chrome context with a cache-bypassing reload; served only by:

`python3 -m http.server 3102 --directory .`

Network, since the fresh reload:

- `GET /` -> 200
- Google Fonts CSS -> 200
- `styles.css` -> 200
- WOFF2 font -> 200
- No `/favicon.ico` request.
- No 4xx/5xx requests.

Console:

- 0 messages.

Computed result:

- 5 buttons.
- Demo section: x `0`, width `390px`.
- First button: x `16px`, width `358px`, height `48px`.
- `display:flex`, `box-sizing:border-box`, `padding:0px 20px`, `align-items:center`, `justify-content:space-between`, `gap:12px`.
- `border-radius:6px`; `color:rgb(255, 255, 255)`.
- Font: Plus Jakarta Sans + fallback; `11px`; weight `800`; line-height `16px`; letter-spacing `1.98px`; `text-transform:uppercase`.
- Normal shadow: `rgba(108, 114, 234, 0.15) 0px 2px 6px 0px`.
- Transition: `0.18s`, `0.18s`, `0.18s` with `ease`.
- Label starts 20px from the button's left padding edge.
- Icon: 18x18, `aria-hidden="true"`, `focusable="false"`, `stroke="currentColor"`, right edge 20px from the button's right padding edge.
- Five modifier backgrounds: `rgb(104, 118, 240)`, `rgb(115, 109, 235)`, `rgb(129, 104, 232)`, `rgb(147, 98, 230)`, `rgb(168, 94, 226)`.
- `scrollWidth == clientWidth == 390`; no horizontal scroll.
- Accessibility snapshot exposes five real links named `ENLACE UNO` through `ENLACE CINCO`.
- `link[rel="icon"]` resolves to `data:,`.

### Browser: 1280x800 desktop

Fresh isolated context and cache-bypassing reload on the same single server:

- Network: document, Google Fonts CSS, `styles.css`, and WOFF2 all `200`.
- No `/favicon.ico` request; no 4xx/5xx.
- Console: 0 messages.
- Demo wrapper: width `420px`, x `430`, therefore centered in the 1280px viewport.
- Button: width `388px`, height `48px`.
- Required typography, padding, radius, color, shadow, and transition values match the mobile run.
- `scrollWidth == clientWidth == 1280`.

Hover:

- `:hover` matched.
- `transform:matrix(1, 0, 0, 1, 0, -1.5)`.
- `box-shadow:rgba(108, 114, 234, 0.28) 0px 8px 18px 0px`.
- `filter:brightness(1.03)`.
- Transition remains `0.18s ease`.

Keyboard focus:

- `Tab` focused the first link; `:focus-visible` matched.
- Accessible text: `Enlace uno`.
- Outline: `rgb(88, 92, 229) solid 2px`; offset `2px`.
- `Enter` navigated to `#link-button-demo` without errors.

Reduced motion:

- `matchMedia('(prefers-reduced-motion: reduce)').matches` -> `true`.
- `transition-property:none`.
- `transition-duration:0s`.
- `transform:none` under hover and keyboard focus.
- Focus outline remained visible: `rgb(88, 92, 229) solid 2px`, offset `2px`.

### Contrast

Independent calculation matches the recorded values:

- White on gradient 1: `3.86:1`
- Gradient 2: `4.10:1`
- Gradient 3: `4.13:1`
- Gradient 4: `4.09:1`
- Gradient 5: `3.91:1`
- Accent on white: `5.15:1`
- Accent on canvas: `4.89:1`

The AA deviation is durably recorded in `docs/risks-and-open-questions.md` for `accessibility-baseline`. No off-palette colors or typography changes were introduced.

### Server log and cleanup

- `python3 -m http.server 3102 --directory .` was the only server used.
- Access log: all local requests were `200`; `favicon` lines = `0`; 404/5xx lines = `0`.
- Server stopped by PID; port 3102 has no remaining listener.

## Findings

### Prior findings closed

- **High — closed:** no `/favicon.ico` request or console error at either required viewport after a cache-bypassing reload. Confirmed by browser network, browser console, and server access log.
- **Medium — closed:** evidence now acknowledges the original favicon error and records the post-repair result rather than claiming a clean run retroactively.

### Low (non-blocking, optional)

- The durable 390x844 evidence records `styles.css` as `304` while describing the navigation as cache-bypassing. This re-validation got `200` with cache bypass. A `304` is not a failed request and does not affect acceptance, but the evidence wording could be tightened or the recorded status corrected in a future documentation pass.

### Blocking findings

- None.

## Security Assessment

Feature-scoped security review found no relevant issues:

- No secrets, auth, permissions, user input, persistence, uploads, redirects, or server-side code.
- No new dependencies or external calls; the existing Google Fonts request is unchanged.
- Inline SVG is static and decorative (`aria-hidden="true"`, `focusable="false"`).
- The `data:,` icon is inert and introduces no executable content.
- Demo links use local fragments only.

## Documentation And Handoff

- `feature_list.json` contains corrected evidence for the repair and evidence matching the independently reproduced behavior.
- `PROGRESS.md` Session 006 correction and Session 007 repair log are accurate and preserve history.
- Contrast risk is registered durably.
- Spec documents the favicon declaration and the temporary demo handoff to `page-shell`.
- `AGENTS.md`, `DESIGN.md`, architecture, and constraints did not require changes for this slice.
- No E2E harness exists; the spec explicitly justifies `init.sh` plus browser verification.
- `./init.sh` remains restartable and passes.
- Status remains `passing` pending orchestrator persistence of this acceptance.

## Verdict Rationale

The repaired favicon behavior is genuinely clean at both required viewports, with cache-bypassing browser evidence and a server log containing no favicon request. The complete component contract still passes: full width, 48px height, 6px radius, uppercase label with 1.98px tracking at the left, 18x18 inline SVG at the right, visible hover/focus, 180ms ease, and reduced-motion behavior. The harness gate, independent negative test, scope discipline, 51-token contract, evidence correction, risk register, and restartability all pass. Accepted.
