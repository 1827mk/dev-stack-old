# dev-stack v6.3.0 Enhancement Spec

**ID:** 001
**Title:** dev-stack UX Enhancements
**Workflow:** new_feature
**Date:** 2026-02-28
**Status:** COMPLETE

## Overview

Enhance dev-stack with 7 new features to improve team collaboration, user experience, and system observability.

## Features

### 1. Agent Teams Support
**Priority:** High
**Type:** Core Enhancement

Teammates can message each other during workflow execution with shared task list visibility.

**Requirements:**
- Agents can send messages to other agents in the team
- Shared task list visible to all team members
- Message log preserved in spec directory
- Integration with orchestrator for team coordination

**BDD Scenarios:**
```gherkin
Feature: Agent Team Communication

  Scenario: Agent sends message to teammate
    Given orchestrator assembled team [analyst, architect, developer]
    When analyst completes domain analysis
    Then analyst sends summary message to architect
    And message is logged to .specify/specs/{id}/team-messages.log

  Scenario: Shared task list access
    Given team is working on spec 001
    When any agent checks task status
    Then they see current progress of all tasks
```

---

### 2. Plan Mode Integration
**Priority:** High
**Type:** New Command

Read-only analysis mode before implementation. Analyzes codebase and produces plan without making changes.

**Requirements:**
- New `/dev-stack:plan {task}` command
- Produces analysis document only, no code changes
- Can be upgraded to full dev workflow
- Output saved to `.specify/specs/{id}/analysis.md`

**BDD Scenarios:**
```gherkin
Feature: Plan Mode

  Scenario: User requests plan-only analysis
    Given user runs /dev-stack:plan "add user auth"
    When orchestrator processes request
    Then analysis.md is created with:
      | Impact assessment |
      | Affected files |
      | Recommended approach |
      | Estimated complexity |
    And no files are modified

  Scenario: Upgrade plan to implementation
    Given analysis.md exists for spec 001
    When user runs /dev-stack:dev 001 --from-plan
    Then workflow continues from plan phase
```

---

### 3. Status Line Integration
**Priority:** Medium
**Type:** Hook Enhancement

Show dev-stack progress in Claude Code status bar.

**Requirements:**
- Hook updates status line during active workflows
- Shows: current phase, agent, task progress
- Integrates with session-start hook

**BDD Scenarios:**
```gherkin
Feature: Status Line

  Scenario: Active workflow shows progress
    Given dev-stack workflow is running
    When any agent is processing
    Then status line shows:
      | dev-stack: {workflow} |
      | Agent: {current_agent} |
      | Phase: {phase} |
      | Tasks: {done}/{total} |
```

---

### 4. Checkpointing Awareness
**Priority:** Medium
**Type:** User Experience

Remind users about /rewind capability at key moments.

**Requirements:**
- Reminder after each gate pass
- Reminder before major code changes
- Include in session-start message
- Configurable via constitution.md

**BDD Scenarios:**
```gherkin
Feature: Checkpointing Awareness

  Scenario: User reminded after gate pass
    Given TDD gate passed
    When proceeding to next phase
    Then reminder shows: "Checkpoint available: /rewind to undo if needed"

  Scenario: Reminder before destructive changes
    Given developer is about to delete/refactor code
    When change is detected
    Then reminder shows: "Consider checkpoint before major changes"
```

---

### 5. Auto Memory Sync
**Priority:** High
**Type:** Intelligence Enhancement

Automatically store patterns and insights in native memory (mcp__memory).

**Requirements:**
- After each phase completion, extract patterns
- Store as entities: Pattern, Insight, LessonLearned
- Link to Spec and BoundedContext
- Queryable via lib-intelligence

**BDD Scenarios:**
```gherkin
Feature: Auto Memory Sync

  Scenario: Pattern extracted after implementation
    Given senior-developer completes task
    When pattern is identified in code
    Then entity created in memory:
      | Type: Pattern |
      | Name: {pattern_name} |
      | Context: {spec_id} |
      | Code: {example} |

  Scenario: Lessons learned stored after retro
    Given retro command completes
    When insights are generated
    Then LessonLearned entities created
    And linked to workflow type
```

---

### 6. Notification Hooks
**Priority:** Medium
**Type:** New Hook

Desktop notifications when gates pass/fail.

**Requirements:**
- New PostToolUse hook for notifications
- Uses native desktop notification (osascript on macOS, notify-send on Linux)
- Notifies on: gate pass/fail, workflow complete, escalation
- Configurable in hooks.json

**BDD Scenarios:**
```gherkin
Feature: Notification Hooks

  Scenario: Gate pass notification
    Given TDD gate passes
    When hook fires
    Then desktop notification shows:
      | Title: dev-stack Gate Passed |
      | Body: TDD gate passed for {spec_id} |

  Scenario: Workflow complete notification
    Given all tasks complete
    When workflow finishes
    Then notification shows:
      | Title: dev-stack Complete |
      | Body: {spec_id}: {title} |
```

---

### 7. MCP Tool Search Config
**Priority:** Low
**Type:** Performance Optimization

Optimize tool search for environments with many MCP servers.

**Requirements:**
- Tool search priority configuration
- Cache frequently used tools
- Parallel tool discovery
- Configurable via plugin.json

**BDD Scenarios:**
```gherkin
Feature: MCP Tool Search Config

  Scenario: Tool search optimized
    Given 10+ MCP servers configured
    When auto-router searches for tools
    Then cached tool list used
    And search completes in <500ms

  Scenario: Priority override
    Given user sets tool priority in config
    When routing decision made
    Then user priority takes precedence
```

---

## Technical Architecture

### New Files

```
plugins/dev-stack/
├── commands/
│   └── plan.md              # Plan mode command
├── hooks/
│   ├── scripts/
│   │   ├── notify.sh        # Desktop notifications
│   │   └── status-line.sh   # Status line updates
│   └── prompts/
│       └── checkpoint-reminder.md
├── skills/
│   └── lib-intelligence/
│       └── references/
│           └── memory-sync.md
└── agents/
    └── team-coordinator.md  # Team messaging coordinator
```

### Modified Files

```
plugins/dev-stack/
├── .claude-plugin/plugin.json     # v6.3.0, new config options
├── hooks/hooks.json               # Add notification hooks
├── agents/orchestrator.md         # Team messaging, plan mode
└── skills/lib-router/SKILL.md     # Tool search optimization
```

---

## Success Criteria

- [ ] All 7 features implemented and tested
- [ ] Backward compatible with v6.2.0
- [ ] Documentation updated
- [ ] No CLAUDE.md modifications
