# Parallel Executor

> Algorithm สำหรับสั่งงาน sub-agents แบบขนา พร้อมกัน

---

## Overview

Parallel Executor สั่งงาน agents หลายตัวพร้อมกัน โดยใช้ Task tool และจัดการ coordination ผ่าน MCP Memory

```
Team Assembly → Parallel Execution → Result Aggregation → Memory Sync
```

---

## Execution Model

### Sequential vs Parallel
```
┌─────────────────┐          ┌─────────────────┐
│   SEQUENTIAL     │          │    PARALLEL      │
├─────────────────┘          └─────────────────┘
│ code-analyzer   │          │ code-analyzer   │ ← Phase 1 (all)
│       ↓         │          │ security-scanner │
│ code-writer     │          │ qa-validator    │
│       ↓         │          │                 │
│ qa-validator    │          │                 │
└─────────────────┘          └─────────────────┘
     Time: 3x             Time: 1x
```

### When to Use Parallel
```yaml
PARALLEL:
  - Independent agents (no dependencies between them)
  - Read-only operations first (analysis, scanning)
  - Time-critical tasks

SEQUENTIAL:
  - Agents depend on each other's output
  - code-writer needs code-analyzer findings
  - qa-validator needs code-writer changes
```

---

## Phase-Based Execution

### Phase 1: Parallel Analysis (Independent)
```javascript
// All agents run simultaneously
const phase1Agents = team.filter(a =>
  ["code-analyzer", "security-scanner", "researcher"].includes(a.name)
);

// Execute in parallel
const phase1Results = await Promise.all(
  phase1Agents.map(agent =>
    Task({
      subagent_type: `dev-stack:${agent.name}`,
      prompt: buildAgentPrompt(agent, taskContext)
    })
  )
);
```

### Phase 2: Sequential Implementation (Dependent)
```javascript
// Wait for Phase 1 to complete
await phase1Results;

// Merge results into shared memory
syncToMemory(phase1Results);

// Execute code-writer
const implementation = await Task({
  subagent_type: "dev-stack:code-writer",
  prompt: buildImplementationPrompt(taskContext, phase1Results)
});

// Execute qa-validator after implementation
const validation = await Task({
  subagent_type: "dev-stack:qa-validator",
  prompt: buildValidationPrompt(taskContext, implementation)
});
```

### Phase 3: Final Reporting (Parallel)
```javascript
// Documentation and memory updates in parallel
const phase3Agents = ["doc-writer", "memory-keeper"];

await Promise.all(
  phase3Agents.map(agent =>
    Task({
      subagent_type: `dev-stack:${agent.name}`,
      prompt: buildReportingPrompt(taskContext, allResults)
    })
  )
);
```

---

## Execution Algorithm
```
FUNCTION execute_team_parallel(team, task_context)

INPUT:
  - team: Agent[] (from capability-matcher)
  - task_context: TaskContext

OUTPUT:
  {
    "success": boolean,
    "results": ExecutionResult[],
    "duration_ms": number
  }

ALGORITHM:
  1. GROUP agents by dependency level
     - Level 0: Independent (can run parallel)
     - Level 1: Depends on Level 0
     - Level 2: Depends on Level 1

  2. EXECUTE Level 0 agents in parallel
     results_level_0 = await Promise.all(level_0.map(agent =>
       Task({subagent_type: agent, ...})
     ))

  3. SYNC Level 0 results to memory
     await sync_to_memory(results_level_0)

  4. EXECUTE Level 1 agents in parallel (with Level 0 context)
     results_level_1 = await Promise.all(level_1.map(agent =>
       Task({
         subagent_type: agent,
         context: { ...task_context, level_0_results }
       })
     ))

  5. SYNC Level 1 results into memory
     await sync_to_memory(results_level_1)

  6. EXECUTE Level 2 agents in parallel
     results_level_2 = await Promise.all(level_2.map(agent =>
       Task({
         subagent_type: agent,
         context: { ...task_context, level_1_results }
       })
     ))

  7. RETURN aggregated results
```

---

## Dependency Levels
```yaml
Level 0 - Independent (Run first, parallel):
  - code-analyzer: Analy code structure
  - security-scanner: Scan for vulnerabilities
  - researcher: Research solutions
  - file-manager: Prepare file structure

  - memory-keeper: Initialize memory context

Level 1 - Depends on Level 0 (run second, with Level 0 context):
  - code-writer: Write code (needs analysis)
  - task-planner: Create detailed plan (needs analysis)
  - data-engineer: Database changes (needs analysis)

  - doc-writer: Write docs (needs research/analysis)

Level 2 - Depends on Level 1 (run last, with Level 1 context):
  - qa-validator: Test implementation (needs code-writer)
  - git-operator: Commit changes (needs qa-validator)
```

---

## Coordination via MCP Memory
```
Before Phase 0:
  memory-keeper.init_task_context()

During Phase 0:
  code-analyzer.write_findings() → memory
  security-scanner.write_findings() → memory
  researcher.write findings() → memory

During Phase 1:
  code-writer reads from memory → implements → writes to memory
  task-planner reads from memory → creates tasks

  data-engineer reads from memory → makes changes

During Phase 2:
  qa-validator reads from memory → tests → writes results
  git-operator reads from memory → commits

After Phase 2:
  memory-keeper.archive_task()
```

---

## Error Handling
```python
TRY:
  results = await execute_team_parallel(team, context)
EXCEPT AgentError as e:
  # Retry failed agent
  retry_result = await retry_agent(e.agent, context)
  results = merge_results(results, retry_result)
EXCEPT TimeoutError:
  # Switch to sequential execution
  return execute_team_sequential(team, context)
EXCEPT MemoryError:
  # Use file-based fallback
  return execute_with_file_fallback(team, context)
```

---

## Performance Metrics
```yaml
Target:
  parallel_execution_time: < sequential_time / 3
  memory_overhead: < 10% of total
  error_recovery_time: < 30s
  coordination_overhead: < 15% of total

Monitoring:
  - Track agent execution times
  - Track memory operations
  - Track coordination messages
  - Calculate efficiency gains
```

---

## Example Execution Flow
```
Task: "Fix login bug and security check"

Step 1: Capability Matching
  → Team: [code-analyzer, security-scanner, code-writer, qa-validator, memory-keeper]

Step 2: Dependency Grouping
  Level 0: [memory-keeper, code-analyzer, security-scanner]
  Level 1: [code-writer]
  Level 2: [qa-validator]

Step 3: Execute Level 0 (Parallel)
  memory-keeper: Init TaskContext
  code-analyzer: Find bug in auth.ts:45
  security-scanner: Find SQL injection risk
  ↓ All results to memory

Step 4: Execute Level 1 (Sequential)
  code-writer: Fix bug + address security issue
  ↓ Result to memory

Step 5: Execute Level 2 (Sequential)
  qa-validator: Run tests, verify fix
  ↓ Result to memory

Step 6: Return Results
  {
    "success": true,
    "bug_fixed": "auth.ts:45",
    "security_improved": true,
    "tests_passed": 5,
    "total_time": "45s"
  }
```

---

## Self-Check
Before completing parallel execution:
- [ ] Agents grouped by dependency level
- [ ] Level 0 agents executed in parallel
- [ ] Results synced to memory between phases
- [ ] Level 1 agents have Level 0 context
- [ ] Level 2 agents have Level 1 context
- [ ] Error handling implemented
- [ ] Performance metrics collected
