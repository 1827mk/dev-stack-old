<div align="center">

<img src="https://img.shields.io/badge/version-8.0.0-blue?style=for-the-badge" alt="Version">
<img src="https://img.shields.io/badge/license-MIT-green?style=for-the-badge" alt="License">
<img src="https://img.shields.io/badge/Claude%20Code-Compatible-purple?style=for-the-badge" alt="Claude Code">

# 🚀 dev-stack

### **Enterprise-Grade Development Orchestration for Claude Code**

*One command. Full team. Zero overhead.*

**SDD** • **DDD** • **BDD** • **TDD** • **Intelligent Routing** • **Quality Gates**

<br>

[🎯 Quick Start](#-quick-start) • [📖 Commands](#-commands) • [👥 Agents](#-agents) • [🔄 Workflows](#-workflows)

<br>

</div>

---

## ✨ What is dev-stack?

**dev-stack** transforms how you build software with Claude Code. Just describe what you want — it automatically assembles specialized AI agents, enforces quality gates, and delivers production-ready code.

### Why teams love dev-stack

| 😫 Without dev-stack | 🚀 With dev-stack |
|:--------------------:|:-----------------:|
| Manual agent coordination | **Auto-assembled teams** |
| Inconsistent code quality | **Enforced quality gates** |
| No process visibility | **Real-time status tracking** |
| Ad-hoc workflows | **Optimized workflow selection** |
| Manual test tracking | **BDD scenario coverage** |

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

**That's it!** dev-stack will:
1. 🔍 **Classify** your intent (feature/bug/refactor/security)
2. 👥 **Assemble** the right team of AI agents
3. 📋 **Generate** DDD specs with BDD scenarios
4. ✅ **Run** quality gates automatically
5. 🚀 **Deliver** production-ready code

---

## 🎯 Commands

### One Smart Entry Point

```bash
/dev-stack:agents <describe what you want>
```

### 11 Unified Commands

```
╔═══════════════════════════════════════════════════════════════╗
║                    🚀 dev-stack v8.0.0                        ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  📦 CORE WORKFLOWS (6)                                        ║
║  ─────────────────────────────────────────────────────────── ║
║  /dev-stack:bug        🐛 Fix bugs                           ║
║  /dev-stack:feature    ✨ New features                       ║
║  /dev-stack:hotfix     🔥 Emergency fixes                    ║
║  /dev-stack:plan       📋 Read-only analysis                 ║
║  /dev-stack:refactor   🔧 Code improvement                   ║
║  /dev-stack:security   🔒 Security patches                   ║
║                                                               ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  🔀 GIT          │  📊 QUALITY     │  📁 INFO                ║
║  ──────────────  │  ─────────────  │  ─────────────          ║
║  /dev-stack:git  │ /dev-stack:quality │ /dev-stack:info      ║
║                                                               ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  💾 SESSION: /dev-stack:session (resume/retro/snapshot)      ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

### Examples

```bash
# Fix a bug
/dev-stack:agents fix null pointer exception in login

# Add a feature
/dev-stack:agents add shopping cart with Stripe

# Emergency fix
/dev-stack:agents production is down!

# Security patch
/dev-stack:agents fix SQL injection in search

# Analyze before coding
/dev-stack:agents assess database migration impact
```

---

## 👥 Agents

dev-stack assembles **11 specialized AI agents** based on your workflow:

| Agent | Role | Superpower |
|:------|:-----|:-----------|
| 🎯 **orchestrator** | Central router | Assembles the right team |
| 📝 **domain-analyst** | DDD/BDD specs | Translates requirements to scenarios |
| 🏗️ **solution-architect** | Architecture | Designs systems, writes ADRs |
| 📋 **tech-lead** | Task decomposition | Breaks work into atomic pieces |
| 💻 **senior-developer** | TDD implementation | Writes tests first, always |
| 🛡️ **quality-gatekeeper** | Code + security review | Catches issues before you |
| ✅ **qa-engineer** | Test validation | Ensures 100% BDD coverage |
| 🚀 **devops-engineer** | Deployment | CI/CD, containers, infra |
| 📊 **performance-engineer** | Optimization | Finds bottlenecks |
| 📖 **documentation-writer** | Docs | Keeps everything documented |
| 🤝 **team-coordinator** | Communication | Coordinates the team |

---

## 🔄 Workflows

### Intelligent Routing

dev-stack automatically selects the right workflow:

| You Say | Workflow | What Happens |
|:--------|:---------|:-------------|
| "add", "create", "implement" | **Feature** | Full DDD/BDD team |
| "fix", "bug", "error" | **Bug Fix** | Fast TDD cycle |
| "urgent", "critical", "production down" | **Hotfix** | Emergency bypass |
| "refactor", "improve", "clean" | **Refactor** | Safe transformation |
| "security", "vulnerability", "CVE" | **Security** | Full OWASP scan |
| "analyze", "assess", "plan" | **Plan** | Read-only analysis |

### Workflow Flow

```
Your Request
     │
     ▼
┌─────────────────┐
│  🎯 orchestrator │  ← Classifies intent
└────────┬────────┘
         │
    ┌────┴────┬─────────┬─────────┐
    ▼         ▼         ▼         ▼
┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐
│Feature│ │  Bug  │ │Hotfix │ │Security│
└───┬───┘ └───┬───┘ └───┬───┘ └───┬───┘
    │         │         │         │
    ▼         ▼         ▼         ▼
Full Team   Fast     Emergency  OWASP
+ Gates    TDD       Bypass     Scan
```

---

## 🛡️ Quality Gates

Every workflow enforces quality at every stage:

```
┌──────────────────────────────────────────────────────────────┐
│                    🎯 QUALITY GATE PIPELINE                   │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────┐   ┌──────┐   ┌──────┐   ┌─────┐   ┌─────┐         │
│  │ DoR │──▶│ Arch │──▶│ Task │──▶│ BDD │──▶│ DoD │         │
│  └─────┘   └──────┘   └──────┘   └─────┘   └─────┘         │
│                                                              │
│  ✓ Spec     ✓ Plan     ✓ Tasks    ✓ Tests    ✓ All        │
│    exists   + ADRs     + BDD        pass       complete    │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### Gate Criteria

| Gate | Checks | Why It Matters |
|:-----|:-------|:---------------|
| **DoR** | Spec exists, 3+ BDD scenarios | Clear requirements |
| **ArchReview** | Plan + ADRs documented | Thoughtful design |
| **TaskReady** | Tasks <4h, test-first tagged | Manageable work |
| **BDDCoverage** | Every scenario has test | No missing tests |
| **DoD** | All gates pass, build green | Production ready |

---

## 📊 Status Line

dev-stack keeps you informed with real-time progress:

```
🔧 dev-stack | Task: new_feature | Domain: auth
Team: domain-analyst → solution-architect → tech-lead
Gate: DoR ✓ | ArchReview ✓ | TaskReady ⏳
```

---

## 🎓 Real Examples

### Feature Development

```bash
# Start
/dev-stack:agents add password reset with email verification

# Check progress
/dev-stack:info status

# Generate PR when done
/dev-stack:git pr
```

### Bug Fix

```bash
# Quick fix
/dev-stack:agents fix cart total rounding error

# Review the fix
/dev-stack:quality review
```

### Security Patch

```bash
# Fix vulnerability
/dev-stack:agents fix XSS in product search

# Full security audit
/dev-stack:quality audit
```

---

## 📋 Requirements

| Requirement | Version |
|:------------|:--------|
| Claude Code CLI | Latest |
| Git | 2.0+ |
| Bash | 4.0+ |

---

## 🗓️ What's New

### v8.0.0 (2026-03-01)

**🎉 Unified Smart Commands**

- **11 commands** (down from 21) — simpler, smarter
- Each command is a **smart router** that auto-detects intent
- **Unified operations**: git, info, quality, session all in one
- **Full tool access**: All commands can use all agents, skills, MCP servers

<details>
<summary>📜 View Full Changelog</summary>

### v7.7.0 (2026-03-01)
- Interactive ASCII menu
- Smart routing with user input

### v7.0.0 (2026-03-01)
- 11 specialized agents
- Unified quality-gatekeeper
- 7 workflow types
- 5 quality gates
- Intelligent auto-routing
- Parallel agent dispatch
- Real-time status line
- Desktop notifications

</details>

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
