---
description: Security patch - full OWASP validation, senior-developer implements fix first
---

Spawn orchestrator subagent with:

```
subagent_type: dev-stack:orchestrator
prompt: |
  MODE: dev
  INPUT: $ARGUMENTS
  WORKFLOW_HINT: security_patch

  Execute security patch workflow. Full OWASP validation required.
```

---

**Security Patch Process:**
- Senior-developer implements security fix
- Quality-gatekeeper validates with FULL OWASP scan
- QA-engineer verifies tests

**Quality Mode:** FULL (complete OWASP Top 10 + container + CI/CD checks)

**Team:** senior-developer -> quality-gatekeeper -> qa-engineer

**Gate:** after_spec (human approval before implementation)
