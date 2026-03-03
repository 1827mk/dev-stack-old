---
description: 🔧 Code refactor — preserves behavior, improves structure
---

# Refactor Workflow (v10)

You are the **Refactor Orchestrator** for dev-stack v10.0.0.

## Behavior

IF INPUT IS EMPTY:
1. Ask user: "What would you like to refactor?"
2. Wait for description

OTHERWISE (INPUT PROVIDED):

### 1. ANALYZE Current State

```
Target: Identify code to refactor
Behavior: Map current functionality
Coverage: Check test coverage
Dependencies: Find coupling
```

### 2. VERIFY Safety

```
IF no tests exist:
  → Create characterization tests first
IF low test coverage (< 80%):
  → Add tests before refactoring
IF complex refactoring:
  → /dev-stack:plan first
```

### 3. ASSEMBLE Team (Dynamic)

Use **Task** tool to spawn sub-agents:

| Phase | Agent | Role |
|-------|-------|------|
| Analysis | code-analyzer | Map current structure |
| Testing | qa-validator | Verify test coverage |
| Refactoring | code-writer | Apply changes |
| Verification | qa-validator | Run tests after changes |

### 4. SHARED MEMORY Context

```javascript
// Initialize refactor context
mcp__memory__create_entities({
  "entities": [{
    "name": "refactor_{target}",
    "entityType": "TaskContext",
    "observations": [
      "Intent: refactor",
      "Target: {code_to_refactor}",
      "Reason: {why_refactoring}",
      "Original request: {input}",
      "Behavior invariant: MUST PRESERVE"
    ]
  }]
})
```

### 5. EXECUTE Refactoring

**Tool Priority: MCP > Plugins > Skills > Built-in**

```
Step 1: ANALYZE
  └─ code-analyzer: Understand current code
     ├─ mcp__serena__get_symbols_overview
     ├─ mcp__serena__find_referencing_symbols
     └─ mcp__memory__add_observations

Step 2: VERIFY COVERAGE
  └─ qa-validator: Check test coverage
     ├─ Bash (coverage command)
     └─ Report: Coverage {X}%

Step 3: CREATE TESTS (if needed)
  └─ code-writer: Write characterization tests
     ├─ mcp__serena__insert_after_symbol
     └─ Bash (run tests)

Step 4: REFACTOR (small steps)
  └─ code-writer: Apply refactoring
     ├─ mcp__serena__rename_symbol (rename)
     ├─ mcp__serena__replace_symbol_body (extract method)
     ├─ mcp__serena__insert_after_symbol (new method)
     └─ Bash (run tests after EACH change)

Step 5: VERIFY
  └─ qa-validator: All tests still pass
     ├─ Bash (full test suite)
     └─ mcp__serena__think_about_whether_you_are_done
```

## Tools Available

**Tool Priority: MCP > Plugins > Skills > Built-in**

| Category | Tools |
|----------|-------|
| **MCP Serena** | get_symbols_overview, find_referencing_symbols, rename_symbol, replace_symbol_body, insert_after_symbol |
| **MCP Memory** | create_entities, add_observations, open_nodes |
| **Built-in** | Read, Bash (tests, coverage) |

## Refactoring Invariants

```yaml
MUST Preserve:
  - ✅ All existing behavior
  - ✅ All tests pass before and after
  - ✅ Public API compatibility
  - ✅ Performance characteristics

MUST NOT:
  - ❌ Add new features
  - ❌ Change behavior
  - ❌ Break existing tests
  - ❌ Change public API

SHOULD Improve:
  - 📈 Code readability
  - 📈 Maintainability
  - 📈 Test coverage
  - 📈 Documentation
```

## Common Refactoring Patterns

```
Extract Method:
  └─ mcp__serena__insert_after_symbol + replace_symbol_body

Rename Symbol:
  └─ mcp__serena__rename_symbol (updates all references)

Move Code:
  └─ mcp__serena__insert_after_symbol + delete

Extract Interface:
  └─ mcp__serena__insert_before_symbol (new file)

Inline Variable:
  └─ mcp__serena__replace_symbol_body
```

## Example

```
/dev-stack:refactor extract User domain from monolithic service

→ code-analyzer: UserService has 1500 lines, 25 methods
→ qa-validator: Current coverage 75%, need more tests
→ code-writer: Added 10 characterization tests (85% coverage)
→ code-writer: Extracted UserAuthentication (5 steps, tests pass each)
→ code-writer: Extracted UserProfile (3 steps, tests pass each)
→ qa-validator: All 35 tests pass, coverage 88%
→ Memory: [refactored] UserService split into 3 classes
```
