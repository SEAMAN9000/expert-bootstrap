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

Three legitimate paths — pick by intent, never bypass.

**A · Wholesale regenerate** — re-run `/expert-bootstrap`. Rewrites `brief/goal.md` and every `{{EXPERT_DIR}}*.md`; loses any tuning. Use only when the roster is broadly miscast.

**B · Tune one expert** — dispatch `prompt-engineer` with that expert's existing prompt + your desired change; overwrite the file with the result. **Tune only — do not add or remove via this path.**

**C · Add one expert (add-one)** — when the user asks to add / hire / staff one more expert (English or other languages), the main agent does NOT convene a meeting; it runs this recipe itself:

1. **Intent check** — did the user state what the new expert is responsible for?
   - Yes → step 2.
   - No → ask once: "What does this expert mainly own? How would it split work with <closest existing expert>?" Get the answer before proceeding. Do not let meta-agents invent responsibilities from thin air.
2. **Snapshot existing roster** — read all frontmatter from `{{EXPERT_DIR}}*.md` and build `existing_roster:` (each entry: `name / title / decides / responsibilities / must_not`).
3. **Dispatch `project-manager` (extend mode)** with one combined input:
   - `mode: extend`
   - `runtime_mode: portable`
   - `existing_roster:` (from step 2)
   - `addition_request: <user's sentence + any clarifications from step 1>`
   - The contents of `brief/goal.md` as project context.
   It returns a single `new_expert:` YAML plus optional `sibling_adjustments_suggested:`.
4. **Boundary preview** — display `new_expert.must_not` and `sibling_adjustments_suggested` to the user verbatim and ask "boundaries OK? (y / change)". This is the only human gate on this path. On reject, redispatch step 3 with the user's correction; on approve, proceed.
5. **Dispatch `prompt-engineer` (Mode C)** with:
   - `existing_roster:` (same as step 2)
   - `extension_rationale: <new_expert.why_needed from step 3>`
   - `role_brief_for_prompt_engineer:` (from `new_expert`)
   - `runtime_mode: portable`
   Returns a complete agent file with valid frontmatter.
6. **Write to disk** — write `{{EXPERT_DIR}}<new-name>.md` (strip outer markdown fence). Never overwrite an existing expert file — on name collision, prompt-engineer's contract returns `NEED CLARIFICATION:` already; handle it in step 5.
7. **Update the roster table** — append one row `| <name> | <title> | <why_needed> |` to the `### Roster` table above. If `sibling_adjustments_suggested` was approved in step 4, run path B against each named sibling to fold the suggested `must_not` addition into its prompt — do not hand-edit the sibling's file.
8. **Announce** — `✅ <new-name> ready, roster is now <N+1>. Council convening rules (skeptic auto-included when ≥3 dispatched) already cover the new seat.`

**Any step returning `NEED CLARIFICATION:`** → forward that line verbatim to the user, wait for the answer, redispatch from the same step. Cap at two retries; on the third, halt and report. Never hallucinate a fallback.

**Any step failing** → halt and tell the user which step and why; never silently persist a half-finished add.

**Forbidden on this path**: skipping step 4 (boundary preview); skipping step 2 (existing-roster snapshot); using `prompt-engineer` Mode B (non-incremental) to generate the new expert (bypasses naming / overlap / must_not checks); hand-editing `{{EXPERT_DIR}}*.md`.

## Project artifacts

| Path | Purpose |
|---|---|
| `brief/goal.md` | Canonical project goal — single source of truth |
| `AGENTS.md` (this file) | Council convening rules + roster index |
| `{{EXPERT_DIR}}<expert>.md` | Expert council members |

<!-- expert-bootstrap:end -->
