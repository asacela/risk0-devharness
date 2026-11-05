---
name: steps
description: List, step by step and in plain words, the manual steps I (Alec) have to do myself to finish a task — what I run, click, paste or set up — after doing everything an agent can do. Use for /steps, "what do I need to do", "tell me step by step", "what's left on me".
argument-hint: "[task, e.g. test PROJ-740 locally | deploy to prod]"
---

# /steps

Read `$RISK0/.claude/skills/WORKFLOW.md` first (who wins, output shape).

1. Input: `$ARGUMENTS`. If it's empty, use the task currently under way in this session. If you can't tell what the task is, ask one question and stop.
2. **Do your part first.** Before listing anything, do every step you are allowed to do: run checks, start containers, run migrations, look up values, confirm scripts and files exist. Check the current state (what's already running or set) instead of assuming it. Never hand Alec a step you could have done yourself.
3. **Only list what's left for Alec.** These are the things you can't or mustn't do:
   - Editing `.env` files: agents only inspect them with `toolbox/scripts/env-check.sh`.
   - Anything that needs a secret, a login or a browser (OAuth consent, consoles, dashboards).
   - Long-running processes he needs to watch: dev servers and pollers, one terminal each.
   - Acting as a real user: sending an email, tapping through the app.
   - Anything outward-facing or hard to undo that he hasn't approved (deploys, prod data, sharing).
4. Write the reply in this shape, plain words, no jargon he'd have to look up:
   - One line: what you already did, so he knows it's handled.
   - Numbered steps, `### Step N: <verb> <thing>`. Each step gives:
     - **Where:** which terminal, site or app.
     - **What:** the exact command in a code block, with absolute paths and a `cd` into the right folder. Copy-pasteable, one command per block.
     - **What you should see:** the sign that it worked.
   - Mark checkpoints: "If this fails, stop and paste the output to me."
   - Order the steps the way he'd do them, and say "leave it running" for long-running ones.
   - End with what to send back (pasted output, a yes/no, a value's length — never the secret itself).
5. Keep each step to one action. If a step needs a decision from him, say which choice you recommend and why, in one line.
6. Never put secrets, tokens or passwords in the steps, and tell him not to paste them back.
7. Last line: anything you didn't check, and which step is the likeliest to break.
