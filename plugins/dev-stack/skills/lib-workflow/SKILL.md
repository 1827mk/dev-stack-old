---
disable-model-invocation: false
user-invokable: false
name: lib-workflow
description: Classify workflow type and return team composition + gate configuration for a given requirement. Use when orchestrator calls skill:lib-workflow(req).
---

# WORKFLOW CLASSIFIER

Semantic classification via `mcp__sequentialthinking__sequentialthinking`:
```
"Analyze this requirement: '{req}'
 Determine workflow_type:
   new_feature:    adds observable user behavior
   bug_fix:        corrects existing behavior (non-urgent)
   hotfix:         production degraded NOW - time-boxed
   refactor:       restructures without behavior change
   security_patch: fixes CVE or OWASP finding
   architecture:   new service, major redesign, or migration
   spike:          research / POC - no production code"
```

---

# WORKFLOW TEAMS & ARTIFACTS

See references/workflow-map.md for full team compositions and artifact requirements.

---

# GATE DEFINITIONS

See references/gates.md for DoR, ArchReview, TaskReady, BDDCoverage, and DoD checklists.

---

# RETURN FORMAT

```
{
  workflow: "{type}",
  team: ["agent1", "agent2||agent3", ...],   // || = parallel
  artifacts: {spec, plan, tasks},
  gates: ["gate_name", ...],
  skip: {agent: reason},  // Optimization: agents to skip
  quality_mode: "quick" | "full" | "none"
}
```

---

# WORKFLOW OPTIMIZATIONS

## Skip Agents by Workflow

| Workflow | Skip These Agents |
|----------|-------------------|
| hotfix | domain-analyst, solution-architect, tech-lead, qa-engineer, devops-engineer |
| bug_fix | solution-architect, devops-engineer |
| refactor | domain-analyst, qa-engineer, devops-engineer |
| security_patch | domain-analyst, solution-architect, devops-engineer |
| spike | all except domain-analyst |

## Quality Mode by Workflow

| Workflow | Quality Mode |
|----------|--------------|
| hotfix | quick |
| bug_fix | quick |
| refactor | quick |
| new_feature | quick |
| security_patch | full |
| architecture | full |
| spike | none |

---

# FAST TEAM LOOKUP

```
GET_TEAM(workflow):
  teams = {
    hotfix: {
      team: ["senior-developer", "quality-gatekeeper"],
      gates: [],
      skip: {domain_analyst: true, architect: true, qa: true, devops: true},
      quality_mode: "quick"
    },
    bug_fix: {
      team: ["domain-analyst", "senior-developer", "quality-gatekeeper", "qa-engineer"],
      gates: ["after_spec"],
      skip: {architect: true, devops: true},
      quality_mode: "quick"
    },
    refactor: {
      team: ["solution-architect", "senior-developer", "quality-gatekeeper"],
      gates: ["after_plan"],
      skip: {domain_analyst: true, qa: true, devops: true},
      quality_mode: "quick"
    },
    security_patch: {
      team: ["senior-developer", "quality-gatekeeper", "qa-engineer"],
      gates: ["after_spec"],
      skip: {domain_analyst: true, architect: true, devops: true},
      quality_mode: "full"
    },
    new_feature: {
      team: ["domain-analyst", "solution-architect", "tech-lead", "senior-developer", "quality-gatekeeper", "qa-engineer", "devops-engineer"],
      gates: ["after_spec", "after_tasks"],
      skip: {},
      quality_mode: "quick"
    },
    architecture: {
      team: ["domain-analyst", "solution-architect", "tech-lead", "senior-developer", "quality-gatekeeper", "qa-engineer", "devops-engineer"],
      gates: ["after_spec", "after_plan", "after_tasks"],
      skip: {},
      quality_mode: "full"
    },
    spike: {
      team: ["domain-analyst"],
      gates: ["after_spec"],
      skip: {architect: true, tech_lead: true, developer: true, reviewer: true, qa: true, devops: true},
      quality_mode: "none"
    }
  }
  RETURN teams[workflow]
```

---

# DEPENDENCY GRAPH

Sequential = agent waits for previous
Parallel = agents run together

new_feature:
  1: [domain-analyst]
  2: [solution-architect] (after 1)
  3: [tech-lead] (after 2)
  4: [senior-developer] (after 3)
  5: [quality-gatekeeper] (after 4)
  6: [qa-engineer, devops-engineer] (parallel, after 5)

bug_fix:
  1: [domain-analyst]
  2: [senior-developer] (after 1)
  3: [quality-gatekeeper] (after 2)
  4: [qa-engineer] (after 3)

hotfix:
  1: [senior-developer]
  2: [quality-gatekeeper] (after 1)

refactor:
  1: [solution-architect]
  2: [senior-developer] (after 1)
  3: [quality-gatekeeper] (after 2)

security_patch:
  1: [senior-developer]
  2: [quality-gatekeeper] (after 1)
  3: [qa-engineer] (after 2)

architecture:
  1: [domain-analyst]
  2: [solution-architect] (after 1)
  3: [tech-lead] (after 2)
  4: [senior-developer] (after 3)
  5: [quality-gatekeeper] (after 4)
  6: [qa-engineer, devops-engineer] (parallel, after 5)

spike:
  1: [domain-analyst]
