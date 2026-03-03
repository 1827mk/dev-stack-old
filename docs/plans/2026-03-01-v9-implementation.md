# dev-stack v9.0.0 Hybrid Architecture Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Upgrade dev-stack to v9.0.0 with Hybrid Architecture, achieving 100% tool coverage across 145 available tools.

**Architecture:** Hybrid design with Smart Router layer + 3 specialized modules (CODE Mesh, KNOWLEDGE Layered, DOCS Modular). Each module optimized for its domain while sharing common interfaces.

**Tech Stack:** Claude Code Plugin System, MCP Servers (serena, memory, context7, doc-forge, filesystem), LSP Plugins (8 languages)

---

## Phase 1: Core Enhancements (Day 1-2)

### Task 1: Enhance lib-router Skill

**Files:**
- Modify: `plugins/dev-stack/skills/lib-router/SKILL.md`
- Test: Manual verification via `/dev-stack:info tools`

**Step 1: Read current lib-router**

Run: `Read plugins/dev-stack/skills/lib-router/SKILL.md`
Expected: See current 6-intent structure

**Step 2: Write enhanced lib-router**

Replace entire content with:

```markdown
---
disable-model-invocation: false
user-invokable: false
name: lib-router
description: AI-optimized tool router with fallback chains. Call skill:lib-router(intent) to get tool chain.
---

# TOOL MAP (v9.0 - 12 Intents)

## Code Operations (Module: CODE)

```yaml
code_read:
  description: Read and understand code symbols
  primary: mcp__serena__find_symbol
  fallbacks: [mcp__serena__get_symbols_overview, Read]
  use_when: Need to understand a specific symbol

code_edit:
  description: Modify code with symbol awareness
  primary: mcp__serena__replace_symbol_body
  fallbacks: [mcp__serena__insert_after_symbol, mcp__serena__insert_before_symbol, Edit]
  use_when: Need to modify a function or class

code_refs:
  description: Find all references to a symbol
  primary: mcp__serena__find_referencing_symbols
  fallbacks: [Grep]
  use_when: Need to understand change impact

code_overview:
  description: Get file structure overview
  primary: mcp__serena__get_symbols_overview
  fallbacks: [Read]
  use_when: Need to understand file quickly
```

## File Operations (Module: DOCS)

```yaml
file_find:
  description: Find files by pattern
  primary: mcp__serena__find_file
  fallbacks: [mcp__filesystem__search_files, Glob]
  use_when: Looking for specific files

dir_list:
  description: List directory contents
  primary: mcp__serena__list_dir
  fallbacks: [mcp__filesystem__list_directory, Bash]
  use_when: Exploring project structure

dir_tree:
  description: Get full directory tree
  primary: mcp__filesystem__directory_tree
  fallbacks: [Bash:find . -type f]
  use_when: Need complete project structure
```

## Documentation Operations (Module: DOCS)

```yaml
doc_fetch:
  description: Fetch library documentation
  primary: mcp__context7__query-docs
  requires: mcp__context7__resolve-library-id first
  fallbacks: [mcp__web_reader__webReader, mcp__fetch__fetch, WebSearch]
  use_when: Need up-to-date library docs

doc_read:
  description: Read document files
  primary: mcp__doc-forge__document_reader
  fallbacks: [Read]
  use_when: Processing PDF, DOCX, HTML files
```

## Memory Operations (Module: KNOWLEDGE)

```yaml
memory_write:
  description: Store knowledge entities
  primary: mcp__memory__create_entities
  fallbacks: [mcp__serena__write_memory]
  use_when: Storing patterns, decisions, learnings

memory_read:
  description: Query knowledge graph
  primary: mcp__memory__search_nodes
  fallbacks: [mcp__memory__read_graph, mcp__serena__read_memory]
  use_when: Finding similar patterns or decisions

memory_link:
  description: Create relations between entities
  primary: mcp__memory__create_relations
  use_when: Linking related concepts
```

## Thinking Operations (Module: KNOWLEDGE)

```yaml
think_sequential:
  description: Step-by-step reasoning
  primary: mcp__sequentialthinking__sequentialthinking
  fallbacks: [mcp__serena__think_about_collected_information]
  use_when: Complex analysis or classification

think_complete:
  description: Check information sufficiency
  primary: mcp__serena__think_about_collected_information
  use_when: Before making decisions

think_adherence:
  description: Check task adherence
  primary: mcp__serena__think_about_task_adherence
  use_when: Quality gates

think_done:
  description: Check task completion
  primary: mcp__serena__think_about_whether_you_are_done
  use_when: Before delivery
```

## Pattern Operations (Module: CODE)

```yaml
pattern_search:
  description: Search code patterns
  primary: mcp__serena__search_for_pattern
  fallbacks: [Grep]
  use_when: Finding similar code patterns

symbol_find:
  description: Find symbols by name
  primary: mcp__serena__find_symbol
  fallbacks: [Grep]
  use_when: Looking for classes, functions
```

---

# INTENT → WORKFLOW MAPPING

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

**Step 3: Verify syntax**

Run: `Read plugins/dev-stack/skills/lib-router/SKILL.md`
Expected: See 12 intents with fallback chains

**Step 4: Commit**

```bash
git add plugins/dev-stack/skills/lib-router/SKILL.md
git commit -m "feat(lib-router): upgrade to 12 intents with fallback chains"
```

---

### Task 2: Enhance orchestrator.md with serena tools

**Files:**
- Modify: `plugins/dev-stack/agents/orchestrator.md`
- Test: Manual verification

**Step 1: Read current orchestrator**

Run: `Read plugins/dev-stack/agents/orchestrator.md`
Expected: Find line 95 or FAST_PATH_CHECK section

**Step 2: Add serena integration section**

After FAST_PATH_CHECK section, add:

```markdown
---

# SERENA TOOLS INTEGRATION (v9.0)

## think_about_* for Quality Gates

Before any GATE decision, run:

```
mcp__serena__think_about_collected_information:
  "Have I gathered all necessary context for this decision?"
```

## find_referencing_symbols for Impact Analysis

When planning changes, find affected code:

```
mcp__serena__find_referencing_symbols:
  name_path: "{symbol}"
  relative_path: "{file}"
```

Returns: List of symbols that reference the target symbol.

## get_symbols_overview for File Understanding

When exploring new files:

```
mcp__serena__get_symbols_overview:
  relative_path: "{file}"
  depth: 1
```

Returns: Structured overview of all symbols in file.

## Memory Sync

Store decisions in serena memory:

```
mcp__serena__write_memory:
  memory_name: "decisions/{workflow_id}-{decision_type}"
  content: "{decision_details}"
```

## Pattern Detection

Find similar code patterns:

```
mcp__serena__search_for_pattern:
  substring_pattern: "{regex}"
  context_lines_before: 2
  context_lines_after: 2
```
```

**Step 3: Verify addition**

Run: `Grep "SERENA TOOLS INTEGRATION" plugins/dev-stack/agents/orchestrator.md`
Expected: Found in file

**Step 4: Commit**

```bash
git add plugins/dev-stack/agents/orchestrator.md
git commit -m "feat(orchestrator): add serena tools integration"
```

---

### Task 3: Enhance quality-gatekeeper.md with think_*

**Files:**
- Modify: `plugins/dev-stack/agents/quality-gatekeeper.md`
- Test: Manual verification

**Step 1: Read current quality-gatekeeper**

Run: `Read plugins/dev-stack/agents/quality-gatekeeper.md`
Expected: Find DECISION LOGIC section or APPROVED/CHANGES_REQUIRED

**Step 2: Add serena quality checks**

Before any APPROVED/CHANGES_REQUIRED decision, add:

```markdown
---

# SERENA QUALITY CHECKS (v9.0)

Before any APPROVED/CHANGES_REQUIRED decision, run these checks:

## Check 1: Information Completeness

```
mcp__serena__think_about_collected_information:
  "Have I reviewed all modified files? Have I checked all BDD scenarios?"
```

IF concerns returned -> CHANGES_REQUIRED with specific missing items.

## Check 2: Task Adherence

```
mcp__serena__think_about_task_adherence:
  "Does the implementation match the spec requirements? Are all tasks complete?"
```

IF concerns returned -> CHANGES_REQUIRED with specific deviations.

## Check 3: Completion Verification

```
mcp__serena__think_about_whether_you_are_done:
  "Are all acceptance criteria met? Is the code production-ready?"
```

IF concerns returned -> CHANGES_REQUIRED with specific blockers.

## Quality Gate Flow

```
┌──────────────────┐
│ Start Review     │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐     ┌──────────────────┐
│ Check 1: Info    │────▶│ CHANGES_REQUIRED │
│ Complete?        │ NO  │ (list missing)   │
└────────┬─────────┘     └──────────────────┘
         │ YES
         ▼
┌──────────────────┐     ┌──────────────────┐
│ Check 2: Task    │────▶│ CHANGES_REQUIRED │
│ Adherence?       │ NO  │ (list deviations)│
└────────┬─────────┘     └──────────────────┘
         │ YES
         ▼
┌──────────────────┐     ┌──────────────────┐
│ Check 3: Done?   │────▶│ CHANGES_REQUIRED │
│                  │ NO  │ (list blockers)  │
└────────┬─────────┘     └──────────────────┘
         │ YES
         ▼
┌──────────────────┐
│ APPROVED         │
└──────────────────┘
```
```

**Step 3: Verify addition**

Run: `Grep "SERENA QUALITY CHECKS" plugins/dev-stack/agents/quality-gatekeeper.md`
Expected: Found in file

**Step 4: Commit**

```bash
git add plugins/dev-stack/agents/quality-gatekeeper.md
git commit -m "feat(quality-gatekeeper): add serena think_* quality checks"
```

---

### Task 4: Create memory-sync reference

**Files:**
- Create: `plugins/dev-stack/skills/lib-intelligence/references/memory-sync.md`

**Step 1: Create directory if needed**

```bash
mkdir -p plugins/dev-stack/skills/lib-intelligence/references
```

**Step 2: Write memory-sync.md**

```markdown
# Memory Sync Reference (v9.0)

Synchronize project knowledge with memory MCP.

## Entity Types

| Type | Purpose | Example |
|------|---------|---------|
| `project` | Project metadata | Languages, frameworks, patterns |
| `pattern` | Design patterns | Repository, Factory, Strategy |
| `decision` | Architecture decisions | ADRs, trade-offs |
| `learning` | Session learnings | What worked, what didn't |
| `convention` | Coding conventions | Style, naming, structure |

## Sync Operations

### On Feature Start

```yaml
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

```yaml
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

```yaml
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

```yaml
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

```yaml
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

## Example: Full Sync Flow

```
1. SESSION START:
   → mcp__memory__open_nodes: ["project-{name}"]
   → Load conventions, patterns, recent decisions

2. FEATURE WORK:
   → mcp__memory__search_nodes: "{feature_type}"
   → Find similar patterns, reuse learnings

3. DECISION POINT:
   → mcp__memory__create_entities: [decision]
   → mcp__memory__create_relations: [links]

4. FEATURE COMPLETE:
   → mcp__memory__create_entities: [learning]
   → Update project observations

5. RETRO:
   → mcp__memory__add_observations: [improvements]
   → Update constitution
```
```

**Step 3: Verify creation**

Run: `Read plugins/dev-stack/skills/lib-intelligence/references/memory-sync.md`
Expected: See complete memory sync reference

**Step 4: Commit**

```bash
git add plugins/dev-stack/skills/lib-intelligence/references/memory-sync.md
git commit -m "feat(lib-intelligence): add memory-sync reference for v9.0"
```

---

## Phase 2: Commands + Hooks (Day 3-4)

### Task 5: Create `:init` command

**Files:**
- Create: `plugins/dev-stack/commands/init.md`

**Step 1: Write init.md**

```markdown
---
description: 🏗️ Initialize dev-stack for current project — auto-detect languages, patterns, create constitution
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

```yaml
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
      → Returns project structure analysis
```

### 4. ANALYZE CODEBASE

```yaml
# Get project structure
structure = mcp__filesystem__directory_tree:
  path: "."
  excludePatterns: ["node_modules", ".git", "dist", "build"]

# Find patterns
patterns = mcp__serena__search_for_pattern:
  - pattern: "class.*Service" → Service pattern
  - pattern: "class.*Repository" → Repository pattern
  - pattern: "class.*Controller" → Controller pattern
  - pattern: "describe\\(" → Test files
  - pattern: "test\\(" → Test files

# Get symbols overview for key files
FOR each entry point file:
  overview = mcp__serena__get_symbols_overview:
    relative_path: file
    depth: 1
```

### 5. CREATE CONSTITUTION

```yaml
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

```yaml
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

    - name: "{project_name}-conventions"
      entityType: "convention"
      observations: {detected_conventions}
```

### 7. CREATE .specify DIRECTORY

```yaml
mcp__filesystem__create_directory: ".specify/memory"
mcp__filesystem__create_directory: ".specify/specs"

Write:
  file: ".specify/memory/constitution.md"
  content: {constitution_content}
```

### 8. GENERATE REPORT

```
# dev-stack:init Complete ✅

## Project: {name}
## Languages: {languages}
## Architecture: {patterns}

## Created Files:
- .specify/memory/constitution.md
- .specify/specs/ (empty, ready for specs)

## Memory Entities:
- project: {name}
- patterns: {count} detected
- conventions: {count} detected

## Next Steps:
1. Run /dev-stack:feature to start your first feature
2. Review .specify/memory/constitution.md
3. Add project-specific conventions

## Tool Usage:
- serena tools: {count} used
- memory tools: {count} used
- filesystem tools: {count} used
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

## Error Handling

```yaml
IF no project files detected:
  REPORT: "No recognized project files found"
  SUGGEST: "Ensure you're in a project directory with package.json, go.mod, etc."

IF serena not available:
  FALLBACK: Use Read + Glob for basic detection
  WARN: "Full analysis requires serena MCP"

IF memory MCP not available:
  FALLBACK: Store only in .specify/memory/constitution.md
  WARN: "Knowledge graph requires memory MCP"
```
```

**Step 2: Verify creation**

Run: `Read plugins/dev-stack/commands/init.md`
Expected: See complete init command

**Step 3: Commit**

```bash
git add plugins/dev-stack/commands/init.md
git commit -m "feat(commands): add :init command for project initialization"
```

---

### Task 6: Add PreCommit hook to hooks.json

**Files:**
- Modify: `plugins/dev-stack/hooks/hooks.json`

**Step 1: Read current hooks.json**

Run: `Read plugins/dev-stack/hooks/hooks.json`
Expected: See current hook configuration

**Step 2: Add PreCommit hook**

Add to hooks object (before closing brace):

```json
,
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

**Step 3: Verify JSON is valid**

Run: `cat plugins/dev-stack/hooks/hooks.json | python3 -m json.tool > /dev/null && echo "Valid JSON"`
Expected: "Valid JSON"

**Step 4: Commit**

```bash
git add plugins/dev-stack/hooks/hooks.json
git commit -m "feat(hooks): add PreCommit hook configuration"
```

---

### Task 7: Create pre-commit.sh script

**Files:**
- Create: `plugins/dev-stack/hooks/scripts/pre-commit.sh`

**Step 1: Write pre-commit.sh**

```bash
#!/bin/bash
# dev-stack PreCommit Hook (v9.0)
# Runs quality checks before git commit

set -e

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$HOME/.claude/plugins/dev-stack}"
REPORT_FILE="/tmp/dev-stack-precommit-report.md"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Initialize report
echo "🔍 dev-stack PreCommit Hook (v9.0)" > "$REPORT_FILE"
echo "================================" >> "$REPORT_FILE"
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
# CHECK 4: Security Patterns
# ============================================
echo "## 4. Security Patterns" >> "$REPORT_FILE"

SECURITY_PATTERNS=(
    "hardcoded.*password\\s*="
    "api_key\\s*=\\s*['\"][^'\"]+['\"]"
    "secret\\s*=\\s*['\"][^'\"]+['\"]"
    "eval\\s*\\("
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

**Step 2: Make executable**

```bash
chmod +x plugins/dev-stack/hooks/scripts/pre-commit.sh
```

**Step 3: Verify**

Run: `ls -la plugins/dev-stack/hooks/scripts/pre-commit.sh`
Expected: See executable permission (-rwxr-xr-x)

**Step 4: Commit**

```bash
git add plugins/dev-stack/hooks/scripts/pre-commit.sh
git commit -m "feat(hooks): add pre-commit.sh with lint, typecheck, test, security checks"
```

---

## Phase 3: Skills + Agents (Day 5-7)

### Task 8: Create lib-testing skill

**Files:**
- Create: `plugins/dev-stack/skills/lib-testing/SKILL.md`

**Step 1: Create directory**

```bash
mkdir -p plugins/dev-stack/skills/lib-testing
```

**Step 2: Write SKILL.md**

```markdown
---
disable-model-invocation: false
user-invokable: false
name: lib-testing
description: Test strategies and validation. Use when implementing tests or validating coverage.
---

# lib-testing (v9.0)

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
  run_command: "npm test"

python:
  primary: "pytest"
  alternatives: ["unittest", "nose"]
  config_files: ["pytest.ini", "pyproject.toml"]
  run_command: "pytest"

go:
  primary: "go test"
  config_files: ["go.mod"]
  run_command: "go test ./..."

rust:
  primary: "cargo test"
  config_files: ["Cargo.toml"]
  run_command: "cargo test"

java:
  primary: "junit"
  alternatives: ["testng"]
  config_files: ["pom.xml", "build.gradle"]
  run_command: "mvn test"
```

## Test Discovery

```yaml
# Find test files
mcp__serena__find_file:
  file_mask: "*.test.*"
  relative_path: "."

mcp__serena__find_file:
  file_mask: "*_test.*"
  relative_path: "."

# Find test patterns
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

```yaml
# Check BDD scenario coverage
FOR each scenario in spec.md:
  Find matching test file
  Check exact title match
  Report missing tests

# Run coverage tool
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

## Test Commands Reference

```yaml
# TypeScript/Jest
npm test                    # Run all tests
npm test -- --watch        # Watch mode
npm test -- --coverage     # With coverage
npm test -- path/to/test   # Specific file

# Python/pytest
pytest                      # Run all tests
pytest -v                   # Verbose
pytest --cov               # With coverage
pytest path/to/test.py     # Specific file

# Go
go test ./...              # Run all tests
go test -v ./...           # Verbose
go test -cover ./...       # With coverage
go test path/to/package    # Specific package

# Rust
cargo test                 # Run all tests
cargo test -- --nocapture  # Show output
cargo test name            # Specific test
```
```

**Step 3: Verify**

Run: `Read plugins/dev-stack/skills/lib-testing/SKILL.md`
Expected: See complete testing skill

**Step 4: Commit**

```bash
git add plugins/dev-stack/skills/lib-testing/SKILL.md
git commit -m "feat(skills): add lib-testing skill for test strategies"
```

---

### Task 9: Create data-engineer agent

**Files:**
- Create: `plugins/dev-stack/agents/data-engineer.md`

**Step 1: Write data-engineer.md**

```markdown
---
name: data-engineer
description: Database and data pipeline specialist. Handles schema design, migrations, data validation, and query optimization. Invoked when database changes detected.
tools: Read, Write, Edit, Glob, Grep, Bash, mcp__serena__*, mcp__filesystem__*
model: sonnet
---

# DATA ENGINEER (v9.0)

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
prisma/schema.prisma → PostgreSQL, MySQL, SQLite
docker-compose.yml → Check for db services
requirements.txt → Check for database drivers
go.mod → Check for database packages
package.json → Check for ORM packages
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

### TypeORM

```typescript
// migrations/{timestamp}-{name}.ts
import { MigrationInterface, QueryRunner } from 'typeorm';

export class CreateUsers1234567890 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.createTable(/* ... */);
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    await queryRunner.dropTable('users');
  }
}
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

```yaml
# Find slow queries
mcp__serena__search_for_pattern:
  substring_pattern: "SELECT.*FROM.*WHERE"
  context_lines_after: 5

# Check for:
- Missing indexes
- N+1 query problems
- Unnecessary JOINs
- Missing pagination

# Suggest optimizations:
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

## Migration Commands Reference

```yaml
# Prisma
npx prisma migrate dev --name {name}
npx prisma migrate reset
npx prisma db push

# Django
python manage.py makemigrations
python manage.py migrate
python manage.py migrate {app} {migration}

# TypeORM
npm run migration:generate -- -n {name}
npm run migration:run
npm run migration:revert

# Flyway
flyway migrate
flyway undo
flyway clean
```
```

**Step 2: Verify**

Run: `Read plugins/dev-stack/agents/data-engineer.md`
Expected: See complete data-engineer agent

**Step 3: Commit**

```bash
git add plugins/dev-stack/agents/data-engineer.md
git commit -m "feat(agents): add data-engineer agent for database work"
```

---

### Task 10: Update plugin.json to v9.0.0

**Files:**
- Modify: `plugins/dev-stack/.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`

**Step 1: Update plugin.json**

```json
{
  "name": "dev-stack",
  "version": "9.0.0",
  "description": "Hybrid Architecture with 145 tools — Smart Router + CODE (Mesh) + KNOWLEDGE (Layered) + DOCS (Modular). /dev-stack:agents routes automatically.",
  "author": { "name": "dev-stack" },
  "keywords": ["orchestration", "tdd", "bdd", "ddd", "automation", "workflow", "owasp", "security", "performance", "hybrid", "serena", "memory"]
}
```

**Step 2: Update marketplace.json**

```json
{
  "name": "dev-stack",
  "version": "9.0.0",
  "description": "Enterprise dev orchestration with Hybrid Architecture — 145 tools, 12 agents, 12 commands, 7 skills, 6 hooks",
  "author": "dev-stack",
  "repository": "https://github.com/1827mk/dev-stack",
  "keywords": ["orchestration", "tdd", "bdd", "ddd", "automation", "workflow", "serena", "memory"]
}
```

**Step 3: Verify**

Run: `cat plugins/dev-stack/.claude-plugin/plugin.json | python3 -m json.tool`
Expected: Valid JSON with version 9.0.0

**Step 4: Commit**

```bash
git add plugins/dev-stack/.claude-plugin/plugin.json .claude-plugin/marketplace.json
git commit -m "chore: bump version to 9.0.0"
```

---

### Task 11: Final commit and tag

**Step 1: Review all changes**

```bash
git status
git log --oneline -15
```

**Step 2: Create tag**

```bash
git tag -a v9.0.0 -m "v9.0.0 - Hybrid Architecture with 145 tools integration"
```

**Step 3: Push**

```bash
git push origin master
git push origin v9.0.0
```

---

## Summary

| Phase | Tasks | Files | Commits |
|-------|-------|-------|---------|
| Phase 1 | 4 | 4 | 4 |
| Phase 2 | 3 | 3 | 3 |
| Phase 3 | 4 | 4 | 4 |
| **Total** | **11** | **11** | **11** |

## Success Verification

```bash
# Verify tool coverage
grep -r "mcp__serena" plugins/dev-stack/ | wc -l  # Should be 20+
grep -r "mcp__memory" plugins/dev-stack/ | wc -l  # Should be 10+
grep -r "mcp__doc-forge" plugins/dev-stack/ | wc -l  # Should be 5+

# Verify new components
ls plugins/dev-stack/commands/init.md  # Should exist
ls plugins/dev-stack/hooks/scripts/pre-commit.sh  # Should exist
ls plugins/dev-stack/skills/lib-testing/SKILL.md  # Should exist
ls plugins/dev-stack/agents/data-engineer.md  # Should exist

# Verify version
cat plugins/dev-stack/.claude-plugin/plugin.json | grep version  # Should be 9.0.0
```

---

*Plan generated: 2026-03-01*
*Ready for execution*
