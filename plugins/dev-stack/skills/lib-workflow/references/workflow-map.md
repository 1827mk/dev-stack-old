# Workflow Map (v7.0)

Teams are dispatched using dependency graphs from lib-workflow.
Sub-system routing (speckit/superpowers) is handled by orchestrator.

## new_feature
Team: domain-analyst -> solution-architect -> tech-lead -> senior-developer -> quality-gatekeeper -> qa-engineer -> devops-engineer
Artifacts: spec:full | plan:full | tasks:full
Quality Mode: quick (code quality + critical security)
Skip: none

## bug_fix
Team: domain-analyst -> senior-developer -> quality-gatekeeper -> qa-engineer
Artifacts: spec:minimal | tasks:simple
Quality Mode: quick
Skip: solution-architect, devops-engineer
Notes: No plan.md needed, minimal spec template

## hotfix
Team: senior-developer -> quality-gatekeeper
Artifacts: tasks:single
Quality Mode: quick
Skip: domain-analyst, solution-architect, tech-lead, qa-engineer, devops-engineer
Notes: Time-boxed, no approval gates, minimal process

## refactor
Team: solution-architect -> senior-developer -> quality-gatekeeper
Artifacts: plan:full | tasks:full
Quality Mode: quick
Skip: domain-analyst, qa-engineer, devops-engineer
Notes: No spec changes needed, existing behavior preserved

## security_patch
Team: senior-developer -> quality-gatekeeper -> qa-engineer
**Execution Order:**
- `senior-developer` implements security fix
- `quality-gatekeeper` validates with full OWASP scan
- `qa-engineer` runs final tests
Artifacts: spec:minimal | tasks:simple
Quality Mode: full (complete OWASP scan)
Skip: domain-analyst, solution-architect, devops-engineer
Notes: Senior-developer implements fix first, then quality-gatekeeper validates with full security mode

## architecture
Team: domain-analyst -> solution-architect -> tech-lead -> senior-developer -> quality-gatekeeper -> qa-engineer -> devops-engineer
Artifacts: spec:full | plan:heavy | tasks:full
Quality Mode: full
Skip: none
Notes: Full process, heavy ADR requirements

## spike
Team: domain-analyst
Artifacts: spec:findings_only
Quality Mode: none
Skip: all other agents
Notes: Research only, no production code

---

## Quality Gatekeeper (Unified)

The quality-gatekeeper agent handles both code quality AND security in a single pass:

- **quick mode**: Code quality + critical security patterns (default)
- **full mode**: Complete OWASP Top 10 + container + CI/CD checks

This consolidation eliminates the need for separate code-reviewer and security-auditor agents.

---

## Parallel Execution Opportunities

After quality-gatekeeper passes:

```
PARALLEL_AGENTS:
  - [qa-engineer, devops-engineer]  # After quality gate pass (if both needed)
```

Implementation:
```
# Dispatch quality-gatekeeper first
Task: quality-gatekeeper with context

# If pass, dispatch remaining agents in parallel
Task[parallel]: qa-engineer with context
Task[parallel]: devops-engineer with context

# Wait for both, merge results
IF both PASS -> continue to delivery
IF any FAIL -> back to senior-developer with gap list
```

---

## Quality Gate Modes

### quick (default for most workflows)
- Code quality checks (SOLID, DRY, naming)
- Critical security patterns only:
  - Hardcoded secrets
  - SQL injection patterns
  - XSS patterns
  - Debug artifacts
- BDD scenario coverage
- Test suite GREEN

### full (security_patch, architecture)
- All quick checks PLUS
- Complete OWASP Top 10 scan
- Docker/container validation
- CI/CD pipeline review
- Infrastructure-as-code review
- Dependency vulnerability check

### none (spike)
- No quality gates
- Just findings documentation

---

## Workflow Decision Tree

```
START
  |
  v
Is production down? --YES--> hotfix
  |
  NO
  |
  v
Is this a security issue? --YES--> security_patch
  |
  NO
  |
  v
Is this research/POC? --YES--> spike
  |
  NO
  |
  v
Changing behavior? --NO--> refactor
  |
  YES
  |
  v
Fixing existing? --YES--> bug_fix
  |
  NO
  |
  v
Major redesign/migration? --YES--> architecture
  |
  NO
  |
  v
new_feature
```
