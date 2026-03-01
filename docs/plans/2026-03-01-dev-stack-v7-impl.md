# dev-stack v7.0 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Refactor dev-stack to be a Resource Orchestrator with context-aware tool selection and dependency-based dispatch.

**Architecture:** Layered router with orchestrator → lib-router → sub-systems (speckit/superpowers/direct agents). No file creation from orchestrator.

**Tech Stack:** Claude Code plugin system, MCP tools (serena, memory, sequentialthinking), Skills

---

## Phase 1: Core Skills Refactor

### Task 1: Update lib-router/SKILL.md - Context-Aware Tool Mappings

**Files:**
- Modify: `plugins/dev-stack/skills/lib-router/SKILL.md`

**Step 1: Replace entire file with AI-optimized format**

```markdown
---
disable-model-invocation: false
user-invokable: false
name: lib-router
description: Tool router. Call skill:lib-router(intent) to get tool chain.
---

# TOOL MAP

code_read: [mcp__serena__find_symbol, mcp__serena__get_symbols_overview, Read]
code_edit: [mcp__serena__replace_symbol_body, mcp__serena__insert_after_symbol, Edit]
code_refs: [mcp__serena__find_referencing_symbols, Grep]
file_find: [mcp__serena__find_file, Glob]
dir_list: [mcp__serena__list_dir, Bash:ls]
web_fetch: [mcp__web_reader__webReader, mcp__fetch__fetch, WebSearch]
doc_read: [mcp__doc-forge__document_reader, Read]
memory: [mcp__memory__create_entities, mcp__memory__search_nodes, mcp__memory__read_graph]
think: [mcp__sequentialthinking__sequentialthinking]

# INTENT → TOOLS

bug_fix: {find: code_read, fix: code_edit, verify: code_refs}
new_feature: {explore: code_read, design: code_edit, test: Bash}
refactor: {analyze: code_refs, transform: code_edit}
review: {scan: code_read, check: Grep}
security: {audit: code_read, report: Write}

# SUB-SYSTEM ROUTING

greenfield: speckit
legacy_bug: superpowers
hotfix: direct
security: superpowers+direct

# EXECUTION

1. GET intent from orchestrator
2. LOOKUP tool chain
3. TRY tools in order until success
4. RETURN result
```

**Step 2: Commit**

```bash
git add plugins/dev-stack/skills/lib-router/SKILL.md
git commit -m "refactor(lib-router): AI-optimized context-aware tool mapping

- Compact format for token efficiency
- Context-aware selection (code→serena, web→fetch)
- Sub-system routing hints

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

### Task 2: Update lib-workflow/SKILL.md - Dependency Graphs

**Files:**
- Modify: `plugins/dev-stack/skills/lib-workflow/SKILL.md`

**Step 1: Add DEP_GRAPH section after FAST TEAM LOOKUP**

Add after line 127:

```markdown
---

# DEPENDENCY GRAPH

Sequential = agent waits for previous
Parallel = agents run together

new_feature:
  1: [domain-analyst]
  2: [solution-architect] (after 1)
  3: [tech-lead] (after 2)
  4: [senior-developer] (after 3)
  5: [quality-gatekeeper] (after 4)
  6: [qa-engineer, devops-engineer] (parallel, after 5)

bug_fix:
  1: [domain-analyst]
  2: [senior-developer] (after 1)
  3: [quality-gatekeeper] (after 2)
  4: [qa-engineer] (after 3)

hotfix:
  1: [senior-developer]
  2: [quality-gatekeeper] (after 1)

refactor:
  1: [solution-architect]
  2: [senior-developer] (after 1)
  3: [quality-gatekeeper] (after 2)

security_patch:
  1: [senior-developer]
  2: [quality-gatekeeper] (after 1)
  3: [qa-engineer] (after 2)

architecture:
  1: [domain-analyst]
  2: [solution-architect] (after 1)
  3: [tech-lead] (after 2)
  4: [senior-developer] (after 3)
  5: [quality-gatekeeper] (after 4)
  6: [qa-engineer, devops-engineer] (parallel, after 5)

spike:
  1: [domain-analyst]
```

**Step 2: Fix security_patch team order in FAST TEAM LOOKUP**

Change line 101-106 from:
```markdown
security_patch: {
  team: ["quality-gatekeeper", "senior-developer", "qa-engineer"],
```

To:
```markdown
security_patch: {
  team: ["senior-developer", "quality-gatekeeper", "qa-engineer"],
```

**Step 3: Commit**

```bash
git add plugins/dev-stack/skills/lib-workflow/SKILL.md
git commit -m "refactor(lib-workflow): add dependency graphs, fix security_patch order

- Add DEPENDENCY GRAPH section for dispatch logic
- Fix security_patch: senior-developer before quality-gatekeeper
- Enable parallel dispatch for independent agents

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

### Task 3: Update orchestrator.md - Sub-System Selection

**Files:**
- Modify: `plugins/dev-stack/agents/orchestrator.md`

**Step 1: Add SUB_SYSTEM_SELECTION section after MODE ROUTING**

Add after line 42:

```markdown
---

# SUB-SYSTEM SELECTION

dev-stack routes to appropriate sub-system based on task context:

| Condition | Sub-System | Reason |
|-----------|------------|--------|
| Greenfield + Business Logic | speckit | Structured spec/plan/tasks |
| Legacy + Complex Bug | superpowers | Root cause + TDD |
| Hotfix + Quick Fix | direct agents | Minimal overhead |
| Security Patch | superpowers + direct | OWASP + TDD |

**IMPORTANT:** dev-stack does NOT create files. Sub-systems handle file creation.

```
SUB_SYSTEM_ROUTE(workflow, context):
  IF workflow == new_feature AND context.is_greenfield:
    RETURN "speckit"
  IF workflow == bug_fix AND context.is_legacy:
    RETURN "superpowers"
  IF workflow == hotfix:
    RETURN "direct"
  IF workflow == security_patch:
    RETURN "superpowers+direct"
  IF workflow == refactor:
    RETURN "direct"
  RETURN "speckit"  # Default for structured work
```
```

**Step 2: Update BOOT_DEV to use sub-system routing**

Replace BOOT_DEV section (lines 90-139) with:

```markdown
---

# BOOT_DEV (v7.0)

```
BOOT_DEV(req, workflow_hint=None):
  IF req is numeric -> load spec {req} -> jump to first pending task

  # Classify workflow
  IF workflow_hint:
    workflow = workflow_hint
  ELSE:
    fast = FAST_PATH_CHECK(req)
    workflow = fast.workflow IF fast.confidence >= 0.5 ELSE CLASSIFY(req).workflow

  # Detect context for sub-system selection
  context = {
    is_greenfield: detect_greenfield(),
    is_legacy: detect_legacy_code(),
    has_business_logic: detect_business_logic(req)
  }

  # Route to sub-system
  sub_system = SUB_SYSTEM_ROUTE(workflow, context)

  # Get team and gates
  {team, gates, dep_graph} <- skill:lib-workflow(workflow)

  # Record in memory (NO file creation)
  mcp__memory__create_entities: TeamFormation {id: next_NNN, workflow, agents: team, sub_system}

  # Dispatch based on sub-system
  IF sub_system == "speckit":
    INJECT: "Use speckit.specify -> speckit.plan -> speckit.tasks"
    Task: team[0] with {workflow, sub_system: "speckit"}

  ELSE IF sub_system == "superpowers":
    INJECT: "Use superpowers:brainstorming -> superpowers:writing-plans"
    Task: team[0] with {workflow, sub_system: "superpowers"}

  ELSE:
    # Direct agent dispatch with dependency graph
    DISPATCH_BY_DEP_GRAPH(team, dep_graph)

  emit FORMATION
```
```

**Step 3: Add DISPATCH_BY_DEP_GRAPH function**

Add after BOOT_DEV:

```markdown
---

# DISPATCH_BY_DEP_GRAPH

```
DISPATCH_BY_DEP_GRAPH(team, dep_graph):
  FOR each level in dep_graph:
    IF level has single agent:
      Task: agent with context
      WAIT for completion
      UPDATE context with result

    ELSE IF level has multiple agents (parallel):
      FOR each agent in level:
        Task[parallel]: agent with context
      WAIT_ALL
      MERGE results into context

    GATE check after each level if applicable
```
```

**Step 4: Remove BUILD_CONTEXT_BUNDLE (no longer needed)**

Delete lines 143-164 (BUILD_CONTEXT_BUNDLE section)

**Step 5: Commit**

```bash
git add plugins/dev-stack/agents/orchestrator.md
git commit -m "refactor(orchestrator): v7.0 sub-system selection, no file creation

- Add SUB_SYSTEM_SELECTION (speckit/superpowers/direct)
- Update BOOT_DEV to route to sub-systems
- Add DISPATCH_BY_DEP_GRAPH for dependency-based dispatch
- Remove BUILD_CONTEXT_BUNDLE (sub-systems handle context)
- dev-stack no longer creates files

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Phase 2: Hooks Cleanup

### Task 4: Fix hooks.json Environment Variables

**Files:**
- Modify: `plugins/dev-stack/hooks/hooks.json`

**Step 1: Read current hooks.json**

Run: `Read plugins/dev-stack/hooks/hooks.json`

**Step 2: Fix Notification hook command**

Find the Notification hook and change from:
```json
"command": "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/notify.sh ${DEV_STACK_EVENT} ${DEV_STACK_SPEC} ${DEV_STACK_DETAILS}"
```

To:
```json
"command": "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/notify.sh"
```

The script will read from a state file instead.

**Step 3: Commit**

```bash
git add plugins/dev-stack/hooks/hooks.json
git commit -m "fix(hooks): remove undefined env vars from notification hook

DEV_STACK_EVENT/SPEC/DETAILS were never set.
Script will read from state file instead.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

### Task 5: Update notify.sh to Use State File

**Files:**
- Modify: `plugins/dev-stack/hooks/scripts/notify.sh`

**Step 1: Add state file reading at the top**

After shebang, add:
```bash
STATE_FILE="$HOME/.claude/dev-stack-state.json"

# Read from state file if args not provided
if [[ -z "$1" ]]; then
  EVENT_TYPE=$(jq -r '.last_event // "unknown"' "$STATE_FILE" 2>/dev/null || echo "unknown")
  SPEC_ID=$(jq -r '.last_spec // ""' "$STATE_FILE" 2>/dev/null || echo "")
  DETAILS=$(jq -r '.last_details // ""' "$STATE_FILE" 2>/dev/null || echo "")
else
  EVENT_TYPE="${1:-unknown}"
  SPEC_ID="${2:-}"
  DETAILS="${3:-}"
fi
```

**Step 2: Add exit 0 at end**

Add at the end of file:
```bash
exit 0
```

**Step 3: Commit**

```bash
git add plugins/dev-stack/hooks/scripts/notify.sh
git commit -m "fix(notify): read from state file, add exit 0

- Read from ~/.claude/dev-stack-state.json if no args
- Add explicit exit 0 for strict mode

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

### Task 6: Update router-core.sh - Add Missing Classifications

**Files:**
- Modify: `plugins/dev-stack/hooks/scripts/lib/router-core.sh`

**Step 1: Add security_patch detection**

After refactor detection (around line 30), add:
```bash
elif echo "$prompt" | grep -qiE 'security|vulnerability|cve|owasp|exploit|xss|injection'; then
  intent="security_patch"
  primary_mcp="serena:search"
  secondary_agent="quality-gatekeeper"
  security="true"
```

**Step 2: Add spike detection**

After security detection, add:
```bash
elif echo "$prompt" | grep -qiE 'spike|research|poc|proof of concept|investigate|explore'; then
  intent="spike"
  secondary_agent="domain-analyst"
```

**Step 3: Commit**

```bash
git add plugins/dev-stack/hooks/scripts/lib/router-core.sh
git commit -m "fix(router-core): add security_patch and spike classifications

- Add security keyword detection (cve, owasp, xss, injection)
- Add spike keyword detection (research, poc, investigate)

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Phase 3: Documentation Update

### Task 7: Update workflow-map.md - Fix Team Orders

**Files:**
- Modify: `plugins/dev-stack/skills/lib-workflow/references/workflow-map.md`

**Step 1: Fix security_patch team order**

Find security_patch section and change:
```markdown
Team: quality-gatekeeper -> senior-developer -> qa-engineer
```

To:
```markdown
Team: senior-developer -> quality-gatekeeper -> qa-engineer
```

**Step 2: Add note about sub-system routing**

Add at the top:
```markdown
# Workflow Map (v7.0)

Teams are dispatched using dependency graphs from lib-workflow.
Sub-system routing (speckit/superpowers) is handled by orchestrator.
```

**Step 3: Commit**

```bash
git add plugins/dev-stack/skills/lib-workflow/references/workflow-map.md
git commit -m "docs(workflow-map): fix security_patch team order, add v7.0 note

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

### Task 8: Update routing.md - Unify Confidence Threshold

**Files:**
- Modify: `plugins/dev-stack/skills/orchestration/references/routing.md`

**Step 1: Find confidence threshold reference**

Change:
```
IF confidence >= 0.3:
```

To:
```
IF confidence >= 0.5:
```

**Step 2: Add explanation**

Add comment:
```
# Threshold 0.5: ensures reasonable confidence before skipping semantic classification
```

**Step 3: Commit**

```bash
git add plugins/dev-stack/skills/orchestration/references/routing.md
git commit -m "docs(routing): unify confidence threshold to 0.5

Matches orchestrator.md threshold.
0.5 ensures reasonable confidence before skipping classification.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

### Task 9: Update plugin.json Version

**Files:**
- Modify: `plugins/dev-stack/.claude-plugin/plugin.json`

**Step 1: Bump version**

Change:
```json
"version": "6.3.0"
```

To:
```json
"version": "7.0.0"
```

**Step 2: Commit**

```bash
git add plugins/dev-stack/.claude-plugin/plugin.json
git commit -m "chore: bump to v7.0.0

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Phase 4: Final Verification

### Task 10: Verify All Changes

**Step 1: Run git status**

Run: `git status`

Expected: All changes committed

**Step 2: Review commit log**

Run: `git log --oneline -10`

Expected: See all 10 commits

**Step 3: Verify file contents**

Run: `Read plugins/dev-stack/agents/orchestrator.md | grep -A5 "SUB_SYSTEM"`

Expected: See SUB_SYSTEM_SELECTION section

---

## Summary

| Phase | Tasks | Commits |
|-------|-------|---------|
| 1. Core Skills | 3 | 3 |
| 2. Hooks Cleanup | 3 | 3 |
| 3. Documentation | 3 | 3 |
| 4. Verification | 1 | 0 |
| **Total** | **10** | **9** |

**Files Modified:**
- `skills/lib-router/SKILL.md`
- `skills/lib-workflow/SKILL.md`
- `agents/orchestrator.md`
- `hooks/hooks.json`
- `hooks/scripts/notify.sh`
- `hooks/scripts/lib/router-core.sh`
- `skills/lib-workflow/references/workflow-map.md`
- `skills/orchestration/references/routing.md`
- `.claude-plugin/plugin.json`
