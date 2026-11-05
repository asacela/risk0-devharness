---
name: setup
description: Clone a repo into $RISK0/repositories and write its .risk0.json config, which every other command reads for that repo (GitHub or GitLab repo, ticket tracker (Jira or issues), branch naming, worktree setup, apps and their dev/test/lint commands). Use for /setup <git-url>, /setup <repo> to redo or update one, "set up this repo", "onboard repo X".
argument-hint: "<git-url | repo name>"
---

# /setup

Read `$RISK0/.claude/skills/WORKFLOW.md` first; its **Repo config** section defines `.risk0.json`.

1. **Clone.** `$ARGUMENTS` is a git URL: `git clone <url>` into `$RISK0/repositories/<name>` (skip if that folder exists). A repo name or path: use that existing checkout. Nothing: ask. That folder is `$MAIN`.
2. **Detect** every field, reading only (no installs, no `.env` contents):
   - `host`: `type` and `repo` from `git -C $MAIN remote get-url origin` (`github.com` → `github`, `gitlab.com` or a self-hosted GitLab → `gitlab`).
   - `tracker`: Jira-like prefixes (`PROJ-123`) in recent branch names (`git branch -r`) and PR titles (WORKFLOW.md → Host commands) mean `jira`, with the site from the Atlassian MCP (`getAccessibleAtlassianResources`) if connected. Otherwise, open issues on the host (`gh issue list` / `glab issue list -R <repo>`) mean `github`/`gitlab`; add `labels` only if the repo has workflow labels (e.g. `doing`, `workflow::review`).
   - `branch`: the pattern recent branches follow (e.g. `feat/{key}-{slug}`).
   - `worktreeSetup`: a setup script the repo documents or ships (e.g. `scripts/setup-worktree.sh`).
   - `apps`: from `$MAIN/AGENTS.md`/`CLAUDE.md` (Commands sections), the README, and each app folder's `package.json` (or the language's equivalent): folder, dev steps in order, port, which apps it needs, and test/lint/typecheck commands. A single-app repo has one app with `dir: "."`.
3. **Confirm.** Show the proposed config. Ask Alec only for what detection left empty or unsure (e.g. tracker, Jira site, ports), in one `AskUserQuestion`. Unknown and unneeded: `null`, never a guess.
4. **Write** `$MAIN/.risk0.json`, then append `.risk0.json` to `$MAIN/.git/info/exclude` (if not already there) so it stays local and is never committed. Re-running `/setup` on a configured repo shows a diff of old vs new and asks before overwriting.
5. **Gate.** If `no-mistakes status` in `$MAIN` says `repo not initialized`, ask once, then `no-mistakes init` there.
6. Reply with the config path and one line per field that is `null`, saying which command will lack it.
