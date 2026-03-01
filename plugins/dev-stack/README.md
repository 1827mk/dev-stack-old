# dev-stack v9.0.0 — Technical Blueprint

> **Internal Plugin Documentation** — Detailed architecture, agents, commands, and configuration for developers.
>
> **v9.0.0 Hybrid Architecture**: 145 tools, 12 agents, 12 commands, 7 skills, 6 hooks

---

## Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Plugin Structure](#plugin-structure)
3. [Agents Reference](#agents-reference)
4. [Commands Reference](#commands-reference)
5. [Skills Reference](#skills-reference)
6. [Hooks Reference](#hooks-reference)
7. [Workflow Classification](#workflow-classification)
8. [Quality Gates](#quality-gates)
9. [Configuration](#configuration)
10. [MCP Integration](#mcp-integration)

---

## Architecture Overview

### Design Philosophy

```
┌─────────────────────────────────────────────────────────────────┐
│                     dev-stack v9.0.0 Architecture               │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   USER INPUT                                                    │
│       │                                                         │
│       ▼                                                         │
│   ┌─────────────┐                                               │
│   │   agents    │ ◀── Smart Router (orchestrator logic)        │
│   │   .md       │     - Keyword classification                  │
│   └──────┬──────┘     - Workflow selection                      │
│          │            - Team assembly (12 agents)               │
│          ▼                                                       │
│   ┌─────────────┐                                               │
│   │  commands/  │ ◀── Workflow Entry Points                     │
│   │   *.md      │     - 12 unified commands (+ :init)           │
│   └──────┬──────┘     - Auto-routing to skills                  │
│          │                                                       │
│          ▼                                                       │
│   ┌─────────────┐                                               │
│   │  skills/    │ ◀── Internal Libraries (7 skills)            │
│   │   lib-*     │     - lib-router: 12 intents + fallbacks      │
│   │   orch-*    │     - lib-workflow: Classification            │
│   └──────┬──────┘     - lib-domain: DDD/BDD                     │
│          │              - lib-tdd: Test cycle                    │
│          │              - lib-testing: Test strategies (NEW)    │
│          │              - lib-intelligence: Snapshot/Drift      │
│          ▼                                                       │
│   ┌─────────────┐                                               │
│   │   hooks/    │ ◀── Event Handlers (6 hooks)                 │
│   │   scripts/  │     - SessionStart: Initialize state          │
│   │   prompts/  │     - UserPromptSubmit: Auto-routing          │
│   └─────────────┘     - PreToolUse: Guard dangerous ops         │
│                       - PostToolUse: Status line update         │
│                       - Notification: Desktop alerts            │
│                       - PreCommit: Quality gate (NEW)           │
│                                                                 │
│   ┌─────────────┐                                               │
│   │  MCP Tools  │ ◀── 145 Tools Integrated                     │
│   │             │     - serena (26): Symbol-aware ops           │
│   │             │     - memory (9): Knowledge graph             │
│   │             │     - doc-forge (16): Document processing     │
│   │             │     - filesystem (15): File operations        │
│   │             │     - context7 (2): Library docs              │
│   └─────────────┘                                               │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### Data Flow

```
User Request
    │
    ▼
┌───────────────────────────────────────────────────────┐
│ 1. CLASSIFY (agents.md)                               │
│    - Keyword detection                                │
│    - Sequential thinking for ambiguous cases          │
│    - Confidence threshold check                       │
└───────────────────────┬───────────────────────────────┘
                        │
                        ▼
┌───────────────────────────────────────────────────────┐
│ 2. SELECT WORKFLOW (lib-workflow)                     │
│    - new_feature → Full DDD/BDD team                  │
│    - bug_fix → domain → dev → gate → qa               │
│    - hotfix → dev only                                │
│    - refactor → architect → dev → gate                │
│    - security_patch → dev → gate (full) → qa          │
└───────────────────────┬───────────────────────────────┘
                        │
                        ▼
┌───────────────────────────────────────────────────────┐
│ 3. ASSEMBLE TEAM (orchestration)                      │
│    - Build dependency graph                           │
│    - Identify parallel execution opportunities        │
│    - Inject context bundle                            │
└───────────────────────┬───────────────────────────────┘
                        │
                        ▼
┌───────────────────────────────────────────────────────┐
│ 4. EXECUTE (agents + skills)                          │
│    - Sequential agents with dependencies              │
│    - Parallel agents where independent                │
│    - Quality gates between phases                     │
└───────────────────────┬───────────────────────────────┘
                        │
                        ▼
┌───────────────────────────────────────────────────────┐
│ 5. VALIDATE (quality-gatekeeper)                      │
│    - DoR → ArchReview → TaskReady → BDDCoverage → DoD │
└───────────────────────────────────────────────────────┘
```

---

## Plugin Structure

```
plugins/dev-stack/
│
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest (version, description)
│
├── README.md                    # This file (technical blueprint)
│
├── agents/                      # 12 Agent Instructions
│   ├── orchestrator.md          # Central router
│   ├── domain-analyst.md        # DDD/BDD specs
│   ├── solution-architect.md    # Architecture + ADRs
│   ├── tech-lead.md             # Task decomposition
│   ├── senior-developer.md      # TDD implementation
│   ├── quality-gatekeeper.md    # Code + security review
│   ├── qa-engineer.md           # Test coverage validation
│   ├── devops-engineer.md       # Deployment + CI/CD
│   ├── team-coordinator.md      # Team communication
│   ├── performance-engineer.md  # Performance analysis
│   ├── documentation-writer.md  # Documentation generation
│   └── data-engineer.md         # Database operations (NEW v9.0)
│
├── commands/                    # 12 Unified Commands
│   ├── agents.md                # Smart router (entry point)
│   ├── bug.md                   # Bug fix workflow
│   ├── feature.md               # Feature workflow
│   ├── hotfix.md                # Emergency hotfix
│   ├── plan.md                  # Read-only analysis
│   ├── refactor.md              # Refactor workflow
│   ├── security.md              # Security workflow
│   ├── git.md                   # Unified git operations
│   ├── info.md                  # Unified info operations
│   ├── quality.md               # Unified quality operations
│   ├── session.md               # Unified session operations
│   └── init.md                  # Project initialization (NEW v9.0)
│
├── hooks/
│   ├── hooks.json               # Hook registration
│   ├── prompts/                 # Prompt-based hooks
│   │   ├── checkpoint-reminder.md
│   │   └── verify-agent-done.md
│   └── scripts/                 # Shell script hooks
│       ├── session-start.sh     # Initialize state
│       ├── auto-router.sh       # Keyword classification
│       ├── pre-tool-guard.sh    # Block dangerous ops
│       ├── notify.sh            # Desktop notifications
│       └── status-line.sh       # Progress updates
│
└── skills/                      # Internal Libraries
    ├── orchestration/           # Central routing
    │   ├── SKILL.md
    │   └── references/
    │       ├── boot-sequences.md
    │       ├── output-formats.md
    │       └── team-messaging.md
    ├── lib-router/              # Tool mapping
    ├── lib-workflow/            # Workflow classification
    ├── lib-domain/              # DDD/BDD patterns
    │   ├── SKILL.md
    │   └── references/
    │       └── ...
    ├── lib-tdd/                 # TDD cycle
    │   ├── SKILL.md
    │   └── references/
    │       └── ...
    └── lib-intelligence/        # Snapshot, drift, impact
        ├── SKILL.md
        └── references/
            └── memory-sync.md
```

---

## Agents Reference

### Agent Types

| Type | Model | Complexity | Use Case |
|------|-------|------------|----------|
| **Orchestrator** | sonnet | High | Routing, team assembly, context injection |
| **Architect** | sonnet | High | Architecture design, ADRs, layer boundaries |
| **Developer** | sonnet | High | TDD implementation, code generation |
| **Analyst** | sonnet | Medium | DDD modeling, BDD scenarios |
| **Reviewer** | sonnet | Medium | Code review, security validation |
| **Support** | haiku | Low | Documentation, QA, coordination |

### Agent Details

#### 1. orchestrator.md

```yaml
Role: Central Router
Model: sonnet
Tools: All (Read, Write, Edit, Bash, MCP)
Responsibilities:
  - Classify user intent
  - Select workflow type
  - Assemble agent team
  - Build dependency graph
  - Inject context bundle
  - Coordinate execution
  - Handle gate events
Invoked: Every command
```

#### 2. domain-analyst.md

```yaml
Role: DDD/BDD Spec Creator
Model: sonnet
Tools: Read, Write, Grep, Glob, MCP (serena, memory)
Responsibilities:
  - Extract domain concepts
  - Define bounded contexts
  - Create ubiquitous language
  - Write BDD scenarios (Given/When/Then)
  - Generate spec.md
Invoked: new_feature, bug_fix, architecture, spike
Outputs:
  - .specify/specs/{id}/spec.md
  - BDD scenarios (3+ required for DoR gate)
```

#### 3. solution-architect.md

```yaml
Role: Architecture Designer
Model: sonnet
Tools: Read, Write, Grep, Glob, MCP (serena, memory)
Responsibilities:
  - Design system architecture
  - Define layer boundaries
  - Write ADRs (Architecture Decision Records)
  - Generate plan.md
  - Identify technical risks
Invoked: new_feature, refactor, architecture
Outputs:
  - .specify/specs/{id}/plan.md
  - .specify/memory/adr/{id}-*.md
Gate: ArchReview (blocks if plan.md missing or ADRs incomplete)
```

#### 4. tech-lead.md

```yaml
Role: Task Decomposer
Model: sonnet
Tools: Read, Write, Grep, Glob, MCP (serena, memory)
Responsibilities:
  - Decompose plan into atomic tasks
  - Define task dependencies
  - Estimate effort (≤4h per task)
  - Tag tasks with BDD references
  - Mark [test-first] for TDD
Invoked: new_feature, architecture
Outputs:
  - .specify/specs/{id}/tasks.md
Gate: TaskReady (blocks if task >4h or no BDD reference)
```

#### 5. senior-developer.md

```yaml
Role: TDD Implementer
Model: sonnet
Tools: Read, Write, Edit, Bash, MCP (serena, context7)
Responsibilities:
  - Write failing tests first (RED)
  - Implement minimum code (GREEN)
  - Refactor for quality (REFACTOR)
  - Run tests after each change
  - Document complex logic
Invoked: All code changes
Workflow:
  1. Read task from tasks.md
  2. Find BDD scenario reference
  3. Write test file first
  4. Implement code
  5. Run tests → all pass
  6. Mark task [x] complete
```

#### 6. quality-gatekeeper.md

```yaml
Role: Code + Security Reviewer
Model: sonnet
Tools: Read, Grep, Glob, MCP (serena)
Responsibilities:
  - Code quality review
  - Security pattern detection
  - OWASP Top 10 validation
  - Container validation
  - CI/CD pipeline check
Modes:
  - quick: Code quality + critical security (default)
  - full: Complete OWASP + container + CI/CD
Invoked: After implementation
Outputs:
  - Quality report
  - Security findings
  - Recommendations
Gate: DoD (blocks if issues found)
```

#### 7. qa-engineer.md

```yaml
Role: Test Coverage Validator
Model: haiku
Tools: Read, Grep, Glob, Bash
Responsibilities:
  - Map BDD scenarios to tests
  - Verify exact title match
  - Run test suite
  - Report coverage gaps
  - Validate all scenarios covered
Invoked: After quality gate
Outputs:
  - Coverage report
  - Missing tests list
Gate: BDDCoverage (blocks if scenario missing test)
```

#### 8. devops-engineer.md

```yaml
Role: Deployment Engineer
Model: haiku
Tools: Read, Write, Bash, MCP (serena)
Responsibilities:
  - Docker/container validation
  - CI/CD pipeline configuration
  - Infrastructure-as-code
  - Deployment scripts
  - Environment configuration
Invoked: Before delivery (new_feature, architecture)
Outputs:
  - Dockerfile updates
  - CI/CD config
  - Deployment checklist
```

#### 9. team-coordinator.md

```yaml
Role: Team Communication
Model: haiku
Tools: Read, Write, Bash
Responsibilities:
  - Message routing between agents
  - Shared task visibility
  - Handoff coordination
  - Session state management
Invoked: Complex workflows
Outputs:
  - .specify/specs/{id}/team-messages.log
```

#### 10. performance-engineer.md

```yaml
Role: Performance Analyst
Model: sonnet
Tools: Read, Grep, Glob, Bash
Responsibilities:
  - Performance profiling
  - Bottleneck detection
  - Load testing strategy
  - Optimization recommendations
Invoked: On-demand
Outputs:
  - Performance report
  - Optimization plan
```

#### 11. documentation-writer.md

```yaml
Role: Documentation Generator
Model: haiku
Tools: Read, Write, Grep, Glob
Responsibilities:
  - Generate API documentation
  - Update README files
  - Create user guides
  - Document architecture
Invoked: After delivery or on-demand
Outputs:
  - API docs
  - README updates
  - Architecture diagrams
```

---

## Commands Reference

### Command Architecture

Each command is a **smart router** that:
1. Accepts natural language input
2. Classifies intent
3. Selects workflow
4. Assembles team
5. Executes with gates

### Command: `/dev-stack:agents`

```yaml
Type: Smart Router
Purpose: Main entry point
Behavior:
  - Empty input → Show menu
  - With input → Classify and route
Classification:
  bug/fix/error/issue → :bug
  feature/add/new/implement → :feature
  urgent/critical/hotfix → :hotfix
  refactor/improve/clean → :refactor
  security/vulnerability → :security
  analyze/assess/plan → :plan
Examples:
  /dev-stack:agents fix login bug
  /dev-stack:agents add user auth
  /dev-stack:agents "production is down!"
```

### Command: `/dev-stack:bug`

```yaml
Type: Core Workflow
Purpose: Bug fixes with TDD
Team: domain-analyst → senior-developer → quality-gatekeeper → qa-engineer
Gates: DoR, DoD
Flow:
  1. domain-analyst: Create minimal spec
  2. senior-developer: TDD cycle (RED-GREEN-REFACTOR)
  3. quality-gatekeeper: Quick review
  4. qa-engineer: Validate tests
Escalation:
  - Security issue → /dev-stack:security
  - Emergency → /dev-stack:hotfix
Tools: Read, Write, Edit, Bash
Time: 2-5 minutes
```

### Command: `/dev-stack:feature`

```yaml
Type: Core Workflow
Purpose: New features with full DDD/BDD
Team: Full team (all 11 agents)
Gates: DoR → ArchReview → TaskReady → BDDCoverage → DoD
Flow:
  1. domain-analyst: spec.md with BDD scenarios
  2. solution-architect: plan.md with ADRs
  3. tech-lead: tasks.md with dependencies
  4. senior-developer: TDD implementation
  5. quality-gatekeeper: Full review
  6. qa-engineer: Test validation
  7. devops-engineer: Deployment prep
Outputs:
  - .specify/specs/{id}/spec.md
  - .specify/specs/{id}/plan.md
  - .specify/specs/{id}/tasks.md
Tools: All
Time: 30-60 minutes
```

### Command: `/dev-stack:hotfix`

```yaml
Type: Core Workflow
Purpose: Emergency fixes (production down only)
Team: senior-developer only
Gates: NONE (bypasses all)
Flow:
  1. ⚠️ Confirm emergency
  2. senior-developer: Direct fix
  3. Manual verification
  4. Document root cause
Guards:
  - Non-emergency → Reject, suggest /bug or /feature
Bypassed:
  - spec.md (❌)
  - plan.md (❌)
  - code review (❌)
  - architecture review (❌)
Warning: "⚠️ Hotfix mode - bypassing quality gates. Use only for emergencies."
Tools: Read, Write, Edit, Bash
Time: 5-15 minutes
```

### Command: `/dev-stack:plan`

```yaml
Type: Core Workflow
Purpose: Read-only analysis (no code changes)
Team: domain-analyst + solution-architect
Gates: None (read-only)
Flow:
  1. Analyze scope
  2. Identify affected files
  3. Map dependencies
  4. Assess risks
  5. Estimate effort
  6. Output: analysis.md
Outputs:
  - .specify/specs/{id}/analysis.md
Constraint: 0 files modified
Tools: Read, Grep, Glob (no Write)
Time: 2-20 minutes
```

### Command: `/dev-stack:refactor`

```yaml
Type: Core Workflow
Purpose: Code improvement (preserves behavior)
Team: solution-architect → senior-developer → quality-gatekeeper
Gates: ArchReview, DoD
Flow:
  1. Verify test coverage (if <80%, warn)
  2. Extract in small steps
  3. Run tests after each step
  4. Verify behavior preserved
  5. Code quality improved
Guards:
  - No tests → Block, require tests first
Safety: High (test-verified)
Tools: Read, Write, Edit, Bash
Time: 15-30 minutes
```

### Command: `/dev-stack:security`

```yaml
Type: Core Workflow
Purpose: Security patches with full OWASP
Team: senior-developer → quality-gatekeeper (full) → qa-engineer
Gates: DoR, DoD
Flow:
  1. Find vulnerability
  2. Implement fix + input validation
  3. Output encoding
  4. Add security tests
  5. OWASP validation (all 10 categories)
  6. Security report
OWASP Categories:
  1. Injection
  2. Broken Authentication
  3. Sensitive Data Exposure
  4. XML External Entities
  5. Broken Access Control
  6. Security Misconfiguration
  7. Cross-Site Scripting
  8. Insecure Deserialization
  9. Using Components with Known Vulnerabilities
  10. Insufficient Logging & Monitoring
Tools: Read, Write, Edit, Bash
Time: 10-20 minutes
```

### Command: `/dev-stack:git`

```yaml
Type: Unified Command
Purpose: Git operations
Team: devops-engineer
Sub-operations:
  impact    → Analyze change ripple effect
  parallel  → Run multiple features in worktrees
  pr        → Generate PR description from spec
Classification:
  "impact" OR "ripple" OR "affect" → git impact
  "parallel" OR "simultaneous" → git parallel
  "pr" OR "pull request" OR "merge" → git pr
  default → git status
Tools: Bash (git commands), Read
Time: <500ms
```

### Command: `/dev-stack:info`

```yaml
Type: Unified Command
Purpose: Information queries
Team: documentation-writer
Sub-operations:
  adr     → Query architecture decisions
  help    → Full command reference
  status  → Show progress + velocity
  tools   → Show available tools catalog
Classification:
  "adr" OR "architecture" OR "decision" → info adr
  "help" OR "commands" → info help
  "status" OR "progress" → info status
  "tools" OR "catalog" → info tools
  default → info help
Tools: Read, Grep, Glob
Time: <100ms
```

### Command: `/dev-stack:quality`

```yaml
Type: Unified Command
Purpose: Quality checks
Team: quality-gatekeeper
Sub-operations:
  audit   → Full security + quality scan
  check   → Lint + typecheck + build
  drift   → Detect spec vs code gaps
  review  → Code review on files
Classification:
  "audit" OR "full" OR "owasp" → quality audit
  "check" OR "lint" OR "build" → quality check
  "drift" OR "gap" OR "sync" → quality drift
  "review" OR "code review" → quality review
  default → quality check
Tools: Read, Grep, Glob, Bash
Time: 10-60 seconds
```

### Command: `/dev-stack:session`

```yaml
Type: Unified Command
Purpose: Session management
Team: team-coordinator
Sub-operations:
  resume    → Resume pending feature
  retro     → Run retrospective
  snapshot  → Save session state
Classification:
  "resume" OR "continue" → session resume
  "retro" OR "retrospective" → session retro
  "snapshot" OR "save" → session snapshot
  default → Show session menu
Tools: Read, Write, Bash
Time: <500ms
```

---

## Skills Reference

### Internal Libraries (6 skills)

| Skill | Purpose | Entry Point |
|-------|---------|-------------|
| `orchestration` | MODE routing, team dispatch, output formats | `skill:dev-stack:orchestration` |
| `lib-router` | AI-optimized tool mapping | `skill:dev-stack:lib-router(intent)` |
| `lib-workflow` | Workflow classification, dependency graphs | `skill:dev-stack:lib-workflow(req)` |
| `lib-domain` | DDD modeling, BDD authoring | `skill:dev-stack:lib-domain` |
| `lib-tdd` | TDD cycle, constitution builder | `skill:dev-stack:lib-tdd` |
| `lib-intelligence` | Snapshot, drift, impact, PR | `skill:dev-stack:lib-intelligence(fn)` |

### lib-router Tool Mapping

```yaml
code_read:
  primary: mcp__serena__find_symbol
  fallback: Read

code_edit:
  primary: mcp__serena__replace_symbol_body
  fallback: Edit

code_refs:
  primary: mcp__serena__find_referencing_symbols
  fallback: Grep

bug_fix:
  find: code_read
  fix: code_edit
  verify: code_refs
```

---

## Hooks Reference

### Event Hooks (5 hooks)

| Hook | Event | Script | Purpose |
|------|-------|--------|---------|
| SessionStart | Session start | session-start.sh | Initialize state, check onboarding |
| UserPromptSubmit | User prompt | auto-router.sh | Keyword classification, fast-path routing |
| PreToolUse | Before tool | pre-tool-guard.sh | Block dangerous operations |
| PostToolUse | After tool | status-line.sh | Update progress indicator |
| Notification | Events | notify.sh | Desktop notifications |

### PreToolUse Guards

```bash
# Blocked operations:
rm -rf                    # Recursive delete
git push --force          # Force push
git reset --hard          # Hard reset
DROP TABLE                # SQL destructive
rm -rf .specify/          # Protect spec directory
```

---

## Workflow Classification

### Classification Logic

```
1. FAST-PATH CHECK (keywords):
   "bug|fix|error|issue" → bug_fix (confidence: 0.9)
   "feature|add|new|implement" → new_feature (confidence: 0.9)
   "urgent|critical|hotfix|production down" → hotfix (confidence: 1.0)
   "refactor|improve|clean|restructure" → refactor (confidence: 0.85)
   "security|vulnerability|OWASP|CVE" → security_patch (confidence: 0.95)
   "analyze|assess|plan|design" → architecture (confidence: 0.8)
   "research|spike|POC|proof of concept" → spike (confidence: 0.8)

2. SEQUENTIAL THINKING (if confidence < 0.5):
   - Use mcp__sequentialthinking to analyze
   - Consider context and ambiguity
   - Make best-effort classification

3. WORKFLOW SELECTION:
   - confidence >= 0.5 → Use classified workflow
   - confidence < 0.5 → Ask user for clarification
```

### Workflow Team Composition

| Workflow | Team | Gates | Avg Time |
|----------|------|-------|----------|
| new_feature | domain + architect + tech-lead + dev + gate + qa + devops | All 5 | 30-60 min |
| bug_fix | domain + dev + gate + qa | DoR, DoD | 2-5 min |
| hotfix | dev only | None | 5-15 min |
| refactor | architect + dev + gate | ArchReview, DoD | 15-30 min |
| security_patch | dev + gate (full) + qa | DoR, DoD | 10-20 min |
| architecture | Full team | All 5 | 30-60 min |
| spike | domain only | None | 10-30 min |

---

## Quality Gates

### Gate Pipeline

```
┌───────┐    ┌────────────┐    ┌────────────┐    ┌───────────┐    ┌───────┐
│  DoR  │───▶│ ArchReview │───▶│ TaskReady  │───▶│ BDDCover  │───▶│  DoD  │
└───────┘    └────────────┘    └────────────┘    └───────────┘    └───────┘
    │              │                 │                 │             │
    ▼              ▼                 ▼                 ▼             ▼
 spec.md       plan.md           tasks.md         test files    all pass
 exists        + ADRs            + BDD refs       + coverage     + build
 3+ BDD        + layers          + [test-first]   100% match     passes
```

### Gate Criteria

| Gate | Criteria | Blocks Agent |
|------|----------|--------------|
| **DoR** | spec.md exists, no `[NEEDS CLARIFICATION]`, 3+ BDD scenarios | domain-analyst |
| **ArchReview** | plan.md exists, ADRs documented, layer boundaries defined | solution-architect |
| **TaskReady** | BDD reference, `[test-first]` tag, single layer, ≤4h estimate | tech-lead |
| **BDDCoverage** | Every BDD scenario has test, exact titles match | qa-engineer |
| **DoD** | All gates pass, all tasks [x], compile + lint + typecheck PASS | Final delivery |

---

## Configuration

### Project Structure

```
.specify/
├── memory/
│   └── constitution.md      # Project conventions (auto-generated)
├── specs/
│   └── 001-feature-name/
│       ├── spec.md          # Requirements + BDD scenarios
│       ├── plan.md          # Architecture + ADRs
│       ├── tasks.md         # Implementation checklist
│       ├── analysis.md      # Plan mode output (optional)
│       └── team-messages.log
```

### Constitution Template

```markdown
# Project Constitution

## Principles
- Use TypeScript for all new code
- Follow TDD for all features
- All code must pass lint, typecheck, and tests

## Architecture
- Layered architecture (domain, application, infrastructure)
- Dependency injection for services
- Repository pattern for data access

## Learnings
- [Updated from retrospectives]
```

---

## MCP Integration

### Required MCP Servers

| Server | Purpose | Required |
|--------|---------|----------|
| `serena` | Symbol-aware code operations | No (falls back to built-in) |
| `memory` | Knowledge graph for patterns | No |
| `sequentialthinking` | Semantic analysis | No |

### Optional MCP Servers

| Server | Purpose |
|--------|---------|
| `context7` | Library documentation lookup |
| `fetch` | Web content fetching |
| `filesystem` | Advanced file operations |
| `ide` | IDE integration |

---

## Version History

| Version | Date | Key Changes |
|---------|------|-------------|
| 9.0.0 | 2026-03-01 | Hybrid Architecture: 145 tools, 12 agents, 12 commands, 7 skills, 6 hooks |
| 8.0.0 | 2026-03-01 | 11 unified commands (down from 21) |
| 7.7.0 | 2026-03-01 | Interactive menu |
| 7.0.0 | 2026-03-01 | Major rewrite, 11 agents |
| 6.x | 2026-02-28 | Pre-v7 architecture |
| 1.0.0 | 2026-02-20 | Initial version |

---

*Last updated: 2026-03-01*
*Plugin version: 9.0.0*
