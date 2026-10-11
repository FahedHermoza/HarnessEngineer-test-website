# Validation Record: design-tokens

- Feature id: `design-tokens`
- Spec: `docs/specs/design-tokens.md`
- Validator: `feature-validator` (validator subagent, independent of implementer)
- Date: 2026-10-11
- Rounds: 2 (round 1 verdict `revise`; round 2 verdict `accept` after repair)
- Verdict: **accept**

## Review Target

- Claimed status before validation: `passing` (implemented + self-verified, not accepted).
- Changed files: `styles.css` (new), `index.html`, `init.sh`, `feature_list.json`, `PROGRESS.md`; spec `docs/specs/design-tokens.md` (planner artifact).
- Working tree contained only the feature's changes; temp copies/servers cleaned up by the validator.

## Round 1 (verdict `revise`)

- **Finding (Medium):** `init.sh` used substring matching (`grep -qF -- "$token" styles.css`). Because `--color-surface` is a substring of `--color-surface-container-low` and `--color-on-surface` is a substring of `--color-on-surface-variant`, deleting the `--color-surface` or `--color-on-surface` declaration still printed `[ok] design tokens present (51/51)` and exited `0`, contradicting Acceptance Scenario 3.
- Repair brief routed back to the implementer: anchor the per-token check to an actual declaration.

## Repair Applied

- `init.sh` line ~110 changed from `grep -qF -- "$token" styles.css` to `grep -qE -- "^[[:space:]]*${token}[[:space:]]*:" styles.css`.
- No token names/values, `index.html`, layout, components, JS, build or deps were touched.
- `feature_list.json` and `PROGRESS.md` updated to reflect the anchored check; `status` kept at `passing` for re-validation.

## Checks Ran And Observed Results (round 2)

### Harness gate

- `bash -n init.sh` → syntax OK.
- `./init.sh` → `Harness status: bootstrapped (static site detected)`, static-bootstrap `[ok]` ×3, `[ok] styles.css exists`, `[ok] index.html links styles.css`, `[ok] design tokens present (51/51)`, exit `0`, no server started.

### Negative tests (temp copies; repo untouched)

- Remove `--color-on-surface` → `FAILED - styles.css missing token: --color-on-surface` + `Harness status: FAILED - styles.css is missing 1 of 51 required design tokens`, exit `1`.
- Remove `--color-surface` → `FAILED - styles.css missing token: --color-surface` + same status, exit `1` (previously reported `51/51`).
- `styles.css` absent → `Harness status: FAILED - styles.css is missing`, exit `1`.
- `<link href="styles.css">` absent → `Harness status: FAILED - index.html does not link styles.css`, exit `1`.
- No server started in any failure path.

### Token contract (independent audit)

- `:root` declarations parsed = 51; expected = 51; MISSING: none; EXTRA: none; MISMATCH: none.
- 16 color + 23 typography + 5 radius + 7 spacing; all values byte-exact vs `DESIGN.md` (colors/typography/rounded/spacing), including the full `--font-family-base`.
- `letter-spacing` present only for `headline-lg`, `headline-md`, `button-label`, `label-sm`; absent for `body-md`/`body-sm`.
- No component tokens (card shadow/border, button height, avatar size).

### Serving and computed styles

- `python3 -m http.server` → `index.html` HTTP 200 `text/html`; `styles.css` HTTP 200 `text/css`.
- Headless Chrome computed `document.body`: `backgroundColor` `rgb(247, 249, 255)` (#f7f9ff), `color` `rgb(45, 49, 57)` (#2d3139), `fontFamily` `"Plus Jakarta Sans", system-ui, -apple-system, "Segoe UI", Roboto, sans-serif`, `marginTop` `0px`, `scrollWidth == clientWidth` (no horizontal scroll).
- Google Fonts `css2?...Plus+Jakarta+Sans...display=swap` → HTTP 200 `text/css`.

### Scope / durability

- Scope clean: no layout, card, components, JS, build tooling or new dependencies added.
- `feature_list.json` `design-tokens` = `passing` with evidence matching reproduced reality; `PROGRESS.md` Session 004 accurate.
- No E2E harness exists in the repo; spec's "E2E not applicable" justification holds.

## Findings

- Blocking: none.
- Low (non-blocking) notes:
  1. The gate asserts token presence, not value/`var()` binding fidelity (manual 1:1 audit covers value parity).
  2. The gate does not scope declarations to the `:root` block.
  3. Commented/disabled declarations would still match.

## Verdict Rationale

The anchored repair closes the round-1 false negative for both prefix-pair tokens, no regression was found, the 51-token contract is byte-exact to `DESIGN.md`, the document applies the background/text/font tokens (verified via computed styles), the harness remains a non-blocking gate with no server by default, and scope/durable docs are honest. Accepted.
