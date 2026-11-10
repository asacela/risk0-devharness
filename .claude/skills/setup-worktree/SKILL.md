---
name: setup-worktree
description: Make a worktree of any repo under $RISK0 ready to run locally — copy config, install deps, isolate its database and ports, repair drift, check the stack. Use for /setup-worktree, "set up this worktree", "get this branch running locally", "my worktree can't start", "worktree shares a DB".
argument-hint: "[worktree path or <repo>/<branch-slug>]  (default: the current worktree)"
---

# /setup-worktree

Read `$RISK0/.claude/skills/WORKFLOW.md` first. This skill knows no repo's layout. It finds each repo's own setup instructions and tooling, runs them in order, and reports. It prepares a worktree; `/up` (or the repo's own start commands) runs it.

`$ARGUMENTS` = a worktree path or `<repo>/<branch-slug>` under `$RISK0/worktrees/`. Empty: the worktree of the current directory (`git rev-parse --show-toplevel`). If that resolves to a main checkout under `repositories/`, stop and say so: this is for worktrees. A worktree that doesn't exist: create it through herdr (`herdr worktree create`), never by hand.

Call it `$WT`, its folder name `$SLUG`, its repo `$REPO`, and the repo's main checkout `$MAIN` (`dirname "$(git -C $WT rev-parse --path-format=absolute --git-common-dir)"`).

## Rules

- Never print, cat or grep a `.env*` file. Names only: `bash $RISK0/toolbox/scripts/env-check.sh` from the folder. Edit only non-secret lines (ports, container and database names, URLs) and never echo a secret into the chat.
- Never run a destructive data command (reset, seed, drop, down on someone else's resources) and never point a worktree at a shared or production database. If a config points at a hosted database, stop and say so.
- Obey the config's `guards` (WORKFLOW.md → Repo config).
- Never stop or recreate another worktree's containers or servers. A taken port or name means pick another.
- Idempotent: re-running changes nothing that is already right. Say what each step did or kept.
- The repo's own docs win over this file where they disagree.

## Steps

1. **Discover.** Read `$WT/AGENTS.md` (or `CLAUDE.md`) and look for worktree guidance: a setup script (`ls $WT/scripts`, anything named like `*worktree*`), a doc on worktrees (`grep -ril worktree $WT/docs $WT/README.md`), and any per-worktree config template (a `*.example` whose name or comments mention worktree). Read what it finds once. No guidance found: say so, and stop after step 5's checks rather than inventing a setup.
2. **Config and dependencies.** Run the repo's setup script from `$WT` if it has one (background if slow, wait for its done line). It should copy gitignored config from `$MAIN` without overwriting and install dependencies. No script: copy nothing, and report which dependencies look missing (`node_modules`, venvs) and the install command from the repo's docs.
3. **Doctor, read-only.** If the config has `worktreeDoctor` and that script exists under `$RISK0`, run it against `$WT` and read every WARN. No `worktreeDoctor`: skip. Then copy each `worktreeFiles` entry that isn't already in `$WT`.
4. **Isolation.** Do what the repo's docs say a worktree needs of its own: a private database, cache, or port set, following its template and literal-value rules. General method:
   - Pick free ports, never the main checkout's: list used ones with `docker ps --format '{{.Names}} {{.Ports}}'` and `lsof -nP -iTCP -sTCP:LISTEN`, start from the template's default, go up by one until free.
   - Name containers and any compose project after `$SLUG`, so bringing this worktree up cannot recreate another's. If the repo's own script uses one shared project name, run the equivalent command with a per-worktree name and say you did.
   - Then migrate or initialize as the docs say. Never seed or reset.
   - Existing per-worktree config: verify its containers are up and its ports don't collide, migrate, and do not rewrite it.
5. **Repair drift.** If the doctor offers `--fix`, run it, then re-run it read-only and report what is left.
6. **Report.** One table: check, state (ok / fixed / needs you), and for each "needs you" the one exact command or edit. Then the resources this worktree now owns (containers, database, ports) and the next command (`/up`, or the repo's own start command). If the repo allows one running server of some kind at a time, say which worktree currently holds it and ask before anything stops it.

## Not in scope

Starting servers, creating test data, anything under `$MAIN`, and repo-specific knowledge: if a step needs it, it belongs in that repo's docs or script, not here.
