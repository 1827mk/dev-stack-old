# Dependency Resolution

## #dependency_query(id)

```
mcp__memory__search_nodes: entity=Task feature_id={id}
IF none → Read: tasks.md → parse "Depends:" lines manually

FOR each task:
  check [x] status of all depends_on tasks
  blocked_by = [deps not yet marked [x]]

return: {done[], ready[], blocked: [{task, blocked_by: [{id, title, status}]}]}
```

**Render blocked tasks:**
```
BLOCKED:
  T{N}: {title}
    ← BLOCKED BY T{M}: {title} ({✓ done | ⏳ est Xh remaining})
```

## #check_ready(task_id)

```
get task.depends_on[] from mcp__memory or tasks.md
FOR each dep: verify [x] DONE in tasks.md
return: {ready: bool, blocking: [{id, title}]}
```

# Time Tracking

## #time_read(id)

```
Read: tasks.md → parse:
  est_h    ← [est:Xh] on each task line
  actual_h ← [actual:Xh] on [x] DONE lines

total_est    = sum of all est_h
done_actual  = sum of actual_h on completed tasks
pending_est  = sum of est_h on pending tasks
accuracy_pct = done_actual / total_est * 100 (if total_est > 0)

IF accuracy_pct < 70%: warn "⚠️ estimates diverging — consider re-estimating pending tasks"

return: {total_est, done_actual, pending_est, accuracy_pct}
```
