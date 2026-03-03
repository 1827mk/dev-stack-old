# Feature Workflow Integration Test

> **Version**: dev-stack v10.0.0
> **Test Type**: Integration Test
> **BDD Coverage**: Epic 1, Scenarios 1.1-1.3

---

## Test Objective

Verify that the feature workflow correctly:
1. Creates spec.md with BDD scenarios
2. Creates plan.md with ADRs
3. Creates tasks.md with dependencies
4. Executes TDD implementation
5. Runs quality gates
6. Updates shared memory

---

## Test Setup

### Prerequisites
- dev-stack v10.0.0 plugin installed
- MCP servers available: serena, memory, context7, sequentialthinking
- Test project with .specify directory

### Test Data
```
Feature: User authentication with OAuth2
Providers: Google, GitHub
Requirements: Login, logout, session management
```

---

## Test Scenarios

### Scenario 1: Domain Analysis

```gherkin
GIVEN user invokes "/dev-stack:feature add OAuth2 authentication"
WHEN feature workflow starts
THEN domain-analyst should create spec.md
AND spec.md should contain BDD scenarios
AND BDD scenarios should follow Given/When/Then format
```

**Verification Steps:**
1. Check .specify/spec.md exists
2. Verify BDD scenarios present
3. Confirm ubiquitous language defined
4. Check bounded context identified

---

### Scenario 2: Architecture Design

```gherkin
GIVEN spec.md is complete
WHEN architecture phase runs
THEN solution-architect should create plan.md
AND plan.md should contain ADRs
AND dependencies should be mapped
```

**Verification Steps:**
1. Check .specify/plan.md exists
2. Verify ADRs documented
3. Confirm layer design complete
4. Check technology decisions documented

---

### Scenario 3: Task Breakdown

```gherkin
GIVEN plan.md is complete
WHEN task planning phase runs
THEN task-planner should create tasks.md
AND tasks should be atomic (<= 4 hours each)
AND dependencies should be defined
```

**Verification Steps:**
1. Check .specify/tasks.md exists
2. Verify all tasks have acceptance criteria
3. Confirm dependency graph valid
4. Check total effort estimate reasonable

---

### Scenario 4: TDD Implementation

```gherkin
GIVEN tasks.md is complete
WHEN implementation phase runs
THEN code-writer should follow RED-GREEN-REFACTOR
AND failing tests should be written first
AND minimal implementation should pass tests
```

**Verification Steps:**
1. Verify test file created before implementation
2. Run tests - should fail initially (RED)
3. Verify implementation added
4. Run tests - should pass (GREEN)
5. Check code coverage >= 80%

---

### Scenario 5: Quality Gates

```gherkin
GIVEN implementation is complete
WHEN quality gates run
THEN qa-validator should verify test coverage
AND security-scanner should check OWASP patterns
AND all quality gates should pass
```

**Verification Steps:**
1. Check test coverage report
2. Verify no OWASP issues found
3. Confirm lint passes
4. Check typecheck passes

---

### Scenario 6: Shared Memory Integration

```gherkin
GIVEN feature workflow complete
WHEN checking shared memory
THEN TaskContext should exist
AND all agent findings should be recorded
AND status should be "completed"
```

**Verification Steps:**
1. Call mcp__memory__open_nodes
2. Verify observations from all agents
3. Confirm final status recorded
4. Check completion timestamp

---

## Expected Output

```
┌─────────────────────────────────────────────────┐
│ ✨ FEATURE WORKFLOW REPORT                      │
│ Feature: OAuth2 Authentication                  │
│ ─────────────────────────────────────────────── │
│                                                 │
│ Phase 1 - Domain Analysis: ✅                   │
│ • spec.md created with 8 BDD scenarios          │
│ • Bounded context: authentication               │
│                                                 │
│ Phase 2 - Architecture: ✅                      │
│ • plan.md with 3 ADRs                           │
│ • Dependencies mapped                           │
│                                                 │
│ Phase 3 - Tasks: ✅                             │
│ • 10 tasks across 3 phases                      │
│ • Total estimate: 12 hours                      │
│                                                 │
│ Phase 4 - Implementation: ✅                    │
│ • TDD: RED → GREEN → REFACTOR                   │
│ • Coverage: 85%                                 │
│                                                 │
│ Phase 5 - Quality Gates: ✅                     │
│ • Tests: 42/42 passing                          │
│ • Security: No OWASP issues                     │
│ • Lint: Pass                                    │
│                                                 │
│ Memory: Updated ✅                              │
│ Status: Complete ✅                             │
└─────────────────────────────────────────────────┘
```

---

## Pass Criteria

- [ ] All 6 scenarios pass
- [ ] spec.md with BDD scenarios created
- [ ] plan.md with ADRs created
- [ ] tasks.md with dependencies created
- [ ] TDD cycle verified
- [ ] Quality gates passed
- [ ] Shared memory updated

---

## Performance Benchmarks

| Operation | Target | Actual |
|-----------|--------|--------|
| Domain analysis | < 2 min | - |
| Architecture design | < 3 min | - |
| Task breakdown | < 2 min | - |
| Full workflow | < 30 min | - |
