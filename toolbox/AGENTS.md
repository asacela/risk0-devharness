# toolbox — Agent Rules

`toolbox/` is Alec's personal workspace. It sits next to the code repos in `$RISK0/`. It is **not** a code repo. It holds the daily tracker, the work journal, personal learning/planning notes and a few small helper scripts for agents. Code changes always go in the repos (e.g. `../repositories/<repo>/`), never here.

```
toolbox/
├── AGENTS.md            ← this file
├── journal/
│   ├── daily.md         ← live working memory: today + next 7 days
│   └── work-journal.md  ← permanent day-by-day log of what got done
├── sandbox/
│   ├── learning/        ← primers, explainers, notes on things I'm learning
│   └── plans/           ← plans and design notes for my own work
└── scripts/             ← helper scripts agents run (see §4)
```

---

## 1. `journal/daily.md` — keep it current, every chat

`daily.md` is the single source of truth for "what am I doing today and this week". **Every session that touches `$RISK0` should update it**, even if the chat was about something else. Do it at the start of the session (refresh) and again before the session ends (record what changed).

### What to refresh, and from where

| Section | Source | How |
|---|---|---|
| **Tickets: due next 7 days** | Each repo's `tracker` (Jira or GitHub/GitLab issues) | For each repo with a `.risk0.json`, [`WORKFLOW.md`](/.claude/skills/WORKFLOW.md) → Tickets, "Mine, open". Keep those due in the next 7 days (Jira `duedate`, issue due date or milestone); the rest go under "No due date". Jira repos sharing a site are one query. Record key, summary, status, due date and link. |
| **My PRs/MRs** | Each repo's `host` (`gh` or `glab`) | For each repo with a `.risk0.json`, [`WORKFLOW.md`](/.claude/skills/WORKFLOW.md) → Host commands: "My open PRs" plus "Reviews I owe". Match each to its ticket key via the config's `branch` pattern (`feat/proj-843-...` → `PROJ-843`, `feat/843-...` → `#843`) or the title. |
| **Merged → Done** | host + tracker | For each of my PRs merged since the last refresh ("Merged since a date", mine), match its ticket key from the branch or title. Jira: if still open and assigned to me, move it to Done ([`WORKFLOW.md`](/.claude/skills/WORKFLOW.md) → Ticket status). Issues close themselves from `Closes #n`; just note it under Tickets. |
| **Active work (Claude sessions)** | `~/.claude/projects/*/*.jsonl` | See below. |
| **Top 3 / tasks / inbox** | The conversation | Whatever I tell you, plus anything that came up in the session. |

### Finding what I'm actively working on

Claude Code stores each session as `~/.claude/projects/<cwd with / and . replaced by ->/<session-id>.jsonl`. Worktrees live under `$RISK0/worktrees/<repo>/<branch-slug>/` (older ones under `~/.herdr/worktrees/<repo>/`), so the project folder name shows the branch/ticket.

```sh
# sessions touched in the last 2 days, newest first
find ~/.claude/projects -name '*.jsonl' -mtime -2 -print0 | xargs -0 ls -t --
# title, branch and cwd for one session
grep -m1 -o '"aiTitle":"[^"]*"' -- "$f"; grep -m1 -o '"gitBranch":"[^"]*"' -- "$f"; grep -m1 -o '"cwd":"[^"]*"' -- "$f"
```

Group sessions by worktree/branch → ticket key, and summarize each as one line: *what it is · where it left off · next step*. Skip trivial sessions (one-off shell help, config tweaks) and skip the current session.

### Rules
- **Today goes on top.** If the newest day section isn't today, start a new one from the template. Carry over unchecked items from the previous day (mark the old ones `[>]`) and put them in today's section. Don't silently drop them.
- **Keep about 7 days of day sections.** When a day rolls off, make sure its done items are in `work-journal.md`, then delete it from `daily.md`.
- Refreshed sections (Tickets, PRs, Active work) are **overwritten** on each refresh, not appended to. Stamp them with `_Refreshed: YYYY-MM-DD HH:MM_`.
- Manual sections (Inbox, Backlog, Waiting on, Top 3, parking lot) are **mine**. Edit them only to add things I said or to check things off. Never reword or reorganize them.
- If a source is unavailable (MCP not authed, `gh`/`glab` fails), leave the last data in place, note `⚠️ stale — <reason>` next to the stamp and keep going.
- Status keys: `[ ]` todo · `[~]` in progress · `[x]` done · `[>]` moved · `[-]` dropped. Priority: 🔴 must today · 🟠 should · ⚪ nice to have.

---

## 2. `journal/work-journal.md` — concise daily log

A permanent record of what I actually did, used for standups, weekly updates and reviews. **Newest day on top**, grouped under `## Week of YYYY-MM-DD` (Monday).

### Rules
- **One entry per day, a few bullets, high level.** Write outcomes, not process: "Shipped error capture for the API (PROJ-892, PR #412)", not "looked at files, ran tests".
- Format: `- \`#tag\` What happened — outcome · PROJ-123 / PR #456` (GitLab: `#42 / !456`). Tags: `#ship` `#build` `#fix` `#review` `#ops` `#learn` `#meeting`.
- Update it whenever something meaningful finishes during a chat, and at end of day from `daily.md` (checked items + Active work progress).
- If I come back after missing days, backfill them from Claude sessions (`mtime`/`aiTitle`), my merged PRs (WORKFLOW.md → Host commands) and ticket moves. Mark backfilled days `_(backfilled)_`.
- Append only. Never rewrite past entries unless I ask.
- On Fridays (or the first chat after), add a 3-line **Week summary** under that week's heading.

---

## 3. `sandbox/` — my learning and planning space

`sandbox/` holds **Markdown for my personal work**: learning notes and plans. It is my scratch space, not team documentation.

- `sandbox/learning/` holds primers and explainers on systems, tools and concepts I'm getting up to speed on (e.g. `<tool>-primer.md`, `architecture-overview.md`). When I ask "explain X / help me understand Y" and want it kept, write it here.
- `sandbox/plans/` holds plans for tickets and personal projects before or during implementation. Name them `<key>-<slug>-plan.md` when tied to a ticket (e.g. `proj-740-short-slug-plan.md`, or `42-short-slug-plan.md` for issue #42), otherwise `<slug>-plan.md`.
- Use kebab-case filenames. Start each file with an H1 and a one-line purpose.
- Write every file path in sandbox docs as a link whose target is relative to the workspace root (`/worktrees/...`, `/toolbox/...`, `/repositories/<repo>/...`) so it's Cmd+clickable in Cursor opened at `$RISK0`. A `/Users/...` target doesn't work: Cursor resolves a leading `/` against the workspace folder. This covers links between plans and pointers to repo files. Every link must resolve: check each target exists before finishing an edit, and leave files that don't exist yet unlinked. See the root `AGENTS.md` for the full rules.
- Plans should link to the ticket and PR/MR and say what is decided and what is still open. Update the plan as the work evolves. Don't create v2 copies.
- Nothing here gets committed to a code repo. If a sandbox doc should become real team docs, tell me and copy it into the repo's `docs/`. Don't move it silently.
- Only Markdown (plus the odd diagram/image). No code projects; prototypes go in a repo branch or worktree.

---

## 4. `scripts/` — helper scripts for agents

`scripts/` holds small, standalone scripts that agents (and I) run while working: workspace and secrets tooling, not product code. Product code and repo tooling still go in the repos.

**Look here first.** Before writing a one-off shell command for a task, check `scripts/` for a script that already does it and use it. Run scripts by their full absolute path (`bash $RISK0/toolbox/scripts/<name>.sh ...` with `$RISK0` expanded, see root `AGENTS.md`), not a copy.

| Script | What it does |
|---|---|
| [`env-check.sh`](/toolbox/scripts/env-check.sh) | Names-only view of `.env` files: each variable's name, set/empty, value length and a known non-secret prefix (`phc_`, `postgresql://`...). Never prints a value. **The only way to inspect a `.env` file:** the `~/.claude/scripts/block-env-access.sh` hook blocks every other command that touches one, and allows this script only at its exact path. Usage: `bash $RISK0/toolbox/scripts/env-check.sh <file> [file ...]` (no args: every `.env*` in the current dir), with nothing chained or piped. |
| [`daily-digest.sh`](/toolbox/scripts/daily-digest.sh) | Runs `/daily` as a background Claude session (`claude --bg`) and republishes the Daily Update artifact. Schedule it with cron or launchd (see its header; on macOS have cron kickstart a launchd job, since cron alone cannot read the keychain `gh`/`glab` need). Set `DAILY_CWD` to a repo's main checkout to give the session that repo's plugins. The artifact's Refresh button copies the manual command. Log: `~/Library/Logs/daily-digest.log`. Usage: `bash $RISK0/toolbox/scripts/daily-digest.sh`. |

Rules:
- One script per job, with a header comment saying what it does and how to call it. Add every new script to the table above.
- Bash or Python with no dependencies to install. No `node_modules`, venvs or build steps.
- Never print secret values. A script that reads secrets prints names, presence and lengths only.
- Moving or renaming a script that a hook or another config refers to (e.g. `env-check.sh`) means updating that reference in the same change.
