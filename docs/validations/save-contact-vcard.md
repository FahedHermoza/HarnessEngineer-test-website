# Validation Record: save-contact-vcard

- Feature id: `save-contact-vcard`
- Spec: `docs/specs/save-contact-vcard.md`
- Validator: `feature-validator` (independent validator, not the implementer)
- Date: 2026-10-23
- Verdict: **accept**
- Recommended state update: orchestrator may set `save-contact-vcard` from `passing` to `accepted` and append concise acceptance evidence.

## Review Target

- Claimed status before this validation: `passing` (not `accepted`); `docs/validations/save-contact-vcard.md` did not exist.
- Changed files reviewed: `assets/fahedhermoza.vcf` (new), `index.html`, `styles.css`, `init.sh`, `CONSTRAINTS.md`, `DESIGN.md`, `docs/technical-discovery.md`, `docs/risks-and-open-questions.md`, `feature_list.json`, `PROGRESS.md`; planner spec `docs/specs/save-contact-vcard.md`.
- `feature_list.json` changes only the `save-contact-vcard` object (`not_started` -> `passing`); no other feature status changed.
- Product diff: only the new static vCard, the `.save-contact` block between `</nav>` and `footer.page-footer`, the neutral `.save-contact-button` component plus focus/hover/reduced-motion states, the `Save contact checks:` gate, and the count/contrast updates required by the spec. The seven Enlaces, their order/tones/URLs/icons, profile, footer, metadata and page shell are untouched.
- Repository was not modified by the validator except for this required validation record. No commit, push or product fix was made.

## Checks Ran And Observed Results

### Harness gate

- `bash -n init.sh` -> exit `0`.
- `./init.sh` -> exit `0` without starting a server:
  - `Harness status: bootstrapped (static site detected)`.
  - 97 `[ok]` and the 3 pre-existing metadata `[warn]` (og-image/relative URL/canonical), no failures.
  - `Save contact checks:` all `[ok]`: vCard asset contract (390 bytes), URL/phone/email coherence, markup/label/icon/static `href`+`download`, position between `</nav>` and the footer, layout rule, button shape 6/6, neutral colors, focus outline, hover/focus brightness and reduced motion.
  - `Accessibility checks:` `[ok]` for document/zoom, Tagline `lang="en"`, avatar alt, **10 real anchor controls (7 link buttons + 1 save contact button + 2 footer links)**, **8 decorative SVG icons** + separator, visible focus, reduced motion, contrast tokens **8/8**, calculated contrast **15/15** (including `primary on surface-container-low (rest) = 6.082:1` and `(hover/focus) = 6.456:1`), and link-button wiring.
  - Serving hint remains `python3 -m http.server 3413 --directory .` and `RUN_SERVE_COMMAND=1`; no listener on 3413 after the gate.
- Removed-line audit of `init.sh`: only the obsolete 9/7 counts, the old messages, the old `.link-button`-only reduced-motion failure text and the 13/13 threshold were replaced. No prior check was removed, weakened or reordered.
- `feature_list.json` parses as valid JSON (21 entries); `git diff --check` clean; `:root` still has **51** custom properties; 0 `<script>`, no `package.json`, lockfiles, `node_modules`, frameworks, bundlers, dependencies or new tokens.

### vCard asset contract

- `wc -c` -> **390 bytes** (<= 4096); `file` -> `vCard visiting card, version 3.0`.
- Bytes: no UTF-8 BOM (`42 45 47`), **0 bare LF**, **0 bare CR**, ends with `END:VCARD\r\n`.
- Exact canonical lines in order: `BEGIN:VCARD`, `VERSION:3.0`, `N:Hermoza;Fahed;;;`, `FN:Fahed Hermoza`, `TITLE:Software Engineer & Speaker & Builder`, `TEL;TYPE=CELL:+51955116562`, `EMAIL;TYPE=INTERNET:fahedhermoza@gmail.com`, the five external `URL:` lines (Instagram, Facebook, `wa.me`, LinkedIn, portfolio) and `END:VCARD`; literal `&`; no `PHOTO`/`ORG`/`REV`/`UID`.
- Served on the validation server: `curl -sI http://localhost:3501/assets/fahedhermoza.vcf` -> `200`, `Content-Type: text/x-vcard`, `Content-Length: 390`. The served body is byte-identical to the asset (SHA-256 `910aa368ce17363d4dca7833cc1fcff644ebd284ba7e160873c9f757f9f80371` both sides), no BOM, CRLF-only, five `URL:`.

### Independent negative cases

Nine temporary copies outside the repository, each with one deliberate mutation; every run exited `1` with a concrete stderr message and no listener on 3501 or 3413:

1. `.vcf` deleted -> `FAILED - assets/fahedhermoza.vcf is missing or empty`.
2. CRLF converted to LF -> `FAILED - assets/fahedhermoza.vcf must use CRLF line endings only`.
3. vCard portfolio URL altered -> `FAILED - assets/fahedhermoza.vcf is missing canonical line: URL:https://fahedhermoza.github.io/`.
4. `download="fahedhermoza.vcf"` removed -> `FAILED - index.html .save-contact-button must use href="assets/fahedhermoza.vcf" and download="fahedhermoza.vcf"`.
5. `href` changed to `assets/otro.vcf` -> same static href/download failure.
6. `.save-contact` block moved after the footer -> `FAILED - index.html .save-contact must sit after </nav> and before <footer class="page-footer">`.
7. `outline`/`outline-offset` removed from `.save-contact-button:focus-visible` -> `FAILED - styles.css .save-contact-button:focus-visible must declare outline: 2px solid var(--color-accent); and outline-offset: 2px;`.
8. Both `.save-contact-button` rules removed from the reduced-motion block -> `FAILED - styles.css reduced-motion block must set transition: none; and transform: none; for .save-contact-button`.
9. `--color-surface-container-low` changed `#f1f4fa` -> `#ffffff` -> `FAILED - styles.css token --color-surface-container-low must be #f1f4fa (found #ffffff)` + `FAILED - accessibility contrast tokens are missing 1 of 8 required values`.

Temporary copies were removed afterwards; the repository was not altered.

### Browser: 390x844 mobile

Served only by `python3 -m http.server 3501 --directory .` (own process, stopped afterwards; 3501 free before and after; 3413/3502 never used). Fresh load with cache ignored:

- Console: **0 messages**.
- Page network: 5 requests (`/` 304, Google Fonts CSS 200, `styles.css` 304, `assets/avatar.jpg` 304, WOFF2 200); no `/favicon.ico`, no failed page requests.
- `scrollWidth === clientWidth === 390`; card `358x901` at `x=16`.
- Card children in order: `HEADER.profile` -> `HEADER.profile-identity` -> `NAV.links` -> `DIV.save-contact` -> `FOOTER.page-footer`.
- 10 anchors (7 `.link-button` + 1 `.save-contact-button` + 2 `.page-footer__link`) and 8 SVG icons, all 8 with `aria-hidden="true"`/`focusable="false"`.
- Button: `308x48` at `x=41`, exactly `12px` below the last Enlace; `background rgb(241, 244, 250)`, `color rgb(72, 77, 196)`, `background-image: none`, 11px/800/16px, tracking `1.98px`, uppercase, `border-radius: 6px`, padding `0 20px`, base shadow `rgba(25, 30, 48, 0.08) 0px 2px 6px 0px`; icon `18x18` 20px from the right edge; attributes only `class`, `href`, `download` (no inline handler).
- `href="assets/fahedhermoza.vcf"`, `download="fahedhermoza.vcf"`, visible label `Guardar contacto` (accessible name `GUARDAR CONTACTO` from the CSS uppercase transform), `<a>` is a real control.
- `Tab` traversal: Instagram -> Facebook -> WhatsApp -> LinkedIn -> Portafolio -> Correo -> Celular -> Guardar contacto -> footer email -> footer handle; all 10 entries `:focus-visible` with `outline: solid 2px rgb(88, 92, 229)` and offset `2px`.
- Real click on the button produced `GET /assets/fahedhermoza.vcf` -> 200 in the server log.
- `prefers-reduced-motion: reduce`: `transition-property: none`, `transition-duration: 0s`, `transform: none`, outline still visible, `document.getAnimations()` empty.

### Browser: 1280x800 desktop

Fresh cache-bypassing load on the same server:

- Console: **0 messages**.
- Page network: 5/5 `200` (`/`, Google Fonts CSS, `styles.css`, `assets/avatar.jpg`, WOFF2); no `/favicon.ico`, no failures.
- `scrollWidth === clientWidth === 1265` due to the classic 15px vertical scrollbar; no horizontal overflow.
- Card `400px` at `x=432.5`; button `350x48` at `x=457.5`, exactly `12px` below the last Enlace; same neutral colors/typography/icon; base transform/filter `none`.
- Real hover: `transform: matrix(1, 0, 0, 1, 0, -1.5)`, `box-shadow: rgba(25, 30, 48, 0.12) 0px 8px 18px 0px`, `filter: brightness(1.03)`, transition `0.18s`.
- `prefers-reduced-motion: reduce`: `transition-property: none`, `transition-duration: 0s`, `transform: none`, focus outline `solid 2px rgb(88, 92, 229)` offset `2px`, no animations.

### Lighthouse mobile accessibility

`chrome-devtools_lighthouse_audit` (device `mobile`, mode `navigation`, `http://localhost:3501/`):

- **Accessibility 100**, no failing accessibility audit (therefore no `critical`/`serious`).
- Best Practices 100, Agentic Browsing 100, SEO 91; the only failed audit is `meta-description` (SEO, pre-existing and outside this feature).
- The server log's only 404s are Lighthouse probes (`/llms.txt`, `/robots.txt`, `/.well-known/ai-catalog.json`), not page resources.

## Findings

### Critical / High / Medium

**None.**

### Low, non-blocking notes

1. **Partial reduced-motion regression is not detected.** Deleting only `.save-contact-button { transition: none; }` still exits `0`, because the shared reduced-motion block still contains the `.save-contact-button` hover/focus selector and the `transition: none;`/`transform: none;` strings supplied by `.link-button`. Removing the save-contact reduced-motion rules entirely exits `1`, the browser confirms the real reduced-motion behavior, and this mirrors the pre-existing `.link-button` gate pattern; the spec asks for "presence in reduced motion". Harness-completeness note, not an observable defect.
2. **Minor durable-doc nits in `docs/technical-discovery.md`:** the negative-case list says "URL/fecha alterada" although the vCard intentionally has no date/`REV`, and the manual-serving line uses the standard hint `3413` while the vCard `curl` example uses `3501`. Behavior and the authoritative contract are correct.
3. The gate is textual/`awk`-based and checks the hover `filter` but not the exact hover `transform`/shadow values; those were verified in the browser. Consistent with the accepted harness style in earlier features.
4. Lighthouse's SEO `meta-description` failure (91) is pre-existing and outside the feature/spec scope.

No repair brief is required.

## Scope And Security Assessment

- Seven Enlaces (order, tone classes, destinations, icons), profile/avatar/identity, footer, metadata and page shell are unchanged (`index.html`/`styles.css` diffs are additions only in the relevant regions).
- `:root` remains at 51 tokens; the neutral button uses existing `--color-surface-container-low`/`--color-primary`; no new palette, font or dependency.
- No JavaScript added for this feature; no `data:text/vcard`, Blob, `<script>`, inline handler on the control, framework, bundler, network call, persistence or auth surface. The only page data added is the intentionally public contact card.
- Static same-origin download with `download` attribute; no user input, secrets, credentials, access-control boundary or new external endpoint.
- iOS/Android agenda import and the Cloudflare Pages MIME remain explicitly recorded as pending manual/deploy checks, not claimed as verified.

## Documentation And Handoff

- `CONSTRAINTS.md` now pins 10 anchors/8 SVG, the neutral focus/reduced-motion rules, the `#484dc4`/`#f1f4fa` contract and the vCard static-anchor contract.
- `DESIGN.md` documents the resolved neutral treatment, component shape/colors/icon/states and the 6.082/6.456 contrast row.
- `docs/risks-and-open-questions.md` closes the `.vcf` vs `data:` mechanism and keeps iOS/Android import and the Cloudflare MIME as pending manual/deploy checks.
- `feature_list.json` and `PROGRESS.md` match observed behavior, evidence and the `passing` (not `accepted`) state; no validator record existed before this one.
- `init.sh` remains non-blocking, fails with exit `1` on the tested regressions and does not start a server by default. No persistent E2E harness exists; adding one would require dependencies prohibited by `docs/technical-discovery.md`, and the spec accepts the harness + browser + Lighthouse approach.
- After the orchestrator persists acceptance, `save-contact-vcard` is complete; `responsive-baseline` remains the next feature in list order with its dependency now satisfied.
