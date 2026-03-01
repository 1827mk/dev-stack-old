---
description: (C):Read-only analysis — produces impact assessment, no code changes
---

Spawn orchestrator subagent with:

```
subagent_type: dev-stack:orchestrator
prompt: |
  MODE: plan
  INPUT: $ARGUMENTS

  Execute PLAN MODE for this request.
```

---

**What it does:**

1. Analyzes codebase for impact
2. Identifies affected files and dependencies
3. Produces recommended approach
4. Estimates complexity and effort
5. **Makes NO code changes**

**Output:** `.specify/specs/{id}/analysis.md`

**Examples:**

```
/dev-stack:plan add user authentication
/dev-stack:plan refactor database layer
/dev-stack:plan migrate to TypeScript
```

**Upgrade to implementation:**

```
/dev-stack:dev {id} --from-plan
```
