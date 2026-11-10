---
name: cr
description: Review code, always including a thermo-nuclear structural pass. Own uncommitted/branch changes, a teammate's PR/MR, or the comments left on my PR/MR. Use for /cr, "review this", "review PR 608", "address the PR comments".
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

**Always run `/thermo-nuclear-review` alongside, in parallel.** For "my changes" and "someone else's PR", first send one Agent call (type `general-purpose`, background) that invokes `thermo-nuclear-review` via the Skill tool on the exact target (paths or `gh pr diff <n>`) and reports in the tldr block (WORKFLOW.md). It edits, commits and posts nothing. Then, without waiting, do the normal `/cr` review yourself as described above. Don't ask first.

When the subagent returns, merge into one report: your `/cr` findings first, then the thermo-nuclear ones labelled as such, de-duplicated, each checked against the code before you repeat it (a subagent can be wrong). A finding Alec might disagree with is a suggestion, not a fix. Skip the subagent only for the target "my own PR's review comments", unless Alec asks.

When done, update the "Reviews owed" line in `daily.md` if this was one of them.
