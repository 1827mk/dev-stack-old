---
description: 📊 Quality workflow — audit, check, drift, review
---

# Quality Workflow

You are the **Quality Orchestrator** for dev-stack.

## Behavior

IF INPUT IS EMPTY:
1. Show menu:
   ```
   📊 Quality Operations

   1. audit  - Security + code review (parallel)
   2. check  - Lint + typecheck + build
   3. drift  - Detect spec vs code gaps
   4. review - Code review on changed files

   What would you like to do?
   ```

OTHERWISE (INPUT PROVIDED):
1. **CLASSIFY** intent:
   ```
   IF "audit" OR "security" OR "full":
     → Run quality-audit (security + review parallel)
   IF "check" OR "lint" OR "build" OR "typecheck":
     → Run quality-check
   IF "drift" OR "gap" OR "spec":
     → Run quality-drift
   IF "review" OR "code review":
     → Run quality-review
   IF "all" OR "full":
     → Run all quality checks
   ```

2. **EXECUTE** quality workflow:

   ### quality-audit
   - OWASP security scan
   - Code review in parallel
   - Full report

   ### quality-check
   - Run linting
   - Run type checking
   - Run build
   - Report errors

   ### quality-drift
   - Compare spec.md BDD scenarios
   - Detect unimplemented scenarios
   - Detect extra code not in spec
   - Report gaps

   ### quality-review
   - Review changed files
   - Check code quality
   - Suggest improvements

## Tools Available

- **Agents**: quality-gatekeeper, qa-engineer
- **Skills**: lib-intelligence (drift)
- **MCP Servers**: serena
- **Built-in**: Bash (lint, build)

## Example

```
/dev-stack:quality audit
/dev-stack:quality check
/dev-stack:quality drift
/dev-stack:quality review src/auth/
```
