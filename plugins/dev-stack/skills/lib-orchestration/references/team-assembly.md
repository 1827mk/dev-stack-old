# Team Assembly Reference

> Part of lib-orchestration skill for dev-stack v10.0.0

---

## Overview

Team assembly dynamically selects agents based on required capabilities. This is the core of v10.0.0's dynamic orchestration.

## Agent Registry

### Available Agents (12)

| Agent | Capabilities | Tools Focus |
|-------|--------------|-------------|
| `orchestrator` | coordination, memory_coordination | Task, memory, sequentialthinking |
| `code-analyzer` | code_analysis, research | serena (symbol lookup), Grep, Read |
| `code-writer` | code_writing, testing | serena (editing), context7, Bash |
| `researcher` | research, api_research | context7, web_reader, fetch |
| `doc-writer` | documentation | doc-forge, filesystem |
| `qa-validator` | testing, quality_analysis | Bash, serena |
| `security-scanner` | security_scan | serena (pattern search) |
| `git-operator` | git_ops | Bash (git) |
| `memory-keeper` | memory_coordination | memory MCP, serena memory |
| `task-planner` | planning, research | sequentialthinking, TaskCreate |
| `file-manager` | file_ops | filesystem MCP |
| `data-engineer` | database_ops, code_writing | serena, Bash |

---

## Capability to Agent Mapping

### CAPABILITY_TO_AGENTS

```python
CAPABILITY_TO_AGENTS = {
    "code_analysis": {
        "primary": ["code-analyzer"],
        "fallback": ["code-writer", "researcher"]
    },
    "code_writing": {
        "primary": ["code-writer"],
        "fallback": ["code-analyzer"]
    },
    "testing": {
        "primary": ["qa-validator"],
        "fallback": ["code-writer"]
    },
    "research": {
        "primary": ["researcher"],
        "fallback": ["code-analyzer", "task-planner"]
    },
    "planning": {
        "primary": ["task-planner"],
        "fallback": ["researcher"]
    },
    "documentation": {
        "primary": ["doc-writer"],
        "fallback": ["researcher"]
    },
    "security_scan": {
        "primary": ["security-scanner"],
        "fallback": ["code-analyzer"]
    },
    "git_ops": {
        "primary": ["git-operator"],
        "fallback": ["code-writer"]
    },
    "file_ops": {
        "primary": ["file-manager"],
        "fallback": ["code-writer"]
    },
    "memory_coordination": {
        "primary": ["memory-keeper"],
        "fallback": ["orchestrator"]
    },
    "database_ops": {
        "primary": ["data-engineer"],
        "fallback": ["code-writer"]
    },
    "api_research": {
        "primary": ["researcher"],
        "fallback": ["doc-writer"]
    }
}
```

---

## Assembly Algorithm

### Step 1: Collect Agents for Required Capabilities

```python
def collect_agents_for_capabilities(capabilities):
    """Collect agents needed for required capabilities"""

    agents = set()

    for capability in capabilities.get("required", []):
        if capability in CAPABILITY_TO_AGENTS:
            # Add primary agent
            primary = CAPABILITY_TO_AGENTS[capability]["primary"]
            agents.update(primary)

    return list(agents)
```

### Step 2: Add Memory-Keeper for Multi-Agent Teams

```python
def add_coordination(agents):
    """Add memory-keeper if multiple agents"""

    if len(agents) > 1:
        if "memory-keeper" not in agents:
            agents.append("memory-keeper")

    return agents
```

### Step 3: Determine Spawn Order

```python
def determine_spawn_order(agents, capabilities):
    """Determine optimal spawn order based on dependencies"""

    # Dependency order
    ORDER = {
        "task-planner": 1,      # Planning first
        "researcher": 2,        # Research second
        "code-analyzer": 3,     # Analysis third
        "security-scanner": 4,  # Security scan fourth
        "code-writer": 5,       # Implementation fifth
        "qa-validator": 6,      # Testing sixth
        "doc-writer": 7,        # Documentation seventh
        "git-operator": 8,      # Git ops last
        "data-engineer": 3,     # Same as analyzer
        "file-manager": 4,      # Same as security
        "memory-keeper": 0,     # Always first (or with planner)
        "orchestrator": -1      # Coordinator, not spawned
    }

    # Sort by order
    sorted_agents = sorted(agents, key=lambda a: ORDER.get(a, 99))

    return sorted_agents
```

### Step 4: Parallel vs Sequential

```python
def determine_execution_mode(agents, capabilities):
    """Determine if agents can run in parallel"""

    # Agents that can run in parallel
    PARALLEL_GROUPS = [
        ["code-analyzer", "security-scanner", "researcher"],
        ["doc-writer", "qa-validator"]
    ]

    # Check if agents can be parallelized
    parallel_groups = []

    for group in PARALLEL_GROUPS:
        matching = [a for a in agents if a in group]
        if len(matching) > 1:
            parallel_groups.append(matching)

    return {
        "parallel_groups": parallel_groups,
        "sequential": [a for a in agents if not any(a in g for g in parallel_groups)]
    }
```

---

## Assembly Function

```
FUNCTION #assemble_team(capabilities, context={})

INPUT:
  - capabilities: object (from map_capabilities)
    {
      "required": [...],
      "optional": [...],
      "priority": "...",
      "complexity": "...",
      "security_sensitive": true/false
    }
  - context: object (optional additional context)

OUTPUT:
  {
    "agents": ["code-analyzer", "code-writer", "qa-validator", "memory-keeper"],
    "spawn_order": ["memory-keeper", "code-analyzer", "code-writer", "qa-validator"],
    "execution_mode": {
      "parallel_groups": [["code-analyzer", "security-scanner"]],
      "sequential": ["code-writer", "qa-validator"]
    },
    "reasoning": "Bug fix requires analysis, fix, and validation"
  }

ALGORITHM:
  1. Collect agents for required capabilities
  2. Add memory-keeper if multi-agent
  3. Determine spawn order
  4. Determine execution mode (parallel vs sequential)
  5. RETURN team configuration
```

---

## Team Templates by Intent

### Bug Fix Team

```
Intent: bug_fix
Complexity: low

Team:
  - code-analyzer  (find the bug)
  - code-writer    (fix the bug)
  - qa-validator   (verify fix)
  - memory-keeper  (coordinate)

Spawn Order: [memory-keeper, code-analyzer, code-writer, qa-validator]
Execution: Sequential
```

### New Feature Team (Simple)

```
Intent: new_feature
Complexity: low

Team:
  - researcher     (research approach)
  - code-analyzer  (analyze existing code)
  - code-writer    (implement feature)
  - qa-validator   (test implementation)
  - memory-keeper  (coordinate)

Spawn Order: [memory-keeper, researcher, code-analyzer, code-writer, qa-validator]
Execution: Sequential with parallel researcher+analyzer
```

### New Feature Team (Complex)

```
Intent: new_feature
Complexity: high

Team:
  - task-planner      (decompose tasks)
  - researcher        (research approach)
  - code-analyzer     (analyze existing code)
  - code-writer       (implement feature)
  - qa-validator      (test implementation)
  - doc-writer        (document feature)
  - memory-keeper     (coordinate)

Spawn Order: [memory-keeper, task-planner, researcher, code-analyzer, code-writer, qa-validator, doc-writer]
Execution: Sequential with parallel phases
```

### New Feature Team (Security-Sensitive)

```
Intent: new_feature
Security-Sensitive: true

Team:
  - task-planner      (decompose tasks)
  - researcher        (research approach)
  - code-analyzer     (analyze existing code)
  - security-scanner  (scan for vulnerabilities)
  - code-writer       (implement feature)
  - qa-validator      (test implementation)
  - doc-writer        (document feature)
  - memory-keeper     (coordinate)

Spawn Order: [memory-keeper, task-planner, researcher, code-analyzer, security-scanner, code-writer, qa-validator, doc-writer]
Execution: Sequential with parallel analyzer+scanner
```

### Security Patch Team

```
Intent: security
Complexity: any

Team:
  - security-scanner  (scan for vulnerabilities)
  - code-analyzer     (analyze affected code)
  - code-writer       (implement fix)
  - qa-validator      (verify fix)
  - memory-keeper     (coordinate)

Spawn Order: [memory-keeper, security-scanner, code-analyzer, code-writer, qa-validator]
Execution: Sequential
Priority: CRITICAL
```

### Research Team

```
Intent: research
Complexity: any

Team:
  - researcher     (do research)
  - doc-writer     (document findings)
  - memory-keeper  (coordinate)

Spawn Order: [memory-keeper, researcher, doc-writer]
Execution: Sequential
```

### Refactor Team

```
Intent: refactor
Complexity: low

Team:
  - code-analyzer  (analyze code structure)
  - code-writer    (refactor code)
  - qa-validator   (verify behavior preserved)
  - memory-keeper  (coordinate)

Spawn Order: [memory-keeper, code-analyzer, code-writer, qa-validator]
Execution: Sequential
```

### Hotfix Team

```
Intent: hotfix
Complexity: any

Team:
  - code-analyzer  (find the issue)
  - code-writer    (fix immediately)
  - memory-keeper  (coordinate)

Spawn Order: [memory-keeper, code-analyzer, code-writer]
Execution: Sequential
Priority: CRITICAL
Bypasses: quality gates, security scan
```

---

## Scoped Commands

Scoped commands limit team to specific scope:

| Command | Scope | Allowed Agents |
|---------|-------|----------------|
| `/dev-stack:bug` | Bug fix only | code-analyzer, code-writer, qa-validator, memory-keeper |
| `/dev-stack:feature` | Full feature | All agents |
| `/dev-stack:security` | Security only | security-scanner, code-analyzer, code-writer, qa-validator, memory-keeper |
| `/dev-stack:refactor` | Refactor only | code-analyzer, code-writer, qa-validator, memory-keeper |
| `/dev-stack:research` | Research only | researcher, doc-writer, memory-keeper |
| `/dev-stack:git` | Git only | git-operator, memory-keeper |
| `/dev-stack:quality` | Quality only | qa-validator, security-scanner, memory-keeper |
| `/dev-stack:docs` | Docs only | doc-writer, researcher, memory-keeper |
| `/dev-stack:data` | Database only | data-engineer, memory-keeper |

---

## Fallback Logic

```python
def get_fallback_agent(capability, unavailable_agents):
    """Get fallback agent when primary is unavailable"""

    if capability not in CAPABILITY_TO_AGENTS:
        return None

    mapping = CAPABILITY_TO_AGENTS[capability]
    primary = mapping["primary"]
    fallback = mapping["fallback"]

    # Try primary first
    for agent in primary:
        if agent not in unavailable_agents:
            return agent

    # Try fallback
    for agent in fallback:
        if agent not in unavailable_agents:
            return agent

    return None
```

---

## Examples

### Example 1: Simple Bug Fix

```
Capabilities:
{
  "required": ["code_analysis", "code_writing", "testing"],
  "optional": ["git_ops"],
  "priority": "high",
  "complexity": "low"
}

Team:
{
  "agents": ["code-analyzer", "code-writer", "qa-validator", "memory-keeper"],
  "spawn_order": ["memory-keeper", "code-analyzer", "code-writer", "qa-validator"],
  "execution_mode": {
    "parallel_groups": [],
    "sequential": ["memory-keeper", "code-analyzer", "code-writer", "qa-validator"]
  },
  "reasoning": "Bug fix requires sequential analysis, fix, validation"
}
```

### Example 2: Complex Feature with Security

```
Capabilities:
{
  "required": ["research", "planning", "code_analysis", "code_writing", "testing", "security_scan"],
  "optional": ["documentation", "git_ops"],
  "priority": "high",
  "complexity": "high",
  "security_sensitive": true
}

Team:
{
  "agents": ["task-planner", "researcher", "code-analyzer", "security-scanner", "code-writer", "qa-validator", "doc-writer", "memory-keeper"],
  "spawn_order": ["memory-keeper", "task-planner", "researcher", "code-analyzer", "security-scanner", "code-writer", "qa-validator", "doc-writer"],
  "execution_mode": {
    "parallel_groups": [["code-analyzer", "security-scanner"], ["researcher", "code-analyzer"]],
    "sequential": ["task-planner", "code-writer", "qa-validator", "doc-writer"]
  },
  "reasoning": "Complex feature with security requires full team with parallel analysis"
}
```

---

## Integration with Memory Protocol

After team assembly, initialize shared memory:

```
team = assemble_team(capabilities)
context = init_memory(task_id, user_request, team)

# Spawn agents with context
for agent in team["spawn_order"]:
    Task(subagent_type=agent, prompt=task_with_context)
```

---

## Testing

```gherkin
Scenario: Assemble bug fix team
  Given capabilities ["code_analysis", "code_writing", "testing"]
  When assemble_team is called
  Then agents should include "code-analyzer"
  And agents should include "code-writer"
  And agents should include "qa-validator"
  And agents should include "memory-keeper"

Scenario: Add security-scanner for sensitive task
  Given capabilities include "security_scan"
  When assemble_team is called
  Then agents should include "security-scanner"

Scenario: Add planning for complex task
  Given complexity is "high"
  When assemble_team is called
  Then agents should include "task-planner"

Scenario: Parallel execution for independent agents
  Given agents ["code-analyzer", "security-scanner"]
  When determine_execution_mode is called
  Then they should be in same parallel group
```
