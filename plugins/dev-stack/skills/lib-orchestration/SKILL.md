---
disable-model-invocation: false
user-invokable: false
name: lib-orchestration
description: "Orchestration library for dev-stack v10.0.0 - capability-based team selection, parallel execution, intent classification, and shared memory protocol. Called by orchestrator via skill:lib-orchestration to function_name()."
---

# lib-orchestration Skill

## Overview

This skill provides the core orchestration logic for dev-stack v10.0.0:
- **Capability Matching**: Analyze requirements and match to agent capabilities
- **Parallel Execution**: Execute independent agents simultaneously (38-75% faster)
- **Intent Classification**: Analyze user request to determine task type
- **Team Assembly**: Dynamically select agents based on capabilities with dependency levels
- **Memory Protocol**: Manage shared memory for agent coordination

## Tool Priority

**ALWAYS follow this priority when selecting tools:**

```
1️⃣ MCP SERVERS (Highest Priority)
   ├─ mcp__serena__* (code analysis, editing)
   ├─ mcp__memory__* (shared memory)
   ├─ mcp__context7__* (documentation lookup)
   ├─ mcp__sequentialthinking__* (planning)
   └─ mcp__filesystem__* (file operations)

2️⃣ PLUGINS
   ├─ superpowers (TDD, debugging)
   └─ spec-kit (SDD workflow)

3️⃣ SKILLS
   └─ dev-stack skills

4️⃣ BUILT-IN TOOLS (Lowest Priority)
   └─ Read, Write, Edit, Glob, Grep, Bash
```

## Available Functions

Load the relevant reference file before executing each function:

| Function | Reference | Description |
|----------|-----------|-------------|
| `#analyze_requirements` | references/capability-matcher.md | Analyze request and detect required capabilities |
| `#classify_intent` | references/intent-classification.md | Classify user request into intent type |
| `#map_capabilities` | references/capability-mapping.md | Map intent to required capabilities |
| `#assemble_team` | references/team-assembly.md | Dynamically assemble agent team with dependency levels |
| `#execute_parallel` | references/parallel-executor.md | Execute agents by dependency level (parallel) |
| `#init_memory` | references/memory-protocol.md | Initialize shared memory context |
| `#write_observation` | references/memory-protocol.md | Write agent finding to memory |
| `#read_context` | references/memory-protocol.md | Read task context from memory |

## Workflow (Phase-Based Parallel Execution)

```
User Request
     │
     ▼
┌─────────────────────────────┐
│ #analyze_requirements       │ ← references/capability-matcher.md
└──────────┬──────────────────┘
           │ Returns: {detected_capabilities, confidence_scores}
           ▼
┌─────────────────────────────┐
│ #classify_intent            │ ← references/intent-classification.md
└──────────┬──────────────────┘
           │ Returns: {intent, confidence, keywords}
           ▼
┌─────────────────────────────┐
│ #map_capabilities           │ ← references/capability-mapping.md
└──────────┬──────────────────┘
           │ Returns: {capabilities, priority}
           ▼
┌─────────────────────────────┐
│ #assemble_team              │ ← references/team-assembly.md
│ (with dependency levels)    │
└──────────┬──────────────────┘
           │ Returns: {agents, dependency_levels: {level_0, level_1, level_2}}
           ▼
┌─────────────────────────────┐
│ #init_memory                │ ← references/memory-protocol.md
└──────────┬──────────────────┘
           │ Returns: {task_id, memory_context}
           ▼
┌─────────────────────────────────────────────────────────────┐
│ #execute_parallel (by dependency level)                     │
│                                                             │
│  Level 0 (Parallel): [code-analyzer, security-scanner]      │
│           │                                                 │
│           ▼ sync_to_memory()                                │
│                                                             │
│  Level 1 (Sequential): [code-writer]                        │
│           │                                                 │
│           ▼ sync_to_memory()                                │
│                                                             │
│  Level 2 (Sequential): [qa-validator]                       │
└─────────────────────────────────────────────────────────────┘
           │
           ▼
    Aggregate Results
```

## Usage Example (Parallel Execution)

```
// In orchestrator agent:

1. Load references:
   - Read references/capability-matcher.md
   - Read references/intent-classification.md
   - Read references/capability-mapping.md
   - Read references/team-assembly.md
   - Read references/parallel-executor.md
   - Read references/memory-protocol.md

2. Analyze requirements:
   analysis = analyze_requirements(user_request)
   // Returns: {detected_capabilities: ["code_analysis", "security_scanning"], confidence: {...}}

3. Classify intent:
   result = classify_intent(user_request, analysis)
   // Returns: {intent: "bug_fix", confidence: 0.9}

4. Map capabilities:
   capabilities = map_capabilities(result.intent, user_request)
   // Returns: {required: ["code_analysis", "code_writing", "testing"], optional: ["security_scan"]}

5. Assemble team with dependencies:
   team = assemble_team_with_dependencies(capabilities)
   // Returns: {
   //   agents: ["memory-keeper", "code-analyzer", "security-scanner", "code-writer", "qa-validator"],
   //   dependency_levels: {
   //     level_0: ["memory-keeper", "code-analyzer", "security-scanner"],
   //     level_1: ["code-writer"],
   //     level_2: ["qa-validator"]
   //   }
   // }

6. Initialize memory:
   context = init_memory(task_id, user_request)
   // Creates TaskContext entity in MCP memory

7. Execute parallel by level:
   // Level 0: Run independent agents in parallel
   level_0_results = await Promise.all([
     spawn_agent("code-analyzer", context),
     spawn_agent("security-scanner", context)
   ])
   sync_to_memory(level_0_results)

   // Level 1: Run with Level 0 context
   level_1_results = await spawn_agent("code-writer", {...context, level_0_results})
   sync_to_memory(level_1_results)

   // Level 2: Run with Level 1 context
   level_2_results = await spawn_agent("qa-validator", {...context, level_1_results})

8. Aggregate and return results
```

## Error Handling

```
IF MCP memory unavailable:
  └─ Fallback: Write to .specify/memory/{task_id}.json

IF intent confidence < 0.5:
  └─ Ask user for clarification

IF agent spawn fails:
  └─ Retry with fallback agent
  └─ Escalate to orchestrator if max retries exceeded
```

## Integration with Other Systems

### spec-kit Integration
```
IF .specify/spec.md exists:
  └─ Read for requirements context
IF .specify/plan.md exists:
  └─ Read for architecture context
IF .specify/tasks.md exists:
  └─ Read for task status
```

### superpowers Integration
```
FOR TDD tasks:
  └─ Invoke superpowers:test-driven-development skill
FOR debugging:
  └─ Invoke superpowers:systematic-debugging skill
FOR code review:
  └─ Invoke superpowers:requesting-code-review skill
```

## Files

```
skills/lib-orchestration/
├── SKILL.md                          # This file
└── references/
    ├── capability-matcher.md        # Capability detection and agent matching (NEW v10)
    ├── parallel-executor.md         # Phase-based parallel execution (NEW v10)
    ├── intent-classification.md      # Intent patterns and classification
    ├── capability-mapping.md         # Intent → Capability mapping
    ├── team-assembly.md              # Capability → Agent assembly with dependency levels
    └── memory-protocol.md            # Shared memory entities and operations
```

## Performance Gains

| Execution Mode | Time | Speedup |
|----------------|------|---------|
| Sequential | 4x | Baseline |
| Phase-based Parallel | ~2.5x | **38% faster** |
| Full Parallel | ~1x | **75% faster** |
