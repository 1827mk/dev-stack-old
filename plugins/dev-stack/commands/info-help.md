---
description: Show command reference
---

# dev-stack v7.1.0 Command Reference

## Smart Entry

```
/dev-stack:agents <task>    # Auto-routes to best workflow
```

---

## Commands by Frequency (Most Used First)

### 🔥🔥🔥 Core Workflows (6 commands)

| Command | Use Case | Example |
|---------|----------|---------|
| `/dev-stack:feature` | New functionality | `/dev-stack:feature add user auth` |
| `/dev-stack:bug` | Bug fixes | `/dev-stack:bug fix null pointer` |
| `/dev-stack:hotfix` | Emergency fixes | `/dev-stack:hotfix patch XSS` |
| `/dev-stack:refactor` | Code improvement | `/dev-stack:refactor simplify auth` |
| `/dev-stack:security` | Security patches | `/dev-stack:security fix SQLi` |
| `/dev-stack:plan` | Analysis only | `/dev-stack:plan analyze schema` |

### 🔥🔥 Info (4 commands)

| Command | Purpose |
|---------|---------|
| `/dev-stack:info-status` | Show active features and progress |
| `/dev-stack:info-tools` | Show available tools catalog |
| `/dev-stack:info-help` | Show this command reference |
| `/dev-stack:info-adr` | Query Architecture Decision Records |

### 🔥🔥 Quality (4 commands)

| Command | Purpose |
|---------|---------|
| `/dev-stack:quality-check` | Run lint + typecheck + build |
| `/dev-stack:quality-review` | Code review on changed files |
| `/dev-stack:quality-audit` | Security + code review in parallel |
| `/dev-stack:quality-drift` | Detect spec vs code gaps |

### 🔥 Git (3 commands)

| Command | Purpose |
|---------|---------|
| `/dev-stack:git-pr` | Generate PR description |
| `/dev-stack:git-impact` | Pre-change risk analysis |
| `/dev-stack:git-parallel` | Run features in parallel worktrees |

### 🔥 Session (3 commands)

| Command | Purpose |
|---------|---------|
| `/dev-stack:session-resume` | Resume pending feature |
| `/dev-stack:session-snapshot` | Save session state |
| `/dev-stack:session-retro` | Run retrospective |

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────┐
│  FREQUENCY SORTED (Most Used First)                         │
├─────────────────────────────────────────────────────────────┤
│  🔥🔥🔥 WORKFLOWS    │  🔥🔥 INFO        │  🔥🔥 QUALITY    │
│  ─────────────────    │  ───────────      │  ────────────   │
│  :feature             │  :info-status     │  :quality-check │
│  :bug                 │  :info-tools      │  :quality-review│
│  :hotfix              │  :info-help       │  :quality-audit │
│  :refactor            │  :info-adr        │  :quality-drift │
│  :security            │                   │                 │
│  :plan                │                   │                 │
├─────────────────────────────────────────────────────────────┤
│  🔥 GIT               │  🔥 SESSION       │                 │
│  ───────              │  ───────────      │                 │
│  :git-pr              │  :session-resume  │                 │
│  :git-impact          │  :session-snapshot│                 │
│  :git-parallel        │  :session-retro   │                 │
└─────────────────────────────────────────────────────────────┘
```

---

**v7.1.0 Features:**
- Smart entry via `/dev-stack:agents`
- 11 specialized agents with intelligent routing
- 7 workflow types with optimized team compositions
- 5 quality gates (DoR, ArchReview, TaskReady, BDDCoverage, DoD)
- Commands sorted by usage frequency
