<div align="center">

# 🚀 dev-stack

**Enterprise-Grade Development Orchestration for Claude Code**

*SDD • DDD • BDD • TDD • Intelligent Routing • Quality Gates*

[![Version](https://img.shields.io/badge/version-7.2.0-blue.svg)](https://github.com/1827mk/dev-stack)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-purple.svg)](https://claude.ai/code)

</div>

---

## 📖 Overview

**dev-stack** is a comprehensive development orchestration plugin that transforms how you build software with Claude Code. It automatically assembles specialized AI agents, enforces quality gates, and routes your requests intelligently.

### Why dev-stack?

| Without dev-stack | With dev-stack |
|-------------------|----------------|
| Manual agent coordination | Auto-assembled teams |
| Inconsistent code quality | Enforced quality gates |
| No process visibility | Real-time status tracking |
| Ad-hoc workflows | Optimized workflow selection |
| Manual test tracking | BDD scenario coverage |

---

## ⚡ Quick Start

### Installation

```bash
# In Claude Code CLI
/install-marketplace https://github.com/1827mk/dev-stack
```

### Your First Feature

```bash
# Just describe what you want - dev-stack handles the rest
/dev-stack:agents add user authentication with JWT tokens
```

That's it! dev-stack will:
1. 🔍 Classify your intent (feature/bug/refactor/security)
2. 👥 Assemble the right team of agents
3. 📋 Generate DDD specs with BDD scenarios
4. ✅ Run quality gates automatically
5. 🚀 Deliver production-ready code

---

## 🎯 Commands Reference

> **Note:** Commands are sorted alphabetically in Claude Code's command picker.

### Smart Entry Point

```bash
/dev-stack:agents <your request>    # Auto-routes to best workflow
```

### All Commands (21 total)

| Category | Commands |
|----------|----------|
| **Core Workflows** | `:feature` `:bug` `:hotfix` `:plan` `:refactor` `:security` |
| **Info** | `:info-adr` `:info-help` `:info-status` `:info-tools` |
| **Quality** | `:quality-audit` `:quality-check` `:quality-drift` `:quality-review` |
| **Git** | `:git-impact` `:git-parallel` `:git-pr` |
| **Session** | `:session-resume` `:session-retro` `:session-snapshot` |

### Core Workflows

| Command | Use Case | Example |
|---------|----------|---------|
| `/dev-stack:bug` | Bug fixes | `/dev-stack:bug fix null pointer in auth` |
| `/dev-stack:feature` | New functionality | `/dev-stack:feature add payment processing` |
| `/dev-stack:hotfix` | Emergency fixes | `/dev-stack:hotfix patch critical XSS` |
| `/dev-stack:plan` | Analysis only | `/dev-stack:plan analyze database schema` |
| `/dev-stack:refactor` | Code improvement | `/dev-stack:refactor simplify auth module` |
| `/dev-stack:security` | Security patches | `/dev-stack:security fix SQL injection` |

### Info Commands

| Command | Purpose |
|---------|---------|
| `/dev-stack:info-adr` | Query architecture decisions |
| `/dev-stack:info-help` | Full command reference |
| `/dev-stack:info-status` | Show active features and progress |
| `/dev-stack:info-tools` | Show available tools catalog |

### Quality Commands

| Command | Purpose |
|---------|---------|
| `/dev-stack:quality-audit` | Security + code review in parallel |
| `/dev-stack:quality-check` | Run lint + typecheck + build |
| `/dev-stack:quality-drift` | Detect spec vs code gaps |
| `/dev-stack:quality-review` | Code review on changed files |

### Git Commands

| Command | Purpose |
|---------|---------|
| `/dev-stack:git-impact` | Pre-change risk analysis |
| `/dev-stack:git-parallel` | Run features in parallel worktrees |
| `/dev-stack:git-pr` | Generate PR description |

### Session Commands

| Command | Purpose |
|---------|---------|
| `/dev-stack:session-resume` | Resume pending feature |
| `/dev-stack:session-retro` | Run retrospective |
| `/dev-stack:session-snapshot` | Save session state |

---

## 👥 Agent Team

dev-stack assembles specialized agents based on your workflow:

### Core Team

| Agent | Role | When Used |
|-------|------|-----------|
| **orchestrator** | Routes requests, assembles teams | Every request |
| **domain-analyst** | Creates DDD specs with BDD scenarios | Features, bugs, architecture |
| **solution-architect** | Designs architecture, writes ADRs | Features, refactoring, architecture |
| **tech-lead** | Decomposes plan into atomic tasks | Features, architecture |
| **senior-developer** | Implements with TDD | All code changes |
| **quality-gatekeeper** | Reviews code + security | All code changes |
| **qa-engineer** | Validates test coverage | Features, bugs |

### Extended Team

| Agent | Role | When Used |
|-------|------|-----------|
| **devops-engineer** | Deployment config, CI/CD | Features, architecture |
| **team-coordinator** | Team communication | Complex workflows |
| **performance-engineer** | Performance analysis | On-demand |
| **documentation-writer** | Generates docs | After delivery |

---

## 🔄 Workflows

### Workflow Selection

dev-stack automatically selects the right workflow:

| Intent Detected | Workflow | Team | Quality Gates |
|-----------------|----------|------|---------------|
| "add", "create", "implement" | `new_feature` | Full team | All 5 gates |
| "fix", "bug", "issue" | `bug_fix` | domain → dev → gate → qa | DoR, DoD |
| "urgent", "critical", "hotfix" | `hotfix` | dev → gate | None |
| "refactor", "improve", "clean" | `refactor` | architect → dev → gate | ArchReview, DoD |
| "security", "vulnerability", "CVE" | `security_patch` | dev → gate (full) → qa | DoR, DoD |
| "analyze", "design", "architecture" | `architecture` | Full team | All gates |
| "research", "spike", "POC" | `spike` | domain-analyst | None |

### Workflow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        /dev-stack <request>                      │
└─────────────────────────────┬───────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │   orchestrator  │
                    │   Classifies    │
                    │   & Routes      │
                    └────────┬────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
   ┌─────────┐          ┌─────────┐          ┌─────────┐
   │ feature │          │   bug   │          │ hotfix  │
   │ workflow│          │workflow │          │workflow │
   └────┬────┘          └────┬────┘          └────┬────┘
        │                    │                    │
        ▼                    ▼                    ▼
   ┌─────────┐          ┌─────────┐          ┌─────────┐
   │ domain  │          │ domain  │          │ senior  │
   │ analyst │          │ analyst │          │  dev    │
   └────┬────┘          └────┬────┘          └────┬────┘
        │                    │                    │
        ▼                    ▼                    ▼
   ┌─────────┐          ┌─────────┐          ┌─────────┐
 │solution │          │ senior  │          │ quality │
   │architect│          │  dev    │          │  gate   │
   └────┬────┘          └────┬────┘          └─────────┘
        │                    │
        ▼                    ▼
   ┌─────────┐          ┌─────────┐
   │  tech   │          │ quality │
   │  lead   │          │  gate   │
   └────┬────┘          └────┬────┘
        │                    │
        ▼                    ▼
   ┌─────────┐          ┌─────────┐
   │ senior  │          │   qa    │
   │  dev    │          │ engineer│
   └────┬────┘          └─────────┘
        │
        ▼
   ┌─────────┐
   │ quality │
   │  gate   │
   └────┬────┘
        │
        ▼
   ┌─────────┐
   │   qa    │
   │ engineer│
   └────┬────┘
        │
        ▼
   ┌─────────┐
   │ devops  │
   │ engineer│
   └─────────┘
```

---

## 🛡️ Quality Gates

dev-stack enforces quality at every stage:

### Gate Flow

```
┌──────────────────────────────────────────────────────────────┐
│                    QUALITY GATE PIPELINE                      │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────┐    ┌──────────┐    ┌───────────┐    ┌────────┐ │
│  │   DoR   │───▶│ArchReview│───▶│ TaskReady │───▶│  BDD   │ │
│  │         │    │          │    │           │    │Coverage│ │
│  └─────────┘    └──────────┘    └───────────┘    └───┬────┘ │
│       │              │               │                │      │
│       ▼              ▼               ▼                ▼      │
│  ┌─────────────────────────────────────────────────────────┐│
│  │                    DoD (Definition of Done)              ││
│  │  • All gates pass                                        ││
│  │  • All tasks [x] completed                               ││
│  │  • compile + lint + typecheck PASS                       ││
│  └─────────────────────────────────────────────────────────┘│
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### Gate Criteria

| Gate | Checks | Blocks |
|------|--------|--------|
| **DoR** | spec.md exists, no `[NEEDS CLARIFICATION]`, 3+ BDD scenarios | domain-analyst |
| **ArchReview** | plan.md exists, ADRs documented, layer boundaries defined | solution-architect |
| **TaskReady** | BDD reference, `[test-first]` tag, single layer, ≤4h estimate | tech-lead |
| **BDDCoverage** | Every BDD scenario has test, exact titles match | qa-engineer |
| **DoD** | All gates pass, all tasks complete, build passes | Final delivery |

---

## 📁 Project Structure

```
dev-stack-marketplace/
├── .claude-plugin/
│   └── marketplace.json          # Marketplace metadata
│
├── plugins/dev-stack/
│   ├── .claude-plugin/
│   │   └── plugin.json           # Plugin manifest
│   │
│   ├── README.md                 # Plugin documentation
│   │
│   ├── agents/                   # 11 Specialized Agents
│   │   ├── orchestrator.md
│   │   ├── domain-analyst.md
│   │   ├── solution-architect.md
│   │   ├── tech-lead.md
│   │   ├── senior-developer.md
│   │   ├── quality-gatekeeper.md
│   │   ├── qa-engineer.md
│   │   ├── devops-engineer.md
│   │   ├── team-coordinator.md
│   │   ├── performance-engineer.md
│   │   └── documentation-writer.md
│   │
│   ├── commands/                 # 22 Slash Commands
│   │   ├── dev-stack.md          # Smart entry point
│   │   ├── feature.md            # Feature workflow
│   │   ├── bug.md                # Bug fix workflow
│   │   ├── hotfix.md             # Hotfix workflow
│   │   ├── refactor.md           # Refactor workflow
│   │   ├── security.md           # Security workflow
│   │   ├── plan.md               # Analysis mode
│   │   └── ...                   # More commands
│   │
│   ├── hooks/                    # Event Hooks
│   │   ├── hooks.json            # Hook configuration
│   │   ├── prompts/              # Prompt-based hooks
│   │   │   ├── checkpoint-reminder.md
│   │   │   └── verify-agent-done.md
│   │   └── scripts/              # Shell script hooks
│   │       ├── session-start.sh
│   │       ├── auto-router.sh
│   │       ├── pre-tool-guard.sh
│   │       ├── notify.sh
│   │       └── status-line.sh
│   │
│   └── skills/                   # Internal Libraries
│       ├── orchestration/        # MODE routing, team dispatch
│       ├── lib-router/           # Tool mapping
│       ├── lib-workflow/         # Workflow classification
│       ├── lib-domain/           # DDD/BDD patterns
│       ├── lib-tdd/              # TDD cycle
│       └── lib-intelligence/     # Snapshot, drift, impact
│
└── docs/
    └── plans/                    # Design documents
```

---

## 🔧 Configuration

### Initialize Project

dev-stack works best with a `.specify/` directory:

```bash
# Creates constitution.md with your project principles
/dev-stack:session-retro
```

### Constitution

Your project's living document that captures:

- **Principles** - Coding standards, patterns
- **Architecture** - Key decisions, ADRs
- **Learnings** - From retrospectives

---

## 📊 Status Line

dev-stack updates your status line with real-time progress:

```
🔧 dev-stack auto-route

Task: new_feature | Domain: auth
Team: domain-analyst → solution-architect → tech-lead
Gate: DoR ✓ | ArchReview ✓ | TaskReady ⏳
```

---

## 🎓 Examples

### Feature Development

```bash
# Start a new feature
/dev-stack:feature add shopping cart with Stripe integration

# Check progress
/dev-stack:info-status

# After implementation, generate PR
/dev-stack:git-pr
```

### Bug Fix

```bash
# Quick bug fix
/dev-stack:bug fix cart total calculation error

# Review the fix
/dev-stack:quality-review
```

### Security Patch

```bash
# Security vulnerability
/dev-stack:security fix XSS in product search

# Full security audit
/dev-stack:quality-audit
```

---

## 📋 Requirements

| Requirement | Version |
|-------------|---------|
| Claude Code CLI | Latest |
| Git | 2.0+ |
| Bash | 4.0+ |

---

## 🗓️ Changelog

### v7.2.0 (2026-03-01)

**Smart Entry & Command Organization**

- 🚀 **Renamed smart entry**: `/dev-stack:dev-stack` → `/dev-stack:agents`
- 📊 **Commands sorted by frequency** (most used first)
- 📚 Reorganized help documentation with priority ordering

### v7.1.0 (2026-03-01)

**Command Restructure**

- 🔧 **Category-prefixed commands** for better organization
  - Info: `info-status`, `info-tools`, `info-help`, `info-adr`
  - Quality: `quality-check`, `quality-review`, `quality-audit`, `quality-drift`
  - Session: `session-resume`, `session-snapshot`, `session-retro`
  - Git: `git-pr`, `git-impact`, `git-parallel`
- 🗑️ Removed `/dev-stack:dev` (use `/dev-stack:dev-stack` instead)

### v7.0.0 (2026-03-01)

**Major Rewrite**

- ✨ 11 specialized agents (was 9)
- ✨ Unified quality-gatekeeper (replaces code-reviewer + security-auditor)
- ✨ 7 workflow types with optimized team compositions
- ✨ 5 quality gates (DoR, ArchReview, TaskReady, BDDCoverage, DoD)
- ✨ Intelligent auto-routing with confidence thresholds
- ✨ Parallel agent dispatch for faster execution
- ✨ Real-time status line updates
- ✨ Desktop notifications for gate events

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Built with ❤️ using Claude Code (Opus 4.6)**

[Getting Started](#-quick-start) • [Commands](#-commands-reference) • [Agents](#-agent-team) • [Workflows](#-workflows)

</div>
