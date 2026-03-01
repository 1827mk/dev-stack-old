---
disable-model-invocation: false
user-invokable: false
name: lib-intelligence
description: "Cross-cutting intelligence operations for dev-stack - snapshot save/restore, drift detection, dependency resolution, time tracking, conflict/impact analysis, and PR generation. Called by orchestrator and agents via skill:lib-intelligence to function_name()."
---

# AVAILABLE FUNCTIONS

Load the relevant reference file before executing each function:

| Function | Reference |
|----------|-----------|
| `#snapshot_capture` / `#snapshot_restore` | references/snapshot.md |
| `#drift` | references/drift.md |
| `#dependency_query` / `#check_ready` | references/dependency.md |
| `#time_read` | references/dependency.md |
| `#pre_impl` / `#impact` | references/impact.md |
| `#pr` | references/impact.md |

# TOOL PRIORITY

Primary (use these first):
- `mcp__serena__find_symbol`, `mcp__serena__find_referencing_symbols`, `mcp__serena__search_for_pattern`
- `mcp__serena__get_symbols_overview`, `mcp__serena__replace_symbol_body`, `mcp__serena__insert_after_symbol`
- `mcp__serena__read_memory`, `mcp__serena__write_memory`, `mcp__serena__list_memories`

Fallback (if serena unavailable — use these instead):
- `Read` + `Grep` + `Glob` + `mcp__filesystem__read_text_file` + `mcp__filesystem__search_files`

Always try primary first. On any serena error, fall back silently and continue.
