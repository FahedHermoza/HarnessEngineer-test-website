# Conflict Playbook

Repo-specific rules for resolving `feature/*` rebases onto `demo/seed` in this static Tarjeta digital.

## General Principles

- Resolve for the union of both sides: the base's already-merged features plus the incoming feature.
- Never drop an accepted feature, its evidence or its harness checks.
- Prefer the base structure when the incoming branch created a parallel container or duplicate rule.
- Append the incoming feature's content; do not reorder unrelated content unless the spec explicitly owns that ordering.
- After resolving, remove every conflict marker and run `bash -n init.sh` + `./init.sh`.

## `index.html`

Expected order inside `article.card`:

1. `header.profile` (avatar)
2. `header.profile-identity`
3. `nav.links` (real Enlaces)
4. `section#link-button-demo` (temporary demo)
5. `footer.page-footer`

Rules:

- There must be exactly one `<nav class="links" aria-label="Enlaces de contacto">`.
- Merge all real Enlaces into that single nav.
- Append the incoming Enlace after the existing ones. The final seven-link order belongs to `links-order-gradient`.
- Keep `link-button` classes, labels, hrefs, icons and `aria-label` values from each feature.
- Do not remove the temporary demo unless the feature explicitly owns its removal.
- Preserve `<link rel="icon" href="data:,">`, Open Graph/Twitter tags and all other `<head>` content.
- If an incoming branch closes `</nav>` before its own anchor and opens a second nav/section, remove the premature close and the second container; keep one nav.

## `styles.css`

- Keep exactly one `.links` rule. Prefer the base rule:
  - `display: flex;`
  - `flex-direction: column;`
  - `gap: var(--space-sm);`
  - `padding: 0 var(--space-lg);`
- Delete duplicate `.links` blocks from the incoming branch.
- Keep all component rules (`.link-button`, gradients, focus, reduced motion) and feature rules (`.profile*`, `.page-footer*`, metadata does not affect CSS).
- Do not add new tokens unless the feature spec requires it.

## `init.sh`

- Start from the base version (`git checkout --ours init.sh` during rebase) and append the incoming feature's checks before the serving command.
- Keep every prior gate: bootstrap, tokens, link button, page shell, avatar, footer, identity, metadata, Instagram/Facebook/WhatsApp/Portafolio/LinkedIn/Correo checks as applicable.
- Adapt incoming checks to the base markup:
  - Do not require an incoming branch-specific container such as `<section class="links" aria-label="Enlaces">`; the base uses `<nav class="links" aria-label="Enlaces de contacto">`.
  - Do not require a branch-specific `.links` padding such as `space-gutter`; the base uses `space-lg`.
- Scope per-anchor checks to that anchor with `awk`. Example: extract the Instagram anchor and check it has no gradient, instead of asserting the whole nav has no `link-button--gradient-*`.
- Do not assert that `class="link-button"` appears exactly once in the nav; several Enlaces legitimately use the base class. Check the specific anchor instead.
- Never weaken a check to make the build pass. If a check is structurally wrong after the merge, scope it correctly and document why.

## `feature_list.json`

- Keep all prior `accepted` features unchanged.
- Keep the incoming feature `accepted` with its validator evidence.
- Update `notes` only when conflict resolution changes behavior for that feature. Example: adding `display:flex` and `gap: var(--space-sm)` to `.links` while resolving a link PR should be noted as an early part of `links-order-gradient`.
- Ensure the file remains valid JSON: `python3 -c "import json; json.load(open('feature_list.json'))"`.

## `PROGRESS.md`

- Keep both sides' session logs.
- Incoming sessions often reuse numbers (for example two different `Session 019`). Renumber the incoming ones to the next free numbers and keep feature names in the headings.
- Update `Current Verified State` to the merged reality: repository root, branch, accepted features, next ready feature, blockers, inherited risks and last verification.
- Add a `Session NNN — rebase de <feature>` entry containing:
  - base branch/SHA,
  - conflicted files,
  - resolution decisions,
  - `./init.sh` result,
  - browser results.

## `docs/specs` and `docs/validations`

- Keep both sides' artifacts.
- If conflict resolution changes behavior from the incoming spec (for example `.links` padding or container element), add a short note to the spec or validation record.
- Do not rewrite historical validation evidence; append a conflict-resolution note.

## Validation Checklist

- `git grep -n '^<<<<<<<\|^=======\|^>>>>>>>'` returns nothing.
- `bash -n init.sh` passes.
- `./init.sh` exits `0`.
- `feature_list.json` is valid JSON and all previously accepted features remain `accepted`.
- Browser at `390×844` and `1280×800`: no console errors, no failed requests, no horizontal scroll.
- The feature's key DOM and geometry are still present.
- `git diff --check` is clean.
