# Validation: open-graph-metadata

- Feature: `open-graph-metadata`
- Validator: `feature-validator`
- Date: 2026-10-23
- Spec: `docs/specs/open-graph-metadata.md`
- Verdict: `accept`

## Scope Accepted

Metadata markup contract (`og:*` + `twitter:*`), `init.sh` gate, and no-regression verification. The real link unfurl (missing `assets/og-image.jpg`, relative images, absent `og:url`/canonical, and WhatsApp/Facebook preview) is explicitly deferred by the orchestrator to `deploy-cloudflare-pages`, as allowed by the spec Acceptance Criteria.

## Checks Reproduced

| Check | Result |
|---|---|
| `bash -n init.sh` | exit 0, no syntax errors |
| `./init.sh` | exit 0; bootstrap 3/3, tokens 51/51, component 6/6, reduced motion, page shell 3/3, `[ok] sharing metadata contract (14/14)`, 3 expected `[warn]`, no server started |
| Negative: remove `og:type` (temp copy outside repo) | exit 1, stderr names `og:type` + `missing 1 of 14 required tags` |
| Negative: remove `twitter:card` | exit 1, same pattern |
| Negative: `og:image:width` 1200 → 1000 | exit 1, same pattern |
| Extra: remove `og:image:alt` | exit 1, names `og:image:alt` |
| Extra: remove `og:image` | exit 1, names `og:image` |
| Extra: future absolute image URL | exit 0, contract 14/14, absolute-path `[ok]` |
| Broken metadata + `RUN_SERVE_COMMAND=1` | exit 1 before serve block; no listener |
| Static server 3204 (validator's process, stopped) | `/` 200 `text/html`, `styles.css` 200 `text/css`, `/assets/og-image.jpg` 404 (known blocker) |
| Served HTML | exactly 14 tags; no `og:url`, canonical, `meta name="description"`, JSON-LD, `example.com`, `theme-color`, `og:audio/video` |
| Browser 390×844 (fresh nav, cache bypass) | console 0 messages; 4 requests all 200 (`/`, Google Fonts CSS, `styles.css`, WOFF2); no `og-image`, no `/favicon.ico`; `.card` 358×362 at x=16; `scrollWidth == clientWidth == 390` |
| Browser 1280×800 (fresh nav, cache bypass) | console 0 messages; 4 requests all 200; no `og-image`/favicon; `.card` 400×362 at x=440; `scrollWidth == clientWidth == 1280` |
| Runtime metadata readback | `og:title === document.title`; `og:type=profile`; `og:image=assets/og-image.jpg`; 1200×630; `twitter:card=summary_large_image`; descriptions render `&`; `og:url`/canonical `null`; 0 `<script>` |
| Scope | only `PROGRESS.md`, `docs/risks-and-open-questions.md`, `feature_list.json`, `index.html`, `init.sh` modified plus the new spec; no `styles.css`, `DESIGN.md`, tokens, visible content, assets, JS, dependencies or build changes |
| Binaries | `assets/` still only `avatar.jpg` (SHA-256 unchanged); `assets/og-image.jpg` absent |
| Cleanup | validator's 3204 server stopped; pre-existing 3101 listener PID 49259 untouched |

## Findings

No Critical / High / Medium findings.

### Low 1 — Presence-based gate over the whole document

The gate verifies presence/values via `grep`, not uniqueness or placement in `<head>`; a future duplicate or out-of-head tag could pass. This matches the spec's prescribed simple regex checks and requires no change.

### Low 2 — Temp copies not deletable

Negative-case copies under the sandbox temp path could not be removed due to external-directory policy. They are outside the worktree and contain no product changes.

## Deferred Blockers

1. `assets/og-image.jpg` (JPEG 1200×630) is absent and must be produced externally; no binary was created, reused, resized or substituted.
2. Public Cloudflare Pages URL is undefined; `og:url` and `<link rel="canonical">` are omitted and `og:image`/`twitter:image` remain relative provisional paths.
3. Real unfurl validation (WhatsApp/Facebook) closes in `deploy-cloudflare-pages` after producing the image, absolutizing image URLs, and adding `og:url`/canonical.
