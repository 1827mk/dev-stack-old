# dev-stack v10.0.0 — Full Dynamic Orchestration Specification

> **Version**: 10.0.0
> **Status**: Draft
> **Created**: 2026-03-01
> **Author**: dev-stack team

---

## 1. Executive Summary

### 1.1 Problem Statement

Current dev-stack (v9.0.0) uses **workflow-based agents** where:
- Agents are designed around workflow steps (domain-analyst → architect → tech-lead → developer)
- Team composition is **fixed** per workflow type
- Not all 145 tools are utilized effectively
- No inter-agent communication mechanism

### 1.2 Proposed Solution

**Tool-Based Dynamic Orchestration**:
- Agents designed around **tool capabilities** (not workflow steps)
- **Full dynamic** team assembly based on task analysis
- **Shared memory** for inter-agent communication
- **145 tools** fully mapped to appropriate agents

### 1.3 Key Changes

| Aspect | v9.0.0 (Current) | v10.0.0 (Proposed) |
|--------|------------------|-------------------|
| Agent Design | Workflow-based | Tool-based |
| Team Assembly | Fixed templates | Full dynamic |
| Communication | None | Shared memory (MCP) |
| Tool Coverage | ~60% | 100% (145 tools) |
| Agents Count | 12 | 12 (redesigned) |

---

## 2. Architecture Overview

### 2.1 High-Level Design

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        dev-stack v10.0.0 ARCHITECTURE                        │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│                              USER INPUT                                      │
│                                  │                                          │
│                                  ▼                                          │
│                      ┌─────────────────────────────┐                        │
│                      │    MASTER ORCHESTRATOR      │                        │
│                      │         v10.0.0             │                        │
│                      │                             │                        │
│                      │  ┌───────────────────────┐  │                        │
│                      │  │ 1. Intent Classifier  │  │                        │
│                      │  │ 2. Capability Mapper  │  │                        │
│                      │  │ 3. Team Assembler     │  │                        │
│                      │  │ 4. Memory Coordinator │  │                        │
│                      │  └───────────────────────┘  │                        │
│                      └──────────────┬──────────────┘                        │
│                                     │                                       │
│                                     ▼                                       │
│                    ┌────────────────────────────────────┐                   │
│                    │        SHARED MEMORY LAYER          │                   │
│                    │   ┌─────────────────────────────┐   │                   │
│                    │   │      MCP memory (9 tools)   │   │                   │
│                    │   │  • create_entities          │   │                   │
│                    │   │  • create_relations         │   │                   │
│                    │   │  • add_observations         │   │                   │
│                    │   │  • search_nodes             │   │                   │
│                    │   │  • read_graph               │   │                   │
│                    │   │  • open_nodes               │   │                   │
│                    │   │  • delete_entities          │   │                   │
│                    │   │  • delete_observations      │   │                   │
│                    │   │  • delete_relations         │   │                   │
│                    │   └─────────────────────────────┘   │                   │
│                    │   ┌─────────────────────────────┐   │                   │
│                    │   │   Serena Memory (3 tools)   │   │                   │
│                    │   │  • write_memory             │   │                   │
│                    │   │  • read_memory              │   │                   │
│                    │   │  • list_memories            │   │                   │
│                    │   └─────────────────────────────┘   │                   │
│                    └────────────────────────────────────┘                   │
│                                     │                                       │
│           ┌─────────────────────────┼─────────────────────────┐            │
│           │                         │                         │            │
│           ▼                         ▼                         ▼            │
│    ┌─────────────┐           ┌─────────────┐           ┌─────────────┐    │
│    │ CODE        │           │ KNOWLEDGE   │           │ OPERATIONS  │    │
│    │ CLUSTER     │           │ CLUSTER     │           │ CLUSTER     │    │
│    ├─────────────┤           ├─────────────┤           ├─────────────┤    │
│    │• analyzer   │           │• researcher │           │• git-ops    │    │
│    │• writer     │           │• doc-writer │           │• file-mgr   │    │
│    │• qa-valid   │           │• memory-kpr │           │• data-eng   │    │
│    │• sec-scan   │           │• task-plan  │           │             │    │
│    └─────────────┘           └─────────────┘           └─────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 Design Principles

1. **Tool-First Design**: Agents are defined by their tool capabilities, not workflow position
2. **Dynamic Assembly**: Teams are assembled fresh for each task based on analysis
3. **Shared Memory**: All agents communicate through MCP memory layer
4. **Single Responsibility**: Each agent has one clear capability domain
5. **Loose Coupling**: Agents don't depend on each other directly

### 2.3 Tool Selection Priority

**CRITICAL**: เลือก tools ตามลำดับความสำคัญนี้เสมอ

```
┌─────────────────────────────────────────────────────────────────┐
│                   TOOL SELECTION PRIORITY                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   1️⃣  MCP SERVERS (Highest Priority)                            │
│       ├─ serena (26 tools) - Code analysis & editing            │
│       ├─ memory (9 tools) - Knowledge graph                     │
│       ├─ doc-forge (16 tools) - Document processing             │
│       ├─ filesystem (15 tools) - File operations                │
│       ├─ context7 (2 tools) - Library documentation             │
│       ├─ sequentialthinking (1 tool) - Step-by-step reasoning   │
│       ├─ web_reader (1 tool) - URL to markdown                  │
│       ├─ fetch (1 tool) - URL fetching                          │
│       └─ 4_5v_mcp (1 tool) - Image analysis                     │
│                       │                                         │
│                       ▼                                         │
│   2️⃣  PLUGINS                                                    │
│       ├─ dev-stack (this plugin)                                │
│       ├─ superpowers (14 skills, agents)                        │
│       ├─ spec-kit (SDD workflow)                                │
│       └─ plugin-dev (development tools)                         │
│                       │                                         │
│                       ▼                                         │
│   3️⃣  SKILLS                                                     │
│       ├─ superpowers:* (14 skills)                              │
│       ├─ speckit:* (9 skills)                                   │
│       ├─ plugin-dev:* (8 skills)                                │
│       └─ dev-stack:* (7 skills)                                 │
│                       │                                         │
│                       ▼                                         │
│   4️⃣  BUILT-IN TOOLS (Lowest Priority)                          │
│       ├─ Read, Write, Edit                                      │
│       ├─ Glob, Grep                                             │
│       ├─ Bash                                                   │
│       ├─ Task, TaskCreate, TaskUpdate                           │
│       └─ WebSearch                                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

Example Decision:
─────────────────
Task: Read a code file

❌ WRONG: Use Read (built-in)
✅ CORRECT: Use mcp__serena__find_symbol → mcp__serena__get_symbols_overview
✅ FALLBACK: Use mcp__filesystem__read_text_file
⚠️ LAST RESORT: Use Read (built-in)
```

### 2.4 Development Methodologies Integration

```
┌─────────────────────────────────────────────────────────────────┐
│                METHODOLOGY INTEGRATION                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │              DDD (Domain-Driven Design)                  │   │
│   │                                                         │   │
│   │  • Bounded Contexts → spec.md (domain-analyst)          │   │
│   │  • Ubiquitous Language → memory entities                │   │
│   │  • Aggregates → code structure (code-writer)            │   │
│   │  • Domain Events → BDD scenarios                        │   │
│   └─────────────────────────────────────────────────────────┘   │
│                           │                                     │
│                           ▼                                     │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │              BDD (Behavior-Driven Development)           │   │
│   │                                                         │   │
│   │  • User Stories → Given/When/Then scenarios             │   │
│   │  • Acceptance Criteria → test cases (qa-validator)      │   │
│   │  • Feature Files → spec.md BDD section                  │   │
│   │  • Scenario Coverage → 100% test mapping                │   │
│   └─────────────────────────────────────────────────────────┘   │
│                           │                                     │
│                           ▼                                     │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │              TDD (Test-Driven Development)               │   │
│   │                                                         │   │
│   │  • RED → Write failing test first (code-writer)         │   │
│   │  • GREEN → Minimal implementation (code-writer)         │   │
│   │  • REFACTOR → Clean code (code-writer)                  │   │
│   │  • Cycle → Repeat until feature complete                │   │
│   └─────────────────────────────────────────────────────────┘   │
│                           │                                     │
│                           ▼                                     │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │              SDD (Spec-Driven Development)               │   │
│   │                                                         │   │
│   │  • spec.md → Living specification                       │   │
│   │  • plan.md → Architecture & ADRs                        │   │
│   │  • tasks.md → Atomic task breakdown                     │   │
│   │  • Session Persistence → Resume anytime                 │   │
│   │  • Branch Switching → Context preserved                 │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 2.5 Spec-Driven Development (SDD) Integration

**เหตุผล**: บาง task ไม่สามารถจบในวันเดียว, ต้อง switch branch, หรือทำงานหลายอย่างพร้อมกัน

```
┌─────────────────────────────────────────────────────────────────┐
│                    SDD WORKFLOW LIFECYCLE                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌──────────┐     ┌──────────┐     ┌──────────┐               │
│   │  START   │────▶│   WORK   │────▶│  PAUSE   │               │
│   └──────────┘     └──────────┘     └──────────┘               │
│                         │              │                        │
│                         │              │                        │
│                         ▼              ▼                        │
│                    ┌──────────┐  ┌──────────┐                  │
│                    │  COMMIT  │  │  RESUME  │                  │
│                    │ PROGRESS │  │  LATER   │                  │
│                    └──────────┘  └──────────┘                  │
│                         │              │                        │
│                         │              │                        │
│   ┌─────────────────────┴──────────────┴─────────────────────┐ │
│   │                                                           │ │
│   │  PERSISTENCE LAYER (spec-kit + superpowers)               │ │
│   │                                                           │ │
│   │  .specify/                                                │ │
│   │  ├── spec.md          # Requirements + BDD scenarios      │ │
│   │  ├── plan.md          # Architecture + ADRs               │ │
│   │  ├── tasks.md         # Task breakdown with dependencies  │ │
│   │  ├── constitution.md  # Project rules & conventions       │ │
│   │  └── state.json       # Current progress & checkpoint     │ │
│   │                                                           │ │
│   │  Memory (MCP):                                            │ │
│   │  ├── TaskContext entities                                 │ │
│   │  ├── AgentFinding observations                            │ │
│   │  └── Decision entities                                    │ │
│   │                                                           │ │
│   └───────────────────────────────────────────────────────────┘ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 2.6 SDD vs Traditional Workflow

| Scenario | Traditional | SDD (spec-kit) |
|----------|-------------|----------------|
| **Task ไม่จบในวันเดียว** | สูญเสีย context | Resume จาก spec.md/tasks.md |
| **Switch branch** | ต้องจำเอง | state.json เก็บ progress |
| **ทำหลาย feature พร้อมกัน** | สับสน | แยก .specify/ ต่อ feature |
| **คนอื่นมาช่วย** | อธิบายใหม่ | spec.md คือ documentation |
| **Review งาน** | ดู code อย่างเดียว | เทียบกับ spec + BDD |

### 2.7 spec-kit vs superpowers Selection

```
┌─────────────────────────────────────────────────────────────────┐
│              WHEN TO USE WHAT?                                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                    USE spec-kit                          │    │
│  │                                                         │    │
│  │  ✅ Long-running features (ไม่จบในวันเดียว)              │    │
│  │  ✅ Complex requirements (DDD/BDD heavy)                │    │
│  │  ✅ Team collaboration (คนหลายคนทำ)                     │    │
│  │  ✅ Multi-session work (ต้อง resume)                    │    │
│  │  ✅ Formal documentation (ต้องมี spec/plan/tasks)        │    │
│  │  ✅ Architecture decisions (ต้องมี ADRs)                 │    │
│  │                                                         │    │
│  │  Commands:                                               │    │
│  │  • /speckit:specify <feature>                           │    │
│  │  • /speckit:plan                                        │    │
│  │  • /speckit:tasks                                       │    │
│  │  • /speckit:implement                                   │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                   USE superpowers                        │    │
│  │                                                         │    │
│  │  ✅ Quick fixes (จบใน session เดียว)                     │    │
│  │  ✅ Bug fixes (ไม่ต้องมี full spec)                       │    │
│  │  ✅ Simple refactoring (ไม่ซับซ้อน)                       │    │
│  │  ✅ Research tasks (ไม่ต้อง implement)                   │    │
│  │  ✅ Hot patches (urgent, bypass gates)                  │    │
│  │  ✅ TDD cycle (RED-GREEN-REFACTOR)                      │    │
│  │                                                         │    │
│  │  Commands:                                               │    │
│  │  • /superpowers:test-driven-development                 │    │
│  │  • /superpowers:systematic-debugging                    │    │
│  │  • /superpowers:brainstorming                           │    │
│  │  • /superpowers:executing-plans                         │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              HYBRID (Both Together)                      │    │
│  │                                                         │    │
│  │  ✅ Feature with complex spec → spec-kit for planning   │    │
│  │  ✅ Then TDD implementation → superpowers for coding    │    │
│  │  ✅ Code review → superpowers:requesting-code-review    │    │
│  │                                                         │    │
│  │  Flow:                                                   │    │
│  │  speckit:specify → speckit:plan → speckit:tasks →       │    │
│  │  superpowers:tdd → superpowers:review → done            │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. Agent Specifications

### 3.1 Master Orchestrator

**Name**: `orchestrator`
**Role**: Master coordinator, task analyzer, team assembler

#### Tools Available

```
Built-in:
├─ Read, Glob, Grep
├─ Task (spawn sub-agents)
├─ TaskCreate, TaskGet, TaskUpdate, TaskList
└─ AskUserQuestion

MCP Servers:
├─ mcp__memory__* (all 9 tools)
├─ mcp__sequentialthinking__sequentialthinking
└─ mcp__serena__*_memory* (3 tools)
```

#### Responsibilities

1. **Intent Classification**: Analyze user request to determine task type
2. **Capability Mapping**: Determine which tool capabilities are needed
3. **Team Assembly**: Dynamically select and spawn appropriate sub-agents
4. **Memory Coordination**: Create shared memory context for task
5. **Progress Monitoring**: Track agent progress via shared memory
6. **Result Aggregation**: Combine results from all sub-agents

#### Decision Matrix

| User Intent | Required Capabilities | Agents to Spawn |
|-------------|----------------------|-----------------|
| `bug`, `fix`, `error` | code_analysis, code_writing, testing | code-analyzer, code-writer, qa-validator |
| `feature`, `add`, `new` | research, planning, coding, testing, docs | researcher, task-planner, code-analyzer, code-writer, qa-validator, doc-writer |
| `security`, `vulnerability` | security_scan, code_writing, testing | security-scanner, code-writer, qa-validator |
| `refactor`, `improve` | code_analysis, code_writing, testing | code-analyzer, code-writer, qa-validator |
| `research`, `analyze` | research, documentation | researcher, doc-writer |
| `git`, `commit`, `push` | git_operations | git-operator |
| `document`, `doc`, `readme` | documentation | doc-writer |
| `test`, `testing` | testing, code_analysis | qa-validator, code-analyzer |
| `database`, `migration`, `schema` | data_operations | data-engineer |

---

### 3.2 Code Analyzer

**Name**: `code-analyzer`
**Role**: Code analysis, symbol lookup, pattern search

#### Tools Available

```
Built-in:
├─ Read, Glob, Grep

MCP Serena:
├─ mcp__serena__find_symbol
├─ mcp__serena__find_referencing_symbols
├─ mcp__serena__get_symbols_overview
├─ mcp__serena__search_for_pattern
├─ mcp__serena__list_dir
├─ mcp__serena__find_file
├─ mcp__serena__think_about_collected_information
└─ mcp__serena__check_onboarding_performed
```

#### Capabilities

| Capability | Description | Tool Used |
|------------|-------------|-----------|
| Symbol Search | Find classes, functions, variables | `find_symbol` |
| Reference Analysis | Find where symbols are used | `find_referencing_symbols` |
| File Overview | Get structure of code file | `get_symbols_overview` |
| Pattern Search | Search for code patterns | `search_for_pattern` |
| Dependency Mapping | Map code dependencies | `find_referencing_symbols` |
| Structure Analysis | Analyze code architecture | `get_symbols_overview` |

#### Output Format

```json
{
  "analysis_id": "analysis_001",
  "timestamp": "2026-03-01T10:00:00Z",
  "files_analyzed": ["src/auth/login.ts"],
  "symbols_found": [
    {
      "name": "LoginService",
      "type": "class",
      "location": "src/auth/login.ts:15",
      "references": ["src/controllers/auth.ts:45", "src/middleware/auth.ts:12"]
    }
  ],
  "patterns_detected": [
    {
      "pattern": "singleton",
      "location": "src/auth/login.ts:20",
      "confidence": 0.95
    }
  ],
  "recommendations": [
    "Consider extracting authentication logic to separate service"
  ]
}
```

---

### 3.3 Code Writer

**Name**: `code-writer`
**Role**: Code implementation, refactoring, TDD

#### Tools Available

```
Built-in:
├─ Read, Write, Edit
├─ Glob, Grep
└─ Bash (limited: test commands only)

MCP Serena:
├─ mcp__serena__replace_symbol_body
├─ mcp__serena__insert_after_symbol
├─ mcp__serena__insert_before_symbol
├─ mcp__serena__rename_symbol
├─ mcp__serena__find_symbol
└─ mcp__serena__get_symbols_overview

MCP Context7:
├─ mcp__context7__resolve-library-id
└─ mcp__context7__query-docs
```

#### Capabilities

| Capability | Description | Tool Used |
|------------|-------------|-----------|
| Symbol Replacement | Replace function/class body | `replace_symbol_body` |
| Code Insertion | Insert code before/after symbol | `insert_before/after_symbol` |
| Renaming | Rename symbol across codebase | `rename_symbol` |
| File Creation | Create new files | `Write` |
| File Editing | Edit existing files | `Edit` |
| API Documentation | Lookup library docs | `context7` |

#### TDD Workflow

```
┌─────────────────────────────────────────────────────────────┐
│                     TDD CYCLE                                │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌────────────┐     ┌────────────┐     ┌────────────┐     │
│   │    RED     │────▶│   GREEN    │────▶│  REFACTOR  │     │
│   │            │     │            │     │            │     │
│   │ Write      │     │ Minimal    │     │ Improve    │     │
│   │ failing    │     │ code to    │     │ code       │     │
│   │ test       │     │ pass       │     │ quality    │     │
│   └────────────┘     └────────────┘     └────────────┘     │
│         │                  │                  │            │
│         ▼                  ▼                  ▼            │
│   Test FAILS         Test PASSES        Test PASSES        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

### 3.4 Researcher

**Name**: `researcher`
**Role**: Documentation lookup, web research, information gathering

#### Tools Available

```
Built-in:
├─ Read
└─ WebSearch

MCP Servers:
├─ mcp__context7__resolve-library-id
├─ mcp__context7__query-docs
├─ mcp__web_reader__webReader
├─ mcp__fetch__fetch
└─ mcp__doc-forge__document_reader
```

#### Capabilities

| Capability | Description | Tool Used |
|------------|-------------|-----------|
| Library Docs | Query library documentation | `context7` |
| Web Reading | Read web pages as markdown | `web_reader` |
| URL Fetching | Fetch URL content | `fetch` |
| Document Reading | Read PDF/DOCX/etc | `doc-forge` |
| Web Search | Search the web | `WebSearch` |

#### Research Workflow

```
1. Receive research topic from shared memory
2. Search for relevant documentation
   ├─ context7 for library docs
   ├─ WebSearch for general search
   └─ web_reader for specific URLs
3. Compile findings
4. Write results to shared memory
```

---

### 3.5 Document Writer

**Name**: `doc-writer`
**Role**: Documentation creation, format conversion

#### Tools Available

```
Built-in:
├─ Read, Write

MCP Doc-Forge:
├─ mcp__doc-forge__document_reader
├─ mcp__doc-forge__docx_to_html
├─ mcp__doc-forge__docx_to_pdf
├─ mcp__doc-forge__excel_read
├─ mcp__doc-forge__format_convert
├─ mcp__doc-forge__html_cleaner
├─ mcp__doc-forge__html_extract_resources
├─ mcp__doc-forge__html_formatter
├─ mcp__doc-forge__html_to_markdown
├─ mcp__doc-forge__html_to_text
├─ mcp__doc-forge__pdf_merger
├─ mcp__doc-forge__pdf_splitter
├─ mcp__doc-forge__text_diff
├─ mcp__doc-forge__text_encoding_converter
├─ mcp__doc-forge__text_formatter
└─ mcp__doc-forge__text_splitter

MCP Filesystem:
├─ mcp__filesystem__write_file
├─ mcp__filesystem__read_text_file
└─ mcp__filesystem__edit_file
```

#### Capabilities

| Capability | Description | Tool Used |
|------------|-------------|-----------|
| Markdown Docs | Write markdown documentation | `Write` |
| PDF Generation | Convert docs to PDF | `docx_to_pdf` |
| HTML Conversion | Convert between formats | `format_convert` |
| Document Merging | Merge multiple PDFs | `pdf_merger` |
| Text Processing | Format and clean text | `text_formatter` |

---

### 3.6 QA Validator

**Name**: `qa-validator`
**Role**: Test execution, coverage validation, quality checks

#### Tools Available

```
Built-in:
├─ Read, Glob, Grep
└─ Bash (test commands)

MCP Serena:
├─ mcp__serena__search_for_pattern
├─ mcp__serena__find_symbol
└─ mcp__serena__think_about_whether_you_are_done
```

#### Capabilities

| Capability | Description | Tool Used |
|------------|-------------|-----------|
| Test Execution | Run test suites | `Bash` |
| Coverage Check | Verify test coverage | `search_for_pattern` |
| BDD Validation | Validate BDD scenarios | `search_for_pattern` |
| Quality Gates | Run quality checks | `Bash`, `Grep` |

#### Quality Checklist

```
□ All tests passing
□ Coverage >= 80%
□ No lint errors
□ No type errors
□ BDD scenarios covered
□ No security vulnerabilities
```

---

### 3.7 Security Scanner

**Name**: `security-scanner`
**Role**: OWASP scanning, vulnerability detection

#### Tools Available

```
Built-in:
├─ Read, Glob, Grep

MCP Serena:
├─ mcp__serena__search_for_pattern
└─ mcp__serena__think_about_task_adherence
```

#### OWASP Top 10 Patterns

| ID | Vulnerability | Search Pattern |
|----|---------------|----------------|
| A01 | Broken Access Control | `@public|skip_auth|bypass_auth` |
| A02 | Crypto Failures | `MD5|SHA1|hardcoded.*secret|password.*=.*"` |
| A03 | Injection | `eval\(|exec\(|innerHTML|SQL.*\+` |
| A04 | Insecure Design | `TODO|FIXME|HACK` |
| A05 | Security Misconfig | `debug.*=.*true|DEBUG=True|CORS.*\*` |
| A06 | Vulnerable Components | Check package versions |
| A07 | Auth Failures | `password.*plain|session.*fix` |
| A08 | Data Integrity | `curl.*\|.*sh|wget.*\|.*bash` |
| A09 | Logging Failures | `console\.log.*password|log.*secret` |
| A10 | SSRF | `fetch\(.*userInput|request\(.*url` |

---

### 3.8 Git Operator

**Name**: `git-operator`
**Role**: Git operations, branch management, PR generation

#### Tools Available

```
Built-in:
├─ Read
└─ Bash (git commands)

MCP Serena:
├─ mcp__serena__search_for_pattern
└─ mcp__serena__find_file
```

#### Allowed Operations (Read-Only)

```
✅ git status
✅ git diff
✅ git log
✅ git branch
✅ git show
✅ git reflog
✅ git ls-files
```

#### Operations Requiring Confirmation

```
⚠️ git commit (requires user confirmation)
⚠️ git push (requires user confirmation)
⚠️ git reset --hard (requires user confirmation)
⚠️ git commit --amend (requires user confirmation)
⚠️ git push --force (requires user confirmation)
```

---

### 3.9 Memory Keeper

**Name**: `memory-keeper`
**Role**: Knowledge graph management, session memory

#### Tools Available

```
Built-in:
├─ Read, Write

MCP Memory:
├─ mcp__memory__create_entities
├─ mcp__memory__create_relations
├─ mcp__memory__add_observations
├─ mcp__memory__search_nodes
├─ mcp__memory__read_graph
├─ mcp__memory__open_nodes
├─ mcp__memory__delete_entities
├─ mcp__memory__delete_observations
└─ mcp__memory__delete_relations

MCP Serena:
├─ mcp__serena__write_memory
├─ mcp__serena__read_memory
└─ mcp__serena__list_memories
```

#### Memory Entity Types

```json
{
  "entity_types": {
    "TaskContext": {
      "description": "Active task context",
      "properties": ["task_id", "type", "status", "created_at"]
    },
    "AgentFinding": {
      "description": "Finding from an agent",
      "properties": ["agent", "finding_type", "details", "confidence"]
    },
    "CodeSymbol": {
      "description": "Code symbol reference",
      "properties": ["name", "type", "location", "references"]
    },
    "Decision": {
      "description": "Architecture/implementation decision",
      "properties": ["decision", "rationale", "alternatives"]
    }
  }
}
```

---

### 3.10 Task Planner

**Name**: `task-planner`
**Role**: Task decomposition, planning, progress tracking

#### Tools Available

```
Built-in:
├─ Read, Write
├─ TaskCreate, TaskGet, TaskUpdate, TaskList

MCP Servers:
└─ mcp__sequentialthinking__sequentialthinking
```

#### Planning Workflow

```
1. Receive task from shared memory
2. Use sequential thinking for decomposition
3. Create task list with TaskCreate
4. Define dependencies between tasks
5. Write plan to shared memory
```

---

### 3.11 File Manager

**Name**: `file-manager`
**Role**: File operations, directory management

#### Tools Available

```
Built-in:
├─ Read, Write, Edit
├─ Glob, Grep

MCP Filesystem:
├─ mcp__filesystem__create_directory
├─ mcp__filesystem__directory_tree
├─ mcp__filesystem__edit_file
├─ mcp__filesystem__get_file_info
├─ mcp__filesystem__list_allowed_directories
├─ mcp__filesystem__list_directory
├─ mcp__filesystem__list_directory_with_sizes
├─ mcp__filesystem__move_file
├─ mcp__filesystem__read_file
├─ mcp__filesystem__read_media_file
├─ mcp__filesystem__read_multiple_files
├─ mcp__filesystem__read_text_file
├─ mcp__filesystem__search_files
└─ mcp__filesystem__write_file
```

#### Capabilities

| Capability | Description | Tool Used |
|------------|-------------|-----------|
| Directory Creation | Create directories | `create_directory` |
| File Search | Search files by pattern | `search_files` |
| File Moving | Move/rename files | `move_file` |
| Directory Tree | Get directory structure | `directory_tree` |
| Media Reading | Read images/audio | `read_media_file` |

---

### 3.12 Data Engineer

**Name**: `data-engineer`
**Role**: Database operations, migrations, ETL

#### Tools Available

```
Built-in:
├─ Read, Write, Edit
├─ Glob, Grep
└─ Bash (DB commands)

MCP Serena:
├─ mcp__serena__find_symbol
├─ mcp__serena__search_for_pattern
├─ mcp__serena__get_symbols_overview
└─ mcp__serena__list_dir
```

#### Capabilities

| Capability | Description | Tool Used |
|------------|-------------|-----------|
| Schema Analysis | Analyze DB schema | `find_symbol`, `search_for_pattern` |
| Migration Writing | Write migrations | `Write`, `Edit` |
| ETL Scripts | Create ETL pipelines | `Write` |
| Query Optimization | Analyze queries | `search_for_pattern` |

---

## 4. Shared Memory Protocol

### 4.1 Memory Structure

```json
{
  "task_context": {
    "entity_type": "TaskContext",
    "name": "task_20260301_001",
    "observations": [
      {
        "type": "task_request",
        "content": "Fix login bug in auth.ts",
        "timestamp": "2026-03-01T10:00:00Z"
      },
      {
        "type": "analysis_result",
        "agent": "orchestrator",
        "content": {
          "intent": "bug_fix",
          "complexity": "moderate",
          "capabilities_needed": ["code_analysis", "code_writing", "testing"]
        }
      },
      {
        "type": "agent_finding",
        "agent": "code-analyzer",
        "content": {
          "file": "src/auth/login.ts",
          "issue": "null pointer exception in validateToken",
          "line": 45
        }
      }
    ]
  },
  "relations": [
    {
      "from": "task_20260301_001",
      "to": "code-analyzer",
      "relation_type": "spawned"
    },
    {
      "from": "code-analyzer",
      "to": "code-writer",
      "relation_type": "handoff"
    }
  ]
}
```

### 4.2 Communication Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                   SHARED MEMORY FLOW                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   Orchestrator                                                  │
│       │                                                         │
│       │ 1. Create TaskContext entity                            │
│       │ 2. Add task_request observation                         │
│       ▼                                                         │
│   ┌─────────────────────────────────────────────┐              │
│   │              SHARED MEMORY                   │              │
│   │                                             │              │
│   │  TaskContext: task_001                      │              │
│   │  ├─ observation: task_request               │              │
│   │  ├─ observation: analysis_result            │              │
│   │  └─ observation: agent_findings [...]       │              │
│   └─────────────────────────────────────────────┘              │
│       │                                                         │
│       │ 3. Spawn agents with task_id                            │
│       ▼                                                         │
│   ┌───────────┬───────────┬───────────┐                        │
│   │   Agent A │   Agent B │   Agent C │                        │
│   └─────┬─────┴─────┬─────┴─────┬─────┘                        │
│         │           │           │                               │
│         │ 4. Read TaskContext   │                               │
│         │ 5. Do work            │                               │
│         │ 6. Add observation    │                               │
│         ▼           ▼           ▼                               │
│   ┌─────────────────────────────────────────────┐              │
│   │              UPDATED MEMORY                  │              │
│   │                                             │              │
│   │  TaskContext: task_001                      │              │
│   │  ├─ observation: agent_A_finding            │              │
│   │  ├─ observation: agent_B_finding            │              │
│   │  └─ observation: agent_C_finding            │              │
│   └─────────────────────────────────────────────┘              │
│       │                                                         │
│       │ 7. Orchestrator reads all findings                      │
│       │ 8. Aggregates results                                   │
│       ▼                                                         │
│   Final Result                                                   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 4.3 Observation Types

| Type | Agent | Description |
|------|-------|-------------|
| `task_request` | orchestrator | Original user request |
| `analysis_result` | orchestrator | Task analysis result |
| `code_finding` | code-analyzer | Code analysis finding |
| `implementation` | code-writer | Code changes made |
| `research_result` | researcher | Research findings |
| `doc_created` | doc-writer | Documentation created |
| `test_result` | qa-validator | Test execution results |
| `security_finding` | security-scanner | Security issues found |
| `git_operation` | git-operator | Git operation performed |
| `plan_created` | task-planner | Task plan created |
| `file_operation` | file-manager | File operations done |
| `data_operation` | data-engineer | DB operations done |

---

## 5. Dynamic Assembly Algorithm

### 5.1 Intent Classification

```python
def classify_intent(user_request: str) -> Intent:
    """
    Classify user request into intent type.
    """

    patterns = {
        "bug_fix": ["bug", "fix", "error", "issue", "problem", "broken", "crash"],
        "new_feature": ["add", "create", "implement", "new", "feature", "build"],
        "refactor": ["refactor", "improve", "clean", "restructure", "optimize"],
        "security": ["security", "vulnerability", "OWASP", "CVE", "exploit"],
        "hotfix": ["urgent", "emergency", "critical", "production down", "ASAP"],
        "research": ["research", "analyze", "investigate", "study", "explore"],
        "documentation": ["document", "doc", "readme", "guide", "manual"],
        "testing": ["test", "spec", "coverage", "qa"],
        "git": ["commit", "push", "merge", "branch", "PR", "pull request"],
        "database": ["database", "migration", "schema", "SQL", "query"]
    }

    scores = {}
    for intent, keywords in patterns.items():
        score = sum(1 for kw in keywords if kw.lower() in user_request.lower())
        scores[intent] = score

    return max(scores, key=scores.get)
```

### 5.2 Capability Mapping

```python
INTENT_TO_CAPABILITIES = {
    "bug_fix": ["code_analysis", "code_writing", "testing"],
    "new_feature": ["research", "planning", "code_analysis", "code_writing", "testing", "documentation"],
    "refactor": ["code_analysis", "code_writing", "testing"],
    "security": ["security_scanning", "code_writing", "testing"],
    "hotfix": ["code_analysis", "code_writing"],
    "research": ["research", "documentation"],
    "documentation": ["documentation"],
    "testing": ["testing", "code_analysis"],
    "git": ["git_operations"],
    "database": ["data_operations", "code_analysis"]
}

CAPABILITY_TO_AGENT = {
    "code_analysis": "code-analyzer",
    "code_writing": "code-writer",
    "testing": "qa-validator",
    "security_scanning": "security-scanner",
    "research": "researcher",
    "planning": "task-planner",
    "documentation": "doc-writer",
    "git_operations": "git-operator",
    "data_operations": "data-engineer",
    "file_operations": "file-manager",
    "memory_management": "memory-keeper"
}
```

### 5.3 Methodology Integration (DDD/TDD/BDD/SDD)

#### 5.3.1 Domain-Driven Design (DDD)

**เมื่อไหร่ใช้**: Feature development ที่ซับซ้อน, bounded contexts, ubiquitous language

```
┌─────────────────────────────────────────────────────────────────┐
│                    DDD WORKFLOW                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   1. DOMAIN ANALYSIS                                            │
│      ├─ Identify Bounded Contexts                               │
│      ├─ Define Ubiquitous Language                              │
│      ├─ Map Aggregates & Entities                               │
│      └─ Document Domain Events                                  │
│                         │                                        │
│                         ▼                                        │
│   2. STRATEGIC DESIGN                                            │
│      ├─ Context Mapping                                          │
│      ├─ Define Relationships (Upstream/Downstream)               │
│      └─ Anti-Corruption Layers                                  │
│                         │                                        │
│                         ▼                                        │
│   3. TACTICAL DESIGN                                             │
│      ├─ Aggregates                                               │
│      ├─ Entities & Value Objects                                 │
│      ├─ Domain Services                                          │
│      └─ Repositories                                            │
│                                                                 │
│   Output Files:                                                  │
│   ├─ .specify/spec.md (with ubiquitous_language section)         │
│   ├─ .specify/contexts/<context>/                               │
│   └─ .specify/adr/ (Architecture Decision Records)              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**DDD Agent Mapping**:
- `task-planner` → Strategic design
- `code-analyzer` → Existing domain discovery
- `code-writer` → Tactical implementation
- `doc-writer` → Ubiquitous language documentation

#### 5.3.2 Test-Driven Development (TDD)

**เมื่อไหร่ใช้**: Implementation phase, bug fixes, refactoring

```
┌─────────────────────────────────────────────────────────────────┐
│                    TDD CYCLE (RED-GREEN-REFACTOR)               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌───────────────┐                                             │
│   │     RED       │  1. Write failing test                     │
│   │               │  2. Test MUST fail (verify it's valid)      │
│   └───────┬───────┘                                             │
│           │ Test FAILS ✅                                        │
│           ▼                                                     │
│   ┌───────────────┐                                             │
│   │    GREEN      │  3. Write MINIMAL code to pass              │
│   │               │  4. Test MUST pass                          │
│   └───────┬───────┘                                             │
│           │ Test PASSES ✅                                       │
│           ▼                                                     │
│   ┌───────────────┐                                             │
│   │   REFACTOR    │  5. Clean up code                           │
│   │               │  6. Test MUST still pass                    │
│   └───────┬───────┘                                             │
│           │ Test PASSES ✅                                       │
│           ▼                                                     │
│   ┌───────────────┐                                             │
│   │    COMMIT     │  7. Commit changes                          │
│   │               │  (requires user confirmation)               │
│   └───────────────┘                                             │
│                                                                 │
│   INVARIANTS:                                                   │
│   ├─ NEVER write implementation before failing test             │
│   ├─ NEVER modify test to make it pass - fix implementation     │
│   ├─ ALWAYS run tests after each change                         │
│   └─ REVERT if test fails after refactor                        │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**TDD Agent Mapping**:
- `code-writer` → Write tests & implementation
- `qa-validator` → Run tests, verify coverage
- `code-analyzer` → Find existing patterns to follow

#### 5.3.3 Behavior-Driven Development (BDD)

**เมื่อไหร่ใช้**: Feature specifications, acceptance criteria, QA

```
┌─────────────────────────────────────────────────────────────────┐
│                    BDD SCENARIO FORMAT                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   Feature: User Authentication                                  │
│                                                                 │
│   Scenario: User logs in with valid credentials                 │
│     Given I am on the login page                                │
│     And I have a registered account                             │
│     When I enter valid username "john@example.com"              │
│     And I enter valid password "SecurePass123!"                 │
│     And I click the "Login" button                              │
│     Then I should be redirected to the dashboard                │
│     And I should see "Welcome, John!"                           │
│                                                                 │
│   Scenario: User logs in with invalid credentials               │
│     Given I am on the login page                                │
│     When I enter invalid credentials                            │
│     And I click the "Login" button                              │
│     Then I should see "Invalid credentials" error               │
│     And I should remain on the login page                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**BDD to Test Mapping**:
```
Given → Test setup (arrange)
When  → Test action (act)
Then  → Test assertion (assert)
```

**BDD Agent Mapping**:
- `task-planner` → Write BDD scenarios
- `code-writer` → Implement scenarios as tests
- `qa-validator` → Verify all scenarios covered

#### 5.3.4 Spec-Driven Development (SDD)

**เมื่อไหร่ใช้**:
- งานที่ไม่สามารถจบในวันเดียว
- ต้อง switch branch ไปทำงานอื่น
- ทำงานหลายอย่างพร้อมกัน
- ต้อง handoff ให้คนอื่นทำต่อ

```
┌─────────────────────────────────────────────────────────────────┐
│                    SDD WORKFLOW                                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                    SESSION 1                             │   │
│   ├─────────────────────────────────────────────────────────┤   │
│   │                                                         │   │
│   │   /speckit:specify "Add user authentication"            │   │
│   │        │                                                │   │
│   │        ▼                                                │   │
│   │   ┌─────────────┐                                       │   │
│   │   │  spec.md    │  ← Requirements + BDD scenarios       │   │
│   │   └─────────────┘                                       │   │
│   │        │                                                │   │
│   │        ▼                                                │   │
│   │   /speckit:plan                                         │   │
│   │        │                                                │   │
│   │        ▼                                                │   │
│   │   ┌─────────────┐                                       │   │
│   │   │  plan.md    │  ← Architecture + ADRs                │   │
│   │   └─────────────┘                                       │   │
│   │        │                                                │   │
│   │        ▼                                                │   │
│   │   /speckit:tasks                                        │   │
│   │        │                                                │   │
│   │        ▼                                                │   │
│   │   ┌─────────────┐                                       │   │
│   │   │  tasks.md   │  ← Atomic tasks with dependencies     │   │
│   │   └─────────────┘                                       │   │
│   │                                                         │   │
│   │   [END OF DAY 1 - Need to switch branches]              │   │
│   │   → All progress saved in .specify/                     │   │
│   │                                                         │   │
│   └─────────────────────────────────────────────────────────┘   │
│                              │                                   │
│                              ▼                                   │
│   ┌─────────────────────────────────────────────────────────┐   │
│   │                    SESSION 2 (Days later)                │   │
│   ├─────────────────────────────────────────────────────────┤   │
│   │                                                         │   │
│   │   /speckit:implement                                    │   │
│   │        │                                                │   │
│   │        ▼                                                │   │
│   │   Reads: spec.md + plan.md + tasks.md                   │   │
│   │        │                                                │   │
│   │        ▼                                                │   │
│   │   TDD Implementation per task                           │   │
│   │        │                                                │   │
│   │        ▼                                                │   │
│   │   [Task completed, can pause/resume anytime]             │   │
│   │                                                         │   │
│   └─────────────────────────────────────────────────────────┘   │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

**SDD File Structure**:
```
.specify/
├── spec.md              # Requirements + BDD scenarios
├── plan.md              # Architecture + ADRs
├── tasks.md             # Atomic tasks with status
├── adr/                 # Architecture Decision Records
│   ├── 001-auth-strategy.md
│   └── 002-database-choice.md
└── constitution.md      # Project principles
```

---

## 5.4 spec-kit Integration

### 5.4.1 Available Commands

| Command | Description | When to Use |
|---------|-------------|-------------|
| `/speckit:specify` | Create/update feature specification | Start of feature work |
| `/speckit:plan` | Create implementation plan | After spec is ready |
| `/speckit:tasks` | Generate atomic tasks | After plan is approved |
| `/speckit:implement` | Execute tasks | Ready to code |
| `/speckit:clarify` | Ask clarification questions | Spec has ambiguities |
| `/speckit:analyze` | Cross-artifact consistency check | Before implementation |
| `/speckit:constitution` | Create/update project constitution | Project setup |
| `/speckit:checklist` | Generate feature checklist | Quality assurance |

### 5.4.2 spec-kit → dev-stack Handoff

```
┌─────────────────────────────────────────────────────────────────┐
│              spec-kit → dev-stack INTEGRATION                    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   PHASE 1: PLANNING (spec-kit)                                  │
│   ─────────────────────────────                                 │
│   /speckit:specify "Add OAuth2 login"                           │
│       │                                                         │
│       ▼                                                         │
│   spec.md with:                                                 │
│   ├─ Feature description                                        │
│   ├─ BDD scenarios (Given/When/Then)                            │
│   ├─ Acceptance criteria                                        │
│   └─ Ubiquitous language (DDD)                                  │
│       │                                                         │
│       ▼                                                         │
│   /speckit:plan                                                 │
│       │                                                         │
│       ▼                                                         │
│   plan.md with:                                                 │
│   ├─ Architecture decisions                                     │
│   ├─ ADRs                                                       │
│   ├─ Layer design                                               │
│   └─ Tech stack choices                                         │
│       │                                                         │
│       ▼                                                         │
│   /speckit:tasks                                                │
│       │                                                         │
│       ▼                                                         │
│   tasks.md with:                                                │
│   ├─ Task 1: [ ] Setup OAuth provider                           │
│   ├─ Task 2: [ ] Implement callback handler                     │
│   ├─ Task 3: [ ] Add session management                         │
│   └─ Task 4: [ ] Write E2E tests                                │
│                                                                 │
│   ═══════════════════════════════════════════════════════════   │
│                                                                 │
│   PHASE 2: IMPLEMENTATION (dev-stack)                           │
│   ──────────────────────────────────                            │
│   /dev-stack:feature implement OAuth2 login                     │
│       │                                                         │
│       ▼                                                         │
│   Orchestrator reads:                                           │
│   ├─ spec.md → BDD scenarios to implement                       │
│   ├─ plan.md → Architecture to follow                           │
│   ├─ tasks.md → Tasks to execute                                │
│       │                                                         │
│       ▼                                                         │
│   Dynamic Team Assembly:                                        │
│   ├─ code-writer → TDD implementation                           │
│   ├─ qa-validator → Test coverage                               │
│   └─ security-scanner → OAuth security check                    │
│       │                                                         │
│       ▼                                                         │
│   Each task follows TDD cycle:                                  │
│   RED → GREEN → REFACTOR → COMMIT                               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 5.4.3 When to Use What

```
┌─────────────────────────────────────────────────────────────────┐
│              DECISION MATRIX: spec-kit vs superpowers            │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   USE spec-kit WHEN:                                            │
│   ├─ ✅ Feature will take multiple days                         │
│   ├─ ✅ Need formal documentation                               │
│   ├─ ✅ Working with a team                                     │
│   ├─ ✅ Requirements are complex                                │
│   ├─ ✅ Need to pause/resume work                               │
│   ├─ ✅ Architecture decisions needed                           │
│   └─ ✅ BDD scenarios required                                  │
│                                                                 │
│   USE superpowers WHEN:                                         │
│   ├─ ✅ Quick fix (finish in same session)                      │
│   ├─ ✅ Bug fix (no spec needed)                                │
│   ├─ ✅ Simple refactoring                                      │
│   ├─ ✅ Research/exploration                                    │
│   ├─ ✅ Hot patch (urgent)                                      │
│   └─ ✅ TDD cycle only                                          │
│                                                                 │
│   USE BOTH (Hybrid) WHEN:                                       │
│   ├─ ✅ Complex feature → spec-kit for planning                 │
│   ├─ ✅ Then → superpowers for TDD implementation               │
│   └─ ✅ Example:                                                │
│       Day 1: /speckit:specify → /speckit:plan → /speckit:tasks  │
│       Day 2: /superpowers:tdd → implement tasks                 │
│       Day 3: /superpowers:review → finalize                     │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 5.3 Team Assembly

```python
def assemble_team(intent: str, request: str) -> List[str]:
    """
    Assemble team of agents based on intent and request.
    """

    # Get base capabilities for intent
    capabilities = INTENT_TO_CAPABILITIES.get(intent, [])

    # Add dynamic capabilities based on request analysis
    if "security" in request.lower() and "security_scanning" not in capabilities:
        capabilities.append("security_scanning")

    if "database" in request.lower() and "data_operations" not in capabilities:
        capabilities.append("data_operations")

    if "document" in request.lower() and "documentation" not in capabilities:
        capabilities.append("documentation")

    # Map capabilities to agents
    agents = [CAPABILITY_TO_AGENT[cap] for cap in capabilities]

    # Always add memory-keeper for coordination
    agents.append("memory-keeper")

    return list(set(agents))  # Remove duplicates
```

---

## 6. Command Interface

### 6.1 Master Command

```
/dev-stack:agents <task description>
```

**Behavior**:
1. Classify intent
2. Analyze required capabilities
3. Assemble dynamic team
4. Create shared memory context
5. Spawn sub-agents
6. Monitor progress
7. Aggregate results
8. Return final result

### 6.2 Sub-Agent Commands (Scoped)

| Command | Scope | Available Agents |
|---------|-------|-----------------|
| `/dev-stack:bug` | Bug fixes only | code-analyzer, code-writer, qa-validator |
| `/dev-stack:feature` | New features | Full team |
| `/dev-stack:security` | Security only | security-scanner, code-writer, qa-validator |
| `/dev-stack:refactor` | Refactoring | code-analyzer, code-writer, qa-validator |
| `/dev-stack:research` | Research only | researcher, doc-writer |
| `/dev-stack:git` | Git operations | git-operator |
| `/dev-stack:quality` | Quality checks | qa-validator, security-scanner |
| `/dev-stack:docs` | Documentation | doc-writer, researcher |
| `/dev-stack:data` | Database ops | data-engineer |
| `/dev-stack:plan` | Planning only | task-planner, researcher |

---

## 7. Implementation Plan

### Phase 1: Core Infrastructure (Week 1)

- [ ] Create orchestrator agent with dynamic assembly
- [ ] Set up shared memory protocol
- [ ] Implement intent classification

### Phase 2: Tool-Based Agents (Week 2)

- [ ] Create code-analyzer agent
- [ ] Create code-writer agent
- [ ] Create researcher agent
- [ ] Create qa-validator agent
- [ ] Create security-scanner agent

### Phase 3: Support Agents (Week 3)

- [ ] Create doc-writer agent
- [ ] Create git-operator agent
- [ ] Create memory-keeper agent
- [ ] Create task-planner agent
- [ ] Create file-manager agent
- [ ] Update data-engineer agent

### Phase 4: Integration (Week 4)

- [ ] Update all commands to use new agents
- [ ] Create sub-agent scoped commands
- [ ] Write integration tests
- [ ] Documentation

---

## 8. Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Tool Coverage | 100% | All 145 tools mapped to agents |
| Dynamic Assembly | 90%+ | Teams assembled dynamically |
| Memory Usage | 100% | All tasks use shared memory |
| Agent Reusability | High | Agents used across multiple workflows |
| Response Time | <5s | Time to assemble team |

---

## 9. Appendix

### A. Tool Count per Agent

| Agent | Built-in | MCP Serena | MCP Other | Total |
|-------|----------|------------|-----------|-------|
| orchestrator | 6 | 3 | 10 | 19 |
| code-analyzer | 3 | 8 | 0 | 11 |
| code-writer | 6 | 6 | 2 | 14 |
| researcher | 2 | 0 | 5 | 7 |
| doc-writer | 2 | 0 | 19 | 21 |
| qa-validator | 4 | 3 | 0 | 7 |
| security-scanner | 3 | 2 | 0 | 5 |
| git-operator | 2 | 2 | 0 | 4 |
| memory-keeper | 2 | 3 | 9 | 14 |
| task-planner | 6 | 0 | 1 | 7 |
| file-manager | 5 | 0 | 15 | 20 |
| data-engineer | 6 | 4 | 0 | 10 |
| **Total** | **47** | **31** | **51** | **139** |

*Note: Some tools are shared across agents*

### B. File Structure

```
plugins/dev-stack/
├── agents/
│   ├── orchestrator.md          # Master orchestrator
│   ├── code-analyzer.md         # Code analysis
│   ├── code-writer.md           # Code implementation
│   ├── researcher.md            # Research & docs lookup
│   ├── doc-writer.md            # Documentation
│   ├── qa-validator.md          # Testing & QA
│   ├── security-scanner.md      # Security scanning
│   ├── git-operator.md          # Git operations
│   ├── memory-keeper.md         # Memory management
│   ├── task-planner.md          # Task planning
│   ├── file-manager.md          # File operations
│   └── data-engineer.md         # Database operations
├── commands/
│   ├── agents.md                # Master command
│   ├── bug.md                   # Bug fix scope
│   ├── feature.md               # Feature scope
│   ├── security.md              # Security scope
│   ├── refactor.md              # Refactor scope
│   ├── research.md              # Research scope
│   ├── git.md                   # Git scope
│   ├── quality.md               # Quality scope
│   ├── docs.md                  # Documentation scope
│   ├── data.md                  # Database scope
│   └── plan.md                  # Planning scope
├── skills/
│   └── lib-orchestration/
│       ├── SKILL.md             # Orchestration library
│       └── references/
│           ├── intent-classification.md
│           ├── capability-mapping.md
│           ├── team-assembly.md
│           └── memory-protocol.md
└── hooks/
    └── scripts/
        └── shared-memory-init.sh  # Initialize shared memory
```

---

## 10. Error Handling & Edge Cases

### 10.1 Agent Failure Handling

```
┌─────────────────────────────────────────────────────────────────┐
│                  AGENT FAILURE RECOVERY                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   SCENARIO: code-writer fails during implementation            │
│                                                                 │
│   ┌──────────────┐                                              │
│   │   FAILURE    │  Agent returns error                         │
│   │  DETECTED    │                                              │
│   └──────┬───────┘                                              │
│          │                                                      │
│          ▼                                                      │
│   ┌──────────────────────────────────────────────────────────┐  │
│   │                    RECOVERY OPTIONS                        │  │
│   ├──────────────────────────────────────────────────────────┤  │
│   │                                                          │  │
│   │   Option A: RETRY (same agent, same task)                │  │
│   │   ├─ Max retries: 2                                      │  │
│   │   └─ Delay: 5 seconds                                    │  │
│   │                                                          │  │
│   │   Option B: FALLBACK (different agent)                   │  │
│   │   ├─ code-writer → code-analyzer + Edit tool             │  │
│   │   └─ Use simpler approach                                │  │
│   │                                                          │  │
│   │   Option C: ESCALATE (to orchestrator)                   │  │
│   │   ├─ Log failure to shared memory                        │  │
│   │   ├─ Ask user for guidance                               │  │
│   │   └─ Potentially abort task                              │  │
│   │                                                          │  │
│   └──────────────────────────────────────────────────────────┘  │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 10.2 MCP Server Unavailable

```
IF MCP server unavailable:
   ├─ serena → Fallback: Read + Grep + Glob
   ├─ memory → Fallback: Write JSON to .specify/memory/
   ├─ context7 → Fallback: WebSearch + web_reader
   ├─ doc-forge → Fallback: Read (basic) + Write
   └─ filesystem → Fallback: Built-in Read + Write + Edit

LOGGING:
   └─ Write fallback event to shared memory for audit
```

### 10.3 Conflicting Agent Outputs

```
SCENARIO: Two agents produce conflicting findings

Example:
├─ code-analyzer: "Function X is unused, safe to delete"
└─ researcher: "Function X is documented as public API"

RESOLUTION:
1. Log conflict to shared memory
2. Orchestrator detects conflict via relation analysis
3. Escalate to user with both findings
4. User decision recorded in memory
5. Proceed with user's decision
```

### 10.4 Session Interruption

```
SCENARIO: User closes session mid-task

RECOVERY:
1. All progress saved in .specify/ and shared memory
2. Next session: /dev-stack:resume <task_id>
3. Orchestrator reads:
   ├─ spec.md (if exists)
   ├─ plan.md (if exists)
   ├─ tasks.md (status of each task)
   └─ memory entities (findings so far)
4. Continue from last checkpoint
```

---

## 11. Testing Strategy

### 11.1 Unit Tests per Agent

| Agent | Test Focus | Tools to Mock |
|-------|------------|---------------|
| orchestrator | Intent classification, team assembly | MCP memory, Task |
| code-analyzer | Symbol lookup, pattern matching | mcp__serena__* |
| code-writer | Code generation, TDD cycle | mcp__serena__*, mcp__context7__* |
| researcher | Doc lookup, web search | mcp__context7__*, WebSearch |
| qa-validator | Test execution, coverage | Bash, mcp__serena__* |
| security-scanner | OWASP pattern detection | mcp__serena__search_for_pattern |
| git-operator | Git commands (dry-run) | Bash |
| memory-keeper | Entity creation, relations | mcp__memory__* |
| task-planner | Task decomposition | mcp__sequentialthinking__* |
| file-manager | File operations | mcp__filesystem__* |
| data-engineer | Schema analysis | mcp__serena__* |

### 11.2 Integration Tests

```yaml
# Test Scenarios

test_bug_fix_workflow:
  input: "fix null pointer in login.ts:45"
  expected:
    - orchestrator classifies as "bug_fix"
    - team: [code-analyzer, code-writer, qa-validator, memory-keeper]
    - shared memory created
    - code-analyzer finds issue
    - code-writer implements fix
    - qa-validator runs tests
    - final result returned

test_feature_workflow:
  input: "add user registration with email verification"
  expected:
    - orchestrator classifies as "new_feature"
    - team includes: researcher, task-planner, code-analyzer, code-writer, qa-validator, doc-writer
    - BDD scenarios generated
    - TDD cycle followed

test_session_interruption:
  steps:
    - Start feature work
    - Create spec.md, plan.md, tasks.md
    - Complete 2 of 5 tasks
    - Simulate session end
    - Resume in new session
    - Verify: tasks 3-5 continue correctly
```

### 11.3 BDD Test Scenarios for dev-stack Itself

```gherkin
Feature: Dynamic Team Assembly

  Scenario: Bug fix triggers correct team
    Given I submit request "/dev-stack:agents fix login bug"
    When the orchestrator analyzes the request
    Then it should classify as "bug_fix"
    And it should assemble team [code-analyzer, code-writer, qa-validator]
    And it should create shared memory context

  Scenario: Feature request includes security scan
    Given I submit request "/dev-stack:agents add payment with credit card"
    When the orchestrator analyzes the request
    Then it should include security-scanner in team
    Because "credit card" triggers security concern

  Scenario: Session resumption from saved state
    Given a previous session with incomplete tasks
    And tasks.md shows 3 of 5 tasks completed
    When I run "/dev-stack:resume"
    Then the orchestrator should read existing spec.md
    And it should continue from task 4
    And it should not re-do completed tasks

Feature: Tool Priority

  Scenario: MCP tools preferred over built-in
    Given both mcp__serena__find_symbol and Grep can find a symbol
    When code-analyzer searches for a function
    Then it should use mcp__serena__find_symbol first
    And only fall back to Grep if serena unavailable

  Scenario: Skills preferred over raw implementation
    Given a TDD implementation task
    When code-writer starts implementation
    Then it should invoke superpowers:test-driven-development skill
    And follow RED-GREEN-REFACTOR cycle
```

---

## 12. Migration Guide (v9 → v10)

### 12.1 Breaking Changes

| v9.0.0 | v10.0.0 | Migration Action |
|--------|---------|------------------|
| `/dev-stack:dev` | `/dev-stack:agents` | Use new master command |
| Fixed workflow agents | Dynamic agents | No action, but behavior changes |
| No shared memory | MCP memory required | Install memory MCP server |
| 12 workflow agents | 12 tool-based agents | Agents renamed, capabilities different |

### 12.2 Compatibility Layer

```
# v9 compatibility (deprecated but working)

/dev-stack:dev     → Routes to /dev-stack:agents
/dev-stack:bug     → Same behavior (scoped)
/dev-stack:feature → Same behavior (scoped)
/dev-stack:hotfix  → Same behavior (scoped)

# New in v10

/dev-stack:agents  → Master dynamic orchestrator
/dev-stack:research → New: research scope
/dev-stack:data    → New: database scope
```

### 12.3 Configuration Migration

```yaml
# v9 config
agents:
  - domain-analyst
  - solution-architect
  - senior-developer
  - qa-engineer

# v10 config (automatic, no manual config needed)
# Orchestrator dynamically selects from:
tool_based_agents:
  - code-analyzer    # was: part of senior-developer
  - code-writer      # was: part of senior-developer
  - researcher       # was: part of domain-analyst
  - qa-validator     # was: qa-engineer
  - security-scanner # was: quality-gatekeeper
  - task-planner     # was: tech-lead
  - doc-writer       # was: documentation-writer
  - git-operator     # new
  - memory-keeper    # new
  - file-manager     # new
  - data-engineer    # same
  - orchestrator     # enhanced
```

---

## 13. Security Considerations

### 13.1 Agent Permissions

```
┌─────────────────────────────────────────────────────────────────┐
│                    AGENT PERMISSION MATRIX                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   AGENT           │ READ │ WRITE │ EDIT │ BASH │ GIT │ DELETE   │
│   ─────────────────────────────────────────────────────────────│
│   orchestrator    │  ✅  │  ❌   │  ❌  │  ❌  │ ❌  │   ❌      │
│   code-analyzer   │  ✅  │  ❌   │  ❌  │  ❌  │ ❌  │   ❌      │
│   code-writer     │  ✅  │  ✅   │  ✅  │  ⚠️  │ ❌  │   ❌      │
│   researcher      │  ✅  │  ❌   │  ❌  │  ❌  │ ❌  │   ❌      │
│   doc-writer      │  ✅  │  ✅   │  ✅  │  ❌  │ ❌  │   ❌      │
│   qa-validator    │  ✅  │  ❌   │  ❌  │  ✅  │ ❌  │   ❌      │
│   security-scanner│  ✅  │  ❌   │  ❌  │  ❌  │ ❌  │   ❌      │
│   git-operator    │  ✅  │  ❌   │  ❌  │  ⚠️  │ ✅  │   ❌      │
│   memory-keeper   │  ✅  │  ✅   │  ✅  │  ❌  │ ❌  │   ⚠️      │
│   task-planner    │  ✅  │  ✅   │  ❌  │  ❌  │ ❌  │   ❌      │
│   file-manager    │  ✅  │  ✅   │  ✅  │  ❌  │ ❌  │   ✅      │
│   data-engineer   │  ✅  │  ✅   │  ✅  │  ⚠️  │ ❌  │   ⚠️      │
│                                                                 │
│   ✅ = Allowed  ⚠️ = Requires Confirmation  ❌ = Denied          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 13.2 Git Safety (Per User Requirement)

```
╔═══════════════════════════════════════════════════════════════╗
║               🔒 GIT SAFETY POLICY (v10.0.0)                   ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  ✅ READ-ONLY (Auto-allowed):                                  ║
║     • git status, git diff, git log, git branch               ║
║     • git show, git reflog, git ls-files                      ║
║                                                               ║
║  ⚠️  REQUIRES USER CONFIRMATION:                               ║
║     • git commit                                              ║
║     • git push                                                ║
║     • git reset --hard                                        ║
║     • git commit --amend                                      ║
║     • git push --force                                        ║
║                                                               ║
║  🚫 NEVER AUTO-EXECUTE:                                        ║
║     • Always ASK user before commit/push                      ║
║     • Present what will be committed/pushed                   ║
║     • Wait for explicit user approval                         ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

### 13.3 Sensitive Data Protection

```
NEVER:
├─ Log API keys, passwords, tokens
├─ Write secrets to shared memory
├─ Include credentials in agent output
└─ Store sensitive data in .specify/

ALWAYS:
├─ Use environment variables for secrets
├─ Reference .env files (never read them)
├─ Mask sensitive values in logs
└─ Audit agent access to sensitive paths
```

---

## 14. Performance Requirements

### 14.1 Response Time Targets

| Operation | Target | Max Acceptable |
|-----------|--------|----------------|
| Intent classification | <1s | 3s |
| Team assembly | <2s | 5s |
| Agent spawn (single) | <3s | 10s |
| Agent spawn (parallel, 4 agents) | <5s | 15s |
| Shared memory read | <100ms | 500ms |
| Shared memory write | <200ms | 1s |
| Full bug fix workflow | <2min | 5min |
| Full feature workflow | <10min | 30min |

### 14.2 Resource Limits

```yaml
limits:
  max_concurrent_agents: 6
  max_memory_entities_per_task: 100
  max_observations_per_entity: 50
  max_task_decomposition_depth: 5
  max_file_size_read: 10MB
  max_total_files_analyzed: 1000
  timeout_per_agent: 300s  # 5 minutes
  timeout_full_workflow: 3600s  # 1 hour
```

### 14.3 Caching Strategy

```
┌─────────────────────────────────────────────────────────────────┐
│                    CACHING LAYERS                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   L1: Agent Context Cache                                       │
│   ├─ Symbols overview (per file)                               │
│   ├─ Recent search results                                      │
│   └─ TTL: 5 minutes                                            │
│                                                                 │
│   L2: Session Memory                                            │
│   ├─ Task context                                               │
│   ├─ Agent findings                                             │
│   └─ Duration: Current session                                  │
│                                                                 │
│   L3: Persistent Memory                                         │
│   ├─ MCP memory entities                                        │
│   ├─ Serena memories                                            │
│   └─ Duration: Until explicitly deleted                         │
│                                                                 │
│   L4: File System Cache                                         │
│   ├─ .specify/ directory                                        │
│   ├─ spec.md, plan.md, tasks.md                                 │
│   └─ Duration: Until task complete                              │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 15. Glossary

| Term | Definition |
|------|------------|
| **Orchestrator** | Master agent that coordinates all other agents |
| **Dynamic Assembly** | Runtime selection of agents based on task analysis |
| **Shared Memory** | MCP memory-based communication layer between agents |
| **Tool-Based Agent** | Agent defined by tool capabilities, not workflow position |
| **Intent Classification** | Process of determining task type from user request |
| **Capability Mapping** | Mapping task requirements to agent capabilities |
| **SDD** | Spec-Driven Development - spec first, implement later |
| **DDD** | Domain-Driven Design - bounded contexts, ubiquitous language |
| **TDD** | Test-Driven Development - RED-GREEN-REFACTOR cycle |
| **BDD** | Behavior-Driven Development - Given/When/Then scenarios |
| **MCP** | Model Context Protocol - tool server standard |
| **Serena** | MCP server for code analysis and editing |
| **spec-kit** | SDD workflow tool (separate plugin) |
| **superpowers** | TDD and workflow skills (separate plugin) |
| **TaskContext** | Shared memory entity containing task state |
| **Observation** | Individual finding stored in memory entity |
| **ADR** | Architecture Decision Record |
| **Quality Gate** | Checkpoint that must pass before proceeding |

---

## 16. Appendices

### Appendix C: Quick Reference Card

```
╔═══════════════════════════════════════════════════════════════╗
║              dev-stack v10.0.0 QUICK REFERENCE                 ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  MASTER COMMAND:                                              ║
║  /dev-stack:agents <describe what you want>                   ║
║                                                               ║
║  SCOPED COMMANDS:                                             ║
║  /dev-stack:bug       - Bug fixes                             ║
║  /dev-stack:feature   - New features                          ║
║  /dev-stack:security  - Security patches                      ║
║  /dev-stack:refactor  - Code refactoring                      ║
║  /dev-stack:research  - Research only                         ║
║  /dev-stack:git       - Git operations                        ║
║  /dev-stack:quality   - Quality checks                        ║
║  /dev-stack:docs      - Documentation                         ║
║  /dev-stack:data      - Database operations                   ║
║  /dev-stack:plan      - Planning only                         ║
║                                                               ║
║  SESSION MANAGEMENT:                                          ║
║  /dev-stack:resume <id>   - Resume incomplete task            ║
║  /dev-stack:status        - Show active tasks                 ║
║  /dev-stack:snapshot      - Save current state                ║
║                                                               ║
║  SDD WORKFLOW (with spec-kit):                                ║
║  /speckit:specify → /speckit:plan → /speckit:tasks            ║
║  /speckit:implement → done                                    ║
║                                                               ║
║  TDD WORKFLOW (with superpowers):                             ║
║  /superpowers:tdd → implement → test → commit                 ║
║                                                               ║
║  TOOL PRIORITY:                                               ║
║  MCP > Plugins > Skills > Built-in                           ║
║                                                               ║
║  GIT SAFETY:                                                  ║
║  Read-only: ✅ Auto-allowed                                    ║
║  Commit/Push: ⚠️ Requires confirmation                        ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

### Appendix D: Changelog

```markdown
## v10.0.0 (2026-03-XX) - Dynamic Orchestration

### Added
- Full dynamic team assembly based on task analysis
- Shared memory protocol for inter-agent communication
- 12 tool-based agents (redesigned from workflow-based)
- SDD workflow integration with spec-kit
- Tool selection priority hierarchy (MCP > Plugins > Skills > Built-in)
- Session resumption from saved state
- Error recovery and fallback mechanisms

### Changed
- Agents redesigned around tool capabilities
- Master command `/dev-stack:agents` with smart routing
- All commands now support dynamic agent selection

### Removed
- Fixed workflow templates
- Workflow-based agent definitions

### Migration
- See Section 12 for migration guide
- Backward compatible with v9 commands (routed to new system)
```

---

**Document Status**: Complete - Ready for Review
**Next Review**: 2026-03-02
**Approval Required From**: @tanaphat.oiu
**Version**: 10.0.0-draft-2
