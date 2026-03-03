# Session Resume Integration Test

> **Version**: dev-stack v10.0.0
> **Test Type**: Integration Test
> **BDD Coverage**: Epic 3, Scenario 3.1

---

## Test Objective

Verify that the session resume workflow correctly:
1. Reads .specify/spec.md
2. Reads .specify/plan.md
3. Reads .specify/tasks.md
4. Identifies last incomplete task
5. Restores shared memory context
6. Continues from correct point

---

## Test Setup

### Prerequisites
- dev-stack v10.0.0 plugin installed
- MCP servers available: serena, memory
- Test project with incomplete feature

### Test Data
```
Feature: OAuth2 Authentication (in progress)
Status: Task 3 of 10 incomplete
Last task: Implement Google OAuth provider
Remaining: 7 tasks
```

---

## Test Scenarios

### Scenario 1: State Detection

```gherkin
GIVEN user invokes "/dev-stack:resume"
WHEN resume workflow starts
THEN .specify/spec.md should be read
AND .specify/plan.md should be read
AND .specify/tasks.md should be read
AND last incomplete task should be identified
```

**Verification Steps:**
1. Verify spec.md exists and is read
2. Verify plan.md exists and is read
3. Verify tasks.md exists and is read
4. Check correct task identified as incomplete

---

### Scenario 2: Memory Restoration

```gherkin
GIVEN previous session had shared memory
WHEN resume workflow runs
THEN TaskContext should be restored
AND previous findings should be available
AND agent progress should be visible
```

**Verification Steps:**
1. Call mcp__memory__open_nodes
2. Verify TaskContext entity exists
3. Check observations from previous session
4. Confirm status is "resumed"

---

### Scenario 3: Context Display

```gherkin
GIVEN session state restored
WHEN displaying context to user
THEN feature description should be shown
AND completed tasks should be listed
AND current task should be highlighted
AND remaining tasks should be shown
```

**Verification Steps:**
1. Verify feature name displayed
2. Check completed tasks shown
3. Confirm current task highlighted
4. Verify remaining count correct

---

### Scenario 4: Continuation

```gherkin
GIVEN context restored and displayed
WHEN user confirms continuation
THEN current task should resume
AND appropriate team should be assembled
AND work should continue from saved point
```

**Verification Steps:**
1. Verify correct task resumed
2. Check team assembly matches task needs
3. Confirm no duplicate work done
4. Verify progress continues correctly

---

## Expected Output

```
╔═══════════════════════════════════════════════════════════════╗
║               📋 SESSION RESUME: OAuth2 Authentication         ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  Feature: User authentication with OAuth2                     ║
║  Status: In Progress (Task 3 of 10)                           ║
║                                                               ║
║  ─────────────────────────────────────────────────────────── ║
║                                                               ║
║  ✅ Completed Tasks (2):                                      ║
║     1. Set up OAuth2 library                                  ║
║     2. Create OAuth configuration                             ║
║                                                               ║
║  🔄 Current Task:                                             ║
║     3. Implement Google OAuth provider                        ║
║        • Status: In Progress (30%)                            ║
║        • Assignee: code-writer                                ║
║                                                               ║
║  ⏳ Remaining Tasks (7):                                      ║
║     4. Implement GitHub provider                              ║
║     5. Create callback handlers                               ║
║     6. Update User model                                      ║
║     ... and 4 more                                            ║
║                                                               ║
║  ─────────────────────────────────────────────────────────── ║
║                                                               ║
║  Memory: ✅ Restored (12 observations)                        ║
║  Last Update: 2026-03-01 14:30:00                             ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝

Ready to continue? [Y/n]
```

---

## Pass Criteria

- [ ] All 4 scenarios pass
- [ ] State correctly detected
- [ ] Memory restored successfully
- [ ] Context displayed clearly
- [ ] Continuation works correctly

---

## Performance Benchmarks

| Operation | Target | Actual |
|-----------|--------|--------|
| State detection | < 5s | - |
| Memory restoration | < 3s | - |
| Context display | < 2s | - |
| Full resume | < 15s | - |

---

## Edge Cases

### Case 1: No Previous Session

```gherkin
GIVEN no .specify directory exists
WHEN /dev-stack:resume is invoked
THEN user should be informed
AND available features should be listed
```

### Case 2: All Tasks Complete

```gherkin
GIVEN all tasks are marked complete
WHEN /dev-stack:resume is invoked
THEN completion message should be shown
AND next steps should be suggested
```

### Case 3: Memory Unavailable

```gherkin
GIVEN MCP memory is unavailable
WHEN resume workflow runs
THEN file-based fallback should be used
AND task progress should still be restored
```
