# Migration Guide: v9.0.0 → v10.0.0

> **Version**: dev-stack v10.0.0
> **Date**: 2026-03-01
> **Audience**: Existing dev-stack users

---

## Overview

dev-stack v10.0.0 represents a **major architectural shift** from workflow-based to tool-based agents. This guide helps you migrate your existing workflows and understand the new capabilities.

---

## Key Changes Summary

| Aspect | v9.0.0 | v10.0.0 |
|--------|--------|---------|
| **Architecture** | Workflow-Based | Tool-Based |
| **Agent Selection** | Fixed teams per workflow | Dynamic team assembly |
| **Communication** | File-based | Shared memory (MCP) |
| **Tool Priority** | None | MCP > Plugins > Skills > Built-in |
| **Git Safety** | Basic | Full confirmation policy |
| **Commands** | 12 | 16 (+4 new) |
| **Agents** | 12 workflow agents | 12 tool-based agents |

---

## Breaking Changes

### 1. Agent Structure Changed

**v9.0.0** (Workflow-Based):
```
domain-analyst → solution-architect → tech-lead → senior-developer
```

**v10.0.0** (Tool-Based):
```
orchestrator → [code-analyzer, code-writer, qa-validator] (dynamic)
```

### 2. New Commands

| Command | Purpose |
|---------|---------|
| `/dev-stack:research` | External research (library docs, web) |
| `/dev-stack:docs` | Documentation generation |
| `/dev-stack:data` | Database/migration operations |

### 3. Shared Memory Required

v10 uses MCP memory for inter-agent communication. Ensure `memory` MCP server is configured.

---

## Migration Steps

### Step 1: Update Plugin

```bash
# Pull latest version
cd ~/.claude/plugins/cache/dev-stack-marketplace/dev-stack
git pull origin main

# Or reinstall
claude-code plugin install dev-stack
```

### Step 2: Configure MCP Memory

Add to your `.mcp.json`:

```json
{
  "mcpServers": {
    "memory": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-memory"]
    }
  }
}
```

### Step 3: Initialize Shared Memory

```bash
# Run memory init script
./plugins/dev-stack/hooks/scripts/shared-memory-init.sh
```

### Step 4: Update Commands

Update your command usage:

| Old (v9) | New (v10) |
|----------|-----------|
| `/dev-stack:bug fix login` | Same (enhanced with memory) |
| `/dev-stack:feature add auth` | Same (dynamic team) |
| `/dev-stack:plan analyze X` | Same (read-only) |
| N/A | `/dev-stack:research React hooks` |
| N/A | `/dev-stack:docs generate API` |
| N/A | `/dev-stack:data create migration` |

---

## Command Mapping

### Unchanged Commands

These commands work the same way (but with enhanced internals):

- `/dev-stack:agents` - Smart router
- `/dev-stack:bug` - Bug fix workflow
- `/dev-stack:feature` - Feature workflow
- `/dev-stack:hotfix` - Emergency fixes
- `/dev-stack:plan` - Read-only analysis
- `/dev-stack:refactor` - Code refactoring
- `/dev-stack:security` - Security patches
- `/dev-stack:git` - Git operations
- `/dev-stack:info` - Information queries
- `/dev-stack:quality` - Quality checks
- `/dev-stack:session` - Session management

### New Commands (v10)

```bash
# Research external resources
/dev-stack:research React useEffect cleanup

# Generate documentation
/dev-stack:docs generate API for UserService

# Database operations
/dev-stack:data create users table
/dev-stack:data migrate to PostgreSQL
```

---

## Workflow Changes

### Bug Fix Workflow

**v9.0.0:**
```
domain-analyst → senior-developer → quality-gatekeeper → qa-engineer
```

**v10.0.0:**
```
orchestrator → code-analyzer (finds root cause)
            → code-writer (TDD fix)
            → qa-validator (verifies)
            → memory (coordinates)
```

### Feature Workflow

**v9.0.0:**
```
domain-analyst → solution-architect → tech-lead → senior-developer → quality-gatekeeper → qa-engineer
```

**v10.0.0:**
```
orchestrator → task-planner (decomposition)
            → code-analyzer (research)
            → code-writer (TDD)
            → qa-validator (tests)
            → security-scanner (OWASP)
            → doc-writer (docs)
            → memory (coordinates)
```

---

## Tool Priority Changes

### v9.0.0
- No explicit priority
- Tools used randomly

### v10.0.0
```
1️⃣ MCP (Primary)
   └─ serena, memory, context7, filesystem, doc-forge

2️⃣ Plugins
   └─ superpowers

3️⃣ Skills
   └─ dev-stack skills

4️⃣ Built-in (Fallback)
   └─ Read, Write, Edit, Bash
```

**Example:**
```yaml
# Code reading
v9:  Read file → search with Grep
v10: mcp__serena__find_symbol → fallback to Read

# Documentation
v9:  Write file with markdown
v10: mcp__doc-forge__* tools → fallback to Write
```

---

## Git Safety Policy

### New Confirmation Requirements

v10 requires user confirmation for:

```bash
git commit          # ⚠️ New in v10
git push            # ⚠️ New in v10
git reset --hard    # ⚠️ New in v10
git commit --amend  # ⚠️ New in v10
git push --force    # ⚠️ New in v10
```

### How to Confirm

When prompted:
```
⚠️ Ready to commit?
   • 3 files changed
   • +150 lines, -20 lines
   
Confirm to proceed? [Y/n]
```

---

## Shared Memory Protocol

### New Concepts

**TaskContext Entity:**
```json
{
  "name": "task_20260301_fix_login",
  "entityType": "TaskContext",
  "observations": [
    "Intent: bug_fix",
    "Original request: fix login bug",
    "[code-analyzer] Root cause: regex too strict",
    "[code-writer] Fix applied"
  ]
}
```

### Agent Findings

All agents now write to shared memory:

```javascript
mcp__memory__add_observations({
  "observations": [{
    "entityName": "task_20260301_fix_login",
    "contents": [
      "[code-analyzer] [root_cause] Found in LoginService.ts:45",
      "[code-writer] [fix_applied] Updated regex pattern"
    ]
  }]
})
```

---

## Troubleshooting

### Issue: Memory MCP Not Available

**Symptom:** "MCP memory unavailable" warning

**Solution:**
```bash
# Install memory MCP
npm install -g @anthropic-ai/mcp-memory

# Add to .mcp.json
{
  "mcpServers": {
    "memory": {
      "command": "mcp-memory"
    }
  }
}
```

### Issue: Serena Tools Not Working

**Symptom:** "Falling back to built-in tools"

**Solution:**
```bash
# Ensure serena MCP is configured
# Check .mcp.json has serena server configured
```

### Issue: Git Operations Blocked

**Symptom:** Git commands require confirmation

**Solution:**
This is expected behavior in v10. Confirm the operation when prompted, or use:
```bash
# Direct git command (bypasses dev-stack)
git commit -m "message"
```

---

## Rollback

If you need to rollback to v9.0.0:

```bash
# Uninstall v10
claude-code plugin uninstall dev-stack

# Install v9
claude-code plugin install dev-stack@9.0.0
```

---

## Support

- **Issues**: https://github.com/anthropics/dev-stack/issues
- **Documentation**: This file + README.md
- **Migration Help**: Open an issue with `[migration]` tag

---

*Last updated: 2026-03-01*
*Version: 10.0.0*
