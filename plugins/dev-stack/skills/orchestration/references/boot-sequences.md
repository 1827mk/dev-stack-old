# Boot Sequences

## PROJECT CONVENTIONS

```
LOAD_PROJECT_CONVENTIONS():
  conventions = {}

  # Check for CLAUDE.md in project root
  IF exists("CLAUDE.md"):
    claude_md = Read("CLAUDE.md")
    conventions.claude = parse_conventions(claude_md)
    # Extract: coding_style, preferred_patterns, avoid_patterns, tool_preferences

  # Check for constitution.md in .specify/memory/
  IF exists(".specify/memory/constitution.md"):
    constitution = Read(".specify/memory/constitution.md")
    conventions.constitution = parse_constitution(constitution)
    # Extract: testing_framework, architectural_style, quality_gates

  # Merge conventions (CLAUDE.md takes precedence for style, constitution for process)
  merged = merge_conventions(conventions)

  RETURN merged

MERGE_CONVENTIONS(conventions):
  result = {
    coding_style: conventions.claude?.coding_style ?? conventions.constitution?.coding_style ?? "standard",
    testing_framework: conventions.constitution?.testing_framework ?? "jest",
    architectural_style: conventions.constitution?.architectural_style ?? "layered",
    preferred_patterns: merge_arrays(conventions.claude?.preferred_patterns, conventions.constitution?.preferred_patterns),
    avoid_patterns: merge_arrays(conventions.claude?.avoid_patterns, conventions.constitution?.avoid_patterns),
    quality_gates: conventions.constitution?.quality_gates ?? ["after_spec", "after_tasks"],
    tool_preferences: conventions.claude?.tool_preferences ?? {}
  }
  RETURN result
```

---

## FAST-PATH ROUTING

Before full CLASSIFY, check for obvious patterns:

```
FAST_PATH_ROUTE(args):
  # Direct number -> resume
  IF args matches /^\d+$/:
    RETURN {intent: resume, id: args}

  # Status command
  IF args matches /^status$/i:
    RETURN {intent: status}

  # Quick intent detection via keywords
  keywords = extract_keywords(args)

  IF any(["bug", "fix", "broken", "error", "crash"] in keywords):
    RETURN {intent: dev, workflow: bug_fix, confidence: high}

  IF any(["hotfix", "urgent", "production", "asap"] in keywords):
    RETURN {intent: dev, workflow: hotfix, confidence: high}

  IF any(["add", "feature", "new", "implement"] in keywords):
    RETURN {intent: dev, workflow: new_feature, confidence: medium}

  IF any(["refactor", "restructure", "clean", "improve"] in keywords):
    RETURN {intent: dev, workflow: refactor, confidence: medium}

  IF any(["security", "vulnerability", "cve", "owasp"] in keywords):
    RETURN {intent: dev, workflow: security_patch, confidence: high}

  # Fall back to full CLASSIFY
  RETURN {intent: unknown}
```

---

## BOOT_DEV

```
BOOT_DEV(req, workflow_hint=None):
  IF req is numeric (e.g. "007") -> load spec {req} -> jump to first pending task
  IF req is "{id} --from-plan"  -> load analysis.md -> convert to full spec -> continue

  # Fast-path check
  IF workflow_hint:
    workflow = workflow_hint
    skip_classification = true
  ELSE:
    fast = FAST_PATH_ROUTE(req)
    IF fast.confidence == high:
      workflow = fast.workflow
      skip_classification = true

  # Load project conventions (parallel with workflow classification)
  conventions <- LOAD_PROJECT_CONVENTIONS()

  IF constitution.md missing AND CLAUDE.md missing:
    skill:lib-tdd -> #constitution_builder -> await user confirmation

  # Workflow-specific optimization
  IF workflow == hotfix:
    # HOTFIX: Minimal overhead, time-boxed
    {team, gates} <- HOTFIX_TEAM()  # senior-developer -> quality-gatekeeper only
    impact <- null  # Skip impact analysis
    skip_memory_check = true
  ELSE IF workflow == bug_fix:
    # BUG_FIX: Light process
    impact <- skill:lib-intelligence -> #pre_impl(req, light=true)
    {team, gates} <- BUGFIX_TEAM()  # domain-analyst -> senior-developer -> quality-gatekeeper -> qa
  ELSE:
    # FULL PROCESS: new_feature, architecture, etc.
    impact <- skill:lib-intelligence -> #pre_impl(req)
    {team, gates} <- skill:lib-workflow(req)
    check mcp__memory for duplicate Spec by title -> if found -> BOOT_RESUME(id)

  mcp__memory__create_entities: TeamFormation {id: next_NNN, workflow, agents: team}
  INIT_TEAM_MESSAGING(id)

  # Prepare context bundle for agents (reduces redundant reads)
  context_bundle <- {
    spec_dir: ".specify/specs/{id}/",
    conventions: conventions,
    workflow: workflow,
    impact_summary: impact?.summary
  }

  emit FORMATION with conventions
  Task: team[0] with full context including context_bundle
```

---

## HOTFIX_TEAM

```
HOTFIX_TEAM():
  RETURN {
    team: ["senior-developer", "quality-gatekeeper"],
    gates: [],  # No approval gates for hotfix
    artifacts: {tasks: single},
    skip_qa: true,
    skip_devops: true
  }
```

---

## BUGFIX_TEAM

```
BUGFIX_TEAM():
  RETURN {
    team: ["domain-analyst", "senior-developer", "quality-gatekeeper", "qa-engineer"],
    gates: ["after_spec"],
    artifacts: {spec: minimal, tasks: simple},
    skip_architect: true,  # No plan.md for bug fixes
    skip_devops: true      # Usually no infra changes
  }
```

---

## BOOT_PLAN

```
BOOT_PLAN(req):
  # Read-only analysis mode - NO code changes

  1. Create spec directory: .specify/specs/{next_id}/
  2. Run impact analysis: skill:lib-intelligence -> #impact(req)
  3. Analyze codebase for affected files
  4. Generate analysis.md with:
     - Impact Assessment
     - Affected Files list
     - Recommended Approach
     - Complexity Estimate (low/medium/high)
     - Suggested Team composition
  5. DO NOT create tasks.md or plan.md
  6. DO NOT modify any source files

  emit PLAN_OUTPUT(id, analysis_path)
```

**PLAN_OUTPUT Format:**
```
Plan Mode | {id}: {title}
Impact: {complexity} | Files: {count} affected
Analysis: .specify/specs/{id}/analysis.md

To implement: /dev-stack:dev {id} --from-plan
```

---

## BOOT_RESUME

```
BOOT_RESUME(id?):
  IF !id -> list all specs with status != COMPLETE -> ask which one
  ctx <- skill:lib-intelligence -> #snapshot_restore(id)
  # snapshot_restore is source of truth: tasks.md newer -> rebuilt from files, warned
  emit RESUME(id, ctx.phase, ctx.current_task)
  Task: agent_for_phase(ctx.phase) with ctx
```

---

## BOOT_PARALLEL

```
BOOT_PARALLEL(req):
  # Parse: "feature-A, feature-B" OR "id:001, id:002" OR single req -> spawn N worktrees

  IF req contains "," -> specs = split by ","
  ELSE                -> specs = [req]  # single spec, still uses worktree isolation

  FOR each spec in specs:
    slug = sanitize(spec.title) -> kebab-case, max 30 chars
    branch = "ds-parallel/{NNN}-{slug}"
    worktree_path = "../{project_name}-wt-{NNN}"

    EnterWorktree:
      branch: branch
      worktree: worktree_path

    # Inside each worktree - full independent pipeline
    Task[isolated in worktree]: orchestrator
      MODE: dev
      INPUT: spec
      WORKTREE: worktree_path
      BRANCH: branch

  # After all worktrees spawn -> monitor in parallel
  emit PARALLEL_FORMATION(specs)

  # When each worktree completes -> merge instructions
  FOR each completed worktree:
    emit PARALLEL_DELIVERY(id, branch)
    print: "-> Merge: git merge {branch} (review PR first via /dev-stack:pr)"
```

**Constraints:**
- Max 4 parallel worktrees (context limit)
- Each worktree is fully isolated: own .specify/specs/{id}/, own branch, own tests
- Shared: .specify/memory/constitution.md (read-only in worktrees)
- Gate approvals still required per worktree independently
- Use only for independent features - conflict check via mcp__memory before spawning

```
PARALLEL_CONFLICT_CHECK:
  mcp__memory__search_nodes: entity=BoundedContext
  IF any two specs share same BoundedContext -> warn, ask to confirm
  mcp__memory__search_nodes: entity=Spec status=ACTIVE
  IF overlap in domain terms -> warn
```

---

## STATUS

```
STATUS(id?):
  targets <- id ? [id] : all spec dirs under .specify/specs/
  FOR each target:
    read tasks.md -> done/total counts
    skill:lib-intelligence -> #dependency_query(id)
    skill:lib-intelligence -> #time_read(id)
    age <- spec.md Date field vs today
  emit STATUS_REPORT
```

---

## RETRO

```
RETRO(id?):
  id <- id || last spec with status COMPLETE
  Read: spec.md + mcp__memory QualityGateResult entities
  generate: what worked | what failed | gate durations | surprises
  append structured section -> .specify/memory/constitution.md
```

---

## ADR_QUERY

```
ADR_QUERY(query):
  mcp__memory__search_nodes: entity=ArchDecision query={query}
  Glob: ".specify/specs/**/plan.md" -> Read each -> extract ADR sections
  emit: context -> alternatives -> decision -> rationale -> consequences
```

---

## GATE

```
GATE(name, owner, result):
  check skill:lib-workflow -> #gate_{name}(result)
  IF fail AND retry < 2  -> re-dispatch owner with specific gap list
  IF fail AND retry >= 2 -> ESCALATE(owner, name)
  IF pass AND name in approval_gates[workflow] -> [HUMAN APPROVAL] await
  IF pass -> Task: next_agent
```

---

## PARALLEL DISPATCH

After quality-gatekeeper passes, dispatch remaining independent agents in parallel:

```
PARALLEL_DISPATCH(agents, context):
  # agents is array of independent agents (e.g., ["qa-engineer", "devops-engineer"])
  # All receive same context bundle

  results = []
  FOR agent in agents:
    Task[parallel]: agent with context
    # Collect results as they complete

  WAIT_ALL_COMPLETE()
  MERGE_RESULTS(results)

  IF any FAILED:
    RETURN combined_failures
  ELSE:
    RETURN combined_pass
```

---

## CONTEXT BUNDLE

Pre-aggregated context to reduce agent file reads:

```
BUILD_CONTEXT_bundle(spec_id, phase):
  bundle = {
    spec_id: spec_id,
    spec_dir: ".specify/specs/{spec_id}/",

    # Pre-read files
    spec_content: Read(".specify/specs/{spec_id}/spec.md"),
    plan_content: Read(".specify/specs/{spec_id}/plan.md") IF exists,
    tasks_content: Read(".specify/specs/{spec_id}/tasks.md") IF exists,

    # Extracted context
    bdd_scenarios: extract_bdd_scenarios(spec_content),
    ubiquitous_language: extract_ubiquitous_language(spec_content),
    layers: extract_layers(plan_content),
    adrs: extract_adrs(plan_content),

    # Project context
    conventions: LOAD_PROJECT_CONVENTIONS()
  }
  RETURN bundle
```

Agents receive bundle and skip re-reading if fields present.
