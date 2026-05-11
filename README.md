# expert-bootstrap

> Bootstrap a project-local council of generated domain experts — cross-platform, one-shot autonomous after goal confirmation.

`expert-bootstrap` is an agentic skill that turns "I want to start a project" into a ready-to-use expert team. It does NOT ship pre-baked experts — instead, two meta-agents (`prompt-engineer` and `project-manager`) **generate a roster tailored to your project** and write them as plain markdown files with valid agent frontmatter, so any agent host can read them.

## What you get after running it

Two output layouts, chosen automatically by runtime detection:

**Claude Code mode** — native subagent dispatching
```
your-project/
├── brief/goal.md                   ← canonical project goal
├── .claude/agents/
│   ├── react-expert.md
│   ├── api-architect.md
│   └── ...
└── CLAUDE.md                       ← council convening rules + roster index
```

**Portable mode** — Codex CLI / Gemini CLI / OpenCode / unknown host
```
your-project/
├── brief/goal.md
├── agents/
│   ├── react-expert.md
│   ├── api-architect.md
│   └── ...
└── AGENTS.md                       ← cross-platform manifest, same content as CLAUDE.md
```

Each expert file uses standard `---\nname: …\ndescription: …\n---` frontmatter — readable as a subagent definition on every host examined.

## Install

### Via Claude Code plugin marketplace (recommended for Claude Code users)

```bash
# In Claude Code:
/plugin marketplace add SEAMAN9000/expert-bootstrap
/plugin install expert-bootstrap@SEAMAN9000
```

### Manual install (any host)

```bash
git clone https://github.com/SEAMAN9000/expert-bootstrap.git

# Claude Code:
cp -r expert-bootstrap/skills/expert-bootstrap ~/.claude/skills/
cp expert-bootstrap/agents/*.md                ~/.claude/agents/
cp expert-bootstrap/commands/expert-bootstrap.md ~/.claude/commands/

# Codex CLI / Gemini CLI / OpenCode: copy the same files to the
# host's equivalent skills / agents / commands directories.
```

## Use

In any project directory, type one of the **canonical trigger phrases** (exact match):

- `/expert-bootstrap`
- "convene the expert council"
- "set up the experts"
- 「组建专家组」「搭建专家组」「初始化专家组」「召集专家组」「成立专家委员会」

Anything else — including 「启动项目」「新项目」"start a new project" — falls through to `superpowers:brainstorming` if installed, or your host's default brainstorm flow. This is intentional: not every project needs a council.

## How it works

1. **Runtime detection** — silent, before any user prompt. Decides Claude-mode vs portable-mode and surfaces one short line for confirmation.
2. **Goal discovery** — the only interactive step. Three states: A) you state a clear goal, B) you point at fragments/notes, C) you have nothing → outcome-first questions, max 3, one at a time.
3. **One-shot autonomous flow** — after goal confirmation, the skill runs goal-refinement, roster design, parallel expert-prompt refinement, and disk writes without further prompts.
4. **Readiness announcement** — final message includes a seeded first-meeting prompt derived from your goal, paste-ready.

## Design principles

- **Cross-platform first** — file format and content are portable; only paths differ between modes. Same generation pipeline serves every host.
- **Zero global pollution** — domain experts live in project-local directories, not in your global agents config. Leave the project, they're invisible.
- **Two meta-agents, generated specialists** — only `prompt-engineer` and `project-manager` are persistent (in `~/.<host>/agents/`). Domain experts are project-bound and regenerated when you re-run.
- **Smallest viable council** — `project-manager` defaults to 3–4 experts; 5–7 only when the project genuinely spans disjoint domains. Skeptic seat reserved at council ≥ 4.
- **One-shot UX** — confirm the goal once, then sit back. No multi-prompt approval gates.
- **No hand-edits to generated files** — drift discipline documented in the project manifest. Re-run the relevant meta-agent for changes.
- **Detect-then-defer for host skills** — generated experts avoid roles already owned by superpowers / anthropic-skills / claude-api / update-config if those skills are present; in portable mode, those rows deactivate.

## Compatibility

| Runtime | Status | Notes |
|---|---|---|
| Claude Code | supported | Uses native `Agent(subagent_type=…)` dispatch and `./.claude/agents/` discovery. |
| Codex CLI | portable (file generation by design, dispatch host-dependent) | Reads `AGENTS.md` and `./agents/<name>.md` natively. |
| Gemini CLI | portable (file generation by design, dispatch host-dependent) | Loads agents via host conventions; consult Gemini CLI docs for invocation syntax. |
| OpenCode | portable (file generation by design, dispatch host-dependent) | Same as above. |

In portable mode the skill writes paste-ready markdown files; the **invocation syntax** for dispatching those experts depends on your host. The files themselves are portable.

## Repository layout

```
.claude-plugin/
└── plugin.json                       Plugin manifest (with runtime compatibility metadata)
agents/
├── prompt-engineer.md                Meta-agent: optimizes any prompt
└── project-manager.md                Meta-agent: designs expert rosters
skills/expert-bootstrap/
├── SKILL.md                          Runtime detection + 5-step pipeline
└── templates/
    ├── CLAUDE.md.tpl                 Claude-mode manifest template
    └── AGENTS.md.tpl                 Portable-mode manifest template
commands/
└── expert-bootstrap.md               /expert-bootstrap slash command
```

## License

MIT — see [LICENSE](./LICENSE).
