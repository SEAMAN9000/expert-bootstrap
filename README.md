# expert-bootstrap

> 为你的项目当场生成一组**专属领域顾问**，配套一套议事规则——遇到跨领域取舍时随时召开会议、各方发言、给一份带保留分歧的决议。

📖 English: [README.en.md](./README.en.md)

## 什么时候用

想做个新项目，卡在「下一步该做哪个功能」？团队对「先打磨内容还是先打磨技术」各执一词？这类跨领域取舍，一个人想很容易陷在自己的盲区里。这个 skill 当场为你的项目搭 3-4 位项目专属顾问 + 一套议事规则——遇到跨领域问题，几位专家并行回答、冲突仲裁、≤ 400 字给你一份带保留分歧的决议。

## 用起来长什么样

下面是一个空目录里从零到专家组就绪的完整过程。`>` 开头的是你打的字，其余是屏幕上的回显。

### ① 搭起来 · 你只答三句话

```
~/my-research $ claude

> 组建专家组

  mode: claude
  新项目要做什么？说一句话就行，细节稍后补。

> 做一份桌面调研：AI 编程助手（Copilot / Cursor / Claude Code）在不同水平的
  开发者里怎么被使用，找出反复被提到、但还没被产品满足的需求。

  纯桌面调研 —— 来源只用公开文献、行业调研、官方更新日志，不做一手访谈，
  这样理解对吗？打算做多久？

> 对，纯桌面。4 到 6 周。

  「不同水平」按什么切片？经验年限、角色、还是对 AI 工具的熟练度？

> 双维度：AI 熟练度（首次接触 / 日常使用 / 重度集成）× 角色（学生 / 初级 /
  资深 / 独立开发者）。一共 12 格。

  整理成 brief/goal.md 了，看一眼 ——

    研究问题  12 格受众矩阵里各自的使用模式与未满足需求
    方法边界  纯桌面，只用公开来源，不做一手数据采集
    做完了    每格 ≥2 处独立来源 + 未满足需求清单 + 3 处研究空白
    时间盒    4–6 周

  OK 就回 y，要改直接说。

> y

  设计名册 ........ 4 位专家
  写专家 prompt ... 4/4

  ✅ 专家组已就绪：

     my-research/
     ├── brief/goal.md
     ├── .claude/agents/hci-se-evidence-curator.md
     ├── .claude/agents/industry-signal-analyst.md
     ├── .claude/agents/research-synthesis-lead.md
     ├── .claude/agents/research-comms-skeptic.md   ← 怀疑席
     └── CLAUDE.md   ← 议事规则写在这里

  复制下面这句发回对话，开你的第一次议会：

    「独立开发者 × 重度集成 AI 工具」这一格，学术文献几乎没有以独立开发者
    为分层的研究，大型行业调研里这类人常被并进「其他」且占比 < 8%。这格该
    放宽证据下限填进去、留空作为研究空白、还是并入相邻维度？
```

到这里你做过的事：答三句话，点一次头。中间那 1–2 分钟不用管它。

### ② 用起来 · 开一次会

把最后那句话发回去就行。之后任何时候想开会，用人话提问即可。

```
> 「独立开发者 × 重度集成 AI 工具」这一格，学术文献几乎没有…（粘贴上面那句）

  议题命中 3 位专家 → 怀疑席必到，共 4 位并行发言。

  hci-se-evidence-curator
    以独立开发者为分层变量的实证研究近乎为零。最接近的是 OSS 单人维护者
    研究，只能当工作特征类比，撑不起使用模式的结论。

  industry-signal-analyst
    Indie Hackers、MicroConf 这类社区还能捞到信号，但都是自选样本；要靠
    「多源同向」升级证据强度，前提是两个来源真的互相独立。

  research-synthesis-lead
    倾向放宽下限 + 脚注标注填进去，保住矩阵完整，读者也看得到证据弱。

  research-comms-skeptic（怀疑席，最后发言）
    那两个社区受众高度重叠，凑不出两个独立来源。填进去读者只会看见格子里
    有字，记不住脚注 —— 收益小于误读风险。

  ── 决议 ─────────────────────────────────────────
  这一格留空，并提名为研究空白候选（不填，也不并维度）。空白格统一挂脚注
  「证据不足以达到本报告下限，差异是否存在未知」，导读章明示「空白 ≠ 无差异」。

  保留分歧
  · 待补证据：两个社区的受众重叠度缺人口数据，补到之后可重审。
  · 并列保留：synthesis-lead 的「填入 + 外推标注」方案记进方法学附录，
    标注为「已考虑，因误读风险弃用」。

  行动项
  · [synthesis-lead] 把「独立来源」的判定改写为「受众池不重叠」
  · [industry-signal-analyst] 中期前补两个社区的受众重叠度证据
  ─────────────────────────────────────────────────
```

你自己跑出来的专家名单会跟这里不同 —— 招谁由 `project-manager` 读完你的目标后现场决定。稳定的是结构：目标文件 < 300 字，每位专家一个文件，决议永远是「决议 / 保留分歧 / 行动项」三段。

## 适合 / 不适合

✅ **适合**
- 在 Claude Code / Codex CLI / OpenCode 上开新项目，想要一组**项目本地、议事用**的领域顾问
- 项目跨 2+ 互不相邻领域（例如硬件 + 合规 + 前端），需要多方立场仲裁
- 专家职责会因项目类型变化——"前端"在 SaaS 仪表盘和营销落地页里要操心的事完全不同

❌ **不适合**
- 单一专家就能回答的问题（直接问主对话更快）
- 需要 agent 真的去改代码、跑测试、改文件（属于并行执行类 skill 的工作范围）
- 用泛义短语调起："启动项目 / 新项目 / start a new project / let's spin up a team" 这类**不会触发**——见下方 § 触发
- 想要的领域已被 skill 套件覆盖。`project-manager` 会主动让位的常见领域：
  - **方法论类**：TDD、systematic-debugging、code-review、写计划/执行计划、并行 agent 调度
  - **平台与工具**：写或优化 skill 本身、settings.json 与 hooks、Claude API 集成
  - **文档格式**：Word / Excel / PDF / PPT 的读写

  所以专家组名册里大概率全是属于你项目领域的专家。某个被让位的领域确实需要项目本地专家，跑完后用"加一位"路径单独追加即可。

## Runtime 支持

三个平台均已实测跑通——触发、名册生成、写入项目这条完整链路，在各自的真实环境里都跑过。

### ✅ Claude Code

- **专家路径**：`./.claude/agents/<name>.md`（扁平：单文件）
- **项目记忆**：`./CLAUDE.md`
- **调度**：主 agent 用 `Agent(subagent_type=...)` 并行派发独立 LLM 实例

### ✅ Codex CLI

- **专家路径**：`./.agents/skills/<name>/SKILL.md`（嵌套：每位专家一个文件夹）
- **项目记忆**：`./AGENTS.md`
- **调度**：Codex 自动扫描项目根 `./.agents/skills/`，按 frontmatter `description` 触发并行 subagent

### ✅ OpenCode

- **专家路径**：`./.opencode/skills/<name>/SKILL.md`（嵌套：每位专家一个文件夹）
- **项目记忆**：`./AGENTS.md`
- **调度**：OpenCode 自动扫描 `./.opencode/skills/`，按 frontmatter `description` 触发并行 subagent

---

skill 在 Step −1 自动判断 AI 编程工具类型——基于上下文里能看到的工具声明（系统提示词或环境特征），不需要用户配置。检测错了，回一句 "切换 claude" / "切换 codex" / "切换 opencode" 覆盖。

## 安装

### 跨工具通用 · 让 AI 自己读 README 装（推荐）

把下面这段话**整段**复制粘贴给 Claude Code / Codex CLI / OpenCode 的对话框：

> 帮我安装这个 skill：`https://github.com/SEAMAN9000/expert-bootstrap`
>
> 你先识别自己跑在 Claude Code、Codex CLI 还是 OpenCode 上，然后读它 README 里对应的"安装"段落，按手工方式执行。装完后告诉我触发关键词。

AI 会自己读 README、跑 `git clone` 和 `cp` 命令落盘，装完告诉你能用了。你不用记任何命令。

---

### Claude Code 用户

**A · slash command（一行）**

```bash
# 在 Claude Code 中：
/plugin marketplace add SEAMAN9000/expert-bootstrap
/plugin install expert-bootstrap@SEAMAN9000
```

**B · 手工**

```bash
git clone https://github.com/SEAMAN9000/expert-bootstrap.git
cp -r expert-bootstrap/skills/expert-bootstrap   ~/.claude/skills/
cp    expert-bootstrap/agents/*.md               ~/.claude/agents/
cp    expert-bootstrap/commands/expert-bootstrap.md ~/.claude/commands/
```

---

### Codex CLI 用户

Codex 没有 sub-agent 概念——`prompt-engineer` 和 `project-manager` 在 Codex 里也按普通 skill 处理。所以**要装三个 skill**：主 skill + 两位 meta-agent。

**A · Codex skill installer（推荐）**

如果你装了 Codex 官方的 [skill-installer](https://github.com/ComposioHQ/awesome-codex-skills)：

```bash
# 主 skill
python3 ~/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py \
  --repo SEAMAN9000/expert-bootstrap --path skills/expert-bootstrap --name expert-bootstrap \
  --dest ~/.agents/skills

# Meta-agent: prompt-engineer
python3 ~/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py \
  --repo SEAMAN9000/expert-bootstrap --path agents/prompt-engineer.md --name prompt-engineer \
  --dest ~/.agents/skills

# Meta-agent: project-manager
python3 ~/.codex/skills/.system/skill-installer/scripts/install-skill-from-github.py \
  --repo SEAMAN9000/expert-bootstrap --path agents/project-manager.md --name project-manager \
  --dest ~/.agents/skills
```

**B · 手工**

```bash
git clone https://github.com/SEAMAN9000/expert-bootstrap.git
mkdir -p ~/.agents/skills/expert-bootstrap \
         ~/.agents/skills/prompt-engineer \
         ~/.agents/skills/project-manager

# 主 skill（带 templates 目录）
cp -r expert-bootstrap/skills/expert-bootstrap/* ~/.agents/skills/expert-bootstrap/

# 两位 meta-agent —— 注意要重命名为 SKILL.md
cp expert-bootstrap/agents/prompt-engineer.md  ~/.agents/skills/prompt-engineer/SKILL.md
cp expert-bootstrap/agents/project-manager.md  ~/.agents/skills/project-manager/SKILL.md
```

> 说明：Codex 官方文档列出的个人级技能位置是 `~/.agents/skills/`。上面命令里的 `~/.codex/skills/.system/…` 只是 Codex 自带安装脚本所在的位置，不是安装目标。

**装完验证**：在任意 Codex 项目里说 "组建专家组"——主 skill 会触发，按 Codex 路径写入 `./.agents/skills/<name>/SKILL.md` + `./AGENTS.md`。

---

### OpenCode 用户

OpenCode 同样把 `prompt-engineer` 和 `project-manager` 当作 skill 处理。装三个 skill：

```bash
git clone https://github.com/SEAMAN9000/expert-bootstrap.git
mkdir -p ~/.config/opencode/skills/expert-bootstrap \
         ~/.config/opencode/skills/prompt-engineer \
         ~/.config/opencode/skills/project-manager

# 主 skill（带 templates 目录）
cp -r expert-bootstrap/skills/expert-bootstrap/* ~/.config/opencode/skills/expert-bootstrap/

# 两位 meta-agent —— 重命名为 SKILL.md
cp expert-bootstrap/agents/prompt-engineer.md  ~/.config/opencode/skills/prompt-engineer/SKILL.md
cp expert-bootstrap/agents/project-manager.md  ~/.config/opencode/skills/project-manager/SKILL.md
```

**装完验证**：在任意 OpenCode 项目里说 "组建专家组"——主 skill 会触发，按 OpenCode 路径写入 `./.opencode/skills/<name>/SKILL.md` + `./AGENTS.md`。

OpenCode 也会扫描 `~/.claude/skills/` 兼容路径，如果你已经在 Claude Code 装过一次，那份也能在 OpenCode 里用。

## 触发

装好后进你的项目目录，敲下面任一条**精确匹配**的短语：

| 中文 | 英文 |
|---|---|
| `/expert-bootstrap` | `/expert-bootstrap` |
| 组建专家组 | set up the experts |
| 搭建专家组 | build the expert council |
| 初始化专家组 | initialize the expert council |
| 召集专家组 | convene the expert council |
| 成立专家委员会 | form the expert committee |

⚠️ 近义短语（"启动项目""新项目""let's spin up a team"）**不会触发**——会被路由到 brainstorming 类 skill 或默认聊天回复。想强制路由本工具，直接打 `/expert-bootstrap`。

## 接下来会发生什么

跑完整条管道约一到两分钟。

1. **识别 runtime** — skill 在背景里判定当前跑在 Claude Code / Codex CLI / OpenCode 中的哪个。识别结果决定写出来的专家文件放在哪、用哪份 manifest。终端会看到 `mode: claude` 之类一行。
2. **问你这个项目想做什么** — 项目目标 + 谁用 + "做完了" 的定义。已有 `brief/goal.md` 或 README 会先读，问的问题更聚焦。
3. **整理成 `brief/goal.md`，给你看一眼** — 后续所有专家共享的项目共识。**这是整条流程里你唯一需要点头确认的环节。**
4. **`project-manager` 出场，决定该招哪些专家** — 默认 3-4 人，跨多领域时最多 7 人，每人附一句"为什么这个项目需要他"。它拿不准时会回 `NEED CLARIFICATION: ...` 问你（最多两轮，第三轮失败就停下报错，绝不瞎编）。
5. **`prompt-engineer` 给每位专家写专属 prompt，落盘** — 同时更新或创建 manifest 文件（Claude Code 下是 `CLAUDE.md`，Codex / OpenCode 下是 `AGENTS.md`），把"以后怎么开会"的规则写进去——什么时候召怀疑席、决议长度上限、冲突怎么分类。

## 跑完后项目里多了什么

**Claude Code 用户**：

```
your-project/
├── brief/goal.md
├── .claude/agents/<expert-1>.md
├── .claude/agents/<expert-2>.md
├── ...
└── CLAUDE.md          ← 议事规则追加在末尾
```

**Codex CLI 用户**：

```
your-project/
├── brief/goal.md
├── .agents/skills/<expert-1>/SKILL.md
├── .agents/skills/<expert-2>/SKILL.md
├── ...
└── AGENTS.md          ← 议事规则追加在末尾
```

**OpenCode 用户**：

```
your-project/
├── brief/goal.md
├── .opencode/skills/<expert-1>/SKILL.md
├── .opencode/skills/<expert-2>/SKILL.md
├── ...
└── AGENTS.md          ← 议事规则追加在末尾
```

所有专家文件都落在项目目录内。home 全局 agents 文件夹**一个字节都不会动到**——离开这个项目，这些专家就不存在。

如果项目里已有 `brief/goal.md` / `CLAUDE.md` / `AGENTS.md` 并做过定制，**先备份再跑**。本工具会在 manifest 文件已存在时只替换 `<!-- expert-bootstrap:begin --> ... <!-- expert-bootstrap:end -->` 哨兵之间的内容，但备份永远是更稳的选择。

## 跑完后怎么用专家组

bootstrap 跑完时，终端会打印**一句首次议会题**——一个能命中 2-3 位专家的具体跨领域问题，按你的项目目标量身生成。把这一行复制发回对话，主 agent 自动按 `CLAUDE.md` 里的**五步会议流**召集：立项 → 挑选 → 引导（专家并行答题）→ 综合（冲突三分类仲裁）→ ≤400 字决议。

之后任何时候想再开会，用人话向主 agent 提问即可：

- **议题命中 ≥2 位专家** → 自动召集
- **命中 ≥3 位** → 怀疑席必到
- **单一专家可独立回答** → 不开会，主 agent 直接转交

## 改专家 / 加一位

三条合法路径——**不要手编 `.claude/agents/*.md`**：

| 路径 | 怎么做 | 影响 |
|---|---|---|
| **A · 整组翻新** | 再跑一次 `/expert-bootstrap` | 覆盖所有专家文件和 `goal.md`；`CLAUDE.md` 内的议事规则区被替换，区外保留 |
| **B · 精调一位** | 直接对主对话说"修改 XX 专家的职责，加 YY 责任"，主 agent 会派 `prompt-engineer` 重写那一位 | 整文件覆盖该专家——只改不增不减 |
| **C · 加一位** | 对主对话说 "再加一位 XX 专家" | 走 add-one 配方：现状快照 → `project-manager` extend 模式 → 边界亮相让你批准 → 落盘 → 追加名册行 |

详细字段语义见跑完后生成的 `CLAUDE.md › 修改名册` 段。

**失败语义**：管道中途任何一步失败会**停下并报告是哪一步**，不会静默落地半成品。没有 resume——重做就是从头再来一遍。

## 设计取舍

**为什么不内置一个通用专家库，要每次现场生成。**
"前端专家"这个标签，放在做 SaaS 仪表盘的项目里，和放在做营销落地页的项目里，要操心的事完全不同——前者关心状态管理和权限边界，后者关心首屏性能和 SEO。一份通用模板要么写得太空（什么都管等于什么都不管），要么写得太满（每次都得手动删掉一半不相关的职责）。所以 `project-manager` 读完你的目标后才决定招谁，`prompt-engineer` 才决定每个人具体管什么。

**为什么所有项目专家都只住在 `./.claude/agents/`，不进全局目录。**
你换一个项目，上一个项目的"支付风控专家""GDPR 合规专家"就跟着上下文一起消失，不会污染这个新项目里关于"做个周末小游戏"的讨论。代价是每个新项目要重做一次 bootstrap，收益是每个项目里召集到的人都和这个项目有关。唯一全局常驻的只有两个 meta-agent（`prompt-engineer` 和 `project-manager`）——它们是用来生产专家的工具，本身不参与议事。

**为什么默认 3-4 人，最多 7 人。**
专家越多，平均每个人能贡献的独立信息越少；到了 8、9 个之后基本就是同一个观点被三个人换着说法重复。`project-manager` 的 prompt 里被反复要求顶住"再加一个"的诱惑，只有项目真的跨越互不相邻的领域（同时涉及硬件、合规、前端、运营）才允许超过 5 人。

**为什么这些专家只参与议事、不直接写代码。**
他们手里没有写代码、跑测试、改文件的权限——只回答问题、给立场、参与议会决议（每次 ≤400 字、含保留分歧、含行动项）。如果你需要并行派几个 agent 真的去改代码，那属于并行执行类 skill 的工作范围，和议事场景走两条不同的流水线。议事和执行各自的失败模式不会缠在一起。

**为什么不在每一步都让你确认。**
读完目标确认一次 `goal.md`，剩下的一路跑完。多轮审批听上去民主，实操下来是把决策成本反复抛回给用户——用户在第五次点 yes 的时候已经不看内容了。所以这里只在两个地方停：你确认目标那一次，以及 `project-manager` 实在拆不清向你问一次。

## License

MIT — 详见 [LICENSE](./LICENSE)。
