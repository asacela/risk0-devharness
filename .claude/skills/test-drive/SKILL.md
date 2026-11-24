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

   Check that the outputs match the ticket or plan and that totals and invariants hold, and look for errors, slow queries and unhandled values in the logs.
   - **Nothing leaves the machine.** Before driving, switch outbound side effects to record-only or off: push, SMS, email, analytics, chat webhooks, payments. Never copy push tokens or other delivery credentials. If one can't be stubbed, don't drive that path; list it under Not tested.
   - **Shape the data locally when real data can't reach the path.** For example, move dates forward when every real booking is in the past, or rebook members into a mix of states. Change only the local copy, and record each change and why in Setup.
   - **Time-based jobs:** replay them over a simulated window at their real cadence, inside a transaction you roll back at the end.
   - **UI:** drive it with what's available, for example the simulator through Maestro or `.sim` flows, and web apps through Playwright with a local-only session. Check the resulting DB rows, not only the screen.
   - **Races:** fire the same request twice in parallel.
   - **Earlier comments:** try to reproduce each finding already raised on the PR, and add a Results row for each.
   - Anything that can't run here (another platform, a real device, a real delivery, third-party sign-in) goes under Not tested.
6. **Findings.** Keep a finding only if running the code showed it and it isn't in the baseline. Reproduce each one twice (`superpowers:systematic-debugging` for the cause, no fixes here). Then:
   - Grade it must / should as `/cr` → **Review** step 2 does. Must → **Blocking**, should → **Not blocking**. An earlier comment that didn't reproduce goes under Not blocking, downgraded, with the Results row that tried it.
   - Attach its evidence: the command, a trimmed output or error excerpt, and the row count or timing behind it.
   - **Evidence goes on a shared page, so never include personal fields** (names, emails, phones, addresses, vehicle or device identifiers), secrets, or row contents. Use counts, shapes, column names, enum values, timings and errors with values masked.
7. **Post one review** as in `/cr-on-pr` step 4, pinned to the tested SHA. Its body is the report in **Evidence post format** below. Each Blocking or Not blocking finding whose lines are in the diff also gets a short inline comment, `**Must fix (test-drive):**` / `**Should fix (test-drive):**`, with one line of evidence pointing to the report. Post even when nothing new turned up, because the evidence is the point.
8. **Close out.** Stop the proxy and any servers you started. If it's my PR with a plan file, add the run to `## Verification`. Reply in tldr form with must-fixes above the divider, the review's URL, and the next step: on my PR, offer `/fix` for each finding; on a teammate's, nothing more.

## Evidence post format

Plain prose, first person, past tense, short sentences, no filler. Concrete numbers, states and texts as observed, never "works as expected". Sections in this order; leave out a section only if it would be empty, except Not tested, which always appears.

```
Local run on real <dataset scope> data, at <short SHA>
I ran every flow this PR touches against a read-only copy of <dataset> from prod, then <how it was driven, one clause>.

Setup
- Data: a read-only copy of <entities with counts>, loaded into a local worktree database. <migrations: ran on top without errors | what failed>.
- <Data shaping> (local only): <what real data couldn't reach, what was changed, how many rows, into which mix of states>.
- Nothing sent: <side effects recorded or off>. No <tokens or credentials> were copied.
- How I drove it: <devices and builds, tools (Maestro, Playwright, HTTP, in-process calls), sessions>.

Results
| # | Flow | How | Result |
|---|---|---|---|
| 1 | <flow name> | <what ran: job replay window, simulator steps, API calls, parallel requests> | ✅ / ❌ / ⚠️ <observed outcome: UI text, DB rows and statuses, response codes, counts, timings> |
| 1b | <variant of 1, e.g. the forbidden case> | … | … |

Blocking
<One-sentence bug statement> (<file:line>, <"on my earlier comment" if it was raised>). <How it was reproduced on this data>. <What it causes>. <Impact counted on the real data, e.g. "23 of the 42 members ...">. Fix: <concrete change>.

Not blocking, seen while running
<One-sentence statement>. <What was seen>. <When it bites in production, with real numbers and dates if it depends on timing>. <Suggestion or the two options>.
<An earlier comment that didn't reproduce (row N), and how to treat it now.>

Not tested: <platforms, real devices, real deliveries, third-party sign-in, anything listed in step 5>.
```

- Name things the way the product does (dataset, campaign, region). Never names, contact details or other personal fields of users: refer to "a real member whose only earlier bookings were ...".
- Every ✅ says what was checked, and every ❌ or ⚠️ has a matching entry under Blocking or Not blocking.
- Impact counts come from the copied data and are labelled as such.
