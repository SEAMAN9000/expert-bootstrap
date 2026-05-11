# Project: {{PROJECT_BRIEF}}

> Council bootstrapped {{COUNCIL_DATE}} via `/expert-bootstrap`.

## Expert Council

This project uses a council of domain experts living in `./.claude/agents/`. They are dispatched via Claude Code's native `Agent` tool with `subagent_type=<expert-name>`.

### Roster

{{ROSTER_TABLE}}

### Convening rules

- **When to convene**: any decision that crosses two or more experts' territories (architecture, scoping, risk, tech choice). Routine implementation does not require a council session.
- **Format**: dispatch the relevant experts **in parallel** with the same question. Each returns an independent opinion. The main agent synthesizes — no expert is overruled silently; disagreements are surfaced.
- **Skeptic privilege**: the skeptic seat (if present in roster) gets the last word before synthesis.
- **Scope discipline**: each expert respects their `must_not` clauses. If a question falls outside all experts' territories, the main agent flags the gap rather than improvising.
- **No theatrical transcripts**: synthesize to a compact verdict. The user reads the verdict, not the raw debate, unless they ask.

### Modifying the roster

Re-run `/expert-bootstrap` to regenerate. Do not hand-edit `./.claude/agents/*.md` — that drifts from the prompt-engineer-optimized baseline. If a single expert needs tuning, dispatch `prompt-engineer` with the existing prompt + the desired change, then overwrite the file with its output.

## Project artifacts

| Path | Purpose |
|---|---|
| `brief/goal.md` | Canonical project goal — single source of truth for what we are building |
| `CLAUDE.md` (this file) | Council convening rules + roster index |
| `.claude/agents/<expert>.md` | Expert council members, project-local, native subagent dispatching |

### Update rules

| File | Who updates | When |
|---|---|---|
| `brief/goal.md` | `/expert-bootstrap` (Step 0–1), or explicit `Agent(subagent_type="prompt-engineer")` dispatch with goal-revision intent | On project start; on substantive scope change |
| `.claude/agents/*.md` | `/expert-bootstrap` re-run only — never hand-edit | Roster changes; expert prompts drift |
| `CLAUDE.md` (this file) | `/expert-bootstrap` regenerates `## Expert Council` and `## Project artifacts` sections; everything else is hand-edited freely | Council changes regenerate; project notes evolve manually |

**Drift discipline**: if you find yourself wanting to hand-edit a generated file, re-run the relevant meta-agent (`prompt-engineer` for individual prompts, `/expert-bootstrap` for the whole roster). Hand edits silently break the regeneration contract.
