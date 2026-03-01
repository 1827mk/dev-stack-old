# Constitution Builder

Runs when `.specify/memory/constitution.md` is missing. Auto-detects project stack.

## Detection Steps

```
1. mcp__serena__get_symbols_overview: src/
   → detect patterns + naming conventions

2. mcp__serena__search_for_pattern: describe|it|test|expect
   → detect testing approach

3. Glob: "{package.json,pyproject.toml,go.mod,Cargo.toml,pom.xml}"
   → detect stack:
     package.json    → node
     pyproject.toml  → python
     go.mod          → go
     Cargo.toml      → rust
     pom.xml         → java

4. Bash: git log --oneline -20
   → detect commit conventions

5. mcp__serena__search_for_pattern: domain layer files
   → collect existing ubiquitous language terms
```

## Output Template

Write to `.specify/memory/constitution.md`:

```markdown
# Constitution — auto-generated {date}

Stack: {lang} | {framework} | {test_runner} | {linter}
Patterns: {detected patterns}
Ubiquitous Language (detected): {terms}

Philosophy:
  SDD: spec is source of truth
  DDD: understand context before writing code
  BDD: Given/When/Then for all scenarios
  TDD: test first, always

Tool priority: MCP serena > MCP filesystem > Built-in Read/Write/Grep

Non-negotiables:
  - No code without a passing test
  - No spec with [NEEDS CLARIFICATION]
  - Security scan before delivery
  - Domain layer: zero imports from application | infrastructure | interface

Session continuity:
  - Resume via /dev-stack:resume {id}
  - Run /dev-stack:snapshot before switching branches
```
