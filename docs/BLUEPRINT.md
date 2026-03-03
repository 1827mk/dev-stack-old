# dev-stack v10.0.0 — Complete Blueprint

> **วัตถุประสงค์**: เอกสารพิมพ์เขียวสำหรับการสร้าง dev-stack ใหม่ทั้งหมด
>
> **Version**: 10.0.0 | **Date**: 2026-03-02

---

## 📋 Table of Contents

1. [Overview](#1-overview)
2. [Architecture Design](#2-architecture-design)
3. [File Structure](#3-file-structure)
4. [Plugin Manifest](#4-plugin-manifest)
5. [Agent Definitions](#5-agent-definitions)
6. [Command Definitions](#6-command-definitions)
7. [Skill Definitions](#7-skill-definitions)
8. [Hook Configurations](#8-hook-configurations)
9. [Shared Memory Protocol](#9-shared-memory-protocol)
10. [Tool Priority System](#10-tool-priority-system)
11. [Implementation Checklist](#11-implementation-checklist)

---

## 1. Overview

### 1.1 Purpose

dev-stack เป็น orchestration plugin สำหรับ Claude Code ที่ใช้ **Tool-Based Agent Architecture** เพื่อ:

- วิเคราะห์ task จากผู้ใช้
- จับคู่ task กับ capabilities ที่ต้องการ
- ประกอบทีม agents แบบ dynamic
- ประมวลผลแบบ parallel (38-75% faster)
- แชร์ memory ระหว่าง agents

### 1.2 Key Features

| Feature | Description |
|---------|-------------|
| **Capability-based Selection** | เลือก agents ตาม task requirements ไม่ใช่ fixed workflow |
| **Parallel Execution** | ประมวลผล agents แบบ parallel ตาม dependency levels |
| **Shared Memory** | ใช้ MCP memory เป็นหลัก มี file-based fallback |
| **Tool Priority** | MCP > Plugins > Skills > Built-in |
| **Git Safety** | ต้อง confirm ก่อน commit/push |
| **DDD/TDD/BDD/SDD** | รองรับทุก development methodology |

### 1.3 Stats

| Metric | Count |
|--------|-------|
| Agents | 12 |
| Commands | 16 |
| Skills | 8 |
| Hooks | 6 |
| MCP Tools | 72 |
| Built-in Tools | 22 |
| **Total Tools** | **145+** |

---

## 2. Architecture Design

### 2.1 High-Level Architecture

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
│   │  │ 1. Capability Detection          │    │                   │
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
│   │  Level 0 (Parallel): [code-analyzer, security-scanner]    │  │
│   │           │                                               │  │
│   │           ▼ sync_to_memory()                              │  │
│   │                                                           │  │
│   │  Level 1 (Sequential): [code-writer]                      │  │
│   │           │                                               │  │
│   │           ▼ sync_to_memory()                              │  │
│   │                                                           │  │
│   │  Level 2 (Sequential): [qa-validator]                     │  │
│   └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│   ┌─────────────────────────────────────────┐                   │
│   │         TOOL LAYER (145+ tools)          │                   │
│   │  Priority: MCP > Plugins > Skills > Built│                   │
│   └─────────────────────────────────────────┘                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Dependency Levels

```yaml
Level 0 - Independent (Run first, parallel):
  - code-analyzer: Analyze code structure
  - security-scanner: Scan for vulnerabilities
  - researcher: Research solutions
  - file-manager: Prepare file structure
  - memory-keeper: Initialize memory context

Level 1 - Depends on Level 0:
  - code-writer: Write code (needs analysis)
  - task-planner: Create detailed plan (needs analysis)
  - data-engineer: Database changes (needs analysis)
  - doc-writer: Write docs (needs research/analysis)

Level 2 - Depends on Level 1:
  - qa-validator: Test implementation (needs code-writer)
  - git-operator: Commit changes (needs qa-validator)
```

### 2.3 Data Flow

```
1. ANALYZE_REQUIREMENTS (capability-matcher.md)
   └─ Detect capabilities, confidence scores, required agents

2. CLASSIFY_INTENT (intent-classification.md)
   └─ Determine task type: bug_fix, new_feature, refactor, etc.

3. MAP_CAPABILITIES (capability-mapping.md)
   └─ Map intent to required/optional capabilities

4. ASSEMBLE_TEAM (team-assembly.md)
   └─ Select agents, group by dependency levels

5. INIT_MEMORY (memory-protocol.md)
   └─ Create TaskContext entity in MCP memory

6. EXECUTE_PARALLEL (parallel-executor.md)
   └─ Run Level 0 parallel → sync → Level 1 → sync → Level 2

7. AGGREGATE_RESULTS
   └─ Combine findings, return summary
```

---

## 3. File Structure

```
plugins/dev-stack/
│
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest
│
├── README.md                    # Technical documentation
│
├── agents/                      # 12 Agent Definitions
│   ├── orchestrator.md
│   ├── memory-keeper.md
│   ├── code-analyzer.md
│   ├── code-writer.md
│   ├── qa-validator.md
│   ├── security-scanner.md
│   ├── researcher.md
│   ├── doc-writer.md
│   ├── git-operator.md
│   ├── file-manager.md
│   ├── task-planner.md
│   └── data-engineer.md
│
├── commands/                    # 16 Command Definitions
│   ├── agents.md                # Master orchestrator command
│   ├── bug.md
│   ├── feature.md
│   ├── hotfix.md
│   ├── plan.md
│   ├── refactor.md
│   ├── security.md
│   ├── git.md
│   ├── info.md
│   ├── quality.md
│   ├── session.md
│   ├── resume.md
│   ├── research.md
│   ├── docs.md
│   ├── data.md
│   └── init.md
│
├── hooks/
│   ├── hooks.json               # Hook registration
│   ├── prompts/                 # Prompt-based hooks
│   │   ├── verify-agent-done.md
│   │   └── checkpoint-reminder.md
│   └── scripts/                 # Shell script hooks
│       ├── session-start.sh
│       ├── status-line.sh
│       ├── auto-router.sh
│       ├── pre-tool-guard.sh
│       ├── notify.sh
│       ├── pre-commit.sh
│       └── shared-memory-init.sh
│
└── skills/                      # 8 Skills
    ├── lib-orchestration/
    │   ├── SKILL.md
    │   └── references/
    │       ├── capability-matcher.md
    │       ├── parallel-executor.md
    │       ├── intent-classification.md
    │       ├── capability-mapping.md
    │       ├── team-assembly.md
    │       └── memory-protocol.md
    ├── orchestration/
    │   ├── SKILL.md
    │   └── references/
    │       ├── routing.md
    │       ├── boot-sequences.md
    │       ├── team-messaging.md
    │       └── output-formats.md
    ├── lib-router/
    │   └── SKILL.md
    ├── lib-workflow/
    │   ├── SKILL.md
    │   └── references/
    │       ├── gates.md
    │       └── workflow-map.md
    ├── lib-domain/
    │   ├── SKILL.md
    │   └── references/
    │       ├── ddd-modeling.md
    │       └── bdd-authoring.md
    ├── lib-tdd/
    │   ├── SKILL.md
    │   └── references/
    │       ├── tdd-cycle.md
    │       └── constitution-builder.md
    ├── lib-intelligence/
    │   ├── SKILL.md
    │   └── references/
    │       ├── snapshot.md
    │       ├── drift.md
    │       ├── impact.md
    │       ├── dependency.md
    │       └── memory-sync.md
    └── lib-testing/
        └── SKILL.md
```

---

## 4. Plugin Manifest

### 4.1 plugin.json

```json
{
  "name": "dev-stack",
  "version": "10.0.0",
  "description": "Tool-Based Agent Architecture — 12 specialized agents with 145+ MCP tools, dynamic team assembly, shared memory protocol. /dev-stack:agents <task> auto-routes to best team",
  "author": { "name": "dev-stack" },
  "keywords": [
    "orchestration",
    "tool-based-agents",
    "dynamic-team",
    "shared-memory",
    "tdd",
    "bdd",
    "ddd",
    "automation",
    "owasp",
    "security",
    "mcp-tools",
    "serena",
    "memory-protocol"
  ]
}
```

---

## 5. Agent Definitions

### 5.1 Agent Template

```markdown
---
model: sonnet|haiku
color: string
tools: [tool1, tool2, ...]
---

# Agent Name

Role description

## Tools

- tool1: purpose
- tool2: purpose

## Responsibilities

1. Task 1
2. Task 2

## Dependency Level

- Level X: Explanation

## Integration

How this agent integrates with others
```

### 5.2 All Agents (12)

| # | Agent | Model | Level | Primary Tools |
|---|-------|-------|-------|---------------|
| 1 | orchestrator | sonnet | Core | mcp__memory__*, mcp__sequentialthinking__*, Task |
| 2 | memory-keeper | haiku | 0 | mcp__memory__*, mcp__serena__*_memory |
| 3 | code-analyzer | sonnet | 0 | mcp__serena__find_symbol, find_referencing_symbols |
| 4 | code-writer | sonnet | 1 | mcp__serena__replace_symbol_body, mcp__context7__* |
| 5 | qa-validator | sonnet | 2 | Bash (tests), mcp__serena__think_* |
| 6 | security-scanner | sonnet | 0 | mcp__serena__search_for_pattern |
| 7 | researcher | sonnet | 0 | mcp__context7__*, mcp__web_reader__*, WebSearch |
| 8 | doc-writer | sonnet | 2 | mcp__doc-forge__*, mcp__filesystem__* |
| 9 | git-operator | sonnet | 2 | Bash (git), Read |
| 10 | file-manager | sonnet | 0 | mcp__filesystem__* (all 15) |
| 11 | task-planner | sonnet | 0 | mcp__sequentialthinking__*, TaskCreate |
| 12 | data-engineer | sonnet | 1 | mcp__serena__*, Bash (migrations) |

### 5.3 Agent Details

#### orchestrator.md

```yaml
Role: Master Orchestrator
Model: sonnet
Color: cyan
Tools:
  - Read, Glob, Grep
  - Task (for spawning agents)
  - mcp__memory__create_entities
  - mcp__memory__add_observations
  - mcp__memory__open_nodes
  - mcp__memory__search_nodes
  - mcp__sequentialthinking__sequentialthinking

Responsibilities:
  1. Analyze user request (capability detection)
  2. Classify intent (bug_fix, new_feature, etc.)
  3. Map capabilities to agents
  4. Assemble team with dependency levels
  5. Initialize shared memory
  6. Execute agents by level (parallel)
  7. Aggregate results

Tool Priority: MCP > Plugins > Skills > Built-in
```

#### memory-keeper.md

```yaml
Role: Memory Coordinator
Model: haiku
Color: gray
Tools:
  - Read, Write
  - mcp__memory__create_entities
  - mcp__memory__create_relations
  - mcp__memory__add_observations
  - mcp__memory__open_nodes
  - mcp__memory__search_nodes
  - mcp__memory__read_graph
  - mcp__serena__write_memory
  - mcp__serena__read_memory
  - mcp__serena__list_memories

Responsibilities:
  1. Create TaskContext entities
  2. Add agent findings as observations
  3. Query memory for coordination
  4. Fallback to file-based storage if MCP unavailable

Dependency Level: 0 (runs first, always)
```

#### code-analyzer.md

```yaml
Role: Code Analysis Specialist
Model: sonnet
Color: blue
Tools:
  - Read, Glob, Grep
  - mcp__serena__find_symbol
  - mcp__serena__find_referencing_symbols
  - mcp__serena__get_symbols_overview
  - mcp__serena__search_for_pattern
  - mcp__memory__add_observations

Responsibilities:
  1. Find symbols (classes, methods, functions)
  2. Find references to symbols
  3. Get symbol overview
  4. Search for patterns
  5. Write findings to shared memory

Dependency Level: 0 (independent)
```

#### code-writer.md

```yaml
Role: TDD Implementation Specialist
Model: sonnet
Color: green
Tools:
  - Read, Write, Edit, Bash
  - mcp__serena__replace_symbol_body
  - mcp__serena__insert_after_symbol
  - mcp__serena__insert_before_symbol
  - mcp__serena__rename_symbol
  - mcp__context7__resolve-library-id
  - mcp__context7__query-docs
  - mcp__memory__add_observations

Responsibilities:
  1. Follow TDD RED-GREEN-REFACTOR cycle
  2. Write failing test first
  3. Minimal implementation to pass
  4. Refactor for quality
  5. Use serena for symbol editing
  6. Write changes to shared memory

Dependency Level: 1 (needs analysis from Level 0)
```

#### qa-validator.md

```yaml
Role: Quality Assurance Specialist
Model: sonnet
Color: yellow
Tools:
  - Read, Glob, Grep, Bash
  - mcp__serena__think_about_whether_you_are_done
  - mcp__serena__think_about_collected_information
  - mcp__memory__add_observations

Responsibilities:
  1. Execute test suites
  2. Verify coverage >= 80%
  3. Validate BDD scenarios
  4. Run quality gates
  5. Write results to shared memory

Dependency Level: 2 (needs code from Level 1)
```

#### security-scanner.md

```yaml
Role: Security Analysis Specialist
Model: sonnet
Color: red
Tools:
  - Read, Glob, Grep
  - mcp__serena__search_for_pattern
  - mcp__memory__add_observations

Responsibilities:
  1. OWASP Top 10 detection
  2. Injection pattern detection
  3. Crypto failure detection
  4. Auth issue detection
  5. Write findings to shared memory

Dependency Level: 0 (independent, runs parallel with code-analyzer)
```

#### researcher.md

```yaml
Role: Research Specialist
Model: sonnet
Color: purple
Tools:
  - WebSearch
  - mcp__context7__resolve-library-id
  - mcp__context7__query-docs
  - mcp__web_reader__webReader
  - mcp__fetch__fetch
  - mcp__doc-forge__document_reader
  - mcp__memory__add_observations

Responsibilities:
  1. Library documentation lookup (context7)
  2. Web search for solutions
  3. URL analysis
  4. Document reading
  5. Write findings to shared memory

Dependency Level: 0 (independent)
```

#### doc-writer.md

```yaml
Role: Documentation Specialist
Model: sonnet
Color: teal
Tools:
  - Read, Write
  - mcp__filesystem__write_file
  - mcp__filesystem__read_text_file
  - mcp__filesystem__edit_file
  - mcp__doc-forge__document_reader
  - mcp__doc-forge__docx_to_html
  - mcp__doc-forge__docx_to_pdf
  - mcp__doc-forge__format_convert
  - mcp__doc-forge__html_to_markdown
  - mcp__memory__add_observations

Responsibilities:
  1. Write markdown docs
  2. PDF generation
  3. Format conversion
  4. Write artifacts to shared memory

Dependency Level: 2 (needs context from Level 0/1)
```

#### git-operator.md

```yaml
Role: Git Operations Specialist
Model: sonnet
Color: orange
Tools:
  - Read, Bash
  - mcp__serena__search_for_pattern
  - mcp__serena__find_file
  - mcp__memory__add_observations

Safety:
  - Read-only: auto-allowed (status, diff, log, branch, show)
  - Write: requires user confirmation (commit, push, reset --hard)

Responsibilities:
  1. Git status, diff, log
  2. PR generation
  3. Impact analysis
  4. Write results to shared memory

Dependency Level: 2 (needs qa approval)
```

#### file-manager.md

```yaml
Role: File Operations Specialist
Model: sonnet
Color: indigo
Tools:
  - Read, Write, Edit
  - mcp__filesystem__create_directory
  - mcp__filesystem__directory_tree
  - mcp__filesystem__edit_file
  - mcp__filesystem__get_file_info
  - mcp__filesystem__list_directory
  - mcp__filesystem__list_directory_with_sizes
  - mcp__filesystem__move_file
  - mcp__filesystem__read_text_file
  - mcp__filesystem__read_media_file
  - mcp__filesystem__read_multiple_files
  - mcp__filesystem__search_files
  - mcp__filesystem__write_file
  - mcp__memory__add_observations

Responsibilities:
  1. Create/move/delete files
  2. Directory tree operations
  3. Search files by pattern
  4. Read media files
  5. Write results to shared memory

Dependency Level: 0 (independent)
```

#### task-planner.md

```yaml
Role: Task Planning Specialist
Model: sonnet
Color: amber
Tools:
  - Read, Write
  - mcp__sequentialthinking__sequentialthinking
  - TaskCreate
  - TaskGet
  - TaskUpdate
  - TaskList
  - mcp__memory__add_observations

Responsibilities:
  1. Decompose tasks using sequential thinking
  2. Create atomic tasks with dependencies
  3. Write plan to shared memory

Dependency Level: 0 (independent)
```

#### data-engineer.md

```yaml
Role: Database Operations Specialist
Model: sonnet
Color: lime
Tools:
  - Read, Write, Edit, Bash
  - mcp__serena__find_symbol
  - mcp__serena__search_for_pattern
  - mcp__serena__find_file
  - mcp__memory__add_observations

Responsibilities:
  1. Schema design
  2. Migrations
  3. Query optimization
  4. ETL pipelines
  5. Write results to shared memory

Dependency Level: 1 (needs analysis from Level 0)
```

---

## 6. Command Definitions

### 6.1 Command Template

```markdown
---
description: Command description shown in menu
---

# /dev-stack:command

Brief description

## Scope

- Allowed agents: [agent1, agent2]
- Team: description

## Workflow

Step-by-step instructions

## Examples

Usage examples
```

### 6.2 All Commands (16)

| # | Command | Scope | Team | Description |
|---|---------|-------|------|-------------|
| 1 | `/dev-stack:agents` | All | Dynamic | Master orchestrator |
| 2 | `/dev-stack:bug` | Bug fix | analyzer + writer + qa | Bug fix workflow |
| 3 | `/dev-stack:feature` | Feature | Full team | New feature with DDD/BDD |
| 4 | `/dev-stack:hotfix` | Emergency | analyzer + writer | Bypasses gates |
| 5 | `/dev-stack:plan` | Analysis | analyzer + researcher | Read-only analysis |
| 6 | `/dev-stack:refactor` | Refactor | analyzer + writer + qa | Code improvement |
| 7 | `/dev-stack:security` | Security | scanner + analyzer + writer | OWASP patches |
| 8 | `/dev-stack:git` | Git | git-operator | Git operations |
| 9 | `/dev-stack:info` | Info | researcher | ADR, help, status |
| 10 | `/dev-stack:quality` | Quality | qa + scanner | Audit, check, review |
| 11 | `/dev-stack:session` | Session | memory-keeper | Resume, retro |
| 12 | `/dev-stack:resume` | Resume | orchestrator + memory-keeper | Resume task |
| 13 | `/dev-stack:research` | Research | researcher + doc-writer | Docs, API, explain |
| 14 | `/dev-stack:docs` | Docs | doc-writer + researcher | Documentation |
| 15 | `/dev-stack:data` | Database | data-engineer | Migrations, schema |
| 16 | `/dev-stack:init` | Init | Full team | Project initialization |

### 6.3 Master Command: agents.md

```markdown
---
description: 🚀 Smart entry — auto-routes to best workflow with dynamic team assembly (v10.0.0)
---

# dev-stack:agents

## Behavior

IF INPUT IS EMPTY:
  Show menu with all commands and features

IF INPUT PROVIDED:
  Execute orchestration

## Orchestration Steps

### Step 1: Load Orchestration Skill
Load: skill:lib-orchestration

### Step 2: Analyze Requirements & Capabilities
From references/capability-matcher.md

### Step 3: Classify Intent
From references/intent-classification.md

### Step 4: Assemble Team with Dependency Levels
From references/team-assembly.md and parallel-executor.md

### Step 5: Initialize Memory
From references/memory-protocol.md

### Step 6: Spawn Agents (Parallel Execution)
From references/parallel-executor.md

### Step 7: Aggregate Results

## Team Templates by Intent (with Dependency Levels)

| Intent | Level 0 | Level 1 | Level 2 |
|--------|---------|---------|---------|
| bug_fix | memory-keeper, code-analyzer | code-writer | qa-validator |
| new_feature | memory-keeper, task-planner, researcher, code-analyzer | code-writer | qa-validator, doc-writer |
| security | memory-keeper, security-scanner, code-analyzer | code-writer | qa-validator |
| hotfix | memory-keeper, code-analyzer | code-writer | - |
| refactor | memory-keeper, code-analyzer | code-writer | qa-validator |
| research | memory-keeper, researcher | doc-writer | - |

## Git Safety Policy

⚠️ commit/push require user confirmation!

## Output Format

FORMATION and DELIVERY boxes
```

---

## 7. Skill Definitions

### 7.1 Skill Template

```markdown
---
disable-model-invocation: false
user-invokable: false|true
name: skill-name
description: "Skill description"
---

# Skill Name

## Overview

Purpose and scope

## Available Functions

| Function | Reference | Description |
|----------|-----------|-------------|
| `#func1` | references/file.md | Description |

## Workflow

Diagram or description

## Usage Example

Code example
```

### 7.2 All Skills (8)

| # | Skill | Purpose | References |
|---|-------|---------|------------|
| 1 | `lib-orchestration` | Core orchestration (v10) | capability-matcher, parallel-executor, intent-classification, capability-mapping, team-assembly, memory-protocol |
| 2 | `orchestration` | MODE routing, team dispatch | routing, boot-sequences, team-messaging, output-formats |
| 3 | `lib-router` | Tool mapping | - |
| 4 | `lib-workflow` | Workflow classification | gates, workflow-map |
| 5 | `lib-domain` | DDD/BDD patterns | ddd-modeling, bdd-authoring |
| 6 | `lib-tdd` | TDD cycle | tdd-cycle, constitution-builder |
| 7 | `lib-intelligence` | Snapshot, drift, impact | snapshot, drift, impact, dependency, memory-sync |
| 8 | `lib-testing` | Test strategies | - |

### 7.3 Core Skill: lib-orchestration

```markdown
---
disable-model-invocation: false
user-invokable: false
name: lib-orchestration
description: "Orchestration library for dev-stack v10.0.0"
---

# lib-orchestration Skill

## Overview

- Capability Matching
- Parallel Execution (38-75% faster)
- Intent Classification
- Team Assembly with Dependency Levels
- Memory Protocol

## Available Functions

| Function | Reference |
|----------|-----------|
| `#analyze_requirements` | capability-matcher.md |
| `#classify_intent` | intent-classification.md |
| `#map_capabilities` | capability-mapping.md |
| `#assemble_team` | team-assembly.md |
| `#execute_parallel` | parallel-executor.md |
| `#init_memory` | memory-protocol.md |
| `#write_observation` | memory-protocol.md |
| `#read_context` | memory-protocol.md |

## Tool Priority

1️⃣ MCP SERVERS > 2️⃣ PLUGINS > 3️⃣ SKILLS > 4️⃣ BUILT-IN

## Performance Gains

| Mode | Time | Speedup |
|------|------|---------|
| Sequential | 4x | Baseline |
| Phase-based | 2.5x | 38% faster |
| Full Parallel | 1x | 75% faster |
```

---

## 8. Hook Configurations

### 8.1 hooks.json

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|resume|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/session-start.sh",
            "timeout": 10
          },
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/status-line.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/auto-router.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Bash|Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/pre-tool-guard.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/status-line.sh",
            "timeout": 3
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "gate_pass|gate_fail|workflow_complete|escalation|phase_complete",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/notify.sh",
            "timeout": 5
          }
        ]
      }
    ],
    "PreCommit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/pre-commit.sh",
            "timeout": 60
          }
        ]
      }
    ]
  }
}
```

### 8.2 Hook Scripts

| Script | Trigger | Purpose |
|--------|---------|---------|
| `session-start.sh` | SessionStart | Initialize session state |
| `status-line.sh` | SessionStart, PostToolUse | Update status line |
| `auto-router.sh` | UserPromptSubmit | Route to appropriate workflow |
| `pre-tool-guard.sh` | PreToolUse (Bash/Write/Edit) | Git safety check |
| `notify.sh` | Notification | Send notifications |
| `pre-commit.sh` | PreCommit | Run quality checks |
| `shared-memory-init.sh` | SessionStart | Initialize shared memory |

---

## 9. Shared Memory Protocol

### 9.1 Entity Types

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

AgentFinding:
  name: "{agent_name}_findings"
  entityType: "AgentFinding"
  observations:
    - "[timestamp] {finding}"
```

### 9.2 Memory Operations

```javascript
// Create task context
mcp__memory__create_entities({
  "entities": [{
    "name": "task_20260302_fix_login",
    "entityType": "TaskContext",
    "observations": [
      "Intent: bug_fix",
      "Original request: fix login bug in auth.ts"
    ]
  }]
})

// Add agent findings
mcp__memory__add_observations({
  "observations": [{
    "entityName": "task_20260302_fix_login",
    "contents": [
      "[code-analyzer] [root_cause] Email validation regex too strict",
      "[code-writer] [fix_applied] Updated regex pattern"
    ]
  }]
})

// Read context
mcp__memory__open_nodes({
  "names": ["task_20260302_fix_login"]
})

// Search nodes
mcp__memory__search_nodes({
  "query": "bug_fix"
})
```

### 9.3 Fallback

```yaml
IF MCP memory unavailable:
  Fallback: Write to .specify/memory/{task_id}.json

Format:
  {
    "task_id": "task_20260302_fix_login",
    "intent": "bug_fix",
    "request": "fix login bug",
    "findings": [
      {"agent": "code-analyzer", "content": "..."},
      {"agent": "code-writer", "content": "..."}
    ]
  }
```

---

## 10. Tool Priority System

### 10.1 Priority Hierarchy

```
1️⃣ MCP SERVERS (Primary - Highest Quality)
   ├─ serena: Symbol-aware code operations (26 tools)
   ├─ memory: Knowledge graph (9 tools)
   ├─ context7: Library documentation (2 tools)
   ├─ filesystem: File operations (15 tools)
   ├─ doc-forge: Document processing (16 tools)
   ├─ web_reader: URL analysis (1 tool)
   ├─ fetch: Web content (1 tool)
   └─ sequentialthinking: Planning (1 tool)

2️⃣ PLUGIN TOOLS (Secondary)
   ├─ superpowers: TDD, debugging, brainstorming
   └─ speckit: SDD workflow

3️⃣ SKILL TOOLS (Tertiary)
   └─ dev-stack skills

4️⃣ BUILT-IN (Fallback - Lowest Priority)
   ├─ Read, Write, Edit
   ├─ Glob, Grep
   └─ Bash
```

### 10.2 Tool Selection Logic

```yaml
code_read:
  primary: mcp__serena__find_symbol
  fallback: Read

code_edit:
  primary: mcp__serena__replace_symbol_body
  fallback: Edit

file_write:
  primary: mcp__filesystem__write_file
  fallback: Write

research:
  primary: mcp__context7__query-docs
  secondary: mcp__web_reader__webReader
  tertiary: WebSearch

documentation:
  primary: mcp__doc-forge__*
  fallback: Write

memory:
  primary: mcp__memory__*
  fallback: file-based .specify/memory/
```

### 10.3 Quality > Speed

```yaml
Principle: Always prioritize quality over speed

Examples:
  - Use serena for code analysis (slower but more accurate)
  - Use context7 for library docs (up-to-date)
  - Run full test suite even if quick check passes
  - Never skip security scan for speed
```

---

## 11. Implementation Checklist

### Phase 1: Plugin Structure

- [ ] Create directory structure
- [ ] Create plugin.json manifest
- [ ] Create README.md

### Phase 2: Core Skills

- [ ] Create lib-orchestration/SKILL.md
- [ ] Create capability-matcher.md
- [ ] Create parallel-executor.md
- [ ] Create intent-classification.md
- [ ] Create capability-mapping.md
- [ ] Create team-assembly.md
- [ ] Create memory-protocol.md

### Phase 3: Agents

- [ ] Create orchestrator.md
- [ ] Create memory-keeper.md
- [ ] Create code-analyzer.md
- [ ] Create code-writer.md
- [ ] Create qa-validator.md
- [ ] Create security-scanner.md
- [ ] Create researcher.md
- [ ] Create doc-writer.md
- [ ] Create git-operator.md
- [ ] Create file-manager.md
- [ ] Create task-planner.md
- [ ] Create data-engineer.md

### Phase 4: Commands

- [ ] Create agents.md (master command)
- [ ] Create bug.md
- [ ] Create feature.md
- [ ] Create hotfix.md
- [ ] Create plan.md
- [ ] Create refactor.md
- [ ] Create security.md
- [ ] Create git.md
- [ ] Create info.md
- [ ] Create quality.md
- [ ] Create session.md
- [ ] Create resume.md
- [ ] Create research.md
- [ ] Create docs.md
- [ ] Create data.md
- [ ] Create init.md

### Phase 5: Hooks

- [ ] Create hooks.json
- [ ] Create session-start.sh
- [ ] Create status-line.sh
- [ ] Create auto-router.sh
- [ ] Create pre-tool-guard.sh
- [ ] Create notify.sh
- [ ] Create pre-commit.sh
- [ ] Create shared-memory-init.sh

### Phase 6: Supporting Skills

- [ ] Create orchestration/SKILL.md
- [ ] Create lib-router/SKILL.md
- [ ] Create lib-workflow/SKILL.md
- [ ] Create lib-domain/SKILL.md
- [ ] Create lib-tdd/SKILL.md
- [ ] Create lib-intelligence/SKILL.md
- [ ] Create lib-testing/SKILL.md

### Phase 7: Testing

- [ ] Test each agent individually
- [ ] Test parallel execution
- [ ] Test memory protocol
- [ ] Test git safety
- [ ] Test all commands

---

## Appendix A: MCP Tools Reference

### serena (26 tools)

| Tool | Purpose |
|------|---------|
| `activate_project` | Activate project by name/path |
| `check_onboarding_performed` | Check if onboarding was done |
| `find_file` | Find files matching pattern |
| `find_referencing_symbols` | Find symbols referencing a symbol |
| `find_symbol` | Find symbol (class, method, function) |
| `get_current_config` | Show current configuration |
| `get_symbols_overview` | Get overview of symbols in file |
| `initial_instructions` | Read Serena usage manual |
| `insert_after_symbol` | Insert code after symbol |
| `insert_before_symbol` | Insert code before symbol |
| `list_dir` | List directory contents |
| `list_memories` | List all memories |
| `onboarding` | Start project onboarding |
| `open_dashboard` | Open Serena web dashboard |
| `read_memory` | Read memory file |
| `rename_memory` | Rename memory file |
| `rename_symbol` | Rename symbol across codebase |
| `replace_symbol_body` | Replace symbol body |
| `search_for_pattern` | Search pattern in codebase |
| `think_about_collected_information` | Evaluate information completeness |
| `think_about_task_adherence` | Check if still on track |
| `think_about_whether_you_are_done` | Check if task is complete |
| `write_memory` | Write project memory |
| `delete_memory` | Delete memory file |
| `edit_memory` | Edit memory content |

### memory (9 tools)

| Tool | Purpose |
|------|---------|
| `add_observations` | Add observations to entities |
| `create_entities` | Create entities in knowledge graph |
| `create_relations` | Create relations between entities |
| `delete_entities` | Delete entities |
| `delete_observations` | Delete observations |
| `delete_relations` | Delete relations |
| `open_nodes` | Open nodes by name |
| `read_graph` | Read entire knowledge graph |
| `search_nodes` | Search nodes |

### filesystem (15 tools)

| Tool | Purpose |
|------|---------|
| `create_directory` | Create directory |
| `directory_tree` | Show directory tree as JSON |
| `edit_file` | Edit file (line-based) |
| `get_file_info` | Get file metadata |
| `list_allowed_directories` | List allowed directories |
| `list_directory` | List directory contents |
| `list_directory_with_sizes` | List directory with file sizes |
| `move_file` | Move or rename file |
| `read_file` | Read file (deprecated) |
| `read_media_file` | Read image/audio files |
| `read_multiple_files` | Read multiple files at once |
| `read_text_file` | Read text file |
| `search_files` | Search files with glob pattern |
| `write_file` | Write file |

### doc-forge (16 tools)

| Tool | Purpose |
|------|---------|
| `document_reader` | Read documents (PDF, DOCX, TXT, HTML, CSV) |
| `docx_to_html` | Convert DOCX to HTML |
| `docx_to_pdf` | Convert DOCX to PDF |
| `excel_read` | Read Excel to JSON |
| `format_convert` | Convert format |
| `html_cleaner` | Clean HTML |
| `html_extract_resources` | Extract resources from HTML |
| `html_formatter` | Format HTML |
| `html_to_markdown` | Convert HTML to markdown |
| `html_to_text` | Convert HTML to text |
| `pdf_merger` | Merge PDFs |
| `pdf_splitter` | Split PDF |
| `text_diff` | Compare text files |
| `text_encoding_converter` | Convert text encoding |
| `text_formatter` | Format text |
| `text_splitter` | Split text file |

### context7 (2 tools)

| Tool | Purpose |
|------|---------|
| `resolve-library-id` | Resolve library ID for documentation lookup |
| `query-docs` | Query library documentation |

### Other MCP Tools

| Server | Tools | Purpose |
|--------|-------|---------|
| web_reader | 1 | URL to markdown |
| fetch | 1 | Web content |
| sequentialthinking | 1 | Step-by-step thinking |
| 4_5v_mcp | 1 | AI vision analysis |

---

## Appendix B: Built-in Tools Reference

| Tool | Purpose |
|------|---------|
| `Task` | Launch specialized agent |
| `TaskOutput` | Get output from task |
| `Bash` | Execute bash commands |
| `Glob` | Find files by pattern |
| `Grep` | Search content in files |
| `Read` | Read files |
| `Edit` | Edit files |
| `Write` | Write files |
| `NotebookEdit` | Edit Jupyter notebook cells |
| `WebSearch` | Search the web |
| `TaskStop` | Stop background task |
| `AskUserQuestion` | Ask user questions |
| `Skill` | Invoke a skill |
| `EnterPlanMode` | Enter planning mode |
| `ExitPlanMode` | Exit planning mode |
| `TaskCreate` | Create task |
| `TaskGet` | Get task details |
| `TaskUpdate` | Update task status |
| `TaskList` | List all tasks |
| `ListMcpResourcesTool` | List MCP resources |
| `ReadMcpResourceTool` | Read MCP resource |
| `EnterWorktree` | Create git worktree |

---

*Blueprint Version: 1.0.0*
*Last Updated: 2026-03-02*
*dev-stack Version: 10.0.0*

<!-- claude --resume 606b536b-60b6-4a5b-aef4-edf20f1f0c7e -->