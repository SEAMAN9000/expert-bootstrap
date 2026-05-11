# Project: {{PROJECT_BRIEF}}

> Council bootstrapped {{COUNCIL_DATE}} via `/expert-bootstrap` (portable mode).

<!-- expert-bootstrap:begin -->

## Expert Council

This project uses a council of domain experts living in `{{EXPERT_DIR}}`. Dispatch them by reading the relevant `<name>.md` file and treating it as a subagent prompt, or — on hosts that support it — via the host's native subagent invocation against the same files.

### Roster

{{ROSTER_TABLE}}

### Convening rules — five-step meeting flow

The main agent plays both **facilitator** and **project lead (approver)** — process-role expansion is forbidden by design. Every council meeting, even single-turn ones, follows these five steps:

**Step 1 · Initiation** — Before dispatching anyone, the main agent silently answers the **initiation-four**:
1. What decision does this question demand? (not "discuss" — "decide what")
2. Which artifacts / files / flows are affected by the decision?
3. What is the minimum set of experts required? (whose `decides:` or `responsibilities:` does it hit?)
4. Expected resolution shape? (single verdict / parallel options preserved / delegated execution)

**If Q3 yields 0 or 1 expert, this is not a council question — the main agent answers directly, no meeting is convened.**

**Step 2 · Selection** — Dispatch only experts whose territory the question genuinely touches. Skip experts whose `must_not` lists the question's domain. Whenever ≥3 experts are dispatched and a skeptic seat exists, the skeptic is always included. Cap at council size; no "everyone in the room" reflex.

| Common topic | Default required attendees |
|---|---|
| Single-expert-owned decision | Do not convene; route directly to that expert |
| Cross-two-expert interface / boundary | Those two + skeptic (if present) |
| Cross-three-or-more architecture / scope / tradeoff | All hit experts + skeptic |
| Touches `brief/goal.md` scope change | Pause convening; escalate via "red-line" rule below |

**Step 3 · Facilitation** — Dispatch all selected experts **in parallel** with the **same question text** (verbatim, no per-expert edits). Each returns an independent opinion under a `### <expert-name>` heading. No expert sees another's reply during this phase. **The skeptic speaks last** before synthesis — its position can override majority if grounded in a specific failure mode.

**Step 4 · Synthesis** — Classify every disagreement using the **conflict triad**, then resolve per type:

| Conflict type | Arbitration path |
|---|---|
| **Factual** (data / citation / correctness) | Verify with evidence; if no evidence, mark "needs proof" and park |
| **Value** (priority / tradeoff / stance) | Main agent decides as project lead; **record both stances**, do not erase the losing side |
| **Interpretive** (multiple valid readings of the same fact) | Preserve as parallel options; surface to user for final pick |

**Step 5 · Output** — A compact verdict (≤ 400 words) with three fixed fields:
- **Decision**: what was decided
- **Preserved disagreements**: which value/interpretive splits remain open and what positions
- **Action items**: who does what (named expert or main agent); emit as TodoWrite when applicable

**No raw transcript** unless the user says "show debate".

### Optional archival

By default meetings are chat-only — nothing written to disk. If the user says **"archive this meeting"** / "存档本次会议", the main agent writes the full record (each expert's segment + synthesis + decision) to `./meetings/YYYY-MM-DD-<topic>.md`, creating the `meetings/` directory as needed.

### Red-line escalation

If a question would alter `brief/goal.md` scope, remove a confirmed constraint, or overturn a prior meeting's decision, it is a **red-line topic**. The main agent **must pause**, state to the user "this will change project scope / prior decisions", and **wait for explicit consent before convening**. Red-line meeting minutes must be archived to disk — no chat-only allowed.

### Process-role boundary (do not hand-add)

This roster intentionally excludes process roles owned by host skill suites if present:
code review, TDD, debugging, planning, verification, parallel dispatch, doc/slide/sheet/pdf authoring, SDK/caching advisory, skill authoring, harness config. Those are skills, not council seats. If you feel one is missing, invoke the corresponding skill directly on your host runtime; do not add an expert that shadows it. If your host lacks such skills entirely, you may regenerate with `/expert-bootstrap` and explicitly include the missing role.

### Suggested first meeting

`{{FIRST_MEETING_PROMPT}}`

### Modifying the roster

Re-run `/expert-bootstrap` to regenerate. Do not hand-edit `{{EXPERT_DIR}}<expert>.md` — it drifts from the prompt-engineer-optimized baseline. For a single expert's tuning, dispatch `prompt-engineer` with the existing prompt + the desired change, then overwrite the file with its output.

## Project artifacts

| Path | Purpose |
|---|---|
| `brief/goal.md` | Canonical project goal — single source of truth |
| `AGENTS.md` (this file) | Council convening rules + roster index |
| `{{EXPERT_DIR}}<expert>.md` | Expert council members |

<!-- expert-bootstrap:end -->
