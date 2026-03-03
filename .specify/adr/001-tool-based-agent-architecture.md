# ADR-001: Tool-Based Agent Architecture

## Status
Accepted

## Context

dev-stack v9.0.0 and earlier versions use **workflow-based agents** where:
- Agents are positioned in a fixed workflow sequence (domain-analyst → architect → tech-lead → developer → qa)
- Team composition is predetermined per workflow type
- Each agent has a specific role in the development lifecycle
- Agents cannot be reused across different workflows

### Problems with Workflow-Based Design

1. **Fixed Teams**: A bug fix uses the same agent sequence as a full feature
2. **Tool Underutilization**: Agents don't use all available tools (only ~60% of 145 tools)
3. **No Communication**: Agents work in isolation without sharing findings
4. **Rigid Structure**: Cannot adapt team composition to task complexity

## Decision

**Redesign agents around tool capabilities instead of workflow positions.**

### New Architecture

```
v9 (Workflow-Based)          v10 (Tool-Based)
────────────────────          ────────────────
domain-analyst ────┐          code-analyzer (serena tools)
                    │          code-writer (serena + context7)
solution-architect ─┤          researcher (context7 + web)
                    │          doc-writer (doc-forge)
tech-lead ──────────┤          qa-validator (bash + testing)
                    │          security-scanner (serena patterns)
senior-developer ───┤          git-operator (git commands)
                    │          memory-keeper (memory MCP)
qa-engineer ────────┤          task-planner (sequentialthinking)
                    │          file-manager (filesystem MCP)
devops-engineer ────┤          data-engineer (serena + DB)
                    │          orchestrator (coordinates all)
documentation-writer─┤
team-coordinator ───┘
```

### Key Principles

1. **Tool-First**: Agent identity comes from tool expertise
2. **Dynamic Assembly**: Orchestrator selects agents based on task needs
3. **Shared Memory**: Agents communicate via MCP memory
4. **Reuse**: Same agent can participate in multiple workflows

## Consequences

### Positive
- **Flexibility**: Team composition adapts to task complexity
- **Tool Coverage**: 100% of 145 tools mapped to agents
- **Reusability**: code-writer can work on bugs, features, or refactors
- **Communication**: Shared memory enables agent coordination
- **Scalability**: Easy to add new agents for new tools

### Negative
- **Learning Curve**: Users familiar with v9 need to adapt
- **Complexity**: Dynamic assembly is more complex than fixed teams
- **Orchestration**: Requires sophisticated orchestrator logic

### Neutral
- **Migration**: v9 commands will route through v10 orchestrator

## Alternatives Considered

### Alternative 1: Keep Workflow-Based with More Agents
- **Rejected**: Still has fixed team problem
- **Rejected**: Doesn't enable dynamic tool usage

### Alternative 2: Single Super-Agent with All Tools
- **Rejected**: Context window limits
- **Rejected**: Loss of specialization

### Alternative 3: Hybrid (Workflow + Tool-Based)
- **Considered**: Could provide backward compatibility
- **Decision**: Too complex to maintain two paradigms

## Implementation

### Phase 1: Core Infrastructure
- Create orchestrator with dynamic assembly
- Set up shared memory protocol
- Implement intent classification

### Phase 2: Code Agents
- code-analyzer, code-writer, qa-validator, security-scanner

### Phase 3: Support Agents
- doc-writer, git-operator, memory-keeper, task-planner, file-manager, data-engineer

### Phase 4: Integration
- Update commands, documentation, tests

## References

- [v10 Dynamic Orchestration Spec](../docs/specs/v10-dynamic-orchestration-spec.md)
- [145 Tools Reference](../docs/tools_name.md)
- [MCP Memory Documentation](https://modelcontextprotocol.io/servers/memory)

## Decision Makers

- **Proposed by**: @tanaphat.oiu
- **Approved by**: @tanaphat.oiu
- **Date**: 2026-03-01
