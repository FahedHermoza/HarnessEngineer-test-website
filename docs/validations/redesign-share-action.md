# Validation: redesign-share-action

- Date: 2026-11-23
- Validator: independent `feature-validator` execution
- Spec: `docs/specs/redesign-share-action.md`
- Worktree: `feature/redesign-share-action`
- Input status: `passing`
- Verdict: `accept` (technical). The sole remaining gates are the spec's external
  conditions — physical-device Web Share testing and the owner's dated visual
  approval (mobile + desktop) — which the orchestrator collects separately and
  which are NOT technical defects.
- Recommended status: keep `passing` until the owner's visual approval and
  device test are recorded, then `accepted`. No product change is required.

## Verdict Basis

The implementation satisfies the spec. Exactly one `<button type="button"
class="quick-action quick-action--share" aria-label="Compartir esta tarjeta"
hidden>` is the third control in `<nav class="quick-actions">`, after Correo;
it carries no `href`, no `role`, no inline handler, and a decorative SVG
(`aria-hidden="true" focusable="false"`). `share.js` (the site's first script,
51 lines, no deps) detects `navigator.share`/`navigator.clipboard.writeText`
support, reveals the button only when at least one exists, reads the share
URL exclusively from `link[rel="canonical"]` (never `location.href`, never
query params), and implements all four behavioral branches correctly,
including silently swallowing `AbortError` with no fallback. Progressive
enhancement is real and verified at the CSS layer (`.quick-action[hidden],
.share-status[hidden] { display: none; }` overrides the higher-specificity
`.quick-action { display: flex }`), not just the HTML `hidden` attribute.
`CONSTRAINTS.md` and `init.sh` were adapted explicitly (semantic `<button>`
allowed for in-page controls, SVG 11→12, `<script>`/Blob prohibition narrowed
to the `.save-contact` block, canonical-URL rule pinned) without weakening any
existing anchor/focus/reduced-motion/contrast/tap-target/production-metadata/
vCard gate. `DESIGN.md`'s only diff is the pre-approved
"Compartir — decisión de diseño aprobada (redesign-share-action, 2026-11-23)"
section plus the reconciled `redesign-contact-navigation` subsection; no other
line changed, and the implemented confirmation/error colors
(`--color-accent`/`--color-error`), `body-sm` typography, and neutral
`.quick-action` treatment match it exactly. vCard mechanism, Celular/Correo,
the five Enlaces, header and footer are byte-identical (confirmed by `git
diff index.html` showing only additive `+` lines for the Share button, the
`.share-status` region and the `<script>` tag — zero removed/modified lines).

## Checks Rerun (reproduced evidence)

### Gate — `bash -n init.sh && ./init.sh`
- `bash -n init.sh` → exit 0 (no syntax errors).
- `./init.sh` → exit 0, `Harness status: bootstrapped`, no server started
  (only prints the opt-in `Serving command:` hint on 3601). Key lines
  reproduced:
  - `Share action checks:` with all 6 `[ok]` lines: share button markup
    (`type="button"`, `aria-label`, `hidden`, no href/role/inline handler),
    sits after Correo as the third quick action, decorative icon, share
    status region markup (`role=status`, `aria-live=polite`, hidden by
    default), progressive enhancement (hidden by CSS, revealed only by
    `share.js`), canonical-URL usage (never `location.href`/test params).
  - `[ok] 9 real anchor controls (5 link buttons + 2 quick actions + 1 save
    contact button + 1 footer link)` — unchanged (the real pre-existing
    baseline is 9, not 10 as the spec assumed when planned; `CONSTRAINTS.md`
    correctly documents this).
  - `[ok] 12 decorative SVG icons are hidden from assistive technology`
    (11→12, the Share icon).
  - `Accessibility checks:` (15/15 contrast, visible focus, reduced motion)
    and `Responsive checks:` sections both intact.

### Negative mutations (temp copies outside the repo via `rsync`, no listener on 3630/3601) — all exit 1 with specific stderr
| # | Mutation | Result |
|---|----------|--------|
| A | Remove the Share button entirely | exit 1 — "must contain exactly one Share button (...), found 0" |
| B | Add `role="button"` on the Share button | exit 1 — "Share button must not use a role attribute" |
| C | Add `onclick="shareCard()"` inline on the Share button | exit 1 — "Share button must not use inline event handlers; bind with addEventListener in share.js" |
| D | `share.js`: `url = location.href` instead of canonical | exit 1 — "share.js must not use location.href as the share URL; it must read link[rel=\"canonical\"]" |
| E | Remove the `.quick-action[hidden], .share-status[hidden] { display: none; }` CSS rule | exit 1 — "styles.css must explicitly hide .quick-action[hidden] and .share-status[hidden] with display: none;" |
| F | Inject `<script>` inside the `.save-contact` anchor block | exit 1 — "the save contact control must not use data:text/vcard, <script> or Blob" |
| G | Remove `aria-hidden="true"` from the Share button's decorative SVG | exit 1 — "Share button icon is missing aria-hidden=\"true\"" |

No mutation started a server. All temp copies were deleted after use; `3630`
and `3601` confirmed free before and after.

### Browser (real Chrome via `puppeteer-core` CDP against `http://localhost:3630/`, own server, stopped after)
Branches mocked by overriding `navigator.share`/`navigator.clipboard` as own
properties (and deleting the inherited `Navigator.prototype.share` to
simulate true absence, since headless Chrome exposes a native `share`
function on the prototype that a plain `delete navigator.share` on the
instance does not remove):
- **Available:** `navigator.share({title, url})` invoked with
  `https://fahed-hermoza-card.fahedhermoza.workers.dev/`; console 0; status
  region stays hidden (no confirmation needed on native-sheet success).
- **Absent + clipboard:** `clipboard.writeText` called with the canonical
  URL; `.share-status` becomes visible with text "Enlace copiado." and class
  `share-status--success`; console 0.
- **Cancelled (`AbortError`):** no status shown, no clipboard fallback
  invoked, console 0 — `AbortError` swallowed silently as required.
- **Clipboard denied (`NotAllowedError`):** `.share-status` shows "No se
  pudo copiar el enlace. Cópialo manualmente: https://fahed-hermoza-card...
  workers.dev/" with class `share-status--error`; console 0.
- **No support (both removed):** button stays `hidden`, `display: none`,
  0×0 rect, not reachable via 15 `Tab` presses; console 0.
- Accessible name: `aria-label="Compartir esta tarjeta"` reported.
- `:focus-visible` via real `Tab` navigation: `outline: rgb(88, 92, 229)
  solid 2px`, `outline-offset: 2px` (the `--color-accent` token).
- `prefers-reduced-motion: reduce` emulated: `transition: none`,
  `transform: none` (inherited from `.quick-action`).
- 1280×800: tap target 48×48, canonical URL correct, no horizontal scroll.
- Eight-width matrix (320, 360, 375, 390, 480, 736, 768, 1280), each
  triggering the long clipboard-denied error message (worst-case text
  length, includes the full canonical URL): `scrollWidth === clientWidth`
  at every width, Share button stays 48×48, no overflow.
- 0 failed requests and 0 console messages across every run.

### Lighthouse
Not independently rerun this session (no `lighthouse`/Chrome Launcher CLI
available in this environment); relying on the implementer's recorded
Accessibility = 100 result, cross-checked against this session's own focus,
contrast-token-reuse, and accessible-name findings above, all of which are
consistent with that score.

## Scope / Security / Docs
- Scope: `git diff index.html` contains zero removed/modified lines — only
  additions (the Share button + icon, `.share-status` region, `<script
  src="share.js" defer>`). vCard mechanism, Celular/Correo destinations, the
  five Enlaces, header and footer are untouched. No QR panel, no second
  Compartir action in the header, no `role="button"`, no inline handlers,
  no new tokens/colors/fonts/frameworks/dependencies. `DESIGN.md` diff
  (`git diff --stat -- DESIGN.md`, 30 lines) is exactly the pre-approved
  "Compartir — decisión de diseño aprobada" section plus the reconciled
  `redesign-contact-navigation` note; nothing else changed.
- Security: static site, one new same-origin script with no external
  network calls, no user-supplied input, no secrets; it reads a static
  canonical `<link>` value and calls only `navigator.share`/
  `navigator.clipboard.writeText`. No injection, auth, or data-exposure
  surface introduced.
- Docs: `CONSTRAINTS.md` re-expressed consistently (9 anchors unchanged, 12
  decorative SVGs, `<script>`/Blob prohibition narrowed to `.save-contact`,
  semantic `<button>` rule added, canonical-URL rule pinned) with no stale
  counts remaining anywhere in the file. `docs/technical-discovery.md`
  documents `share.js` as the first script and its strict scope.
  `docs/risks-and-open-questions.md` was not updated with the pending
  device-test/owner-approval note (the spec marked this update as
  conditional, "si procede," and the same information is already recorded
  honestly in `feature_list.json` evidence and `PROGRESS.md`) — Low,
  non-blocking.

## Remaining External Conditions (not defects)
- Real physical-device Web Share testing (actual Android/iOS native share
  sheet) was not performed; all four branches were verified by mocking
  `navigator.share`/`navigator.clipboard` in Chrome via CDP on `localhost`
  (a secure context), declared honestly per the spec's own allowance.
- Owner visual approval (mobile + desktop) is `pending` and must be
  collected by the orchestrator before status flips to `accepted`.

## Owner Final Acceptance (2026-11-23)

Both external conditions above are now closed:

1. **Real-device Web Share test**: Fahed Hermoza confirmed in chat that he tested the
   Compartir button on a real physical device and the native share sheet opens correctly
   with the canonical URL.
2. **Owner's dated visual review**: Fahed Hermoza reviewed fresh renders of the live page
   (isolated server, port 3630) in both required viewports, both idle and confirmed-state
   (clipboard-fallback success message), and approved the feature as a whole in chat.
   Screenshots captured via Chrome DevTools MCP (`take_screenshot`, `fullPage: true`) and
   committed as durable evidence:
   - `docs/validations/redesign-share-action-owner-approval-mobile-closed.png` — 390×844.
   - `docs/validations/redesign-share-action-owner-approval-mobile-confirmed.png` — 390×844, "Enlace copiado." visible.
   - `docs/validations/redesign-share-action-owner-approval-desktop-closed.png` — 1280×800.
   - `docs/validations/redesign-share-action-owner-approval-desktop-confirmed.png` — 1280×800, confirmation visible.

   Note on how the confirmed-state screenshots were produced: a real `navigator.share()`
   call never settles in this headless/CDP-automated Chrome (there is no OS share surface
   to resolve it), so capturing the on-page confirmation required simulating the
   no-native-Share-API branch (`navigator.share` undefined via `initScript`, real
   `navigator.clipboard` intact) to exercise the clipboard-copy fallback path exactly as
   written in `share.js`. The native-share path itself was validated on the owner's real
   device per point 1, not by screenshot.

With both conditions closed, the feature moves from `passing` to `accepted`.
