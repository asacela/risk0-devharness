---
name: test-drive
description: Run a PR's changed code for real, against a read-only copy of prod data in the local DB where the change is data-heavy, to find bugs a static /cr review missed, then post the evidence and the new findings on the PR. Use for /test-drive 608, "test-drive this PR", "run this PR against prod data", "find what review missed".
argument-hint: "[PR#/MR! | PR/MR URL]   (none = the current branch's PR)"
---

# /test-drive

Read `$RISK0/.claude/skills/WORKFLOW.md` first (who wins, plan location, output shape). This builds on three skills; read the sections it names and run them as written:
- `/cr` → **Review**: the static review that is the baseline.
- `/test` step 4 (prod data) and step 5 (coverage).
- `/cr-on-pr` step 4: how to post.

`/cr` reads the code. `/test-drive` runs it, so it only reports what running the code shows. Alec has authorised posting for this command: post without asking. Never approve, request changes, merge, or resolve anyone's threads.

1. **Target.** `$ARGUMENTS`, else the PR for the current branch ("PR for a branch" in Host commands); none: ask. Get the author, branch, head SHA, the linked ticket and plan file if there is one, and every existing review and comment.
2. **Workspace.** You need the PR's code checked out and runnable. Use the herdr worktree that already has the branch; if none has it, create one for the existing branch (WORKFLOW.md → Overrides) and run `/setup-worktree`. Check that the worktree is at the PR's head SHA; if Alec has local changes there, stop and say so. Never run it in the main checkout.
3. **Baseline (what's already known).** Collect every finding already raised on the PR, by people, bots, the gate or an earlier `/cr-on-pr`. If no `/cr`-style review is among them, run `/cr` → **Review** on the PR diff now, but don't post it. Everything in this baseline is excluded from what you post later.
4. **Prod data.** Decide use or skip by Quality bars §2 ("Prod-data check"), following the plan's `Prod data:` line if there is one. With `use`, run `/test` step 4 sub-steps 1–4 to load the rows into the worktree's local DB, read-only from prod and within its row caps. Shape the row selection toward what the change might get wrong: old and legacy rows, nulls and missing optional fields, every enum or status value actually present, the biggest accounts or longest histories, duplicates, timezone edges. With `skip`, say why and carry on with local data.
5. **Drive it.** Run the suites and coverage (`/test` steps 2 and 5). Then run each changed path the way production will:
   - the migration (up on the loaded rows);
   - the backfill or script, as a dry run first if it has one;
   - the changed queries, with `EXPLAIN ANALYZE` or the equivalent at real volumes;
   - the endpoints or jobs, through `/up` and real requests.

   Check that the outputs match the ticket or plan and that totals and invariants hold, and look for errors, slow queries and unhandled values in the logs. Mobile and UI paths: run whatever can be run here, and list the rest as not driven, with the reason.
6. **Findings.** Keep a finding only if running the code showed it and it isn't in the baseline. Reproduce each one twice (`superpowers:systematic-debugging` for the cause, no fixes here). Then:
   - Grade it must / should as `/cr` → **Review** step 2 does.
   - Attach its evidence: the command, a trimmed output or error excerpt, and the row count or timing behind it.
   - **Evidence goes on a shared page, so never include personal fields** (names, emails, phones, addresses, vehicle or device identifiers), secrets, or row contents. Use counts, shapes, column names, enum values, timings and errors with values masked.
7. **Post one review** as in `/cr-on-pr` step 4, pinned to the tested SHA, with findings inline where their lines are in the diff, prefixed `**Must fix (test-drive):**` / `**Should fix (test-drive):**` with the evidence under each. Post it even when nothing new turned up, because the evidence is the point. The body:
   - `Test-drive: N new must · N new should` (or `Test-drive: no new findings`);
   - the environment, the prod-data decision and reason (tables and row counts copied, never contents), and the commands run with their pass/fail result;
   - the suite counts and coverage of the changed files;
   - what wasn't driven and why.
8. **Close out.** Stop the proxy and any servers you started. If it's my PR with a plan file, add the run to `## Verification`. Reply in tldr form with must-fixes above the divider, the review's URL, and the next step: on my PR, offer `/fix` for each finding; on a teammate's, nothing more.
