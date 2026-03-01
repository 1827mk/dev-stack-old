# dev-stack v7.0 Architecture Design

**Date**: 2026-03-01
**Status**: Approved
**Author**: User + Claude

---

## Executive Summary

dev-stack v7.0 เป็น **Resource Orchestrator Plugin** ที่จัดการ:
1. **Tool Selection** - Context-aware, Quality-first (MCP > Plugin > Skill > Built-in)
2. **Team Orchestration** - Dependency-based dispatch (parallel when independent)
3. **Workflow Routing** - Auto-classify intent → route to appropriate system

**Key Principle**: dev-stack ไม่สร้างไฟล์ มีหน้าที่ "จัดสรรการเรียกใช้ทรัพยากร" เท่านั้น

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                  /dev-stack                         │
│              (Entry Command)                        │
└─────────────────────┬───────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────┐
│              orchestrator agent                     │
│  ┌─────────────┬─────────────┬─────────────────┐   │
│  │ Classify    │ Route       │ Dispatch        │   │
│  │ (seqthink)  │ (lib-router)│ (dep-graph)     │   │
│  └─────────────┴─────────────┴─────────────────┘   │
└─────────────────────┬───────────────────────────────┘
                      │
        ┌─────────────┼─────────────┐
        ▼             ▼             ▼
┌───────────┐  ┌───────────┐  ┌───────────┐
│ speckit   │  │superpowers│  │ direct    │
│ workflows │  │ workflows │  │ agents    │
└───────────┘  └───────────┘  └───────────┘
```

---

## Design Decisions

### D1: Entry Point Behavior

| Command | Behavior |
|---------|----------|
| `/dev-stack` | Auto-classify intent → route to workflow |
| `/dev-stack:dev` | Direct dev workflow |
| `/dev-stack:bug` | Direct bug_fix workflow |
| `/dev-stack:feature` | Direct new_feature workflow |
| `/dev-stack:hotfix` | Direct hotfix workflow |
| `/dev-stack:refactor` | Direct refactor workflow |
| `/dev-stack:security` | Direct security_patch workflow |
| `/dev-stack:plan` | Read-only analysis mode |
| `/dev-stack:review` | Direct quality-gatekeeper |
| `/dev-stack:audit` | Full OWASP scan |

**Classification**: Use `mcp__sequentialthinking__sequentialthinking` for semantic analysis

### D2: Tool Selection Priority

**Principle**: Context-aware, Quality-first

```
TOOL_PRIORITY:
  code_read: [mcp__serena__find_symbol, mcp__serena__get_symbols_overview, mcp__serena__search_for_pattern, Read]
  code_edit: [mcp__serena__replace_symbol_body, mcp__serena__insert_after_symbol, mcp__serena__rename_symbol, Edit]
  code_refs: [mcp__serena__find_referencing_symbols, Grep]
  file_find: [mcp__serena__find_file, Glob]
  dir_list: [mcp__serena__list_dir, mcp__filesystem__list_directory, Bash:ls]
  web_fetch: [mcp__web_reader__webReader, mcp__fetch__fetch, WebSearch]
  doc_read: [mcp__doc-forge__document_reader, Read]
  memory: [mcp__memory__*, mcp__serena__*_memory]
  think: [mcp__sequentialthinking__sequentialthinking]
```

**Guideline**: MCP > Plugin > Skill > Built-in (but context determines best tool)

### D3: Team Dispatch Strategy

**Dependency-based dispatch**:
- Agents with no dependencies → Parallel
- Agents with dependencies → Sequential (wait for dependency)

```
DEPENDENCY_GRAPH:
  new_feature:
    parallel_group_1: [domain-analyst]
    sequential_after_1: [solution-architect]
    sequential_after_2: [tech-lead]
    sequential_after_3: [senior-developer]
    sequential_after_4: [quality-gatekeeper]
    parallel_final: [qa-engineer, devops-engineer]

  bug_fix:
    parallel_group_1: [domain-analyst]
    sequential_after_1: [senior-developer]
    sequential_after_2: [quality-gatekeeper]
    sequential_after_3: [qa-engineer]

  hotfix:
    sequential: [senior-developer, quality-gatekeeper]

  refactor:
    parallel_group_1: [solution-architect]
    sequential_after_1: [senior-developer]
    sequential_after_2: [quality-gatekeeper]

  security_patch:
    sequential: [senior-developer, quality-gatekeeper, qa-engineer]
```

### D4: Sub-System Selection

| Condition | Use System | Reason |
|-----------|------------|--------|
| Greenfield + Clear Business Logic | **speckit** | Structured spec/plan/tasks |
| Legacy Code + Complex Bug | **superpowers** | Root cause + TDD |
| Quick Fix + Hotfix | **Direct agents** | Minimal overhead |
| Security Patch | **Direct + superpowers** | OWASP + TDD |

**dev-stack does NOT create files** - Let sub-agents (speckit/superpowers) handle file creation

### D5: Tool Mapping Storage

**Format**: Skill-based, AI-optimized (not human-readable)

Store in `skills/lib-router/SKILL.md`:
- Compact JSON-like structure
- Intent → Tool chain mapping
- Fallback chains

---

## Components

### C1: orchestrator agent

**File**: `agents/orchestrator.md`

**Responsibilities**:
1. Parse MODE from command
2. Classify intent (if MODE=smart)
3. Select tool chain via lib-router
4. Build dependency graph
5. Dispatch agents
6. Collect results
7. Report status

**Tools**: Read, Task, mcp__sequentialthinking__*, mcp__memory__*

### C2: lib-router skill

**File**: `skills/lib-router/SKILL.md`

**Responsibilities**:
1. Intent → Tool mapping
2. Context-aware selection
3. Fallback chains
4. Quality-first optimization

### C3: lib-workflow skill

**File**: `skills/lib-workflow/SKILL.md`

**Responsibilities**:
1. Workflow classification
2. Team composition
3. Gate configuration
4. Dependency graph generation

### C4: lib-intelligence skill

**File**: `skills/lib-intelligence/SKILL.md`

**Responsibilities**:
1. Snapshot save/restore
2. Drift detection
3. Impact analysis
4. PR generation

---

## Commands Structure

```
commands/
├── dev-stack.md      # Entry point (MODE=smart)
├── dev.md            # MODE=dev
├── bug.md            # MODE=dev, workflow=bug_fix
├── feature.md        # MODE=dev, workflow=new_feature
├── hotfix.md         # MODE=dev, workflow=hotfix
├── refactor.md       # MODE=dev, workflow=refactor
├── security.md       # MODE=dev, workflow=security_patch
├── plan.md           # MODE=plan
├── review.md         # MODE=review
├── audit.md          # MODE=audit
├── status.md         # MODE=status
├── resume.md         # MODE=resume
├── snapshot.md       # MODE=snapshot
├── pr.md             # MODE=pr
├── drift.md          # MODE=drift
├── impact.md         # MODE=impact
├── adr.md            # MODE=adr
├── retro.md          # MODE=retro
├── parallel.md       # MODE=parallel
├── check.md          # Quality check
└── tools.md          # Show tool catalog
```

---

## Hooks Structure

```
hooks/
├── hooks.json        # Hook configuration
└── scripts/
    ├── session-start.sh    # Inject context on session start
    ├── auto-router.sh      # Pre-classify (optional fast-path)
    ├── status-line.sh      # Update status line
    ├── notify.sh           # Desktop notifications
    └── lib/
        ├── router-core.sh  # Shell-based routing (fallback)
        └── discovery.sh    # Tool discovery
```

---

## File Structure

```
dev-stack/
├── .claude-plugin/
│   └── plugin.json
├── agents/
│   ├── orchestrator.md
│   ├── domain-analyst.md
│   ├── solution-architect.md
│   ├── tech-lead.md
│   ├── senior-developer.md
│   ├── quality-gatekeeper.md
│   ├── qa-engineer.md
│   ├── devops-engineer.md
│   ├── performance-engineer.md
│   ├── documentation-writer.md
│   └── team-coordinator.md
├── commands/
│   └── [all commands]
├── skills/
│   ├── lib-router/
│   │   └── SKILL.md
│   ├── lib-workflow/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── lib-intelligence/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── lib-domain/
│   │   ├── SKILL.md
│   │   └── references/
│   ├── lib-tdd/
│   │   ├── SKILL.md
│   │   └── references/
│   └── orchestration/
│       ├── SKILL.md
│       └── references/
├── hooks/
│   ├── hooks.json
│   └── scripts/
└── README.md
```

---

## Implementation Phases

### Phase 1: Core Refactor
1. Update `orchestrator.md` with new logic
2. Update `lib-router/SKILL.md` with tool mappings
3. Update `lib-workflow/SKILL.md` with dependency graphs

### Phase 2: Commands Update
1. Update all command files to use new patterns
2. Ensure MODE routing is correct

### Phase 3: Hooks Cleanup
1. Fix hooks.json environment variables
2. Update shell scripts for new structure

### Phase 4: Testing
1. Test `/dev-stack` auto-classification
2. Test `/dev-stack:xxx` direct workflows
3. Test tool selection priority
4. Test dependency-based dispatch

---

## Success Criteria

1. `/dev-stack "fix login bug"` → Auto-classifies as bug_fix → Routes to superpowers
2. `/dev-stack "add user auth"` → Auto-classifies as new_feature → Routes to speckit
3. `/dev-stack:bug "fix crash"` → Direct bug_fix workflow
4. Tool selection uses serena for code, fetch for web
5. Dependency-based dispatch works correctly
6. No file creation from orchestrator (only from sub-agents)

---

## References

- Tools list: `/Users/tanaphat.oiu/.claude/memory/tools_name.md`
- speckit commands: `/Users/tanaphat.oiu/.claude/.claude/commands/speckit.*.md`
- superpowers skills: `/Users/tanaphat.oiu/.claude/plugins/cache/claude-plugins-official/superpowers/`
