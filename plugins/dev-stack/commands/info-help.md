---
description: Show command reference
---

# dev-stack v7.2.0 Command Reference

## Smart Entry

```
/dev-stack:agents <task>    # Auto-routes to best workflow
```

---

## All Commands (21 total)

> **Note:** Commands are sorted alphabetically in Claude Code's command picker.

| Category | Commands |
|----------|----------|
| **Core Workflows** | `:feature` `:bug` `:hotfix` `:plan` `:refactor` `:security` |
| **Info** | `:info-adr` `:info-help` `:info-status` `:info-tools` |
| **Quality** | `:quality-audit` `:quality-check` `:quality-drift` `:quality-review` |
| **Git** | `:git-impact` `:git-parallel` `:git-pr` |
| **Session** | `:session-resume` `:session-retro` `:session-snapshot` |

---

## Core Workflows (6 commands)

| Command | Use Case | Example |
|---------|----------|---------|
| `/dev-stack:bug` | Bug fixes | `/dev-stack:bug fix null pointer` |
| `/dev-stack:feature` | New functionality | `/dev-stack:feature add user auth` |
| `/dev-stack:hotfix` | Emergency fixes | `/dev-stack:hotfix patch XSS` |
| `/dev-stack:plan` | Analysis only | `/dev-stack:plan analyze schema` |
| `/dev-stack:refactor` | Code improvement | `/dev-stack:refactor simplify auth` |
| `/dev-stack:security` | Security patches | `/dev-stack:security fix SQLi` |

---

## Info (4 commands)

| Command | Purpose |
|---------|---------|
| `/dev-stack:info-adr` | Query architecture decisions |
| `/dev-stack:info-help` | Show this command reference |
| `/dev-stack:info-status` | Show active features and progress |
| `/dev-stack:info-tools` | Show available tools catalog |

---

## Quality (4 commands)

| Command | Purpose |
|---------|---------|
| `/dev-stack:quality-audit` | Security + code review in parallel |
| `/dev-stack:quality-check` | Run lint + typecheck + build |
| `/dev-stack:quality-drift` | Detect spec vs code gaps |
| `/dev-stack:quality-review` | Code review on changed files |

---

## Git (3 commands)

| Command | Purpose |
|---------|---------|
| `/dev-stack:git-impact` | Pre-change risk analysis |
| `/dev-stack:git-parallel` | Run features in parallel worktrees |
| `/dev-stack:git-pr` | Generate PR description |

---

## Session (3 commands)

| Command | Purpose |
|---------|---------|
| `/dev-stack:session-resume` | Resume pending feature |
| `/dev-stack:session-retro` | Run retrospective |
| `/dev-stack:session-snapshot` | Save session state |

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────┐
│  CORE WORKFLOWS     │  INFO           │  QUALITY           │
│  ───────────────     │  ─────         │  ─────────         │
│  :bug                │  :info-adr     │  :quality-audit    │
│  :feature            │  :info-help    │  :quality-check    │
│  :hotfix             │  :info-status  │  :quality-drift    │
│  :plan               │  :info-tools   │  :quality-review   │
│  :refactor           │                │                    │
│  :security           │                │                    │
├─────────────────────────────────────────────────────────────┤
│  GIT                 │  SESSION        │                    │
│  ────                │  ───────        │                    │
│  :git-impact         │  :session-resume│                    │
│  :git-parallel       │  :session-retro │                    │
│  :git-pr             │  :session-snapshot│                   │
└─────────────────────────────────────────────────────────────┘
```

---

**v7.2.0 Features:**
- Smart entry via `/dev-stack:agents`
- 11 specialized agents with intelligent routing
- 21 commands organized by category
- 5 quality gates (DoR, ArchReview, TaskReady, BDDCoverage, DoD)
