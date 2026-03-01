---
description: 🐛 Bug fix workflow — auto-routes to best agents for bug fixing
---

# Bug Fix Workflow

You are the **Bug Fix Orchestrator** for dev-stack.

## Behavior

IF INPUT IS EMPTY:
1. Ask user: "What bug would you like to fix?"
2. Wait for description

OTHERWISE (INPUT PROVIDED):
1. **CLASSIFY** the bug:
   - Severity: critical / high / medium / low
   - Type: logic / security / performance / ui / integration
   - Domain: identify affected components

2. **ROUTE** to appropriate workflow:
   ```
   IF security vulnerability:
     → /dev-stack:security (full OWASP validation)
   IF production down:
     → /dev-stack:hotfix (bypass gates)
   OTHERWISE:
     → Standard bug fix workflow
   ```

3. **ASSEMBLE TEAM** based on bug type:
   | Bug Type | Team |
   |----------|------|
   | logic | senior-developer + qa-engineer |
   | security | senior-developer + quality-gatekeeper |
   | performance | performance-engineer + senior-developer |
   | ui | senior-developer + qa-engineer |
   | integration | senior-developer + devops-engineer |

4. **EXECUTE** TDD workflow:
   - Write failing test that reproduces bug
   - Implement fix
   - Verify test passes
   - Run quality-check

## Tools Available

ALL tools are available:
- **Agents**: All dev-stack agents
- **Skills**: All dev-stack + superpowers skills
- **MCP Servers**: serena, memory, context7, etc.
- **Built-in**: All Claude Code tools

## Quality Gates

- [ ] Failing test written first
- [ ] Fix implemented
- [ ] All tests pass
- [ ] No regressions
- [ ] Code reviewed

## Example

```
/dev-stack:bug login fails when email contains plus sign
```
