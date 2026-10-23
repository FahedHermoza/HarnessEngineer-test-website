# Validation Record: link-celular

- Feature id: `link-celular`
- Spec: `docs/specs/link-celular.md`
- Validator: `feature-validator` (independent validator, not the implementer)
- Date: 2026-10-23
- Verdict: **accept**
- Recommended state update: orchestrator may set `link-celular` from `passing` to `accepted` and append concise acceptance evidence.

## Review Target

- Claimed status before this validation: `passing` (not `accepted`).
- Changed files reviewed: `index.html`, `styles.css`, `init.sh`, `feature_list.json`, `PROGRESS.md`; planner spec `docs/specs/link-celular.md`.
- `feature_list.json` diff changes only the `link-celular` object (`not_started` -> `passing`); no other feature status changed.
- The product diff adds only the Celular link block, the `.links` gutter rule, the five harness checks and the 3307 port change; plus the durable evidence.
- Repository was not modified by the validator except for this required validation record. No commit, push, or product fix was made.

## Checks Ran And Observed Results

### Harness gate

- `bash -n init.sh` -> exit `0`.
- `./init.sh` -> exit `0`, no server started (port 3307 had no listener before and after the run):
  - `Harness status: bootstrapped (static site detected)`
  - Bootstrap checks `[ok]` x3; `[ok] design tokens present (51/51)`.
  - Component checks `[ok]` (`.link-button`, contract 6/6, reduced motion).
  - Page shell checks `[ok]` x3; profile checks `[ok]` x4 (contract 5/5).
  - Page footer checks `[ok]` x5 (contract 5/5).
  - `Link checks:` with `[ok] celular link markup`, `[ok] celular link destination`, `[ok] celular link accessible label`, `[ok] .links base rule exists`, `[ok] links container contract (1/1)`.
  - Profile identity checks `[ok]` x14; sharing metadata `[ok] 14/14` plus the 3 expected `[warn]` (missing preview image/absolute URL/public URL).
  - `Serving command: python3 -m http.server 3307 --directory .`; `RUN_SERVE_COMMAND` also uses 3307.
- `init.sh` executes the checks itself, keeps every prior check, and does not start a long-running server by default.

### Independent negative cases

Six temporary copies outside the repository, each with one deliberate mutation; every run exited `1`, printed the expected stderr, and left port 3307 without a listener:

1. `class="links"` renamed -> `Harness status: FAILED - index.html is missing the Celular link markup`.
2. `tel:+51955116562` changed to `tel:+51955116563` -> `Harness status: FAILED - index.html is missing the Celular link destination tel:+51955116562`.
3. Anchor `aria-label` removed -> `Harness status: FAILED - index.html is missing the Celular link accessible label`.
4. Visible label changed to `Teléfono` -> `Harness status: FAILED - index.html is missing the Celular link markup`.
5. `.links` base rule removed -> `Harness status: FAILED - styles.css is missing the .links base rule`.
6. `padding: 0 var(--space-gutter);` removed from `.links` -> `FAILED - .links base rule missing declaration: padding: 0 var(--space-gutter);` + `Harness status: FAILED - links container contract is missing 1 of 1 required declarations`.

The temporary copies are in the session temp directory outside the repo; the sandbox denied deleting them, so they remain ephemeral temp artifacts only.

### Static and scope audit

- Only one product anchor exists: `<a class="link-button" href="tel:+51955116562" aria-label="Celular: llamar al +51 955 116 562">`, outside `[data-demo="link-button"]`; no tone modifier.
- `section.links[aria-label="Enlaces de contacto"]` is a child of `article.card`, after the demo section and before `footer.page-footer`.
- The inline phone SVG is 18x18, `stroke="currentColor"`, `aria-hidden="true"`, `focusable="false"`.
- `styles.css` adds only `.links { padding: 0 var(--space-gutter); }`; no `display`, `gap`, ordering, tone or gradient rules for the links list.
- `:root` still has exactly 51 unique custom properties; `body`, `.page`, `.card`, `.link-button` and the temporary demo CSS are unchanged.
- The demo section (five anchors), the footer, the profile blocks and the whole `<head>` are byte-identical to `HEAD`.
- No `<script>` element, `package.json`, framework, bundler, dependency, new asset or new product file; `assets/` contains only the unchanged `avatar.jpg`.
- `git diff --check` -> exit `0`.

### Browser: 390x844 mobile

Served only by `python3 -m http.server 3307 --directory .` (own process, stopped afterwards; port free). Fresh load:

- Console: **0 messages**.
- Network: 5 requests (`/`, Google Fonts CSS, `styles.css`, `assets/avatar.jpg`, WOFF2), all 2xx/3xx, **no `/favicon.ico`**, no failures.
- `section.links` is a child of `article.card` and not inside the demo; exactly 1 product anchor and the 5 demo anchors remain.
- `.links`: 356x48 at `x=17`, `padding: 0px 16px`.
- Product anchor: 324x48 at `x=33`; `display:flex`, `height:48px`, `box-sizing:border-box`, `padding:0px 20px`, `border-radius:6px`, `justify-content:space-between`, white text, 11px/800/16px, `letter-spacing:1.98px`, `text-transform:uppercase`, background `rgb(104, 118, 240)` (component default, no modifier).
- `href="tel:+51955116562"`; accessibility snapshot: `link "Celular: llamar al +51 955 116 562"` with visible text `CELULAR` included in the name (label-in-name holds case-insensitively).
- `scrollWidth == clientWidth == 390` for document and body (no horizontal scroll).

### Browser: 1280x800 desktop

Fresh cache-bypassing reload on the same single server:

- Console: **0 messages**.
- Network: 5 requests, all `200`; **no `/favicon.ico`**; no failures.
- Product anchor: 366x48, label on a single line, same component styles, href and accessible name.
- The page is taller than 800px (card 400x841), so this Chrome uses a classic 15px vertical scrollbar: `window.innerWidth=1280`, `documentElement.clientWidth=1265`, `scrollbarWidth=15`, `scrollWidth==clientWidth==1265` (no horizontal scroll).
- Consequently `.card` is at `x=432.5`, `.links` 398px at `x=433.5` and the anchor at `x=449.5` instead of the spec's `x=441/457`.
- Supplementary run at 1280x900 (same width, no vertical scrollbar): `clientWidth=1280`, `.links` 398px at `x=441`, anchor 366x48 at `x=457`, `scrollWidth=1280`. This confirms the 1280x800 offset is caused solely by the environment's classic scrollbar, not by the product geometry.
- The spec's `scrollWidth==clientWidth==1280` expectation assumes overlay scrollbars; the product was not changed to hide the vertical scrollbar.

### Hover, keyboard focus and reduced motion

- Real hover: `transform: matrix(1, 0, 0, 1, 0, -1.5)`, `box-shadow: rgba(108, 114, 234, 0.28) 0px 8px 18px 0px`, `filter: brightness(1.03)`, `transition-duration: 0.18s` with `ease`.
- Keyboard `Tab` traversal (sixth focus) lands on the product anchor: `:focus-visible=true`, outline `rgb(88, 92, 229) solid 2px` with `outline-offset: 2px`.
- `prefers-reduced-motion: reduce`: `transition-property: none`, `transition-duration: 0s`, `transform: none` under hover/focus, focus outline still visible 2px/offset 2px.
- `tel:` was never activated; the destination was only read from the DOM.

### Security assessment

Feature-scoped checklist applied to the diff: no secrets, auth/authz surface, user input, database, server/client boundary, file uploads, external service calls, or new dependencies. The only external references are the existing Google Fonts stylesheet and the fixed `tel:` destination. No Critical/High/Medium security finding; no relevant notes beyond the inherited font external dependency already documented in `docs/technical-discovery.md`.

## Findings

No Critical, High, or Medium findings. The implementation satisfies the acceptance scenarios and the harness/docs are consistent.

### Low: 1280x800 geometry deviates only because of a classic scrollbar

- Evidence: measured `clientWidth=1265` and `scrollbarWidth=15` at 1280x800; `.links x=433.5`, anchor `x=449.5`; at 1280x900 `clientWidth=1280`, `.links x=441`, anchor `x=457`.
- Why it matters: the spec's literal pixel expectation is environment-dependent.
- Required change: none for this feature; the product is centered correctly in the available width and has no horizontal scroll.
- Note for future specs: state the expected geometry in terms of `clientWidth`, or specify viewport height that avoids the scrollbar.

### Low: `init.sh` manual verification hint still names 320/375/768px

- Evidence: `Manual verification: open http://localhost:3307 in a mobile viewport (320/375/768px).`
- Why it matters: the project requires 390x844 and 1280x800 browser validation; the hint is stale after the port change.
- Required change: optional follow-up in a harness/docs feature; not blocking because the standard validation path in `PROGRESS.md` is correct.

### Low: harness checks are presence-based

- Evidence: the five new checks use `grep -qF` and an `awk` rule extractor; they do not prove that the class, href and aria-label belong to the same anchor or that the anchor is outside the demo.
- Why it matters: a future incorrect edit could satisfy some checks separately.
- Required change: none for this accepted slice; the spec prescribed this exact pattern and the browser/a11y checks covered the integration. Consider a more structural check when the full seven-link list lands.

### Low: mobile network recorded 304 for `/` and `styles.css` in this run

- Evidence: the implementation evidence records 5/5 `200`; independent mobile load returned 304 for the document and `styles.css`, while desktop with cache bypass returned 200.
- Why it matters: 304 is a successful revalidation, not a failed request; the evidence's "200" wording is slightly optimistic for a warm cache.
- Required change: none; no failed request occurred and the spec allows 2xx/3xx.

## Handoff

- `feature_list.json` and `PROGRESS.md` accurately describe the implemented behavior, six negative cases, browser evidence and the environmental scrollbar offset.
- After the orchestrator persists acceptance, the next ready features remain `avatar-fallback` and the six remaining Enlaces; `links-order-gradient` still owns ordering, spacing, tone progression and demo removal.
- Inherited risks unchanged: `.link-button` label contrast 3.86-4.13:1 and Tagline contrast ~4.43:1 belong to `accessibility-baseline`.
