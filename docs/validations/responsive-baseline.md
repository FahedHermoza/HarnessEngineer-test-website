# Validation Record: responsive-baseline

- Feature id: `responsive-baseline`
- Spec: `docs/specs/responsive-baseline.md`
- Validator: `feature-validator` (independent validator, not the implementer)
- Date: 2026-10-23
- Verdict: **accept**
- Recommended state update: the orchestrator may set `responsive-baseline` from `passing` to `accepted` and append concise acceptance evidence. This validator did not change `feature_list.json`, commit, push, or switch branches.

## Review Target

- Claimed status before validation: `passing`; dependencies `page-shell` and `links-order-gradient` are `accepted`.
- Product diff reviewed: `git status --short` shows modified `CONSTRAINTS.md`, `DESIGN.md`, `PROGRESS.md`, `docs/risks-and-open-questions.md`, `docs/technical-discovery.md`, `feature_list.json`, `init.sh`, plus the new untracked spec. `index.html` and `styles.css` have no diff versus `HEAD`.
- Harness diff: one hunk at the old serving hint; 160 lines added after `Accessibility checks:` and only the three serving lines replaced (two `echo` lines and the `RUN_SERVE_COMMAND` `exec`). All checks before `Responsive checks:` are byte-identical to `HEAD`.
- No JS, `<script>`, `package.json`, lockfile, framework, bundler, dependency, generated asset, new token or new product file was introduced. `styles.css` still has only `@media (hover: hover)` and `@media (prefers-reduced-motion: reduce)`; there are no width media queries.

## Checks Ran And Observed Results

### Harness gate

- `bash -n init.sh` -> exit `0`.
- `./init.sh` -> exit `0`, no stderr, no server started. Output contains the three expected metadata `[warn]`s (`og-image.jpg` missing, relative preview image, `og:url`/canonical pending).
- Section order in stdout: all pre-existing sections (bootstrap, tokens, component, page shell, profile, avatar fallback, footer, links, identity, metadata, Instagram, WhatsApp, order/gradient) and `Accessibility checks:` first, then `Responsive checks:`, then the serving hint.
- New `[ok]` lines:
  - `universal border-box`
  - `page gutter uses var(--space-gutter)`
  - `card max-width guard`
  - `link label shrink guard (4/4)`
  - `no horizontal overflow masking or 100vw widths`
  - `no width breakpoints; fluid layout covers 320-1280`
  - `width breakpoints keep link button tap targets >=44px (none today)`
  - `responsive contract (fluid card, full-width 48px buttons, shrink-safe labels)`
- Serving hint and `RUN_SERVE_COMMAND` both use `3502`; the manual verification line lists the eight widths.
- `./init.sh` was re-run after the browser server was stopped: exit `0`, no listener on 3502.

### Independent negative cases

Seven temporary copies outside the repo (deleted afterwards) each exited `1`, printed concrete stderr, kept the prior checks running, and left 3502 without a listener:

1. Universal `box-sizing: border-box;` removed -> `FAILED - styles.css must keep *, *::before, *::after { box-sizing: border-box; }`.
2. `.card` `max-width: 100%;` removed -> `FAILED - styles.css .card must keep max-width: 100%;`.
3. `.page` padding no longer uses `var(--space-gutter)` -> `FAILED - styles.css .page must keep a padding declaration using var(--space-gutter)`.
4. `text-overflow: ellipsis;` removed from `.link-button__label` -> `FAILED - .link-button__label rule missing declaration: text-overflow: ellipsis;` + `Harness status: FAILED - .link-button__label contract is missing 1 of 4 required declarations`.
5. `overflow-x: hidden;` added to `body` -> `FAILED - styles.css must not mask horizontal overflow (overflow-x hidden/clip, body/page masking or width: 100vw)`.
6. `@media (min-width: 600px)` added -> `FAILED - width breakpoint 600px is outside the DESIGN.md set (360px/480px/736px)` + `Harness status: FAILED - styles.css uses 1 width breakpoint value(s) outside 360px/480px/736px`.
7. `@media (max-width: 360px) { .link-button { height: 40px; } }` added -> `FAILED - width breakpoint declares .link-button height 40px (<44px)` + `Harness status: FAILED - width breakpoints must keep .link-button height >= 44px`.

### Browser matrix

Single server `python3 -m http.server 3502 --directory .` in this worktree; each row used a fresh cache-bypassing reload and awaited `document.fonts.ready`; mobile/touch emulation for <=480 and desktop for >=736. The server was stopped afterwards and 3502 confirmed free.

| Viewport | clientWidth | doc/body scrollWidth | Card w×h (x) | 7 buttons w×h | min tap | Truncated labels | Elements outside | Console | Page requests |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| 320×844 | 320 | 320/320 | 288×861 (16) | 238×48 | 48 | 0 | 0 | 0 messages | 5/5 200 |
| 360×844 | 360 | 360/360 | 328×861 (16) | 278×48 | 48 | 0 | 0 | 0 messages | 5/5 200 |
| 375×844 | 375 | 375/375 | 343×841 (16) | 293×48 | 48 | 0 | 0 | 0 messages | 5/5 200 |
| 390×844 (DPR 3) | 390 | 390/390 | 358×841 (16) | 308×48 | 48 | 0 | 0 | 0 messages | 5/5 200 |
| 480×844 | 480 | 480/480 | 400×841 (40) | 350×48 | 48 | 0 | 0 | 0 messages | 5/5 200 |
| 736×800 | 721 | 721/721 | 400×841 (160.5) | 350×48 | 48 | 0 | 0 | 0 messages | 5/5 200 |
| 768×800 | 753 | 753/753 | 400×841 (176.5) | 350×48 | 48 | 0 | 0 | 0 messages | 5/5 200 |
| 1280×800 | 1265 | 1265/1265 | 400×841 (432.5) | 350×48 | 48 | 0 | 0 | 0 messages | 5/5 200 |

Additional per-row assertions: card width equals `Math.min(400, clientWidth - 32)` and is centered (`|center - clientWidth/2| < 1`); every button width equals `card.width - 50` (border + 24px padding per side) and height is 48; footer and its two links stay inside the card, the email/handle do not overflow, and the Profile identity blocks have `scrollWidth <= clientWidth`; footer text is two lines at 320–360 and one line from 375. Network for every row: `/`, Google Fonts CSS, `styles.css`, `assets/avatar.jpg`, WOFF2; no failed request, no `/favicon.ico`. Server log contains zero `favicon` lines; the only 404s are Lighthouse probes.

### Focus and reduced motion

- 1280×800: real `Tab` focused `Instagram` with `:focus-visible=true`, `outline: rgb(88, 92, 229) solid 2px`, `outline-offset: 2px`; `documentElement`/`body` scrollWidth remained `1265`.
- 320×844: real `Tab` focused `Instagram` with the same focus contract; scrollWidth remained `320`.
- `prefers-reduced-motion: reduce` at both widths: `matchMedia(...).matches=true`, `.link-button` computed `transition-property: none`, `transition-duration: 0s`, `transform: none`, focus outline preserved.

### Lighthouse mobile accessibility

`chrome-devtools_lighthouse_audit`, device `mobile`, mode `navigation`, URL `http://localhost:3502`:

- Accessibility **100**, Best Practices 100, Agentic Browsing 100, SEO 91.
- 45 audits passed, 1 failed: SEO `meta-description` only (out of scope).
- No `critical`/`serious` accessibility failures.

### Durable docs and scope

- `DESIGN.md` records the verified `Responsive Baseline` decision, the fluid formula, the label guard, the audit frontiers and the eight-row measurement table.
- `CONSTRAINTS.md` adds operational MUST/MUST NOT responsive rules, including no overflow masking, the 360/480/736 breakpoint set, tap targets and the runtime-matrix requirement.
- `docs/technical-discovery.md` documents `Responsive checks:`, the eight-width matrix and port 3502; `docs/risks-and-open-questions.md` records the runtime-only proof and the future eighth button; `PROGRESS.md` records Session 048.
- `feature_list.json` remains at `passing` with concrete evidence; no other feature status changed.
- `git diff --check` -> clean.

## Findings

### Critical

None.

### High

None.

### Medium

None.

### Low (non-blocking)

1. **Gate scope is narrower than its summary line for future overrides.** `init.sh` check 7 only inspects `height` declarations inside width media queries, and check 6 only recognizes `(min-width|max-width: Npx)`. Independent probes showed that a later plain override `.link-button { height: 40px; }` and a range-syntax breakpoint `@media (width >= 600px)` both leave `./init.sh` at exit 0. This matches the spec's defined check semantics and the documented "runtime matrix is the real proof", so it is not a defect in this feature; the browser matrix would catch the tap-target regression. Optional hardening for a future change: scan all `.link-button` height declarations or reject range-syntax width queries.
2. **Selector extraction is formatting-sensitive (fails closed).** The universal rule check expects `*,` on its own line, and the `.page`/`.card`/`.link-button__label` checks expect the selector and `{` on the same line. A reformat would fail the gate even with semantically valid CSS; it does not create false confidence. Optional hardening: normalize extraction or document the formatting requirement.
3. **Historical 3413 references remain in old session logs and older specs.** Current verification paths (`PROGRESS.md` header, `DESIGN.md`, `docs/technical-discovery.md`, `docs/risks-and-open-questions.md`, serving hint) consistently use 3502. The remaining mentions are historical evidence, not a current instruction.

Security assessment: no product code or input surface changed; the diff is a local static CSS/HTML verification gate plus documentation. No new network destinations, dependencies, scripts, secrets, or data flows. No relevant security issue found.

## Verdict

**accept.** The feature satisfies the spec and the Definition Of Done: the responsive contract is reproduced independently in all eight widths, the new gate is meaningful for its defined invariants and fails all seven required mutations, the AA gate and Lighthouse accessibility are green, product files are untouched, durable docs are coherent, and the repo remains restartable from `./init.sh` with 3502 free.
