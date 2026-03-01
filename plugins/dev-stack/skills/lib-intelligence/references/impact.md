# Conflict & Impact Analysis

## #pre_impl(req)

```
mcp__sequentialthinking__sequentialthinking: extract key domain nouns from req
FOR each noun:
  mcp__serena__find_symbol: {noun}
  mcp__serena__find_referencing_symbols: {noun}
mcp__memory__search_nodes: entity=Spec status=DRAFT → active work overlap
Bash: git diff --name-only HEAD → currently modified files
return: IMPACT(req, risk, affected[], conflicts[])
```

## #impact(target)

```
mcp__serena__find_symbol: {target}
mcp__serena__find_referencing_symbols: {target} → chain depth ≤ 3
mcp__memory__search_nodes: entity=BoundedContext, Spec → overlap check
```

**Output format:**
```
# Impact: {target}
Risk: 🟢 LOW | 🟡 MEDIUM | 🔴 HIGH

Affected:
  {file}: {symbol} — read | write | breaking change

Conflicts:
  Feature {id} touches {file} — coordinate before proceeding

Context overlap:
  {bounded_context}: active spec {id}

Recommendation: safe_to_proceed | coordinate_first | design_acl_first
```

---

# PR Generation

## #pr()

```
branch  ← Bash: git branch --show-current
spec    ← find matching spec by branch name OR most recent DRAFT spec
Read: spec.md → {title, problem, stories, BDD_scenarios, ADR_refs}
Read: plan.md → {ADRs}
stat    ← Bash: git diff main...HEAD --stat
commits ← Bash: git log main...HEAD --oneline
tests   ← mcp__serena__search_for_pattern: test names in changed test files
```

**PR description template:**
```markdown
## {title}

### What
{problem statement — 1 paragraph}

### Why
{business value from user stories}

### Changes
{git diff stat output}

### BDD Coverage
{for each scenario}: ✅ "{title}" → {test_file}
{if missing}:        ⚠️ "{title}" → NOT FOUND — run /dev-stack:drift

### Architecture Decisions
{ADR-N}: {one-line summary}

### Test
{test command from constitution.md}

### Checklist
- [ ] BDD scenarios automated
- [ ] Security audit passed
- [ ] No [NEEDS CLARIFICATION] remaining
- [ ] All tasks [x]
- [ ] /dev-stack:drift shows 🟢 CLEAN

---
*dev-stack {id} | {date}*
```
