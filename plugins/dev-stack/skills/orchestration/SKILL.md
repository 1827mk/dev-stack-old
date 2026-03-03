# Orchestration Skill (v10.0.0)

Central routing and coordination for dev-stack v10.0.0. This skill provides MODE routing, boot sequences, and team messaging for tool-based agents.

> **Note**: For capability matching and parallel execution, use `skill:lib-orchestration`.

## References

- **[routing.md](references/routing.md)** - MODE routing table, fast-path routing
- **[boot-sequences.md](references/boot-sequences.md)** - Boot sequences for v10 agents
- **[team-messaging.md](references/team-messaging.md)** - Team communication and memory sync
- **[output-formats.md](references/output-formats.md)** - Standard output formats

## Quick Reference

### MODE Routing (v10.0.0)

```
smart   -> CLASSIFY -> capability-based team assembly
dev     -> Full team (all 12 agents available)
plan    -> Read-only: [code-analyzer, researcher, task-planner]
parallel -> Worktree isolation + parallel execution
resume  -> [memory-keeper, orchestrator]
status  -> [memory-keeper]
quality -> [qa-validator, security-scanner] (parallel)
```

### Key Flows (v10.0.0 Tool-Based)

1. **New Feature**:
   ```
   Level 0: [memory-keeper, task-planner, researcher, code-analyzer] (parallel)
   Level 1: [code-writer]
   Level 2: [qa-validator, doc-writer] (parallel)
   ```

2. **Bug Fix**:
   ```
   Level 0: [memory-keeper, code-analyzer] (parallel)
   Level 1: [code-writer]
   Level 2: [qa-validator]
   ```

3. **Security Patch**:
   ```
   Level 0: [memory-keeper, security-scanner, code-analyzer] (parallel)
   Level 1: [code-writer]
   Level 2: [qa-validator]
   ```

4. **Hotfix** (bypasses gates):
   ```
   Level 0: [memory-keeper, code-analyzer]
   Level 1: [code-writer]
   (No qa-validator for speed)
   ```

---

## Performance Optimizations (v10.0.0)

### 1. Parallel Execution by Dependency Level

Independent agents run simultaneously:
- **Level 0** (Parallel): code-analyzer, security-scanner, researcher, file-manager
- **Level 1** (Sequential): code-writer, data-engineer (needs Level 0 context)
- **Level 2** (Sequential): qa-validator, git-operator (needs Level 1 context)

### 2. Fast-Path Routing

Before full classification, check for obvious patterns:
- Direct number -> resume
- Keywords "bug", "fix" -> bug_fix
- Keywords "hotfix", "urgent" -> hotfix
- Keywords "add", "feature" -> new_feature
- Keywords "security", "cve" -> security_patch
- Keywords "spike", "research" -> spike

### 3. Tool Priority (CRITICAL)

```
1️⃣ MCP SERVERS (Highest)
   ├─ mcp__serena__* (code analysis, editing)
   ├─ mcp__memory__* (shared memory)
   ├─ mcp__context7__* (documentation)
   └─ mcp__filesystem__* (file operations)

2️⃣ PLUGINS
   ├─ superpowers (TDD, debugging)
   └─ spec-kit (SDD workflow)

3️⃣ SKILLS
   └─ dev-stack skills

4️⃣ BUILT-IN (Lowest)
   └─ Read, Write, Edit, Glob, Grep, Bash
```

### 4. Workflow-Specific Agent Selection

Not every workflow needs every agent:

| Workflow | Level 0 | Level 1 | Level 2 |
|----------|---------|---------|---------|
| hotfix | memory-keeper, code-analyzer | code-writer | - |
| bug_fix | memory-keeper, code-analyzer | code-writer | qa-validator |
| refactor | memory-keeper, code-analyzer | code-writer | qa-validator |
| security | memory-keeper, security-scanner, code-analyzer | code-writer | qa-validator |
| feature | memory-keeper, task-planner, researcher, code-analyzer | code-writer | qa-validator, doc-writer |

### 5. Quality Gates

| Mode | Checks | When |
|------|--------|------|
| quick | Code quality + critical security | Default |
| full | Complete OWASP + container + CI/CD | security, architecture |
| none | Skip all | spike, hotfix |

---

## Integration with lib-orchestration

This skill works with `skill:lib-orchestration`:

```
orchestration/SKILL.md          → MODE routing, boot sequences
lib-orchestration/SKILL.md      → Capability matching, parallel execution
```

### Usage Pattern

```javascript
// In orchestrator agent:

// 1. Use orchestration skill for routing
const mode = route_mode(user_request);  // From orchestration/SKILL.md

// 2. Use lib-orchestration for team assembly
const team = assemble_team_with_dependencies(capabilities);  // From lib-orchestration/SKILL.md

// 3. Execute with parallel executor
const results = execute_parallel(team, task_context);  // From lib-orchestration/SKILL.md
```

---

## Project Conventions

The orchestrator loads conventions from:
1. `CLAUDE.md` in project root (coding style, patterns, tool preferences)
2. `.specify/memory/constitution.md` (testing framework, architectural style, quality gates)

CLAUDE.md takes precedence for style, constitution for process.

---

*Last updated: 2026-03-02*
*Plugin version: 10.0.0*
