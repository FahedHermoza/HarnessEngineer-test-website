# Validation Record: links-order-gradient

- Feature id: `links-order-gradient`
- Spec: `docs/specs/links-order-gradient.md`
- Validator: `feature-validator` (independent validator, not the implementer)
- Date: 2026-10-23
- Verdict: **accept**
- Recommended state update: orchestrator may set `links-order-gradient` from `passing` to `accepted` and append concise acceptance evidence.

## Review Target

- Claimed status before this validation: `passing` (not `accepted`).
- Changed files reviewed: `index.html`, `styles.css`, `init.sh`, `DESIGN.md`, `docs/risks-and-open-questions.md`, `feature_list.json`, `PROGRESS.md`; planner spec `docs/specs/links-order-gradient.md`.
- `feature_list.json` changes only the `links-order-gradient` object (`not_started` -> `passing`); no other feature status changed.
- Product diff: exact Enlace order and tone classes, two interpolated tone modifiers, temporary demo removal, harness updates and durable evidence. No product destinations, labels, icons, profile, footer or page-shell behavior changed.
- Repository was not modified by the validator except for this required validation record. No commit, push or product fix was made.

## Checks Ran And Observed Results

### Harness gate

- `bash -n init.sh` -> exit `0`.
- `./init.sh` -> exit `0`, no server started:
  - `Harness status: bootstrapped (static site detected)`.
  - All prior checks `[ok]`; three pre-existing `og-image`/URL warnings remain non-blocking.
  - `Order and gradient checks:` all `[ok]`: 7 anchors, exact order, exact tone classes, both `color-mix` expressions, `@supports` guard and demo absence.
- `jq empty feature_list.json` -> valid JSON.
- `git diff --check` -> clean.
- `:root` remained at 51 tokens and byte-identical to `HEAD`; no new hex colors, JavaScript, product dependencies or assets.

### Independent negative cases

Five temporary copies outside the repository, each with one deliberate mutation; every run exited `1` with a concrete stderr message and no listener on port `3412`:

1. Full LinkedIn/Portafolio anchor swap -> order mismatch failure.
2. LinkedIn tone changed to `gradient-4` -> tone progression mismatch failure.
3. One `color-mix` expression removed -> missing-expression failure.
4. Demo reintroduced with `data-demo`/`#link-button-demo` -> demo-present failure.
5. `.links` gap changed to `space-md` -> gap failure.

Temporary copies were removed and the repository was not altered.

### Browser: 390x844 mobile

Served only by `python3 -m http.server 3412 --directory .` (own process, stopped afterwards; port free). Fresh load with cache ignored:

- Console: **0 messages**.
- Network: 5/5 requests `200` (`/`, Google Fonts CSS, `styles.css`, `assets/avatar.jpg`, WOFF2); no `/favicon.ico`; no failures.
- `scrollWidth === clientWidth === 390`.
- Exactly 7 `.link-button` anchors in the exact order and classes; no demo markers or demo labels.
- `.links`: 356x408, `padding: 0 24px`, `gap: 12px`.
- Each anchor: 308x48; consecutive gaps exactly `12px`.

### Browser: 1280x800 desktop

Fresh cache-bypassing load on the same server:

- Console: **0 messages**.
- Network: 5/5 requests `200`; no `/favicon.ico`; no failures.
- `documentElement.scrollWidth === clientWidth === 1265` due to the classic 15px vertical scrollbar; no horizontal overflow.
- `.links`: 398x408, `gap: 12px`.
- Each anchor: 350x48; consecutive gaps exactly `12px`.

### Tone progression and inherited states

Computed backgrounds matched the specification:

`rgb(104,118,240)`, `rgb(115,109,235)`, `rgb(129,104,232)`, `color(srgb 0.541176 0.396078 0.905882)`, `rgb(147,98,230)`, `color(srgb 0.617647 0.376471 0.894118)`, `rgb(168,94,226)`.

- Monotonic lavender-to-violet progression confirmed; maximum adjacent per-channel delta is `14/255`.
- First `Tab` focused Instagram with `:focus-visible`; outline `rgb(88, 92, 229) solid 2px`, offset `2px`.
- Hover: `translateY(-1.5px)`, specified hover shadow, `brightness(1.03)`, `0.18s`.
- `prefers-reduced-motion: reduce`: `transition-property: none`, `transition-duration: 0s`, `transform: none`, outline still visible.
- No external destination was activated.

## Findings

### Critical / High / Medium

**None.**

### Low, non-blocking notes

1. The demo-label absence loop checks only `index.html`, while the spec's Scenario 4 mentions labels in both HTML and CSS. The demo markers and CSS block are checked in both files, and no label remnants exist. This is a minor harness-completeness gap, not an observable defect.
2. The new order/tone gates use textual `grep`/`awk` extraction, consistent with the existing harness. They are supported by the existing per-link destination/label/icon checks and the browser verification; no gap affected this validation.

No repair brief is required.

## Scope And Security Assessment

- Same 7 product hrefs, visible labels, `aria-label`s, SVG markup and absence of `target`/`rel`; only tone classes and LinkedIn/Portafolio order changed.
- `<head>`, profile, avatar, identity, footer and page shell are identical to `HEAD`; the demo HTML/CSS is fully removed.
- No new design tokens, palette colors, assets, dependencies, server/client boundary or dynamic behavior.
- No secrets, credentials, authentication/authorization surface, user input, persistence or new external endpoints. External navigation was not performed.
- The only relevant inherited risk remains the documented white-label contrast (`3.86-4.13:1`) for `accessibility-baseline`.

## Documentation And Handoff

- `DESIGN.md` correctly documents the resolved seven-link ramp; `docs/risks-and-open-questions.md` accurately records the interpolated-tone contrast.
- `feature_list.json` and `PROGRESS.md` match observed behavior and verification evidence, including demo removal and port `3412`.
- `init.sh` remains non-blocking and does not start a server by default. No persistent E2E harness exists; adding one would require dependencies prohibited by `docs/technical-discovery.md`, and the spec accepts the harness-plus-browser approach.
- After the orchestrator persists acceptance, `save-contact-vcard` becomes dependency-ready; `avatar-fallback` remains the earlier ready feature in list order.
