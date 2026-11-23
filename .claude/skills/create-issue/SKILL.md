---
name: create-issue
description: Create one ticket (Jira, or a GitHub/GitLab issue) with assignee, labels, due date, team and status set from the repo's tracker defaults. Use for /create-issue, "make a ticket for X", "file an issue for X". Other commands call it when a change has no ticket.
argument-hint: "<title or description> [type, assignee, labels, due, team, status, parent]"
---

# /create-issue

Read `$RISK0/.claude/skills/WORKFLOW.md` first (Repo config → `tracker`, Tickets, Ticket status). This skill only creates. Searching for an existing ticket is the caller's job (WORKFLOW.md → Ticket for every change); when you're invoked directly, don't search, just create.

`tracker: null` (or no config): say there is no tracker and stop.

## 1. Fields

Take what `$ARGUMENTS` (or the caller) gives; fill the rest from `tracker.defaults` in the config; anything neither names stays unset. Ask only when there is no title and nothing to derive one from, one line.

| Field | Input | Default | Never |
|---|---|---|---|
| Title | short imperative summary | none | invent one from nothing |
| Description | goal + acceptance criteria (from the plan or intent, else the input) | the title | pad it |
| Type | `Bug` for a fix, `Story` for a user-facing feature, else `Task` | `Task` | `Epic` or `Subtask` unless asked |
| Assignee | a person's name | `defaults.assignee` (`me` = the current user) | assign to someone unasked |
| Labels | list | `defaults.labels` | create new label names unasked |
| Due date | a date, "friday", "in 2 weeks" (resolve to `YYYY-MM-DD`) | `defaults.dueInDays` days from today, else none | invent a date |
| Team | a team name | `defaults.team` | |
| Status | a status name | `defaults.status`, else the tracker's initial one | Done, On Hold or any closed state unless asked by name |
| Parent | a ticket key | `tracker.parentEpic` (Jira) | |

## 2. Create

**`jira`** (Atlassian MCP, `cloudId` = `tracker.site`):
1. Current user for `me`: `atlassianUserInfo`. Another person: `lookupJiraAccountId`; several matches or none: leave unassigned and say so.
2. Field ids differ per site, so read them: `getJiraIssueTypeMetaWithFields` (`requiredFieldsOnly: false`) for the project and type. Team is the field whose schema ends in `atlassian-team`; labels and `duedate` are standard.
3. `createJiraIssue`: `projectKey` = `tracker.project`, `issueTypeName`, `summary`, `description`, `assignee_account_id`, `parent` (if it rejects `parent` for an epic, put `{"parent": {"key": "<KEY>"}}` in `additional_fields`), and in `additional_fields`: `labels` (array of strings), `duedate` (`"YYYY-MM-DD"`), the team field (the team's id from `defaults.team.id`; a name only: find its id from an existing ticket, `searchJiraIssuesUsingJql` with `Team is not EMPTY`, reading that field).
4. Check the parent exists first (`getJiraIssue`); if it doesn't, create without it and say so.
5. Status: a new ticket starts in the workflow's first status. If the wanted one differs, `getTransitionsForJiraIssue`, pick the transition by its **target status name**, `transitionJiraIssue`. No such transition: leave it and say so.

**`github` / `gitlab`:** `gh issue create` / `glab issue create -R <host.repo>` with title, body, `--assignee` (`@me` or the login), `--label` for each label. Due date: GitHub has none on issues (put it in the body, or a milestone if one fits); GitLab `--due-date`. Team: a `team:<name>` label only if that label already exists. Status: `labels.inProgress` when asked for in-progress, otherwise open is the status. A field the tracker can't hold is skipped and named in the reply.

## 3. Reply

One block: the key and URL, then each field as set (`assignee: Alec · labels: none · due: 2026-12-01 · team: Engineering · status: To Do · parent: PROJ-1`), then anything left unset and why. A field that failed to set doesn't undo the ticket: say it in one line.
