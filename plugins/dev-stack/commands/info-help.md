---
description: Show command reference
---

# dev-stack v7.0.0 Command Reference

## Smart Entry

```
/dev-stack:dev-stack <task>    # Auto-routes to best workflow
```

---

## Core Workflows

| Command | Use Case | Example |
|---------|----------|---------|
| `/dev-stack:feature` | New functionality | `/dev-stack:feature add user auth` |
| `/dev-stack:bug` | Bug fixes | `/dev-stack:bug fix null pointer` |
| `/dev-stack:hotfix` | Emergency fixes | `/dev-stack:hotfix patch XSS` |
| `/dev-stack:refactor` | Code improvement | `/dev-stack:refactor simplify auth` |
| `/dev-stack:security` | Security patches | `/dev-stack:security fix SQLi` |
| `/dev-stack:plan` | Analysis only | `/dev-stack:plan analyze schema` |

---

## Info Commands (`/dev-stack:info-*`)

| Command | Purpose |
|---------|---------|
| `/dev-stack:info-status` | Show active features and progress |
| `/dev-stack:info-tools` | Show available tools catalog |
| `/dev-stack:info-adr` | Query Architecture Decision Records |
| `/dev-stack:info-help` | Show this command reference |

---

## Quality Commands (`/dev-stack:quality-*`)

| Command | Purpose |
|---------|---------|
| `/dev-stack:quality-check` | Run lint + typecheck + build |
| `/dev-stack:quality-review` | Code review on changed files |
| `/dev-stack:quality-audit` | Security + code review in parallel |
| `/dev-stack:quality-drift` | Detect spec vs code gaps |

---

## Session Commands (`/dev-stack:session-*`)

| Command | Purpose |
|---------|---------|
| `/dev-stack:session-resume` | Resume pending feature |
| `/dev-stack:session-snapshot` | Save session state |
| `/dev-stack:session-retro` | Run retrospective |

---

## Git Commands (`/dev-stack:git-*`)

| Command | Purpose |
|---------|---------|
| `/dev-stack:git-pr` | Generate PR description |
| `/dev-stack:git-impact` | Pre-change risk analysis |
| `/dev-stack:git-parallel` | Run features in parallel worktrees |

---

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────────┐
│  WORKFLOW           │  INFO          │  QUALITY            │
│  ─────────          │  ─────         │  ───────            │
│  :feature           │  :info-status  │  :quality-check     │
│  :bug               │  :info-tools   │  :quality-review    │
│  :hotfix            │  :info-adr     │  :quality-audit     │
│  :refactor          │  :info-help    │  :quality-drift     │
│  :security          │                │                     │
│  :plan              │                │                     │
├─────────────────────────────────────────────────────────────┤
│  SESSION            │  GIT           │                     │
│  ───────            │  ───           │                     │
│  :session-resume    │  :git-pr       │                     │
│  :session-snapshot  │  :git-impact   │                     │
│  :session-retro     │  :git-parallel │                     │
└─────────────────────────────────────────────────────────────┘
```

---

**v7.0.0 Features:**
- 11 specialized agents with intelligent routing
- 7 workflow types with optimized team compositions
- 5 quality gates (DoR, ArchReview, TaskReady, BDDCoverage, DoD)
- Category-prefixed commands for better organization
