---
description: 💾 Resume incomplete task from saved state — reads .specify/ artifacts and restores context
---

# dev-stack:resume

Resume an incomplete task from a previous session.

## Usage

```
/dev-stack:resume [task_id]
```

- `task_id` (optional): Task ID to resume. If not provided, shows available tasks.

---

## Behavior

IF NO TASK_ID PROVIDED:

```
╔═══════════════════════════════════════════════════════════════╗
║                    💾 RESUME TASK                             ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  Available Tasks to Resume:                                   ║
║  ─────────────────────────────────────────────────────────── ║
║                                                               ║
║  ID: 001-dev-stack-enhancements                               ║
║  Status: in_progress                                          ║
║  Progress: 5/12 tasks completed                               ║
║  Last Active: 2026-03-01                                      ║
║                                                               ║
║  ─────────────────────────────────────────────────────────── ║
║                                                               ║
║  Run: /dev-stack:resume 001-dev-stack-enhancements            ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

OTHERWISE, RESUME SPECIFIED TASK:

---

## Resume Workflow

### Step 1: Read SDD Artifacts

```python
# Read all .specify/ files
spec = Read(".specify/spec.md")
plan = Read(".specify/plan.md")
tasks = Read(".specify/tasks.md")

# Parse to understand context
task_context = {
    "feature": spec.feature_name,
    "status": tasks.current_status,
    "completed": tasks.completed_items,
    "pending": tasks.pending_items,
    "next_task": tasks.next_incomplete
}
```

### Step 2: Read Memory Context

```python
# Try MCP memory first
TRY:
  memory_context = mcp__memory__open_nodes({"names": [f"task_{task_id}"]})

CATCH:
  # Fallback to file
  memory_context = Read(f".specify/memory/{task_id}.json")
```

### Step 3: Determine Resume Point

```python
# Find last completed task
for task in tasks.items:
    if task.status != "completed":
        resume_point = task
        break

# Resume from this point
print(f"Resuming from: {resume_point.title}")
```

### Step 4: Restore Team Configuration

```python
# From memory or tasks.md
team = memory_context.team OR tasks.team

# If team not stored, re-assemble based on workflow type
IF not team:
  capabilities = map_capabilities(workflow_type, task_context)
  team = assemble_team(capabilities)
```

### Step 5: Initialize Memory (if needed)

```python
# Check if memory exists
IF not memory_context:
  # Re-initialize from artifacts
  init_memory(task_id, spec.original_request, team)

  # Add progress observations
  for completed in tasks.completed_items:
    write_observation(task_id, {
      "agent": "resume",
      "type": "task_completed",
      "content": f"Previously completed: {completed.title}"
    })
```

### Step 6: Resume Execution

```python
# Continue from resume_point
for task in tasks.pending_items:
  # Spawn appropriate agent
  agent = get_agent_for_task(task)

  Task({
    subagent_type: agent,
    prompt: f"""
      Resuming task: {task.title}

      Task ID: {task_id}

      Context from previous session:
      {read_context(task_id)}

      Your task: {task.description}
    """,
    description: f"Resume: {task.title}"
  })

  # After each task, update tasks.md
  update_task_status(task.id, "completed")
```

---

## Output Format

**RESUME START**
```
┌─────────────────────────────────────────────────┐
│ 💾 Resuming Task: {task_id}                     │
│ Feature: {feature_name}                         │
│ ─────────────────────────────────────────────── │
│ Progress: {completed}/{total} tasks completed   │
│ Next: Task {n} - {next_task_title}              │
│ Team: {agent1}, {agent2}, ...                   │
│ Memory: {task_id}                               │
└─────────────────────────────────────────────────┘
```

**RESUME COMPLETE**
```
┌─────────────────────────────────────────────────┐
│ ✅ Task Resumed Successfully                    │
│ Task ID: {task_id}                              │
│ ─────────────────────────────────────────────── │
│ Resumed from: {resume_point}                    │
│ Remaining: {count} tasks                        │
│ Status: Ready to continue                       │
└─────────────────────────────────────────────────┘
```

---

## Integration with SDD Workflow

### .specify/ Directory Structure

```
.specify/
├── spec.md          # Feature specification (BDD scenarios)
├── plan.md          # Implementation plan (architecture)
├── tasks.md         # Atomic tasks with status
├── memory/
│   └── {task_id}.json  # Memory fallback
└── adr/
    └── 001-*.md     # Architecture decisions
```

### Task Status in tasks.md

```markdown
| Task | Status | Assignee | Started | Completed |
|------|--------|----------|---------|-----------|
| 1.1 | ✅ Done | Claude | 2026-03-01 | 2026-03-01 |
| 1.2 | ✅ Done | Claude | 2026-03-01 | 2026-03-01 |
| 1.3 | 🔄 In Progress | Claude | 2026-03-01 | - |
| 1.4 | ⏳ Pending | - | - | - |
```

Resume continues from first non-completed task.

---

## Memory Restoration

### MCP Memory (Primary)

```json
// mcp__memory__open_nodes result
{
  "name": "task_abc123",
  "entityType": "TaskContext",
  "observations": [
    "Original request: fix login bug",
    "Intent: bug_fix",
    "[code-analyzer] Bug found in auth.ts:45",
    "[code-writer] Fix implemented",
    "[qa-validator] Tests passing"
  ]
}
```

### File Fallback

```json
// .specify/memory/task_abc123.json
{
  "name": "task_abc123",
  "entityType": "TaskContext",
  "observations": [...],
  "status": "in_progress",
  "team": ["code-analyzer", "code-writer", "qa-validator"]
}
```

---

## Error Handling

```
IF .specify/ directory not found:
  └─ ERROR: No saved tasks found. Start with /dev-stack:agents

IF task_id not found:
  └─ ERROR: Task {task_id} not found
  └─ Show available tasks

IF memory corrupted:
  └─ Rebuild from tasks.md
  └─ Warn user about lost observations

IF all tasks completed:
  └─ INFO: Task already completed!
  └─ Show summary
```

---

## Examples

### Example 1: Resume with ID

```
User: /dev-stack:resume 001-dev-stack-enhancements

Output:
┌─────────────────────────────────────────────────┐
│ 💾 Resuming Task: 001-dev-stack-enhancements    │
│ Feature: dev-stack v10.0.0 Dynamic Orchestration│
│ ─────────────────────────────────────────────── │
│ Progress: 5/22 tasks completed                  │
│ Next: Task 1.4 - Create Master Command          │
│ Team: memory-keeper, task-planner, researcher   │
│ Memory: 001-dev-stack-enhancements              │
└─────────────────────────────────────────────────┘

[Continuing from Task 1.4...]
```

### Example 2: Resume without ID

```
User: /dev-stack:resume

Output:
╔═══════════════════════════════════════════════════════════════╗
║                    💾 RESUME TASK                             ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  Available Tasks to Resume:                                   ║
║  ─────────────────────────────────────────────────────────── ║
║                                                               ║
║  1. 001-dev-stack-enhancements (in_progress, 5/22)            ║
║  2. 002-auth-refactor (pending, 0/8)                          ║
║                                                               ║
║  Run: /dev-stack:resume <id>                                  ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

### Example 3: Already Completed

```
User: /dev-stack:resume 003-bugfix-login

Output:
┌─────────────────────────────────────────────────┐
│ ✅ Task Already Completed                       │
│ Task ID: 003-bugfix-login                      │
│ ─────────────────────────────────────────────── │
│ Completed: 2026-02-28                           │
│ Summary: Login bug fixed, tests passing         │
│ Status: No further action needed                │
└─────────────────────────────────────────────────┘
```

---

## Related Commands

- `/dev-stack:session snapshot` - Save current state before switching
- `/dev-stack:session retro` - Review completed task
- `/dev-stack:status` - Check progress without resuming
- `/dev-stack:agents` - Start new task
