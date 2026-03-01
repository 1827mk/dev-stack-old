---
description: (I):Show full command reference with examples
---

# dev-stack v7.7.0 Command Reference

## Smart Entry

```
/dev-stack:agents <task>    # Auto-routes to best workflow
```

---

## All Commands (21 total)

> **Note:** Commands are sorted alphabetically by category prefix.

```
┌─────────────────────────────────────────────────────────────┐
│  agents        │ Smart Entry - auto-routes to best workflow │
├─────────────────────────────────────────────────────────────┤
│  CORE          │  GIT           │  INFO         │  QUALITY  │
│  ──────        │  ───────       │  ──────       │  ─────────│
│  :core-bug     │  :git-impact   │  :info-adr    │  :quality-audit   │
│  :core-feature │  :git-parallel │  :info-help   │  :quality-check   │
│  :core-hotfix  │  :git-pr       │  :info-status │  :quality-drift   │
│  :core-plan    │                │  :info-tools  │  :quality-review  │
│  :core-refactor│                │               │              │
│  :core-security│                │               │              │
├─────────────────────────────────────────────────────────────┤
│  SESSION       │                                             │
│  ───────────      │                                             │
│  :session-resume│                                             │
│  :session-retro │                                             │
│  :session-snapshot│                                           │
└─────────────────────────────────────────────────────────────┘
```

### Core Workflows (6 commands)

| Command | Use Case | Example |
|---------|----------|---------|
| `/dev-stack:core-bug` | Bug fixes | `/dev-stack:core-bug fix null pointer` |
| `/dev-stack:core-feature` | New functionality | `/dev-stack:core-feature add user auth` |
| `/dev-stack:core-hotfix` | Emergency fixes | `/dev-stack:core-hotfix patch XSS` |
| `/dev-stack:core-plan` | Analysis only | `/dev-stack:core-plan analyze schema` |
| `/dev-stack:core-refactor` | Code improvement | `/dev-stack:core-refactor simplify auth` |
| `/dev-stack:core-security` | Security patches | `/dev-stack:core-security fix SQLi` |

### Git Commands (3 commands)

| Command | Purpose |
|---------|---------|
| `/dev-stack:git-impact` | Pre-change risk analysis |
| `/dev-stack:git-parallel` | Run features in parallel worktrees |
| `/dev-stack:git-pr` | Generate PR description |

### Info Commands (4 commands)

| Command | Purpose |
|---------|---------|
| `/dev-stack:info-adr` | Query architecture decisions |
| `/dev-stack:info-help` | Show this command reference |
| `/dev-stack:info-status` | Show active features and progress |
| `/dev-stack:info-tools` | Show available tools catalog |

### Quality Commands (4 commands)

| Command | Purpose |
|---------|---------|
| `/dev-stack:quality-audit` | Security + code review in parallel |
| `/dev-stack:quality-check` | Run lint + typecheck + build |
| `/dev-stack:quality-drift` | Detect spec vs code gaps |
| `/dev-stack:quality-review` | Code review on changed files |

### Session Commands (3 commands)

| Command | Purpose |
|---------|---------|
| `/dev-stack:session-resume` | Resume pending feature |
| `/dev-stack:session-retro` | Run retrospective |
| `/dev-stack:session-snapshot` | Save session state |

---

**v7.4.0 Features:**
- Smart entry via `/dev-stack:agents`
- Category-prefixed commands for organized sorting
- 11 specialized agents with intelligent routing
- 21 commands organized by category
- 5 quality gates (DoR, ArchReview, TaskReady, BDDCoverage, DoD)

---

## Workflow Constraints

> **For AI Agents:** Always follow these constraints when selecting commands.

### Pre-Implementation
1. **ALWAYS** use `core-plan` before `core-feature` for features affecting 3+ files
2. **ALWAYS** use `git-impact` before major refactoring

### Security Rules
3. **ALWAYS** use `core-security` (not `core-bug`) for vulnerabilities
4. **NEVER** use `core-hotfix` for non-emergency security issues

### Quality Gates
5. **ALWAYS** run `quality-check` after implementation
6. **ALWAYS** run `quality-review` before `git-pr`
7. **NEVER** skip quality gates for production code

### Session Management
8. **ALWAYS** run `session-snapshot` before switching branches
9. **ALWAYS** run `session-retro` after feature delivery

### Emergency Protocol
10. **ONLY** use `core-hotfix` for: production down, data loss, security breach
11. **NEVER** use `core-hotfix` for: features, refactors, non-critical bugs
