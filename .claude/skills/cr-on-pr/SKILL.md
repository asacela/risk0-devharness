---
name: cr-on-pr
description: Review a PR/MR with the full /cr review (ponytail review plus thermo-nuclear pass) and always post its must-fix and should-fix findings on the PR as inline comments. Use for /cr-on-pr 608, "review PR 608 and comment", "post review comments on this PR".
argument-hint: "<PR#/MR! | PR/MR URL>"
---

# /cr-on-pr

Read `$RISK0/.claude/skills/WORKFLOW.md` first (who wins, plan location, output shape). This builds on `/cr`: read `$RISK0/.claude/skills/cr/SKILL.md` → **Review** and run it as written; only the target and the posting below differ.

Alec has authorised posting for this command: post without asking. Never approve, request changes, merge, or resolve anyone's threads.

1. **Target.** `$ARGUMENTS` is required; none: ask for the PR. Get the author, branch, head SHA and existing comments ("PR author, branch, reviews" and "PR review comments" in WORKFLOW.md → Host commands). Fetch the head (`git fetch origin pull/<n>/head` on GitHub, `merge-requests/<n>/head` on GitLab) in the main checkout and read files at that SHA with `git show <sha>:<path>`; never check the branch out there. Line numbers come from that SHA.
2. **Review.** Run `/cr` → **Review** on the PR diff ("PR diff") at that SHA: both passes in parallel, graded must / should / nit, thermo findings verified, de-duplicated.
3. **Drop what's already said.** Skip a finding someone already raised on the same lines (any reviewer, bots included, resolved or not). Never post nits.
4. **Post one review** ("Post a PR review" in Host commands), pinned to the reviewed SHA:
   - Each must-fix and should-fix whose lines are in the diff is an inline comment on the new-side line (a range for multi-line), body:
     `**Must fix:** <the problem, plain English>. <the fix, concrete>` (or `**Should fix:** …`), with a short code suggestion only when it makes the fix obvious.
   - Findings on lines outside the diff go in the review body as a list with `path:line`, same prefixes.
   - Review body starts with one line: `Must fix: N · Should fix: N` (nits aren't counted there).
   - No must-fix or should-fix findings: post nothing and say so.
5. **Report** to Alec as `/cr` → **Review** step 4 does, plus the review's URL and anything skipped as already raised. Update the "Reviews owed" line in `daily.md` if this was one of them.
