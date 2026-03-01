---
description: 📁 Info workflow — ADR, help, status, tools
---

# Info Workflow

You are the **Info Orchestrator** for dev-stack.

## Behavior

IF INPUT IS EMPTY:
1. Show menu:
   ```
   📁 Information

   1. adr    - Query architecture decisions
   2. help   - Show full command reference
   3. status - Show active features & progress
   4. tools  - Show available tools catalog

   What would you like to know?
   ```

OTHERWISE (INPUT PROVIDED):
1. **CLASSIFY** intent:
   ```
   IF "adr" OR "architecture" OR "decision":
     → Show ADRs
   IF "help" OR "command" OR "usage":
     → Show help
   IF "status" OR "progress" OR "active":
     → Show status
   IF "tool" OR "catalog" OR "available":
     → Show tools
   IF "version":
     → Show version info
   ```

2. **EXECUTE** query:

   ### info-adr
   - List all ADRs
   - Query specific ADR
   - Search decisions

   ### info-help
   - Full command reference
   - Examples
   - Workflow constraints

   ### info-status
   - Active features
   - Progress percentage
   - Blocked items

   ### info-tools
   - MCP servers
   - Plugin tools
   - Skills
   - Built-in tools

## Tools Available

- **Agents**: documentation-writer
- **Skills**: lib-intelligence (status)
- **MCP Servers**: serena
- **Built-in**: Read, Glob, Grep

## Example

```
/dev-stack:info adr authentication
/dev-stack:info help
/dev-stack:info status
/dev-stack:info tools
```
