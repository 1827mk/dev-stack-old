# dev-stack v7.0.0

> **One command for everything.** Auto-orchestrates agents, quality gates, and workflow with AI-optimized tool routing.

## Installation

### Option 1: From Local Path (Recommended for now)

```bash
# Add the local marketplace
/plugin marketplace add /Users/tanaphat.oiu/.claude/dev-stack-marketplace

# Install the plugin
/plugin install dev-stack@dev-stack-marketplace
```

### Option 2: From GitHub (After publishing)

```bash
# Add the marketplace from GitHub
/plugin marketplace add YOUR_GITHUB_USERNAME/dev-stack-marketplace

# Install the plugin
/plugin install dev-stack@dev-stack-marketplace
```

### Option 3: Test Locally (Development)

```bash
# Test without installing - loads plugin directly
claude --plugin-dir /Users/tanaphat.oiu/.claude/dev-stack-marketplace/plugins/dev-stack
```

### Verify Installation

```
/plugin
```

Go to **Installed** tab - should show:
```
dev-stack@dev-stack-marketplace (v7.0.0)
```

### First Time Setup

After installation, run in your project:

```
/dev-stack:help
```

This will:
1. Create `.specify/memory/constitution.md` with project conventions
2. Set up the spec directory structure
3. Show available commands

---

## Quick Start

```
/dev-stack build user login feature    -> Full feature workflow
/dev-stack fix auth bug                -> Bug fix with TDD
/dev-stack:plan add user auth          -> Read-only analysis
/dev-stack:status                      -> See progress
```

## Commands

| Command | What it does |
|---------|--------------|
| `/dev-stack {task}` | Main entry - auto-routes to best workflow |
| `/dev-stack:bug {desc}` | Fast bug fix - skip architect |
| `/dev-stack:feature {desc}` | New feature - full team |
| `/dev-stack:hotfix {desc}` | Emergency fix - minimal process |
| `/dev-stack:refactor {desc}` | Code refactoring |
| `/dev-stack:security {desc}` | Security patch - full OWASP |
| `/dev-stack:plan {task}` | Read-only analysis, no code changes |
| `/dev-stack:dev {id}` | Continue feature {id} from last task |
| `/dev-stack:status` | Show all active features |
| `/dev-stack:check` | Run lint + typecheck + build |
| `/dev-stack:review` | Code review changed files |
| `/dev-stack:audit` | Security + code review |
| `/dev-stack:parallel {a,b}` | Run multiple features in parallel |
| `/dev-stack:pr` | Generate PR from completed spec |
| `/dev-stack:drift {id}` | Check if spec drifted from code |
| `/dev-stack:impact {id}` | Analyze change impact |
| `/dev-stack:adr {query}` | Query architecture decisions |
| `/dev-stack:retro {id}` | Run retrospective on completed spec |
| `/dev-stack:snapshot {id}` | Save/restore spec state |
| `/dev-stack:tools` | Show available MCP tools |
| `/dev-stack:help` | Full command reference |

## Agents (11 Specialized Agents)

| Agent | Role | When Invoked |
|-------|------|--------------|
| **orchestrator** | Central router, team assembly, sub-system selection | Every command |
| **domain-analyst** | DDD/BDD spec creation | new_feature, bug_fix, architecture, spike |
| **solution-architect** | Architecture + ADRs | After spec approval |
| **tech-lead** | Task decomposition | After plan approval |
| **senior-developer** | TDD implementation | Per task |
| **qa-engineer** | Test coverage validation | After implementation |
| **quality-gatekeeper** | Unified code quality + security | After all tasks |
| **devops-engineer** | Deployment readiness | Before delivery |
| **team-coordinator** | Agent communication | Throughout workflow |
| **performance-engineer** | Performance optimization | On demand |
| **documentation-writer** | Documentation | On demand |

---

## What's New in v7.0

### 1. AI-Optimized Tool Routing (lib-router)

New `lib-router` skill provides intelligent tool selection:

```
code_read: [mcp__serena__find_symbol, Read]  # Try serena first, fallback to Read
code_edit: [mcp__serena__replace_symbol_body, Edit]
bug_fix: {find: code_read, fix: code_edit, verify: code_refs}
```

### 2. Sub-System Selection

Orchestrator routes to appropriate sub-system based on context:

| Condition | Sub-System | Reason |
|-----------|------------|--------|
| Greenfield + Business Logic | speckit | Structured spec/plan/tasks |
| Legacy + Complex Bug | superpowers | Root cause + TDD |
| Hotfix + Quick Fix | direct agents | Minimal overhead |
| Security Patch | superpowers + direct | OWASP + TDD |

### 3. Dependency Graph Execution

Teams execute using explicit dependency graphs with parallel dispatch:

```
new_feature:
  1: [domain-analyst]
  2: [solution-architect] (after 1)
  3: [tech-lead] (after 2)
  4: [senior-developer] (after 3)
  5: [quality-gatekeeper] (after 4)
  6: [qa-engineer, devops-engineer] (parallel, after 5)
```

### 4. Enhanced Fast-Path Routing

Keyword-based workflow detection with expanded vocabulary:

```
"production down" -> hotfix (immediate)
"security vulnerability" -> security_patch (high confidence)
"spike research poc" -> spike (research mode)
```

### 5. Unified Quality Gatekeeper

Single agent handles both code quality AND security:
- **quick mode**: Code quality + critical security patterns
- **full mode**: Complete OWASP Top 10 + container + CI/CD

---

## Performance Optimizations

### 1. Fast-Path Routing
Keyword-based workflow detection skips full classification:
```
"fix login bug" -> bug_fix (no sequentialthinking needed)
"hotfix urgent" -> hotfix (immediate)
"add new feature" -> new_feature (high confidence)
```

### 2. Workflow-Specific Agent Skipping
Not every workflow needs every agent:

| Workflow | Skipped Agents | Time Saved |
|----------|----------------|------------|
| hotfix | domain-analyst, architect, tech-lead, qa, devops | ~70% |
| bug_fix | solution-architect, devops | ~40% |
| refactor | domain-analyst, qa, devops | ~35% |
| security_patch | domain-analyst, architect, devops | ~30% |

### 3. Quality Gate Modes
- **quick**: Code quality + critical security (default for most workflows)
- **full**: Complete OWASP Top 10 + container + CI/CD (security_patch, architecture)
- **none**: Skip all checks (spike)

### 4. Context Bundle Injection
Agents receive pre-read context instead of re-reading files:
- spec.md, plan.md read once by orchestrator
- BDD scenarios pre-extracted
- Ubiquitous language pre-parsed

### 5. Parallel Agent Dispatch
After quality gate passes, independent agents run in parallel:
```
qa-engineer || devops-engineer     (after quality gate)
```

### 6. Minimal Spec Templates
Bug fixes use streamlined spec template:
- No NFRs section
- No cross-context contracts
- Focus on fix scenario only

---

## Features

### 1. Plan Mode
Read-only analysis before implementation:
```
/dev-stack:plan add user authentication
```
Produces `analysis.md` with impact assessment, affected files, and recommendations.

### 2. Agent Teams
Teammates can message each other during workflow:
- Shared task list visibility
- Handoff coordination
- Message log in `.specify/specs/{id}/team-messages.log`

### 3. Parallel Execution
Run multiple independent features simultaneously:
```
/dev-stack:parallel "add login", "add registration"
```
Creates isolated worktrees for each feature.

### 4. Status Line
Progress shown in status bar during active workflows.

### 5. Checkpointing Awareness
Reminders about `/rewind` capability at key moments.

### 6. Auto Memory Sync
Patterns and insights automatically stored in native memory for future reference.

### 7. Notification Hooks
Desktop notifications when gates pass/fail (macOS and Linux).

### 8. MCP Tool Search Config
Optimized tool search for environments with many MCP servers.

## How it Works

```
/dev-stack "add user auth"
       |
       v
+-------------------------------------+
|  Orchestrator                       |
|  1. Fast-path check (keywords)      |
|  2. [Skip if high confidence]       |
|  3. Classify workflow               |
|  4. Detect context (greenfield/etc) |
|  5. Select sub-system               |
|  6. Build context bundle            |
|  7. Assemble team with dep graph    |
|  8. Execute with parallel dispatch  |
+-------------------------------------+
```

## Project Structure

```
.specify/
+-- memory/
|   +-- constitution.md    # Project conventions (auto-generated)
+-- specs/
    +-- 001-user-auth/
        +-- spec.md        # Requirements + BDD scenarios
        +-- plan.md        # Architecture + ADRs
        +-- tasks.md       # Implementation checklist
        +-- analysis.md    # Plan mode output (optional)
        +-- team-messages.log  # Team communication log
```

## Quality Gates

| Workflow | TDD | BDD | Security | Review | Quality Mode |
|----------|-----|-----|----------|--------|--------------|
| bug_fix | yes | - | quick | yes | quick |
| new_feature | yes | yes | quick | yes | quick |
| refactor | - | - | quick | yes | quick |
| hotfix | - | - | quick | yes | quick |
| architecture | yes | yes | full | yes | full |
| security_patch | yes | - | full | yes | full |
| spike | - | - | - | - | none |

## Approval Gates by Workflow

| Workflow | Human Approval Required |
|----------|------------------------|
| hotfix | None |
| bug_fix | after_spec |
| refactor | after_plan |
| security_patch | after_spec |
| new_feature | after_spec, after_tasks |
| architecture | after_spec, after_plan, after_tasks |
| spike | after_spec |

## Configuration

Add to `.specify/memory/constitution.md`:

```yaml
checkpointing:
  remind_after_gates: true
  remind_before_destructive: true

notifications:
  enabled: true
  events: [gate_pass, workflow_complete]

memory_sync:
  enabled: true
  sync_patterns: true

tool_priority:
  bug_fix:
    primary: mcp__serena__find_symbol
```

## MCP Servers (Optional)

| Server | Use | Required |
|--------|-----|----------|
| `serena` | Symbol-aware code ops | No (falls back to built-in) |
| `memory` | Knowledge graph for patterns | No |
| `context7` | Library docs | No |
| `sequentialthinking` | Semantic analysis | No |

## Skills Architecture (v7.0)

dev-stack is built on modular skills:

| Skill | Purpose |
|-------|---------|
| `orchestration` | MODE routing, team dispatch, output formats |
| `lib-router` | AI-optimized tool mapping and fallback chains |
| `lib-workflow` | Workflow classification, dependency graphs |
| `lib-domain` | DDD/BDD spec authoring |
| `lib-tdd` | Test-driven development cycle |
| `lib-intelligence` | Memory sync, drift detection, impact analysis |

## Integration with CLAUDE.md

dev-stack respects your project's `CLAUDE.md` file. For best results, add:

```markdown
# CLAUDE.md
- Use /dev-stack for all feature work
- Run /dev-stack:check before commits
- Check /dev-stack:status for active work
```

---

**That's it.** Just use `/dev-stack {task}` and let it handle the rest.
