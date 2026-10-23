# Validation Record: page-shell

- Feature id: `page-shell`
- Spec: `docs/specs/page-shell.md`
- Validator: `feature-validator` (validator subagent, independent of implementer)
- Date: 2026-10-23
- Rounds: 1
- Verdict: **accept**

## Review Target

- Claimed status before validation: `passing` (implemented + self-verified, not accepted).
- Changed files: `index.html`, `styles.css`, `init.sh`, `feature_list.json`, `PROGRESS.md`; spec `docs/specs/page-shell.md` (planner artifact).
- Working tree contained only the feature's changes; the validator's server on port 3101 was stopped afterwards.

## Checks Ran And Observed Results

### Harness gate

- `bash -n init.sh` → syntax OK.
- `./init.sh` → `Harness status: bootstrapped (static site detected)`, prior checks `[ok]`, `[ok] page shell markup`, `[ok] page shell styles`, `[ok] card width contract`, serving command printed for port 3101, exit `0`, no server started.
- Negative tests on temp copies:
  - remove `class="card"` → exit `1`, `FAILED - index.html is missing class="page" or class="card"`.
  - rename `.card` rule → exit `1`, `FAILED - styles.css is missing the .page or .card rule`.
  - alter the width contract → exit `1`, `FAILED - styles.css is missing the card width contract ...`.
  - no listener on 3101 after any failure.

### Serving

- `python3 -m http.server 3101 --directory .` → `/` HTTP 200 `text/html`; `/styles.css` HTTP 200 `text/css`; Google Fonts CSS HTTP 200.
- Reloads produced expected `304` revalidations for local assets.

### Browser

- 390×844 and 1280×800: no console messages, no failed page requests.
- Geometry verified at 320/375/390/768/1280:

| Viewport | Card width | `x` | `y` | Equal top/bottom space | Horizontal scroll |
| --- | ---: | ---: | ---: | --- | --- |
| 320×844 | 288px | 16 | 262 | yes | none |
| 375×844 | 343px | 16 | 262 | yes | none |
| 390×844 | 358px | 16 | 262 | yes | none |
| 768×800 | 400px | 184 | 240 | yes | none |
| 1280×800 | 400px | 440 | 240 | yes | none |

- Computed `.card`: background `rgb(255, 255, 255)`, radius `12px`, border `1px rgba(0,0,0,0.04)`, exact two-layer DESIGN.md shadow, `margin-block: auto`, `flex-shrink: 0`.
- Computed `.page`: flex column, centered, `100vh`/`100dvh`, padding `24px 16px` from tokens; `body` remains `rgb(247, 249, 255)`.
- Tall-card override at 390×600 (`.card { min-height: 1200px }`): top `24px` at `scrollTop = 0`, page scrollable to the end, no horizontal scroll; override removed.
- HTML is exactly `<main class="page"><article class="card"></article></main>`; the card has no children or text and no other feature content.
- `:root` and `body` unchanged; only the expected CSS additions. No JS, framework, bundler, dependency or new token.

## Findings

- Blocking: none.
- Low (non-blocking):
  1. `init.sh` uses textual `grep` checks rather than semantic DOM/CSS parsing; it covers the spec's three gate cases but not every malformed markup variant.
  2. The implementer's evidence phrase "no archivos nuevos" refers to product files; `docs/specs/page-shell.md` is the planned planning artifact.
  3. The browser's optional `/favicon.ico` probe returns `404`, but independent Chrome runs did not request it during page loads, DevTools/`performance` showed only `/`, `styles.css` and the Google Fonts CSS, the spec excludes the favicon, and the verification contract scopes failed requests to those page resources. It is therefore not counted as a feature-level failed request; treating every optional URL as a required request would need a repo-wide rule/spec reconciliation.

## Scope / Durability

- Scope clean: shell only, no Profile/Links/Footer/vCard content, no JS/build/dependencies, no changes to `DESIGN.md`.
- `feature_list.json` evidence matched reproduced reality; `PROGRESS.md` Session 006 accurate.
- No E2E harness exists; the spec's justification for manual browser verification holds.

## Verdict Rationale

All acceptance scenarios pass, the card is visible and correctly centered and styled while intentionally empty, the harness detects a broken shell without starting a server, and the evidence is accurate. Accepted.
