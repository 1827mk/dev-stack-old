---
description: Smart entry point - auto-orchestrates team, quality gates, and workflow
---

Spawn orchestrator subagent with:

```
subagent_type: dev-stack:orchestrator
prompt: |
  MODE: smart
  INPUT: $ARGUMENTS

  Execute the full workflow for this request.
```

---

**Quick Examples:**

```
/dev-stack:agents fix login bug
/dev-stack:agents add user authentication
/dev-stack:agents refactor database layer
/dev-stack:agents review security
```

**What happens:**
1. Fast-path keyword check (skips classification if obvious)
2. Classifies your intent (bug/feature/refactor/review/security/spike)
3. Detects context (greenfield/legacy) for sub-system selection
4. Routes to appropriate sub-system (speckit/superpowers/direct)
5. Assembles team using dependency graph
6. Runs quality gates (quick/full based on workflow)
7. Reports progress with parallel dispatch

---

**Commands by Frequency (Most Used First):**

| Freq | Category | Commands |
|------|----------|----------|
| 🔥🔥🔥 | **Workflows** | `:feature` `:bug` `:hotfix` `:refactor` `:security` `:plan` |
| 🔥🔥 | **Info** | `:info-status` `:info-tools` `:info-help` `:info-adr` |
| 🔥🔥 | **Quality** | `:quality-check` `:quality-review` `:quality-audit` `:quality-drift` |
| 🔥 | **Git** | `:git-pr` `:git-impact` `:git-parallel` |
| 🔥 | **Session** | `:session-resume` `:session-snapshot` `:session-retro` |

---

**Direct Workflow Shortcuts:**

| Command | Use Case |
|---------|----------|
| `/dev-stack:feature` | New functionality |
| `/dev-stack:bug` | Bug fixes |
| `/dev-stack:hotfix` | Emergency fixes |
| `/dev-stack:refactor` | Code improvement |
| `/dev-stack:security` | Security patches |
| `/dev-stack:plan` | Analysis only |

Run `/dev-stack:info-help` for full command reference.
