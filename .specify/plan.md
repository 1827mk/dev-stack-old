# Implementation Plan: dev-stack v10.0.0

> **Status**: Draft
> **Created**: 2026-03-01
> **Based on**: spec.md

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        v10.0.0 ARCHITECTURE                                  │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   USER INPUT                                                                │
│       │                                                                     │
│       ▼                                                                     │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                     ORCHESTRATOR                                     │   │
│   │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────┐  │   │
│   │  │ Intent          │  │ Capability      │  │ Team Assembly       │  │   │
│   │  │ Classification  │─▶│ Mapping         │─▶│ (Dynamic)           │  │   │
│   │  └─────────────────┘  └─────────────────┘  └─────────────────────┘  │   │
│   └─────────────────────────────┬───────────────────────────────────────┘   │
│                                 │                                           │
│                                 ▼                                           │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                     SHARED MEMORY (MCP)                              │   │
│   │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────────┐  │   │
│   │  │ TaskContext │  │ AgentFindings│  │ Relations & Observations    │  │   │
│   │  └─────────────┘  └─────────────┘  └─────────────────────────────┘  │   │
│   └─────────────────────────────┬───────────────────────────────────────┘   │
│                                 │                                           │
│       ┌─────────────────────────┼─────────────────────────┐                │
│       │                         │                         │                │
│       ▼                         ▼                         ▼                │
│   ┌─────────────┐         ┌─────────────┐         ┌─────────────┐         │
│   │ CODE CLUSTER│         │KNOWLEDGE    │         │ OPS CLUSTER │         │
│   │             │         │ CLUSTER     │         │             │         │
│   │ analyzer    │         │ researcher  │         │ git-operator│         │
│   │ writer      │         │ doc-writer  │         │ file-manager│         │
│   │ qa-validator│         │ memory-keeper│        │ data-engineer│        │
│   │ sec-scanner │         │ task-planner│         │             │         │
│   └─────────────┘         └─────────────┘         └─────────────┘         │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Layer Design

### Layer 1: Orchestration Layer

**Purpose**: Coordinate all agents and manage task flow

| Component | File | Responsibility |
|-----------|------|----------------|
| Orchestrator Agent | `agents/orchestrator.md` | Master coordinator |
| Orchestration Skill | `skills/lib-orchestration/SKILL.md` | Shared logic |
| Intent Classification | `skills/lib-orchestration/references/intent-classification.md` | Classify user intent |
| Capability Mapping | `skills/lib-orchestration/references/capability-mapping.md` | Map to capabilities |
| Team Assembly | `skills/lib-orchestration/references/team-assembly.md` | Dynamic assembly |
| Memory Protocol | `skills/lib-orchestration/references/memory-protocol.md` | Communication |

### Layer 2: Agent Layer (12 Agents)

**Purpose**: Execute specialized tasks with tool expertise

| Cluster | Agents | Tools Focus |
|---------|--------|-------------|
| CODE | analyzer, writer, qa-validator, sec-scanner | serena, context7, Bash |
| KNOWLEDGE | researcher, doc-writer, memory-keeper, task-planner | context7, doc-forge, memory, sequentialthinking |
| OPS | git-operator, file-manager, data-engineer | Bash, filesystem, serena |

### Layer 3: Command Layer (12 Commands)

**Purpose**: User-facing interface with scope control

| Command | Scope | Primary Agents |
|---------|-------|----------------|
| `/dev-stack:agents` | Full dynamic | All (orchestrator decides) |
| `/dev-stack:bug` | Bug fix | analyzer, writer, qa |
| `/dev-stack:feature` | New feature | All (full team) |
| `/dev-stack:security` | Security | sec-scanner, writer, qa |
| `/dev-stack:refactor` | Refactoring | analyzer, writer, qa |
| `/dev-stack:research` | Research | researcher, doc-writer |
| `/dev-stack:git` | Git ops | git-operator |
| `/dev-stack:quality` | Quality | qa-validator, sec-scanner |
| `/dev-stack:docs` | Documentation | doc-writer, researcher |
| `/dev-stack:data` | Database | data-engineer |
| `/dev-stack:plan` | Planning | task-planner, researcher |
| `/dev-stack:resume` | Session | orchestrator, memory-keeper |

### Layer 4: Infrastructure Layer

**Purpose**: Hooks, scripts, and configuration

| Component | File | Purpose |
|-----------|------|---------|
| PreToolUse Hook | `hooks/scripts/pre-tool-guard.sh` | Git safety enforcement |
| Status Line | `hooks/scripts/status-line.sh` | Progress display |
| Hooks Config | `hooks/hooks.json` | Hook registration |
| Plugin Config | `.claude-plugin/plugin.json` | Plugin metadata |

---

## Architecture Decision Records (ADRs)

### ADR-001: Tool-Based Agent Design

**Status**: Accepted

**Context**: v9 uses workflow-based agents (domain-analyst → architect → dev → qa) which creates fixed teams that don't adapt to task needs.

**Decision**: Redesign agents around tool capabilities instead of workflow positions.

**Consequences**:
- (+) Agents can be reused across workflows
- (+) Dynamic team assembly based on actual needs
- (+) Better tool coverage
- (-) Requires new orchestration logic
- (-) Learning curve for existing users

### ADR-002: MCP Memory as Communication Layer

**Status**: Accepted

**Context**: Agents need to share findings and coordinate work. No existing mechanism.

**Decision**: Use MCP memory server as shared memory layer for inter-agent communication.

**Consequences**:
- (+) Structured entity-observation model
- (+) Persistent across sessions
- (+) Queryable
- (-) Requires MCP memory to be running
- (-) Fallback needed if unavailable

### ADR-003: Git Safety Policy

**Status**: Accepted

**Context**: Users need control over git commit/push operations.

**Decision**: All git write operations require explicit user confirmation via PreToolUse hook.

**Consequences**:
- (+) User always in control of changes
- (+) No accidental commits/pushes
- (-) Extra step for every git operation
- (-) May slow down workflows

### ADR-004: Tool Priority Hierarchy

**Status**: Accepted

**Context**: Multiple tools can achieve same result (e.g., serena search vs Grep).

**Decision**: Establish priority: MCP > Plugins > Skills > Built-in

**Consequences**:
- (+) Consistent tool selection
- (+) Prefer more capable tools
- (+) Clear fallback chain
- (-) Requires availability checks
- (-) Fallback may be less capable

### ADR-005: SDD Workflow Integration

**Status**: Accepted

**Context**: Tasks may span multiple sessions or require handoff.

**Decision**: Integrate with spec-kit SDD workflow via .specify/ directory.

**Consequences**:
- (+) Resume incomplete tasks
- (+) Switch branches without losing progress
- (+) Handoff to other developers
- (-) Requires discipline to use SDD
- (-) Additional files to maintain

---

## Tech Stack

| Layer | Technology | Version |
|-------|------------|---------|
| Runtime | Claude Code CLI | Latest |
| Agent Framework | Claude Code Agents | Native |
| Memory | MCP memory | Latest |
| Code Analysis | MCP serena | Latest |
| Documentation | MCP doc-forge | Latest |
| File Ops | MCP filesystem | Latest |
| Research | MCP context7, web_reader | Latest |
| Planning | MCP sequentialthinking | Latest |
| Shell | Bash | 4.0+ |
| VCS | Git | 2.0+ |

---

## File Manifest

### New Files to Create

```
plugins/dev-stack/
├── agents/
│   ├── orchestrator.md          # NEW (redesigned)
│   ├── code-analyzer.md         # NEW
│   ├── code-writer.md           # NEW
│   ├── researcher.md            # NEW
│   ├── doc-writer.md            # NEW
│   ├── qa-validator.md          # NEW
│   ├── security-scanner.md      # NEW
│   ├── git-operator.md          # NEW
│   ├── memory-keeper.md         # NEW
│   ├── task-planner.md          # NEW
│   ├── file-manager.md          # NEW
│   └── data-engineer.md         # NEW (updated)
├── commands/
│   ├── agents.md                # NEW (master command)
│   ├── bug.md                   # UPDATE
│   ├── feature.md               # UPDATE
│   ├── security.md              # UPDATE
│   ├── refactor.md              # UPDATE
│   ├── research.md              # NEW
│   ├── git.md                   # UPDATE
│   ├── quality.md               # UPDATE
│   ├── docs.md                  # NEW
│   ├── data.md                  # NEW
│   ├── plan.md                  # UPDATE
│   └── resume.md                # NEW
├── skills/
│   └── lib-orchestration/
│       ├── SKILL.md             # NEW
│       └── references/
│           ├── intent-classification.md  # NEW
│           ├── capability-mapping.md     # NEW
│           ├── team-assembly.md          # NEW
│           └── memory-protocol.md        # NEW
└── hooks/
    └── scripts/
        └── shared-memory-init.sh  # NEW
```

### Files to Update

```
plugins/dev-stack/
├── .claude-plugin/plugin.json   # Version to 10.0.0
├── hooks/hooks.json             # Add new hooks if needed
├── hooks/scripts/pre-tool-guard.sh  # Ensure git safety
└── README.md                    # Update documentation

dev-stack-marketplace/
├── .claude-plugin/marketplace.json  # Version to 10.0.0
└── README.md                        # Update documentation
```

### Files to Remove/Deprecate

```
plugins/dev-stack/agents/
├── domain-analyst.md     # Replaced by researcher + task-planner
├── solution-architect.md # Replaced by task-planner
├── senior-developer.md   # Replaced by code-analyzer + code-writer
├── tech-lead.md          # Replaced by task-planner
├── quality-gatekeeper.md # Replaced by security-scanner + qa-validator
├── qa-engineer.md        # Replaced by qa-validator
├── devops-engineer.md    # Replaced by git-operator + file-manager
├── performance-engineer.md # Replaced by code-analyzer (perf mode)
├── documentation-writer.md # Replaced by doc-writer
└── team-coordinator.md   # Replaced by memory-keeper
```

---

## Risk Mitigation

| Risk | Mitigation Strategy |
|------|---------------------|
| Breaking existing workflows | Compatibility layer for v9 commands |
| MCP unavailable | Fallback to built-in tools |
| Performance regression | Caching, parallel agent spawn |
| User confusion | Migration guide, documentation |
| Git safety bypass | PreToolUse hook enforcement |

---

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Intent Classification Accuracy | >= 90% | Manual testing |
| Tool Coverage | 100% | All 145 tools mapped |
| Dynamic Assembly Rate | >= 90% | All non-scoped commands |
| Memory Usage | 100% | All tasks use shared memory |
| Git Safety | 100% | Zero auto-commits |
| Performance: Team Assembly | < 5s | Benchmark |

---

## Dependencies

### Required MCP Servers
- [x] serena (26 tools)
- [x] memory (9 tools)
- [x] context7 (2 tools)
- [x] doc-forge (16 tools)
- [x] filesystem (15 tools)
- [x] sequentialthinking (1 tool)
- [x] web_reader (1 tool)
- [x] fetch (1 tool)
- [x] 4_5v_mcp (1 tool)

### Required Plugins
- [x] superpowers (TDD skills)
- [x] plugin-dev (for development)

---

## Timeline

| Phase | Duration | Focus |
|-------|----------|-------|
| Phase 1 | 1 week | Core Infrastructure (orchestrator, memory) |
| Phase 2 | 1 week | Code Agents (analyzer, writer, qa, security) |
| Phase 3 | 1 week | Support Agents (doc, git, file, data, memory, planner) |
| Phase 4 | 1 week | Integration, Commands, Documentation |

**Total**: 4 weeks
