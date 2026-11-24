---
name: fix
description: Find the root cause of a bug, error or failing test, fix it once in shared code with a regression test. Use for /fix, "debug this", "why is X broken", "this test fails", pasted stack traces.
argument-hint: "<symptom | error | failing test>"
---

# /fix

(Named `/fix` because `/debug` is a built-in skill.)

Read `$RISK0/.claude/skills/WORKFLOW.md` first (who wins, plan location, output shape).

1. Input: `$ARGUMENTS` (symptom, error text, test name, ticket key). No input: use the last failure in this session.
   - **Several failures:** group them by likely cause first (same error, same module → one group). Two or more independent groups (different subsystems, no shared files): `superpowers:dispatching-parallel-agents`, one agent per group, each running steps 2–4 on its group only and reporting cause, fix and proof in the tldr block. Then review each fix, check they don't touch the same code, and run step 5 once over everything. One group: do it yourself.
2. Run `superpowers:systematic-debugging`: reproduce, find the root cause, form one hypothesis at a time. No fix before the cause is proven.
3. Production errors: the config's `debugSkills` (if any) pull real stack traces and logs.
4. Fix: write a regression test that fails first (`superpowers:test-driven-development`), then fix the root cause once, in the shared code, after grepping every caller.
5. Verify with the test plus the app's suite. Report the cause, the fix, and the proof. If this was on a branch, offer `/push`.
