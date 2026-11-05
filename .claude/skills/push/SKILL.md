---
name: push
description: Ship the current branch through the no-mistakes gate (review, test, lint, docs, push, PR/MR, CI babysitting), driving its approval gates as the agent. Use for /push, "ship it", "open a PR", "push this", "rerun the gate".
argument-hint: "[yes — auto-resolve gates] [extra intent text]"
---

# /push

Read `$RISK0/.claude/skills/WORKFLOW.md` first (who wins, plan location, output shape).

no-mistakes is the only review-and-PR path in this workspace. It replaces `superpowers:requesting-code-review` and `superpowers:finishing-a-development-branch`. Don't run those first. (`/cr` is an optional look before this, not a requirement.)

## 1. Preconditions

- Must be in a repo on a feature branch, not `main`. If on `main`, stop and say so.
- Existing PR (an MR on GitLab): WORKFLOW.md → Host commands, "PR for a branch". Never open a second PR for a branch.
  - Open PR: say so, push to it, and leave its title and body alone unless Alec asks. If the gate's PR step would create a new one, stop and ask.
  - Only merged or closed PRs: stop and ask Alec before a new PR is opened.
- `no-mistakes status`. If it says `repo not initialized`: that adds a `no-mistakes` git remote and a local gate repo, so **ask Alec once**, then run `no-mistakes init` in the main checkout (`$RISK0/repositories/<repo>`, not a worktree; worktrees share its remotes).
- Uncommitted changes: commit them (repo's commit style, Co-Authored-By trailer). Never commit `.env*` or anything under `toolbox/`.
- Quick local check (`superpowers:verification-before-completion`): lint/typecheck only for the apps the diff touches (`lint`/`typecheck` from the repo config, WORKFLOW.md → Repo config). Skip slow suites, since the gate's Test step runs them. A failure here gets fixed before the run.

## 1b. Optional extra passes (before the gate)

- **Risky change → `/thermo-nuclear-review`.** Risky = a database migration, auth or permissions, billing or payments, a public API contract, or a diff well past a normal ticket's size. Say it looks risky and **ask Alec** before running it. Findings are judged like `superpowers:receiving-code-review`; real ones go to `/fix`, then commit on top before the gate. Not risky: skip it, no-mistakes is enough.
- **Prose in the diff → `/unslop`.** If the diff adds or edits Markdown docs, READMEs or user-facing copy, run `/unslop` on those lines only. Never on code or generated files.

## 2. Start or reattach

Write the intent to a file in the scratchpad: what Alec set out to do (ticket key + goal + acceptance criteria), not a description of the diff. Add any intent text from `$ARGUMENTS`.

```sh
no-mistakes axi run --intent-file <scratchpad>/intent.md   # Bash timeout 600000
```

- If an active run already exists for the branch, `no-mistakes axi run` with no intent reattaches.
- Add `--yes` only if `$ARGUMENTS` contains `yes` / "just ship it". It auto-fixes every finding, including ask-user ones.
- A returned wait timeout is not a failure: `no-mistakes axi status`, then reattach.

## 3. Drive the gates

At each gate, read the findings (`no-mistakes axi logs` for detail) and judge them like `superpowers:receiving-code-review`: real bug or not, in scope or not.

- Fix the real ones, decline the rest. Every shown finding must be named in one list or the other:
  `no-mistakes axi respond --action fix --findings <ids> --ignore <ids> [--instructions "..."]`
- Clean, or only declined findings left: `no-mistakes axi respond --action approve`.
- Reviewer question (`question-<id>`): answer it yourself if the code or ticket settles it, else ask Alec. Then `no-mistakes axi answer --question question-<id> --answer "..." --by claude`.
- **Always ask Alec** on protected-path refusals, Test "unvalidated work" refusals, and any finding that touches security, data loss, migrations or billing.

## 4. Hard rules

- Follow-up work goes in **new commits on top**. Never `axi abort` and restart, reset, rebase away or force-push gate fix commits.
- Don't merge the PR. Alec merges.
- If the run fails outright, report the step and its verbatim error from `no-mistakes axi logs`. Don't paraphrase it.

## 5. Report and log

Once the PR is open or CI is ready, reply in tldr form: PR URL, gates passed, findings fixed/declined (with one-line reasons), CI state, anything Alec must decide. Update the ticket for the open PR (WORKFLOW.md → Ticket status; for issue trackers put `Closes #<n>` in the intent so the PR body carries it). Then refresh the PR section of `toolbox/journal/daily.md` and add a `#ship` bullet to `work-journal.md` (`- \`#ship\` <outcome> · PROJ-123 / PR #456`, on GitLab `#42 / !456`).
