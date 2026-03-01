---
description: Quick bug fix workflow - skips architect, minimal process
---

Spawn orchestrator subagent with:

```
subagent_type: dev-stack:orchestrator
prompt: |
  MODE: dev
  INPUT: $ARGUMENTS
  WORKFLOW_HINT: bug_fix

  Execute bug fix workflow for this issue.
```

---

**Optimizations for bug_fix:**
- Skips solution-architect (no plan.md)
- Skips devops-engineer (usually no infra changes)
- Uses minimal spec template
- Quick quality check (no full OWASP)

**Team:** domain-analyst -> senior-developer -> quality-gatekeeper -> qa-engineer
