# Validation Record: static-bootstrap

- Feature id: `static-bootstrap`
- Spec: `docs/specs/static-bootstrap.md`
- Validator: `feature-validator` (validator subagent, independent of implementer)
- Date: 2026-10-11
- Verdict: **accept**

## Review Target

- Implementation commit: `11e8c64` (`index.html` new, `init.sh` modified, `feature_list.json`, `PROGRESS.md`).
- Claimed status before validation: `passing` (implemented + self-verified, not accepted).
- Working tree clean; `index.html` and `init.sh` match HEAD content.

## Checks Ran And Observed Results

### Harness gate

- `bash -n init.sh` → syntax OK (exit 0).
- `./init.sh` → `Harness status: bootstrapped (static site detected)`, `[ok] lang="es"`, `[ok] non-empty <title>`, `[ok] viewport meta`, exit `0`. Printed the serving command and did **not** start a server.

### Negative tests (run in temp copy; repo untouched)

- Remove `lang="es"` → `FAILED - index.html is missing lang="es"`, exit `1`.
- Empty `<title></title>` → `FAILED - index.html is missing a non-empty <title>`, exit `1`.
- Remove viewport meta → `FAILED - index.html is missing the viewport meta tag`, exit `1`.
- Delete `index.html` → `Harness status: pre-bootstrap`, exit `1`.
- All failure messages emitted on stderr; no server started in any failure path.

### Serving check

- `python3 -m http.server 8099 --directory .` + `curl http://localhost:8099/` → HTTP 200, `content-type: text/html`, `size=250`.
- Served body `diff` vs `index.html` → identical.

### Structural checks (Python `html.parser`)

- `<!DOCTYPE html>` present, `<html lang="es">`, `<main>`…`</main>` present.
- No `<script>`, no `<style>`, no `<link>`.

### Not rerun

- Real-browser console/viewport check at 320/375/768px. No browser tooling in the environment. The document has zero scripts and zero CSS, so console errors and horizontal overflow are not possible in this slice (consistent with the spec's documented E2E justification).

## Findings

- Scope: clean — minimal skeleton only; no profile, links, vCard, footer, OG metadata, tokens, layout, JS, npm, or build tooling.
- Architecture: compliant — static HTML, no build/bundler/deps, output at repo root.
- Security: no relevant issues — no secrets, input, JS, external calls, or auth surface.
- Harness: compliant — checks run, non-zero exit on failure, serve mode is opt-in only.
- Durable docs: `feature_list.json` and `PROGRESS.md` reflect actual state.

### Low-severity notes (non-blocking)

1. `init.sh` validates structure with `grep` rather than a parser (acceptable for a minimal gate).
2. `PROGRESS.md` root path referenced the main checkout rather than the worktree (fixed during acceptance).
3. Spec task/checklist checkboxes were left unchecked while the work is done (cosmetic).
4. Pre-existing repo hygiene: tracked `.DS_Store` files and no `.gitignore` (not introduced by this feature).

## Verdict Rationale

All acceptance scenarios pass on rerun, scope is clean, harness gate compliant, no critical/high/medium findings. Accepted.
