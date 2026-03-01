---
description: Start any dev task - auto-orchestrates team, quality gates, and workflow
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
/dev-stack fix login bug
/dev-stack add user authentication
/dev-stack refactor database layer
/dev-stack review security
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

Skip classification entirely with these shortcuts:

| Command | Workflow | Optimizations |
|---------|----------|---------------|
| `/dev-stack:bug {desc}` | bug_fix | Skip architect, minimal spec |
| `/dev-stack:feature {desc}` | new_feature | Full team, quick quality |
| `/dev-stack:hotfix {desc}` | hotfix | Minimal team, no gates |
| `/dev-stack:refactor {desc}` | refactor | Skip domain analysis |
| `/dev-stack:security {desc}` | security_patch | Full OWASP scan |

---

**Other useful commands:**
- `/dev-stack:help` - Full command reference
- `/dev-stack:status` - See active features
- `/dev-stack:dev {id}` - Continue specific feature
- `/dev-stack:tools` - See available MCP tools
