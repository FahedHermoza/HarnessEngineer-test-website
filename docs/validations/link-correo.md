# Validation Record: link-correo

- Feature id: `link-correo`
- Spec: `docs/specs/link-correo.md`
- Validator: `feature-validator` (independent validator, not the implementer)
- Date: 2026-10-23
- Verdict: **accept**
- Recommended state update: orchestrator may set `link-correo` from `passing` to `accepted` and append concise acceptance evidence.

## Review Target

- Claimed status before this validation: `passing` (not `accepted`).
- Changed files reviewed: `index.html`, `styles.css`, `init.sh`, `feature_list.json`, `PROGRESS.md`; planner spec `docs/specs/link-correo.md`.
- `feature_list.json` diff changes only the `link-correo` object status/evidence; all other feature statuses are unchanged.
- Repository was not modified by the validator except for this required validation record. The server and temporary copies were stopped/deleted.

## Checks Ran And Observed Results

### Harness gate

- `bash -n init.sh` -> exit `0`.
- `./init.sh` -> exit `0`, no server started:
  - `Harness status: bootstrapped (static site detected)`
  - All prior gates `[ok]`: bootstrap 3/3, tokens 51/51, component 6/6 + reduced motion, page shell 3/3, avatar 5/5, footer 5/5, identity contracts, then `[ok] link Correo contract (7/7)` and `[ok] links list rule`.
  - Expected metadata warnings (`og-image` missing, relative image, public URL pending) remain non-blocking.
- `feature_list.json` parses as valid JSON; only `link-correo` moved from `not_started` to `passing`.

### Independent negative cases

Each mutation was applied to a temporary copy outside the repository; all exited `1` with the expected stderr and no listener was left behind:

| Case | Result |
| --- | --- |
| `href` changed | exit `1`, missing Correo anchor |
| `aria-label` removed | exit `1`, missing Correo anchor |
| Visible label changed | exit `1`, `1 of 7` contract items missing |
| SVG removed | exit `1`, `3 of 7` contract items missing |
| `.links` padding removed | exit `1`, `.links rule is missing padding...` |
| `<nav class="links">` removed | exit `1`, links list markup missing |
| Footer `mailto:` changed while Correo link remained | exit `1`, page-footer email destination missing |

The implementer's change scoping the footer email check to the `<footer class="page-footer">` block is a strengthening, not a weakening: the footer gate now fails when the footer destination breaks even though the new Correo link contains the same `mailto:` string.

### Static and scope audit

- `:root` contains 51 tokens and was not changed.
- No `<script>` element; no `package.json`, lockfile, framework, bundler, JS source, or new dependency.
- No new assets.
- `git diff --check` -> clean.
- Scope: exactly one real product Enlace under `nav.links > a.link-button`; no gradient modifier; no ordering/gap/interpolation.
- Temporary demo intact: five anchors with `link-button--gradient-1…5` and `href="#link-button-demo"`; its CSS unchanged.
- No other feature implemented (no other Enlaces, vCard, ordering, or unrelated changes).
- Security: static public page with no input, auth, persistence, or server-side surface; public `mailto:` is intentional; inline SVG and href introduce no untrusted markup or script.

## Browser Verification

Own server on port `3306` (confirmed free before start; PID `93689`; stopped afterward; port free).

### Mobile 390x844

- Console: `0` messages.
- Network: `5/5` requests `200`; no `/favicon.ico`, no failed requests.
- No horizontal scroll: `scrollWidth == clientWidth == 390`.
- Correo anchor: `324x48` at `x=33` (full `.links` content width minus 16px side padding).
- Computed: `display:flex`, `space-between`, `padding:0px 20px`, `border-radius:6px`, `11px/800`, tracking `1.98px`, uppercase, white on `rgb(104, 118, 240)`.
- Icon: `18x18`, `currentColor`, `aria-hidden="true"`, `focusable="false"`.
- Accessibility tree: link name `Correo a fahedhermoza@gmail.com`; href resolves to `mailto:fahedhermoza@gmail.com`.

### Desktop 1280x800

- Console: `0` messages.
- Network: `5/5` requests `200`; no failed requests.
- No horizontal scroll: `scrollWidth == clientWidth == 1265`; `innerWidth` is `1280` and the `1265px` content width reflects the vertical scrollbar.
- Correo anchor: `366x48`, inside `.links` with 16px side padding, centered with the 400px card.
- `Tab` -> `:focus-visible=true`, outline `rgb(88, 92, 229) solid 2px` offset `2px`.
- Hover/focus visuals inherited correctly: translate `-1.5px`, hover shadow, `brightness(1.03)`, `0.18s` transition.

## Findings

No Critical, High, or Medium findings.

Non-blocking notes:

- Low: harness uses exact textual matching and does not itself assert uniqueness of the Correo anchor; independent DOM inspection confirmed exactly one.
- Low: desktop evidence records `1265` rather than `1280` for `clientWidth` because of the vertical scrollbar; the actual acceptance condition, no horizontal scroll, passes.
- Low: opening a real mail application remains manually deferred, as allowed by the spec.
- Low: existing white-on-gradient-1 contrast risk (`3.86:1`) remains assigned to `accessibility-baseline`.

## Verdict

**accept**. The implementation satisfies the feature contract, stays within scope, and the recorded `passing` status/evidence is accurate.
