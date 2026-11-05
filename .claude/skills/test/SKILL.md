---
name: test
description: Run the right tests for what changed, add missing ones for untested logic, and report results with evidence. Use for /test, "run the tests", "add tests for X", "is this covered".
argument-hint: "[path | feature | 'write' to add tests]"
---

# /test

Read `$RISK0/.claude/skills/WORKFLOW.md` first (who wins, plan location, output shape).

1. Scope: `$ARGUMENTS` if given, else the branch diff against `main` (`git diff main...HEAD` plus uncommitted).
2. Map changed files to apps by their `dir` and run their `test` commands from the repo config (WORKFLOW.md → Repo config); the repo's `AGENTS.md` says which suites need extra services, e.g. Docker. Run the narrowest set first (changed test files), then the app suite.
3. Gaps: for changed logic with no test (a branch, parser, money, auth, data writes), write the test with `superpowers:test-driven-development`, so it must fail without the change. Trivial edits need none (ponytail).
4. Failures: report them verbatim. Don't fix product code here; hand off to `/fix` unless the fix is obvious and one line.
5. Report per `superpowers:verification-before-completion`: the command, pass/fail counts, failures verbatim, tests added.
