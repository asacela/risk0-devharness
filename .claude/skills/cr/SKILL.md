---
name: cr
description: Review my own work in progress (uncommitted or branch changes) with ponytail review plus a thermo-nuclear structural pass, and present the must-fix and should-fix findings from both; or address the comments left on my own PR/MR. Use for /cr, "review my changes", "review this", "address the PR comments". A teammate's PR goes to /cr-on-pr.
argument-hint: "[path | my PR#/MR! (its comments)]   (none = my current changes)"
---

# /cr

(Code review of my own WIP. Named `/cr` because `/review` is a built-in alias for `/code-review`. To review a PR and post the findings on it, use `/cr-on-pr`.)

Read `$RISK0/.claude/skills/WORKFLOW.md` first (who wins, plan location, output shape).

Pick the target from `$ARGUMENTS`:

- **Nothing or a path: my changes.** The uncommitted changes, else the branch vs `main`. Run **Review** below and present the result. Offer to fix the must-fix ones. (`/push` runs no-mistakes' own review too, so this is a look before that, not a replacement.)
- **A PR/MR number or URL**: check the author (WORKFLOW.md → Host commands, "PR author, branch, reviews").
  - **My PR**: pull its review comments ("PR review comments") and apply `superpowers:receiving-code-review`. Verify each comment, fix the valid ones as new commits on top, draft replies with reasons for the rest (don't post without asking). Then offer `/push` to re-run the gate. No **Review** pass here unless Alec asks.
  - **Someone else's PR**: not this command. Say so in one line and run `/cr-on-pr <n>` instead.

## Review

Shared with `/cr-on-pr`. The target is a diff (paths, a branch, or "PR diff" from Host commands, reading the connected code in the main checkout).

1. **Both passes, in parallel. Don't ask first.** First send one Agent call (type `general-purpose`, background) that invokes `thermo-nuclear-review` via the Skill tool on the exact target and reports in the tldr block (WORKFLOW.md), except that `findings` lists every must-fix and should-fix (no cap of 5), each with `file:line`, severity and a one-line why. It edits, commits and posts nothing. Then, without waiting, run `ponytail:ponytail-review` on the same target yourself.
2. **Grade every finding:**
   - **Must fix**: wrong behaviour, a crash, data loss or corruption, a security hole, a broken contract or caller, a migration that can't run on real data, or logic-bearing code with no test (Quality bars §1).
   - **Should fix**: maintainability or structure that will cost later: a thermo-nuclear "code judo" restructure, duplication, a misplaced abstraction, a missing edge-case test, a slow path that will bite at real load.
   - **Nit**: style, naming, taste. Count them, don't list them, unless Alec asks.
   A finding Alec might reasonably disagree with is at most should-fix.
3. **Merge.** When the subagent returns, check each thermo-nuclear finding against the code before keeping it (a subagent can be wrong), then de-duplicate across both passes (same spot and same problem → one finding, both sources named).
4. **Present** above the tldr divider when there are must-fixes:

   ```
   Must fix (N)
   1. [ponytail|thermo|both] path/to/file.ts:42 — <the problem> → <the fix>
   Should fix (N)
   1. [thermo] path/to/other.ts:10-30 — <the problem> → <the fix>
   Nits: N (ask to list)
   ```

   Paths are absolute in chat (root `AGENTS.md`). Plain English, one line each, fix included. Nothing found in a section: say `none`.

When done, update the "Reviews owed" line in `daily.md` if this was one of them.
