<div align="center">

<img src="https://img.shields.io/badge/version-10.0.0-blue?style=for-the-badge" alt="Version">
<img src="https://img.shields.io/badge/license-MIT-green?style=for-the-badge" alt="License">
<img src="https://img.shields.io/badge/Claude%20Code-Compatible-purple?style=for-the-badge" alt="Claude Code">

# 🚀 dev-stack

### **Enterprise-Grade Development Orchestration for Claude Code**

*Dynamic teams. Shared memory. 145+ tools.*

**Tool-Based Agents** • **Dynamic Team Assembly** • **Shared Memory** • **145+ MCP Tools**

<br>

[🎯 Quick Start](#-quick-start) • [📖 Commands](#-commands) • [👥 Agents](#-agents) • [🔄 Workflows](#-workflows)

<br>

</div>

---

## ✨ What is dev-stack?

**dev-stack** transforms how you build software with Claude Code. Just describe what you want — it dynamically assembles specialized tool-based AI agents, coordinates via shared memory, and delivers production-ready code.

### 🆕 v10.0.0 Tool-Based Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                 🏗️ TOOL-BASED AGENT ARCHITECTURE                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │               🎯 ORCHESTRATOR (v10)                      │   │
│   │    Intent Classification → Capability Mapping            │   │
│   │         → Dynamic Team Assembly → Memory Coordination    │   │
│   └─────────────────────────────────────────────────────────┘   │
│                              │                                   │
│   ┌──────────────────────────┼───────────────────────────────┐  │
│   │                  SHARED MEMORY (MCP)                      │  │
│   │              TaskContext + Agent Findings                 │  │
│   └──────────────────────────┬───────────────────────────────┘  │
│                              │                                   │
│   ┌──────────────────────────┼───────────────────────────────┐  │
│   │                    12 TOOL-BASED AGENTS                    │  │
│   ├────────────────┬─────────┴──────────┬────────────────────┤  │
│   │    CODE (5)    │    SUPPORT (6)     │    CORE (2)        │  │
│   ├────────────────┼────────────────────┼────────────────────┤  │
│   │ code-analyzer  │ git-operator       │ orchestrator       │  │
│   │ code-writer    │ file-manager       │ memory-keeper      │  │
│   │ qa-validator   │ task-planner       │                    │  │
│   │ security-scanner│ doc-writer        │                    │  │
│   │ researcher     │ data-engineer      │                    │  │
│   └────────────────┴────────────────────┴────────────────────┘  │
│                                                                 │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │              TOOL PRIORITY HIERARCHY                      │   │
│   │   MCP > Plugins > Skills > Built-in                      │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**145+ Tools Integrated** — serena (26), memory (9), doc-forge (16), filesystem (15), context7 (2), + more

### Why teams love dev-stack v10

| 😫 Without dev-stack | 🚀 With dev-stack v10 |
|:--------------------:|:---------------------:|
| Manual agent coordination | **Dynamic team assembly** |
| File-based communication | **Shared memory (MCP)** |
| Random tool usage | **Priority: MCP > Built-in** |
| No process visibility | **Real-time memory sync** |
| Fixed team per workflow | **Flexible agent selection** |
| No Git safety | **Confirmation policy** |
| Limited tool usage | **145+ tools integration** |

---

## ⚡ Quick Start

### Install

```bash
# In Claude Code CLI
/install-marketplace https://github.com/1827mk/dev-stack
```

### Your First Feature

```bash
/dev-stack:agents add user authentication with JWT tokens
```

**That's it!** dev-stack v10 will:
1. 🎯 **Classify** intent → new_feature
2. 🗺️ **Map** capabilities → code-writer, qa-validator, security-scanner
3. 👥 **Assemble** dynamic team
4. 💾 **Initialize** shared memory (TaskContext)
5. ✅ **Execute** with tool priority
6. 📝 **Report** findings to memory

---

## 🎯 Commands

### Smart Entry Point

```bash
/dev-stack:agents <describe what you want>
```

### 16 Scoped Commands

```
╔═══════════════════════════════════════════════════════════════╗
║                    🚀 dev-stack v10.0.0                       ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  📦 CORE WORKFLOWS (6)                                        ║
║  ─────────────────────────────────────────────────────────── ║
║  /dev-stack:bug        🐛 Bug fix (TDD cycle)                 ║
║  /dev-stack:feature    ✨ New feature (full DDD/BDD)          ║
║  /dev-stack:hotfix     🔥 Emergency fix (bypass gates)        ║
║  /dev-stack:plan       📋 Read-only analysis                  ║
║  /dev-stack:refactor   🔧 Code improvement                    ║
║  /dev-stack:security   🔒 Security patch (OWASP)              ║
║                                                               ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  🔀 GIT          │  📊 QUALITY     │  📁 INFO                 ║
║  ──────────────  │  ─────────────  │  ──────────────          ║
║  /dev-stack:git  │ /dev-stack:quality│ /dev-stack:info        ║
║  (impact/parallel│ (audit/check/   │ (adr/help/               ║
║   /pr)           │  drift/review)  │  status/tools)           ║
║                                                               ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  🆕 NEW IN v10 (4)                                            ║
║  ─────────────────────────────────────────────────────────── ║
║  /dev-stack:research   🔍 Library docs, web search            ║
║  /dev-stack:docs       📝 Documentation generation            ║
║  /dev-stack:data       🗄️ Database migrations                ║
║  /dev-stack:resume     ▶️ Resume session from memory          ║
║                                                               ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  💾 SESSION          │  🚀 INIT                               ║
║  ──────────────────  │  ──────────────────                   ║
║  /dev-stack:session  │  /dev-stack:init                      ║
║  (resume/retro/      │  (auto-detect & initialize)           ║
║   snapshot)          │                                       ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

---

## 👥 Agents (v10 Tool-Based)

dev-stack v10 has **12 specialized tool-based agents**:

### Core Agents (2)

| Agent | Role | Primary Tools |
|:------|:-----|:--------------|
| 🎯 **orchestrator** | Central router | mcp__memory__*, mcp__sequentialthinking__* |
| 💾 **memory-keeper** | Memory coordinator | mcp__memory__*, mcp__serena__*_memory |

### Code Agents (5)

| Agent | Role | Primary Tools |
|:------|:-----|:--------------|
| 🔍 **code-analyzer** | Symbol lookup | mcp__serena__find_symbol, find_referencing_symbols |
| ✍️ **code-writer** | TDD implementation | mcp__serena__replace_symbol_body, mcp__context7__* |
| ✅ **qa-validator** | Test coverage | Bash (tests), mcp__serena__think_* |
| 🔒 **security-scanner** | OWASP scanning | mcp__serena__search_for_pattern |
| 🔎 **researcher** | External research | mcp__context7__*, mcp__web_reader__* |

### Support Agents (5)

| Agent | Role | Primary Tools |
|:------|:-----|:--------------|
| 📝 **doc-writer** | Documentation | mcp__doc-forge__*, mcp__filesystem__* |
| 🔀 **git-operator** | Git operations | Bash (git), mcp__serena__* |
| 📁 **file-manager** | File operations | mcp__filesystem__* (all 15) |
| 📋 **task-planner** | Task decomposition | mcp__sequentialthinking__*, TaskCreate |
| 🗄️ **data-engineer** | Database ops | mcp__serena__*, Bash (migrations) |

---

## 🔄 Dynamic Team Assembly

### v10 Key Innovation

Unlike v9 (fixed teams), v10 assembles teams **dynamically** based on task requirements:

```
User: "Fix SQL injection in login"

v9:  domain-analyst → senior-developer → quality-gatekeeper → qa-engineer
     (Fixed 4-agent team regardless of task)

v10: orchestrator → security-scanner (OWASP) → code-analyzer (find code)
          → code-writer (fix) → qa-validator (tests)
     (Dynamic 5-agent team based on security + code needs)
```

### Team Assembly Logic

```yaml
bug_fix:
  - code-analyzer (find root cause)
  - code-writer (TDD fix)
  - qa-validator (verify)

security_patch:
  - security-scanner (OWASP)
  - code-analyzer (map affected)
  - code-writer (fix)
  - qa-validator (tests)

new_feature:
  - task-planner (decompose)
  - code-analyzer (research)
  - code-writer (implement)
  - security-scanner (scan)
  - qa-validator (coverage)
  - doc-writer (docs)
```

---

## 💾 Shared Memory Protocol

### TaskContext Entity

All agents communicate via shared memory:

```javascript
// Created by orchestrator
{
  "name": "task_20260302_fix_login",
  "entityType": "TaskContext",
  "observations": [
    "Intent: bug_fix",
    "Original request: fix login bug",
    "[code-analyzer] [root_cause] Found in LoginService.ts:45",
    "[code-writer] [fix_applied] Updated validation regex",
    "[qa-validator] [tests_passing] 5/5 tests pass"
  ]
}
```

### Agent Findings

Each agent writes to shared memory:

```javascript
mcp__memory__add_observations({
  "observations": [{
    "entityName": "task_20260302_fix_login",
    "contents": [
      "[security-scanner] [scan_complete] 0 OWASP issues found",
      "[code-writer] [tdd] RED → GREEN → REFACTOR complete"
    ]
  }]
})
```

---

## 🛡️ Git Safety Policy

v10 enforces Git safety with user confirmation:

```
╔═══════════════════════════════════════════════════════════════╗
║               🔒 GIT SAFETY POLICY (v10.0.0)                  ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  ✅ READ-ONLY (Auto-allowed):                                 ║
║     • git status, git diff, git log, git branch              ║
║                                                               ║
║  ⚠️  REQUIRES USER CONFIRMATION:                              ║
║     • git commit, git push                                    ║
║     • git reset --hard, git commit --amend                    ║
║     • git push --force                                        ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

---

## 🛠️ Tool Priority

### v10 Innovation

**MCP > Plugins > Skills > Built-in**

```
Code Reading:
  1️⃣ mcp__serena__find_symbol     (Primary - symbol-aware)
  2️⃣ Read                          (Fallback - raw file)

Documentation:
  1️⃣ mcp__doc-forge__*             (Primary - specialized)
  2️⃣ Write                         (Fallback - basic)

Research:
  1️⃣ mcp__context7__query-docs    (Primary - up-to-date)
  2️⃣ mcp__web_reader__webReader   (Secondary)
  3️⃣ WebSearch                     (Tertiary)
```

---

## 🎓 Real Examples

### Bug Fix with v10

```bash
# Request
/dev-stack:bug login fails when email contains plus sign

# What happens (v10)
orchestrator → Creates TaskContext
code-analyzer → Finds LoginService.ts:45 (regex issue)
code-writer → TDD: Write test (RED) → Fix (GREEN)
qa-validator → 5/5 tests passing
memory → [bug_fixed] Email validation updated
```

### Security Patch with v10

```bash
# Request
/dev-stack:security fix SQL injection in search

# What happens (v10)
orchestrator → Creates TaskContext (security_patch)
security-scanner → A03:2021 injection found
code-analyzer → 3 files affected
code-writer → Parameterized queries
security-scanner → Re-scan: clean
qa-validator → 3 security tests added
```

### Research with v10

```bash
# Request (NEW in v10)
/dev-stack:research React useEffect cleanup

# What happens (v10)
researcher → mcp__context7__query-docs(React)
memory → [research_complete] Cleanup function docs
```

---

## 📋 Requirements

| Requirement | Version |
|:------------|:--------|
| Claude Code CLI | Latest |
| Git | 2.0+ |
| MCP Memory Server | Optional (recommended) |
| MCP Serena Server | Optional (recommended) |

---

## 🗓️ What's New

### v10.0.0 (2026-03-02) — Tool-Based Architecture

**🚀 Major Redesign: Dynamic Teams + Shared Memory**

- **Tool-Based Agents**: 12 specialized agents with specific tool sets
- **Dynamic Team Assembly**: Teams assembled based on task requirements
- **Shared Memory Protocol**: MCP memory for inter-agent communication
- **Tool Priority Hierarchy**: MCP > Plugins > Skills > Built-in
- **Git Safety Policy**: Confirmation required for destructive operations
- **16 Commands** (+4 new: research, docs, data, resume)
- **8 Skills** (+lib-orchestration for v10 core)

<details>
<summary>📜 View Full Changelog</summary>

### v9.0.0 (2026-03-01) — Hybrid Architecture
- 145 tools integration
- 12 workflow-based agents
- 7 skills

### v8.0.0 (2026-03-01)
- 11 unified commands (down from 21)

### v7.0.0 (2026-03-01)
- 11 specialized agents
- 5 quality gates
- Intelligent auto-routing

</details>

---

## 📖 Documentation

- [Plugin README](plugins/dev-stack/README.md) - Technical blueprint
- [Migration Guide](plugins/dev-stack/docs/MIGRATION-v9-to-v10.md) - v9 → v10
- [Tools Reference](docs/tools_name.md) - 155 tools catalog

---

## 🤝 Contributing

Contributions welcome! Feel free to submit a Pull Request.

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

---

<div align="center">

**Built with ❤️ using Claude Code (Opus 4.6)**

<br>

[Get Started](#-quick-start) • [Commands](#-commands) • [Agents](#-agents) • [Workflows](#-workflows)

</div>
