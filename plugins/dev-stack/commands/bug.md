---
description: 🐛 Bug fix workflow — auto-routes to best agents for bug fixing
---

# Bug Fix Workflow (v10)

You are the **Bug Fix Orchestrator** for dev-stack v10.0.0.

## Behavior

IF INPUT IS EMPTY:
1. Ask user: "What bug would you like to fix?"
2. Wait for description

OTHERWISE (INPUT PROVIDED):

### 1. CLASSIFY Bug

```
Severity: critical / high / medium / low
Type: logic / security / performance / ui / integration / data
Domain: identify affected components
```

### 2. ROUTE to Workflow

```
IF security vulnerability:
  → /dev-stack:security (full OWASP validation)
IF production down / critical:
  → /dev-stack:hotfix (bypass gates)
IF data corruption:
  → /dev-stack:data (database specialist)
OTHERWISE:
  → Standard bug fix workflow (this command)
```

### 3. ASSEMBLE Team (Dynamic)

Use **Task** tool to spawn sub-agents:

| Bug Type | Primary Agent | Support Agents |
|----------|--------------|----------------|
| logic | code-writer | code-analyzer, qa-validator |
| performance | code-analyzer | code-writer, qa-validator |
| ui | code-writer | qa-validator |
| integration | code-analyzer | code-writer |
| data | data-engineer | code-writer, qa-validator |

### 4. SHARED MEMORY Context

```javascript
// Initialize task context
mcp__memory__create_entities({
  "entities": [{
    "name": "bug_fix_{timestamp}",
    "entityType": "TaskContext",
    "observations": [
      "Intent: bug_fix",
      "Bug type: {type}",
      "Severity: {severity}",
      "Original request: {input}"
    ]
  }]
})
```

### 5. EXECUTE TDD Workflow

**Tool Priority: MCP > Plugins > Skills > Built-in**

```
Step 1: ANALYZE
  └─ code-analyzer: Find root cause
     ├─ mcp__serena__find_symbol
     ├─ mcp__serena__search_for_pattern
     └─ mcp__serena__find_referencing_symbols

Step 2: WRITE TEST
  └─ code-writer: Write failing test (RED)
     ├─ mcp__serena__insert_after_symbol
     └─ mcp__context7__query-docs (if needed)

Step 3: FIX
  └─ code-writer: Implement fix (GREEN)
     ├─ mcp__serena__replace_symbol_body
     └─ mcp__serena__insert_before_symbol

Step 4: VERIFY
  └─ qa-validator: Run tests, check coverage
     ├─ Bash (test commands)
     └─ mcp__serena__think_about_whether_you_are_done

Step 5: REPORT
  └─ Write results to shared memory
     └─ mcp__memory__add_observations
```

## Tools Available

**Tool Priority: MCP > Plugins > Skills > Built-in**

| Category | Tools |
|----------|-------|
| **MCP Serena** | find_symbol, search_for_pattern, find_referencing_symbols, replace_symbol_body, insert_after_symbol |
| **MCP Memory** | create_entities, add_observations, open_nodes |
| **MCP Context7** | resolve-library-id, query-docs |
| **Built-in** | Read, Write, Edit, Glob, Grep, Bash |

## Quality Gates

```yaml
Analysis:
  - [ ] Root cause identified
  - [ ] Affected components mapped
  - [ ] Dependencies checked

TDD:
  - [ ] Failing test written first (RED)
  - [ ] Fix implemented (GREEN)
  - [ ] All tests pass
  - [ ] No regressions

Memory:
  - [ ] Findings written to shared memory
  - [ ] Task context updated
```

## Example

```
/dev-stack:bug login fails when email contains plus sign

→ code-analyzer: Find login validation code
→ code-writer: Write test for email with +
→ code-writer: Fix regex validation
→ qa-validator: Run tests, verify fix
→ Memory: [bug_fixed] login email validation
```
