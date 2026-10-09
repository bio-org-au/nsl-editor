---
name: post-merge-clean-up
description: After a PR has been merged upstream, sync local and fork main with upstream/main and delete the merged feature branch. Use when the user says a PR was merged, or asks for post-merge cleanup.
argument-hint: "[branch-name]"
---

# Post-merge clean-up

Bring `main` up to date with the upstream repo after a PR merge, push it to the fork (`origin`), and delete the local feature branch.

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
   git checkout main
   git merge upstream/main
   git push
   ```
   If the merge is not a fast-forward or hits conflicts, stop and report it. Don't resolve the merge automatically.

4. **Delete the merged branch:**
   ```bash
   git branch -d <branch-name>
   ```
   Use `-d`, never `-D`. If git refuses because the branch is "not fully merged" (common after a squash merge), tell the user and ask before force-deleting it.

5. **Optionally delete the remote branch on the fork.** If `origin/<branch-name>` still exists, ask the user whether to run `git push origin --delete <branch-name>`.

6. **Report** the new `main` HEAD (`git log --oneline -1`) and which branches were deleted.
