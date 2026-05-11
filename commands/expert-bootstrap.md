---
description: Bootstrap an expert council for the current project — detects host runtime, discovers the goal interactively (one step only), then autonomously designs the roster, optimizes each expert's prompt, and writes the council to ./.claude/agents/+CLAUDE.md (Claude mode) or ./agents/+AGENTS.md (portable mode). Ends with a seeded first-meeting prompt.
---

Invoke the `expert-bootstrap` skill now. Follow it exactly: detect the runtime mode first, do not skip Step 0 (goal discovery), do not insert confirmation prompts in Steps 1–4 beyond the `NEED CLARIFICATION:` escape, and stop after Step 5's readiness announcement.

User context for this run (if any): $ARGUMENTS
