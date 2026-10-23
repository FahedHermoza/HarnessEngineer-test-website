# Validation: link-portafolio

- Feature: `link-portafolio`
- Validator: `feature-validator`
- Date: 2026-10-23
- Spec: `docs/specs/link-portafolio.md`
- Verdict: `accept`

## Scope Accepted

One real Enlace `Portafolio` reusing the accepted `.link-button` component and the inline chevron SVG, inside a new `<nav class="links" aria-label="Enlaces">` between `.profile-identity` and the temporary demo. `href` is exactly `https://fahedhermoza.github.io/`; the accessible name derives from the visible text `Portafolio`; the SVG is decorative (`aria-hidden="true"`, `focusable="false"`). No other Enlace, no order/gradient assignment, and no other feature was implemented. The temporary `[data-demo="link-button"]` demo, the Perfil, the pie, `.link-button`, `.page`, `.card`, `body` and `:root` remain intact.

## Checks Reproduced

| Check | Result |
|---|---|
| `bash -n init.sh` | exit 0, no syntax errors |
| `./init.sh` | exit 0; bootstrap 3/3, tokens 51/51, component 6/6 + reduced motion, page shell 3/3, avatar 5/5, pie 5/5, identity checks, `[ok] portfolio link container`, `[ok] portfolio link markup`, `[ok] portfolio link icon`, `[ok] links container contract (4/4)`, 3 expected metadata `[warn]`; no server started |
| Negative: `href` → `https://example.com/` (temp copy outside repo) | exit 1, stderr `Harness status: FAILED - index.html is missing the portfolio link markup (...)` |
| Negative: label `Portafolio` → `Portfolio` | exit 1, same markup failure |
| Negative: `gap: var(--space-sm);` removed from `.links` | exit 1, `FAILED - .links base rule missing declaration: gap: var(--space-sm);` + contract `missing 1 of 4` |
| Negative: SVG `aria-hidden="true"` → `"false"` | exit 1, `Harness status: FAILED - index.html is missing the decorative portfolio link icon (...)` |
| Scope: demo HTML/CSS vs `HEAD` | `cmp` identical; only the `.links` rule was added to `styles.css` and only the `<nav>` block to `index.html` |
| Scope: tokens/JS/deps | `:root` unchanged with 51 custom properties; 0 `<script>`; no `package.json`/bundler/dependencies; `assets/` only `avatar.jpg`; `git diff --check` clean |
| Static server 3305 (validator's own process, stopped) | `/` and `styles.css` served 200; no listener remains (subsequent bind needed only `SO_REUSEADDR` for `TIME_WAIT`, `connect` returns ECONNREFUSED) |
| Browser 390×844 (fresh reload, cache bypass) | console 0 messages; 5 requests all 200 (`/`, Google Fonts CSS, `styles.css`, `avatar.jpg`, WOFF2); no `/favicon.ico`; `scrollWidth == clientWidth == 390` |
| Browser 1280×800 (fresh reload, cache bypass) | console 0 messages; 5 requests all 200; no `/favicon.ico`; `scrollWidth == clientWidth == 1265` (vertical scrollbar); no horizontal scroll |
| Browser 320×844 (extra, fresh reload) | console 0 messages; 5 requests all 200; `scrollWidth == clientWidth == 320`; label and icon do not overlap |
| Geometry 390×844 | card 358×817 at x=16; `nav.links` 356×48 at x=17 (`display:flex`, `flex-direction:column`, `gap:12px`, `padding:0 24px`, `aria-label="Enlaces"`); anchor 308×48 at x=41, `padding:0 20px`, radius 6px, `space-between`, 11px/800, tracking 1.98px, uppercase, background `rgb(104,118,240)`; label left, icon 18×18 right |
| Geometry 1280×800 | card 400×817 centered at x=432.5; `nav.links` 398×48 at x=433.5; anchor 350×48 at x=457.5 centered; same component contract; label left / icon right |
| Accessibility tree | `navigation "Enlaces"` + `link "PORTAFOLIO"` with URL `https://fahedhermoza.github.io/`; SVG contributes no name; demo five links and footer still present |
| Keyboard | `Tab` → anchor `:focus-visible=true`, outline `solid 2px rgb(88, 92, 229)` offset 2px; `Enter` navigated to `https://fahedhermoza.github.io/` |
| Destination | `curl -sI --max-time 20 https://fahedhermoza.github.io/` → HTTP/2 200 |
| Hover | `transform: matrix(1, 0, 0, 1, 0, -1.5)`, hover shadow, `brightness(1.03)`, transition 0.18s |
| `prefers-reduced-motion: reduce` | `transition-property:none`, `transition-duration:0s`, `transform:none` |
| Demo/footer orders | card children `HEADER.profile`, `HEADER.profile-identity`, `NAV.links`, `SECTION[data-demo]`, `FOOTER.page-footer`; demo still has 5 anchors; footer is last child |

## Findings

No Critical / High / Medium findings.

### Low 1 — Implementer evidence used port 3005 instead of the spec's 3305

- Evidence: `PROGRESS.md` Session 019 and `feature_list.json` record the browser run with `python3 -m http.server 3005 --directory .`; the spec Verification Plan requires port **3305**.
- Why it matters: it is a verification-process deviation; if not reproduced, the recorded evidence would not match the prescribed environment.
- Resolution: the validator independently reproduced all browser checks on `127.0.0.1:3305` with a private server that was stopped afterwards. Results matched (0 console messages, all requests 2xx, no `/favicon.ico`, same geometry and behavior), so there is no behavioral impact. No code change required; the orchestrator may correct the port reference in durable evidence when persisting acceptance.

### Low 2 — Accessible name is exposed as `PORTAFOLIO`

- Evidence: accessibility tree reports `link "PORTAFOLIO"`; the DOM text is `Portafolio` and `.link-button` applies `text-transform: uppercase`.
- Why it matters: the spec names the accessible name `Portafolio`; casing differs in the computed name.
- Resolution: this is inherited from the already-accepted `.link-button` component contract (the demo labels are exposed the same way). The source text is correct and there is no redundant `aria-label`. No change required in this feature.

### Low 3 — Textual gate does not verify uniqueness or placement

- Evidence: `init.sh` uses `grep`/`awk` presence checks for the nav, anchor, label, icon and `.links` declarations.
- Why it matters: a duplicate or misplaced block could pass the gate.
- Resolution: consistent with the spec's prescribed simple checks; not blocking.

## Security Assessment

No relevant security issues in this slice: static HTML/CSS with no user input, no JS, no secrets, and a single hardcoded trusted destination URL. The anchor opens in the same tab with no `target`/`rel` change, so no reverse-tabnabbing surface was introduced. No dependency, build, or server/client boundary changes.

## Documentation And Harness State

- `docs/specs/link-portafolio.md` exists and matches the implemented contract.
- `feature_list.json` has `link-portafolio` in `passing` with evidence; PROGRESS.md records Session 019 and the current state. The orchestrator remains responsible for persisting `accepted`.
- The spec's Durable Documentation Impact is respected: no `ARCHITECTURE.md`, `CONSTRAINTS.md`, `AGENTS.md`, `DESIGN.md`, `CONTEXT.md`, build-brief, domain-model, technical-discovery or risks changes were needed or made.
- `./init.sh` remains the standard non-blocking gate and does not start long-running processes.

## Cleanup

The validator started only its own static server on port 3305 and stopped it. No commit, push, merge, branch or worktree change was performed. Temporary negative-case copies were created outside the worktree under the sandbox temp directory.
