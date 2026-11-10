# Workflow rules (shared by every command skill)

Each command skill reads this file first. It decides which installed tool does which job, and how superpowers bends to this workspace's rules.

## Who wins

| Job | Use | Not | Why |
|---|---|---|---|
| Coding style and scope | ponytail (always on via its hook) | — | Smallest complete change. |
| Fuzzy idea → design | `superpowers:brainstorming` | — | Best at pulling out requirements. |
| Design → steps | `superpowers:writing-plans` | — | Bite-sized tasks with exact files. |
| Worktrees | `herdr worktree create` | `superpowers:using-git-worktrees` | Workspace rule (root `AGENTS.md`). |
| Running a plan | `superpowers:subagent-driven-development` | `executing-plans` (only if Alec asks for inline) | Fresh context per task, review between tasks. |
| Logic-bearing code | `superpowers:test-driven-development` | — | Trivial edits need no test (ponytail). |
| Bugs | `superpowers:systematic-debugging` | — | Root cause before fix. |
| "It's done" | `superpowers:verification-before-completion` | — | Evidence before claims. |
| Review, push, PR/MR, CI | no-mistakes (the push command) | `requesting-code-review`, `finishing-a-development-branch` | It reviews, tests, lints, opens the PR and babysits CI. |
| Reviewing code by hand | `ponytail:ponytail-review`, then `/thermo-nuclear-review` (both run by `/cr`) | `/code-review` (only to post inline PR comments: `--comment`) | Reads the connected code, plain-English findings, then a strict structural pass. |
| Modelling states and transitions | `/statechart` (manual, asks first) | — | TLA+ model checker with a Mermaid chart; use in `/planning` for lifecycle tickets. |
| Risky change, extra scrutiny | `/thermo-nuclear-review` (always inside `/cr`; before `/push` it asks first) | — | Harsh structural review: migrations, auth, billing, public API contracts, oversized diffs. |
| Cutting AI tells from prose | `/unslop` | — | Docs, READMEs, user-facing copy, saved learning notes. Prose only, never code. |
| Feedback on my PR | `superpowers:receiving-code-review` | — | Verify each comment, no blind agreement. |
| Output shape | tldr format, below | — | `/tldr` is user-only, so the shape is copied here. |

## Repo config (`.risk0.json`)

Every per-repo value comes from `.risk0.json` at the root of the repo's **main checkout** (`$RISK0/repositories/<repo>/.risk0.json`), written by `/setup` and excluded from git via `.git/info/exclude`. From a worktree, find it with `"$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")/.risk0.json"`. Missing file: say so and offer `/setup`; never guess the values. A `null` field means the repo doesn't have that thing: skip the step that needs it.

```json
{
  "host": { "type": "github", "repo": "<org>/<repo>" },
  "tracker": { "type": "jira", "site": "<site>.atlassian.net", "project": "PROJ" },
  "branch": "feat/{key}-{slug}",
  "worktreeSetup": "bash scripts/setup-worktree.sh",
  "worktreeDoctor": "toolbox/scripts/worktree-doctor.sh",
  "worktreeFiles": [{ "from": ".claude/repo-settings.local.json", "to": ".claude/settings.local.json" }],
  "guards": ["Never run db:reset or db:seed", "Stop if a hosted-database URL is set in the app env"],
  "risky": ["an internal RPC contract"],
  "debugSkills": ["posthog:investigating-error-issue", "posthog:investigating-logs"],
  "deployWorkflow": "Deploy",
  "apps": {
    "api": { "dir": "api", "dev": ["npm run db:up", "npm run dev"], "port": 4000, "needs": [],
             "test": "npm test", "lint": "npm run lint", "typecheck": "npm run typecheck" },
    "web": { "dir": "web", "dev": ["npm run dev"], "port": 3000, "needs": ["api"],
             "test": "npm test", "lint": "npm run lint", "typecheck": null }
  }
}
```

All fields below `branch` are optional; a missing or `null` one means the repo has none, so skip that step.

`apps.*.dir` is relative to the repo root; `dev` runs in order from it, the last step being the long-running server. `needs` lists apps that must be up first.

- `host.type`: `github` or `gitlab`. `host.repo` is the `<org>/<repo>` path from the origin URL (GitLab subgroups keep every segment).
- `tracker.type`: `jira` (with `site` and `project`), `github` or `gitlab` (issues in `host.repo`, nothing else needed; optional `"labels": { "inProgress": "<label>", "review": "<label>" }` for boards driven by labels), or `tracker: null` for none.
- `worktreeDoctor`: a read-only checker script (path relative to `$RISK0`) that `/setup-worktree` runs against a worktree; it may offer `--fix`.
- `worktreeFiles`: local files (`from` relative to `$RISK0`, `to` relative to the worktree) copied in after `worktreeSetup`, for config a repo gitignores (e.g. per-worktree plugin settings). `mkdir -p` the target folder; never overwrite an existing file; never commit them.
- `guards`: hard "never" rules in plain words. `/up`, `/setup-worktree` and `/groom` obey them on top of the built-in rules (never reset or seed data, never use a remote or production database), and stop and say so when one would be broken.
- `risky`: extra triggers that make `/push` and `/groom` ask to run `/thermo-nuclear-review`, added to the built-in list (migrations, auth, billing, oversized diffs).
- `debugSkills`: skills `/fix` invokes to pull real production errors and logs.
- `deployWorkflow`: the CI workflow name `/daily` reports as the "Backend deploy" tile; `null` leaves the tile `unk`.

## Overrides on superpowers (workspace rules win)

- **Plans never go in the repo.** One file per piece of work: `$RISK0/toolbox/sandbox/plans/<key>-<slug>-plan.md` (or `<slug>-plan.md`), with `## Design` (brainstorming) and `## Plan` (writing-plans) sections. Never write `docs/superpowers/...` and never commit it. Update in place, no v2 copies. Links follow root `AGENTS.md` (targets like `/worktrees/<repo>/<slug>/...`, every link must resolve).
- **Worktrees come from herdr:** `herdr worktree create --cwd $RISK0/repositories/<repo> --branch <config branch, e.g. feat/proj-123-short-slug>`, then the config's `worktreeSetup` inside it (if set). It lands in `$RISK0/worktrees/<repo>/<branch-slug>/`. Work there with absolute paths.
- **Finishing is the push command.** Never merge, force push or delete branches yourself.

## Host commands (GitHub or GitLab)

Skills say **PR**; on GitLab that means a merge request (MR, `!123`). Never hardcode `gh` or `glab`: look the action up here by `host.type` and pass `-R <host.repo>`. GitLab line-level threads also come from the GitLab MCP (`mr_discussions`) when connected.

| Action | GitHub (`gh`) | GitLab (`glab`) |
|---|---|---|
| PR for a branch | `gh pr list --head <branch> --state all --json number,state,url` | `glab mr list --source-branch <branch> --all -F json` |
| PR author, branch, reviews | `gh pr view <n> --json author,headRefName,reviews,comments` | `glab mr view <n> -F json` |
| PR diff | `gh pr diff <n>` | `glab mr diff <n>` |
| PR review comments | `gh pr view <n> --comments` + `gh api repos/<repo>/pulls/<n>/comments` | `glab mr view <n> --comments` (+ MCP `mr_discussions`) |
| My open PRs | `gh pr list --author @me --state open --json number,title,headRefName,reviewDecision,isDraft,url` | `glab mr list --author=@me -F json` |
| Reviews I owe | `gh pr list --search "review-requested:@me" --state open` | `glab mr list --reviewer=@me -F json` |
| Merged since a date | `gh pr list --state merged --search "merged:>=YYYY-MM-DD" --json number,title,author,mergedAt,url` (add `--author @me` for mine) | `glab mr list --merged -o merged_at -F json` (add `--author=@me`), keep `merged_at >=` the date |
| Failed CI on `main` | `gh run list --branch main --status failure` | `glab ci list --ref main --status failed` |

## Tickets

A ticket comes from the repo config's `tracker`. `tracker: null`: skip every ticket step silently.

| | `jira` | `github` / `gitlab` issues |
|---|---|---|
| Key | `PROJ-123`; from a branch `feat/proj-123-...` | `#123`; from a branch `feat/123-...` |
| Fetch | Atlassian MCP `getJiraIssue` | `gh issue view 123 --comments` / `glab issue view 123 --comments` |
| Mine, open | `searchJiraIssuesUsingJql`: `assignee = currentUser() AND statusCategory != Done ORDER BY duedate ASC` | `gh issue list --assignee @me` / `glab issue list --assignee=@me -O json` (due date: milestone or GitLab `due_date`) |
| Moved in the last N days | JQL `project = <project> AND updated >= -<N>d ORDER BY updated DESC` | `gh issue list --state all --search "updated:>=YYYY-MM-DD"` / `glab issue list --all --order updated_at -O json`, keep `updated_at >=` the date |
| Comment | `addCommentToJiraIssue` | `gh issue comment 123 -b` / `glab issue note 123 -m` |

Acceptance criteria (Jira field or the issue body) are the spec. Plan files are named `<key>-<slug>-plan.md` with the key lowercased and `#` dropped (`proj-123-...`, `123-...`).

## Ticket status

Commands keep the ticket's status in step with the work. They move it automatically and list each move in the reply (`PROJ-123: To Do → In Progress`, `#123: + doing`).

- **Ticket key:** from the input, else the branch name. No key, or `tracker` is `null`: skip silently.
- **Lifecycle:**

| When | `jira` | `github` / `gitlab` issues | Who |
|---|---|---|---|
| `/planning` or `/implement` starts on a ticket | In Progress (from To Do only) | add `labels.inProgress` if set | the command |
| `/push` has an open PR | Waiting for approval (transition "Request approval"), plus a comment with the PR link (once per PR) | `Closes #123` in the PR body (that links it), swap `labels.inProgress` for `labels.review` if set | `/push` |
| PR merged | Done | nothing: the host closes it from `Closes #123` | the `daily.md` refresh (`toolbox/AGENTS.md` §1) |

- **How (Jira):** Atlassian MCP, `cloudId:` the config's `tracker.site`. `getTransitionsForJiraIssue`, pick the transition by its **target status name** (IDs differ by issue type), then `transitionJiraIssue`.
- **How (issues):** `gh issue edit 123 --add-label/--remove-label` / `glab issue update 123 --label/--unlabel`. No `labels` in the config: the PR link is the only update.
- **Guards:** only forward along that table. Never move a ticket out of Done, On Hold or SALES LOST, never reopen a closed issue, and never touch a ticket assigned to someone else (check `assignee` first). An epic is never moved. If the move fails, say so in one line and carry on; the work matters more than the board.

## Output shape (tldr, terminal form)

Final replies over ~150 words start with:

```
TL;DR
1. <what is true>
2. <the one next action>
3. <cost or caveat that would change the decision>
--- detail ---
<everything else, not thinned out>
```

Destructive actions, security findings, verbatim errors and anything that bills stay above the divider. Prompts to subagents ask them to report in this block only:

````
```tldr
status: ok | partial | blocked | failed
summary: <result, one line>
findings:
  - <max 5, most important first>
next: <one action or "none">
risk: none | low | high — <why>
```
````

## Close out

When something finishes: tick it in `toolbox/journal/daily.md` and add a `work-journal.md` bullet (`toolbox/AGENTS.md` §1–2).
