# Quality Gate Definitions

## DoR — Definition of Ready [after domain-analyst]
- spec.md exists
- Zero `[NEEDS CLARIFICATION]` items
- Every story has exactly 3 BDD scenarios (happy + edge + error)
- ubiquitous_language table populated
- Aggregates have invariants listed
- NFRs are measurable
- Out of Scope stated explicitly
- Zero HOW (no implementation details)

## ArchReview [after solution-architect]
- plan.md exists
- ADR for every significant technical decision
- No ADR conflicts with existing `mcp__memory ArchDecision` entities
- Layer boundaries defined

## TaskReady [after tech-lead]
- Every task has: BDD ref + `[test-first]` tag + single layer + ≤4h estimate
- Sequence: domain → application → infrastructure → interface
- Task entities written to `mcp__memory`

## BDDCoverage [after qa-engineer]
- Every BDD scenario has an automated test
- Exact scenario titles match test descriptions
- Full test suite GREEN

## DoD — Definition of Done [final]
- DoR + ArchReview + TaskReady all PASS
- All tasks `[x]`
- Compile + lint + typecheck PASS
- BDDCoverage PASS
- Security: zero CRITICAL or HIGH findings
- Code review: APPROVED
- All gate results recorded in `mcp__memory`
