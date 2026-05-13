---
name: expert-bootstrap
description: 仅当用户明确要求为某项目搭建专家组 / 专家委员会 / 专家团时调用。会先检测 AI 编程工具（Claude Code / Codex CLI / OpenCode），一次性交互式抓取项目目标，然后自动精炼目标、通过 project-manager 设计专家名册、通过 prompt-engineer 精修每位专家的 system prompt，并按运行时把产物写到对应位置（Claude Code 是 `./.claude/agents/<name>.md` + `CLAUDE.md`；Codex CLI 是 `./skills/<name>/SKILL.md` + `AGENTS.md`；OpenCode 是 `./.opencode/skills/<name>/SKILL.md` + `AGENTS.md`），最后给出可粘贴的首次议会题。规范触发短语（须精确匹配，任一即可，中英文均可）：`/expert-bootstrap`、"组建专家组"、"搭建专家组"、"初始化专家组"、"召集专家组"、"成立专家委员会"、"set up the experts"、"build the expert council"、"initialize the expert council"、"convene the expert council"、"form the expert committee"。泛义的"启动项目 / 新项目 / start a new project / let's spin up a team"等近义表达**不**触发本 skill——它们会落到 `superpowers:brainstorming`（如装了）。
---

# 专家组搭建（Council Bootstrap）

你负责把一个已确认的项目目标，自动转化为一组随时可用的专家组。两个 meta-agent `prompt-engineer` 与 `project-manager` 由你派发。你的职责是：编排它们、把产物写盘、宣告就位、停下。

## 前置条件

- 当前工作目录是项目根。如果存在歧义，问一次。
- `prompt-engineer` 与 `project-manager` 必须可用——要么作为原生 subagent（`Agent(subagent_type="…")`），要么作为同名 skill 被 AI 编程工具加载（Codex / OpenCode 把它们当 skill 处理）。
- 目录按需创建。**Step 4 之前不要预创建任何东西。**

---

## Step −1 · 运行时检测（静默，Step 0 之前）

整次运行**只决定一次**部署模式并记住。三种模式：`claude` / `codex` / `opencode`。按优先级匹配，**首条命中即停**：

1. **对话信号（最强）** —— 系统提示词或环境上下文是否明确披露宿主名？
   - 出现 "Claude Code" / "Anthropic CLI" → `claude` 模式
   - 出现 "Codex CLI" / "OpenAI Codex" → `codex` 模式
   - 出现 "OpenCode" / "opencode.ai" → `opencode` 模式
2. **工具可用性信号** —— 当前是否存在 `Agent` 工具，且接受 `subagent_type` 参数，**且** `subagent_type="prompt-engineer"` 可调用？是 → `claude` 模式。
3. **文件系统信号** —— 项目根存在 `./.claude/` → `claude`；存在 `./.opencode/` → `opencode`；存在 `./skills/` 但前两者都不存在 → `codex`。用 `Glob` 或等价能力检查。
4. **用户显式声明** —— 用户在本次会话里说 "我在 X" → 尊重它。
5. **缺省** —— `codex` 模式。无法分辨时按 Codex 处理（项目根 `./skills/` + `./AGENTS.md` 是最被广泛遵守的非 Claude 约定）。

| 模式 | 专家文件 | manifest 文件 | 文件结构 |
|---|---|---|---|
| `claude` | `./.claude/agents/<name>.md` | `./CLAUDE.md` | 扁平：每位专家一个 .md |
| `codex` | `./skills/<name>/SKILL.md` | `./AGENTS.md` | 嵌套：每位专家一个文件夹，内固定名 `SKILL.md` |
| `opencode` | `./.opencode/skills/<name>/SKILL.md` | `./AGENTS.md` | 嵌套：在 `.opencode/skills/` 下，每位专家一个文件夹 |

Step 0 之前用**单行**宣告检测结果，便于用户纠错：
`检测到 <mode> 模式，专家将写入 <expert_dir>。如需切换回复 "切换 claude" / "切换 codex" / "切换 opencode"。`

检测到的模式（`claude` / `codex` / `opencode`）就是 Step 2–3 传给 project-manager 和 prompt-engineer 的 **runtime_mode** 值，整次运行牢记。

---

## Step 0 · 目标发现（唯一交互步）

按用户的起点状态分三类处理：

**状态 A · 已说清目标。** 用一句话复述。问"确认这是项目目标吗？(y / 改)"。确认后写入 `brief/goal.md`。

**状态 B · 有片段** （笔记、文件、半成品目录）。读用户指向的内容，基于这些材料起草一段（一个段落）项目目标。展示草稿 + 你读过的源。问"确认？(y / 改 / 补充)"。按用户修改后写入 `brief/goal.md`。

**状态 C · 除了"我想做个项目"以外什么都没有。** 用 **outcome-first** 风格提问，**一次一个，最多 3 个**（够了就立刻停）：

1. **30 天后你想看到什么具体结果？**（可观察的结果，不是"能跑"）
2. **谁会感受到这个结果？**（你自己 / 团队 / 某类用户——越具体越好）
3. **最硬的约束是什么？**（时间 / 技能空白 / 现有系统）

"不知道"是合法答案——记为 `unknown`，不要逼问。任何一题后只要够起草，立即起草并展示。批准后写入 `brief/goal.md`。

**Step 0 出口契约**：`brief/goal.md` 存在，且持有用户已确认的原始版本。**从此进入全自动流水线，不再询问用户**，直到 Step 5 的终态广播。

---

## Step 1 · 精炼目标（自动）

派发 `prompt-engineer`（有原生 subagent 用原生；否则用 inline prompt）。把 `brief/goal.md` 的内容传入，附带显式指令：**"output: a refined project goal statement, not an agent system prompt"**。

用精炼后的版本**覆写** `brief/goal.md`。**不再问用户**。若与原版有显著差异，Step 5 的就位公告里顺带提一下。

---

## Step 2 · 设计名册（自动）

重新读取 `brief/goal.md`。派发 `project-manager`，传入**两项**输入：

1. `brief/goal.md` 的内容。
2. 一行 `runtime_mode: <claude|codex|opencode>`（Step −1 检测出的值）。这会激活对应的黑名单层级：`claude` 模式下 project-manager 应用完整的工具自带 skill 避让表；`codex` / `opencode` 模式下仅跨平台行（anthropic-skills / 平台 skill 行）默认激活，superpowers 行**不**默认激活（除非用户明示有）。

它会返回一个 YAML 名册，3–4 位专家（仅当项目确实跨多个不相交领域时才到 7）。

**处理 `NEED CLARIFICATION:`** —— 若返回体正好是一行 `NEED CLARIFICATION: <问题>`，这是自动段里**唯一**允许的交互。把问题原文转给用户，等回答后用原输入 + 追加一行 `user_clarification: <答案>` 重新派发 project-manager。最多两轮；若第三轮还要追问，**停下并报告**。

若 YAML 合法，静默继续。**在内存中**持有它给 Step 3 用——**不要写成文件**。

---

## Step 3 · 精修每位专家的 prompt（自动，并行）

**并行**派发 `prompt-engineer`——同一回合内每位专家一次调用。每次传入：

- 该专家的 `role_brief_for_prompt_engineer` 字段
- `brief/goal.md` 的内容作为项目背景
- Step −1 检测出的运行时模式（确保 prompt 不依赖 AI 编程工具特定假设）

每次返回一个带围栏（fenced）的 markdown 块，内容是带合法 frontmatter（`name:` kebab-case、`description:` 一句话）的生产就绪 system prompt。

任一调用失败或返回畸形，**附带澄清说明重试一次**。若仍失败，**整体停下并报告**究竟哪位专家失败——绝不静默吐出残缺名册。

---

## Step 4 · 写盘（自动）

每位专家的目标路径**取决于 Step −1 的模式**：

- **claude 模式** —— 写入 `./.claude/agents/<name>.md`（扁平：单文件直接落在 agents 目录下）。
- **codex 模式** —— 先 `mkdir -p ./skills/<name>/`，再写入 `./skills/<name>/SKILL.md`（嵌套：项目根的 `./skills/` 目录下每位专家一个文件夹，内含固定名 `SKILL.md`）。
- **opencode 模式** —— 先 `mkdir -p ./.opencode/skills/<name>/`，再写入 `./.opencode/skills/<name>/SKILL.md`（嵌套：OpenCode 项目专属目录 `./.opencode/skills/`，结构同 codex）。

**剥掉** prompt-engineer 外层的 markdown 围栏。

每个专家文件的正文必须以合法 frontmatter 开头：

```
---
name: <kebab-case 名字>
description: <一句话触发场景>
---

<精修后的 system prompt 正文>
```

接着写 manifest 文件：

- **claude 模式** → `./CLAUDE.md`，从 `templates/CLAUDE.md.tpl` 填充
- **codex / opencode 模式** → `./AGENTS.md`，从 `templates/AGENTS.md.tpl` 填充（两种模式共用此 manifest 约定，只是 `{{EXPERT_DIR}}` 不同）

替换 token：

- `{{PROJECT_BRIEF}}` → `brief/goal.md` 的首行
- `{{ROSTER_TABLE}}` → 一个 `name | title | why_needed` 的 markdown 表
- `{{COUNCIL_DATE}}` → 今日日期（YYYY-MM-DD）
- `{{EXPERT_DIR}}` → claude 模式 `./.claude/agents/`；codex 模式 `./skills/`；opencode 模式 `./.opencode/skills/`
- `{{EXPERT_FILE_PATTERN}}` → claude 模式 `<expert_dir><name>.md`；codex / opencode 模式 `<expert_dir><name>/SKILL.md`
- `{{FIRST_MEETING_PROMPT}}` → 见 Step 5——这同一行也会在就位公告里出现

若 manifest 文件**已存在**，**不要覆写**。仅替换 `<!-- expert-bootstrap:begin -->` 与 `<!-- expert-bootstrap:end -->` 这两行哨兵之间的内容。若哨兵不存在，**追加**一次（连同哨兵一起包裹）。

若名册缩水后残留旧专家产物（claude 模式：孤立的 `<old-name>.md`；codex / opencode 模式：孤立的 `<old-name>/` 文件夹），**Step 5 公告里列为"孤儿（可手动删除）"**——不要自动删。

---

## Step 5 · 宣告就位（模板化）

**严格按下列格式输出，然后停下。不要建议实施步骤。不要自己开始用专家。**搭建完成本身就是交付物。

```
🎓 专家组已就位，<N> 席待命

  goal:    <brief/goal.md 第一行>
  mode:    <claude | codex | opencode>
  experts: <expert_dir>
           - <name1>  (<一句话 title>)
           - <name2>  (<一句话 title>)
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

**生成 `FIRST_MEETING_PROMPT`** ：从 `brief/goal.md` + 名册中导出一个跨领域问题。选取最能命中 ≥2 位专家领地的张力点，措辞为一个**议会可裁决的具体决策**，不是空泛的"讨论"。**一句话，可直接粘贴**。

---

## 失败模式（必须规避）

- **不要跳过 Step 0**——状态 B/C 下"省一步"换来的是稀薄的 brief，必然产出稀薄的名册。
- **Step 1–4 不要插入用户确认 prompt**——除 Step 2 的 `NEED CLARIFICATION:` 逃生口之外的任何"再问一下"都违约。一次确认、一次自治的承诺源头在这里。
- **不要把专家 prompt 内联进你自己的上下文**——永远派发 prompt-engineer 去写。
- **不要把专家写到 `~/.claude/agents/`、`~/.codex/skills/`、`~/.config/opencode/skills/` 等全局位置**。永远按检测到的模式写到**项目本地**——claude 模式下 `./.claude/agents/`，codex 模式下 `./skills/`，opencode 模式下 `./.opencode/skills/`。
- **运行中途不要手动改 YAML 名册或精修后的 prompt**——重新派发对应 meta-agent。
- **不要覆写既有的 manifest 文件**——用哨兵包裹的替换。
- **不要持久化 roster.yaml 或 state.json**——本次运行是 one-shot。唯一的耐久产物是：`brief/goal.md`、`<expert_dir>/*.md` 与 manifest 文件。
