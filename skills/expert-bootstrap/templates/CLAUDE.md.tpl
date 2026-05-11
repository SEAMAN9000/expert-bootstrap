# Project: {{PROJECT_BRIEF}}

> Council bootstrapped {{COUNCIL_DATE}} via `/expert-bootstrap` (Claude Code mode).

<!-- expert-bootstrap:begin -->

## Expert Council

This project uses a council of domain experts living in `{{EXPERT_DIR}}`. They are dispatched via Claude Code's native `Agent` tool with `subagent_type=<expert-name>`.

### Roster

{{ROSTER_TABLE}}

### Convening rules — five-step meeting flow

The main agent plays both **议事主席（facilitator）** and **决议人（project lead / approver）** — process-role expansion is forbidden by design. Every council meeting, even single-turn ones, follows these five steps:

**Step 1 · 立项 (Initiation)** — Before dispatching anyone, the main agent silently answers the **议题立项 4 问**:
1. 这个议题要解决什么决策？（不是"讨论"，是"决定什么"）
2. 哪些产出 / 文件 / 流程会受这个决议影响？
3. 最少必须召集哪几位专家？（命中谁的 `decides:` 或 `responsibilities:`）
4. 期望的决议形态？（单一结论 / 多方案并列保留 / 委托执行）

**如果第 3 问得出 0 或 1 位专家，这不是议会议题——主 agent 直接回答，不要召集。**

**Step 2 · 挑选 (Selection)** — Dispatch only experts whose territory the question genuinely touches. Skip experts whose `must_not` lists the question's domain. Whenever ≥3 experts are dispatched and a skeptic seat exists, the skeptic is always included. Cap at council size; no "全员到场" reflex.

| 常见议题 | 默认必到 |
|---|---|
| 单一专家独占决策权的问题 | 不召集，主 agent 直接转交该专家 |
| 跨两位专家的接口 / 边界 | 这两位 + 怀疑席（如有） |
| 跨三位以上专家的架构 / 范围 / 取舍 | 命中的专家全到 + 怀疑席 |
| 触及 `brief/goal.md` 范围变更 | 暂停召集，先按"红线"流程升级 |

**Step 3 · 引导 (Facilitation)** — Dispatch all selected experts **in parallel** with the **same question text** (verbatim, no per-expert edits). Each returns an independent opinion under a `### <expert-name>` heading. No expert sees another's reply during this phase. **Skeptic speaks last** before synthesis — its position can override majority if grounded in a specific failure mode.

**Step 4 · 综合 (Synthesis)** — Classify every disagreement using the **conflict triad**, then resolve per type:

| 冲突类型 | 仲裁路径 |
|---|---|
| **事实分歧** (事实 / 数据 / 引用对错) | 用证据核查；无证据则标注"需补证据"并暂存 |
| **价值分歧** (优先级 / 取舍 / 立场) | 主 agent 作为决议人裁断；**两方立场都记录在案**，不抹去败方 |
| **解释分歧** (同一事实的多种合理读法) | 并列保留为多方案，交回用户裁决 |

**Step 5 · 输出 (Output)** — A compact verdict (≤ 400 words) with three固定字段：
- **决议**：本次会议作出的决定
- **保留分歧**：哪些价值/解释分歧未消化、对应哪些立场
- **行动项**：谁做什么（指向具体专家或主 agent）；若适用，作为 TodoWrite 落地

**No raw transcript** unless the user says "show debate" / "展示原始辩论"。

### Optional archival

By default meetings are chat-only — nothing written to disk. If the user says **"存档本次会议"** / "archive this meeting"，主 agent 将完整记录（含每位专家发言段、综合段、决议段）落到 `./meetings/YYYY-MM-DD-<topic>.md`，并自动创建 `meetings/` 目录。

### Red-line escalation

如果议题会修改 `brief/goal.md` 的范围、删除已确认的约束、或推翻先前会议的决议——这是红线议题。主 agent **必须停下来**，向用户陈述"此问题将改变项目范围/先前决议"，**等用户明确同意才继续召集**。红线议题的纪要必须落盘，不可仅在 chat。

### Process-role boundary (do not hand-add)

This roster intentionally excludes process roles owned by superpowers or other host skills if installed:
code review, TDD, debugging, planning, verification, parallel dispatch, doc/slide/sheet/pdf authoring, SDK/caching advisory, skill authoring, harness config. Those are skills, not council seats. If you feel one is missing, invoke the skill directly; do not add an expert that shadows it. If a needed skill is NOT installed on this host, regenerate with `/expert-bootstrap` and the missing role may be staffed.

### Suggested first meeting

`{{FIRST_MEETING_PROMPT}}`

### Modifying the roster

Three legitimate paths — pick by intent, never bypass.

**A · Wholesale regenerate** — re-run `/expert-bootstrap`. Rewrites `brief/goal.md` and every `{{EXPERT_DIR}}*.md`; loses any tuning. Use only when the roster is broadly miscast.

**B · Tune one expert** — dispatch `prompt-engineer` with that expert's existing prompt + your desired change; overwrite the file with the result. **Tune only — do not add or remove via this path.**

**C · Add one expert (add-one)** — when the user says **`加一位 / 招一位 / 还缺一个 … 专家`** or "add a / hire a / we need a … expert" (or near-equivalents), the main agent **does NOT convene a meeting**; it runs this recipe itself:

1. **Intent check** — did the user state what the new expert is responsible for?
   - Yes → step 2.
   - No → ask once: "What does this expert mainly own? How would it split work with <closest existing expert>?" Get the answer before proceeding. **Do not let meta-agents invent responsibilities from thin air.**
2. **Snapshot existing roster** — read all frontmatter from `{{EXPERT_DIR}}*.md` and build `existing_roster:` (each entry: `name / title / decides / responsibilities / must_not`).
3. **Dispatch `project-manager` (extend mode)** with one combined input:
   - `mode: extend`
   - `runtime_mode: claude`
   - `existing_roster:` (from step 2)
   - `addition_request: <user's sentence + any clarifications from step 1>`
   - The contents of `brief/goal.md` as project context.
   It returns a single `new_expert:` YAML plus optional `sibling_adjustments_suggested:`.
4. **Boundary preview** — display `new_expert.must_not` and `sibling_adjustments_suggested` to the user verbatim and ask "边界这样划分 OK 吗？(y / 改 / boundaries OK?)". This is the **only** human gate on this path. On reject, redispatch step 3 with the user's correction; on approve, proceed.
5. **Dispatch `prompt-engineer` (Mode C)** with:
   - `existing_roster:` (same as step 2)
   - `extension_rationale: <new_expert.why_needed from step 3>`
   - `role_brief_for_prompt_engineer:` (from `new_expert`)
   - `runtime_mode: claude`
   Returns a complete agent file with valid frontmatter.
6. **Write to disk** — write `{{EXPERT_DIR}}<new-name>.md` (strip the outer markdown fence). **Never overwrite an existing expert file** — on name collision, prompt-engineer's contract returns `NEED CLARIFICATION:` already; handle it in step 5.
7. **Update the roster table** — append one row `| <name> | <title> | <why_needed> |` to the `### Roster` table above. If `sibling_adjustments_suggested` was approved in step 4, run path B against each named sibling to fold the suggested `must_not` addition into its prompt — do not hand-edit the sibling's file.
8. **Announce** — `✅ <new-name> ready, roster is now <N+1>. Council convening rules (skeptic auto-included when ≥3 dispatched) already cover the new seat.`

**Any step returning `NEED CLARIFICATION:`** → forward that line verbatim to the user, wait for the answer, redispatch from the same step. Cap at two retries; on the third, halt and report. **Never hallucinate a fallback.**

**Any step failing** → halt and tell the user which step and why; **never silently persist a half-finished add**.

**Forbidden on this path**: skipping step 4 (boundary preview); skipping step 2 (existing-roster snapshot); using `prompt-engineer` Mode B (non-incremental) to generate the new expert (bypasses naming / overlap / must_not checks); hand-editing `{{EXPERT_DIR}}*.md`.

## Project artifacts

| Path | Purpose |
|---|---|
| `brief/goal.md` | Canonical project goal — single source of truth |
| `CLAUDE.md` (this file) | Council convening rules + roster index |
| `{{EXPERT_DIR}}<expert>.md` | Expert council members, project-local, native subagent dispatching |

<!-- expert-bootstrap:end -->
