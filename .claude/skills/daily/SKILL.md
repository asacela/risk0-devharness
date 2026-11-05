---
name: daily
description: Daily "what's been happening" digest as a private artifact — merged/open PRs/MRs, ticket movement (Jira or issues), Slack activity, and my own work, since the last digest. Use for /daily, "give me the daily update", "what happened since yesterday", "catch me up".
argument-hint: "[days back, default: since last digest or 1]"
---

# /daily

Builds one overarching update on what's been happening across the team and my own work, and publishes it as a private Artifact. Read-only everywhere except the artifact and `daily.md`.

## 1. Window
`$ARGUMENTS` = days back. Default: since the previous digest (stamp in `$RISK0/toolbox/journal/daily.md`, line `_Last routine: YYYY-MM-DD HH:MM_`), else 1 day (3 on Mondays, to cover the weekend).

## 2. Gather (run independent calls in parallel; skip a source that fails and say so in the digest)
Sources per repo: every `$RISK0/repositories/*/.risk0.json` (WORKFLOW.md → Repo config); run the host and ticket queries once per configured repo, using WORKFLOW.md → Host commands and → Tickets for its `host.type` and `tracker.type`.
- **Host** (GitHub or GitLab): merged PRs in the window (all authors, "Merged since a date"), open PRs and their review state, PRs awaiting my review, failed CI on `main`.
- **Tickets** (skip if `tracker` is `null`): "Moved in the last N days" for what moved (status changes, new tickets), plus "Mine, open" due in the next 7 days.
- **Slack** (Slack MCP): `slack_search_public` for the window and read the busiest channels; pull decisions, incidents, questions aimed at me, launches. Skip chatter.
- **Me**: bullets from `$RISK0/toolbox/journal/work-journal.md` in the window and active sessions per `toolbox/AGENTS.md` §1.
- **Calendar** (optional): today's meetings, one line.

## 3. Write the artifact
Load `artifact-design` first. One scannable HTML page, title `Daily Update`. Layout: a masthead (date as the heading) with a four-count strip (merged PRs, needs me, open PRs, failed CI); TL;DR as one card per bullet with a bold lead phrase; "Needs me" as cards with a state pill, a bold action and one muted reason line; Shipped and In flight as tables (PR, what, who, date/state), one row per PR, grouped by theme, bot drafts collapsed into one row; Tickets as three columns (Done, In Progress, New); My work as two columns (Done, Next). Pills use one vocabulary: good/warn/bad/info. Sections in this order, each omitted if empty:
1. **TL;DR**: 3 to 5 bullets, the things that actually matter.
2. **Needs me**: reviews owed, questions in Slack, due-soon tickets, failing CI.
3. **Shipped**: merged PRs grouped by feature/ticket, with author and links.
4. **In flight**: open PRs and ticket movement.
5. **Slack highlights**: decisions, incidents, announcements, with channel links.
6. **My work**: what I did, what's next.
7. **Sources**: anything that failed or was skipped.

Every item links to its PR, ticket or message. Publish with the Artifact tool; on later runs update the same URL (the URL is stored on the `_Last routine_` line) so there's one living page. Re-read before republishing if it may have been edited.

## 4. Finish
- Update `_Last routine: YYYY-MM-DD HH:MM · <artifact URL>_` in `daily.md` (add the line under the top heading if missing).
- Reply with the TL;DR bullets and the artifact link (use the absolute-path rule from `AGENTS.md` for any files). Nothing else.

## Scheduling
To get it every weekday automatically, use the `schedule` skill with the prompt `/daily` (e.g. weekdays 8:30am).
