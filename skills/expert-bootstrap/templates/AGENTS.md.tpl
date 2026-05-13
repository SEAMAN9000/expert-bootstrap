# 项目：{{PROJECT_BRIEF}}

> 专家组由 `/expert-bootstrap` 于 {{COUNCIL_DATE}} 搭建（portable 模式）。

<!-- expert-bootstrap:begin -->

## 专家组（Expert Council）

本项目使用一组项目本地领域专家，活在 `{{EXPERT_DIR}}` 下——每位专家是一个文件夹 `<name>/`，内含固定名 `SKILL.md`，这是 Codex CLI 项目级 skill 加载约定。

**Codex CLI** 在项目根目录会自动扫描 `./skills/*/SKILL.md` 并按 frontmatter 的 `description` 触发；**其它 AI 编程工具**手动 `@` 派发对应 `SKILL.md` 或贴进对话作为角色 prompt 使用。

> 注意：议会式"多位专家并行发言"在原生 sub-agent 派发的 AI 编程工具（如 Claude Code）下才能完整运行；Codex 等"加载到当前上下文"的 AI 编程工具里，议会会退化为**顺序加载 + 顺序回答**——结构有效，但失去并行隔离。

### 名册（Roster）

{{ROSTER_TABLE}}

### 议事规则 —— 五步会议流

主 agent 同时扮演**议事主席**与**决议人**两个角色——按设计禁止额外生成流程类专家。每次会议（哪怕只是单轮回答）都按以下五步：

**Step 1 · 立项** —— 派发任何专家之前，主 agent 内部回答**议题立项 4 问**：

1. 这个议题要解决什么决策？（不是"讨论"，是"决定什么"）
2. 哪些产出 / 文件 / 流程会受这个决议影响？
3. 最少必须召集哪几位专家？（命中谁的 `decides:` 或 `responsibilities:`）
4. 期望的决议形态？（单一结论 / 多方案并列保留 / 委托执行）

**如果第 3 问得出 0 或 1 位专家，这不是议会议题——主 agent 直接回答，不要召集。**

**Step 2 · 挑选** —— 仅派发议题真正命中的专家。跳过 `must_not` 排除的领域。**派发 ≥3 位专家且存在怀疑席时，怀疑席必到**。绝不"全员到场"。

| 常见议题 | 默认必到 |
|---|---|
| 单一专家独占决策权 | 不召集，主 agent 直接转交 |
| 跨两位专家的接口 / 边界 | 这两位 + 怀疑席（如有） |
| 跨三位以上专家的架构 / 范围 / 取舍 | 命中的专家全到 + 怀疑席 |
| 触及 `brief/goal.md` 范围变更 | 暂停召集，先按"红线"流程升级 |

**Step 3 · 引导** —— 选中的专家用**完全相同的问题原文**并行派发；每位回复在 `### <expert-name>` 标题下独立成段，互不见对方答复。**怀疑席最后发言**，可基于具体失效模式覆盖多数意见。

**Step 4 · 综合** —— 用**冲突三分类**拆解每条分歧并对症仲裁：

| 冲突类型 | 仲裁路径 |
|---|---|
| **事实分歧**（事实 / 数据 / 引用对错） | 证据核查；无证据则标注"需补证据"并暂存 |
| **价值分歧**（优先级 / 取舍 / 立场） | 主 agent 作为决议人裁断；**两方立场都记录在案**，不抹去败方 |
| **解释分歧**（同一事实的多种合理读法） | 并列保留为多方案，交回用户裁决 |

**Step 5 · 输出** —— 紧凑决议（≤ 400 字），三个固定字段：

- **决议**：本次会议作出的决定
- **保留分歧**：哪些价值/解释分歧未消化、对应哪些立场
- **行动项**：谁做什么（指向具体专家或主 agent）；适用时落 TodoWrite

**默认不展示原始辩论**，除非用户说"展示原始辩论 / show debate"。

### 可选存档

默认 chat-only，不写盘。用户说"**存档本次会议**"时，主 agent 将完整记录（每位专家发言段 + 综合段 + 决议段）落到 `./meetings/YYYY-MM-DD-<topic>.md`，并自动创建 `meetings/` 目录。

### 红线升级（red-line escalation）

如果议题会修改 `brief/goal.md` 范围、删除已确认的约束、或推翻先前会议决议——这是**红线议题**。主 agent **必须停下**，向用户陈述"此问题将改变项目范围/先前决议"，**等用户明确同意才继续召集**。红线议题的纪要必须落盘，不可仅在 chat。

### 流程类角色边界（不要手动加）

本名册有意排除以下"流程类角色"——它们由工具自带 skill 套件（如有）拥有：code review、TDD、debug、planning、verification、并行派发、doc/slide/sheet/pdf 写作、SDK/caching 咨询、skill 写作、harness 配置。**这些是 skill，不是议席。** 如果你觉得缺哪一项，**直接在你的 AI 编程工具上调用对应 skill**，不要新加专家影子化它。如果你的 AI 编程工具**完全没有**这类 skill，重跑 `/expert-bootstrap` 并显式纳入缺失的角色。

### 建议的首次议会题

`{{FIRST_MEETING_PROMPT}}`

### 修改名册

三条合法路径——按需选用，不要绕开。

**A · 整体翻新** —— 重跑 `/expert-bootstrap`。会重写 `brief/goal.md` 与全部 `{{EXPERT_DIR}}<name>/SKILL.md`，丢失现有定制。**仅在名册大幅失配时**使用。

**B · 精调一位** —— 派发 `prompt-engineer` 并附上目标专家的现有 prompt + 你想要的变更，用输出整文件覆盖。**只改不增不减。**

**C · 加一位（add-one）** —— 当用户用任何语言要求"加 / 招 / 还缺一位 … 专家"时，主 agent **不开议会**，自己跑下面这条配方：

1. **意图核对** —— 用户那句话里是否说清了新专家"负责什么"？
   - 是 → 进入第 2 步。
   - 否 → 反问一句："他主要管什么？跟现有的 <最相邻的专家> 会怎么分工？" 拿到答案再继续。**不要让 meta-agent 凭空捏造职责。**
2. **现状快照** —— 读 `{{EXPERT_DIR}}*/SKILL.md` 全部 frontmatter，解析出 `existing_roster:` 列表（每条含 `name / title / decides / responsibilities / must_not`）。
3. **派发 `project-manager`（extend 模式）** —— 一次性传入：
   - `mode: extend`
   - `runtime_mode: portable`
   - `existing_roster:` （上一步快照）
   - `addition_request: <用户那句话 + 必要的反问澄清>`
   - `brief/goal.md` 内容作为项目背景。
   返回单条 `new_expert:` YAML + 可选 `sibling_adjustments_suggested:`。
4. **边界亮相** —— 把 `new_expert.must_not` 与 `sibling_adjustments_suggested` **直接展示给用户**，问一句："边界这样划分 OK 吗？(y / 改)"。这是这条路径上**唯一**的护栏。用户否决就回 3 重派；批准进入 5。
5. **派发 `prompt-engineer`（Mode C）** —— 传入：
   - `existing_roster:` （同第 2 步）
   - `extension_rationale: <project-manager 返回的 why_needed>`
   - `role_brief_for_prompt_engineer:` （来自 `new_expert`）
   - `runtime_mode: portable`
   返回带 frontmatter 的完整 agent 文件。
6. **落盘** —— `mkdir -p {{EXPERT_DIR}}<new-name>/`，写入 `{{EXPERT_DIR}}<new-name>/SKILL.md`（剥外层 fence）。**不要覆盖现有专家文件夹**——重名时 prompt-engineer 已经按契约返回 `NEED CLARIFICATION:`，应在第 5 步处理掉。
7. **更新名册表** —— 在本文件 `### 名册` 表末尾**追加一行** `| <name> | <title> | <why_needed> |`。如有 `sibling_adjustments_suggested` 且用户在第 4 步已批准，对应 sibling 的 `must_not` 不在本文件更新——重新派发 `prompt-engineer`（Mode B）针对该 sibling 走 B 路径，把 `must_not` 改进去并整文件覆盖。
8. **回报** —— `✅ <new-name> 已加入，现 <N+1> 位专家。议事流程的"≥3 位专家触发怀疑席"阈值已自动包含他。`

**任意一步返回 `NEED CLARIFICATION:`** → 把那一行原文转给用户，等回答后从同一步重派。最多两轮，第三轮失败则停下报错，**绝不脑补 fallback**。

**任意一步失败** → 立刻停下来告知用户失败在哪一步、为什么；**不要静默落盘半成品**。

**禁止**：跳过第 4 步（边界亮相）直接落盘；跳过第 2 步（现状快照）派发 project-manager；用 `prompt-engineer` Mode B（非增量）生成新专家（会绕过命名 / 边界 / must_not 三道检查）；手编 `{{EXPERT_DIR}}*/SKILL.md`。

## 项目产物

| 路径 | 用途 |
|---|---|
| `brief/goal.md` | 项目目标的规范副本——单一事实源 |
| `AGENTS.md`（本文件） | 议事规则 + 名册索引（Codex 自动加载） |
| `{{EXPERT_DIR}}<expert>/SKILL.md` | 专家组成员（Codex 自动扫描）|

<!-- expert-bootstrap:end -->
