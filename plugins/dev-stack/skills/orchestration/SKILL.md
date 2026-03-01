# Orchestration Skill

Central routing and coordination for all dev-stack operations. This skill provides the core orchestration logic used by the orchestrator agent.

## References

- **[routing.md](references/routing.md)** - MODE routing table, fast-path routing, semantic classification
- **[boot-sequences.md](references/boot-sequences.md)** - BOOT_DEV, BOOT_PLAN, BOOT_RESUME, BOOT_PARALLEL, STATUS, RETRO, ADR_QUERY, GATE
- **[team-messaging.md](references/team-messaging.md)** - Team communication, handoffs, and memory sync
- **[output-formats.md](references/output-formats.md)** - Standard output formats for all operations

## Quick Reference

### MODE Routing
```
smart   -> CLASSIFY -> appropriate BOOT
dev     -> BOOT_DEV (force dev workflow)
plan    -> BOOT_PLAN (read-only analysis)
parallel -> BOOT_PARALLEL (worktree isolation)
resume  -> BOOT_RESUME
status  -> STATUS
review  -> quality-gatekeeper
audit   -> quality-gatekeeper (full OWASP)
```

### Key Flows

1. **New Feature**: CLASSIFY -> BOOT_DEV -> domain-analyst -> solution-architect -> tech-lead -> senior-developer -> quality-gatekeeper -> qa-engineer || devops-engineer (parallel)
2. **Bug Fix**: CLASSIFY -> BOOT_DEV -> domain-analyst -> senior-developer -> quality-gatekeeper -> qa-engineer
3. **Hotfix**: CLASSIFY -> BOOT_DEV -> senior-developer -> quality-gatekeeper
4. **Architecture**: CLASSIFY -> BOOT_DEV -> domain-analyst -> solution-architect -> tech-lead -> senior-developer -> quality-gatekeeper -> qa-engineer || devops-engineer (parallel)

---

## Performance Optimizations (v7.0)

### 1. AI-Optimized Tool Routing (lib-router)
Context-aware tool selection with fallback chains:
- Code operations: serena tools -> built-in tools
- Web operations: web_reader -> fetch -> WebSearch
- Intent-based tool chains for each workflow

### 2. Sub-System Selection
Orchestrator routes to appropriate sub-system based on context:
- Greenfield + Business Logic -> speckit
- Legacy + Complex Bug -> superpowers
- Hotfix + Quick Fix -> direct agents
- Security Patch -> superpowers + direct

### 3. Dependency Graph Execution
Teams execute using explicit dependency graphs:
- Sequential: agent waits for previous
- Parallel: independent agents run together
- Example: qa-engineer || devops-engineer after quality gate

### 4. Fast-Path Routing
Before full classification, check for obvious patterns:
- Direct number -> resume
- Keywords "bug", "fix" -> bug_fix
- Keywords "hotfix", "urgent" -> hotfix
- Keywords "add", "feature" -> new_feature
- Keywords "security", "cve" -> security_patch
- Keywords "spike", "research" -> spike

Saves sequentialthinking call for obvious cases.

### 5. Workflow-Specific Agent Skipping
Not every workflow needs every agent:
- hotfix: Skip domain-analyst, architect, tech-lead, qa, devops
- bug_fix: Skip solution-architect, devops
- refactor: Skip domain-analyst, qa, devops
- security_patch: Skip domain-analyst, architect, devops

### 6. Quality Gate Modes
- quick: Code quality + critical security (default)
- full: Complete OWASP + container + CI/CD (security_patch, architecture)
- none: Skip all checks (spike)

### 7. Quality Gatekeeper (Unified)
The quality-gatekeeper handles both code quality AND security in one pass:
- quick mode: Code quality + critical security (default)
- full mode: Complete OWASP + container + CI/CD (security_patch, architecture)

This eliminates the need for separate code-reviewer and security-auditor agents.

### 8. Minimal Templates
- bug_fix: Minimal spec template (no NFRs, no cross-context)
- spike: Findings-only template

---

## Project Conventions

The orchestrator loads conventions from both:
1. `CLAUDE.md` in project root (coding style, patterns, tool preferences)
2. `.specify/memory/constitution.md` (testing framework, architectural style, quality gates)

CLAUDE.md takes precedence for style, constitution for process.
