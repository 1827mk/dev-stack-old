# dev-stack v9.0.0 Implementation Plan

**Status:** 🚀 READY TO IMPLEMENT
**Date:** 2026-03-01
**Target:** 1 week sprint

---

## 🎯 Goals

1. **Leverage serena MCP** (40% → 95%)
2. **Leverage memory MCP** (0% → 80%)
3. **Add PreCommit hook** with LSP
4. **Add `:init` command**
5. **Enhance quality gates** with serena:think_*
6. **Add lib-testing skill**
7. **Add data-engineer agent**

---

## 📋 TASKS (Ordered by Dependency)

### Phase 1: Core Enhancements (Day 1-2)

#### Task 1.1: Enhance orchestrator.md with serena tools

**File:** `plugins/dev-stack/agents/orchestrator.md`

**Add after line 95 (after FAST_PATH_CHECK):**

```markdown
# SERENA TOOLS INTEGRATION

## think_about_* for Quality Gates

Before any GATE decision, run:

\`\`\`
mcp__serena__think_about_collected_information:
  "Have I gathered all necessary context for this decision?"
\`\`\`

## find_referencing_symbols for Impact Analysis

When planning changes:

\`\`\`
mcp__serena__find_referencing_symbols:
  name_path: "{symbol}"
  relative_path: "{file}"
\`\`\`

## get_symbols_overview for File Understanding

When exploring new files:

\`\`\`
mcp__serena__get_symbols_overview:
  relative_path: "{file}"
  depth: 1
\`\`\`

## Memory Sync

Store decisions in serena memory:

\`\`\`
mcp__serena__write_memory:
  memory_name: "decisions/{workflow_id}-{decision_type}"
  content: "{decision_details}"
\`\`\`
```

---

#### Task 1.2: Enhance quality-gatekeeper.md with serena:think_*

**File:** `plugins/dev-stack/agents/quality-gatekeeper.md`

**Add after line 166 (after DECISION LOGIC):**

```markdown
---

# SERENA QUALITY CHECKS

Before any APPROVED/CHANGES_REQUIRED decision:

\`\`\`
# 1. Check information completeness
mcp__serena__think_about_collected_information:
  "Have I reviewed all modified files? Have I checked all BDD scenarios?"

# 2. Check task adherence
mcp__serena__think_about_task_adherence:
  "Does the implementation match the spec requirements? Are all tasks complete?"

# 3. Check completion
mcp__serena__think_about_whether_you_are_done:
  "Are all acceptance criteria met? Is the code production-ready?"
\`\`\`

If any check returns concerns -> CHANGES_REQUIRED with specific issues.
```

---

#### Task 1.3: Enhance lib-router skill

**File:** `plugins/dev-stack/skills/lib-router/SKILL.md`

**Replace entire content with:**

```markdown
---
disable-model-invocation: false
user-invokable: false
name: lib-router
description: AI-optimized tool router with fallback chains. Call skill:lib-router(intent) to get tool chain.
---

# TOOL MAP (Enhanced v9.0)

## Code Operations

```yaml
code_read:
  description: Read and understand code symbols
  primary: mcp__serena__find_symbol
  fallbacks:
    - mcp__serena__get_symbols_overview
    - Read
  use_when: "Need to understand a specific symbol or function"

code_edit:
  description: Modify code with symbol awareness
  primary: mcp__serena__replace_symbol_body
  fallbacks:
    - mcp__serena__insert_after_symbol
    - mcp__serena__insert_before_symbol
    - Edit
  use_when: "Need to modify a specific function or class"

code_refs:
  description: Find all references to a symbol
  primary: mcp__serena__find_referencing_symbols
  fallbacks:
    - Grep
  use_when: "Need to understand impact of changes"

code_overview:
  description: Get structure overview of a file
  primary: mcp__serena__get_symbols_overview
  fallbacks:
    - Read
  use_when: "Need to understand file structure quickly"
```

## File Operations

```yaml
file_find:
  description: Find files by pattern
  primary: mcp__serena__find_file
  fallbacks:
    - mcp__filesystem__search_files
    - Glob
  use_when: "Looking for specific files"

dir_list:
  description: List directory contents
  primary: mcp__serena__list_dir
  fallbacks:
    - mcp__filesystem__list_directory
    - Bash:ls
  use_when: "Exploring project structure"

dir_tree:
  description: Get directory tree
  primary: mcp__filesystem__directory_tree
  fallbacks:
    - Bash:find
  use_when: "Need full project structure"
```

## Documentation Operations

```yaml
doc_fetch:
  description: Fetch library documentation
  primary: mcp__context7__query-docs
  requires: mcp__context7__resolve-library-id first
  fallbacks:
    - mcp__web_reader__webReader
    - mcp__fetch__fetch
    - WebSearch
  use_when: "Need up-to-date library docs"

doc_read:
  description: Read document files (PDF, DOCX, etc.)
  primary: mcp__doc-forge__document_reader
  fallbacks:
    - Read
  use_when: "Processing specification documents"
```

## Memory & Knowledge

```yaml
memory_write:
  description: Store knowledge entities
  primary: mcp__memory__create_entities
  fallbacks:
    - mcp__serena__write_memory
  use_when: "Storing patterns, decisions, learnings"

memory_read:
  description: Query knowledge graph
  primary: mcp__memory__search_nodes
  fallbacks:
    - mcp__memory__read_graph
    - mcp__serena__read_memory
  use_when: "Finding similar patterns or decisions"

memory_link:
  description: Create relations between entities
  primary: mcp__memory__create_relations
  use_when: "Linking related concepts"
```

## Thinking & Analysis

```yaml
think_sequential:
  description: Step-by-step reasoning
  primary: mcp__sequentialthinking__sequentialthinking
  fallbacks:
    - mcp__serena__think_about_collected_information
  use_when: "Complex analysis or classification"

think_complete:
  description: Check if information is sufficient
  primary: mcp__serena__think_about_collected_information
  use_when: "Before making decisions"

think_adherence:
  description: Check task adherence
  primary: mcp__serena__think_about_task_adherence
  use_when: "Quality gates"

think_done:
  description: Check if task is complete
  primary: mcp__serena__think_about_whether_you_are_done
  use_when: "Before delivery"
```

## Pattern Search

```yaml
pattern_search:
  description: Search for code patterns
  primary: mcp__serena__search_for_pattern
  fallbacks:
    - Grep
  use_when: "Finding similar code patterns"

symbol_find:
  description: Find symbols by name pattern
  primary: mcp__serena__find_symbol
  fallbacks:
    - Grep
  use_when: "Looking for classes, functions, variables"
```

---

# INTENT → TOOLS MAPPING

```yaml
bug_fix:
  explore: [code_read, code_overview]
  find: [pattern_search, symbol_find]
  fix: [code_edit]
  verify: [code_refs, think_done]

new_feature:
  explore: [code_read, dir_tree]
  design: [think_sequential, memory_read]
  implement: [code_edit]
  test: [Bash]
  document: [doc_fetch, memory_write]

refactor:
  analyze: [code_refs, code_overview]
  transform: [code_edit]
  verify: [code_refs, think_adherence]

review:
  scan: [code_read, pattern_search]
  check: [think_complete, think_adherence]
  report: [Write]

security:
  audit: [pattern_search, code_read]
  report: [Write]
  verify: [think_done]
```

---

# EXECUTION PATTERN

```
1. GET intent from orchestrator
2. LOOKUP tool chain for intent
3. TRY primary tool
4. IF fail -> TRY fallbacks in order
5. RETURN result
6. IF all fail -> report tool unavailable
```

---

# SUB-SYSTEM ROUTING

```yaml
greenfield: speckit
legacy_bug: superpowers
hotfix: direct
security: superpowers+direct
```
```

---

### Phase 2: New Commands (Day 2-3)

#### Task 2.1: Create `:init` command

**File:** `plugins/dev-stack/commands/init.md` (NEW)

```markdown
---
description: 🏗️ Initialize dev-stack for current project — analyzes codebase, creates constitution, stores patterns
---

# dev-stack:init

Initialize dev-stack for the current project.

## Flow

### 1. CHECK PREREQUISITES

```
IF .specify/memory/constitution.md exists:
  ASK: "Project already initialized. Re-analyze? (y/n)"
  IF no: EXIT with current status
```

### 2. DETECT PROJECT CONTEXT

```bash
# Language detection
languages = []
IF tsconfig.json exists: languages += ["typescript"]
IF pyproject.toml OR setup.py exists: languages += ["python"]
IF go.mod exists: languages += ["go"]
IF Cargo.toml exists: languages += ["rust"]
IF pom.xml OR build.gradle exists: languages += ["java"]
IF package.json exists: languages += ["javascript"]
```

### 3. RUN SERENA ONBOARDING

```
mcp__serena__check_onboarding_performed:
  IF false:
    mcp__serena__onboarding:
      -> Returns project structure analysis
```

### 4. ANALYZE CODEBASE

```
# Get project structure
structure = mcp__filesystem__directory_tree(path: ".")

# Find patterns
patterns = mcp__serena__search_for_pattern:
  - "class.*Service" -> Service pattern
  - "class.*Repository" -> Repository pattern
  - "class.*Controller" -> Controller pattern
  - "describe\\(" -> Test files
  - "test\\(" -> Test files

# Get symbols overview for key files
FOR each entry point file:
  overview = mcp__serena__get_symbols_overview(file)
```

### 5. CREATE CONSTITUTION

```
mcp__serena__write_memory:
  memory_name: "constitution"
  content: |
    # Project Constitution

    ## Detected Languages
    {languages}

    ## Architecture Patterns
    {patterns_found}

    ## Entry Points
    {entry_points}

    ## Testing Framework
    {test_framework}

    ## Conventions
    - [Auto-detected from code style]
    - [Patterns from existing code]
```

### 6. STORE IN MEMORY MCP

```
mcp__memory__create_entities:
  entities:
    - name: "{project_name}"
      entityType: "project"
      observations:
        - "Languages: {languages}"
        - "Architecture: {patterns}"
        - "Initialized: {date}"

    - name: "{project_name}-patterns"
      entityType: "patterns"
      observations: {detected_patterns}
```

### 7. CREATE .specify DIRECTORY

```
mcp__filesystem__create_directory: ".specify/memory"
mcp__filesystem__create_directory: ".specify/specs"

Write: ".specify/memory/constitution.md"
```

### 8. GENERATE REPORT

```
# dev-stack:init Complete

## Project: {name}
## Languages: {languages}
## Architecture: {patterns}

## Created Files:
- .specify/memory/constitution.md
- .specify/specs/ (empty, ready for specs)

## Memory Entities:
- project: {name}
- patterns: {count} detected

## Next Steps:
1. Run /dev-stack:feature to start your first feature
2. Review .specify/memory/constitution.md
3. Add project-specific conventions
```

## Tools Used

| Tool | Purpose |
|------|---------|
| mcp__serena__check_onboarding_performed | Check if already onboarded |
| mcp__serena__onboarding | Analyze project structure |
| mcp__filesystem__directory_tree | Get project structure |
| mcp__serena__search_for_pattern | Find patterns |
| mcp__serena__get_symbols_overview | Understand key files |
| mcp__serena__write_memory | Store constitution |
| mcp__memory__create_entities | Store in knowledge graph |
| mcp__filesystem__create_directory | Create directories |
| Write | Create files |

## Examples

```bash
# Initialize new project
/dev-stack:init

# Re-analyze existing project
/dev-stack:init --reanalyze
```
```

---

### Phase 3: New Hooks (Day 3-4)

#### Task 3.1: Add PreCommit hook

**File:** `plugins/dev-stack/hooks/hooks.json`

**Add to hooks object:**

```json
"PreCommit": [
  {
    "matcher": ".*",
    "hooks": [
      {
        "type": "command",
        "command": "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/pre-commit.sh",
        "timeout": 60
      }
    ]
  }
]
```

---

#### Task 3.2: Create pre-commit.sh script

**File:** `plugins/dev-stack/hooks/scripts/pre-commit.sh` (NEW)

```bash
#!/bin/bash
# dev-stack PreCommit Hook
# Runs quality checks before git commit

set -e

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/plugins/dev-stack}"
STATE_FILE="/tmp/dev-stack-precommit-state"
REPORT_FILE="/tmp/dev-stack-precommit-report.md"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔍 dev-stack PreCommit Hook" > "$REPORT_FILE"
echo "==========================" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

PASSED=0
FAILED=0
WARNINGS=0

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect project type
detect_language() {
    if [ -f "tsconfig.json" ]; then echo "typescript"
    elif [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then echo "python"
    elif [ -f "go.mod" ]; then echo "go"
    elif [ -f "Cargo.toml" ]; then echo "rust"
    elif [ -f "pom.xml" ]; then echo "java"
    else echo "unknown"
    fi
}

LANG=$(detect_language)
echo "📦 Detected language: $LANG" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# ============================================
# CHECK 1: Lint/Format
# ============================================
echo "## 1. Lint/Format Check" >> "$REPORT_FILE"

case $LANG in
    typescript)
        if [ -f "package.json" ] && grep -q '"lint"' package.json; then
            if npm run lint >> "$REPORT_FILE" 2>&1; then
                echo "✅ Lint passed" >> "$REPORT_FILE"
                ((PASSED++))
            else
                echo "❌ Lint failed" >> "$REPORT_FILE"
                ((FAILED++))
            fi
        else
            echo "⚠️ No lint script found" >> "$REPORT_FILE"
            ((WARNINGS++))
        fi
        ;;
    python)
        if command_exists ruff; then
            if ruff check . >> "$REPORT_FILE" 2>&1; then
                echo "✅ Ruff check passed" >> "$REPORT_FILE"
                ((PASSED++))
            else
                echo "❌ Ruff check failed" >> "$REPORT_FILE"
                ((FAILED++))
            fi
        elif command_exists flake8; then
            if flake8 . >> "$REPORT_FILE" 2>&1; then
                echo "✅ Flake8 passed" >> "$REPORT_FILE"
                ((PASSED++))
            else
                echo "❌ Flake8 failed" >> "$REPORT_FILE"
                ((FAILED++))
            fi
        else
            echo "⚠️ No Python linter found" >> "$REPORT_FILE"
            ((WARNINGS++))
        fi
        ;;
    go)
        if command_exists golint; then
            if golint ./... >> "$REPORT_FILE" 2>&1; then
                echo "✅ Go lint passed" >> "$REPORT_FILE"
                ((PASSED++))
            else
                echo "❌ Go lint failed" >> "$REPORT_FILE"
                ((FAILED++))
            fi
        else
            echo "⚠️ golint not installed" >> "$REPORT_FILE"
            ((WARNINGS++))
        fi
        ;;
    *)
        echo "⚠️ No lint check for $LANG" >> "$REPORT_FILE"
        ((WARNINGS++))
        ;;
esac
echo "" >> "$REPORT_FILE"

# ============================================
# CHECK 2: Type Check
# ============================================
echo "## 2. Type Check" >> "$REPORT_FILE"

case $LANG in
    typescript)
        if command_exists tsc && [ -f "tsconfig.json" ]; then
            if tsc --noEmit >> "$REPORT_FILE" 2>&1; then
                echo "✅ TypeScript check passed" >> "$REPORT_FILE"
                ((PASSED++))
            else
                echo "❌ TypeScript check failed" >> "$REPORT_FILE"
                ((FAILED++))
            fi
        else
            echo "⚠️ TypeScript not available" >> "$REPORT_FILE"
            ((WARNINGS++))
        fi
        ;;
    python)
        if command_exists mypy; then
            if mypy . >> "$REPORT_FILE" 2>&1; then
                echo "✅ MyPy passed" >> "$REPORT_FILE"
                ((PASSED++))
            else
                echo "❌ MyPy failed" >> "$REPORT_FILE"
                ((FAILED++))
            fi
        else
            echo "⚠️ MyPy not installed" >> "$REPORT_FILE"
            ((WARNINGS++))
        fi
        ;;
    go)
        # Go has built-in type checking via build
        if go build ./... >> "$REPORT_FILE" 2>&1; then
            echo "✅ Go build passed" >> "$REPORT_FILE"
            ((PASSED++))
        else
            echo "❌ Go build failed" >> "$REPORT_FILE"
            ((FAILED++))
        fi
        ;;
    *)
        echo "⚠️ No type check for $LANG" >> "$REPORT_FILE"
        ((WARNINGS++))
        ;;
esac
echo "" >> "$REPORT_FILE"

# ============================================
# CHECK 3: Tests (if exist)
# ============================================
echo "## 3. Test Check" >> "$REPORT_FILE"

case $LANG in
    typescript)
        if [ -f "package.json" ] && grep -q '"test"' package.json; then
            if npm test >> "$REPORT_FILE" 2>&1; then
                echo "✅ Tests passed" >> "$REPORT_FILE"
                ((PASSED++))
            else
                echo "❌ Tests failed" >> "$REPORT_FILE"
                ((FAILED++))
            fi
        else
            echo "⚠️ No test script found" >> "$REPORT_FILE"
            ((WARNINGS++))
        fi
        ;;
    python)
        if [ -d "tests" ] || [ -d "test" ]; then
            if command_exists pytest; then
                if pytest --tb=short >> "$REPORT_FILE" 2>&1; then
                    echo "✅ Pytest passed" >> "$REPORT_FILE"
                    ((PASSED++))
                else
                    echo "❌ Pytest failed" >> "$REPORT_FILE"
                    ((FAILED++))
                fi
            else
                echo "⚠️ Pytest not installed" >> "$REPORT_FILE"
                ((WARNINGS++))
            fi
        else
            echo "⚠️ No tests directory" >> "$REPORT_FILE"
            ((WARNINGS++))
        fi
        ;;
    go)
        if go test ./... >> "$REPORT_FILE" 2>&1; then
            echo "✅ Go tests passed" >> "$REPORT_FILE"
            ((PASSED++))
        else
            echo "❌ Go tests failed" >> "$REPORT_FILE"
            ((FAILED++))
        fi
        ;;
    *)
        echo "⚠️ No test check for $LANG" >> "$REPORT_FILE"
        ((WARNINGS++))
        ;;
esac
echo "" >> "$REPORT_FILE"

# ============================================
# CHECK 4: Security Patterns (Quick Scan)
# ============================================
echo "## 4. Security Patterns" >> "$REPORT_FILE"

SECURITY_PATTERNS=(
    "hardcoded.*password\\s*="
    "api_key\\s*=\\s*['\"][^'\"]+['\"]"
    "secret\\s*=\\s*['\"][^'\"]+['\"]"
    "eval\\s*\\("
    "dangerously.*Set.*Inner.*HTML"
)

SEC_ISSUES=0
for pattern in "${SECURITY_PATTERNS[@]}"; do
    if git diff --cached --name-only | xargs grep -E "$pattern" 2>/dev/null; then
        echo "⚠️ Potential security issue: $pattern" >> "$REPORT_FILE"
        ((SEC_ISSUES++))
    fi
done

if [ $SEC_ISSUES -eq 0 ]; then
    echo "✅ No security patterns detected" >> "$REPORT_FILE"
    ((PASSED++))
else
    echo "❌ $SEC_ISSUES security patterns detected" >> "$REPORT_FILE"
    ((FAILED++))
fi
echo "" >> "$REPORT_FILE"

# ============================================
# SUMMARY
# ============================================
echo "" >> "$REPORT_FILE"
echo "## Summary" >> "$REPORT_FILE"
echo "- ✅ Passed: $PASSED" >> "$REPORT_FILE"
echo "- ❌ Failed: $FAILED" >> "$REPORT_FILE"
echo "- ⚠️ Warnings: $WARNINGS" >> "$REPORT_FILE"

# Output report
cat "$REPORT_FILE"

# Exit code
if [ $FAILED -gt 0 ]; then
    echo ""
    echo -e "${RED}❌ PreCommit hook failed. Please fix issues before committing.${NC}"
    exit 1
else
    echo ""
    echo -e "${GREEN}✅ PreCommit hook passed. Proceeding with commit.${NC}"
    exit 0
fi
```

**Make executable:**
```bash
chmod +x plugins/dev-stack/hooks/scripts/pre-commit.sh
```

---

### Phase 4: New Skills (Day 4-5)

#### Task 4.1: Create lib-testing skill

**File:** `plugins/dev-stack/skills/lib-testing/SKILL.md` (NEW)

```markdown
---
disable-model-invocation: false
user-invokable: false
name: lib-testing
description: Test strategies and validation. Use when implementing tests or validating coverage.
---

# lib-testing

Test strategy, execution, and validation skill.

## Test Types

| Type | Purpose | When to Use |
|------|---------|-------------|
| **unit** | Test isolated functions | All code changes |
| **integration** | Test component interactions | API, database changes |
| **e2e** | Test user workflows | Critical paths |
| **bdd** | Test business scenarios | Features with specs |
| **performance** | Test speed/load | Optimization work |
| **security** | Test vulnerability fixes | Security patches |

## Test Framework Detection

```yaml
typescript:
  primary: "jest"
  alternatives: ["vitest", "mocha"]
  config_files: ["jest.config.*", "vitest.config.*"]

python:
  primary: "pytest"
  alternatives: ["unittest", "nose"]
  config_files: ["pytest.ini", "pyproject.toml"]

go:
  primary: "go test"
  config_files: ["go.mod"]

rust:
  primary: "cargo test"
  config_files: ["Cargo.toml"]

java:
  primary: "junit"
  alternatives: ["testng"]
  config_files: ["pom.xml", "build.gradle"]
```

## Test Discovery

```
1. Find test files:
   mcp__serena__find_file:
     file_mask: "*.test.*"
     relative_path: "."

   mcp__serena__find_file:
     file_mask: "*_test.*"
     relative_path: "."

2. Find test patterns:
   mcp__serena__search_for_pattern:
     substring_pattern: "(describe|it|test)\\s*\\("
```

## TDD Workflow

Uses `superpowers:test-driven-development` skill:

```
1. RED: Write failing test first
   - Test must fail without implementation
   - Use exact BDD scenario title

2. GREEN: Implement minimum code
   - Just enough to pass test
   - Don't over-engineer

3. REFACTOR: Clean up code
   - Run tests after each change
   - Revert if tests fail
```

## Coverage Validation

```
1. Check BDD scenario coverage:
   FOR each scenario in spec.md:
     Find matching test file
     Check exact title match
     Report missing tests

2. Run coverage tool:
   TypeScript: npm test -- --coverage
   Python: pytest --cov
   Go: go test -cover
```

## Test Generation

When BDD scenario exists but test missing:

```typescript
// Generated from BDD scenario
describe('{Aggregate} - {action}', () => {
  it('{exact BDD scenario title}', () => {
    // Given: {setup from scenario}
    // When: {action from scenario}
    // Then: {assertion from scenario}
  });
});
```

## Tools Used

| Tool | Purpose |
|------|---------|
| mcp__serena__find_file | Find test files |
| mcp__serena__search_for_pattern | Find test patterns |
| mcp__serena__find_symbol | Find test functions |
| Bash | Run test commands |
| superpowers:test-driven-development | TDD workflow |

## Integration with dev-stack

- Called by senior-developer during implementation
- Called by qa-engineer for coverage validation
- Supports lib-tdd for TDD cycle
```

---

### Phase 5: New Agent (Day 5-6)

#### Task 5.1: Create data-engineer agent

**File:** `plugins/dev-stack/agents/data-engineer.md` (NEW)

```markdown
---
name: data-engineer
description: Database and data pipeline specialist. Handles schema design, migrations, data validation, and query optimization. Invoked when database changes detected or data operations needed.
tools: Read, Write, Edit, Glob, Grep, Bash, mcp__serena__*, mcp__filesystem__*
model: sonnet
---

# DATA ENGINEER

Database and data pipeline specialist for dev-stack.

## When Invoked

```
IF workflow involves:
  - Database schema changes
  - Migration scripts
  - Data validation
  - Query optimization
  - Data pipeline work
THEN invoke data-engineer
```

## Responsibilities

| Area | Tasks |
|------|-------|
| **Schema Design** | Design tables, indexes, relationships |
| **Migrations** | Write up/down migration scripts |
| **Data Validation** | Ensure data integrity, constraints |
| **Query Optimization** | Analyze and optimize queries |
| **Data Pipelines** | ETL scripts, data transformations |

## Database Detection

```yaml
# Detect database type from project files
prisma/schema.prisma -> PostgreSQL, MySQL, SQLite
docker-compose.yml -> Check for db services
requirements.txt -> Check for database drivers
go.mod -> Check for database packages
```

## Migration Patterns

### PostgreSQL

```sql
-- Migration: {id}_create_{table}.sql
CREATE TABLE {table} (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Rollback
DROP TABLE IF EXISTS {table};
```

### Prisma

```prisma
model {Model} {
  id        Int      @id @default(autoincrement())
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
```

### Django

```python
# migrations/{id}_{name}.py
from django.db import migrations, models

class Migration(migrations.Migration):
    initial = True
    dependencies = []
    operations = [
        migrations.CreateModel(
            name='{Model}',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True)),
            ],
        ),
    ]
```

## Data Validation Checklist

```
□ Primary keys defined
□ Foreign keys with proper constraints
□ Indexes on frequently queried columns
□ NOT NULL constraints where appropriate
□ Default values for optional fields
□ Unique constraints on business keys
□ Check constraints for data ranges
```

## Query Optimization

```
1. Find slow queries:
   mcp__serena__search_for_pattern:
     substring_pattern: "SELECT.*FROM.*WHERE"
     context_lines_after: 5

2. Check for:
   - Missing indexes
   - N+1 query problems
   - Unnecessary JOINs
   - Missing pagination

3. Suggest optimizations:
   - Add appropriate indexes
   - Use eager loading
   - Add query caching
```

## Tools Used

| Tool | Purpose |
|------|---------|
| mcp__serena__search_for_pattern | Find database code |
| mcp__serena__find_symbol | Find model definitions |
| mcp__filesystem__directory_tree | Find migration files |
| Read | Read schema files |
| Write | Write migration files |
| Bash | Run migration commands |

## Output Format

```
# Data Engineer Report

## Changes Made
- {migration_file}: {description}
- {schema_file}: {description}

## Validation Results
- ✅ Foreign key constraints: PASS
- ✅ Index coverage: PASS
- ⚠️ Missing index on {column}

## Rollback Instructions
{how to rollback changes}

## Performance Notes
{any performance considerations}
```

## Integration with Workflows

| Workflow | When Invoked |
|----------|--------------|
| new_feature | When feature involves data model |
| refactor | When refactoring data layer |
| security_patch | When fixing data security issues |
| architecture | When designing data architecture |
```

---

### Phase 6: Memory Integration (Day 6-7)

#### Task 6.1: Create memory-sync reference

**File:** `plugins/dev-stack/skills/lib-intelligence/references/memory-sync.md` (NEW)

```markdown
# Memory Sync Reference

Synchronize project knowledge with memory MCP.

## Entity Types

| Type | Purpose | Example |
|------|---------|---------|
| `project` | Project metadata | Project info, languages, frameworks |
| `pattern` | Design patterns | Repository, Factory, Strategy |
| `decision` | Architecture decisions | ADRs, trade-offs |
| `learning` | Session learnings | What worked, what didn't |
| `convention` | Coding conventions | Style, naming, structure |

## Sync Operations

### On Feature Start

```
1. Search for similar patterns:
   mcp__memory__search_nodes:
     query: "{feature_description}"

2. Load related decisions:
   mcp__memory__search_nodes:
     query: "ADR {domain}"

3. Check project conventions:
   mcp__memory__open_nodes:
     names: ["{project}-conventions"]
```

### On Decision Made

```
mcp__memory__create_entities:
  entities:
    - name: "ADR-{id}-{title}"
      entityType: "decision"
      observations:
        - "Context: {context}"
        - "Decision: {decision}"
        - "Consequences: {consequences}"
        - "Date: {date}"
```

### On Pattern Discovered

```
mcp__memory__create_entities:
  entities:
    - name: "pattern-{name}"
      entityType: "pattern"
      observations:
        - "Type: {pattern_type}"
        - "File: {file_path}"
        - "Usage: {how_used}"
```

### On Feature Complete

```
mcp__memory__create_entities:
  entities:
    - name: "learning-{feature_id}"
      entityType: "learning"
      observations:
        - "What worked: {successes}"
        - "Challenges: {challenges}"
        - "Improvements: {improvements}"
```

## Relation Types

| Relation | Meaning | Example |
|----------|---------|---------|
| `uses` | Uses pattern | Feature → Pattern |
| `depends_on` | Dependency | Feature → Feature |
| `relates_to` | Related concept | ADR → Pattern |
| `replaces` | Supersedes | New ADR → Old ADR |
| `contradicts` | Conflicts | Learning → Decision |

## Query Patterns

```
# Find patterns similar to current task
mcp__memory__search_nodes:
  query: "pattern authentication"

# Find all ADRs for a domain
mcp__memory__search_nodes:
  query: "ADR database"

# Get full knowledge graph
mcp__memory__read_graph: {}

# Get specific entities
mcp__memory__open_nodes:
  names: ["project-myapp", "ADR-001-auth"]
```

## Integration Points

| Hook | Action |
|------|--------|
| SessionStart | Load project context from memory |
| Feature start | Search for similar patterns |
| Decision made | Store as entity |
| Feature complete | Store learnings |
| Retro | Update learnings |
```

---

## 📊 PROGRESS TRACKING

### Checklist

```
Phase 1: Core Enhancements
[ ] Task 1.1: Enhance orchestrator.md
[ ] Task 1.2: Enhance quality-gatekeeper.md
[ ] Task 1.3: Enhance lib-router skill

Phase 2: New Commands
[ ] Task 2.1: Create :init command

Phase 3: New Hooks
[ ] Task 3.1: Add PreCommit hook to hooks.json
[ ] Task 3.2: Create pre-commit.sh script

Phase 4: New Skills
[ ] Task 4.1: Create lib-testing skill

Phase 5: New Agent
[ ] Task 5.1: Create data-engineer agent

Phase 6: Memory Integration
[ ] Task 6.1: Create memory-sync reference
```

### Success Criteria

| Criteria | How to Verify |
|----------|---------------|
| serena tools used | Check agent files for mcp__serena__* |
| memory MCP used | Check for mcp__memory__* calls |
| PreCommit works | Make a commit, see checks run |
| :init works | Run /dev-stack:init in new project |
| Quality gates enhanced | Check quality-gatekeeper.md |
| lib-testing available | Skill appears in /dev-stack:info tools |
| data-engineer available | Agent appears in team formation |

---

## 🚀 READY TO START

เริ่ม implement ที่ **Task 1.1** หรือต้องการปรับแผนก่อน?
