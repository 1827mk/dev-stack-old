# Feature: dev-stack v10.0.0 Dynamic Orchestration

> **Status**: Draft
> **Created**: 2026-03-01
> **Owner**: @tanaphat.oiu
> **Reference**: /docs/specs/v10-dynamic-orchestration-spec.md

---

## Overview

### Problem Statement

dev-stack v9.0.0 ใช้ workflow-based agents ที่:
- มี team composition คงที่ตาม workflow type
- ไม่ได้ใช้ 145 tools ทั้งหมดอย่างมีประสิทธิภาพ
- ไม่มี inter-agent communication mechanism
- ไม่รองรับงานที่ต้องทำหลายวัน หรือ switch branch

### Proposed Solution

**Tool-Based Dynamic Orchestration**:
- Agents ออกแบบตาม **tool capabilities** (ไม่ใช่ workflow steps)
- **Full dynamic** team assembly based on task analysis
- **Shared memory** (MCP memory) สำหรับ inter-agent communication
- **Tool Priority**: MCP > Plugins > Skills > Built-in
- **SDD Workflow** integration สำหรับงานที่ต้องทำหลายวัน

---

## Ubiquitous Language

| Term | Definition |
|------|------------|
| **Orchestrator** | Master agent ที่วิเคราะห์ task และ assemble team |
| **Tool-Based Agent** | Agent ที่ออกแบบตามความสามารถของ tools ที่มี |
| **Dynamic Assembly** | การเลือก agents แบบ dynamic ตาม task requirements |
| **Shared Memory** | MCP memory layer สำหรับ agent communication |
| **Intent** | ประเภทของ task (bug_fix, new_feature, refactor, security, etc.) |
| **Capability** | ความสามารถที่ต้องการ (code_analysis, code_writing, testing, etc.) |
| **TaskContext** | Memory entity ที่เก็บ state ของ task |
| **Observation** | Finding ที่ agent เขียนลง shared memory |

---

## BDD Scenarios

### Epic 1: Master Orchestrator

#### Scenario 1.1: Intent Classification
```gherkin
Feature: Intent Classification

  Scenario: Classify bug fix request
    Given user submits "/dev-stack:agents fix login bug in auth.ts"
    When orchestrator analyzes the request
    Then intent should be classified as "bug_fix"
    And confidence should be >= 0.8

  Scenario: Classify new feature request
    Given user submits "/dev-stack:agents add OAuth2 login"
    When orchestrator analyzes the request
    Then intent should be classified as "new_feature"
    And required capabilities should include "research", "planning", "code_writing", "testing"

  Scenario: Classify ambiguous request
    Given user submits "/dev-stack:agents help with auth"
    When orchestrator analyzes the request
    Then confidence should be < 0.5
    And orchestrator should ask user for clarification
```

#### Scenario 1.2: Dynamic Team Assembly
```gherkin
Feature: Dynamic Team Assembly

  Scenario: Assemble bug fix team
    Given intent is "bug_fix"
    And request involves code changes
    When orchestrator assembles team
    Then team should include:
      | Agent           | Reason                          |
      | code-analyzer   | To analyze the bug              |
      | code-writer     | To implement the fix            |
      | qa-validator    | To verify the fix works         |
      | memory-keeper   | To coordinate shared memory     |
    And team should NOT include researcher or doc-writer

  Scenario: Assemble feature team with security concern
    Given intent is "new_feature"
    And request contains "credit card" or "payment"
    When orchestrator assembles team
    Then team should include security-scanner
    And team should include:
      | Agent             | Reason                      |
      | researcher        | To research best practices  |
      | task-planner      | To decompose tasks          |
      | code-analyzer     | To analyze existing code    |
      | code-writer       | To implement feature        |
      | qa-validator      | To test implementation      |
      | security-scanner  | To scan for vulnerabilities |
      | doc-writer        | To document feature         |
      | memory-keeper     | To coordinate memory        |

  Scenario: Assemble research-only team
    Given intent is "research"
    And no code changes needed
    When orchestrator assembles team
    Then team should include:
      | Agent        | Reason                      |
      | researcher   | To do research              |
      | doc-writer   | To document findings        |
      | memory-keeper| To coordinate memory        |
    And team should NOT include code-writer or qa-validator
```

#### Scenario 1.3: Shared Memory Coordination
```gherkin
Feature: Shared Memory Protocol

  Scenario: Create task context
    Given orchestrator receives new task request
    When orchestrator creates TaskContext
    Then memory should contain entity "task_<id>"
    And entity type should be "TaskContext"
    And first observation should be original request

  Scenario: Agent writes finding to memory
    Given code-analyzer completes analysis
    When code-analyzer writes finding
    Then TaskContext should have new observation
    And observation type should be "code_finding"
    And observation should include file path and issue details

  Scenario: Orchestrator aggregates results
    Given all agents have completed their work
    And each agent has written observations to memory
    When orchestrator reads TaskContext
    Then orchestrator should have all findings
    And orchestrator should produce final result
```

---

### Epic 2: Tool-Based Agents

#### Scenario 2.1: Code Analyzer
```gherkin
Feature: Code Analyzer Agent

  Scenario: Analyze symbol references
    Given code-analyzer receives task to analyze "LoginService"
    When code-analyzer uses mcp__serena__find_symbol
    Then it should find symbol definition
    And it should use mcp__serena__find_referencing_symbols to find usages
    And it should write findings to shared memory

  Scenario: Fallback when serena unavailable
    Given MCP serena server is down
    When code-analyzer needs to find symbols
    Then it should fall back to Grep + Read
    And it should log fallback event to memory
```

#### Scenario 2.2: Code Writer
```gherkin
Feature: Code Writer Agent with TDD

  Scenario: TDD cycle - write failing test first
    Given code-writer needs to implement new feature
    When code-writer starts implementation
    Then it should follow RED-GREEN-REFACTOR cycle
    And first it should write a failing test
    And test should fail (verify it's valid)

  Scenario: TDD cycle - minimal implementation
    Given failing test exists
    When code-writer implements code
    Then it should write minimal code to pass
    And it should use mcp__serena__replace_symbol_body if available
    And test should pass

  Scenario: Use context7 for API documentation
    Given code-writer needs to use unfamiliar library
    When code-writer looks up documentation
    Then it should use mcp__context7__resolve-library-id
    And it should use mcp__context7__query-docs
    And priority should be MCP context7 over WebSearch
```

#### Scenario 2.3: Git Operator
```gherkin
Feature: Git Operator with Safety Policy

  Scenario: Read-only git operations
    Given git-operator receives "git status" request
    When git-operator executes command
    Then it should execute without asking confirmation
    And it should return result to orchestrator

  Scenario: Git commit requires confirmation
    Given git-operator receives "git commit" request
    When git-operator prepares to commit
    Then it should show what will be committed
    And it should ASK user for confirmation
    And IF user confirms THEN execute commit
    And IF user denies THEN abort operation

  Scenario: Git push requires confirmation
    Given git-operator receives "git push" request
    When git-operator prepares to push
    Then it should show commits to be pushed
    And it should ASK user for confirmation
    And IF user confirms THEN execute push
    And IF user denies THEN abort operation
```

---

### Epic 3: SDD Workflow Integration

#### Scenario 3.1: Long-Running Task
```gherkin
Feature: Session Persistence

  Scenario: Save progress on session end
    Given user is working on feature "OAuth2 login"
    And 3 of 5 tasks are completed
    When user ends session
    Then progress should be saved in .specify/
    And spec.md should contain requirements
    And plan.md should contain architecture
    And tasks.md should show completed tasks

  Scenario: Resume incomplete task
    Given previous session ended with incomplete tasks
    And tasks.md shows 3 of 5 tasks completed
    When user runs "/dev-stack:resume <task_id>"
    Then orchestrator should read existing spec.md
    And orchestrator should read existing plan.md
    And orchestrator should continue from task 4
    And orchestrator should NOT re-do completed tasks
```

#### Scenario 3.2: spec-kit Handoff
```gherkin
Feature: spec-kit Integration

  Scenario: Use spec-kit for planning
    Given user starts new complex feature
    When user runs "/speckit:specify"
    Then spec-kit creates spec.md with BDD scenarios
    And user runs "/speckit:plan"
    Then spec-kit creates plan.md with architecture
    And user runs "/speckit:tasks"
    Then spec-kit creates tasks.md with atomic tasks

  Scenario: dev-stack implements spec-kit artifacts
    Given spec.md, plan.md, and tasks.md exist
    When user runs "/dev-stack:feature implement OAuth2"
    Then orchestrator should read all three files
    And orchestrator should follow TDD for each task
    And orchestrator should respect architecture in plan.md
    And orchestrator should implement all BDD scenarios in spec.md
```

---

### Epic 4: Tool Priority

#### Scenario 4.1: MCP Priority
```gherkin
Feature: Tool Selection Priority

  Scenario: Prefer MCP serena over built-in tools
    Given agent needs to find a symbol in code
    And mcp__serena__find_symbol is available
    When agent searches for symbol
    Then it should use mcp__serena__find_symbol
    And NOT use Grep directly

  Scenario: Prefer MCP memory over file-based storage
    Given agent needs to store shared context
    And mcp__memory__create_entities is available
    When agent writes context
    Then it should use mcp__memory__create_entities
    And NOT write to file directly

  Scenario: Fallback chain when MCP unavailable
    Given mcp__serena is unavailable
    When agent needs to search code
    Then it should fall back to Grep + Read
    And it should log fallback in memory
```

---

## Acceptance Criteria

### Must Have (P0)
- [ ] Orchestrator can classify intent correctly (>= 90% accuracy)
- [ ] Dynamic team assembly works for all intent types
- [ ] Shared memory protocol functional
- [ ] Git safety policy enforced (commit/push require confirmation)
- [ ] Tool priority: MCP > Plugins > Skills > Built-in
- [ ] All 12 agents implemented with correct tool mappings
- [ ] TDD cycle (RED-GREEN-REFACTOR) works in code-writer

### Should Have (P1)
- [ ] Session resumption from saved state
- [ ] spec-kit integration (read spec.md, plan.md, tasks.md)
- [ ] Fallback mechanisms when MCP unavailable
- [ ] Error recovery (retry, fallback, escalate)

### Nice to Have (P2)
- [ ] Performance: Team assembly < 5 seconds
- [ ] Caching for repeated analyses
- [ ] Progress tracking in shared memory

---

## Out of Scope

- Automatic git commit/push (always requires user confirmation)
- Direct database connections (use MCP tools instead)
- GUI interface (CLI only)
- Real-time collaboration features

---

## Technical Requirements

### Dependencies
- Claude Code CLI (latest)
- MCP Servers: serena, memory, context7, doc-forge, filesystem, sequentialthinking
- Plugins: superpowers, plugin-dev
- Bash 4.0+, Git 2.0+

### File Structure
```
plugins/dev-stack/
├── agents/
│   ├── orchestrator.md
│   ├── code-analyzer.md
│   ├── code-writer.md
│   ├── researcher.md
│   ├── doc-writer.md
│   ├── qa-validator.md
│   ├── security-scanner.md
│   ├── git-operator.md
│   ├── memory-keeper.md
│   ├── task-planner.md
│   ├── file-manager.md
│   └── data-engineer.md
├── commands/
│   ├── agents.md
│   ├── bug.md
│   ├── feature.md
│   ├── security.md
│   ├── refactor.md
│   ├── research.md
│   ├── git.md
│   ├── quality.md
│   ├── docs.md
│   ├── data.md
│   └── plan.md
└── skills/
    └── lib-orchestration/
        ├── SKILL.md
        └── references/
            ├── intent-classification.md
            ├── capability-mapping.md
            ├── team-assembly.md
            └── memory-protocol.md
```

---

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| MCP server unavailable | High | Medium | Fallback to built-in tools |
| Intent misclassification | Medium | Medium | Confidence threshold + user confirmation |
| Agent timeout | Medium | Low | Retry + fallback + escalate |
| Memory corruption | High | Low | Validation + backup to file |
| Git safety bypass | Critical | Low | PreToolUse hook enforcement |

---

## Definition of Done

- [ ] All BDD scenarios passing
- [ ] Unit tests for each agent
- [ ] Integration tests for workflows
- [ ] Documentation updated
- [ ] Migration guide from v9 to v10
- [ ] Performance benchmarks met
- [ ] Security review completed
- [ ] User acceptance testing passed
