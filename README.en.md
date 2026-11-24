# expert-bootstrap

> Generate a **project-tailored council of domain experts** plus a full set of meeting rules — convene them anytime cross-domain decisions need multiple perspectives, with conflict triage and a single ≤400-word resolution preserving every dissent.

📖 中文版：[README.md](./README.md)

## When to use this

Starting a new project but stuck on "which feature to build next"? Team split between "polish the content first or polish the tech first"? These cross-domain tradeoffs are hard to resolve alone — easy to get trapped in your own blind spots. This skill builds 3–4 project-tailored advisors plus a council ruleset right inside your project. When a cross-domain question comes up, multiple experts answer in parallel, conflicts get triaged, and you get a ≤400-word resolution with preserved disagreements.

## What it looks like

Here is the whole thing, from an empty directory to a council that's ready to meet. Lines starting with `>` are what you type; everything else is what comes back.

### ① Build it · you answer three questions

```
~/my-research $ claude

> set up the experts

  mode: claude
  What is this project? One sentence is enough — details can come later.

> A desk study on how AI coding assistants (Copilot / Cursor / Claude Code) get
  used across developers of different skill levels, and which repeatedly-voiced
  needs no product has met yet.

  Desk study — so sources are published literature, industry surveys, and
  official changelogs only, with no first-party interviews. Right? And how
  long is the time box?

> Right, desk only. 4 to 6 weeks.

  How do you slice "different skill levels" — years of experience, role, or
  fluency with AI tools?

> Two dimensions: AI fluency (first contact / daily use / deep integration) ×
  role (student / junior / senior / solo developer). 12 cells.

  Wrote it up as brief/goal.md — take a look:

    Question   usage patterns and unmet needs per cell of a 12-cell matrix
    Boundary   desk only, public sources, no first-party data collection
    Done when  ≥2 independent sources per cell + unmet-needs list + 3 gaps
    Time box   4–6 weeks

  Reply y to continue, or just tell me what to change.

> y

  Designing roster ..... 4 experts
  Writing prompts ...... 4/4

  ✅ Council ready:

     my-research/
     ├── brief/goal.md
     ├── .claude/agents/hci-se-evidence-curator.md
     ├── .claude/agents/industry-signal-analyst.md
     ├── .claude/agents/research-synthesis-lead.md
     ├── .claude/agents/research-comms-skeptic.md   ← skeptic seat
     └── CLAUDE.md   ← meeting rules live here

  Paste this back into the chat to open your first council meeting:

    The "solo developer × deep AI integration" cell: academic work almost never
    stratifies by solo developer, and large industry surveys fold these people
    into "other" at under 8%. Do we lower the evidence bar and fill the cell,
    leave it empty as a research gap, or merge the dimension?
```

Everything you did: answered three questions, nodded once. The 1–2 minutes in between run unattended.

### ② Use it · hold a meeting

Paste that last line back. From then on, plain questions are enough to convene.

```
> The "solo developer × deep AI integration" cell: academic work almost… (pasted)

  Question hits 3 experts → skeptic seat required. 4 speak in parallel.

  hci-se-evidence-curator
    Empirical work stratifying by solo developer is close to nonexistent. The
    nearest neighbor is OSS solo-maintainer research — usable as a work-pattern
    analogy, too weak to carry a usage-pattern claim.

  industry-signal-analyst
    Indie Hackers and MicroConf still give us signal, but both are self-selected
    samples. Upgrading evidence strength via "multiple sources agreeing" only
    holds if the two sources are genuinely independent.

  research-synthesis-lead
    I'd lower the bar, fill the cell, and footnote it. The matrix stays whole
    and the reader can still see the evidence is thin.

  research-comms-skeptic (skeptic seat, speaks last)
    Those two communities overlap heavily — they don't add up to two independent
    sources. Fill the cell and readers remember the text, never the footnote.
    The misreading risk outweighs the gain.

  ── RESOLUTION ───────────────────────────────────
  Leave the cell empty and nominate it as a research-gap candidate (no fill, no
  merge). Every empty cell carries the footnote "evidence below this report's
  bar; whether a difference exists is unknown", and the reader's guide states
  plainly that empty ≠ no difference.

  PRESERVED DISAGREEMENT
  · Pending evidence: no demographic data on how far the two communities
    overlap. Revisit once someone digs it up.
  · Kept on record: synthesis-lead's "fill + extrapolation label" option goes
    into the methodology appendix, marked "considered, dropped over misreading
    risk".

  ACTION ITEMS
  · [synthesis-lead] redefine "independent source" as "non-overlapping audience"
  · [industry-signal-analyst] find overlap evidence before the midpoint
  ─────────────────────────────────────────────────
```

Your own roster will differ from this one — who gets hired is decided on the spot by `project-manager` after it reads your goal. What stays fixed is the shape: a goal file under 300 words, one file per expert, and every resolution in three parts — resolution, preserved disagreement, action items.

## Fits / does NOT fit

✅ **Fits**
- Starting a new project on Claude Code / Codex CLI / OpenCode, wanting a **project-local, advisory** group of domain experts
- Projects spanning 2+ disjoint domains (hardware + compliance + frontend), where multi-position arbitration matters
- Expert responsibilities that shift with project type — "frontend" in a SaaS dashboard worries about state and permissions; the same label in a marketing landing page worries about first-paint and SEO

❌ **Does NOT fit**
- Questions a single expert can answer (just ask the main conversation — faster)
- Tasks where agents must actually write code, run tests, or modify files (use a parallel-execution skill instead)
- Triggering with vague phrases like "start a new project" / "let's spin up a team" / "启动项目" — these **won't trigger**, see § Trigger below
- Domains already covered by mature skill suites. `project-manager` will yield to:
  - **Methodology**: TDD, systematic-debugging, code-review, writing/executing plans, parallel-agent dispatch
  - **Platform & tooling**: skill authoring, settings.json & hooks, Claude API integration
  - **Document formats**: Word / Excel / PDF / PowerPoint

  So the generated roster is overwhelmingly project-domain-specific. If you genuinely want a project-local expert for a yielded domain, run the bootstrap, then use the "add one" path explicitly.

## Runtime support

All three runtimes are verified in real runs — trigger, roster generation, and writing into the project were each exercised end to end on the runtime itself.

### ✅ Claude Code

- **Expert path**: `./.claude/agents/<name>.md` (flat: one file per expert)
- **Project memory**: `./CLAUDE.md`
- **Dispatch**: Lead agent uses `Agent(subagent_type=...)` to dispatch independent LLM instances in parallel

### ✅ Codex CLI

- **Expert path**: `./.agents/skills/<name>/SKILL.md` (nested: one folder per expert)
- **Project memory**: `./AGENTS.md`
- **Dispatch**: Codex auto-scans `./.agents/skills/` at the project root by frontmatter `description` and dispatches sub-agents in parallel

### ✅ OpenCode

- **Expert path**: `./.opencode/skills/<name>/SKILL.md` (nested: one folder per expert)
- **Project memory**: `./AGENTS.md`
- **Dispatch**: OpenCode auto-scans `./.opencode/skills/` by frontmatter `description` and dispatches sub-agents in parallel

---

The skill auto-detects the AI coding tool at Step −1 from contextual signals (system prompt or environment cues) — no user configuration. If detection is wrong, reply `switch to claude` / `switch to codex` / `switch to opencode` (or the Chinese equivalents) to override.

## Install

### Cross-tool · Let the AI read the README and install (recommended)

Copy the entire block below and paste it into Claude Code / Codex CLI / OpenCode:

> Please install this skill: `https://github.com/SEAMAN9000/expert-bootstrap`
>
> First identify whether you're running on Claude Code, Codex CLI, or OpenCode, then read the matching "Install" section in the README and execute the manual method. After installation, tell me the trigger keywords.

The AI will read the README, run the `git clone` + `cp` commands, and tell you when it's ready. You don't need to remember any commands.

---

### Claude Code users

**A · Slash command (one-liner)**

```bash
# In Claude Code:
/plugin marketplace add SEAMAN9000/expert-bootstrap
/plugin install expert-bootstrap@SEAMAN9000
```

**B · Manual**

```bash
git clone https://github.com/SEAMAN9000/expert-bootstrap.git
cp -r expert-bootstrap/skills/expert-bootstrap   ~/.claude/skills/
cp    expert-bootstrap/agents/*.md               ~/.claude/agents/
cp    expert-bootstrap/commands/expert-bootstrap.md ~/.claude/commands/
```

---

### Codex CLI users

Codex has no sub-agent concept — `prompt-engineer` and `project-manager` are also treated as ordinary skills in Codex. So you need to install **three** skills: the main one plus two meta-agents.

**A · Codex skill installer (recommended)**

If you've installed Codex's official [skill-installer](https://github.com/ComposioHQ/awesome-codex-skills):

```bash
# Main skill
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

**B · Manual**

```bash
git clone https://github.com/SEAMAN9000/expert-bootstrap.git
mkdir -p ~/.agents/skills/expert-bootstrap \
         ~/.agents/skills/prompt-engineer \
         ~/.agents/skills/project-manager

# Main skill (with its templates/ directory)
cp -r expert-bootstrap/skills/expert-bootstrap/* ~/.agents/skills/expert-bootstrap/

# Two meta-agents — note they must be renamed to SKILL.md
cp expert-bootstrap/agents/prompt-engineer.md  ~/.agents/skills/prompt-engineer/SKILL.md
cp expert-bootstrap/agents/project-manager.md  ~/.agents/skills/project-manager/SKILL.md
```

> Note: the user-level skill location listed in the official Codex docs is `~/.agents/skills/`. The `~/.codex/skills/.system/…` path in the commands above is only where Codex keeps its bundled installer script, not the install target.

**Verify**: in any Codex project, say "set up the experts" — the main skill should fire and write artifacts to `./.agents/skills/<name>/SKILL.md` + `./AGENTS.md`.

---

### OpenCode users

OpenCode also treats `prompt-engineer` and `project-manager` as ordinary skills. Install all three:

```bash
git clone https://github.com/SEAMAN9000/expert-bootstrap.git
mkdir -p ~/.config/opencode/skills/expert-bootstrap \
         ~/.config/opencode/skills/prompt-engineer \
         ~/.config/opencode/skills/project-manager

# Main skill (with its templates/ directory)
cp -r expert-bootstrap/skills/expert-bootstrap/* ~/.config/opencode/skills/expert-bootstrap/

# Two meta-agents — renamed to SKILL.md
cp expert-bootstrap/agents/prompt-engineer.md  ~/.config/opencode/skills/prompt-engineer/SKILL.md
cp expert-bootstrap/agents/project-manager.md  ~/.config/opencode/skills/project-manager/SKILL.md
```

**Verify**: in any OpenCode project, say "set up the experts" — the main skill should fire and write artifacts to `./.opencode/skills/<name>/SKILL.md` + `./AGENTS.md`.

OpenCode also scans `~/.claude/skills/` for compatibility, so if you've already installed under Claude Code, that copy works under OpenCode too.

## Trigger

Once installed, in your project directory, type any one of these **exact** phrases:

| English | 中文 |
|---|---|
| `/expert-bootstrap` | `/expert-bootstrap` |
| set up the experts | 组建专家组 |
| build the expert council | 搭建专家组 |
| initialize the expert council | 初始化专家组 |
| convene the expert council | 召集专家组 |
| form the expert committee | 成立专家委员会 |

⚠️ Paraphrases ("start a new project" / "let's spin up a team" / "启动项目") **will not trigger** — they fall through to a brainstorming-class skill or the host's default chat reply. To force-route here, prefix with `/expert-bootstrap`.

## What happens next

The full pipeline takes ~1–2 minutes.

1. **Runtime detection** — the skill silently identifies whether you're on Claude Code / Codex CLI / OpenCode. The result decides where the generated expert files land and which manifest file to use. You'll see one line like `mode: claude` in the terminal.
2. **Asks what the project is actually about** — goal + who uses it + what "done" means. If `brief/goal.md` or a README already exists, it's read first and the questions get more specific.
3. **Distills your answers into `brief/goal.md`, shown for review** — this becomes the shared context for every expert. **This is the only step that requires your approval.**
4. **`project-manager` enters and chooses the roster** — default 3–4 seats, up to 7 for cross-domain projects, each with a one-line "why this project needs them". When genuinely uncertain it replies `NEED CLARIFICATION: ...` (max two rounds; on the third failure it halts and reports — no fabrication).
5. **`prompt-engineer` writes each expert's system prompt and persists them** — then updates or creates the manifest file (`CLAUDE.md` on Claude Code, `AGENTS.md` on Codex / OpenCode) with the meeting rules: when to summon the skeptic seat, resolution length cap, conflict triage.

## What ends up in your project after a run

**Claude Code users**:

```
your-project/
├── brief/goal.md
├── .claude/agents/<expert-1>.md
├── .claude/agents/<expert-2>.md
├── ...
└── CLAUDE.md          ← council rules appended at the end
```

**Codex CLI users**:

```
your-project/
├── brief/goal.md
├── .agents/skills/<expert-1>/SKILL.md
├── .agents/skills/<expert-2>/SKILL.md
├── ...
└── AGENTS.md          ← council rules appended at the end
```

**OpenCode users**:

```
your-project/
├── brief/goal.md
├── .opencode/skills/<expert-1>/SKILL.md
├── .opencode/skills/<expert-2>/SKILL.md
├── ...
└── AGENTS.md          ← council rules appended at the end
```

Everything lands inside the project directory. Your home global agents folder is **never touched** — leave the project and these experts cease to exist.

If `brief/goal.md` / `CLAUDE.md` / `AGENTS.md` already exists with customizations, **back them up before running**. When a manifest file already exists, the skill only replaces content between the `<!-- expert-bootstrap:begin --> ... <!-- expert-bootstrap:end -->` sentinels — but a backup is always safer.

## Using the council after bootstrap

When bootstrap finishes, the terminal prints a **first-meeting prompt** — a concrete cross-domain question tailored to your project goal that hits 2–3 experts. Copy that line back to the conversation, and the lead agent runs the **five-step meeting flow** from `CLAUDE.md`: charter → select → solicit (experts answer in parallel, in isolation) → synthesize (factual / value / interpretive triage) → resolve in ≤400 words.

From then on, just ask the lead agent any cross-domain question in plain language:

- **Topic hits ≥2 experts** → council auto-convened
- **Hits ≥3** → the skeptic seat is mandatory
- **Single-expert questions** → no meeting; the lead agent handles it directly

## Modify an expert / add one

Three legitimate paths — **don't hand-edit `.claude/agents/*.md`**:

| Path | How | Effect |
|---|---|---|
| **A · Full rebuild** | Run `/expert-bootstrap` again | Overwrites every expert file and `goal.md`; replaces the council-rules region in `CLAUDE.md`, preserves the rest |
| **B · Tune one** | Tell the main conversation "modify the XX expert's responsibilities, add YY"; the main agent dispatches `prompt-engineer` to rewrite that one | Full file overwrite for that one expert — no add, no remove |
| **C · Add one** | Tell the main conversation "add an XX expert" (or 加一位) | Runs the add-one recipe: snapshot roster → `project-manager` extend mode → boundary preview for your approval → write to disk → append roster row |

Detailed field semantics are in the `CLAUDE.md › 修改名册` section generated for your project.

**Failure semantics**: if any step fails, the pipeline **halts and reports which step**. Partial councils are never silently shipped. There is no resume — re-running starts from the beginning.

## Design choices

**Why generate on the spot instead of shipping a generic expert library.**
The label "frontend expert" demands very different responsibilities in a SaaS dashboard project versus a marketing landing page — the former cares about state management and permission boundaries, the latter about first-paint and SEO. A generic template is either too vague (everything is in scope, so nothing is) or too crowded (you delete half of it every time). So `project-manager` decides who to summon after reading your goal, and `prompt-engineer` decides what each one actually owns.

**Why all project experts live in `./.claude/agents/` and nothing global.**
Switch projects, and your previous project's "payment risk expert" and "GDPR compliance expert" vanish along with the context — they won't pollute the discussion about your weekend game project. The cost is re-running bootstrap per project; the benefit is that everyone you convene is actually relevant. Only two meta-agents (`prompt-engineer` and `project-manager`) live globally — they're the factory, not the product.

**Why default 3–4 seats, max 7.**
More experts means lower average signal per voice; past 8–9 it's the same opinion paraphrased by three different speakers. `project-manager`'s prompt is repeatedly instructed to resist the temptation to "add one more". Only projects truly spanning disjoint domains (hardware + compliance + frontend + ops) are allowed past 5.

**Why these experts only deliberate, never write code.**
They have no permission to write code, run tests, or modify files — only to answer questions, take positions, and participate in council resolutions (each ≤400 words, with preserved disagreements and action items). If you need parallel agents to actually modify code, that belongs to a parallel-execution skill — two different pipelines with two different failure modes that shouldn't tangle.

**Why no approval at every step.**
You confirm the goal once and the rest runs to completion. Multi-step approval sounds democratic, but in practice it just bounces decision cost back to you over and over — by the fifth "yes" click you've stopped reading. So there are only two pause points: goal confirmation, and the rare `project-manager` clarification.

## License

MIT — see [LICENSE](./LICENSE).
