---
name: planning
description: Explore an idea or ticket (Jira or GitHub/GitLab issue): ask Alec the open questions, then from his answers write the exact design, a step-by-step plan and a full-coverage test and verification plan, all in the toolbox plan file. Use for /planning, "brainstorm X", "plan PROJ-123", "plan issue 42", "let's think through X", "how should we build X", "write the plan".
argument-hint: "<PROJ-123 | idea | plan file>"
---

# /planning

Read `$RISK0/.claude/skills/WORKFLOW.md` first (who wins, plan location, output shape).

(Named `/planning` because `/plan` is a built-in command, plan mode.)

1. Input: `$ARGUMENTS`. A ticket key is fetched first (WORKFLOW.md → Tickets). No input: ask what to plan, one line. Find or create the plan file (WORKFLOW.md → Overrides). Resolve the ticket, creating one if the work has none (WORKFLOW.md → Ticket for every change), then move it to In Progress (WORKFLOW.md → Ticket status).
2. **Open questions (always, and wait).** If the file has no `## Design` yet: read the code it touches first (the ticket's worktree if it exists, else the main checkout), then run `superpowers:brainstorming`, sized to the input. Even when the ticket has clear acceptance criteria, send one message with your understanding and every open question the ticket and code can't answer (behaviour, edge cases, scope, data, rollout), numbered, each with your recommended answer. Then stop and wait for Alec's answers; ask follow-ups only if an answer opens a new question. Record the questions and answers in `## Design` under `### Decisions`.
   **Design (no extra approval step).** Once the questions are answered, go straight on: write the exact design to `## Design` (the files and functions it touches, data and API shape, states and transitions, error handling, what's reused). Ponytail applies: the smallest design that does the job, with what you'd skip in one line.
   - If the ticket is about states or transitions (a status lifecycle, a flow, a protocol), offer `/statechart` to model it before the design is agreed. Ask first: its first run installs TLC and Java with mise and needs the network. Work in a scratch folder, keep the chart and the one line per bug in `## Design`.
3. **Plan**, right after the design (or straight away if `## Design` already exists): run `superpowers:writing-plans` into `## Plan` of the same file. Point repo paths at the ticket's worktree. No task that isn't needed, and reuse what the repo already has.
   - **Tests first (WORKFLOW.md → Quality bars §1):** each logic task opens with its failing tests, taken from the rows of `## Test plan` that it covers.
   - **`## Test plan` (full coverage map).** A table with one row per behaviour, and nothing padded: `# · behaviour / path · level (unit, integration, e2e, prod-data, manual) · test file and name · status`. Rows to cover, wherever they apply:
     - every acceptance criterion and every decision from `### Decisions`;
     - each branch the design adds, error and failure paths (bad input, third-party errors, timeouts), and the empty, missing or first-time case;
     - every other caller of the changed behaviour (grep them) and the reverse transition;
     - permissions (who may and may not), idempotency or double-submit, and ordering or concurrency when writes race;
     - existing behaviour that must not change (regression rows);
     - data: migrations up on prod-shaped rows, and backfills.
     Below the table, the coverage goal: every new or changed branch is executed by at least one test, measured by `/test` on changed lines. List anything deliberately left untested, with the reason.
   - **Prod-data decision (§2, "Prod-data check").** Classify the change as heavy data layer, UI-level, or mixed, and put the decision at the top of `## Verification`: `Prod data: use — <tables, filters, row caps, what runs against them>`, or `Prod data: skip — <one-line reason, e.g. UI-only: new screen over the unchanged GET /campaigns>`. Mixed: use it, scoped to the data-layer part. With `use`, the prod-data rows in `## Test plan` have level `prod-data` and name the script, query or endpoint that runs against the copied rows.
   - **Verification task (§2–3):** if the change reads prod data, depends on a third-party payload, touches env/build config or ships to devices, the last task before `/push` runs it on a prod-data copy, staging or an EAS/device build. Name the environment and the command. Mobile tickets also answer the §3 questions. Add a `## Verification` section with the planned checks (environment, command, expected result) and an empty result line for each.
4. Never write `docs/superpowers/` and never commit the plan. Check every link in the file resolves.
5. End with the plan file path and offer `/implement`.
