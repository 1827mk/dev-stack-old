# Bug Fix Analysis - dev-stack v6.x

**Date**: 2026-03-01
**Target Directory**: /Users/tanaphat.oiu/.claude/dev-stack-marketplace
**Mode**: PLAN (read-only analysis)

---

## Executive Summary

| Priority | Count | Total Effort |
|----------|-------|--------------|
| High | 4 | ~2 hours |
| Medium | 4 | ~1.5 hours |
| Low | 3 | ~1 hour |
| **Total** | **11** | **~4.5 hours** |

**Risk Level**: LOW - All fixes are isolated with no cross-dependencies.

---

## High Priority Bugs

### BUG-001: Missing security_patch Classification in router-core.sh

**Location**: `plugins/dev-stack/hooks/scripts/lib/router-core.sh`
**Lines**: 17-40 (Intent Classification section)

**Issue**:
The bash classifier (`router-core.sh`) does not include pattern matching for `security_patch` workflow. While the orchestrator's FAST_PATH_CHECK (lines 62, 82 in orchestrator.md) recognizes `security_patch`, the shell script lacks the corresponding regex pattern.

**Current State**:
```bash
# Lines 17-40: Has patterns for bug_fix, new_feature, refactor, review, testing, query
# Missing: security_patch pattern matching
```

**Impact**:
- Security-related prompts fall back to `unknown` intent
- Auto-router cannot properly route security issues
- Users must use `/dev-stack:security` command explicitly

**Recommended Fix**:
Add a new elif branch after the `refactor` detection (around line 30):
```bash
elif echo "$prompt" | grep -qiE 'security|vulnerability|cve|owasp|exploit|xss|injection'; then
  intent="security_patch"
  primary_mcp="serena:search"
  secondary_agent="quality-gatekeeper"
  security="true"
```

**Dependencies**: None
**Effort**: 15 minutes
**Risk**: None - additive change only

---

### BUG-002: Environment Variable References in hooks.json

**Location**: `plugins/dev-stack/hooks/hooks.json`
**Line**: 61

**Issue**:
The Notification hook references environment variables `DEV_STACK_EVENT`, `DEV_STACK_SPEC`, and `DEV_STACK_DETAILS` that are never set by any component in the system. These variables would be empty strings when the hook executes.

**Current State**:
```json
"command": "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/notify.sh ${DEV_STACK_EVENT} ${DEV_STACK_SPEC} ${DEV_STACK_DETAILS}"
```

**Impact**:
- Notification hook receives empty arguments
- Desktop notifications show "unknown" for event type and spec ID
- Users get no meaningful feedback from gate pass/fail events

**Root Cause Analysis**:
1. The orchestrator is supposed to set these via `INIT_TEAM_MESSAGING(id)` but that's pseudocode
2. No actual mechanism exists to export these to the hook environment
3. Claude Code hooks run in isolated shell processes

**Recommended Fix**:
Two options:

**Option A (Preferred)**: Read from stdin/arguments passed by the Notification event itself
```json
"command": "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/notify.sh \"$DEV_STACK_EVENT\" \"$DEV_STACK_SPEC\" \"$DEV_STACK_DETAILS\""
```
Note: This still requires the orchestrator to emit proper notification events with these fields.

**Option B**: Use a state file approach
```bash
# notify.sh reads from ~/.claude/dev-stack-state.json
STATE_FILE="$HOME/.claude/dev-stack-state.json"
EVENT=$(jq -r '.last_event // "unknown"' "$STATE_FILE" 2>/dev/null || echo "unknown")
```

**Dependencies**: Requires orchestrator to emit notification events properly
**Effort**: 30-45 minutes (including testing)
**Risk**: Medium - requires coordination between orchestrator and hooks

---

### BUG-003: Inconsistent Confidence Threshold Between routing.md and orchestrator.md

**Location**:
- `skills/orchestration/references/routing.md` line 54
- `agents/orchestrator.md` line 75

**Issue**:
Two different confidence thresholds are documented for fast-path routing:

| File | Threshold | Location |
|------|-----------|----------|
| routing.md | 0.3 | Line 54: `IF confidence >= 0.3:` |
| orchestrator.md | 0.5 | Line 75: `IF fast.confidence >= 0.5:` |

**Impact**:
- Inconsistent behavior depending on which reference is followed
- routing.md threshold (0.3) would route more aggressively
- orchestrator.md threshold (0.5) is more conservative

**Recommended Fix**:
Standardize on **0.5** threshold:
1. Update `routing.md` line 54 to use `0.5`
2. Document the reasoning: "0.5 ensures reasonable confidence before skipping semantic classification"

**Rationale for 0.5**:
- Prevents false positive routing on weak keyword matches
- Sequentialthinking provides better semantic understanding
- 0.5 is a common threshold in ML/information retrieval

**Dependencies**: None
**Effort**: 5 minutes
**Risk**: None - documentation change only

---

### BUG-004: Incorrect security_patch Team Order in workflow-map.md

**Location**: `skills/lib-workflow/references/workflow-map.md` lines 30-35

**Issue**:
The `security_patch` workflow defines the team order as:
```
Team: quality-gatekeeper -> senior-developer -> qa-engineer
```

This is **backwards**. The quality-gatekeeper should review AFTER the senior-developer implements the fix, not before.

**Current Flow (Incorrect)**:
```
quality-gatekeeper (reviews first) -> senior-developer (implements) -> qa-engineer
```

**Expected Flow**:
```
senior-developer (implements fix) -> quality-gatekeeper (validates) -> qa-engineer
```

**Impact**:
- Security patches would be reviewed before any code exists
- Wasted agent invocation
- Confusing workflow execution

**Recommended Fix**:
Update line 31 in `workflow-map.md`:
```markdown
Team: senior-developer -> quality-gatekeeper -> qa-engineer
```

Also update line 35 notes:
```markdown
Notes: Senior-developer implements security fix, quality-gatekeeper validates with full OWASP scan
```

**Dependencies**: None
**Effort**: 5 minutes
**Risk**: None - documentation change only

---

## Medium Priority Bugs

### BUG-005: Missing spike Workflow in router-core.sh

**Location**: `plugins/dev-stack/hooks/scripts/lib/router-core.sh`
**Lines**: 17-40 (Intent Classification section)

**Issue**:
Similar to BUG-001, the `spike` workflow is not recognized by the bash classifier. While documented in routing.md (line 48), the shell script lacks the pattern.

**Impact**:
- Research/POC requests fall back to `unknown` intent
- Users must use explicit commands or sequentialthinking classification

**Recommended Fix**:
Add pattern detection after the `testing` branch:
```bash
elif echo "$prompt" | grep -qiE 'spike|research|poc|proof of concept|investigate|explore'; then
  intent="spike"
  secondary_agent="domain-analyst"
```

**Dependencies**: None
**Effort**: 10 minutes
**Risk**: None - additive change only

---

### BUG-006: Missing Retry Counter Mechanism in GATE

**Location**: `agents/orchestrator.md` lines 192-198

**Issue**:
The GATE pseudocode references a `retry` counter but never defines how it's initialized or incremented:
```python
IF fail AND retry < 2  -> re-dispatch owner with specific gap list
IF fail AND retry >= 2 -> ESCALATE(owner, name)
```

**Impact**:
- No actual retry limiting occurs
- Infinite retry loops possible
- ESCALATE never triggered

**Recommended Fix**:
Define the retry mechanism explicitly:

```python
# In orchestrator state
gate_retries = {}  # {gate_name: count}

GATE(name, owner, result):
  retry_key = f"{name}_{owner}"
  current_retry = gate_retries.get(retry_key, 0)

  check skill:lib-workflow -> #gate_{name}(result)

  IF fail:
    IF current_retry < 2:
      gate_retries[retry_key] = current_retry + 1
      re-dispatch owner with specific gap list
    ELSE:
      gate_retries.pop(retry_key, None)  # Reset for future
      ESCALATE(owner, name)
  ELSE:
    gate_retries.pop(retry_key, None)  # Reset on success
    IF name in approval_gates[workflow] -> [HUMAN APPROVAL] await
    ELSE -> Task: next_agent
```

**Dependencies**: Requires state management (memory MCP)
**Effort**: 30 minutes
**Risk**: Low - internal logic improvement

---

### BUG-007: Inconsistent BUILD_CONTEXT_BUNDLE Field Names

**Location**: `agents/orchestrator.md` lines 147-163

**Issue**:
The `BUILD_CONTEXT_BUNDLE` pseudocode defines field names that may not match what agents expect:

**Defined Fields**:
```python
spec_id, workflow, conventions, quality_mode, skip_agents, spec_path, plan_path, tasks_path
```

**Potential Inconsistencies**:
- `skip_agents` vs `skip` in BOOT_DEV (line 114, 118, 122)
- `spec_path` uses relative path but agents may expect absolute

**Impact**:
- Agents may fail to find expected fields
- Inconsistent path handling

**Recommended Fix**:
1. Rename `skip_agents` to `skip` for consistency
2. Consider making paths absolute:
```python
spec_path: "{cwd}/.specify/specs/{spec_id}/spec.md",
```

**Dependencies**: Requires agent updates for field name changes
**Effort**: 20 minutes
**Risk**: Low - may require agent coordination

---

### BUG-008: Missing Explicit exit 0 in notify.sh

**Location**: `plugins/dev-stack/hooks/scripts/notify.sh`
**Line**: 84 (end of file)

**Issue**:
The script ends at line 84 without an explicit `exit 0`. While the script will exit with the last command's status, explicit exit is best practice for hook scripts.

**Current End**:
```bash
if [[ -n "$EVENT_TYPE" && "$EVENT_TYPE" != "unknown" ]]; then
  send_notification "$EVENT_TYPE" "$SPEC_ID" "$DETAILS"
fi
# No explicit exit
```

**Impact**:
- Minor - script currently works
- Could fail silently if send_notification fails
- Inconsistent with other scripts (session-start.sh has `exit 0`)

**Recommended Fix**:
Add explicit exit at end:
```bash
if [[ -n "$EVENT_TYPE" && "$EVENT_TYPE" != "unknown" ]]; then
  send_notification "$EVENT_TYPE" "$SPEC_ID" "$DETAILS"
fi

exit 0
```

**Dependencies**: None
**Effort**: 2 minutes
**Risk**: None

---

## Low Priority Bugs

### BUG-009: No Debug Logging Option in session-start.sh

**Location**: `plugins/dev-stack/hooks/scripts/session-start.sh`

**Issue**:
The script has no debug logging capability, making troubleshooting difficult when hooks fail silently.

**Impact**:
- Hard to diagnose hook failures
- No visibility into tool catalog discovery
- Cannot trace execution flow

**Recommended Fix**:
Add optional debug mode via environment variable:
```bash
# At top of script
DEBUG="${DEV_STACK_DEBUG:-false}"

debug_log() {
  if [[ "$DEBUG" == "true" ]]; then
    echo "[DEBUG] $1" >&2
  fi
}

# Usage throughout
debug_log "Session source: $SOURCE"
debug_log "Tool count: $TOOL_COUNT"
```

Enable with: `export DEV_STACK_DEBUG=true`

**Dependencies**: None
**Effort**: 15 minutes
**Risk**: None

---

### BUG-010: No Spec ID Format Validation

**Location**: Multiple files that perform spec ID file operations

**Issue**:
No validation of spec ID format before using in file paths. A malformed spec ID could cause:
- Path traversal issues
- Invalid file operations
- Confusing error messages

**Current Pattern**:
```bash
SPEC_DIR="$SPECS_DIR/$SPEC_ID"  # No validation
```

**Impact**:
- Edge case - spec IDs are typically generated
- Could affect manual resume commands

**Recommended Fix**:
Add validation function:
```bash
validate_spec_id() {
  local id="$1"
  # Allow only numeric IDs (001, 002, etc.)
  if [[ ! "$id" =~ ^[0-9]{3,}$ ]]; then
    echo "Invalid spec ID format: $id (expected: NNN)" >&2
    return 1
  fi
  return 0
}
```

**Dependencies**: None
**Effort**: 15 minutes
**Risk**: None

---

### BUG-011: Undocumented Memory Check Skip for Hotfix

**Location**: `agents/orchestrator.md` line 114

**Issue**:
The hotfix workflow skips `memory_check` but the reasoning is not documented:
```python
skip = {impact: true, memory_check: true, architect: true, qa: true, devops: true}
```

**Impact**:
- Future maintainers may not understand the design decision
- Could be mistakenly "fixed" as a bug

**Recommended Fix**:
Add documentation comment:
```python
# Hotfix: Skip memory check because production issues need immediate attention
# and we intentionally allow duplicate hotfix specs for the same issue
skip = {impact: true, memory_check: true, architect: true, qa: true, devops: true}
```

**Dependencies**: None
**Effort**: 5 minutes
**Risk**: None

---

## Dependency Graph

```
BUG-002 (env vars) ──┐
                     │
BUG-006 (retry) ─────┼──> Requires memory MCP integration
                     │
BUG-007 (fields) ────┘

BUG-001 (security_patch) ──┐
BUG-005 (spike) ───────────┴──> Same file, can fix together

BUG-003 (threshold) ──────> Documentation only
BUG-004 (team order) ─────> Documentation only
BUG-008 (exit) ───────────> Isolated
BUG-009 (debug) ──────────> Isolated
BUG-010 (validation) ─────> Isolated
BUG-011 (doc) ────────────> Documentation only
```

---

## Recommended Implementation Order

### Phase 1: High Priority (Do First)
1. **BUG-003** - Threshold documentation (5 min) - Foundation for routing behavior
2. **BUG-004** - Team order documentation (5 min) - Critical for security workflow
3. **BUG-001 + BUG-005** - Add missing classifications (25 min) - Same file, fix together
4. **BUG-002** - Environment variables (45 min) - Most complex, needs testing

### Phase 2: Medium Priority
5. **BUG-008** - Explicit exit (2 min) - Quick win
6. **BUG-006** - Retry counter (30 min) - Important for reliability
7. **BUG-007** - Field names (20 min) - Coordinate with agents

### Phase 3: Low Priority (Nice to Have)
8. **BUG-011** - Document skip reasoning (5 min)
9. **BUG-009** - Debug logging (15 min)
10. **BUG-010** - Spec ID validation (15 min)

---

## Files to Modify

| File | Bugs | Changes |
|------|------|---------|
| `hooks/scripts/lib/router-core.sh` | 001, 005 | Add security_patch, spike patterns |
| `hooks/hooks.json` | 002 | Fix env var references |
| `hooks/scripts/notify.sh` | 008 | Add exit 0 |
| `agents/orchestrator.md` | 003, 006, 007, 011 | Threshold, retry, fields, docs |
| `skills/orchestration/references/routing.md` | 003 | Update threshold |
| `skills/lib-workflow/references/workflow-map.md` | 004 | Fix team order |
| `hooks/scripts/session-start.sh` | 009 | Add debug logging |

---

## Testing Recommendations

1. **BUG-001, BUG-005**: Test with prompts like:
   - "Fix the XSS vulnerability in login form"
   - "Research best practices for GraphQL caching"

2. **BUG-002**: Test notification flow end-to-end:
   - Trigger gate_pass event
   - Verify desktop notification shows correct spec ID

3. **BUG-004**: Test security_patch workflow:
   - Run `/dev-stack:security test CVE fix`
   - Verify senior-developer runs before quality-gatekeeper

4. **BUG-006**: Test retry mechanism:
   - Force gate failure
   - Verify max 2 retries before escalation

---

## Conclusion

All 11 bugs are fixable with minimal risk. The majority (6/11) are documentation or configuration issues. Only BUG-002 (environment variables) and BUG-006 (retry counter) require more substantial implementation work.

**Recommended Approach**: Fix in phases, starting with documentation (BUG-003, BUG-004, BUG-011) to establish correct baseline, then implement code changes.
