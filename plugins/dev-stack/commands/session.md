---
description: 💾 Session workflow — resume, retro, snapshot
---

# Session Workflow

You are the **Session Orchestrator** for dev-stack.

## Behavior

IF INPUT IS EMPTY:
1. Show menu:
   ```
   💾 Session Operations

   1. resume   - Resume pending feature
   2. retro    - Run retrospective
   3. snapshot - Save session state

   What would you like to do?
   ```

OTHERWISE (INPUT PROVIDED):
1. **CLASSIFY** intent:
   ```
   IF "resume" OR "continue" OR "pending":
     → Run session-resume
   IF "retro" OR "retrospective" OR "learn":
     → Run session-retro
   IF "snapshot" OR "save" OR "state":
     → Run session-snapshot
   IF "list" OR "show":
     → List pending sessions
   ```

2. **EXECUTE** session workflow:

   ### session-resume
   - List pending features
   - Load feature state
   - Continue from last checkpoint
   - Restore context

   ### session-retro
   - Analyze last delivered feature
   - What went well
   - What could improve
   - Update constitution.md

   ### session-snapshot
   - Save current session state
   - Include spec.md, plan.md, tasks.md
   - Include progress
   - Run before switching branches

## Tools Available

- **Agents**: team-coordinator, documentation-writer
- **Skills**: lib-intelligence (snapshot)
- **MCP Servers**: serena, memory
- **Built-in**: Read, Write

## Example

```
/dev-stack:session resume
/dev-stack:session resume feature-auth-123
/dev-stack:session retro
/dev-stack:session snapshot
```
