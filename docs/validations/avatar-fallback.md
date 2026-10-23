# Validation Record: avatar-fallback

- Feature id: `avatar-fallback`
- Spec: `docs/specs/avatar-fallback.md`
- Validator: `feature-validator` (independent validator, not the implementer)
- Date: 2026-10-23
- Verdict: **accept**
- Recommended state update: orchestrator may set `avatar-fallback` from `passing` to `accepted` and append concise acceptance evidence.

## Review Target

- Claimed status before this validation: `passing` (not `accepted`); no other feature status changed.
- Changed files reviewed: `index.html`, `styles.css`, `init.sh`, `feature_list.json`, `PROGRESS.md`; planner spec `docs/specs/avatar-fallback.md`.
- The product diff wraps the accepted avatar in `.profile-avatar-frame`, adds the decorative `FH` fallback and the inline `onerror`, adds the frame/fallback/activation CSS and 7 harness checks, and adds the durable evidence.
- Repository was not modified by the validator except for this validation record. No commit, push, product fix or feature status change was made.

## Checks Ran And Observed Results

### Harness gate

- `bash -n init.sh` -> exit `0`.
- `./init.sh` -> exit `0`, no server started (3411 and 3301 had no listener before and after):
  - `Harness status: bootstrapped (static site detected)`.
  - All prior checks `[ok]`: bootstrap 3/3, tokens 51/51, `.link-button` 6/6 + reduced motion, page shell 3/3, profile avatar 5/5, footer 5/5, identity, the seven Enlaces, metadata 14/14 with the 3 expected `[warn]`.
  - New `Avatar fallback checks:`: `[ok] avatar fallback markup`, `[ok] .profile-avatar-frame rule exists`, `[ok] profile avatar frame contract (3/3)`, `[ok] avatar fallback stacking`, `[ok] .profile-avatar-fallback rule exists`, `[ok] avatar fallback contract (10/10)`, `[ok] avatar fallback activation`.
  - `Serving command` and `RUN_SERVE_COMMAND` still use port 3301; `init.sh` diff is additions only (`149/0`), so no prior check was removed, reordered or weakened.

### Independent negative cases

Fourteen runs on temporary copies outside the repository; the copies were deleted afterwards. Every mutation exited `1`, printed the specific failing element/declaration on stderr and left 3411/3301 without a listener. A clean control copy exited `0`.

1. `onerror` removed -> `FAILED - .profile markup missing avatar fallback element: onerror=...` + `avatar fallback markup is missing 1 of 5 required elements`.
2. Fallback `<span>` removed -> missing `class="profile-avatar-fallback"`, `>FH</span>` and `aria-hidden="true"`; `missing 3 of 5`.
3. `FH` changed to `FE` -> missing `>FH</span>`; `missing 1 of 5`.
4. `aria-hidden="true"` removed from the fallback -> missing `aria-hidden="true"`; `missing 1 of 5`.
5. `.profile-avatar-frame` rule renamed -> `styles.css is missing the .profile-avatar-frame base rule`.
6. Frame width `88px` changed to `87px` -> missing `width: 88px;` + `profile avatar frame contract is missing 1 of 3 required declarations`.
7. `grid-area: 1 / 1;` stacking rule removed -> `styles.css is missing the avatar fallback stacking rule grid-area: 1 / 1;`.
8. Fallback background changed to `var(--color-surface)` -> missing `background-color: var(--color-surface-container-low);` + `avatar fallback contract is missing 1 of 10 required declarations`.
9. Fallback color changed to `var(--color-on-surface)` -> missing `color: var(--color-primary);` + `missing 1 of 10`.
10. `opacity: 0;` activation removed -> `styles.css is missing the avatar fallback activation rules (opacity: 0; and display: flex;)`.
11. `display: flex;` activation removed -> same activation failure.
12. `object-fit: cover;` removed (prior check regression) -> `FAILED - .profile-avatar base rule missing declaration: object-fit: cover;` + `profile avatar contract is missing 1 of 5`.
13. `assets/avatar.jpg` emptied -> `Harness status: FAILED - assets/avatar.jpg is missing or empty`.
14. Clean control -> exit `0` with the fallback checks `[ok]`.

### Static and scope audit

- `:root` still has exactly 51 custom properties; component-internal `--link-button-*` variables are outside `:root` and unchanged.
- Token values used by the fallback are exact: `--color-surface-container-low: #f1f4fa` and `--color-primary: #484dc4`; `--color-surface: #ffffff`; `--radius-full: 9999px`; `headline-lg` 26px/600/34px/-0.02em.
- `assets/avatar.jpg` is byte-identical to `HEAD` (`b73575ae31cee7ead9de09377d90b60d3cbf2079402602c217a47f02afe4aa7c`); `assets/avatar.jpg.bak` is absent.
- No `<script>` elements, JS files, `package.json`, frameworks, bundlers or dependencies; the only JavaScript is the static inline `onerror` attribute authorized by `docs/technical-discovery.md`.
- No new tokens, roles, `aria-label`, additional visible text beyond the required `FH`, or controls; `DESIGN.md` unchanged; the temporary link-button demo and all accepted rules are untouched (diff additions only in `index.html`/`styles.css` for this feature).
- `git diff --check` -> clean; `git status` shows only `PROGRESS.md`, `feature_list.json`, `index.html`, `init.sh`, `styles.css` and the planner spec as changes.
- `feature_list.json` is valid JSON; only `avatar-fallback` changed (`not_started` -> `passing`) with evidence; the durable evidence matches the reproduced behavior.

### Browser: normal state, 390x844

Single server `python3 -m http.server 3411 --directory .` (own process, stopped; 3411 free afterwards), fresh isolated browser context, cache-bypassing reload.

- Console: **0 messages**.
- Network: 5/5 requests successful (`/`, Google Fonts CSS, `styles.css`, `assets/avatar.jpg`, WOFF2), all `200`/`304`-class, **no `/favicon.ico`**, no failures.
- Avatar: 88x88 at `x=151`, centered on the card (`frameCenterX = cardCenterX = 195`), `complete=true`, `naturalWidth/Height=460`, `object-fit: cover`, `border-radius: 9999px`, `box-shadow: rgb(255, 255, 255) 0px 0px 0px 3px`.
- Fallback computed `display: none`; `.profile` height 160, `.profile-identity` top 185, card 358px wide; `scrollWidth == clientWidth == 390` for document and body.
- Accessibility snapshot: one `image "Retrato de Fahed Hermoza"`; `FH` is not exposed.

### Browser: normal state, 1280x800

- Console: **0 messages**.
- Network: 5/5 successful, no `/favicon.ico`, no failures.
- Card 400px at `x=432.5` (1265px content width due to the classic 15px vertical scrollbar), frame/avatar 88x88 at `x=588.5`, center 632.5 = card center; same image contract and white halo; fallback `display: none`.
- `.profile` height 160, identity top 185; `scrollWidth == clientWidth == 1265` (no horizontal scroll).
- Accessibility snapshot: `image "Retrato de Fahed Hermoza"`; no `FH`.

### Browser: simulated failure, 390x844

`assets/avatar.jpg` renamed to `.bak`; fresh isolated context and cache-bypassing reload.

- Console: exactly **one resource error** for the missing image (`Failed to load resource: 404`), **no JavaScript errors**.
- Network: 5 requests, exactly **one `404` for `/assets/avatar.jpg`**, the other four `2xx`, no `/favicon.ico`, no other failures.
- Frame and fallback 88x88 at the same `x=151, y=61` as the image; fallback `display: flex`, text `FH`, `background-color: rgb(241, 244, 250)`, `color: rgb(72, 77, 196)`, `border-radius: 9999px`, `box-shadow: rgb(255, 255, 255) 0px 0px 0px 3px`, `align-items/justify-content: center`, 26px/600/34px.
- Image remains in the DOM with `opacity: 0`, `complete=true`, `naturalWidth=0`, `display: block`.
- Layout identical to normal: card 358px, `.profile` height 160, identity top 185, frame rect 88x88 at x=151; `scrollWidth == clientWidth == 390`.
- Accessibility snapshot retains `image "Retrato de Fahed Hermoza"` and does not expose `FH` (fallback `aria-hidden="true"`).

### Browser: simulated failure, 1280x800

- Console: exactly **one resource error** (the expected 404), no JavaScript errors.
- Network: 5 requests, exactly one `404` for `/assets/avatar.jpg`, no `/favicon.ico`, no other failures.
- Frame/fallback 88x88 at `x=588.5, y=61`, center 632.5 = card center; same `FH`, colors, radius, halo and centering; image `opacity: 0`.
- Layout identical to normal: card 400px, `.profile` height 160, identity top 185, `scrollWidth == clientWidth == 1265` (no horizontal scroll).
- Accessibility snapshot retains the image name and does not expose `FH`.

### Restoration

- `assets/avatar.jpg` restored by `mv`; `.bak` absent; SHA-256 `b73575ae31cee7ead9de09377d90b60d3cbf2079402602c217a47f02afe4aa7c` (identical to the initial value).
- Cache-bypassing reload in both viewports: avatar `complete=true`, `naturalWidth=460`, `opacity: 1`, fallback `display: none`, frame class no longer `--fallback`, console **0 messages**, network 5/5 `200`, card/profile/identity geometry identical; `./init.sh` exits `0` again.

### Layout shift comparison

| Viewport | State | `.profile` height | Identity top | Card width | Frame rect | Horizontal scroll |
| --- | --- | --- | --- | --- | --- | --- |
| 390x844 | normal | 160 | 185 | 358 | 88x88 @ x=151,y=61 | none |
| 390x844 | failure | 160 | 185 | 358 | fallback 88x88 @ x=151,y=61 | none |
| 1280x800 | normal | 160 | 185 | 400 | 88x88 @ x=588.5,y=61 | none (content 1265) |
| 1280x800 | failure | 160 | 185 | 400 | fallback 88x88 @ x=588.5,y=61 | none (content 1265) |

## Findings

### Critical / High / Medium

None.

### Low (non-blocking)

1. **Durable state header is stale/inconsistent (pre-existing).** `PROGRESS.md:5` still names the main repository root/`feature/link-celular`, and `PROGRESS.md:7` says the standard verification server is on 3201 while `init.sh:1083-1087` uses 3301. This predates the feature and does not contradict the new evidence, but the orchestrator should refresh the header when persisting acceptance.
2. **The harness matches text, not structure.** `init.sh:260-280` checks the five strings inside `.profile`; it does not assert that the image is a child of the frame or that `aria-hidden` belongs to the fallback span. `init.sh:346-358` checks 10 declarations but not `align-items`/`justify-content`, which actually center `FH`. Browser and accessibility evidence cover these behaviors; the gate is still an effective regression net for the specified mutations.
3. **Fallback depends on inline JavaScript.** Without JS (or under a future CSP disallowing inline handlers) a broken image with `alt` is shown; this is the documented accepted degradation/non-goal, and the migration path to a minimal `addEventListener` script is already recorded in the spec.
4. **Expected console noise in the failure simulation.** The browser logs one resource error for the intentional 404. It is not a JavaScript error and is explicitly allowed by Scenario 7; the normal and restored states have zero console messages.

## Security Assessment

No new attack surface: static content, no user input, no network calls from product code, no secrets. The only script is a static inline `onerror` with `classList.add` on a fixed class, no `eval`, DOM injection, storage or cross-origin behavior. There is no CSP in the site; the spec documents the future CSP migration. No blocking security issues.

## Documentation And Handoff

- `feature_list.json` is `passing` (not `accepted`) with truthful evidence and only this feature changed.
- `PROGRESS.md` has the Session 040 record and the updated status/next-step lines.
- The spec is present; no unnecessary durable docs were added. The only remaining documentation issue is the pre-existing stale header noted above.
- No persistent E2E harness exists and adding one would require prohibited dependencies; the spec explains this and the reproducible browser/gate evidence is the substitute.
- Recommended next step: orchestrator sets `avatar-fallback` to `accepted`, appends the acceptance evidence, refreshes the `PROGRESS.md` header, and commits only this feature's files (validation record included) without pushing.
