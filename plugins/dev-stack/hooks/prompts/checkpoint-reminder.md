---
trigger: gate_pass, pre_destructive
---

# Checkpoint Reminder

When triggered, append to agent response:

## After Gate Pass

```
[dev-stack] Checkpoint available. Use /rewind to undo if needed.
```

## Before Destructive Changes

When about to:
- Delete files
- Refactor large code sections
- Modify critical paths
- Change database schemas

```
[dev-stack] Consider checkpoint before major changes. Use /rewind if you need to revert.
```

## Session Start

Include in initial context:

```
[dev-stack] Checkpointing is enabled. At any point, use /rewind to undo recent changes.
```

## Configuration

In `.specify/memory/constitution.md`:

```yaml
checkpointing:
  remind_after_gates: true  # Default: true
  remind_before_destructive: true  # Default: true
  remind_on_session_start: true  # Default: true
```
