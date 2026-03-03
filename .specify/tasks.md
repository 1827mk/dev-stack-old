# Tasks: dev-stack v10.0.0 Implementation

> **Status**: Ready for Implementation
> **Created**: 2026-03-01
> **Based on**: spec.md, plan.md

---

## Task Summary

| Phase | Tasks | Est. Time | Status |
|-------|-------|-----------|--------|
| Phase 1: Core | 6 | 1 week | Pending |
| Phase 2: Code Agents | 5 | 1 week | Pending |
| Phase 3: Support Agents | 6 | 1 week | Pending |
| Phase 4: Integration | 5 | 1 week | Pending |
| **Total** | **22** | **4 weeks** | |

---

## Phase 1: Core Infrastructure

### Task 1.1: Create lib-orchestration Skill
**Priority**: P0 | **Est.**: 2h | **BDD**: Epic 1, Scenario 1.1-1.3

**Files**:
- Create: `skills/lib-orchestration/SKILL.md`
- Create: `skills/lib-orchestration/references/intent-classification.md`
- Create: `skills/lib-orchestration/references/capability-mapping.md`
- Create: `skills/lib-orchestration/references/team-assembly.md`
- Create: `skills/lib-orchestration/references/memory-protocol.md`

**Acceptance Criteria**:
- [ ] SKILL.md with function signatures
- [ ] intent-classification.md with patterns
- [ ] capability-mapping.md with INTENT_TO_CAPABILITIES
- [ ] team-assembly.md with assemble_team()
- [ ] memory-protocol.md with entity types

---

### Task 1.2: Create Orchestrator Agent (v10)
**Priority**: P0 | **Est.**: 3h | **BDD**: Epic 1, Scenario 1.1-1.3

**Files**:
- Create: `agents/orchestrator.md`

**Acceptance Criteria**:
- [ ] Intent classification logic
- [ ] Capability mapping logic
- [ ] Dynamic team assembly
- [ ] Memory coordinator role
- [ ] Tool priority: MCP > Plugins > Skills > Built-in

**Tools**:
```
Read, Glob, Grep, Task
mcp__memory__* (all 9)
mcp__sequentialthinking__sequentialthinking
mcp__serena__*_memory* (3)
```

---

### Task 1.3: Create Memory-Keeper Agent
**Priority**: P0 | **Est.**: 2h | **BDD**: Epic 1, Scenario 1.3

**Files**:
- Create: `agents/memory-keeper.md`

**Acceptance Criteria**:
- [ ] Manage TaskContext entities
- [ ] Create agent findings as observations
- [ ] Query memory for agent coordination
- [ ] Fallback to file-based storage if MCP unavailable

**Tools**:
```
Read, Write
mcp__memory__* (all 9)
mcp__serena__write_memory, read_memory, list_memories
```

---

### Task 1.4: Create Master Command /dev-stack:agents
**Priority**: P0 | **Est.**: 2h | **BDD**: Epic 1, Scenario 1.1

**Files**:
- Update: `commands/agents.md`

**Acceptance Criteria**:
- [ ] Show menu if input empty
- [ ] Classify intent from input
- [ ] Assemble dynamic team
- [ ] Create shared memory context
- [ ] Spawn sub-agents via Task tool
- [ ] Aggregate and return results

---

### Task 1.5: Create Resume Command
**Priority**: P1 | **Est.**: 2h | **BDD**: Epic 3, Scenario 3.1

**Files**:
- Create: `commands/resume.md`

**Acceptance Criteria**:
- [ ] Read .specify/spec.md
- [ ] Read .specify/plan.md
- [ ] Read .specify/tasks.md
- [ ] Continue from last incomplete task
- [ ] Restore shared memory context

---

### Task 1.6: Update Hooks for Git Safety
**Priority**: P0 | **Est.**: 1h | **BDD**: Epic 2, Scenario 2.3

**Files**:
- Update: `hooks/scripts/pre-tool-guard.sh`

**Acceptance Criteria**:
- [ ] git commit requires confirmation
- [ ] git push requires confirmation
- [ ] git reset --hard requires confirmation
- [ ] git commit --amend requires confirmation
- [ ] git push --force requires confirmation

---

## Phase 2: Code Agents

### Task 2.1: Create Code-Analyzer Agent
**Priority**: P0 | **Est.**: 2h | **BDD**: Epic 2, Scenario 2.1

**Files**:
- Create: `agents/code-analyzer.md`

**Acceptance Criteria**:
- [ ] Use serena for symbol lookup
- [ ] Find referencing symbols
- [ ] Get symbols overview
- [ ] Search for patterns
- [ ] Fallback to Grep+Read if serena unavailable
- [ ] Write findings to shared memory

**Tools**:
```
Read, Glob, Grep
mcp__serena__find_symbol
mcp__serena__find_referencing_symbols
mcp__serena__get_symbols_overview
mcp__serena__search_for_pattern
mcp__serena__think_about_collected_information
```

---

### Task 2.2: Create Code-Writer Agent (TDD)
**Priority**: P0 | **Est.**: 3h | **BDD**: Epic 2, Scenario 2.2

**Files**:
- Create: `agents/code-writer.md`

**Acceptance Criteria**:
- [ ] Follow RED-GREEN-REFACTOR cycle
- [ ] Write failing test first
- [ ] Minimal implementation
- [ ] Use serena for symbol editing
- [ ] Use context7 for API docs
- [ ] Tool priority: MCP > Built-in

**Tools**:
```
Read, Write, Edit, Glob, Grep, Bash (test commands)
mcp__serena__replace_symbol_body
mcp__serena__insert_after_symbol
mcp__serena__insert_before_symbol
mcp__serena__rename_symbol
mcp__context7__resolve-library-id
mcp__context7__query-docs
```

---

### Task 2.3: Create QA-Validator Agent
**Priority**: P0 | **Est.**: 2h | **BDD**: Epic 2, Scenario 2.1

**Files**:
- Create: `agents/qa-validator.md`

**Acceptance Criteria**:
- [ ] Execute test suites
- [ ] Verify coverage >= 80%
- [ ] Validate BDD scenarios covered
- [ ] Run quality gates (lint, typecheck)
- [ ] Write results to shared memory

**Tools**:
```
Read, Glob, Grep, Bash
mcp__serena__search_for_pattern
mcp__serena__think_about_whether_you_are_done
```

---

### Task 2.4: Create Security-Scanner Agent
**Priority**: P0 | **Est.**: 2h | **BDD**: Epic 2, Scenario 2.1

**Files**:
- Create: `agents/security-scanner.md`

**Acceptance Criteria**:
- [ ] OWASP Top 10 pattern detection
- [ ] Scan for injection patterns
- [ ] Scan for crypto failures
- [ ] Scan for auth issues
- [ ] Write findings to shared memory

**Tools**:
```
Read, Glob, Grep
mcp__serena__search_for_pattern
mcp__serena__think_about_task_adherence
```

---

### Task 2.5: Create Researcher Agent
**Priority**: P1 | **Est.**: 2h | **BDD**: Epic 2, Scenario 2.2

**Files**:
- Create: `agents/researcher.md`

**Acceptance Criteria**:
- [ ] Use context7 for library docs
- [ ] Use web_reader for URLs
- [ ] Use WebSearch for general search
- [ ] Use doc-forge for document reading
- [ ] Write findings to shared memory

**Tools**:
```
Read, WebSearch
mcp__context7__resolve-library-id
mcp__context7__query-docs
mcp__web_reader__webReader
mcp__fetch__fetch
mcp__doc-forge__document_reader
```

---

## Phase 3: Support Agents

### Task 3.1: Create Doc-Writer Agent
**Priority**: P1 | **Est.**: 2h | **BDD**: Epic 2, Scenario 2.1

**Files**:
- Create: `agents/doc-writer.md`

**Acceptance Criteria**:
- [ ] Write markdown documentation
- [ ] Use doc-forge for PDF generation
- [ ] Use doc-forge for format conversion
- [ ] Use filesystem tools for file ops
- [ ] Write output to shared memory

**Tools**:
```
Read, Write
mcp__doc-forge__* (all 16)
mcp__filesystem__write_file, read_text_file, edit_file
```

---

### Task 3.2: Create Git-Operator Agent
**Priority**: P0 | **Est.**: 2h | **BDD**: Epic 2, Scenario 2.3

**Files**:
- Create: `agents/git-operator.md`

**Acceptance Criteria**:
- [ ] Read-only operations auto-allowed
- [ ] Write operations require confirmation
- [ ] Generate PR descriptions
- [ ] Analyze impact before changes
- [ ] Write results to shared memory

**Tools**:
```
Read, Bash (git commands)
mcp__serena__search_for_pattern, find_file
```

**Safety**:
```
✅ Auto-allowed: status, diff, log, branch, show, reflog, ls-files
⚠️ Confirmation: commit, push, reset --hard, commit --amend, push --force
```

---

### Task 3.3: Create File-Manager Agent
**Priority**: P1 | **Est.**: 2h | **BDD**: Epic 2, Scenario 2.1

**Files**:
- Create: `agents/file-manager.md`

**Acceptance Criteria**:
- [ ] Create/move/delete files
- [ ] Directory tree operations
- [ ] Search files by pattern
- [ ] Read media files (images)
- [ ] Write results to shared memory

**Tools**:
```
Read, Write, Edit, Glob, Grep
mcp__filesystem__* (all 15)
```

---

### Task 3.4: Create Task-Planner Agent
**Priority**: P1 | **Est.**: 2h | **BDD**: Epic 1, Scenario 1.2

**Files**:
- Create: `agents/task-planner.md`

**Acceptance Criteria**:
- [ ] Decompose tasks with sequentialthinking
- [ ] Create atomic tasks with TaskCreate
- [ ] Define dependencies
- [ ] Follow DDD/BDD patterns
- [ ] Write plan to shared memory

**Tools**:
```
Read, Write
mcp__sequentialthinking__sequentialthinking
TaskCreate, TaskGet, TaskUpdate, TaskList
```

---

### Task 3.5: Create Data-Engineer Agent (Update)
**Priority**: P1 | **Est.**: 1h | **BDD**: Epic 2, Scenario 2.1

**Files**:
- Update: `agents/data-engineer.md`

**Acceptance Criteria**:
- [ ] Add shared memory integration
- [ ] Add tool priority documentation
- [ ] Keep existing functionality
- [ ] Add fallback mechanisms

---

### Task 3.6: Create Shared Memory Init Script
**Priority**: P1 | **Est.**: 1h | **BDD**: Epic 1, Scenario 1.3

**Files**:
- Create: `hooks/scripts/shared-memory-init.sh`

**Acceptance Criteria**:
- [ ] Initialize TaskContext entity
- [ ] Create base observations
- [ ] Run on session start

---

## Phase 4: Integration

### Task 4.1: Create Scoped Commands
**Priority**: P0 | **Est.**: 3h | **BDD**: Epic 1, Scenario 1.2

**Files**:
- Update: `commands/bug.md`
- Update: `commands/feature.md`
- Update: `commands/security.md`
- Update: `commands/refactor.md`
- Create: `commands/research.md`
- Update: `commands/git.md`
- Update: `commands/quality.md`
- Create: `commands/docs.md`
- Create: `commands/data.md`
- Update: `commands/plan.md`

**Acceptance Criteria**:
- [ ] Each command has scoped agent list
- [ ] Commands use shared memory
- [ ] Tool priority enforced
- [ ] Backward compatible with v9

---

### Task 4.2: Update Plugin Configuration
**Priority**: P0 | **Est.**: 1h | **BDD**: N/A

**Files**:
- Update: `.claude-plugin/plugin.json`
- Update: `../.claude-plugin/marketplace.json`

**Acceptance Criteria**:
- [ ] Version: 10.0.0
- [ ] Agent count: 12
- [ ] Command count: 12
- [ ] Skill count: 8

---

### Task 4.3: Write Integration Tests
**Priority**: P1 | **Est.**: 3h | **BDD**: Section 11.2

**Files**:
- Create: `tests/integration/bug-fix-workflow.test.md`
- Create: `tests/integration/feature-workflow.test.md`
- Create: `tests/integration/session-resume.test.md`

**Acceptance Criteria**:
- [ ] Test bug fix workflow
- [ ] Test feature workflow
- [ ] Test session resumption
- [ ] All BDD scenarios covered

---

### Task 4.4: Update Documentation
**Priority**: P1 | **Est.**: 2h | **BDD**: N/A

**Files**:
- Update: `README.md`
- Update: `../README.md`
- Create: `docs/MIGRATION-v9-to-v10.md`

**Acceptance Criteria**:
- [ ] README updated for v10
- [ ] Migration guide created
- [ ] Quick reference card updated

---

### Task 4.5: Final Validation
**Priority**: P0 | **Est.**: 2h | **BDD**: All

**Files**:
- All files

**Acceptance Criteria**:
- [ ] All 22 BDD scenarios passing
- [ ] Tool coverage 100%
- [ ] Git safety verified
- [ ] Performance benchmarks met
- [ ] Documentation complete

---

## Dependency Graph

```
Phase 1 (Core Infrastructure)
├── Task 1.1 (lib-orchestration skill) ←─┐
├── Task 1.2 (orchestrator agent) ←──────┤
├── Task 1.3 (memory-keeper) ←───────────┤
├── Task 1.4 (agents command) ←──────────┤
├── Task 1.5 (resume command) ←──────────┘
└── Task 1.6 (git safety hooks)

Phase 2 (Code Agents) - Depends on Phase 1
├── Task 2.1 (code-analyzer)
├── Task 2.2 (code-writer)
├── Task 2.3 (qa-validator)
├── Task 2.4 (security-scanner)
└── Task 2.5 (researcher)

Phase 3 (Support Agents) - Depends on Phase 1
├── Task 3.1 (doc-writer)
├── Task 3.2 (git-operator)
├── Task 3.3 (file-manager)
├── Task 3.4 (task-planner)
├── Task 3.5 (data-engineer update)
└── Task 3.6 (memory init script)

Phase 4 (Integration) - Depends on Phase 1, 2, 3
├── Task 4.1 (scoped commands)
├── Task 4.2 (plugin config)
├── Task 4.3 (integration tests)
├── Task 4.4 (documentation)
└── Task 4.5 (final validation)
```

---

## Progress Tracking

| Task | Status | Assignee | Started | Completed | Notes |
|------|--------|----------|---------|-----------|-------|
| 1.1 | ✅ Done | Claude | 2026-03-01 | 2026-03-01 | lib-orchestration skill + 4 refs |
| 1.2 | ✅ Done | Claude | 2026-03-01 | 2026-03-01 | Orchestrator agent v10 |
| 1.3 | ✅ Done | Claude | 2026-03-01 | 2026-03-01 | Memory-keeper agent |
| 1.4 | ✅ Done | Claude | 2026-03-01 | 2026-03-01 | /dev-stack:agents command |
| 1.5 | ✅ Done | Claude | 2026-03-01 | 2026-03-01 | /dev-stack:resume command |
| 1.6 | ✅ Done | - | - | 2026-03-01 | Already implemented |
| 2.1 | ✅ Done | Claude | 2026-03-01 | 2026-03-01 | code-analyzer agent |
| 2.2 | ✅ Done | Claude | 2026-03-01 | 2026-03-01 | code-writer agent (TDD) |
| 2.3 | ✅ Done | Claude | 2026-03-01 | 2026-03-01 | qa-validator agent |
| 2.4 | ✅ Done | Claude | 2026-03-01 | 2026-03-01 | security-scanner agent |
| 2.5 | ✅ Done | Claude | 2026-03-01 | 2026-03-01 | researcher agent |
| 3.1 | ✅ Done | Claude | 2026-03-01 | 2026-03-01 | doc-writer agent |
| 3.2 | ✅ Done | Claude | 2026-03-01 | 2026-03-01 | git-operator agent |
| 3.3 | ✅ Done | Claude | 2026-03-01 | 2026-03-01 | file-manager agent |
| 3.4 | ✅ Done | Claude | 2026-03-01 | 2026-03-01 | task-planner agent |
| 3.5 | ✅ Done | Claude | 2026-03-01 | 2026-03-01 | data-engineer updated |
| 3.6 | ✅ Done | Claude | 2026-03-01 | 2026-03-01 | shared-memory-init.sh |
| 4.1 | ✅ Done | Claude | 2026-03-01 | 2026-03-01 | 16 scoped commands |
| 4.2 | ✅ Done | Claude | 2026-03-01 | 2026-03-01 | v10.0.0 config |
| 4.3 | ✅ Done | Claude | 2026-03-01 | 2026-03-01 | 3 integration tests |
| 4.4 | ✅ Done | Claude | 2026-03-01 | 2026-03-01 | README + migration guide |
| 4.5 | ✅ Done | Claude | 2026-03-01 | 2026-03-01 | All 22 tasks complete |

**Legend**: ⏳ Pending | 🔄 In Progress | ✅ Done | ❌ Blocked
