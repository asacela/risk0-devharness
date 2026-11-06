---
name: daily
description: Daily digest as a private interactive artifact — merged/open PRs/MRs, ticket movement (Jira or issues), Slack activity, CI and error health where connected, and my own work, since the last digest. Use for /daily, "give me the daily update", "what happened since yesterday", "catch me up".
argument-hint: "[days back, default: since last digest or 1]"
---

# /daily

Builds one overarching digest of the team, app and backend health, and my own work, and publishes it as a private Artifact. Read-only everywhere except the artifact and `daily.md`. Runs locally (never in a cloud routine): `$RISK0/toolbox/scripts/daily-digest.sh` runs it headless (schedule it with cron or launchd, see its header), and the page's Refresh button copies that command. It may run with no one watching, so never ask a question; skip and report instead.

## 1. Window
`$ARGUMENTS` = days back. Default: since the previous digest (stamp in `$RISK0/toolbox/journal/daily.md`, line `_Last routine: YYYY-MM-DD HH:MM_`), else 1 day (3 on Mondays, to cover the weekend).

## 2. Gather (run independent calls in parallel; skip a source that fails and say so in the digest)
Sources per repo: every `$RISK0/repositories/*/.risk0.json` (WORKFLOW.md → Repo config); run the host and ticket queries once per configured repo, using WORKFLOW.md → Host commands and → Tickets for its `host.type` and `tracker.type`.
- **Host** (GitHub or GitLab): merged PRs in the window (all authors, "Merged since a date"), merged count per day for the last 7 days (for the sparkline), open PRs and their review state, PRs awaiting my review.
- **CI and deploys**: "Failed CI on `main`" plus the latest conclusion of each workflow/pipeline on `main`, failures in the window, and the latest deploy run if the repo has one. Cancelled runs are cancelled, never failed.
- **Tickets** (skip if `tracker` is `null`): "Moved in the last N days" for what moved, plus "Mine, open" due in the next 7 days and anything overdue. Large results spill to a file: extract fields with `jq`.
- **Slack** (Slack MCP): `slack_search_public` for the window and read the busiest channels; decisions, incidents, questions aimed at me, launches. Skip chatter. If search returns nothing, say so.
- **App and log health** (optional, only if an observability MCP such as PostHog, Sentry or Datadog is connected): new error issues in the window (top 10), top active issues, and error-level log lines grouped by message with a count. Label every number with the project or environment name it came from. If that project is a sandbox or staging one, say so on the card and set the app-errors and logs tiles to `unk`, never `good`. Never switch projects or change MCP scopes to reach production data; if it is unreachable, say so. Not connected: set those tiles to `unk` ("not connected").
- **Me**: run the `/context-manager` gather (sessions, worktrees, plans) and bullets from `$RISK0/toolbox/journal/work-journal.md` in the window.
- **Calendar** (optional): today's meetings, one line.

## 3. Write the artifact
Never edit or copy the template. Read `$RISK0/.claude/skills/daily/example.html` once (a complete sample page with fake values, for shape only), then write two fragment files in the scratchpad and assemble the page with the build script:
- `mast.html`: the inside of `<header class="mast">`: eyebrow `<p id="eyebrow" data-updated="<ISO time with offset>">`, `<h1 id="greet">`, the verdict, exactly four `.vital` tiles, and the `.counts` row with one `#spark` (`data-vals` = merged PRs per day, last 7 days, oldest first).
- `sections.html`: the `<details class="sec">` blocks only.
- Run `python3 $RISK0/.claude/skills/daily/build.py --mast mast.html --sections sections.html --foot "Updated <date time> PT · runs locally on weekdays · Refresh copies the command to re-run it" --out daily.html` and publish `daily.html`. If the build fails, fix the fragments and rerun; never publish around a failure.
- Rules: `data-who` (me | bot | other | all; `other` is a teammate) on `.todo li`, `.feed li`, `tbody tr`, `.card` and Jira `li`; a unique `data-id` on every `.todo li` (e.g. `pr-695`); tile classes good | warn | bad | unk.
- Do not redesign the page on a daily run; design changes go in `template.html`.
- Title stays `Daily Update`. Eyebrow carries the update time (`data-updated` as an ISO timestamp with offset).
- **Vital tiles** (good/warn/bad/unk): Main CI, Backend deploy (the repo's deploy workflow), App errors, Backend logs. A tile is `good` only when a source was read and clean. An unreadable source is `unk` with the reason.
- **Verdict**: one sentence, the single most important thing, bold on two or three facts.
- **Sections in order**, each omitted if empty: Today's focus (3 to 5 cards), Needs me (checkable `li`s, each with a stable `data-id`), Health, Shipped, In flight (bot drafts collapsed into one row), Tickets, Slack, My work, Sources.
- Health cards: new errors (name, message, events, users, first seen, link), top active, backend log errors grouped with counts, CI and deploys. Only state what the sources show; do not guess causes.
- Every item links to its PR, ticket, issue or message.
- Publish with the Artifact tool to the same URL (stored on the `_Last routine_` line); read it first with `action: "read"`. Pass a one-sentence `description`. No `capabilities`.

## 4. Finish
- Update `_Last routine: YYYY-MM-DD HH:MM · <artifact URL>_` in `daily.md`.
- Reply with the TL;DR bullets and the artifact link. Nothing else.
