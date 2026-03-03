# Memory Protocol Reference

> Part of lib-orchestration skill for dev-stack v10.0.0

---

## Overview

Memory protocol defines how agents communicate via MCP memory. This enables coordination, state sharing, and progress tracking.

## Memory Architecture

### High-Level Design

```
┌─────────────────────────────────────────────────────────────────┐
│                     MCP MEMORY SERVER                            │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────────────┐  ┌──────────────────┐  ┌───────────────┐ │
│  │   TaskContext    │  │  AgentFindings   │  │  Relations    │ │
│  │   (Entity)       │──│  (Observations)  │──│  (Edges)      │ │
│  └──────────────────┘  └──────────────────┘  └───────────────┘ │
│                                                                  │
│  ┌──────────────────┐  ┌──────────────────┐                    │
│  │  CodeAnalysis    │  │  TestResults     │                    │
│  │  (Observations)  │  │  (Observations)  │                    │
│  └──────────────────┘  └──────────────────┘                    │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Entity Types

### TaskContext

Primary entity for each task/session.

```json
{
  "name": "task_<uuid>",
  "entityType": "TaskContext",
  "observations": [
    {
      "content": "Original request: fix login bug in auth.ts",
      "timestamp": "2026-03-01T10:00:00Z",
      "agent": "orchestrator"
    },
    {
      "content": "Intent classified as: bug_fix (confidence: 0.9)",
      "timestamp": "2026-03-01T10:00:01Z",
      "agent": "orchestrator"
    },
    {
      "content": "Team assembled: [code-analyzer, code-writer, qa-validator]",
      "timestamp": "2026-03-01T10:00:02Z",
      "agent": "orchestrator"
    }
  ]
}
```

### AgentFinding

Individual agent's findings.

```json
{
  "name": "finding_<agent>_<timestamp>",
  "entityType": "AgentFinding",
  "observations": [
    {
      "content": "Bug found: Null pointer exception in auth.ts:45",
      "timestamp": "2026-03-01T10:05:00Z",
      "agent": "code-analyzer",
      "type": "bug_location",
      "file": "auth.ts",
      "line": 45,
      "severity": "high"
    }
  ]
}
```

---

## Observation Types

### Standard Observation Types

| Type | Description | Required Fields |
|------|-------------|-----------------|
| `task_request` | Original user request | content, timestamp |
| `intent_classification` | Intent classification result | content, intent, confidence |
| `team_assembly` | Team configuration | content, agents |
| `code_finding` | Code analysis finding | content, file, line?, severity? |
| `bug_location` | Bug location | content, file, line, severity |
| `implementation` | Implementation details | content, file, changes |
| `test_result` | Test execution result | content, passed, failed, coverage |
| `security_finding` | Security issue | content, severity, type, file |
| `doc_update` | Documentation update | content, file |
| `git_status` | Git operation status | content, operation, status |
| `completion` | Task completion | content, status, summary |

### Observation Structure

```json
{
  "content": "Human-readable description",
  "timestamp": "ISO-8601 timestamp",
  "agent": "agent-name",
  "type": "observation_type",
  // Optional fields based on type
  "file": "path/to/file",
  "line": 123,
  "severity": "low|medium|high|critical",
  "status": "pending|in_progress|completed|failed"
}
```

---

## Relation Types

### Standard Relations

| Relation | From | To | Description |
|----------|------|-----|-------------|
| `has_finding` | TaskContext | AgentFinding | Task has this finding |
| `caused_by` | BugLocation | CodeFinding | Bug caused by this code |
| `fixed_by` | BugLocation | Implementation | Bug fixed by this change |
| `tested_by` | Implementation | TestResult | Implementation tested by |
| `depends_on` | TaskContext | TaskContext | Task dependency |
| `blocks` | AgentFinding | AgentFinding | Finding blocks another |

---

## Memory Functions

### #init_memory

Initialize shared memory context for a task.

```
FUNCTION #init_memory(task_id, request, team)

INPUT:
  - task_id: string (unique task identifier)
  - request: string (original user request)
  - team: object (team configuration)

OUTPUT:
  {
    "task_entity": "task_<uuid>",
    "status": "initialized",
    "created_at": "ISO-8601"
  }

ALGORITHM:
  1. Generate unique task UUID
  2. Create TaskContext entity with initial observations:
     - Original request
     - Timestamp
     - Team configuration
  3. Create initial relations if needed
  4. RETURN task entity reference

MCP CALL:
  mcp__memory__create_entities({
    "entities": [{
      "name": "task_<uuid>",
      "entityType": "TaskContext",
      "observations": [
        "Original request: <request>",
        "Team: <team.agents>",
        "Status: initialized"
      ]
    }]
  })

FALLBACK:
  IF MCP memory unavailable:
    Write to .specify/memory/<task_id>.json
```

### #write_observation

Write agent finding to shared memory.

```
FUNCTION #write_observation(task_id, observation)

INPUT:
  - task_id: string (task entity name)
  - observation: object
    {
      "content": "Bug found in auth.ts:45",
      "agent": "code-analyzer",
      "type": "bug_location",
      "file": "auth.ts",
      "line": 45,
      "severity": "high"
    }

OUTPUT:
  {
    "status": "written",
    "observation_id": "<auto-generated>"
  }

ALGORITHM:
  1. Format observation as string
  2. Add to TaskContext observations
  3. Optionally create separate AgentFinding entity
  4. Create relation if needed

MCP CALL:
  mcp__memory__add_observations({
    "observations": [{
      "entityName": "task_<id>",
      "contents": [
        "[code-analyzer] Bug found in auth.ts:45 (severity: high)"
      ]
    }]
  })

FALLBACK:
  IF MCP memory unavailable:
    Append to .specify/memory/<task_id>.json
```

### #read_context

Read task context from memory.

```
FUNCTION #read_context(task_id)

INPUT:
  - task_id: string (task entity name)

OUTPUT:
  {
    "task": { /* TaskContext entity */ },
    "findings": [ /* All related findings */ ],
    "status": "current status",
    "progress": { /* Progress info */ }
  }

ALGORITHM:
  1. Read TaskContext entity
  2. Search for related AgentFinding entities
  3. Parse observations into structured data
  4. Calculate progress if possible

MCP CALL:
  // Read main task
  mcp__memory__open_nodes({
    "names": ["task_<id>"]
  })

  // Search for related findings
  mcp__memory__search_nodes({
    "query": "task_<id>"
  })

FALLBACK:
  IF MCP memory unavailable:
    Read from .specify/memory/<task_id>.json
```

### #update_status

Update task status in memory.

```
FUNCTION #update_status(task_id, status, message)

INPUT:
  - task_id: string
  - status: "pending" | "in_progress" | "completed" | "failed"
  - message: string (status message)

OUTPUT:
  { "status": "updated" }

MCP CALL:
  mcp__memory__add_observations({
    "observations": [{
      "entityName": "task_<id>",
      "contents": [
        "[orchestrator] Status: <status> - <message>"
      ]
    }]
  })
```

### #query_findings

Query findings by type or agent.

```
FUNCTION #query_findings(task_id, filter={})

INPUT:
  - task_id: string
  - filter: object
    {
      "type": "bug_location",  // optional
      "agent": "code-analyzer", // optional
      "severity": "high"        // optional
    }

OUTPUT:
  [ /* Array of matching findings */ ]

MCP CALL:
  mcp__memory__search_nodes({
    "query": "<task_id> <filter.type or ''> <filter.agent or ''>"
  })
```

---

## Memory Workflow

### Task Initialization

```
1. Orchestrator receives request
2. Orchestrator calls #init_memory
3. Memory creates TaskContext entity
4. All subsequent agents use task_id to coordinate
```

### Agent Communication

```
1. Agent reads context: #read_context(task_id)
2. Agent does work
3. Agent writes findings: #write_observation(task_id, {...})
4. Next agent reads updated context
```

### Progress Tracking

```
1. Orchestrator periodically reads context
2. Calculates progress from observations
3. Updates status line
4. Reports to user
```

### Session Resume

```
1. User runs /dev-stack:resume <task_id>
2. Orchestrator reads context: #read_context(task_id)
3. Restores state from observations
4. Continues from last incomplete step
```

---

## Fallback Storage

### File-Based Fallback

When MCP memory is unavailable:

```
.specify/memory/
├── task_<uuid>.json       # TaskContext
├── finding_<id>.json      # AgentFindings
└── relations.json         # Relations
```

### Fallback Format

```json
// .specify/memory/task_abc123.json
{
  "name": "task_abc123",
  "entityType": "TaskContext",
  "observations": [
    {
      "content": "Original request: fix login bug",
      "timestamp": "2026-03-01T10:00:00Z",
      "agent": "orchestrator"
    }
  ],
  "relations": [
    {
      "to": "finding_code-analyzer_20260301-1005",
      "type": "has_finding"
    }
  ]
}
```

### Fallback Functions

```python
def fallback_write(task_id, observation):
    """Write to file when MCP unavailable"""
    path = f".specify/memory/{task_id}.json"

    # Read existing
    if os.path.exists(path):
        with open(path) as f:
            data = json.load(f)
    else:
        data = {"name": task_id, "entityType": "TaskContext", "observations": []}

    # Add observation
    observation["timestamp"] = datetime.now().isoformat()
    data["observations"].append(observation)

    # Write back
    with open(path, 'w') as f:
        json.dump(data, f, indent=2)
```

---

## Memory Cleanup

### Task Completion

```
FUNCTION #archive_task(task_id)

1. Mark TaskContext as completed
2. Add final summary observation
3. Optionally export to long-term storage
4. Keep in memory for 7 days (configurable)

MCP CALL:
  mcp__memory__add_observations({
    "observations": [{
      "entityName": "task_<id>",
      "contents": ["[orchestrator] Task completed successfully"]
    }]
  })
```

### Memory Expiry

```
Tasks older than EXPIRY_DAYS:
  1. Export to archive
  2. Delete from active memory
  3. Keep reference in index
```

---

## Examples

### Example 1: Initialize Task

```
// Orchestrator
task_id = "task_abc123"
result = init_memory(task_id, "fix login bug", {
  "agents": ["code-analyzer", "code-writer", "qa-validator"]
})

// Memory state:
{
  "name": "task_abc123",
  "entityType": "TaskContext",
  "observations": [
    "Original request: fix login bug",
    "Team: [code-analyzer, code-writer, qa-validator]",
    "Status: initialized"
  ]
}
```

### Example 2: Code Analyzer Finding

```
// Code-analyzer
write_observation("task_abc123", {
  "content": "Bug found: Null check missing",
  "agent": "code-analyzer",
  "type": "bug_location",
  "file": "auth.ts",
  "line": 45,
  "severity": "high"
})

// Memory state updated:
{
  "observations": [
    ...previous...,
    "[code-analyzer] Bug found: Null check missing (auth.ts:45, severity: high)"
  ]
}
```

### Example 3: Read Context for Next Agent

```
// Code-writer starts
context = read_context("task_abc123")

// Returns:
{
  "task": {...},
  "findings": [
    {
      "type": "bug_location",
      "file": "auth.ts",
      "line": 45,
      "content": "Null check missing",
      "severity": "high"
    }
  ],
  "status": "in_progress"
}

// Code-writer now knows what to fix
```

### Example 4: QA Validation

```
// QA-validator
write_observation("task_abc123", {
  "content": "Tests passing: 5/5",
  "agent": "qa-validator",
  "type": "test_result",
  "passed": 5,
  "failed": 0,
  "coverage": "85%"
})

// Orchestrator sees progress and can complete task
```

---

## Integration with Serena Memory

Serena also has memory tools for project-specific knowledge:

```python
# Serena project memory (persistent)
mcp__serena__write_memory("auth/login-patterns", "Login flow uses JWT...")
mcp__serena__read_memory("auth/login-patterns")

# MCP memory (session/task-scoped)
mcp__memory__create_entities([...])
mcp__memory__add_observations([...])
```

**Distinction:**
- **MCP Memory**: Task-scoped, for inter-agent communication
- **Serena Memory**: Project-scoped, for long-term knowledge

---

## Testing

```gherkin
Scenario: Initialize task memory
  Given task_id "task_test"
  When init_memory is called
  Then TaskContext entity should exist
  And observations should include original request

Scenario: Write agent finding
  Given task memory initialized
  When code-analyzer writes bug_location finding
  Then TaskContext should have new observation
  And observation should include file and line

Scenario: Read context for agent
  Given task memory with findings
  When read_context is called
  Then all findings should be returned
  And status should be current

Scenario: Fallback when MCP unavailable
  Given MCP memory is down
  When write_observation is called
  Then data should be written to .specify/memory/
  And no error should occur
```

---

## Error Handling

```
IF mcp__memory__* fails:
  1. Log error
  2. Switch to file-based fallback
  3. Continue operation
  4. Retry MCP periodically
  5. Sync fallback to MCP when available
```
