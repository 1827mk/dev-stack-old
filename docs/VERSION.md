# Version Reference - dev-stack

## Current Version: 8.0.0

## Release Date: 2026-03-01

## Plugin Status: ✅ Production Ready

---

## Version History

| Version | Release Date | Status | Key Changes |
|--------|-------------|--------|-------------|
| 8.0.0 | 2026-03-01 | ✅ Current | 11 unified commands (down from 21) |
| 7.7.0 | 2026-03-01 | ✅ Stable | Interactive menu |
| 7.6.0 | 2026-03-01 | ✅ Stable | Visual prefixes |
| 7.5.0 | 2026-03-01 | ✅ Stable | Simplified descriptions |
| 7.4.0 | 2026-03-01 | ✅ Stable | Enhanced context |
| 7.3.0 | 2026-03-01 | ✅ Stable | Category prefixes |
| 7.2.0 | 2026-03-01 | ✅ Stable | Smart entry point |
| 7.1.0 | 2026-03-01 | ✅ Stable | Command restructure |
| 7.0.0 | 2026-03-01 | ✅ Stable | Major rewrite |
| 6.x.x | 2026-02-28 | ⚠️ Legacy | Pre-v7 architecture |
| 5.x.x | 2026-02-27 | ⚠️ Legacy | Initial architecture |
| 4.x.x | 2026-02-26 | ⚠️ Legacy | Basic plugin |
| 3.x.x | 2026-02-25 | ⚠️ Legacy | Proof of concept |
| 2.x.x | 2026-02-24 | ⚠️ Legacy | Initial design |
| 1.0.0 | 2026-02-20 | ⚠️ Legacy | Initial version |

---

## Commands Reference

### Current Commands (v8.0.0)

| Command | Description | Workflow |
|---------|-------------|----------|
| `/dev-stack:agents` | Smart router | Auto-routes to best workflow |
| `/dev-stack:bug` | Bug fix | senior-developer + qa-engineer |
| `/dev-stack:feature` | New feature | Full DDD/BDD team |
| `/dev-stack:hotfix` | Emergency fix | senior-developer only |
| `/dev-stack:plan` | Read-only analysis | domain-analyst + solution-architect |
| `/dev-stack:refactor` | Code improvement | senior-developer + qa-engineer + quality-gatekeeper |
| `/dev-stack:security` | Security patch | senior-developer + quality-gatekeeper + qa-engineer |
| `/dev-stack:git` | Git operations | devops-engineer |
| `/dev-stack:info` | Information | documentation-writer |
| `/dev-stack:quality` | Quality checks | quality-gatekeeper |
| `/dev-stack:session` | Session management | team-coordinator |

### Deprecated Commands (Pre-v8.0.0)
| Old Command | Replacement |
|---------------|------------|
| `/dev-stack:core-bug` | `/dev-stack:bug` |
| `/dev-stack:core-feature` | `/dev-stack:feature` |
| `/dev-stack:core-hotfix` | `/dev-stack:hotfix` |
| `/dev-stack:core-plan` | `/dev-stack:plan` |
| `/dev-stack:core-refactor` | `/dev-stack:refactor` |
| `/dev-stack:core-security` | `/dev-stack:security` |
| `/dev-stack:git-impact` | `/dev-stack:git impact` |
| `/dev-stack:git-parallel` | `/dev-stack:git parallel` |
| `/dev-stack:git-pr` | `/dev-stack:git pr` |
| `/dev-stack:info-adr` | `/dev-stack:info adr` |
| `/dev-stack:info-help` | `/dev-stack:info help` |
| `/dev-stack:info-status` | `/dev-stack:info status` |
| `/dev-stack:info-tools` | `/dev-stack:info tools` |
| `/dev-stack:quality-audit` | `/dev-stack:quality audit` |
| `/dev-stack:quality-check` | `/dev-stack:quality check` |
| `/dev-stack:quality-drift` | `/dev-stack:quality drift` |
| `/dev-stack:quality-review` | `/dev-stack:quality review` |
| `/dev-stack:session-resume` | `/dev-stack:session resume` |
| `/dev-stack:session-retro` | `/dev-stack:session retro` |
| `/dev-stack:session-snapshot` | `/dev-stack:session snapshot` |

---

## Agents Reference

### Core Team (11 agents)

| Agent | Model | Role |
|-------|-------|------|
| orchestrator | sonnet | Routes requests, assembles teams |
| domain-analyst | sonnet | Creates DDD specs with BDD scenarios |
| solution-architect | sonnet | Designs architecture, writes ADRs |
| tech-lead | sonnet | Decomposes plan into atomic tasks |
| senior-developer | sonnet | Implements via TDD |
| quality-gatekeeper | sonnet | Reviews code + security |
| qa-engineer | haiku | Validates test coverage |
| devops-engineer | haiku | Deployment config, CI/CD |
| performance-engineer | sonnet | Performance analysis |
| documentation-writer | haiku | Generates documentation |
| team-coordinator | haiku | Team communication |

### Model Distribution

| Model | Count | Use Case |
|-------|-------|--------|
| sonnet | 7 | Complex reasoning, architecture, TDD |
| haiku | 4 | Fast operations, documentation, QA |

---

## Skills Reference

### Internal Libraries (6 skills)

| Skill | Type | Description |
|-------|------|-------------|
| lib-domain | Library | DDD modeling + BDD authoring |
| lib-intelligence | Library | Snapshot, drift, impact, PR |
| lib-router | Library | Tool routing |
| lib-tdd | Library | TDD cycle + constitution |
| lib-workflow | Library | Workflow classification + gates |
| orchestration | Skill | Central routing + coordination |

---

## Hooks Reference

### Event Hooks (5 hooks)

| Hook | Event | Script |
|------|-------|--------|
| SessionStart | Session start | session-start.sh |
| UserPromptSubmit | User prompt | auto-router.sh |
| PreToolUse | Before tool use | pre-tool-guard.sh |
| PostToolUse | After tool use | status-line.sh |
| Notification | Notifications | notify.sh |

---

## Performance Metrics

### Response Times

| Operation | Average | Rating |
|-----------|---------|--------|
| Menu display | <5ms | ⚡⚡⚡⚡⚡ |
| Classification | <10ms | ⚡⚡⚡⚡⚡ |
| Git operations | <500ms | ⚡⚡⚡⚡ |
| Quality checks | 10-30s | ⚡⚡⚡ |
| Bug fix | 2-5min | ⚡⚡⚡ |
| Full feature | 30-60min | ⚡⚡ |

---

## Migration Guide

### From v7.x to v8.0.0

1. **Update command calls:**
   - Old: `/dev-stack:core-bug "fix login"`
   - New: `/dev-stack:bug "fix login bug"

2. **Use unified commands:**
   - Old: `/dev-stack:git-impact`
   - New: `/dev-stack:git impact`

3. **Update hooks** (no changes needed)

4. **Update agents** (no changes needed)

5. **Update skills** (no changes needed)

---

*Last updated: 2026-03-01*
*Plugin version: 8.0.0*
