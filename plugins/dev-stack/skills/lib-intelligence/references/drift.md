# Drift Detection

## #drift(id?)

```
targets ← id ? [id] : all non-COMPLETE specs
FOR each spec:
  Read: spec.md → {BDD_scenarios[], ubiquitous_language[]}

  FOR each scenario:
    a. mcp__serena__search_for_pattern: exact title in test files
    b. IF miss → try camelCase | snake_case | key_noun+verb variants
    c. classify: COVERED | SEMANTIC(flag) | MISSING

  FOR each term in ubiquitous_language:
    mcp__serena__search_for_pattern: term in src/
    mismatch → TERM_DRIFT

  mcp__serena__search_for_pattern: business logic in interface|infrastructure layer → LAYER_DRIFT
```

**Output format:**
```
# Drift: {id}
Coverage: {N}/{total}
MISSING  [{N}]: "{title}" → expected: {file}
SEMANTIC [{N}]: "{title}" → found as "{name}" in {file} [verify intent]
TERM_DRIFT [{N}]: spec:"{term}" code:"{found}" at {file}:{line}
LAYER_DRIFT [{N}]: biz logic in {layer}: {file}:{line}
Severity: 🟢 CLEAN | 🟡 REVIEW | 🔴 ACTION REQUIRED
```
