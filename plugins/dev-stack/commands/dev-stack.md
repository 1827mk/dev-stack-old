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
/dev-stack:dev-stack fix login bug
/dev-stack:dev-stack add user authentication
/dev-stack:dev-stack refactor database layer
/dev-stack:dev-stack review security
```

**What happens (v7.0):**
1. Fast-path keyword check (skips classification if obvious)
2. Classifies your intent (bug/feature/refactor/review/security/spike)
3. Detects context (greenfield/legacy) for sub-system selection
4. Routes to appropriate sub-system (speckit/superpowers/direct)
5. Assembles team using dependency graph
6. Runs quality gates (quick/full based on workflow)
7. Reports progress with parallel dispatch

---

**Direct Workflow Commands (Faster):**

| Command | Workflow | Optimizations |
|---------|----------|---------------|
| `/dev-stack:feature {desc}` | new_feature | Full team, quick quality |
| `/dev-stack:bug {desc}` | bug_fix | Skip architect, minimal spec |
| `/dev-stack:hotfix {desc}` | hotfix | Minimal team, no gates |
| `/dev-stack:refactor {desc}` | refactor | Skip domain analysis |
| `/dev-stack:security {desc}` | security_patch | Full OWASP scan |
| `/dev-stack:plan {desc}` | spike | Analysis only |

---

**Other Commands by Category:**

| Category | Commands |
|----------|----------|
| **Info** | `:info-status` `:info-tools` `:info-adr` `:info-help` |
| **Quality** | `:quality-check` `:quality-review` `:quality-audit` `:quality-drift` |
| **Session** | `:session-resume` `:session-snapshot` `:session-retro` |
| **Git** | `:git-pr` `:git-impact` `:git-parallel` |

Run `/dev-stack:info-help` for full command reference.
