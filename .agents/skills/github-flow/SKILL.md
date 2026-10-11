---
name: github-flow
description: Orchestrate the full GitHub round-trip for one or more features using git and gh, reusing feature-flow as the per-feature engine. Use when the user asks to run the GitHub flow, open an issue + branch + worktree + pull request for a feature, publish an accepted feature, work features in isolated worktrees in parallel, or move features from feature_list.json through issue, implementation, validation, and PR.
---

# GitHub Flow

Use this skill to wrap `feature-flow` with the repository's GitHub workflow: issue, isolated git worktree, an independent unattended session per feature, and a pull request against the base branch.

The main agent is the orchestrator. It never implements a feature itself; it prepares the GitHub surface for each feature, launches one independent session per feature, and publishes only accepted work.

## Hard Rules

- Reuse `feature-flow` as the per-feature engine. Do not re-implement its planner/implementer/validator logic here.
- One feature per branch, per worktree, and per session. Never run two features in the same session or worktree.
- Create each feature branch and worktree from the same resolved base SHA. Never stack feature worktrees on each other.
- Reuse before you act: if an issue, worktree, branch, or PR already exists for a feature, reuse it. Do not duplicate or delete existing work.
- No acceptance, no publish. Only a feature whose `feature_list.json` status is `accepted` may be pushed and opened as a PR.
- No permission, no push. Ask for explicit push/PR permission unless the user already granted it for this run.
- Merging is out of scope. Never merge a pull request from this skill.
- Do not delete a worktree that has uncommitted changes, unpushed commits, or no pushed branch.
- Return the repository to its original branch when the run finishes.

## Inputs

Read in this order:

1. `../../../AGENTS.md`
2. `../../../PROGRESS.md`
3. `feature_list.json`
4. `docs/specs/` and `docs/validations/` if present
5. Current git status and `git worktree list`

Resolve the run inputs:

- Feature IDs: use the IDs the user provided, in the order provided.
- If no feature IDs are provided, default to:
  - repository: the current repository (`git rev-parse --show-toplevel`),
  - base branch: `demo/seed`,
  - feature selection: the next available feature per `feature-flow` selection rules,
  - quantity: one feature per run unless the user asked for several.
- Base branch: `demo/seed` unless the user overrides it.
- Worktree root: `../devexpert-project-worktrees/<feature-id>` (sibling of the repository root).
- Feature branch: `feature/<feature-id>`.
- Scratch directory for issue/PR body files: `<worktree>/.github-flow/`, excluded locally via `.git/info/exclude` so it is never committed.

## Preflight (Before Executing)

Stop and report if any check fails. Do not fix a dirty base or a missing dependency by inventing work.

### 1. Dependencies accepted

For every selected feature, confirm each `depends_on` id exists and has status `accepted` in `feature_list.json`. A dependency that is only `passing` is not accepted. If a dependency is unmet, report the blocking feature ids and stop selecting that feature.

### 2. Base is clean

- `git status --porcelain` must be empty in the base checkout (ignored files are fine). If the tree is dirty, stop and ask the user to commit or stash before starting.
- `git fetch origin` and confirm the base branch exists (`git rev-parse --verify origin/<base>` or local `<base>`). If it does not exist, stop and report; do not create it silently.
- Resolve the base SHA once for the whole run: `BASE_SHA="$(git rev-parse "origin/<base>")"`. Every feature worktree uses exactly this SHA.

### 3. Permissions

- Confirm `gh auth status` is authenticated and, for push, that the account has `repo` scope.
- Confirm git push permission for the remote.
- Record whether the user granted push/PR permission. If not granted, run the flow up to validated commits and stop before push.

### 4. Independent environments

Every worktree must be runnable on its own:

- each worktree gets its own `.env`,
- each `.env` has a unique `PORT`,
- each `.env` has a unique database name/URL,
- no worktree shares a running server, port, or database with another.

Assign each feature a stable port and database derived from its id so re-runs are idempotent (for example, a fixed base port plus the feature's index in the run, and a database name like `devexpert_<id_with_underscores>`). Confirm `.env` is gitignored before copying secrets into it.

## Per-Feature Pipeline

Run these steps for each selected feature, in order.

### 1. Issue (create or reuse)

- Search first: `gh issue list --state all --search 'in:title "<feature-id>"' --json number,title,state,url`.
- If an issue for the feature exists, reuse it. Do not create a duplicate.
- Otherwise create one with a formatted body file:
  - write the body to `<worktree>/.github-flow/<feature-id>.md`,
  - `gh issue create --title "<type>: <feature-id> — <title>" --body-file "<worktree>/.github-flow/<feature-id>.md" --label enhancement`.
- The issue body must include: summary, feature metadata (`id`, `area`, `depends_on`), user-visible behavior, acceptance criteria (from the feature's `verification`), a link to `docs/specs/<feature-id>.md`, the planned branch and worktree path, and an evidence section to be filled by the PR.

### 2. Branch and worktree from the same base SHA

- Check existing worktrees: `git worktree list --porcelain`.
- If the worktree path already exists, reuse it. Never delete or recreate it.
- Otherwise create branch and worktree together from the shared base SHA:
  - `git worktree add -b feature/<feature-id> "../devexpert-project-worktrees/<feature-id>" "$BASE_SHA"`.
- If the branch already exists but has no worktree, attach it instead of recreating it.

### 3. Isolated environment

- Copy the environment template (`.env`, `.env.example`, or `.env.template`, whichever exists) into the new worktree as `.env`.
- Override `PORT` with the feature's unique port and the database variable (for example `DATABASE_URL` or `DB_NAME`) with the feature's unique database.
- Confirm `.env` is not tracked: `git -C "<worktree>" check-ignore .env`.

### 4. Independent session (one per feature)

- Launch exactly one unattended session per feature, rooted in the worktree:
  - `opencode run --dir "../devexpert-project-worktrees/<feature-id>" "<prompt>"`.
- The prompt must instruct the session to run `feature-flow` for the single feature id until the flow reaches an explicit stop condition, working only inside this worktree, and to return the selected feature id, the validator verdict, the final `feature_list.json` status, the commit hash, and the recorded evidence.
- Never batch two feature ids into one session. Run the sessions sequentially (or as explicitly separated processes), never sharing a worktree.

### 5. Collect the result

After the session returns, read the worktree's `feature_list.json` and `PROGRESS.md`:

- confirm the feature status,
- capture the commit hash on `feature/<feature-id>`,
- capture the validator verdict and evidence.

## Re-run Behavior

When the flow is run again for a feature that already exists:

- reuse the existing issue,
- reuse the existing worktree and branch,
- reuse the existing PR if one is open,
- continue the feature-flow from its current status; do not duplicate or delete prior work,
- if the worktree was removed but the branch was pushed, re-attach the branch instead of forking a new one.

## Publish (Accepted + Permitted Only)

Publish happens only when both conditions hold:

1. `feature_list.json` in the worktree shows the feature as `accepted`.
2. The user granted push/PR permission for this run.

If either is missing, skip publish and report the feature as ready-but-unpublished.

To publish:

- Push the branch: `git -C "<worktree>" push -u origin feature/<feature-id>`.
- Check for an existing PR: `gh pr list --head feature/<feature-id> --state all`.
- If none exists, create one against the base branch using a formatted body file:
  - write the PR evidence to `<worktree>/.github-flow/<feature-id>-pr.md` (what changed, verification, validator verdict, evidence, issue reference),
  - `gh pr create --base <base> --head feature/<feature-id> --title "<type>: <feature-id> — <title>" --body-file "<worktree>/.github-flow/<feature-id>-pr.md"`.
- If a PR already exists, update/comment the evidence instead of creating a second PR.
- Never merge the pull request.

## Cleanup (After Publish)

For each feature, after its branch is pushed and its PR exists:

- Only if the worktree is clean and fully pushed — `git -C "<worktree>" status --porcelain` is empty and `git -C "<worktree>" log @{u}..` is empty — remove it: `git worktree remove "<worktree>"`.
- If the worktree is dirty or has unpushed commits, keep it and report it as retained.
- When all features are done, return the repository to its original branch (`git checkout <original-branch>`).

## Output Summary

Report per feature:

- feature id and title,
- branch (`feature/<feature-id>`),
- worktree path (and whether it was removed or retained),
- status in `feature_list.json`,
- commit hash and message,
- validator verdict and evidence summary,
- issue URL,
- pull request URL (or "not published" with the reason),
- base branch and base SHA used.

Then report the run-level result: which features were published, which were skipped and why, and any blockers.

## Final User Handoff

The handoff headings below are intentionally in Spanish: the skill is written in English, but the final handoff is addressed to the Spanish-speaking user.

Include:

- `Qué se ha hecho`: 2-5 bullets summarizing the published features, not internal noise.
- `Cómo probarlo`: how to review the PR(s) and run the accepted feature locally (command, port, database).
- `Validación`: validator verdict and the most relevant checks that actually ran.
- `Publicación`: branch, commit, issue and PR URLs.
- `Bloqueos`: unmet dependencies, dirty base, missing permission, or retained worktrees, if any.

Do not invent publish results. If nothing was pushed, say so explicitly and explain why.
