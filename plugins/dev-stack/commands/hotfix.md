---
description: Emergency hotfix - minimal process, no gates
---

Spawn orchestrator subagent with:

```
subagent_type: dev-stack:orchestrator
prompt: |
  MODE: dev
  INPUT: $ARGUMENTS
  WORKFLOW_HINT: hotfix

  Execute hotfix workflow IMMEDIATELY. Time-boxed, production issue.
```

---

**Hotfix Optimizations:**
- Skips ALL analysis (no impact, no memory check)
- Skips domain-analyst (no spec)
- Skips solution-architect (no plan)
- Skips tech-lead (single task)
- Skips qa-engineer (time-boxed)
- Skips devops-engineer (usually direct deploy)
- NO approval gates

**Team:** senior-developer -> quality-gatekeeper only

**Quality:** Quick mode, minimal checks

**WARNING:** Use only for production emergencies. For non-urgent fixes, use /dev-stack:bug instead.
