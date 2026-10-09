---
name: post-merge-clean-up
description: After a PR has been merged upstream, sync local and fork main with upstream/main and delete the merged feature branch locally and on the fork. Use when the user says a PR was merged, or asks for post-merge cleanup.
argument-hint: "[branch-name]"
---

# Post-merge clean-up

Bring `main` up to date with the upstream repo after a PR merge, push it to the fork (`origin`), and delete the feature branch locally and on the fork.

## Steps

1. **Work out which branch to delete.**
   - Use the branch name passed as an argument, if there is one.
   - Otherwise, if the current branch is not `main`, use the current branch.
   - Otherwise, ask the user which branch to delete. Show them `git branch` so they can pick one.

2. **Check that it's safe to continue.**
   - Run `git status --porcelain`. If there are uncommitted changes, stop and tell the user.
   - Run `git remote` and confirm that an `upstream` remote exists. If it doesn't, stop and tell the user to add it, for example `git remote add upstream https://github.com/bio-org-au/nsl-editor.git`.

3. **Sync main with upstream:**
   ```bash
   git fetch upstream
   git fetch origin --prune
   git merge-base --is-ancestor <branch-name> upstream/main   # confirm the PR is merged
   git checkout main
   git merge --ff-only upstream/main
   ```
   - If the branch isn't in `upstream/main`, stop and ask. The PR may not be merged yet, or it may have been squash-merged.
   - If the merge is not a fast-forward or hits conflicts, stop and report it. Don't resolve the merge automatically.

4. **Delete the merged branch:**
   ```bash
   git branch -d <branch-name>
   ```
   Use `-d`, never `-D`. If git refuses because the branch is "not fully merged" (common after a squash merge), tell the user and ask before force-deleting it.

5. **Delete the branch on the fork.** If `origin/<branch-name>` still exists and step 3 confirmed it's merged, delete it without asking:
   ```bash
   git push origin --delete <branch-name>
   ```
   If the merge couldn't be confirmed, ask first.

6. **Push main to the fork:** `git push`. After step 3, `main` matches `upstream/main`, so the pre-push hook lets it through without asking. If the hook asks "Are you sure?" anyway, `main` has commits that aren't in upstream. The push will fail in Claude's shell, which has no terminal. Stop and tell the developer which commits those are (`git log --oneline upstream/main..main`). Never bypass the hook with `--no-verify`.

7. **Report** the new `main` HEAD (`git log --oneline -1`), which branches were deleted (local and remote), and that `main` is pushed.
