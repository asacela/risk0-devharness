---
name: up
description: Start a repo's dev servers locally from this one session — named targets, "all", or inferred from the current task or free text. Use for /up, /up <app>, /up api web, /up all, /up the settings page, "start the servers", "spin up what I need".
argument-hint: "[targets | all | free text]  (targets are the repo's runnable apps)"
---

# /up

**Where:** the repo checkout of the current session: `git rev-parse --show-toplevel` when inside a worktree under `$RISK0/worktrees/<repo>/`, else `$RISK0/repositories/<repo>`. Call it `$ROOT`. Run each command from the folder shown, and use absolute paths.

**Targets are the `apps` in the repo config** (`.risk0.json`, WORKFLOW.md → Repo config): each has a `dir`, `dev` steps in order, a `port` and the apps it `needs`. Apps with no `dev` steps aren't targets. No config: stop and offer `/setup`.

`$ARGUMENTS` picks what to start, from this one session (several background servers at once):
- Target names, space or comma separated: `/up api web`.
- `all`: every target with a `port`. Apps without one (mobile/native) only when named.
- Empty or free text (`/up the settings page`): infer from the text, else from the current task: `git diff --name-only main...HEAD` plus uncommitted files, the branch name, and this conversation. A changed file maps to the app whose `dir` contains it, and an inferred target pulls in its `needs`. Nothing to infer from: ask which targets, listing them.
- Unknown word: list the targets and stop.
- `kill-ports` (alone or alongside targets, e.g. `/up api kill-ports`): you've pre-approved freeing the ports of the chosen targets. Before starting, kill whatever listens on each of their ports (`lsof -ti :<port> | xargs kill`) and say what you killed (PID and its cwd). Only those ports, nothing else. Alone, it infers targets as for empty args.

Before starting, print one line: the chosen targets and why. Start `needs` first and wait until their port answers (poll `lsof -i :<port>`, up to about 2 minutes), then start the rest together in one message.

If dependencies are missing (`node_modules` or the equivalent), install them with the repo's package manager first. Run the long-running server with `run_in_background`, never in the foreground. Don't run a command that isn't in the target's `dev` steps.

Rules:
- Explicitly named targets that omit something they `need`: check its port; if it isn't up, say so and offer to start it, don't start it unasked. Inferred sets and `all` include it.
- Ports: when several targets default to the same port, give the extras free ports through the framework's port flag. Check each port with `lsof -i :<port>` first; if something else holds it, say what and ask before killing it (unless `kill-ports` was passed). Never kill another worktree's server unless asked, which `kill-ports` counts as.
- Setup: in a fresh worktree, run the config's `worktreeSetup` (if set) once from `$ROOT`. If an env file the docs say you create by hand is missing, stop and say which one and where its example lives; don't guess values or ports.
- Guards: obey every entry of the config's `guards`; if one would be broken, stop and say which.
- Data: migrations only against a local DB. Never reset or seed a database from here, and never point at a remote or production one (if the env does, stop and say so).
- After starting, read a few lines of each background output to confirm it's listening, then reply with one table: target, URL, folder. Nothing else.
