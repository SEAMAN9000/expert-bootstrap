---
name: expert-bootstrap
description: Use ONLY when the user explicitly asks to set up an expert council / expert team / expert committee for a project. Discovers the project goal interactively (or extracts it from existing materials), writes brief/goal.md, designs an expert roster via project-manager, refines each expert's system prompt via prompt-engineer, writes them to ./.claude/agents/ for native subagent dispatching, and creates/updates the project's CLAUDE.md with council convening rules. Trigger when the user says any of: "set up the experts", "bootstrap council", "expert bootstrap", "convene the expert council", "组建专家组", "搭建专家组", "初始化专家组", "召集专家组", "成立专家委员会", "组织专家会议", "配置项目专家", or invokes /expert-bootstrap. **This supersedes superpowers:brainstorming for project starts THAT EXPLICITLY INVOLVE an expert council** — Step 0 already performs the intent-discovery role for that case. Do NOT trigger on generic project-start phrases ("启动项目", "新项目", "开始做个项目") that do not mention experts/council/team — those should fall through to superpowers:brainstorming instead.
---

# Council Bootstrap

You are orchestrating a five-step pipeline that turns a raw project idea (or even nothing at all) into a ready-to-use expert council. The two meta-agents `prompt-engineer` and `project-manager` already exist globally. Your job is to compose them, write outputs to disk, and stop.

## Preconditions

- Current working directory is the project root. If ambiguous, ask once and confirm.
- The `prompt-engineer` and `project-manager` agents are available via the `Agent` tool with those exact `subagent_type` values.
- File layout to be produced:
  - `./brief/goal.md` — canonical project goal
  - `./.claude/agents/<expert>.md` — each expert
  - `./CLAUDE.md` — created or appended with council section
- Create `./brief/` and `./.claude/agents/` directories if missing.

---

## Step 0 — Project discovery

Classify the user's starting state into one of three:

**State A — Clear goal already stated in conversation.**
Restate it in one sentence. Ask "确认这是项目目标吗？(y / 改)". On confirm, write the raw statement to `brief/goal.md` and proceed to Step 1.

**State B — Has fragments** (notes, partial requirements, existing folder/files, vision sentence).
Read whatever the user points at — use `Read` on listed files, `Glob`/`Grep` if a folder. Synthesize a draft one-paragraph goal grounded in those materials. Show the draft and list the sources you read. Ask "确认这是基于你材料归纳的目标吗？(y / 改 / 补充)". Apply edits, then write to `brief/goal.md`.

**State C — Nothing beyond "I want to start a project".**
Run interactive discovery. Ask the following **one question at a time** (do NOT batch — wait for each answer). Stop the moment you have enough to draft a one-paragraph goal (typically after 3–5 answers):

1. **要解决的真实问题是什么？**（描述痛点，不是方案）
2. **谁会感受到这个问题？**（你自己 / 一个团队 / 某类用户 — 越具体越好）
3. **30 天后看到什么就算成功？**（可观察的结果，不是"能跑"）
4. **最硬的约束是什么？**（时间 / 技能空白 / 现有系统 / 预算）
5. **明确不做的一件事是什么？**（划边界）

允许"不知道"作为合法答案 — 记为 `unknown`，不要逼问。3 题后即可起草，把草稿展示给用户确认；批准后写入 `brief/goal.md`。

**Step 0 出口契约**：`brief/goal.md` 存在、有用户确认的原始版本。

---

## Step 1 — Refine the goal

Dispatch `prompt-engineer` with `subagent_type: "prompt-engineer"`. Pass the contents of `brief/goal.md` (Read it fresh) and explicitly say: **"output: a refined project goal statement, not an agent system prompt"**.

Show the user the before/after diff. Ask "确认采用精修版？(y / 还原)".
- On `y`: overwrite `brief/goal.md` with the refined version.
- On `还原`: keep the raw version.

`brief/goal.md` is now the canonical brief for all downstream steps.

---

## Step 2 — Design the roster

Read `brief/goal.md` (do not assume cache). Dispatch `project-manager` with `subagent_type: "project-manager"`, passing its contents.

It returns a YAML roster of 3–7 experts. If malformed or contains `NEED CLARIFICATION:`, surface to the user, get the answer, and re-dispatch.

Show the roster as a compact table (name | title | why_needed) and ask **"确认名单？(y / 改 / 加 / 删)"**. Apply edits by re-dispatching project-manager with the edit instruction — do not hand-edit YAML.

---

## Step 3 — Refine each expert's prompt

For each approved expert, dispatch `prompt-engineer` **in parallel** (one Agent call per expert in the same response). Pass:
- The expert's `role_brief_for_prompt_engineer` field
- The contents of `brief/goal.md` as project context

Each call returns a fenced markdown block containing the production-ready system prompt.

---

## Step 4 — Write to disk

For each expert, write `./.claude/agents/<name>.md` (strip the markdown fence from prompt-engineer's output for the body):

```
---
name: <expert.name>
description: Use when... <expert.why_needed reframed as a trigger>
---

<refined system prompt body>
```

Then handle `./CLAUDE.md`:
- Read `templates/CLAUDE.md.tpl` from this skill directory.
- Substitute:
  - `{{PROJECT_BRIEF}}` → first line of `brief/goal.md` (one-sentence summary)
  - `{{ROSTER_TABLE}}` → markdown table of experts (name | title | why_needed)
  - `{{COUNCIL_DATE}}` → today's date (YYYY-MM-DD)
- If `./CLAUDE.md` does NOT exist: write the filled template.
- If it EXISTS: do NOT overwrite. Show the user a diff of the council section and append it as a `## Expert Council` section after confirmation.

---

## Step 5 — Report and stop

Output exactly this format, then stop:

```
✅ Council bootstrapped
   Goal:     <one line from brief/goal.md>
   Brief:    ./brief/goal.md
   Experts:  <n> written to ./.claude/agents/
             - <name1>
             - <name2>
             ...
   CLAUDE.md: <created | appended>

Next: 主 agent 会按 description 自动召唤专家；
       也可显式 Agent(subagent_type="<expert-name>") 派发。
       重跑 /expert-bootstrap 可整体翻新。
```

Do not start using the experts yourself. Do not propose implementation steps. The bootstrap is the deliverable.

---

## Failure modes to avoid

- **Do not skip Step 0 discovery for State B/C.** A thin brief produces a thin roster.
- **Do not inline expert prompts into your own context.** Always dispatch prompt-engineer; never write a prompt yourself.
- **Do not bundle Steps 2–4 into one mega-dispatch.** Each step's output is the next step's input; bundling loses the user-confirmation gates.
- **Do not write experts to `~/.claude/agents/`** (global). Always project-local at `./.claude/agents/`.
- **Do not hand-edit YAML rosters or refined prompts.** Re-dispatch the relevant meta-agent.
- **Do not overwrite an existing CLAUDE.md.** Append the council section.
