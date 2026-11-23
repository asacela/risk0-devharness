---
name: planning
description: Explore an idea or ticket (Jira or GitHub/GitLab issue) into an agreed design, then a step-by-step plan, both in the toolbox plan file. Use for /planning, "brainstorm X", "plan PROJ-123", "plan issue 42", "let's think through X", "how should we build X", "write the plan".
argument-hint: "<PROJ-123 | idea | plan file>"
---

# /planning

Read `$RISK0/.claude/skills/WORKFLOW.md` first (who wins, plan location, output shape).

(Named `/planning` because `/plan` is a built-in command, plan mode.)

1. Input: `$ARGUMENTS`. A ticket key is fetched first (WORKFLOW.md → Tickets). No input: ask what to plan, one line. Find or create the plan file (WORKFLOW.md → Overrides). Resolve the ticket, creating one if the work has none (WORKFLOW.md → Ticket for every change), then move it to In Progress (WORKFLOW.md → Ticket status).
2. **Design.** If the file has no `## Design` yet: run `superpowers:brainstorming`, sized to the input. If the ticket already has clear acceptance criteria, skip the question loop and restate your understanding plus open questions in one message. Read the code it touches first (the ticket's worktree if it exists, else the main checkout). Ponytail applies: propose the smallest design that does the job and list what you'd skip. Write the agreed design to `## Design`.
   - If the ticket is about states or transitions (a status lifecycle, a flow, a protocol), offer `/statechart` to model it before the design is agreed. Ask first: its first run installs TLC and Java with mise and needs the network. Work in a scratch folder, keep the chart and the one line per bug in `## Design`.
3. **Plan.** Once Alec agrees on the design (or if it already exists), run `superpowers:writing-plans` into `## Plan` of the same file. Point repo paths at the ticket's worktree. No task that isn't needed, and reuse what the repo already has.
   - **Tests first (WORKFLOW.md → Quality bars §1):** each logic task opens with its failing test. List the paths it must cover: every acceptance criterion, the other callers of the same behaviour (grep them), and the reverse or empty case.
   - **Verification task (§2–3):** if the change reads prod data, depends on a third-party payload, touches env/build config or ships to devices, the last task before `/push` runs it on a prod-data copy, staging or an EAS/device build. Name the environment and the command. Mobile tickets also answer the §3 questions. Add an empty `## Verification` section for the result.
4. Never write `docs/superpowers/` and never commit the plan. Check every link in the file resolves.
5. End with the plan file path and offer `/implement`.
