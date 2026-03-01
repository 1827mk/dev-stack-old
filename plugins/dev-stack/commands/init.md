---
name: init
description: Initialize dev-stack for any project with auto-detection. Detects languages, patterns, and creates constitution.md
arguments:
  - name: path
    description: Optional project path (defaults to current directory)
    required: false
---

# dev-stack:init

Initialize dev-stack for any project with intelligent auto-detection.

## Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    dev-stack:init                           │
├─────────────────────────────────────────────────────────────┤
│  1. CHECK if already initialized                            │
│     └─→ .specify/constitution.md exists?                    │
│                                                              │
│  2. DETECT Languages                                         │
│     ├─→ tsconfig.json → TypeScript                          │
│     ├─→ pyproject.toml / setup.py → Python                  │
│     ├─→ go.mod → Go                                         │
│     ├─→ pom.xml / build.gradle → Java                       │
│     ├─→ Cargo.toml → Rust                                   │
│     └─→ package.json → JavaScript/Node                      │
│                                                              │
│  3. RUN serena:onboarding                                    │
│     └─→ LSP setup, symbol indexing                          │
│                                                              │
│  4. ANALYZE Codebase Structure                              │
│     └─→ mcp__filesystem__directory_tree                     │
│                                                              │
│  5. DETECT Patterns                                          │
│     ├─→ Service Layer (service/, services/)                 │
│     ├─→ Repository (repository/, repos/)                    │
│     ├─→ Controller (controller/, controllers/)              │
│     ├─→ Factory (factory/, factories/)                      │
│     ├─→ Strategy (strategy/, strategies/)                   │
│     └─→ Domain-Driven Design (domain/, aggregate/)          │
│                                                              │
│  6. CREATE constitution.md                                   │
│     └─→ Based on detected patterns & languages              │
│                                                              │
│  7. STORE in memory MCP                                      │
│     ├─→ mcp__memory__create_entities: Project               │
│     └─→ mcp__memory__create_relations: Project → uses → X   │
│                                                              │
│  8. GENERATE Report                                          │
│     └─→ Summary of detected config                          │
└─────────────────────────────────────────────────────────────┘
```

## Implementation

### Step 1: Check Existing

```bash
# Check if already initialized
if [ -f ".specify/constitution.md" ]; then
  echo "✅ dev-stack already initialized"
  echo "   Run /dev-stack:status for project info"
  exit 0
fi
```

### Step 2: Detect Languages

Use pattern search to identify project languages:

```yaml
TypeScript:
  patterns: ["tsconfig.json", "*.ts", "*.tsx"]
  tools: [mcp__serena__find_file, mcp__filesystem__search_files]

Python:
  patterns: ["pyproject.toml", "setup.py", "requirements.txt", "*.py"]
  tools: [mcp__serena__find_file, mcp__filesystem__search_files]

Go:
  patterns: ["go.mod", "*.go"]
  tools: [mcp__serena__find_file]

Java:
  patterns: ["pom.xml", "build.gradle", "*.java"]
  tools: [mcp__serena__find_file]

Rust:
  patterns: ["Cargo.toml", "*.rs"]
  tools: [mcp__serena__find_file]

JavaScript:
  patterns: ["package.json", "*.js", "*.jsx"]
  tools: [mcp__serena__find_file, mcp__filesystem__search_files]
```

### Step 3: Serena Onboarding

```
mcp__serena__check_onboarding_performed
IF not performed:
  mcp__serena__onboarding
```

### Step 4: Analyze Structure

```
mcp__filesystem__directory_tree:
  path: .
  excludePatterns:
    - "node_modules"
    - ".git"
    - "dist"
    - "build"
    - "__pycache__"
    - "*.min.js"
```

### Step 5: Detect Patterns

```
mcp__serena__search_for_pattern:
  - "class.*Service"
  - "class.*Repository"
  - "class.*Controller"
  - "class.*Factory"
  - "class.*Strategy"
  - "@Entity|@AggregateRoot"
  - "interface.*Repository"
```

### Step 6: Create Constitution

Generate `.specify/constitution.md`:

```markdown
# Project Constitution

## Detected Languages
- {language_1}
- {language_2}

## Architecture Patterns
- {pattern_1}
- {pattern_2}

## Project Structure
{directory_tree_summary}

## Naming Conventions
- Classes: PascalCase
- Functions: camelCase / snake_case (based on language)
- Files: {detected_convention}

## Testing Framework
- {detected_framework}

## Generated
- Date: {timestamp}
- dev-stack: v9.0.0
```

### Step 7: Store in Memory

```
mcp__memory__create_entities:
  - name: {project_name}
    entityType: Project
    observations:
      - "Languages: {detected_languages}"
      - "Patterns: {detected_patterns}"
      - "Initialized: {timestamp}"
      - "Path: {project_path}"

mcp__memory__create_relations:
  - from: {project_name}
    to: {language}
    relationType: uses
  - from: {project_name}
    to: {pattern}
    relationType: implements
```

### Step 8: Generate Report

```
╔═══════════════════════════════════════════════════════════════╗
║              ✅ dev-stack Initialized                         ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  📁 Project: {name}                                           ║
║  📂 Path: {path}                                              ║
║                                                               ║
║  🔧 Languages Detected:                                       ║
║     • {language_1}                                            ║
║     • {language_2}                                            ║
║                                                               ║
║  🏗️ Architecture Patterns:                                    ║
║     • {pattern_1}                                             ║
║     • {pattern_2}                                             ║
║                                                               ║
║  📄 Files Created:                                            ║
║     • .specify/constitution.md                                ║
║                                                               ║
║  🧠 Memory Stored:                                            ║
║     • Project entity created                                  ║
║     • Pattern relations linked                                ║
║                                                               ║
║  Next Steps:                                                  ║
║  ─────────────────────────────────────────────────────────── ║
║  1. Review .specify/constitution.md                           ║
║  2. Run /dev-stack:status to verify setup                     ║
║  3. Start development with /dev-stack:agents <task>           ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

## Tools Used

| Tool | Purpose |
|------|---------|
| mcp__serena__check_onboarding_performed | Check LSP setup |
| mcp__serena__onboarding | Initialize LSP |
| mcp__serena__find_file | Find language markers |
| mcp__serena__search_for_pattern | Detect architecture patterns |
| mcp__filesystem__directory_tree | Analyze project structure |
| mcp__filesystem__create_directory | Create .specify/ |
| mcp__memory__create_entities | Store project info |
| mcp__memory__create_relations | Link patterns |
| Write | Create constitution.md |

## Error Handling

```
IF no language detected:
  ASK user: "What is the primary language for this project?"

IF serena onboarding fails:
  WARN: "LSP features limited. Manual setup may be required."
  CONTINUE with basic initialization

IF memory MCP unavailable:
  WARN: "Memory storage skipped. Install memory MCP for cross-project learning."
  CONTINUE with local-only initialization
```

## Examples

```bash
# Initialize current directory
/dev-stack:init

# Initialize specific project
/dev-stack:init /path/to/project
```
