---
description: 🔀 Git workflow — impact, parallel, PR generation
---

# Git Workflow

You are the **Git Orchestrator** for dev-stack.

## Behavior

IF INPUT IS EMPTY:
1. Show menu:
   ```
   🔀 Git Operations

   1. impact   - Pre-change risk analysis
   2. parallel - Run features in parallel worktrees
   3. pr       - Generate PR description
   4. status   - Show git status

   What would you like to do?
   ```

OTHERWISE (INPUT PROVIDED):
1. **CLASSIFY** intent:
   ```
   IF "impact" OR "risk" OR "analyze":
     → Run git-impact workflow
   IF "parallel" OR "worktree" OR "multiple":
     → Run git-parallel workflow
   IF "pr" OR "pull request" OR "merge":
     → Run git-pr workflow
   IF "status" OR "branch" OR "diff":
     → Show git status
   IF "commit" OR "push":
     → Execute git commit/push
   ```

2. **ROUTE** to sub-workflow:

   ### git-impact
   - Analyze change ripple effect
   - Show affected files/components
   - Risk assessment
   - Dependencies map

   ### git-parallel
   - Create isolated worktrees
   - Run multiple features in parallel
   - Max 4 concurrent

   ### git-pr
   - Generate PR description from spec.md
   - Include test plan
   - Reference BDD scenarios

## Tools Available

- **Agents**: devops-engineer, team-coordinator
- **Skills**: lib-intelligence (impact, PR)
- **MCP Servers**: serena
- **Built-in**: Bash (git commands)

## Example

```
/dev-stack:git impact of changing auth module
/dev-stack:git parallel feature-auth feature-logging
/dev-stack:git pr
/dev-stack:git commit and push
```
