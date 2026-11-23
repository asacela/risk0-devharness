---
name: daily
description: Daily digest as a private interactive artifact — merged/open PRs, Jira movement, Slack activity, app and backend health (new errors, CI, deploys), and my own work, since the last digest. Use for /daily, "give me the daily update", "what happened since yesterday", "catch me up".
argument-hint: "[days back, default: since last digest or 1]"
---

# /daily

Builds one overarching digest of the team, app and backend health, and my own work, and publishes it as a private Artifact. Read-only everywhere except the artifact and `daily.md`. Runs locally (never in a cloud routine): `$RISK0/toolbox/scripts/daily-digest.sh` runs it headless from launchd on weekdays, and the page's Refresh button copies that command. It may run with no one watching, so never ask a question; skip and report instead.

## 1. Window
`$ARGUMENTS` = days back. Default: since the previous digest (stamp in `$RISK0/toolbox/journal/daily.md`, line `_Last routine: YYYY-MM-DD HH:MM_`), else 1 day (3 on Mondays, to cover the weekend).

## 2. Gather (run independent calls in parallel; skip a source that fails and say so in the digest)
Repos: every `$RISK0/repositories/<repo>/.risk0.json`. Take each one's `host` and `tracker` from it (WORKFLOW.md → Repo config, Host commands, Tickets) and label rows with the repo when there is more than one.
- **GitHub/GitLab** (per repo's `host`, commands from WORKFLOW.md → Host commands): merged PRs in the window (all authors: `gh pr list --state merged --search "merged:>=YYYY-MM-DD" --json number,title,author,mergedAt,url`), merged count per day for the last 7 days (for the sparkline), open PRs and their review state, PRs awaiting my review.
- **CI and deploys** (`gh run list --branch main --limit 15 --json name,conclusion,createdAt,url`): latest conclusion of each workflow on `main`, failures in the window, the latest run of the config's `deployWorkflow`. Cancelled runs are cancelled, never failed.
- **Tickets** (per repo's `tracker`, WORKFLOW.md → Tickets; Jira: Atlassian MCP `searchJiraIssuesUsingJql`, cloudId `tracker.site`): `project = <tracker.project> AND updated >= -<N>d ORDER BY updated DESC` for what moved, plus mine due in the next 7 days and anything overdue. Large results spill to a file: extract fields with `jq`.
- **Slack** (Slack MCP): `slack_search_public` for the window and read the busiest channels; decisions, incidents, questions aimed at me, launches. Skip chatter. If search returns nothing, say so.
- **PostHog health** (`mcp__plugin_posthog_posthog__exec`): first `call project-get {}` for the project **name**, and label every PostHog number with it. Then `call query-error-tracking-issues-list` with `firstSeenAfter` and `dateRange.date_from` set to the window (new issues, top 10), and again without `firstSeenAfter` (top active issues). For backend logs: `call logs-attribute-values-list {"key":"service.name","attribute_type":"resource"}`, then `call query-logs` with `severityLevels: ["error","fatal"]`, the discovered service, `dateRange`, `limit` 100, `excludeAttributes: true`, and group identical `body` lines with a count. One `exec` per call. If the project is **Sandbox**, say "Sandbox project, not production" on the card and in the Sources row, and set the app-errors and backend-logs tiles to `unk`, never `good`: Sandbox is not the live app. Never switch projects or change MCP scopes to reach production data; if it is unreachable, say so.
- **Me**: run the `/context-manager` gather (sessions, worktrees, plans) and bullets from `$RISK0/toolbox/journal/work-journal.md` in the window.
- **Standup (always the last 7 days, whatever the window)**: my PRs `gh pr list --author @me --state all --search "created:>=YYYY-MM-DD OR merged:>=YYYY-MM-DD" --json number,title,state,mergedAt,body`, PRs I reviewed, work-journal entries and tickets I created in those 7 days.
- **Calendar** (optional): today's meetings, one line.

## 3. Write the artifact
Never edit or copy the template. Read `$RISK0/.claude/skills/daily/example.html` once (a complete sample page with fake values, for shape only), then write two fragment files in the scratchpad and assemble the page with the build script:
- `mast.html`: the inside of `<header class="mast">`: eyebrow `<p id="eyebrow" data-updated="<ISO time with offset>">`, `<h1 id="greet">`, the verdict, exactly four `.vital` tiles, and the `.counts` row with one `#spark` (`data-vals` = merged PRs per day, last 7 days, oldest first).
- `sections.html`: the `<details class="sec">` blocks only.
- Run `python3 $RISK0/.claude/skills/daily/build.py --mast mast.html --sections sections.html --foot "Updated <date time> PT · runs locally on weekdays · Refresh copies the command to re-run it" --out daily.html` and publish `daily.html`. If the build fails, fix the fragments and rerun; never publish around a failure.
- Rules: `data-who` (alec | clark | sydney | bot | other | all) on `.todo li`, `.feed li`, `tbody tr`, `.card` and Jira `li`; a unique `data-id` on every `.todo li` (e.g. `pr-695`); tile classes good | warn | bad | unk.
- Do not redesign the page on a daily run; design changes go in `template.html`.
- Title stays `Daily Update`. Eyebrow carries the update time (`data-updated` as an ISO timestamp with offset).
- **Vital tiles** (good/warn/bad/unk): Main CI, Backend deploy (`deployWorkflow`; `unk` if none), App errors, Backend logs. A tile is `good` only when a source was read and clean. An unreadable source is `unk` with the reason.
- **Verdict**: one sentence, the single most important thing, bold on two or three facts.
- **Sections in order**, each omitted if empty: Today's focus (3 to 5 cards), Needs me (checkable `li`s, each with a stable `data-id`), Health, Shipped, Standup, In flight (bot drafts collapsed into one row), Jira, Slack, My work, Sources.
- **Standup** (`id="s-standup"`, `data-who="alec"`): what I did in the last 7 days, 4 to 8 `.card`s ordered by impact. Each card: `h4` = plain-words outcome with PR or ticket links; `p` = one high-level sentence of what changed, then `<b>Why it matters:</b>` one sentence on the user, ops or business effect. Merged work first, then open PRs, reviews, planning and tickets. State only what the PR, ticket or journal shows; no guessed impact numbers. Summary line: `.sub` with counts (merged, open, reviewed).
- Health cards: new errors (name, message, events, users, first seen, link), top active, backend log errors grouped with counts, CI and deploys. Only state what the sources show; do not guess causes.
- Every item links to its PR, ticket, issue or message.
- Publish with the Artifact tool to the same URL (stored on the `_Last routine_` line); read it first with `action: "read"`. Pass a one-sentence `description`. No `capabilities`.

## 4. Finish
- Update `_Last routine: YYYY-MM-DD HH:MM · <artifact URL>_` in `daily.md`.
- Reply with the TL;DR bullets and the artifact link. Nothing else.
