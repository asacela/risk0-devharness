---
name: implement
description: Build a plan, ticket or task in the right worktree, with tests where the logic needs them, and verify it. Use for /implement, "build it", "do PROJ-123", "do issue 42".
argument-hint: "[plan file | PROJ-123 | #42 | task]"
---

# /implement

Read `$RISK0/.claude/skills/WORKFLOW.md` first (who wins, plan location, output shape).

1. Input: `$ARGUMENTS`, else the plan file for the current branch/ticket, else ask. Move the ticket to In Progress (WORKFLOW.md → Ticket status).
2. Workspace: on `main` or in the main checkout, create a herdr worktree first (WORKFLOW.md → Overrides). Already in the ticket's worktree: stay.
3. Pick the mode:
   - **Plan with several tasks**: `superpowers:subagent-driven-development`. Subagents report in the tldr block.
   - **Small or single task**: do it yourself under ponytail. Use `superpowers:test-driven-development` only when it adds logic.
4. Follow the repo's `AGENTS.md` conventions. Commit in logical steps (repo commit style, Co-Authored-By trailer).
5. `superpowers:verification-before-completion`: run the touched app's checks (`test`/`lint`/`typecheck` from the repo config, WORKFLOW.md → Repo config) and show the result.
6. Tick finished tasks in the plan file, then offer `/push`.
