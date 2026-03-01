---
description: (C):New feature — full DDD/BDD process with all quality gates
---

Spawn orchestrator subagent with:

```
subagent_type: dev-stack:orchestrator
prompt: |
  MODE: dev
  INPUT: $ARGUMENTS
  WORKFLOW_HINT: new_feature

  Execute new feature workflow for this request.
```

---

**Full team for new_feature:**
- domain-analyst: Creates spec.md with DDD/BDD
- solution-architect: Creates plan.md with architecture
- tech-lead: Creates tasks.md with dependencies
- senior-developer: Implements via TDD
- quality-gatekeeper: Code quality + security review
- qa-engineer: Validates test coverage
- devops-engineer: Deployment config

**Quality:** Quick mode (code quality + critical security)
