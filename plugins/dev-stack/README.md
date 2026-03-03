# dev-stack v10.0.0 — Tool-Based Agent Architecture

> **Internal Plugin Documentation** — Detailed architecture, agents, commands, and configuration for developers.
>
> **v10.0.0 Tool-Based Architecture**: 145+ tools, 12 specialized agents, 16 commands, 8 skills

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Plugin Structure](#plugin-structure)
3. [Agents Reference](#agents-reference)
4. [Commands Reference](#commands-reference)
5. [Skills Reference](#skills-reference)
6. [Shared Memory Protocol](#shared-memory-protocol)
7. [Tool Priority](#tool-priority)
8. [Git Safety Policy](#git-safety-policy)
9. [Configuration](#configuration)
10. [MCP Integration](#mcp-integration)

---

## Architecture Overview

### v10.0.0 Key Changes

| Feature | v9.0.0 | v10.0.0 |
|---------|--------|---------|
| **Architecture** | Workflow-Based | Tool-Based |
| **Agent Selection** | Fixed teams per workflow | **Capability-based dynamic assembly** |
| **Execution** | Sequential | **Phase-based parallel (38-75% faster)** |
| **Communication** | File-based | Shared memory (MCP) |
| **Tool Priority** | None | MCP > Plugins > Skills > Built-in |
| **Git Safety** | Basic | Full confirmation policy |

### Design Philosophy

```
┌─────────────────────────────────────────────────────────────────┐
│                    dev-stack v10.0.0 Architecture               │
│              Capability-Based Parallel Orchestration            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   USER INPUT                                                    │
│       │                                                         │
│       ▼                                                         │
│   ┌─────────────────────────────────────────┐                   │
│   │          ORCHESTRATOR (v10)              │                   │
│   │  ┌─────────────────────────────────┐    │                   │
│   │  │ 1. Capability Detection (NEW)    │    │                   │
│   │  │ 2. Intent Classification         │    │                   │
│   │  │ 3. Dependency-Level Team Assembly│    │                   │
│   │  │ 4. Memory Coordinator            │    │                   │
│   │  └─────────────────────────────────┘    │                   │
│   └──────────────────┬──────────────────────┘                   │
│                      │                                          │
│                      ▼                                          │
│   ┌─────────────────────────────────────────┐                   │
│   │         SHARED MEMORY (MCP)              │                   │
│   └──────────────────┬──────────────────────┘                   │
│                      │                                          │
│   ┌──────────────────────────────────────────────────────────┐  │
│   │     PARALLEL EXECUTION (by Dependency Level)              │  │
│   │                                                           │  │
│   │  Level 0 (Parallel):                                      │  │
│   │  ┌──────────┐ ┌──────────┐ ┌──────────┐                  │  │
│   │  │ code-    │ │ security-│ │ researcher│  ← Independent  │  │
│   │  │ analyzer │ │ scanner  │ │          │                  │  │
│   │  └──────────┘ └──────────┘ └──────────┘                  │  │
│   │                      │                                   │  │
│   │                      ▼ sync_to_memory()                   │  │
│   │                                                           │  │
│   │  Level 1 (With Level 0 Context):                         │  │
│   │  ┌──────────────────────────────────────┐                │  │
│   │  │         code-writer                  │  ← Needs analysis│ │
│   │  └──────────────────────────────────────┘                │  │
│   │                      │                                   │  │
│   │                      ▼ sync_to_memory()                   │  │
│   │                                                           │  │
│   │  Level 2 (With Level 1 Context):                         │  │
│   │  ┌──────────────────┐ ┌──────────────────┐              │  │
│   │  │   qa-validator   │ │   doc-writer     │  ← Needs code│  │
│   │  └──────────────────┘ └──────────────────┘              │  │
│   └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│   ┌─────────────────────────────────────────┐                   │
│   │         TOOL LAYER (145+ tools)          │                   │
│   │  MCP: serena, memory, context7,          │                   │
│   │       filesystem, doc-forge, web_reader  │                   │
│   │  Priority: MCP > Plugins > Skills > Built│                   │
│   └─────────────────────────────────────────┘                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Data Flow (Parallel Execution)

```
User Request
    │
    ▼
┌───────────────────────────────────────────────────────┐
│ 1. ANALYZE REQUIREMENTS (capability-matcher.md)      │
│    - Detect required capabilities                     │
│    - Score confidence for each capability             │
│    - Identify required agents                         │
└───────────────────────┬───────────────────────────────┘
                        │
                        ▼
┌───────────────────────────────────────────────────────┐
│ 2. CLASSIFY INTENT (orchestrator)                     │
│    - Keyword detection                                │
│    - Sequential thinking for ambiguous cases          │
│    - Combine with capability analysis                 │
└───────────────────────┬───────────────────────────────┘
                        │
                        ▼
┌───────────────────────────────────────────────────────┐
│ 3. MAP CAPABILITIES (capability-mapping.md)           │
│    - Intent → Capabilities mapping                    │
│    - Capability → Agent mapping with dependency levels│
└───────────────────────┬───────────────────────────────┘
                        │
                        ▼
┌───────────────────────────────────────────────────────┐
│ 4. CREATE SHARED MEMORY (memory-protocol.md)          │
│    - Create TaskContext entity                        │
│    - Store original request                           │
│    - Initialize observation log                       │
└───────────────────────┬───────────────────────────────┘
                        │
                        ▼
┌───────────────────────────────────────────────────────┐
│ 5. PARALLEL EXECUTION (parallel-executor.md)          │
│                                                       │
│   Level 0: [code-analyzer, security-scanner]          │
│            └─ Promise.all() → sync_to_memory()        │
│                                                       │
│   Level 1: [code-writer] (with Level 0 context)      │
│            └─ sync_to_memory()                        │
│                                                       │
│   Level 2: [qa-validator] (with Level 1 context)     │
│            └─ sync_to_memory()                        │
└───────────────────────┬───────────────────────────────┘
                        │
                        ▼
┌───────────────────────────────────────────────────────┐
│ 6. AGGREGATE RESULTS (memory coordinator)             │
│    - Read all agent findings from memory              │
│    - Combine into final output                        │
│    - Update task status                               │
└───────────────────────────────────────────────────────┘
```

---

## Plugin Structure

```
plugins/dev-stack/
│
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest (v10.0.0)
│
├── README.md                    # This file (technical blueprint)
│
├── agents/                      # 12 Tool-Based Agents
│   ├── orchestrator.md          # Central router (v10)
│   ├── memory-keeper.md         # Memory coordinator (NEW v10)
│   ├── code-analyzer.md         # Symbol lookup (NEW v10)
│   ├── code-writer.md           # TDD implementation (NEW v10)
│   ├── researcher.md            # External research (NEW v10)
│   ├── doc-writer.md            # Documentation (NEW v10)
│   ├── qa-validator.md          # Test coverage (NEW v10)
│   ├── security-scanner.md      # OWASP scanning (NEW v10)
│   ├── git-operator.md          # Git operations (NEW v10)
│   ├── task-planner.md          # Task decomposition (NEW v10)
│   ├── file-manager.md          # File operations (NEW v10)
│   └── data-engineer.md         # Database operations
│
├── commands/                    # 16 Commands
│   ├── agents.md                # Smart router (v10)
│   ├── bug.md                   # Bug fix workflow (v10)
│   ├── feature.md               # Feature workflow (v10)
│   ├── hotfix.md                # Emergency hotfix
│   ├── plan.md                  # Read-only analysis (v10)
│   ├── refactor.md              # Refactor workflow (v10)
│   ├── security.md              # Security workflow (v10)
│   ├── git.md                   # Git operations (v10)
│   ├── info.md                  # Info queries
│   ├── quality.md               # Quality checks (v10)
│   ├── session.md               # Session management
│   ├── resume.md                # Resume command (NEW v10)
│   ├── research.md              # Research workflow (NEW v10)
│   ├── docs.md                  # Documentation workflow (NEW v10)
│   ├── data.md                  # Data workflow (NEW v10)
│   └── init.md                  # Project initialization
│
├── hooks/
│   ├── hooks.json               # Hook registration
│   ├── prompts/                 # Prompt-based hooks
│   └── scripts/                 # Shell script hooks
│       ├── shared-memory-init.sh # Memory init (NEW v10)
│       └── ...
│
└── skills/                      # 8 Skills
    ├── lib-orchestration/       # Core orchestration (NEW v10)
    │   ├── SKILL.md
    │   └── references/
    │       ├── intent-classification.md
    │       ├── capability-mapping.md
    │       ├── team-assembly.md
    │       └── memory-protocol.md
    ├── orchestration/           # Team dispatch
    ├── lib-router/              # Tool mapping
    ├── lib-workflow/            # Workflow classification
    ├── lib-domain/              # DDD/BDD patterns
    ├── lib-tdd/                 # TDD cycle
    └── lib-intelligence/        # Snapshot, drift
```

---

## Agents Reference

### Agent Categories (with Dependency Levels)

| Category | Agents | Dependency Level | Purpose |
|----------|--------|-----------------|---------|
| **Core** | orchestrator, memory-keeper | Level 0 | Routing, coordination |
| **Code** | code-analyzer, security-scanner | Level 0 | Analysis (parallel) |
| **Code** | code-writer | Level 1 | Implementation (needs analysis) |
| **Code** | qa-validator | Level 2 | Validation (needs code) |
| **Research** | researcher | Level 0 | External information |
| **Support** | doc-writer | Level 2 | Documentation (needs context) |
| **Support** | git-operator | Level 2 | Git (needs qa approval) |
| **Support** | task-planner, file-manager, data-engineer | Level 0-1 | Planning, file ops, DB |

### Tool-Based Agent Details

#### 1. orchestrator.md (v10)

```yaml
Role: Master Orchestrator
Model: sonnet
Tools: Read, Glob, Grep, Task, mcp__memory__*, mcp__sequentialthinking__*
Responsibilities:
  - Classify user intent
  - Map intent to capabilities
  - Assemble dynamic team
  - Coordinate memory
  - Aggregate results
Tool Priority: MCP > Plugins > Skills > Built-in
```

#### 2. memory-keeper.md (NEW v10)

```yaml
Role: Memory Coordinator
Model: haiku
Tools: Read, Write, mcp__memory__*, mcp__serena__*_memory
Responsibilities:
  - Manage TaskContext entities
  - Create agent findings
  - Query memory for coordination
  - Fallback to file-based storage
```

#### 3. code-analyzer.md (NEW v10)

```yaml
Role: Code Analysis Specialist
Model: sonnet
Tools: Read, Glob, Grep, mcp__serena__find_symbol, mcp__serena__find_referencing_symbols
Responsibilities:
  - Symbol lookup
  - Reference finding
  - Pattern search
  - Write findings to memory
```

#### 4. code-writer.md (NEW v10)

```yaml
Role: TDD Implementation Specialist
Model: sonnet
Tools: Read, Write, Edit, Bash, mcp__serena__replace_symbol_body, mcp__context7__*
Responsibilities:
  - Follow RED-GREEN-REFACTOR
  - Write failing test first
  - Minimal implementation
  - Use serena for symbol editing
```

#### 5. qa-validator.md (NEW v10)

```yaml
Role: Quality Assurance Specialist
Model: sonnet
Tools: Read, Glob, Grep, Bash, mcp__serena__*
Responsibilities:
  - Execute test suites
  - Verify coverage >= 80%
  - Validate BDD scenarios
  - Run quality gates
```

#### 6. security-scanner.md (NEW v10)

```yaml
Role: Security Analysis Specialist
Model: sonnet
Tools: Read, Glob, Grep, mcp__serena__search_for_pattern
Responsibilities:
  - OWASP Top 10 detection
  - Injection patterns
  - Crypto failures
  - Auth issues
```

#### 7. researcher.md (NEW v10)

```yaml
Role: Research Specialist
Model: sonnet
Tools: WebSearch, mcp__context7__*, mcp__web_reader__*, mcp__fetch__*, mcp__doc-forge__*
Responsibilities:
  - Library docs (context7)
  - Web search
  - URL analysis
  - Document reading
```

#### 8. doc-writer.md (NEW v10)

```yaml
Role: Documentation Specialist
Model: sonnet
Tools: Read, Write, mcp__filesystem__*, mcp__doc-forge__*
Responsibilities:
  - Write markdown docs
  - PDF generation
  - Format conversion
  - File operations
```

#### 9. git-operator.md (NEW v10)

```yaml
Role: Git Operations Specialist
Model: sonnet
Tools: Read, Bash, mcp__serena__*
Safety:
  - Read-only: auto-allowed
  - Write: requires confirmation
Responsibilities:
  - Git status, diff, log
  - PR generation
  - Impact analysis
```

#### 10. task-planner.md (NEW v10)

```yaml
Role: Task Planning Specialist
Model: sonnet
Tools: Read, Write, mcp__sequentialthinking__*, TaskCreate, TaskGet, TaskUpdate, TaskList
Responsibilities:
  - Decompose tasks
  - Define dependencies
  - Create atomic tasks
  - Write plan to memory
```

#### 11. file-manager.md (NEW v10)

```yaml
Role: File Operations Specialist
Model: sonnet
Tools: mcp__filesystem__* (all 15), Read, Write, Edit
Responsibilities:
  - Create/move/delete files
  - Directory tree operations
  - Search files by pattern
  - Read media files
```

#### 12. data-engineer.md (Updated v10)

```yaml
Role: Database Operations Specialist
Model: sonnet
Tools: Read, Write, Edit, Bash, mcp__serena__*, mcp__memory__*
Responsibilities:
  - Database migrations
  - Schema changes
  - Query optimization
  - ETL pipelines
```

---

## Commands Reference

### Command Architecture

Each command is a **scoped orchestrator** that:
1. Accepts natural language input
2. Routes to specific sub-agents
3. Uses shared memory for coordination
4. Returns aggregated results

### Quick Reference

| Command | Scope | Team | Tools |
|---------|-------|------|-------|
| `/dev-stack:agents` | All | Dynamic | All |
| `/dev-stack:bug` | Bug fixes | code-analyzer + code-writer + qa-validator | serena, memory |
| `/dev-stack:feature` | New features | Full team (dynamic) | All |
| `/dev-stack:hotfix` | Emergency | code-writer | Basic |
| `/dev-stack:plan` | Analysis | code-analyzer + researcher | serena, context7 |
| `/dev-stack:refactor` | Code improvement | code-analyzer + code-writer | serena |
| `/dev-stack:security` | Security | security-scanner + code-writer | serena |
| `/dev-stack:git` | Git ops | git-operator | Bash (git) |
| `/dev-stack:research` | Research | researcher | context7, web_reader |
| `/dev-stack:docs` | Documentation | doc-writer | doc-forge, filesystem |
| `/dev-stack:data` | Database | data-engineer | serena, Bash |
| `/dev-stack:quality` | Quality | qa-validator + security-scanner | serena, Bash |
| `/dev-stack:resume` | Session | orchestrator + memory-keeper | memory |

---

## Skills Reference

### Internal Libraries (8 skills)

| Skill | Purpose | New in v10 |
|-------|---------|------------|
| `lib-orchestration` | Intent classification, capability mapping, team assembly, memory protocol | ✅ |
| `orchestration` | MODE routing, team dispatch | |
| `lib-router` | Tool mapping | |
| `lib-workflow` | Workflow classification | |
| `lib-domain` | DDD modeling, BDD authoring | |
| `lib-tdd` | TDD cycle | |
| `lib-intelligence` | Snapshot, drift, impact | |

---

## Shared Memory Protocol

### Entity Types

```yaml
TaskContext:
  name: "task_{timestamp}"
  entityType: "TaskContext"
  observations:
    - "Intent: {classified_intent}"
    - "Original request: {user_input}"
    - "[agent_name] [action] {details}"
  relations:
    - "depends_on: {other_task}"
```

### Memory Operations

```javascript
// Create task context
mcp__memory__create_entities({
  "entities": [{
    "name": "task_20260301_fix_login",
    "entityType": "TaskContext",
    "observations": ["Intent: bug_fix", "Original request: fix login bug"]
  }]
})

// Add agent findings
mcp__memory__add_observations({
  "observations": [{
    "entityName": "task_20260301_fix_login",
    "contents": [
      "[code-analyzer] [root_cause] Email validation regex too strict",
      "[code-writer] [fix_applied] Updated regex pattern"
    ]
  }]
})

// Read context
mcp__memory__open_nodes({
  "names": ["task_20260301_fix_login"]
})
```

---

## Tool Priority

### Priority Hierarchy

```
1️⃣ MCP SERVERS (Primary)
   ├─ serena: Symbol-aware code operations
   ├─ memory: Knowledge graph
   ├─ context7: Library documentation
   ├─ filesystem: File operations
   ├─ doc-forge: Document processing
   └─ web_reader: URL analysis

2️⃣ PLUGIN TOOLS (Secondary)
   └─ superpowers: TDD, debugging, etc.

3️⃣ SKILL TOOLS (Tertiary)
   └─ dev-stack skills

4️⃣ BUILT-IN (Fallback)
   ├─ Read, Write, Edit
   ├─ Glob, Grep
   └─ Bash
```

### Tool Selection Example

```yaml
code_read:
  primary: mcp__serena__find_symbol    # Try first
  fallback: Read                        # If serena unavailable

code_edit:
  primary: mcp__serena__replace_symbol_body
  fallback: Edit

web_research:
  primary: mcp__context7__query-docs
  secondary: mcp__web_reader__webReader
  tertiary: WebSearch
```

---

## Git Safety Policy

### Auto-Allowed (Read-Only)

```bash
git status
git diff
git log
git branch
git show
git reflog
git ls-files
```

### Requires User Confirmation

```bash
git commit          # ⚠️ ASK before executing
git push            # ⚠️ ASK before executing
git reset --hard    # ⚠️ ASK before executing
git commit --amend  # ⚠️ ASK before executing
git push --force    # ⚠️ ASK before executing
```

### PreToolUse Hook

```bash
# In hooks/scripts/pre-tool-guard.sh
if [[ "$tool" == "Bash" && "$command" =~ git\ (commit|push) ]]; then
  echo "⚠️ Git operation requires confirmation"
  exit 1  # Block until user confirms
fi
```

---

## Configuration

### Project Structure

```
.specify/
├── memory/                      # Shared memory fallback (v10)
│   ├── index.json
│   └── task_*.json
├── specs/
│   └── 001-feature-name/
│       ├── spec.md
│       ├── plan.md
│       └── tasks.md
└── adr/                         # Architecture Decision Records
```

---

## MCP Integration

### Required MCP Servers

| Server | Tools | Purpose |
|--------|-------|---------|
| `serena` | 26+ | Symbol-aware code operations |
| `memory` | 9 | Knowledge graph for coordination |
| `sequentialthinking` | 1 | Semantic analysis |

### Optional MCP Servers

| Server | Tools | Purpose |
|--------|-------|---------|
| `context7` | 2 | Library documentation |
| `filesystem` | 15 | Advanced file operations |
| `doc-forge` | 16 | Document processing |
| `web_reader` | 1 | URL analysis |
| `fetch` | 1 | Web content |

---

## Version History

| Version | Date | Key Changes |
|---------|------|-------------|
| **10.0.0** | 2026-03-01 | **Tool-Based Architecture**: 12 specialized agents, shared memory, dynamic teams, tool priority |
| 9.0.0 | 2026-03-01 | Hybrid Architecture: 145 tools, 12 agents |
| 8.0.0 | 2026-03-01 | 11 unified commands |
| 7.0.0 | 2026-03-01 | Major rewrite, 11 agents |

---

*Last updated: 2026-03-01*
*Plugin version: 10.0.0*
