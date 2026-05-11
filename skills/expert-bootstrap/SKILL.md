---
name: expert-bootstrap
description: Use ONLY when the user explicitly asks to set up an expert council / expert team / expert committee for a project. Detects the host runtime (Claude Code vs. portable), discovers the project goal once interactively, then autonomously refines the goal, designs an expert roster via project-manager, refines each expert's system prompt via prompt-engineer, writes them to the runtime-appropriate location (`./.claude/agents/` + `CLAUDE.md` on Claude Code, `./agents/` + `AGENTS.md` elsewhere), and announces readiness with a seeded first-meeting prompt. Canonical triggers (any of these, exact): `/expert-bootstrap`, "set up the experts", "convene the expert council", "组建专家组", "搭建专家组", "初始化专家组", "召集专家组", "成立专家委员会". Generic project-start phrases ("启动项目", "新项目", "start a new project") do NOT trigger this — they fall through to superpowers:brainstorming when present.
---

# Council Bootstrap

You orchestrate a single autonomous run that turns a confirmed project goal into a ready-to-use expert council. The two meta-agents `prompt-engineer` and `project-manager` are dispatched by you. Your job is to compose them, write outputs to disk, announce readiness, and stop.

## Preconditions

- Current working directory is the project root. If ambiguous, ask once.
- The `prompt-engineer` and `project-manager` agents are available either as native subagents (`Agent(subagent_type="…")`) or as inline-prompt fallbacks if the host lacks subagent dispatch.
- Create needed directories on demand. Do not pre-create anything until Step 4.

---

## Step −1 — Runtime detection (silent, before Step 0)

Decide the deploy mode **once** and remember for the run. Apply signals in this priority order — first match wins:

1. **Filesystem signal (strongest)** — does `./.claude/` exist in the project root, OR does `~/.claude/` exist in the user home? If yes → `claude` mode. Use `Glob` or equivalent to check.
2. **Tool-availability signal** — is there an `Agent` tool exposed that accepts `subagent_type` as a parameter, AND is `subagent_type="prompt-engineer"` invokable (i.e., the meta-agent is registered as a native subagent)? If yes → `claude` mode.
3. **Conversation signal** — has the user explicitly named their host runtime in this session (e.g., "I'm on Codex CLI")? Honor it.
4. **Default** — `portable` mode. It works everywhere; Claude Code can still read `AGENTS.md` as a secondary signal even if `CLAUDE.md` is its native one, and an expert directory at `./agents/` is loadable by every host examined.

| Mode | Expert dir | Manifest file |
|---|---|---|
| `claude` | `./.claude/agents/` | `./CLAUDE.md` |
| `portable` | `./agents/` | `./AGENTS.md` |

Announce the detected mode in **one short line** before Step 0 so the user can correct it:
`检测到 <mode> 模式，专家将写入 <expert_dir>。如需切换回复 "切换 portable" 或 "切换 claude"。`

The detected mode (`claude` or `portable`) is the **runtime_mode** value passed to project-manager and prompt-engineer in Steps 2–3. Remember it for the entire run.

---

## Step 0 — Goal discovery (ONLY interactive step)

Classify the user's starting state:

**State A — Clear goal already stated.** Restate in one sentence. Ask "确认这是项目目标吗？(y / 改)". On confirm, write to `brief/goal.md`.

**State B — Has fragments** (notes, files, partial folder). Read what the user points at. Synthesize a draft one-paragraph goal grounded in those materials. Show the draft, list the sources you read. Ask "确认？(y / 改 / 补充)". Apply edits, write to `brief/goal.md`.

**State C — Nothing beyond "I want to start a project".** Ask **outcome-first**, one at a time, **maximum 3 questions** (stop the moment you have enough):

1. **30 天后你想看到什么具体结果？**（可观察的结果，不是"能跑"）
2. **谁会感受到这个结果？**（你自己 / 团队 / 某类用户 — 越具体越好）
3. **最硬的约束是什么？**（时间 / 技能空白 / 现有系统）

"不知道"是合法答案——记为 `unknown`，不要逼问。任何一题后若已够起草，立即起草并展示。批准后写入 `brief/goal.md`。

**Step 0 出口契约**：`brief/goal.md` 存在、有用户确认的原始版本。**从此处起进入全自动流水线，不再询问用户**，直到 Step 5 终态提醒。

---

## Step 1 — Refine goal (autonomous)

Dispatch `prompt-engineer` (native subagent if available; otherwise inline prompt). Pass the contents of `brief/goal.md` with the explicit instruction: **"output: a refined project goal statement, not an agent system prompt"**.

Overwrite `brief/goal.md` with the refined version. **Do not ask for confirmation.** If the refined version is materially different, mention this in the Step 5 announcement.

---

## Step 2 — Design roster (autonomous)

Read `brief/goal.md` fresh. Dispatch `project-manager` passing **two** inputs:
1. The contents of `brief/goal.md`.
2. A line stating `runtime_mode: <claude|portable>` (the value detected in Step −1). This activates the correct blacklist tier: in `claude` mode, project-manager applies the full host-skill avoidance table; in `portable` mode, only the cross-platform rows (anthropic-skills / platform-skill rows that may be present) activate by default, and superpowers rows deactivate unless the user has stated otherwise.

It returns a YAML roster of 3–4 experts (or up to 7 if the project genuinely spans disjoint domains).

**Handling `NEED CLARIFICATION:`** — if the YAML body is exactly a `NEED CLARIFICATION: <question>` line, this is the only permitted interaction in the autonomous segment. Surface the question to the user verbatim, wait for the answer, then re-dispatch project-manager with the original inputs PLUS the user's answer appended as `user_clarification: <answer>`. Loop at most twice; if a third clarification is needed, halt the run and report.

If the YAML is valid, proceed silently. Hold it in memory for Step 3 — do not persist as a file.

---

## Step 3 — Refine each expert's prompt (autonomous, parallel)

Dispatch `prompt-engineer` **in parallel** — one call per expert in the same response. Pass:
- The expert's `role_brief_for_prompt_engineer` field
- The contents of `brief/goal.md` as project context
- The detected runtime mode (so prompts avoid host-specific assumptions)

Each call returns a fenced markdown block containing the production-ready system prompt with valid frontmatter (`name:` kebab-case, `description:` one sentence).

If any single dispatch fails or returns malformed output, retry once with a clarifying note. If it fails twice, **halt the run** and report exactly which expert failed — do not silently ship a partial council.

---

## Step 4 — Write to disk (autonomous)

For each expert, write to `<expert_dir>/<name>.md` (mode-appropriate path from Step −1). Strip the prompt-engineer's outer markdown fence.

The body each expert file must start with valid frontmatter:
```
---
name: <kebab-case name>
description: <one-sentence trigger>
---

<refined system prompt body>
```

Then write the manifest file:
- **claude mode** → `./CLAUDE.md` filled from `templates/CLAUDE.md.tpl`
- **portable mode** → `./AGENTS.md` filled from `templates/AGENTS.md.tpl`

Substitutions:
- `{{PROJECT_BRIEF}}` → first line of `brief/goal.md`
- `{{ROSTER_TABLE}}` → markdown table of `name | title | why_needed`
- `{{COUNCIL_DATE}}` → today's date (YYYY-MM-DD)
- `{{EXPERT_DIR}}` → `./.claude/agents/` or `./agents/`
- `{{FIRST_MEETING_PROMPT}}` → see Step 5 — same string is also surfaced in the announcement

If the manifest file already exists, do NOT overwrite. Replace only the section between `<!-- expert-bootstrap:begin -->` and `<!-- expert-bootstrap:end -->` sentinels. If sentinels are absent, append the section once with sentinels wrapping it.

If a roster shrink leaves orphan `<old-name>.md` files in `<expert_dir>/`, list them in the Step 5 announcement as `孤儿（可手动删除）` — do not delete automatically.

---

## Step 5 — Announce readiness (templated)

Output exactly this format, then stop. **Do not propose implementation steps. Do not start using the experts yourself.** The bootstrap is the deliverable.

```
🎓 专家组已就位，<N> 席待命

  goal:    <one line from brief/goal.md>
  mode:    <claude | portable>
  experts: <expert_dir>
           - <name1>  (<one-liner title>)
           - <name2>  (<one-liner title>)
           - ...
  manifest: <CLAUDE.md | AGENTS.md>

────────────────────────────────────────────────────
🪑 现在你可以随时召开会议，例如：

  「<FIRST_MEETING_PROMPT>」

  这是一个典型的跨领域问题——多个专家会从各自视角发言，
  怀疑席（如有）会压轴。直接把这一行（或你的改写）发给我即可。
────────────────────────────────────────────────────

需要别的专家组？  /expert-bootstrap 重跑可整体翻新。
```

**Generating `FIRST_MEETING_PROMPT`**: derive one cross-domain question from `brief/goal.md` + roster. Pick the tension point that most clearly hits ≥2 experts' territories. Phrase as a concrete decision the council can take, not a vague "discuss". One sentence, paste-ready.

Example (this project's own first meeting):
> 在「跨平台 + 文件系统化简 + 一次成型 UX」三条约束下，专家文件该生成到 `./agents/` 还是 `./.claude/agents/`？AGENTS.md 与 CLAUDE.md 如何并存？把 v2 路线图重新排序。

---

## Failure modes to avoid

- **Do not skip Step 0 discovery for State B/C.** A thin brief produces a thin roster.
- **Do not insert user-confirmation prompts in Steps 1–4** beyond Step 2's `NEED CLARIFICATION:` escape hatch. The promise is one-shot autonomy after goal confirmation.
- **Do not inline expert prompts into your own context.** Always dispatch prompt-engineer.
- **Do not write experts to `~/.claude/agents/` or `~/.codex/agents/`** (global). Always project-local in the detected mode's path.
- **Do not hand-edit YAML rosters or refined prompts mid-run.** Re-dispatch the relevant meta-agent.
- **Do not overwrite an existing manifest file.** Use sentinel-bounded replacement.
- **Do not persist roster.yaml or state.json.** The run is one-shot; the only durable artifacts are `brief/goal.md`, `<expert_dir>/*.md`, and the manifest file.
