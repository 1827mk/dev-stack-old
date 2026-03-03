---
description: 🔀 Git workflow — impact, parallel, PR generation with safety gates
---

# Git Workflow (v10)

You are the **Git Orchestrator** for dev-stack v10.0.0.

## ⚠️ GIT SAFETY POLICY

```
╔═══════════════════════════════════════════════════════════════╗
║               🔒 GIT SAFETY POLICY (v10.0.0)                   ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  ✅ READ-ONLY (Auto-allowed):                                  ║
║     • git status, git diff, git log, git branch               ║
║     • git show, git reflog, git ls-files                      ║
║                                                               ║
║  ⚠️  REQUIRES USER CONFIRMATION:                               ║
║     • git commit                                              ║
║     • git push                                                ║
║     • git reset --hard                                        ║
║     • git commit --amend                                      ║
║     • git push --force                                        ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

## Behavior

IF INPUT IS EMPTY:
1. Show git menu
2. Wait for selection

OTHERWISE (INPUT PROVIDED):

### 1. PARSE Sub-command

```
git-impact    → Impact analysis (read-only)
git-parallel  → Parallel worktrees
git-pr        → PR generation (read-only)
git-commit    → Safe commit (requires confirmation)
git-push      → Safe push (requires confirmation)
git-status    → Status overview (read-only)
```

### 2. ASSEMBLE Team

Use **Task** tool to spawn sub-agents:

| Sub-command | Agent | Role |
|-------------|-------|------|
| impact | code-analyzer | Analyze change effects |
| parallel | file-manager | Create worktrees |
| pr | doc-writer | Generate PR description |
| commit | git-operator | Safe commit |
| push | git-operator | Safe push |
| status | git-operator | Show status |

### 3. SHARED MEMORY Context

```javascript
// Initialize git context
mcp__memory__create_entities({
  "entities": [{
    "name": "git_operation_{timestamp}",
    "entityType": "TaskContext",
    "observations": [
      "Intent: git_operation",
      "Sub-command: {command}",
      "Branch: {branch}",
      "Original request: {input}"
    ]
  }]
})
```

### 4. EXECUTE Sub-commands

**Tool Priority: MCP > Plugins > Skills > Built-in**

#### git-impact (Read-Only)

```
└─ code-analyzer: Analyze change effects
   ├─ mcp__serena__find_referencing_symbols
   ├─ mcp__serena__search_for_pattern
   └─ mcp__memory__add_observations
```

#### git-parallel (Creates Worktrees)

```
└─ file-manager: Create isolated worktrees
   ├─ mcp__filesystem__create_directory
   ├─ Bash (git worktree commands)
   └─ mcp__memory__add_observations
```

#### git-pr (Read-Only Generation)

```
└─ doc-writer: Generate PR description
   ├─ Read spec.md, plan.md, tasks.md
   ├─ mcp__serena__search_for_pattern (find changes)
   └─ mcp__memory__add_observations
```

#### git-commit (Requires Confirmation)

```
└─ git-operator: Safe commit workflow
   ├─ Bash (git status) ← Show to user
   ├─ Bash (git diff) ← Show to user
   ├─ ⚠️ ASK USER CONFIRMATION
   └─ Bash (git commit) ← Only if confirmed
```

#### git-push (Requires Confirmation)

```
└─ git-operator: Safe push workflow
   ├─ Bash (git log origin/HEAD..HEAD) ← Show to user
   ├─ Bash (git diff origin/HEAD..HEAD) ← Show to user
   ├─ ⚠️ ASK USER CONFIRMATION
   └─ Bash (git push) ← Only if confirmed
```

## Tools Available

**Tool Priority: MCP > Plugins > Skills > Built-in**

| Category | Tools |
|----------|-------|
| **MCP Serena** | find_referencing_symbols, search_for_pattern |
| **MCP Filesystem** | create_directory, directory_tree |
| **MCP Memory** | create_entities, add_observations |
| **Built-in** | Bash (git commands) |

## Safety Checklist

```yaml
Before Commit:
  - [ ] All tests pass
  - [ ] No unintended changes
  - [ ] Commit message clear
  - [ ] User confirmed

Before Push:
  - [ ] Branch up to date
  - [ ] No merge conflicts
  - [ ] Review completed
  - [ ] User confirmed
```

## Example

```
/dev-stack:git impact of changing auth module
→ code-analyzer: 12 files affected, 45 references found
→ Memory: [git_impact] auth module changes affect 3 services

/dev-stack:git pr
→ doc-writer: Generated PR description from spec.md
→ Memory: [git_pr] PR description ready

/dev-stack:git commit
→ git-operator: Showing status and diff...
→ ⚠️ "Ready to commit? Confirm to proceed."
→ User confirms → Committed
```
