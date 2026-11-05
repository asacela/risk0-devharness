# Risk0 (Development Repo Scaffold)

My development root: code repos plus a personal toolbox. Clone it anywhere; that folder is the workspace root (`<root>` below, `$RISK0` in the agent rules), and nothing assumes a fixed path. Risk0 is the scaffold git repo that tracks only the rules, README and folder skeleton. Its `.gitignore` is an allowlist, so code repos (everything inside `repositories/`) and toolbox content are never tracked (except the helper scripts in `toolbox/scripts/`).

| Path | What | Notes |
|------|------|-------|
| `repositories/` | Main copy of every cloned code repo | the folder is tracked, its contents are ignored; clone new repos here, see [Setup](#setup) |
| `.claude/skills/` | Workflow commands | `/setup` `/planning` `/implement` `/test` `/fix` `/cr` `/understand` `/steps` `/push` `/log` `/daily` `/up` `/build` `/legend`, see below. Symlinked into `~/.claude/skills/` |
| `toolbox/` | Personal workspace | daily tracker, work journal, learning notes, plans, helper scripts |
| `worktrees/` | herdr-managed git worktrees | `worktrees/<repo>/<branch-slug>/`, one per feature branch |

herdr is configured to create worktrees here (`[worktrees] directory = "<root>/worktrees"` in `~/.config/herdr/config.toml`).

## Setup

**Tools to install first**

| Tool | Why | Check |
|---|---|---|
| `git` + [`gh`](https://cli.github.com) and/or [`glab`](https://gitlab.com/gitlab-org/cli) | clones, PRs/MRs, issues, CI status for GitHub / GitLab repos; run `gh auth login` / `glab auth login` | `gh auth status` · `glab auth status` |
| [`herdr`](https://herdr.dev) (`brew install herdr`) | creates and removes the git worktrees | `herdr --version` |
| [`no-mistakes`](https://github.com/kunchenguid/no-mistakes) | the review → push → PR → CI gate behind `/push`. Not a Claude plugin and not in Homebrew. Install: `curl -fsSL https://raw.githubusercontent.com/kunchenguid/no-mistakes/main/docs/install.sh \| sh` (other platforms: [installation guide](https://kunchenguid.github.io/no-mistakes/start-here/installation/)) | `no-mistakes doctor` |
| Claude Code | runs the skills and plugins | `claude --version` |
| Node + Docker | whatever the cloned repos need to build and test; see each repo's README | per repo |

**Steps**

1. **Clone this scaffold** into any folder; that folder is `<root>`.
2. **Point herdr at `worktrees/`**: set `[worktrees] directory = "<root>/worktrees"` (absolute path) in `~/.config/herdr/config.toml`.
3. **Link the workflow skills** into `~/.claude/skills/` so worktree sessions (separate git roots) see them: `ln -s <root>/.claude/skills/<name> ~/.claude/skills/<name>` for each skill dir.
4. **Trust the folder in Claude Code** so it offers the plugin dependencies from `.claude/settings.json` (ponytail, superpowers, ui-ux-pro-max, claude-security).
5. **Connect the integrations** agents use, in Claude Code: the Atlassian MCP (only for repos whose tracker is Jira: tickets, status moves) and Slack (for `/daily`). If one isn't authed, `daily.md` keeps its last data marked `⚠️ stale`.
6. **Create the journal files** under `toolbox/journal/` (`daily.md`, `work-journal.md`). Their content is git-ignored, so a fresh clone starts without them; the layout and refresh rules are in [`toolbox/AGENTS.md`](toolbox/AGENTS.md).
7. **Run `/setup <git-url>` per repo.** It clones into `repositories/<name>/`, detects the repo's host (GitHub or GitLab) and repo path, its ticket tracker (Jira, GitHub or GitLab issues), branch naming, worktree setup script and apps (dev/test/lint commands, ports), asks for what it can't detect, and writes `repositories/<name>/.risk0.json`. Every command reads that file for the repo it runs in. It's excluded from the repo's git (`.git/info/exclude`), so it never gets committed. It also offers `no-mistakes init` in that main checkout (never in a worktree; worktrees share its remotes), which adds a `no-mistakes` git remote and a local gate repo for `/push`. Don't develop in the main checkout directly; use worktrees. Re-run `/setup <name>` to update the config.
8. **Per-repo secrets stay local.** Copy a repo's env template (e.g. `.env.worktree`) by hand. Agents may only look inside a `.env` through `toolbox/scripts/env-check.sh` (names only).

## Workflow

```
 Tickets / PRs ──► toolbox/journal/daily.md ──► plan (toolbox/sandbox/plans/)
                                                   │
                                                   ▼
            toolbox/journal/work-journal.md ◄── implement in <repo> / worktree
```

- **`toolbox/journal/daily.md`** holds today's focus, tickets due in the next 7 days, open PRs/MRs and active Claude sessions. Agents refresh it every chat.
- **`toolbox/journal/work-journal.md`** is a concise day-by-day log of what got done.
- **`toolbox/sandbox/learning/`** holds primers and notes on things I'm learning.
- **`toolbox/sandbox/plans/`** holds plans for tickets and personal projects.
- **`toolbox/scripts/`** holds helper scripts agents run, e.g. `env-check.sh`, a names-only `.env` viewer (the only way the Claude hook lets an agent look inside one).

**Plugin dependencies** are declared in `.claude/settings.json` (`extraKnownMarketplaces` + `enabledPlugins`): ponytail, superpowers, ui-ux-pro-max and claude-security. Claude Code offers to install them when the repo is trusted. no-mistakes is not a plugin and is installed separately. Add new plugin dependencies there. [`.claude/SKILLS.md`](.claude/SKILLS.md) catalogues every installed skill, the overlaps and what to trim.

## Commands

Slash commands for my own loop. Each one wires in the best of the installed tools: **ponytail** (smallest change, always on), **superpowers** (design, plans, TDD, debugging, verification), **no-mistakes** (review → PR → CI gate) and the **tldr** reply format. Which tool wins where they overlap is decided in [`.claude/skills/WORKFLOW.md`](.claude/skills/WORKFLOW.md).

| Command | Does | Example |
|---|---|---|
| `/setup` | Clones a repo into `repositories/` and writes its `.risk0.json` config (GitHub/GitLab, Jira/issues, branch naming, apps and their commands) that every other command reads | `/setup git@github.com:org/repo.git` · `/setup repo` |
| `/planning` | Idea or ticket → agreed design → step-by-step plan, in `toolbox/sandbox/plans/` (never the repo) | `/planning PROJ-938` · `/planning #42` |
| `/implement` | Builds a plan/ticket/task in a herdr worktree, tests where logic needs them, verifies | `/implement PROJ-938` |
| `/test` | Runs the tests for what changed, adds missing ones, reports with evidence | `/test` · `/test <app>/src/<module>` |
| `/fix` | Root cause first, failing regression test, fix once | `/fix "Cannot find module 'zod'" in simulate CI` |
| `/cr` | Code review: my changes, a teammate's PR, or comments on my PR | `/cr` · `/cr 608` |
| `/understand` | Explains code or a system traced through the real code; `save` keeps it in `toolbox/sandbox/learning/` | `/understand order lifecycle save` |
| `/steps` | Does what an agent can, then lists in plain words the manual steps left for me: what to run, click or send, and what I should see | `/steps test PROJ-740 locally` · `/steps` |
| `/log` | Adds a bullet to today's entry in `toolbox/journal/work-journal.md`; no args logs this session's outcomes | `/log shipped PR #599` · `/log` |
| `/daily` | Daily "what's been happening" digest (PRs/MRs, tickets, Slack, my work) published as a private artifact, one living page | `/daily` · `/daily 3` |
| `/up` | Starts dev servers from this one session: named targets, `all`, or inferred from the current task / free text; reports the URLs. Targets come from the repo's `.risk0.json` | `/up` · `/up api web` · `/up all` · `/up the settings page` · `/up api kill-ports` (frees the targets' ports first) |
| `/build` | The whole loop in one go, agentically: `/planning` → `/implement` → `/test` (`/fix` on failures) → `/push` → `/review` my PR's comments → `/fix` → `/push` again. Stops only for gate questions (security, data, migrations, billing) and repeated failures; never merges | `/build PROJ-938` · `/build add CSV export to reports` |
| `/legend` | Prints this table | `/legend` |
| `/fix-merge-conflicts` | Resolves merge conflicts non-interactively, then validates build and tests (borrowed from Cursor's team kit) | `/fix-merge-conflicts` |
| `/verify-this` | Verifies a claim with baseline vs treatment evidence: VERIFIED / NOT VERIFIED / INCONCLUSIVE (Cursor team kit) | `/verify-this the retry fix stops duplicate sends` |
| `/weekly-review` | Weekly synthesis of my commits by bugfix, tech debt and net-new (Cursor team kit) | `/weekly-review` |
| `/statechart` | Models a system's states and transitions in TLA+, checks the rules, draws a Mermaid chart (pstack). Used in `/planning` for lifecycle tickets; asks first, first run installs TLC and Java | `/statechart order lifecycle` |
| `/thermo-nuclear-review` | Extremely strict structural review (Cursor team kit). Manual extra step before `/push` for risky changes: migrations, auth, billing, public API contracts, oversized diffs | `/thermo-nuclear-review` |
| `/unslop` | Cuts AI tells from prose (pstack). For docs, READMEs, user-facing copy and saved notes, never code | `/unslop README.md` |
| `/push` | no-mistakes gate: review, test, push, PR, CI; drives its gates; `yes` auto-accepts fixes | `/push` · `/push yes` |

### `/up` targets

`/up` reads its targets from the `apps` in the repo's `.risk0.json` (written by `/setup`): each app's folder, start steps, port and what it needs. It runs from the current session's checkout (`$ROOT` = the worktree, e.g. `<root>/worktrees/<repo>/<branch-slug>`, or `<root>/repositories/<repo>` outside one). With no argument (or free text) it infers targets from the task: changed folders in `git diff main...HEAD`, the branch name and the conversation. It starts what an app needs first and waits for those ports, gives extra free ports when several apps share a default, runs the repo's worktree setup script on a fresh worktree, never kills a process on a taken port without asking, and never resets or seeds a database.

**Ticket status follows the work automatically** (rules in `.claude/skills/WORKFLOW.md` → Ticket status). Jira: `/planning` or `/implement` → In Progress, `/push` → Waiting for approval plus a PR-link comment, merged PR → Done (on the next `daily.md` refresh). GitHub/GitLab issues: `/push` puts `Closes #n` in the PR/MR so merging closes the issue, plus optional status labels. Only forward, only tickets assigned to me.

Typical loop: `/planning` → `/implement` → `/push`, with `/test`, `/fix`, `/cr`, `/understand` and `/steps` whenever needed, `/log` to journal it. `/plan`, `/debug` and `/review` are Claude Code built-ins, hence `/planning`, `/fix` and `/cr`.

The skills live in `.claude/skills/` and are symlinked one by one into `~/.claude/skills/` so worktree sessions (separate git roots) see them. A new command needs its own symlink: `ln -s <root>/.claude/skills/<name> ~/.claude/skills/<name>`.

Agent rules: [`AGENTS.md`](AGENTS.md) (root) and [`toolbox/AGENTS.md`](toolbox/AGENTS.md).
