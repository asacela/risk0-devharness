# Skills inventory

Every skill a session here can see, who owns it, and when it matters. Snapshot from 2026-10-27; refresh it when a plugin is added, removed or updated. Job-to-tool decisions live in [`skills/WORKFLOW.md`](/.claude/skills/WORKFLOW.md); this file is the catalogue and the reasoning behind them.

Why it matters: every model-invocable skill's name and description loads into each session's context. Unused plugins cost tokens and make the model pick the wrong skill more often. Skills marked manual-only (`disable-model-invocation`) cost nothing until you type them.

## The core stack: who does what

| Layer | Tool | Fires | Owns |
|---|---|---|---|
| Style / scope | **ponytail** | always (hook) | Smallest complete change; `ponytail-review` for hand review |
| Process | **superpowers** | when a skill matches | Brainstorm → plan → subagents → TDD → debug → verify |
| Gate | **no-mistakes** | `/push` | Review, test, lint, docs, PR, CI babysitting |
| Glue | **own commands** | you type them | Ticket → worktree → plan file → journal; all the workspace rules |
| Extras | **cursor-team-kit** (4 copied) + **pstack** (2 copied) + **janestreet/agent_skills** (1 copied) | you type them | `/socratic-tutor`, `/fix-merge-conflicts`, `/verify-this`, `/weekly-review`, `/thermo-nuclear-review`, `/statechart`, `/unslop` |

Each does one job. Where two tools claim the same job, the winner is in the overlaps table.

## Sources

| Source | Skills | Verdict |
|---|---|---|
| Own commands (`.claude/skills/`) | 13 + 7 borrowed | **Keep** |
| `ponytail` 5.3.1 | 6 | **Keep** (always-on core) |
| `superpowers` 7.0.0 | 14 | **Keep** |
| `no-mistakes` (not a plugin) | 1 | **Keep** |
| `claude-security` 0.12.0 | 1 skill + 9 agents | **Keep**, agents load only when a scan runs |
| `ui-ux-pro-max` 2.15.0 | 7 | **Keep for now**; 4 overlap, project-scope to a repo if context feels heavy |
| `anthropic-skills` | 9 | **Keep**, on demand (docx, pdf, pptx, xlsx, docs, ...) |
| Built-ins (`code-review`, `simplify`, `loop`, `schedule`, `claude-api`, `update-config`, ...) | ~14 | **Keep**, can't remove |
| `tldr` | 1 | **Keep** (shape copied into WORKFLOW.md) |
| `pstack` | ~60 (mostly manual-only) + 2 agents | **Removed** 2026-10-27, but `statechart` and `unslop` copied out of it (see below); `swarm`, `ketchup` dropped |

## Why pstack went

pstack is a whole competing workflow (`poteto-mode`, `architect`, `swarm`, `ketchup`, ~30 `principle-*` skills). Almost everything has a counterpart already running here:

| pstack | Already covered by |
|---|---|
| `principle-laziness-protocol`, `principle-subtract-before-you-add` | ponytail (always on) |
| `principle-prove-it-works` | `superpowers:verification-before-completion` |
| `tdd`, `principle-test-behavior-not-implementation` | `superpowers:test-driven-development` |
| `principle-fix-root-causes` | `superpowers:systematic-debugging` |
| `architect`, `poteto-mode` | `/planning` + `/implement` |
| `no-comments` / `comment-sicko` | ponytail (comment only the why) |
| `typescript-best-practices` | each repo's own `AGENTS.md` |

Most are manual-only, so the context cost was small; the real cost was two overlapping workflows giving conflicting instructions. `statechart` and `unslop` were copied into `.claude/skills/` afterwards (`statechart` without its test corpus), so the plugin stays off. `swarm` and `ketchup` were dropped on purpose.

| Copied from pstack | Fits | Note |
|---|---|---|
| `statechart` | `/planning` design step for state/transition tickets | TLA+ checker; first run installs TLC and Java with mise, needs network. Asks first. |
| `unslop` | Prose only: docs, READMEs, user-facing copy, saved learning notes (`/understand save`, `/push`) | Not a code cleanup, it edits writing. Code style stays with ponytail. |

## cursor-team-kit: what was taken and what wasn't

Cursor-only plugin (no Claude manifest), so skills are copied into `.claude/skills/`, MIT licensed.

| Skill | Decision | Why |
|---|---|---|
| `fix-merge-conflicts` | **Copied** | Nothing here handles conflicts |
| `verify-this` | **Copied** | Baseline-vs-treatment evidence is stricter than `verification-before-completion`; use for "does this fix really work" |
| `weekly-review` | **Copied** | `/daily` is a digest of others' movement; this is my own weekly synthesis |
| `fix-ci`, `loop-on-ci` | Skip | no-mistakes already babysits CI |
| `review-and-ship`, `new-branch-and-pr`, `make-pr-easy-to-review` | Skip | `/push` and no-mistakes |
| `get-pr-comments` | Skip | `/cr` handles PR comments |
| `what-did-i-get-done` | Skip | `/weekly-review` and `/log` cover it |
| `deslop` | Skip | ponytail |
| `thermo-nuclear-code-quality-review` | **Copied** as `/thermo-nuclear-review` (2026-10-27) | Manual extra step before `/push` on risky changes (migration, auth, billing, public API contract, oversized diff). Asks first; `ponytail-review` stays the default hand review |
| `check-compiler-errors`, `run-smoke-tests` | Skip | repo scripts and `/test` |
| `control-cli`, `control-ui`, `pr-review-canvas`, `workflow-from-chats` | Skip | Cursor-specific |

## Overlaps (pick one winner)

| Job | Winner | Loser(s) |
|---|---|---|
| Review by hand | `ponytail:ponytail-review` (`/thermo-nuclear-review` as the manual extra on risky changes) | `code-review`, `security-review`, `requesting-code-review` (use `/code-review --comment` only to post inline PR comments) |
| Finish branch / PR / CI | no-mistakes via `/push` | `finishing-a-development-branch` |
| Worktrees | `herdr worktree` | `using-git-worktrees` |
| Run a plan | `subagent-driven-development` | `executing-plans` |
| Cleanup pass | ponytail (always on) | `/simplify` (only for a post-hoc sweep), `ponytail-audit` |
| Prove a claim | `verify-this` for a specific claim; `verification-before-completion` before "done" | |
| UI work | `ui-ux-pro-max:ui-ux-pro-max` | `ui-styling`, `design`, `design-system` |
| Docs / writeups | `anthropic-skills:docs` or Artifact | `docx` only when a .docx is requested |
| Recurring jobs | `loop` (session), `schedule` (cloud) | `CronCreate` directly |

## Own commands

| Command | Job | Leans on |
|---|---|---|
| `/planning` | Idea or ticket → design → plan file | brainstorming, writing-plans |
| `/implement` | Plan → code in a herdr worktree | subagent-driven-development, TDD |
| `/test` | Run and add tests | TDD |
| `/fix` | Root-cause a bug, regression test | systematic-debugging |
| `/cr` | Review own diff, a PR, or PR comments | ponytail-review, thermo-nuclear-review, receiving-code-review |
| `/push` | Ship through the gate | no-mistakes |
| `/build` | All of the above end to end | everything |
| `/setup`, `/understand`, `/steps`, `/log`, `/daily`, `/up`, `/setup-worktree`, `/groom`, `/legend`, `/context-manager` | Support commands | none |
| `/fix-merge-conflicts`, `/verify-this`, `/weekly-review` | Copied from cursor-team-kit | none |
| `/thermo-nuclear-review` | Copied from cursor-team-kit; risk gate before `/push` and in `/build` | none |
| `/socratic-tutor` | Copied from janestreet/agent_skills (MIT, `LICENSE.md` kept in its folder); trigger-phrase driven ("teach me", "quiz me") | none |
| `/statechart`, `/unslop` | Copied from pstack; `/statechart` in `/planning`, `/unslop` on prose in `/push` and `/understand save` | none |

## Still open

- `ui-ux-pro-max`: 7 skills, 4 near-duplicate triggers. Drop or project-scope it if you don't design UI in a repo.
- `superpowers`: 5 skills WORKFLOW.md never picks (`executing-plans`, `using-git-worktrees`, `requesting-code-review`, `finishing-a-development-branch`, `dispatching-parallel-agents`). Can't be disabled per skill; small cost.
- Gaps: no skill for ticket grooming or release notes; both are ad hoc via the Atlassian MCP or `gh`/`glab`.
