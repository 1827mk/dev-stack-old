# Snapshot: Save & Restore

## #snapshot_capture(id?)

```
targets ← id ? [id] : all spec dirs with status != COMPLETE
FOR each target:
  Read: spec.md  → {title, bounded_context, ubiquitous_language}
  Read: tasks.md → {done[], pending[], current_task = first `- [ ]`}
  mcp__serena__write_memory: "ds-snap-{id}-{unix_ts}" → {
    id, title, workflow, phase,
    current_task,
    done:    [{id, title, actual_h}],
    pending: [{id, title, est_h, depends_on[]}],
    last_gate_passed,
    vocab: [],
    adrs:  [],
    ts: ISO8601
  }
emit: "📸 {id} saved — resume: /dev-stack:resume {id}"
```

## #snapshot_restore(id)

```
mcp__serena__list_memories → find latest "ds-snap-{id}-*"
mcp__serena__read_memory   → snapshot

Read: tasks.md → compare mtime vs snapshot.ts
  IF tasks.md newer → rebuild ctx from tasks.md, emit "⚠️ snapshot stale — rebuilt from files"
  ELSE              → use snapshot as-is

return: restored_context {id, phase, current_task, done[], pending[], vocab[], adrs[]}
```
