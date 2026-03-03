# Implementation Plan

**Spec ID:** 001
**Version:** 6.3.0

## Architecture Decision Records

### ADR-001: Team Messaging Architecture
**Decision:** Use file-based message queue in `.specify/specs/{id}/team-messages.log`
**Rationale:** Simple, persistent, no external dependencies. Agents append messages which are readable by all teammates.
**Consequences:** Messages persist across sessions, but no real-time push. Acceptable for async agent workflow.

### ADR-002: Plan Mode Implementation
**Decision:** New command `/dev-stack:plan` that sets `MODE=plan` in orchestrator
**Rationale:** Reuses existing classification and analysis logic. Only difference is stopping before implementation phase.
**Consequences:** Minimal code changes, consistent UX.

### ADR-003: Notification Implementation
**Decision:** Shell script using `osascript` (macOS) and `notify-send` (Linux)
**Rationale:** Native, no dependencies, works in background.
**Consequences:** Platform-specific code, but well-supported.

### ADR-004: Memory Sync Strategy
**Decision:** Hook into phase completion, extract patterns via lib-intelligence
**Rationale:** Leverages existing intelligence infrastructure.
**Consequences:** Adds slight overhead to phase transitions.

---

## Implementation Order

| Phase | Feature | Complexity | Dependencies |
|-------|---------|------------|--------------|
| 1 | Plan Mode | Low | None |
| 2 | Status Line | Low | None |
| 3 | Checkpointing Awareness | Low | None |
| 4 | Notification Hooks | Medium | None |
| 5 | Auto Memory Sync | Medium | lib-intelligence |
| 6 | Agent Teams | High | orchestrator |
| 7 | MCP Tool Search Config | Medium | lib-router |

---

## File Changes

### New Files (6)

1. `commands/plan.md` - Plan mode command
2. `agents/team-coordinator.md` - Team messaging agent
3. `hooks/scripts/notify.sh` - Desktop notifications
4. `hooks/scripts/status-line.sh` - Status line hook
5. `hooks/prompts/checkpoint-reminder.md` - Reminder template
6. `skills/lib-intelligence/references/memory-sync.md` - Memory sync guide

### Modified Files (5)

1. `.claude-plugin/plugin.json` - Version bump, new config
2. `hooks/hooks.json` - Add notification/status hooks
3. `agents/orchestrator.md` - Team messaging, plan mode routing
4. `skills/lib-router/SKILL.md` - Tool search optimization
5. `README.md` - Document new features
