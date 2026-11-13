# Risk0 workspace — Agent Guide

This is Alec's development root, wherever this scaffold is cloned. **`$RISK0`** is that folder: the nearest folder at or above the current directory that holds both `repositories/` and `toolbox/` (`d=$PWD; until { [ -d "$d/repositories" ] && [ -d "$d/toolbox" ]; } || [ "$d" = / ]; do d=$(dirname "$d"); done; echo "$d"`). Every path in these rules and the skills is relative to it; never assume a fixed location like `~/Development`. It holds independent code repos plus a personal `toolbox/`. The root is a small **scaffold git repo** that tracks only the agent rules, README and folder skeleton (see *Scaffold repo* below). The `repositories/` folder itself is tracked as an empty shell; the repos inside it and personal content are not.

```
$RISK0/
├── .gitignore    ← allowlist for the scaffold repo
├── AGENTS.md     ← this file (how to work here)
├── README.md     ← human-facing overview; keep it in sync with this file
├── .claude/skills/ ← workflow commands (/setup /planning /implement /test /fix /cr /understand /steps /push /log /daily /up /setup-worktree /build /groom /legend /context-manager) + WORKFLOW.md
├── repositories/ ← main copy of every cloned code repo (folder tracked, contents ignored)
│   └── <repo>/   ← one folder per cloned repo (its own AGENTS.md, plus a local .risk0.json from /setup)
├── worktrees/    ← herdr-managed git worktrees: worktrees/<repo>/<branch-slug>/
└── toolbox/      ← personal workspace: daily tracker, work journal, learning/plans, helper scripts (has its own AGENTS.md)
```

Feature-branch worktrees live in `worktrees/<repo>/<branch-slug>/`. herdr creates them there (`worktrees.directory` in `~/.config/herdr/config.toml`). Because they sit under `$RISK0`, sessions started in a worktree also load this file. Create and remove them through herdr (`herdr worktree create/remove`), not by hand, and never commit or edit inside `worktrees/` as if it were the main checkout.

## The workflow

1. **Work happens in `<repo>`s.** Each code repo (`repositories/<repo>/`) is self-contained and onboarded with `/setup`, which writes its `.risk0.json`: the per-repo values (GitHub or GitLab repo, ticket tracker (Jira or issues), branch naming, apps and their commands) every command reads ([`.claude/skills/WORKFLOW.md`](.claude/skills/WORKFLOW.md) → Repo config). Inside a repo, follow **that repo's own `AGENTS.md`**: its conventions win for anything code-related. Feature work usually runs in a herdr worktree named after the ticket, using the repo's branch naming (e.g. `feat/proj-843-short-slug`, see `repositories/<repo>/AGENTS.md` → Git).
2. **`toolbox/` tracks and supports that work.** It is not product code. It holds:
   - `toolbox/journal/daily.md` is the live tracker: today's tasks, tickets due in the next 7 days, open PRs/MRs and active Claude sessions. **Refresh it in every chat.**
   - `toolbox/journal/work-journal.md` is the day-by-day log of what got done.
   - `toolbox/sandbox/` holds personal learning notes (`learning/`) and plans (`plans/`).
   - `toolbox/scripts/` holds helper scripts for agents, e.g. `env-check.sh`, the only allowed way to look inside a `.env` file. **Check it for an existing script before writing a one-off command.**

   Read `toolbox/AGENTS.md` for the detailed rules.
3. **The loop:** pick up a ticket from `daily.md` → plan it in `toolbox/sandbox/plans/` if it's non-trivial → implement it in the repo/worktree → log the outcome in `work-journal.md` → tick it off in `daily.md`.

## Workflow skills
Alec's slash commands live in `.claude/skills/`: `/setup`, `/planning`, `/implement`, `/test`, `/fix`, `/cr`, `/understand`, `/steps`, `/push`, `/log`, `/daily`, `/up`, `/setup-worktree`, `/build`, `/groom`, `/legend`, `/context-manager`, plus borrowed `/statechart`, `/thermo-nuclear-review`, `/unslop`, `/fix-merge-conflicts`, `/verify-this`, `/weekly-review`, `/socratic-tutor` (table in `README.md`). They share [`.claude/skills/WORKFLOW.md`](.claude/skills/WORKFLOW.md), which decides which of ponytail / superpowers / no-mistakes does each job and how superpowers bends to these rules (plans in `toolbox/sandbox/plans/`, herdr worktrees, no-mistakes for review and PRs). Each skill dir is symlinked into `~/.claude/skills/` so worktree sessions see it. Edit the source here; adding a skill means adding its symlink and its `README.md` row.

**Plugin dependencies** are declared in `.claude/settings.json` (`extraKnownMarketplaces` + `enabledPlugins`): ponytail, superpowers, ui-ux-pro-max and claude-security. Claude Code offers to install them when the repo is trusted. no-mistakes is not a plugin and is installed separately. Add new plugin dependencies there. [`.claude/SKILLS.md`](.claude/SKILLS.md) is the inventory of every skill (own + plugin), overlaps and trim candidates; refresh it when plugins change.

## Rules for agents
- **Every session, wherever it starts under `$RISK0` (including `worktrees/`):** update `toolbox/journal/daily.md` per `toolbox/AGENTS.md`. Log notable outcomes to `work-journal.md`.
- **File paths must be Cmd+clickable.** Sessions often run in a worktree while Cursor is opened at `$RISK0`, so plain relative paths don't resolve. Code inside repos keeps its normal repo-relative conventions.
  - In chat replies, write full absolute paths (`$RISK0` expanded, e.g. `<absolute $RISK0>/toolbox/sandbox/plans/foo-plan.md`, not `toolbox/...` or `~/...`). Paths in tables follow the same rule.
  - In `toolbox/` Markdown, write paths as links with a short label and a target **relative to the workspace root (`$RISK0`), starting with `/`**: ``[`<app>/src/<file>.ts:24`](/worktrees/<repo>/<branch-slug>/<app>/src/<file>.ts#L24)``. Cursor resolves a leading `/` in Markdown links against the open workspace folder, not the filesystem root, so a `/Users/...` target opens `$RISK0/Users/...` and fails. Use `#L<n>` or `#L<n>-L<m>` for line numbers, and percent-encode spaces and other odd characters in the target.
  - Point repo paths in a ticket's plan at **that ticket's worktree** (`/worktrees/<repo>/<branch-slug>/...`), because that's where the files get edited. Use the main checkout (`/repositories/<repo>/...`) only when no worktree exists, or when the file so far exists only on the branch checked out there (e.g. an unmerged PR the ticket builds on). Retarget to the worktree once it has the file.
  - **Every link must resolve.** Before finishing any edit to a `toolbox/` doc, check that each link target exists on disk (a leading `/` resolves against `$RISK0`; relative targets against the doc's folder), and fix any that don't. A link that opens "file not found" is a bug.
    - Don't link files that don't exist yet (files a plan will create, files only on an unmerged branch that isn't checked out anywhere). Write them as plain code and turn them into links once they exist.
    - Files outside `$RISK0` (screenshots, downloads) can't be linked. Copy them next to the doc with a kebab-case name and link the copy.
    - Repo docs (`docs/...`) from learning notes link through the main checkout: `/repositories/<repo>/docs/...`.
  - Generic per-app paths ("each app's `src/lib/<module>.ts`") and bare filenames stay as plain code. Keep image embeds (`![](...)`) relative so the Markdown preview can render them.
- Never put code in `toolbox/` (only small helper scripts in `toolbox/scripts/`, per `toolbox/AGENTS.md` §4), and never put personal notes/plans in a repo (unless I ask to promote a doc into the repo's `docs/`).
- Don't create new top-level folders here without asking. **Add every new code repo with `/setup <git-url>`**, which clones it into `repositories/<name>/` (its main copy; feature work happens in `worktrees/`) and writes its `.risk0.json`.
- **Keep `README.md` current.** When the layout, the list of repos or the workflow changes, update both this file and `README.md` in the same change.

## Scaffold repo
- `.gitignore` is an **allowlist**: `/*` ignores everything, then `!` rules re-include specific scaffold files. `repositories/` is the one re-included folder for code: its `.gitkeep` is tracked and `/repositories/*` ignores everything else, so repos cloned there are ignored automatically.
- Tracked: root `AGENTS.md`/`CLAUDE.md`/`README.md`/`.gitignore`, `.claude/skills/`, `toolbox/AGENTS.md`/`CLAUDE.md`, `repositories/.gitkeep`, `.gitkeep` files for the toolbox folders, and everything in `toolbox/scripts/` (scripts must hold no secrets).
- Never tracked: everything inside `repositories/`, `worktrees/`, any other repo, and journal/sandbox content.
- To track a new scaffold file, add an explicit `!` rule to `.gitignore` (and its parent folder's `!/dir/` + `/dir/*` pair). Never use `git add -f`.
