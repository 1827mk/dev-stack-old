# Output Formats

## PARALLEL_FORMATION
```
Parallel mode | {N} worktrees
{for each spec}:
  [{i}] {id}: {title} -> branch: ds-parallel/{branch} | worktree: {path}
Conflict: GREEN/YELLOW {summary}
Monitor: /dev-stack:status (shows all active)
```

---

## PARALLEL_DELIVERY
```
[{i}] {id}: {title} complete in worktree {path}
Branch: {branch}
-> Review: /dev-stack:pr {id}
-> Merge:  git merge {branch}
-> Clean:  git worktree remove {path}
```

---

## FORMATION (Optimized)
```
{workflow} | {id}
Conflict: GREEN/YELLOW/RED  {summary}
Team: {a1 -> a2 -> ... || parallel}
Skip: {skipped_agents}  // NEW: show optimization
Quality: {quick|full|none}  // NEW: show quality mode
Approve at: {gates or none}
```

---

## RESUME
```
{id} | Phase: {phase}
Next: Task {N} - {title}
```

---

## STATUS per feature
```
{id}: {title} [{workflow}] {done}/{total} tasks
Velocity: est {X}h / actual {Y}h
[if blocked] BLOCKED: T{N} <- T{M}
[if stale]   WARNING spec {age} old - run /dev-stack:drift
```

---

## DELIVERY
```
{id}: {title} | Tasks: {X}/{total} | Gates: all pass
```

---

## ESCALATE
```
{id} | {agent} | gate: {gate}
Failures: {list}
Fix: {specific_action}
```

---

## FAST-PATH MATCH (NEW)
```
Fast-path: {workflow} detected via keyword match
Confidence: {high|medium}
Skipping full classification...
```

---

## WORKFLOW OPTIMIZATION (NEW)
```
Workflow: {workflow}
Optimizations applied:
  - Skip: {skipped_agents}
  - Quality: {quality_mode}
  - Template: {spec_template}
```

---

## CHECKPOINT REMINDERS

After each GATE pass, include in output:

```
[dev-stack] Checkpoint available. Use /rewind to undo if needed.
```

Before destructive operations (delete, major refactor):

```
[dev-stack] Consider checkpoint before major changes. Use /rewind if needed.
```

---

## QUALITY GATE REPORTS

### Quick Mode
```
Quality Gate (Quick): {id}
Status: APPROVED | CHANGES REQUIRED

Code Quality: {N} issues
Critical Security: {N} issues
BDD Coverage: {N}/{total} scenarios

[if CHANGES REQUIRED]
-> Re-dispatching senior-developer with gap list
```

### Full Mode
```
Quality Gate (Full): {id}
Status: APPROVED | CHANGES REQUIRED

Code Quality: {N} issues
OWASP Top 10: {N} issues
Container: {N} issues
CI/CD: {N} issues
BDD Coverage: {N}/{total} scenarios

[if CHANGES REQUIRED]
-> Re-dispatching senior-developer with gap list
```
