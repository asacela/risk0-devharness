---
name: fix
description: Find the root cause of a bug, error or failing test, fix it once in shared code with a regression test. Use for /fix, "debug this", "why is X broken", "this test fails", pasted stack traces.
argument-hint: "<symptom | error | failing test>"
---

# /fix

(Named `/fix` because `/debug` is a built-in skill.)

Read `$RISK0/.claude/skills/WORKFLOW.md` first (who wins, plan location, output shape).

1. Input: `$ARGUMENTS` (symptom, error text, test name, ticket key). No input: use the last failure in this session.
2. Run `superpowers:systematic-debugging`: reproduce, find the root cause, form one hypothesis at a time. No fix before the cause is proven.
3. Fix: write a regression test that fails first (`superpowers:test-driven-development`), then fix the root cause once, in the shared code, after grepping every caller.
4. Verify with the test plus the app's suite. Report the cause, the fix, and the proof. If this was on a branch, offer `/push`.
