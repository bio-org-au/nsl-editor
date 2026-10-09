---
name: git-branch-workflow-set-up
description: Make a change the way this repo expects - local branch, commit, push to your fork (origin), then a PR to the upstream repo. Use when starting or shipping a change, or when the user asks to branch, commit, push, or raise a PR.
argument-hint: "[jira-id or branch-name]"
---

# Git branch workflow

This repo is a fork. Changes go to `upstream` (`bio-org-au/nsl-editor`) through a PR from a branch on your fork (`origin`). Never commit directly to `main`.

## 1. Create a local branch

- Start from an up-to-date `main`. If it's behind `upstream/main`, run `/post-merge-clean-up` or `git fetch upstream && git merge upstream/main` first.
- Branch names:
  - With a Jira ticket: `nsl-<number>`, lowercase, for example `nsl-5974`.
  - Without one: a short kebab-case description, for example `update-claude-md-git-workflow`.
- `git checkout -b <branch-name>`. Uncommitted work comes with you onto the new branch.

## 2. Commit

- Ask the user whether this change should be recorded in the change history. If it should, run `/change-history-and-version` before committing. Changes that don't affect users (tooling, docs, CLAUDE.md, skills) usually skip it.
- Stage the files explicitly. Don't use `git add -A`, because it can pick up stray files.
- Commit message format:
  - With a Jira ticket: `NSL-<number>: <Area>: <description>`, matching the history entry, for example `NSL-5974: Security: Sanitize Batch Loader Review Comment HTML`.
  - Without one: a short imperative summary, for example `Add CLAUDE.md for Claude Code guidance`.
- The pre-commit hook runs RuboCop on staged Ruby files and blocks Bootstrap 3/4 classes. If it fails, fix the problem. Don't bypass it with `--no-verify` unless the user asks.

## 3. Push to origin (your fork)

```bash
git push -u origin <branch-name>
```

## 4. Create the PR to upstream

Work out the fork owner from `git remote get-url origin`. Then run:

```bash
gh pr create --repo bio-org-au/nsl-editor --base main \
  --head <fork-owner>:<branch-name> \
  --title "<commit subject>" --body "<summary of the change>"
```

- Keep the body short: what changed and why, plus anything a reviewer should check.
- Give the user the PR URL.
- After the PR is merged, run `/post-merge-clean-up`.
