---
name: build
description: Run the whole workflow end to end without stopping — plan, implement, test, push, review, fix, push again. Use for /build PROJ-123, /build 42 (an issue), /build <idea>, "build this start to finish", "take this all the way to a PR".
argument-hint: "<PROJ-123 | #42 | idea | plan file>"
---

# /build

Read `$RISK0/.claude/skills/WORKFLOW.md` first. This skill only sequences the other skills. Each step is the real skill (invoke it with the Skill tool, one at a time, in this session) with its own rules. Where a step says to wait for Alec ("once Alec agrees", "offer /implement"), don't: take the default and keep going.

`$ARGUMENTS` = ticket key, idea or plan file. Empty: ask what to build, one line, then go.

## Sequence

1. **`/planning $ARGUMENTS`.** Autonomous: if the ticket has clear acceptance criteria, write `## Design` and `## Plan` straight away. Ask Alec only when a question changes the design and the ticket or code can't answer it. Ask all such questions in one message, then continue.
2. **`/implement`** on the plan file. Worktree, tasks, verification, as that skill says.
3. **`/test`** on the branch diff. Failures go to `/fix`, then re-run `/test`. Up to 3 rounds, then stop and report.
3b. **Extras.** Risky diff (migration, auth, billing, public API contract, unusually large): run `/thermo-nuclear-review` and treat findings like review comments (valid ones to `/fix`, then re-run `/test`). Diff edits docs or user-facing copy: `/unslop` those lines. Neither: skip.
4. **`/push`** (without `yes`: its own gate rules decide what to fix or decline). Result: PR open, gates passed, CI state.
5. **`/cr <PR#>`** on my own PR: apply `receiving-code-review` to every review and bot comment left on it, including the CI and gate findings still open. Nothing to address: skip to the report.
6. **`/fix`** for any valid comment or failure that isn't a plain edit (a bug needing a root cause), then **`/push`** again, as new commits on top. Repeat 5–6 at most twice, then stop and report what's left.

## Stop and ask (everything else runs on)

- `/push`'s always-ask cases: protected-path refusals, "unvalidated work" refusals, any finding touching security, data loss, migrations or billing, and the one-time `no-mistakes init`.
- An existing merged or closed PR for the branch.
- Work that would need a destructive step (`db:reset`, force-push, deleting data) or a credential you don't have.
- The same step failing the same way twice: report the verbatim error instead of trying a third variation.

## Rules

- Never merge the PR and never post review replies on GitHub/GitLab unasked (`/cr` and `/push` already say so).
- Ticket status, `daily.md` and `work-journal.md` are updated by the steps that own them. Don't duplicate.
- Keep going between steps without narrating. One short status line per finished step is enough.

## Final reply (tldr form)

Ticket and plan file path · branch/worktree · PR URL · per step: done / skipped / stopped · tests run and result · findings fixed vs declined · what Alec must decide or do next (merge, a gate question, a manual check). If it stopped early, say at which step and why first.
