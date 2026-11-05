---
name: cr
description: Review code. Own uncommitted/branch changes, a teammate's PR/MR, or the comments left on my PR/MR. Use for /cr, "review this", "review PR 608", "address the PR comments".
argument-hint: "[PR#/MR! | PR/MR URL | path]   (none = my current changes)"
---

# /cr

(Code review. Named `/cr` because `/review` is a built-in alias for `/code-review`.)

Read `$RISK0/.claude/skills/WORKFLOW.md` first (who wins, plan location, output shape).

Pick the target from `$ARGUMENTS`:

- **Nothing or a path: my changes.** `ponytail:ponytail-review` on the uncommitted changes, else the branch vs `main`. Report and offer to fix. (`/push` runs no-mistakes' own review too, so this is for a look before that, not a replacement.)
- **PR/MR number or URL**: check the author (WORKFLOW.md → Host commands, "PR author, branch, reviews").
  - **Someone else's PR**: `ponytail:ponytail-review` on it ("PR diff", read the connected code in the main checkout). Report findings in plain English. Post inline comments only if Alec says so (`/code-review --comment`). Never approve or request changes on the host without asking.
  - **My PR with review comments**: pull them ("PR review comments") and apply `superpowers:receiving-code-review`. Verify each comment, fix the valid ones as new commits on top, draft replies with reasons for the rest (don't post without asking). Then offer `/push` to re-run the gate.

When done, update the "Reviews owed" line in `daily.md` if this was one of them.
