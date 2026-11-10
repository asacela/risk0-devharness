---
name: context-manager
description: Show what I'm working on per Claude session as a short bullet list, grouped by work stream with its stage, and help move each stream to its next stage. Use for /context-manager, "what am I working on", "what's in flight", "where is each session at", "what's the next stage for X".
argument-hint: "[stream, ticket or PR to manage | blank for the whole picture]"
---

# /context-manager

Read `$RISK0/.claude/skills/WORKFLOW.md` first (who wins, output shape). Read-only until I approve an action. Output is **short bullets, never tables or big graphs**.

## 1. Gather (parallel; skip a source that fails and say so)
- **Sessions:** `ListAgents` for the peer names, then the logs per `$RISK0/toolbox/AGENTS.md` §1 (`find ~/.claude/projects -name '*.jsonl' -mtime -2 -not -path '*/subagents/*'`, read `aiTitle`, `gitBranch`, cwd). Skip `no-mistakes` pipeline worktrees and trivial one-off sessions. `ListAgents` gives names only, so say when a session can't be tied to a branch.
- **Worktrees:** `git worktree list` in each `$RISK0/repositories/<repo>`, ignoring `prunable` and `/private/tmp` entries.
- **PRs:** per repo (WORKFLOW.md → Host commands): "My open PRs" (on GitHub add `mergeStateStatus,statusCheckRollup` to `--json`), plus PRs of mine merged since the last refresh. Failing check names come from `statusCheckRollup`.
- **Tickets:** the branch name or PR title gives the ticket key (WORKFLOW.md → Tickets); read its status only when a key is in play.
- **Plans:** `$RISK0/toolbox/sandbox/plans/` for a matching plan file.

## 2. Group and assign a stage
Group sessions by work stream (a branch, a ticket, or "main checkout / ad hoc"). Give each stream exactly one stage:
- **Exploring**: no branch or plan yet.
- **Planned**: plan file exists, no code.
- **Building**: branch with commits, no PR.
- **Gate / CI**: PR open, checks running or failing.
- **In review**: CI green, waiting on a reviewer.
- **Blocked**: merge conflicts, failing CI, or waiting on someone else.
- **Merged, clean up**: merged; worktree and ticket still open.

## 3. Output (bullets only)
- One bullet per stream: **name** · stage · one line on where it left off · the single next action.
- Sessions go in sub-bullets under their stream, with title and short id.
- After the streams, short lists: **Stuck** (blocked or waiting more than a few days), **Cleanup** (merged worktrees, stale branches), **Unattributed sessions**.
- Full absolute paths for any file or worktree. Close with what you didn't check.

## 4. Manage stages
For a named stream, or after the overview if I pick one:
- Say the next stage and what gets it there, then offer the matching command: `/planning`, `/implement`, `/test`, `/push`, `/groom`, `/cr`, `/fix`, `/log`.
- Only do these without asking: refreshing `$RISK0/toolbox/journal/daily.md` (the Active work section, with the `_Refreshed_` stamp, per `toolbox/AGENTS.md` §1) and reading things.
- Ask before: pushing, posting a review, moving a Jira ticket, removing a worktree (use `herdr worktree remove`), or messaging another session with `SendMessage`.
- When a stream finishes a stage, offer a one-line `/log` entry.

## Not this skill
- `/daily` is the team digest artifact (merged PRs, Slack, Jira across everyone). `/context-manager` is my own streams and sessions only.
- `/steps` lists manual steps for one task. `/build` and `/groom` drive one branch through all stages; this skill only shows where each branch is.
