---
name: implement
description: Build a plan, ticket or task in the right worktree test-first (TDD: failing tests committed, then code built against them), and verify it. Use for /implement, "build it", "do PROJ-123", "do issue 42".
argument-hint: "[plan file | PROJ-123 | #42 | task] [solo]"
---

# /implement

Read `$RISK0/.claude/skills/WORKFLOW.md` first (who wins, plan location, output shape).

1. Input: `$ARGUMENTS`, else the plan file for the current branch/ticket, else ask. Resolve the ticket, creating one if the input is a task or plan with none (WORKFLOW.md → Ticket for every change), then move it to In Progress (WORKFLOW.md → Ticket status). Do this before step 2: the branch name uses the key.
2. Workspace: on `main` or in the main checkout, create a herdr worktree first (WORKFLOW.md → Overrides). After the worktree setup, copy the config's `worktreeFiles` into it (WORKFLOW.md → Repo config). Already in the ticket's worktree: stay.
3. Pick the mode:
   - **Plan with several tasks**: `superpowers:subagent-driven-development`. Each implementer subagent's prompt tells it to invoke `superpowers:test-driven-development` via the Skill tool for its task. Subagents report in the tldr block.
   - **Small or single task**: do it yourself under ponytail, inside `superpowers:test-driven-development` (invoke it via the Skill tool before writing any code).
   - **`solo` in `$ARGUMENTS`** (meant for mobile tickets, WORKFLOW.md → Quality bars §3): write no product code. Set up the worktree, point Alec at the files, docs and the §3 questions, then wait. When he says he's done, review his diff like `/cr` and explain the mobile and EAS parts rather than rewriting them.
   - Either mode, **tests first, then build against them**: write the tests from the plan's `## Test plan` rows (else the acceptance criteria and other paths, Quality bars §1), run them and show they fail for the right reason, commit them on their own (`test:`), then write the code until they pass, without editing the tests to fit. Only a change that adds no logic (copy, config value, pure styling) skips this, and the reply says so.
4. Follow the repo's `AGENTS.md` conventions. Commit in logical steps (repo commit style, Co-Authored-By trailer).
5. `superpowers:verification-before-completion`: run the touched app's checks (`test`/`lint`/`typecheck` from the repo config, WORKFLOW.md → Repo config) and show the result. Then run the plan's real-shape verification task (Quality bars §2) and fill in `## Verification`. The prod-data part follows the plan's `Prod data: use | skip` line: with `use`, run `/test`'s prod-data step; with `skip`, don't, and repeat the reason in the reply. If it can't run (blocked key, no device build), say so above the divider. Don't mark the plan done.
6. Tick finished tasks in the plan file and fill the test file and status of each `## Test plan` row, then offer `/push`.
