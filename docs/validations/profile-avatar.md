# Validation Record: profile-avatar

- Feature id: `profile-avatar`
- Spec: `docs/specs/profile-avatar.md`
- Validator: `feature-validator` (validator subagent, independent of implementer)
- Date: 2026-10-23
- Rounds: 1
- Verdict: **accept** (orchestrator persists the status change to `accepted`)

## Review Target

- Claimed status before validation: `passing` (implemented + self-verified, not accepted).
- Changed files: `index.html`, `styles.css`, `init.sh`, `feature_list.json`, `PROGRESS.md`; spec `docs/specs/profile-avatar.md` (planner artifact). No product files outside the feature.
- `assets/avatar.jpg` is byte-identical to `HEAD` (`git hash-object` = `git rev-parse HEAD:assets/avatar.jpg` = `c2ff862d4383cd58630714c2e3ea3bfdde249835`; `git diff` empty; JPEG baseline 460×460, 45029 bytes).
- Validator server (port 3201) started and stopped during validation; port free afterwards.

## Checks Ran And Observed Results

### Static / scope

- `git diff` for `index.html` / `styles.css` contains only additions: `<header class="profile">` with the `<img>` before `section#link-button-demo`, and the `.profile` / `.profile-avatar` rules. No changes to `:root`, `body`, `.page`, `.card`, `.link-button` or `[data-demo]`.
- `:root` still declares 51 custom properties; the component-local variable count is unchanged. New values are component-level (`88px`, `3px`), not tokens.
- No `<script>`, `package.json`, framework, bundler or dependency added; no image generated, cropped or replaced.
- The demo section remains inside `.card` after the profile block and its markup is untouched.

### Harness gate

- `bash -n init.sh` → syntax OK.
- `./init.sh` → `Harness status: bootstrapped (static site detected)`, bootstrap 3/3, tokens 51/51, component checks, page shell checks, `Profile checks:` `[ok] profile avatar markup`, `[ok] avatar asset exists`, `[ok] .profile-avatar base rule exists`, `[ok] profile avatar contract (5/5)`; exit `0`; no server started. Serving command prints port 3201.
- Independent negative cases on temp copies outside the repo (all exit `1`, stderr message, no listener on 3201, copies removed):
  - remove `object-fit: cover;` → `FAILED - .profile-avatar base rule missing declaration: object-fit: cover;` + `Harness status: FAILED - profile avatar contract is missing 1 of 5 required declarations`.
  - remove `box-shadow: 0 0 0 3px var(--color-surface);` → same pattern naming that declaration.
  - rename `.profile-avatar` rule → `Harness status: FAILED - styles.css is missing the .profile-avatar base rule`.
  - empty `alt=""` → `Harness status: FAILED - index.html is missing the profile avatar markup (...)`.
  - delete `assets/avatar.jpg` and truncate it to 0 bytes → `Harness status: FAILED - assets/avatar.jpg is missing or empty`.
  - unmodified baseline copy → exit `0` with the four Profile checks (control).

### Serving

- Single own server `python3 -m http.server 3201 --directory .` (port checked free first; listener confirmed; stopped afterwards, no listener remains):
  - `curl -sI /` → `200 text/html`, `curl -sI /styles.css` → `200 text/css`, `curl -sI /assets/avatar.jpg` → `200 image/jpeg` (45029 bytes).
  - Server access log (14 requests): `0` responses with status `404`, `0` `/favicon.ico` requests.

### Browser (Chrome DevTools, fresh load ignoring cache)

| Measurement | 390×844 | 1280×800 |
| --- | --- | --- |
| Viewport | 390×844 mobile/touch | 1280×800 desktop |
| `<img>` rect | x=151, y=198, 88×88 | x=596, y=176, 88×88 |
| Card | x=16, y=161, 358×522, center 195 | x=440, y=139, 400×522, center 640 |
| Avatar center vs card center | 195 = 195 | 640 = 640 |
| `complete` / natural size | true / 460×460 | true / 460×460 |
| Computed `display` | `block` | `block` |
| Computed `width` / `height` | `88px` / `88px` | `88px` / `88px` |
| Computed `object-fit` | `cover` | `cover` |
| Computed `border-radius` | `9999px` | `9999px` |
| Computed `box-shadow` | `rgb(255, 255, 255) 0px 0px 0px 3px` | `rgb(255, 255, 255) 0px 0px 0px 3px` |
| `.profile` | flex column, `align-items:center`, padding 36px/36px | same |
| DOM position | inside `.card`, before `[data-demo="link-button"]` | same |
| Horizontal scroll | `scrollWidth == clientWidth == 390` (document and body) | `1280 == 1280` (document and body) |
| Console | 0 messages | 0 messages |
| Network | 5 requests, all `200`: `/`, Google Fonts CSS, `styles.css`, WOFF2, `assets/avatar.jpg` | same 5 requests, all `200` |
| Accessible name | `image "Retrato de Fahed Hermoza"` | `image "Retrato de Fahed Hermoza"` |

- The avatar is fully visible on desktop and not clipped; the demo still renders after the profile block.
- Image request observed `200` in DevTools and the server log; `currentSrc` is `http://localhost:3201/assets/avatar.jpg`.
- `alt` is descriptive and non-empty; no `role="presentation"`, `alt=""`, hidden or decorative treatment. No added controls, focus behavior or contrast change.

## Findings

- Blocking: none.
- Critical/High/Medium: none.
- Low (non-blocking):
  1. The gate checks markup via textual `grep` and the CSS contract via substring matching inside the extracted `.profile-avatar` rule. It covers all spec-required negative cases, but it would not catch a rule containing extra declarations or a same-named selector in a non-applied block. Acceptable at this project maturity; not feature-blocking.
  2. The gate verifies that the avatar markup exists but not that it is inside `.card` / before the demo; that structural condition was verified in the browser instead. The spec only requires the three markup strings, so this is a coverage note, not a contract miss.
  3. The manual-verification hint still reads "mobile viewport (320/375/768px)" while this feature's required viewports are 390×844 and 1280×800; wording only, no behavior impact.
  4. Screenshot capture was produced but image interpretation was unavailable to the validator runtime; measured `getBoundingClientRect()` / `getComputedStyle()` and the accessibility tree were used as primary evidence, matching the spec's fallback allowance.

## Security Assessment

- Feature-scoped checklist: no secrets/config, no auth/authorization surface, no user input, no dynamic HTML/JS sink, no external service calls, no uploads, no dependency changes. Static image reference only.
- Attack surface added: a local image element with fixed dimensions and descriptive `alt`. No relevant security or privacy finding.

## Documentation / Harness State

- `feature_list.json`: `profile-avatar` is `passing` with evidence that matches the reproduced results (no overstated browser claims found).
- `PROGRESS.md`: current verified state, worktree path, port 3201, Session 010 and next step are accurate; the stale worktree path noted in the spec was corrected.
- Spec `Durable Documentation Impact` respected: no `ARCHITECTURE.md`, `CONSTRAINTS.md`, `DESIGN.md` or discovery-doc changes were needed or made.
- No E2E harness exists; the spec's justification (adding one would require prohibited dependencies) holds. The non-blocking gate plus reproducible browser measurements provide the coverage.

## Verdict Rationale

All four acceptance scenarios pass: the avatar renders 88×88 with `object-fit: cover`, circular radius and a 3px white outer halo, centered inside `.card` before the untouched demo at both required viewports without console errors, failed requests or horizontal scroll; the asset is unchanged and served `200 image/jpeg`; the accessible name is correct; and the harness fails independently on each broken avatar variant without starting a server. Scope, security and durable-doc checks are clean. Accepted.
