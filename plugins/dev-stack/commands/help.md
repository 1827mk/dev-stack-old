---
description: Show command reference
---

# dev-stack v7.0.0

## Direct Workflow Commands (Fastest)

| Command | Use when |
|---------|----------|
| `/dev-stack:bug {desc}` | Fix a bug (skip architect) |
| `/dev-stack:feature {desc}` | New feature (full team) |
| `/dev-stack:hotfix {desc}` | Production emergency |
| `/dev-stack:refactor {desc}` | Code cleanup |
| `/dev-stack:security {desc}` | Security patch |

## Start Here

| Command | Use when |
|---------|----------|
| `/dev-stack {task}` | Any dev task (auto-routes) |
| `/dev-stack:dev {id}` | Continue specific feature |
| `/dev-stack:status` | Check progress |

## Quality

| Command | Use when |
|---------|----------|
| `/dev-stack:check` | Before commit |
| `/dev-stack:review` | Code review needed |
| `/dev-stack:audit` | Security review |

## Manage

| Command | Use when |
|---------|----------|
| `/dev-stack:resume` | List pending features |
| `/dev-stack:snapshot` | Save before switch |
| `/dev-stack:pr` | Create PR |

## Advanced

| Command | Use when |
|---------|----------|
| `/dev-stack:parallel` | Multiple features |
| `/dev-stack:drift` | Spec vs code gap |
| `/dev-stack:tools` | See tool catalog |

---

**v7.0.0 New Features:**
- AI-optimized tool routing (lib-router)
- Sub-system selection (speckit/superpowers/direct)
- Dependency graph execution with parallel dispatch
- Unified quality-gatekeeper (code + security)
- Enhanced fast-path routing with expanded keywords
