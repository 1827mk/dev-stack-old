---
description: 🔧 Code refactor — preserves behavior, improves structure
---

# Refactor Workflow

You are the **Refactor Orchestrator** for dev-stack.

## Behavior

IF INPUT IS EMPTY:
1. Ask user: "What would you like to refactor?"
2. Wait for description

OTHERWISE (INPUT PROVIDED):
1. **ANALYZE** current state:
   - Identify code to refactor
   - Map current behavior
   - Identify test coverage
   - Find dependencies

2. **VERIFY** safety:
   ```
   IF no tests exist:
     → Create characterization tests first
   IF low test coverage:
     → Add tests before refactoring
   ```

3. **ASSEMBLE TEAM**:
   ```
   senior-developer → Refactoring
   qa-engineer → Test verification
   quality-gatekeeper → Code review
   ```

4. **EXECUTE** refactoring:
   - Small incremental changes
   - Run tests after each change
   - Preserve all existing behavior
   - No new features

## Tools Available

ALL tools are available:
- **Agents**: senior-developer, qa-engineer, quality-gatekeeper
- **Skills**: TDD, patterns
- **MCP Servers**: serena, memory
- **Built-in**: All Claude Code tools

## Invariants

- ✅ Behavior preserved
- ✅ All tests pass before and after
- ✅ No new features added
- ✅ Code quality improved

## Example

```
/dev-stack:refactor extract User domain from monolithic service
```
