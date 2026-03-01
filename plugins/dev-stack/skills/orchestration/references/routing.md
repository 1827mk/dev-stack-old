# Orchestration Routing

Read MODE from the calling command file, then:

| MODE | Action |
|------|--------|
| `smart` | CLASSIFY(arguments) - analyze context, pick full route |
| `dev` | BOOT_DEV(arguments) - skip classifier, force dev workflow |
| `plan` | BOOT_PLAN(arguments) - read-only analysis, no code changes |
| `parallel` | BOOT_PARALLEL(arguments) - run multiple features simultaneously in isolated worktrees |
| `resume` | BOOT_RESUME(arguments) |
| `status` | STATUS(arguments) |
| `review` | Task: quality-gatekeeper {scope: arguments} |
| `audit` | Task: quality-gatekeeper {scope: arguments, full_owasp: true} |
| `snapshot` | skill:lib-intelligence -> #snapshot_capture(arguments) |
| `pr` | skill:lib-intelligence -> #pr() |
| `drift` | skill:lib-intelligence -> #drift(arguments) |
| `retro` | RETRO(arguments) |
| `adr` | ADR_QUERY(arguments) |
| `impact` | skill:lib-intelligence -> #impact(arguments) |

---

## FAST-PATH ROUTING

Before full CLASSIFY via sequentialthinking, try pattern-based routing:

```
FAST_PATH_CHECK(args):
  # Direct resume by number
  IF args matches /^\d+$/:
    RETURN {action: BOOT_RESUME, id: args}

  # Status check
  IF args matches /^(status|progress)$/i:
    RETURN {action: STATUS}

  # Keyword-based workflow hints
  keywords = tokenize(args.lower())

  workflow_hints = {
    hotfix: ["hotfix", "urgent", "production down", "asap", "critical", "outage"],
    bug_fix: ["bug", "fix", "broken", "error", "crash", "not working", "fails"],
    new_feature: ["add", "feature", "new", "implement", "create", "build"],
    refactor: ["refactor", "restructure", "clean up", "improve", "optimize"],
    security_patch: ["security", "vulnerability", "cve", "owasp", "exploit"],
    architecture: ["architecture", "redesign", "migrate", "major change"],
    spike: ["spike", "research", "poc", "proof of concept", "investigate"]
  }

  FOR each (workflow, hints) in workflow_hints:
    IF any(hint in keywords for hint in hints):
      confidence = count_matches(keywords, hints) / len(hints)
      # Threshold 0.5: ensures reasonable confidence before skipping semantic classification
      IF confidence >= 0.5:
        RETURN {action: BOOT_DEV, workflow: workflow, confidence: confidence}

  RETURN {action: CLASSIFY_FULL}  # Fall back to sequentialthinking
```

---

## CLASSIFY

Semantic intent routing - no regex, any language:

```
CLASSIFY(msg):
  # Try fast-path first
  fast = FAST_PATH_CHECK(msg)
  IF fast.action != CLASSIFY_FULL:
    IF fast.confidence >= 0.5:
      RETURN fast  # High confidence, skip full classification

  # Fall back to semantic classification
  mcp__sequentialthinking__sequentialthinking:
    "Analyze meaning of: '{msg}'
     intent: [dev|bug|resume|review|audit|status|snapshot|pr|drift|retro|adr|impact|unknown]
     workflow_type if dev/bug: [new_feature|bug_fix|hotfix|refactor|architecture|security_patch|spike]
     confidence: [high|medium|low]"

  route by intent -> appropriate BOOT or action
  unknown -> ask ONE clarifying question
```

---

## DIRECT COMMAND SHORTCUTS

For common workflows, provide direct commands that bypass classification:

| Command | Action |
|---------|--------|
| `/dev-stack:bug {desc}` | BOOT_DEV with workflow=bug_fix |
| `/dev-stack:feature {desc}` | BOOT_DEV with workflow=new_feature |
| `/dev-stack:hotfix {desc}` | BOOT_DEV with workflow=hotfix |
| `/dev-stack:refactor {desc}` | BOOT_DEV with workflow=refactor |
| `/dev-stack:security {desc}` | BOOT_DEV with workflow=security_patch |

These commands set `workflow_hint` parameter to skip classification entirely.

---

## Approval Gates by Workflow

| Workflow | Gates requiring human approval |
|----------|-------------------------------|
| `hotfix` | none |
| `bug_fix` | after_spec |
| `refactor` | after_plan |
| `security_patch` | after_spec |
| `new_feature` | after_spec, after_tasks |
| `architecture` | after_spec, after_plan, after_tasks |
| `spike` | after_spec |

---

## Workflow-Specific Optimizations

| Workflow | Skip Impact | Skip Architect | Skip QA | Skip DevOps | Quality Mode |
|----------|-------------|----------------|---------|-------------|--------------|
| hotfix | YES | YES | YES | YES | quick |
| bug_fix | light | YES | NO | YES | quick |
| refactor | NO | NO | NO | YES | quick |
| security_patch | NO | NO | NO | NO | full |
| new_feature | NO | NO | NO | NO | quick |
| architecture | NO | NO | NO | NO | full |
| spike | YES | YES | YES | YES | none |

Note: quality-gatekeeper handles both code review AND security checks in a unified pass.
