---
description: 📊 Quality workflow — audit, check, drift, review with shared memory
---

# Quality Workflow (v10)

You are the **Quality Orchestrator** for dev-stack v10.0.0.

## Behavior

IF INPUT IS EMPTY:
1. Show quality menu
2. Wait for selection

OTHERWISE (INPUT PROVIDED):

### 1. PARSE Sub-command

```
quality-audit   → Full quality scan
quality-check   → Lint + typecheck + build
quality-drift   → Spec vs code comparison
quality-review  → Code review of files
```

### 2. ASSEMBLE Team

Use **Task** tool to spawn sub-agents:

| Sub-command | Agent | Role |
|-------------|-------|------|
| audit | qa-validator + security-scanner | Full quality scan |
| check | qa-validator | Run quality checks |
| drift | code-analyzer + qa-validator | Detect spec drift |
| review | code-analyzer | Review code quality |

### 3. SHARED MEMORY Context

```javascript
// Initialize quality context
mcp__memory__create_entities({
  "entities": [{
    "name": "quality_{type}_{timestamp}",
    "entityType": "TaskContext",
    "observations": [
      "Intent: quality_check",
      "Sub-command: {command}",
      "Target: {files_or_scope}",
      "Original request: {input}"
    ]
  }]
})
```

### 4. EXECUTE Sub-commands

**Tool Priority: MCP > Plugins > Skills > Built-in**

#### quality-audit (Full Scan)

```
├─ qa-validator: Code quality
│  ├─ Bash (lint commands)
│  ├─ Bash (typecheck)
│  └─ mcp__memory__add_observations
│
└─ security-scanner: Security audit
   ├─ mcp__serena__search_for_pattern (OWASP patterns)
   ├─ mcp__serena__think_about_task_adherence
   └─ mcp__memory__add_observations
```

#### quality-check (Lint + Build)

```
└─ qa-validator: Run checks
   ├─ Bash (npm run lint / cargo clippy / etc.)
   ├─ Bash (npm run typecheck / cargo check)
   ├─ Bash (npm run build / cargo build)
   └─ mcp__memory__add_observations
```

#### quality-drift (Spec vs Code)

```
├─ code-analyzer: Find spec coverage
│  ├─ Read spec.md (BDD scenarios)
│  ├─ mcp__serena__search_for_pattern (find implementations)
│  └─ mcp__memory__add_observations
│
└─ qa-validator: Compare coverage
   ├─ Map BDD scenarios to tests
   ├─ Find missing implementations
   └─ mcp__serena__think_about_whether_you_are_done
```

#### quality-review (Code Review)

```
└─ code-analyzer: Review code
   ├─ mcp__serena__get_symbols_overview
   ├─ mcp__serena__find_referencing_symbols
   ├─ mcp__serena__think_about_collected_information
   └─ mcp__memory__add_observations
```

## Tools Available

**Tool Priority: MCP > Plugins > Skills > Built-in**

| Category | Tools |
|----------|-------|
| **MCP Serena** | get_symbols_overview, search_for_pattern, find_referencing_symbols, think_about_collected_information |
| **MCP Memory** | create_entities, add_observations, open_nodes |
| **Built-in** | Bash (lint, test, build), Read, Glob, Grep |

## Quality Report Format

```markdown
# Quality Report: {type}

## Summary
- **Status**: ✅ PASS / ❌ FAIL
- **Issues**: {count} found
- **Coverage**: {X}%

## Details

### Lint
- {status}
- Issues: {list}

### Type Check
- {status}
- Errors: {list}

### Tests
- {passed}/{total} passing
- Coverage: {X}%

### Security
- Vulnerabilities: {count}
- Severity: {levels}

## Recommendations
1. {recommendation_1}
2. {recommendation_2}
```

## Example

```
/dev-stack:quality audit

→ qa-validator: Running lint, typecheck, build...
→ security-scanner: Scanning for OWASP patterns...
→ Memory: [quality_audit] 3 issues found

Report:
- Lint: ✅ PASS
- TypeCheck: ✅ PASS
- Tests: 42/42 ✅
- Security: ⚠️ 1 medium (XSS in user input)
```
