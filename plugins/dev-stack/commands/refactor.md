---
description: Code refactoring - preserves behavior, improves structure
---

Spawn orchestrator subagent with:

```
subagent_type: dev-stack:orchestrator
prompt: |
  MODE: dev
  INPUT: $ARGUMENTS
  WORKFLOW_HINT: refactor

  Execute refactor workflow for this request.
```

---

**Refactor Optimizations:**
- Skips domain-analyst (no spec changes)
- Skips qa-engineer (behavior unchanged)
- Skips devops-engineer (no infra changes)

**Team:** solution-architect -> senior-developer -> quality-gatekeeper

**Key Principle:** Refactoring must preserve existing behavior. All existing tests must pass.

**Gate:** after_plan (human approval before implementation)
