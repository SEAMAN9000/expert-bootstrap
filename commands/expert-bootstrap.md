---
description: 为当前项目搭建专家组——先检测 AI 编程工具，然后交互式抓取项目目标（仅此一步交互），随后自动设计专家名册、优化每位专家的 prompt，并把专家组落盘到 ./.claude/agents/ + CLAUDE.md（Claude 模式）或 ./agents/ + AGENTS.md（portable 模式）。终态附赠一句可粘贴的首次议会题。
---

立即调用 `expert-bootstrap` skill。严格按其流程执行：先检测运行时模式，不要跳过 Step 0（目标发现），Step 1–4 中除了 `NEED CLARIFICATION:` 这一逃生口外不要插入任何确认提问，Step 5 的就位公告之后必须停下。

本次运行的用户上下文（如有）: $ARGUMENTS
