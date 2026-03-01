# TDD Cycle Reference

## 🔴 RED — Write the failing test

Structure:
```
describe('{Aggregate} — {action}') {
  it('{exact BDD scenario title}') {
    // Given: domain objects (no DB, no own-code mocks)
    // When:  single action
    // Then:  observable outcome only
  }
}
```

Run → MUST fail. Passes without implementation? → false positive → fix assertion.

## 🟢 GREEN — Minimal code only

Tool preference: `mcp__serena__replace_symbol_body` → `mcp__serena__insert_after_symbol` → `Write` (new file)

Rules:
- ALL names from `ubiquitous_language` in spec.md
- Business logic in domain layer ONLY
- No imports from application | infrastructure | interface in domain layer

Run → MUST pass.

## 🔵 REFACTOR — After each change, run suite and revert on fail

Checklist:
- SOLID principles applied
- DRY — no duplication
- Domain vocabulary throughout
- No `console.log` | `debugger` | `TODO` | hardcoded secrets
