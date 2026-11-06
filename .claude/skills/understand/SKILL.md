---
name: understand
description: Explain how a piece of code, a feature, a system or a concept works, traced through the real code. Optionally keep it as a learning note. Use for /understand, "how does X work", "walk me through X", "explain X".
argument-hint: "<thing to understand> [save] [map]"
---

# /understand

Read `$RISK0/.claude/skills/WORKFLOW.md` first (who wins, plan location, output shape).

1. Input: `$ARGUMENTS`. Read the repo's docs first (`repositories/<repo>/docs/`, the app's README).
2. Trace it through the real code, entry point to storage and back. For a broad sweep, send `Explore` subagents in parallel (one per area). Read the key files yourself, not just excerpts.
3. Explain at the level asked. This is the tldr "explain" case: the TL;DR is a map, and the body runs as long as the topic needs. Cite every claim with `$RISK0/...:line` paths. Say which parts you didn't read.
4. A small diagram helps when there are 3+ moving parts (ASCII in the terminal).
5. For a whole app, several subsystems or "how does the frontend talk to the backend", or when the input says `map`/`floorplan`, also invoke the `floorplan:floorplan` skill to draw the interactive map. It writes `floorplan/index.html` into the codebase: don't commit it, and link it in the reply.
6. If `save` is in the input or Alec asks to keep it: write it to `toolbox/sandbox/learning/<kebab-slug>.md` (H1 + one-line purpose, workspace-root links that resolve, `/repositories/<repo>/docs/...` for repo docs). Run `/unslop` over the prose before saving.
