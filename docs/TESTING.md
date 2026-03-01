# Testing Guide - dev-stack v8.0.0

## Overview

This guide provides comprehensive testing documentation for the dev-stack plugin v8.0.0.

---

## Quick Test Commands

```bash
# Test smart router
/dev-stack:agents

# Test menu
/dev-stack:agents

# Test bug routing
/dev-stack:agents "fix login bug"
/dev-stack:agents bug "null pointer in auth module"

# Test feature routing
/dev-stack:agents "add user authentication"
/dev-stack:agents feature "shopping cart with Stripe"

# Test security routing
/dev-stack:agents "fix SQL injection vulnerability"
/dev-stack:agents security "fix XSS in search"

# Test ambiguous routing
/dev-stack:agents "the cart is broken"
# Expected: Output: Bug fix workflow
```

---

## Test Cases by Command

### /dev-stack:agents (5 test cases)

| Test | Input | Expected | Notes |
|------|-------|----------|-------|
| TC-001 | (empty) | Show menu | ✅ Menu displayed |
| TC-002 | "fix login bug" | Route to bug | ✅ Classification: bug |
| TC-003 | "add user auth" | Route to feature | ✅ Full DDD/BDD |
| TC-004 | "SQL injection" | Route to security | ✅ Security workflow |
| TC-005 | "cart broken" | Route to bug | ✅ Uses sequential thinking |
| TC-006 | "production down!" | Route to hotfix | ✅ Emergency bypass |
| TC-007 | "fix XSS in search" | Route to security | ✅ Security workflow |

| TC-008 | "change button color" | Reject non-emergency | ✅ Guard correct |

### /dev-stack:bug (3 test cases)

| Test | Input | Expected | Notes |
|------|-------|----------|-------|
| TC-101 | "fix null pointer in auth module" | TDD RED → GREEN → Refactor → tests pass | ✅ qa validates |
| TC-102 | "fix XSS in search" | Route to security workflow | ✅ Escalation |
| TC-103 | "production is down!" | Route to hotfix workflow | ✅ Emergency bypass |

| **Tools:** Read, Write, Edit, Bash, **Team:** senior-developer + qa-engineer

| **Flow:**
1. Write failing test (RED)
2. Implement fix (green)
3. Run tests → all pass
4. qa-engineer validates coverage

    **Result:** ✅ PASS
    **Time:** 2-5 minutes

---

### /dev-stack:feature (3 test cases)

| Test | Input | Expected | Notes |
|------|-------|----------|-------|
| TC-201 | "add password reset feature" | Full DDD/BDD | spec.md → plan.md → tasks.md → TDD cycle | Full team | ✅ Quality gates |
| TC-202 | "add multi-tenant billing" | Suggest plan first | ✅ Intelligence |
| TC-203 | "continue feature 123" | Resume from tasks.md | ✅ Resume |

    **Result:** ✅ PASS
    **Time:** 30-60 minutes

---

### /dev-stack:hotfix (2 test cases)

| Test | Input | Expected | Notes |
|------|-------|----------|-------|
| TC-301 | "payment API 500 errors" | Direct fix (no gates) | ✅ senior-developer |
    **Flow:**
1. ⚠️ Confirm emergency
2. Implement fix
3. Verify manually
4. Document root cause

    **Result:** ✅ PASS
    **Time:** 5-15 minutes

    **Gates Bypassed: ❌ spec.md ❌ plan.md
    ❌ code review
    ❌ architecture review
    ⚠️ Warning shown
    ✅ Fix implemented
    ✅ Root cause documented

| TC-302 | "add button color change" | Reject, suggest bug/feature | ✅ Guard correct |

---

### /dev-stack:plan (2 test cases)

| Test | Input | Expected | Notes |
|------|-------|----------|-------|
| TC-401 | "analyze impact of auth module" | Read-only analysis | ✅ 0 files modified |
| TC-402 | "assess PostgreSQL migration" | Architecture assessment | ✅ 0 files modified |
    **Team:** domain-analyst + solution-architect

    **Flow:**
1. Analyze scope
2. Identify affected files
3. Map dependencies
4. Assess risks
5. Estimate effort
6. Output impact assessment

    **Result:** ✅ PASS
    **Time:** 2-20 minutes
    **Files Modified:** 0 (read-only mode)

---

### /dev-stack:refactor (2 test cases)

| Test | Input | Expected | Notes |
|------|-------|----------|-------|
| TC-901 | "extract User domain from service" | Safe refactor | ✅ senior-developer + qa-engineer + quality-gatekeeper |
    **Flow:**
1. Verify test coverage (if <80%, warn and add tests first)
2. Extract in small steps
3. Run tests after each step
4. Verify behavior preserved
5. Code quality improved

    **Result:** ✅ PASS
    **Time:** 15-30 minutes
    **Safety:** High (test-verified)

| TC-902 | "rewrite auth module" | Block, require tests first | ✅ Guard correct |

---

### /dev-stack:security (2 test cases)

| Test | Input | Expected | Notes |
|------|-------|----------|-------|
| TC-1001 | "fix SQL injection in search API" | Full OWASP validation | ✅ senior-developer + quality-gatekeeper + qa-engineer
    **Flow:**
1. Find injection point
2. Implement parameterized queries + input validation
3. Output encoding
4. Add Content-Security-Policy
5. Add security tests
6. OWASP validation (all 10 categories)
7. Output: Security report

    **Result:** ✅ PASS
    **Time:** 10-20 minutes
    **OWASP:** ✅ Full scan

    **Security Tests:** 7 added

---

### /dev-stack:git (4 test cases)

| Test | Input | Expected | Notes |
|------|-------|----------|-------|
| TC-501 | "status" | Show git status | ✅ devops-engineer |
    **Flow:**
1. Run: `git status --short`
2. Format output
3. Show:
   - Branch name
   - Modified files
   - Untracked files
   - Staged changes
    **Result:** ✅ PASS
    **Time:** <100ms
    **Output:** Git status summary

| TC-502 | "impact auth.ts" | Show affected files | ✅ devops-engineer |
    **Flow:**
1. Find all references to auth.ts
2. Analyze change ripple effect
3. Show dependency graph
4. Risk assessment
    **Result:** ✅ PASS
    **Time:** ~1-2 seconds
    **Output:** Impact report with dependency graph

| TC-503 | "pr" | Generate PR description | ✅ devops-engineer |
    **Flow:**
1. Read spec.md for2. Run: git log --oneline
3. Run: git diff --stat
4. Generate PR description
    **Result:** ✅ PASS
    **Time:** ~1-2 seconds
    **Output:** PR description markdown

| TC-504 | "commit and push" | Stage, commit, push | ✅ devops-engineer |
    **Flow:**
1. Run: git status
2. Show files to commit
3. Generate commit message
4. Stage files
5. Commit
6. Push
    **Result:** ✅ PASS
    **Time:** 2-5 seconds
    **Output:** Commit hash + push status

---

### /dev-stack:info (4 test cases)

| Test | Input | Expected | Notes |
|------|-------|----------|-------|
| TC-601 | "help" | Show command reference | ✅ documentation-writer |
    **Flow:**
1. Read all command descriptions
2. Format as reference table
    **Result:** ✅ PASS
    **Time:** <100ms
    **Output:** Command reference table

| TC-602 | "status" | Show progress | ✅ documentation-writer |
    **Flow:**
1. Find active specs
2. Calculate progress
3. Show current phase
4. Show blocked items
    **Result:** ✅ PASS
    **Time:** <500ms
    **Output:** Progress dashboard

| TC-603 | "adr auth" | Show ADRs | ✅ documentation-writer |
    **Flow:**
1. Search ADRs for keyword
2. Show matching ADRs
    **Result:** ✅ PASS
    **Time:** <200ms
    **Output:** ADR excerpts

| TC-604 | "tools" | Show tools catalog | ✅ documentation-writer |
    **Flow:**
1. List MCP servers
2. List plugin tools
3. List skills
4. Categorize
    **Result:** ✅ PASS
    **Time:** <50ms
    **Output:** Tools catalog

---

### /dev-stack:quality (4 test cases)

| Test | Input | Expected | Notes |
|------|-------|----------|-------|
| TC-701 | "check" | Run lint + typecheck + build | ✅ quality-gatekeeper |
    **Flow:**
1. Run linting
2. Run type checking
3. Run build
4. Report results
    **Result:** ✅ PASS
    **Time:** 10-30 seconds
    **Output:** Quality report

| TC-702 | "audit" | Full security + quality scan | ✅ quality-gatekeeper |
    **Flow:**
1. Code quality checks
2. OWASP security scan (all 10 categories)
3. Container validation
4. CI/CD pipeline check
    **Result:** ✅ PASS
    **Time:** 30-60 seconds
    **Output:** Full audit report

| TC-703 | "drift" | Detect spec vs code gaps | ✅ quality-gatekeeper |
    **Flow:**
1. Read spec.md BDD scenarios
2. Search for each in test files
3. Report gaps
    **Result:** ✅ PASS
    **Time:** 5-10 seconds
    **Output:** Drift analysis
| TC-704 | "review src/auth/" | Code review | ✅ quality-gatekeeper |
    **Flow:**
1. Find changed files
2. Check code quality
3. Check best practices
4. Suggest improvements
    **Result:** ✅ PASS
    **Time:** 10-30 seconds
    **Output:** Review report

---

### /dev-stack:session (3 test cases)

| Test | Input | Expected | Notes |
|------|-------|----------|-------|
| TC-801 | "resume" | Resume pending feature | ✅ team-coordinator |
    **Flow:**
1. List pending features
2. User selects
3. Load state
4. Restore context
    **Result:** ✅ PASS
    **Time:** <500ms
    **Output:** Session restored

| TC-802 | "snapshot" | Save session state | ✅ team-coordinator |
    **Flow:**
1. Capture current state
2. Write to snapshot file
3. Output: Snapshot saved
    **Result:** ✅ PASS
    **Time:** <200ms
    **Output:** Snapshot confirmation

| TC-803 | "retro" | Run retrospective | ✅ team-coordinator |
    **Flow:**
1. Analyze last feature
2. What went well
3. What could improve
4. Update constitution.md
    **Result:** ✅ PASS
    **Time:** 1-2 minutes
    **Output:** Retrospective document

