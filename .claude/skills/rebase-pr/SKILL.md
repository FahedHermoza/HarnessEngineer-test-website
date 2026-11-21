---
name: rebase-pr
description: Fix "This branch cannot be rebased due to conflicts" and similar rebase-and-merge errors for the current pull request. Use when the user asks to resolve rebase-and-merge errors, update a PR branch against its base, remove a merge commit from a PR branch, or resolve PR conflicts before merging.
---

# Rebase PR

Use this skill when GitHub cannot perform "Rebase and merge" on the current PR because the base branch advanced, the PR branch contains a merge commit, or the branch conflicts with the base.

The goal is a linear branch on top of the current base, with conflicts resolved, verification passing, and the PR back to `MERGEABLE` / `CLEAN`. Do not merge the PR.

## Hard Rules

- Never merge the pull request.
- Only rebase and force-push the current PR branch. Never touch another branch.
- Use `git push --force-with-lease`, never plain `--force`.
- Do not push until `./init.sh` exits 0 and browser validation passes.
- Do not kill a server or process you did not start. Reuse a compatible existing server if one is serving the repo.
- Stop and report if the working tree is dirty, the branch is not the PR head, or `gh` is not authenticated.
- Ask for explicit push/force-push permission if the user has not already granted it for this run.

## Inputs

Read in this order:

1. `../../../AGENTS.md`
2. `../../../PROGRESS.md`
3. `feature_list.json`
4. Current `git status`, `git branch --show-current`, and `git worktree list`
5. `gh auth status`

Resolve:

- Repository root: `git rev-parse --show-toplevel`.
- Current branch: `git branch --show-current`; it must be the PR head.
- Base branch: `demo/seed` unless the user specifies another base.
- PR: `gh pr list --head <branch> --state open --json number,title,baseRefName,headRefName,mergeable,url`.
- Base SHA: after `git fetch origin --prune`, `git rev-parse origin/<base>`.

## Preflight

1. `git status --porcelain` must be empty. If dirty, stop and ask the user to commit or stash.
2. `git fetch origin --prune`.
3. Confirm the current branch has an open PR and that the PR head matches.
4. Confirm the branch is actually behind or conflicting:
   - `git log --oneline origin/<base>..HEAD`
   - `gh pr view <n> --json mergeable,mergeStateStatus`
5. Note whether the branch contains a merge commit. The rebase will remove it and produce a linear history.

## Rebase

1. Run `git rebase origin/<base>`.
2. If it completes without conflicts, skip to Validation.
3. On conflicts, follow `references/conflict-playbook.md` plus these general rules:
   - Preserve both sides' product behavior.
   - Keep the base harness checks and add the incoming feature checks; never weaken a gate.
   - Keep every `accepted` status in `feature_list.json`.
   - Keep both session logs in `PROGRESS.md`; renumber incoming sessions to the next free numbers.
   - Add a new `Session NNN — rebase de <feature>` entry with the actual verification results.
4. Stage only resolved files and continue:
   - `git add <files>`
   - `GIT_EDITOR=true git rebase --continue`
5. Repeat until the rebase finishes.
6. Confirm the result is linear:
   - `git log --oneline --graph --max-count=6`
   - `git rev-parse HEAD~1` should equal `origin/<base>` for a single-commit PR.

## Validation

1. `bash -n init.sh`.
2. `./init.sh`; it must exit `0`. Capture the output, especially new and prior checks.
3. Browser validation with Chrome DevTools MCP:
   - If a server is already serving the repo (for example port 3101), reuse it. Do not stop it.
   - Otherwise start `python3 -m http.server <free-port> --directory .` and stop only that process.
   - Validate at mobile `390×844` and desktop `1280×800`.
   - Console: 0 errors/messages caused by the page.
   - Network: no failed requests, no 4xx/5xx, no unexpected `/favicon.ico`.
   - Layout: no horizontal scroll.
   - Feature-specific DOM, geometry, hrefs, labels and styles must still be present.
4. If anything fails, fix the resolution and repeat. Do not push a failing result.

## Publish

1. `git push --force-with-lease origin <branch>`.
2. Wait for GitHub to recompute and verify:
   - `gh pr view <n> --json number,state,mergeable,mergeStateStatus,headRefOid,baseRefOid,url`
   - Expected: `OPEN`, `MERGEABLE`, `CLEAN`.
3. Add a concise PR comment with:
   - new head commit,
   - base branch and SHA,
   - conflicts resolved,
   - `./init.sh` result,
   - browser results.
4. Do not merge.
5. Leave the repository clean on the PR branch and confirm `git status --porcelain` is empty.
6. Report which other open PRs touch the same files and will need the same rebase after the next merge.

## Output

Report in Spanish:

- PR number, title and branch.
- New head commit and message.
- Base branch and base SHA.
- Files with conflicts and how they were resolved.
- `./init.sh` result and browser results.
- Final PR state.
- Remaining PRs at risk of the same conflict.
