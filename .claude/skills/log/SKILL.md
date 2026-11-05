---
name: log
description: Add an entry to the work journal (toolbox/journal/work-journal.md), from what I say or from this session's outcomes. Use for /log, "log this", "add to the journal", "journal that".
argument-hint: "[what to log]"
---

# /log

Rules for the journal are in `$RISK0/toolbox/AGENTS.md` §2. Follow them; this is the short version.

1. Input: `$ARGUMENTS`. If it's empty, log this session's meaningful outcomes (skip process and trivia). If there's nothing worth logging, say so and stop.
2. Open `$RISK0/toolbox/journal/work-journal.md`. Find today's `### YYYY-MM-DD (Day)` under `## Week of <Monday>`; create either heading (newest on top) if missing.
3. Add one bullet per outcome: `` - `#tag` What happened — outcome · PROJ-123 / PR #456 `` (on GitLab: `#42 / !456`). Tags: `#ship` `#build` `#fix` `#review` `#ops` `#learn` `#meeting`. Pick the tag, ticket key, PR and branch from the input or the session; leave out what you don't know rather than guess.
4. If today already has a bullet for the same work, update that bullet instead of adding a duplicate. Never touch past days.
5. If the logged item matches an open task in `toolbox/journal/daily.md`, tick it `[x]` there too.
6. Reply with the bullet(s) you wrote, nothing else.
