# Bug Fix Workflow Integration Test

> **Version**: dev-stack v10.0.0
> **Test Type**: Integration Test
> **BDD Coverage**: Epic 2, Scenarios 2.1-2.3

---

## Test Objective

Verify that the bug fix workflow correctly:
1. Classifies bug type and severity
2. Assembles appropriate team dynamically
3. Executes TDD cycle (RED-GREEN-REFACTOR)
4. Writes findings to shared memory
5. Enforces Git safety policy

---

## Test Setup

### Prerequisites
- dev-stack v10.0.0 plugin installed
- MCP servers available: serena, memory, context7
- Test project with sample bug

### Test Data
```
Bug: Login fails when email contains plus sign (+)
File: src/auth/LoginService.ts
Expected: Email validation should allow + character
```

---

## Test Scenarios

### Scenario 1: Bug Classification

```gherkin
GIVEN user invokes "/dev-stack:bug login fails when email contains plus sign"
WHEN bug workflow starts
THEN intent should be classified as "bug_fix"
AND severity should be "medium"
AND bug type should be "logic"
```

**Verification Steps:**
1. Check shared memory for TaskContext entity
2. Verify observations contain correct classification
3. Confirm team assembly triggered

---

### Scenario 2: Team Assembly

```gherkin
GIVEN bug classified as "logic" type
WHEN team is assembled
THEN code-analyzer should be spawned
AND code-writer should be spawned
AND qa-validator should be spawned
```

**Verification Steps:**
1. Check Task tool invocations
2. Verify correct subagent types spawned
3. Confirm no unnecessary agents spawned

---

### Scenario 3: TDD Cycle Execution

```gherkin
GIVEN team assembled for bug fix
WHEN implementation proceeds
THEN failing test should be written first (RED)
AND fix should be implemented (GREEN)
AND all tests should pass
```

**Verification Steps:**
1. Check test file exists before fix
2. Run tests - should fail initially
3. Verify fix implemented
4. Run tests - should pass

---

### Scenario 4: Shared Memory Integration

```gherkin
GIVEN bug fix completed
WHEN agents report findings
THEN observations should be added to TaskContext
AND findings should include root cause
AND findings should include fix details
```

**Verification Steps:**
1. Call mcp__memory__open_nodes for TaskContext
2. Verify observations contain "[code-analyzer] [root_cause]"
3. Verify observations contain "[code-writer] [fix_applied]"
4. Verify observations contain "[qa-validator] [tests_passing]"

---

### Scenario 5: Git Safety Policy

```gherkin
GIVEN bug fix requires commit
WHEN git commit is attempted
THEN user confirmation should be required
AND commit should only proceed after confirmation
```

**Verification Steps:**
1. Attempt git commit via git-operator
2. Verify confirmation dialog appears
3. Confirm commit not executed without confirmation
4. Confirm commit executed after confirmation

---

## Expected Output

```
┌─────────────────────────────────────────────────┐
│ 🐛 BUG FIX WORKFLOW REPORT                      │
│ Task: bug_fix_login_email                       │
│ ─────────────────────────────────────────────── │
│                                                 │
│ Classification:                                 │
│ • Type: logic                                   │
│ • Severity: medium                              │
│                                                 │
│ Team:                                           │
│ • code-analyzer: Root cause found               │
│ • code-writer: Fix implemented                  │
│ • qa-validator: All tests passing               │
│                                                 │
│ TDD Cycle:                                      │
│ • RED: Test written ✅                          │
│ • GREEN: Fix applied ✅                         │
│ • Tests: 5/5 passing ✅                         │
│                                                 │
│ Memory: Updated ✅                              │
│ Git: Requires confirmation ⚠️                   │
└─────────────────────────────────────────────────┘
```

---

## Pass Criteria

- [ ] All 5 scenarios pass
- [ ] Shared memory contains all findings
- [ ] TDD cycle verified (RED → GREEN)
- [ ] Git safety enforced
- [ ] No errors in execution

---

## Performance Benchmarks

| Operation | Target | Actual |
|-----------|--------|--------|
| Bug classification | < 5s | - |
| Team assembly | < 3s | - |
| Analysis phase | < 30s | - |
| Full workflow | < 3 min | - |
