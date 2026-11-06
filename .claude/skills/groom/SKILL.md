---
name: groom
description: Re-run the update, test and review loop on a branch that already exists — sync with main, test, review, fix, repeat until a pass finds nothing. Use for /groom, "groom this", "re-test and re-review", "bring this branch up to date and check it again".
argument-hint: "[push] [PR# | path]   (none = current branch)"
---

# /groom

Read `$RISK0/.claude/skills/WORKFLOW.md` first. This skill only sequences other skills (invoke each with the Skill tool, one at a time, in this session) over work that already exists. It never plans or builds new scope: that's `/build`.

`$ARGUMENTS`: `push` opts in to shipping at the end. A PR number or path narrows the target. Default target: the current branch against `main`, in its worktree.

## One pass

1. **Update.** `git fetch origin main`. If the branch is behind, merge `origin/main` into it (a merge commit, never a rebase or force-push). Conflicts go to `/fix-merge-conflicts`. Then refresh whatever the diff made stale: the ticket's plan file in `toolbox/sandbox/plans/` (tick done tasks) and any repo doc the diff touches.
2. **Test.** `/test` on the branch diff. Failures go to `/fix`, then `/test` again.
3. **Review.** `/cr` on the changes. If a PR is open, also `/cr <PR#>` for the comments and gate findings still open. Apply `receiving-code-review` to each: fix the valid ones, note the declined ones with a reason. Risky diff (migration, auth, billing, public API contract, very large): add `/thermo-nuclear-review`.
4. **Re-test** if step 3 changed any code.

## Loop

Repeat the pass while the last pass changed code, at most 3 passes. A pass that merged nothing, fixed nothing and found nothing new ends the loop. Still changing after 3: stop and report what keeps moving.

## Ship (only if `push` was given)

Run `/push` once after the loop ends clean. Without `push`, stop with everything committed locally and say so: pushing is outward-facing and Alec asked for groom, not a PR update.

## Stop and ask

- `/push`'s always-ask cases (protected paths, security, data loss, migrations, billing).
- A merge conflict that is a judgement call about behavior, not a mechanical overlap.
- A destructive step (`db:reset`, force-push, deleting data) or a credential you don't have.
- The same step failing the same way twice: report the verbatim error.

## Rules

- Never merge the PR, never post GitHub replies or approvals unasked.
- Commit fixes as new commits with the repo's message style. No amend, no history rewrite.
- One short status line per step; no narration between steps.

## Final reply (tldr form)

Branch/worktree · passes run · per step: done / skipped / stopped · merged from main (commit count) · tests run and result · findings fixed vs declined · whether anything is unpushed · what Alec must decide next.
