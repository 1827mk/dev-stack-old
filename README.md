# dev-stack v7.0.0

> SDD + DDD + BDD + TDD Orchestration Plugin for Claude Code

A comprehensive development orchestration system that automates software development workflows with specialized agents, quality gates, and intelligent routing.

## Features

- **11 Specialized Agents** - Each with specific roles and tools
- **7 Workflow Types** - Optimized for different development scenarios
- **5 Quality Gates** - Ensure code quality and consistency
- **22 Commands** - Quick access to common operations
- **Intelligent Routing** - Auto-classifies intent and assembles the right team

## Quick Start

### Install from Marketplace

```bash
# In Claude Code
/install-marketplace https://github.com/1827mk/dev-stack
```

### Basic Usage

```bash
# Smart entry - auto-routes based on intent
/dev-stack add user authentication

# Direct workflow commands (faster)
/dev-stack:feature add login system
/dev-stack:bug fix null pointer in auth
/dev-stack:hotfix critical security issue
/dev-stack:refactor database layer
/dev-stack:security fix XSS vulnerability
```

## Agents

| Agent | Role | Model |
|-------|------|-------|
| **orchestrator** | Central router, team assembly | sonnet |
| **domain-analyst** | DDD/BDD spec creation | sonnet |
| **solution-architect** | Architecture + ADRs | sonnet |
| **tech-lead** | Task decomposition | sonnet |
| **senior-developer** | TDD implementation | sonnet |
| **quality-gatekeeper** | Code + security review | sonnet |
| **qa-engineer** | Test coverage validation | haiku |
| **devops-engineer** | Deployment config | haiku |
| **team-coordinator** | Team communication | haiku |
| **performance-engineer** | Performance analysis | sonnet |
| **documentation-writer** | Documentation generation | haiku |

## Workflows

| Workflow | Description | Team | Gates |
|----------|-------------|------|-------|
| **new_feature** | Full DDD/BDD with all gates | Full team | All 5 gates |
| **bug_fix** | Minimal spec, quick resolution | domain → dev → qa → gate | DoR, DoD |
| **hotfix** | Emergency path | dev → gate | None |
| **refactor** | Structure improvement | architect → dev → gate | ArchReview, DoD |
| **security_patch** | Full OWASP validation | dev → gate (full) → qa | DoR, DoD |
| **architecture** | Greenfield/legacy analysis | Full team | All gates |
| **spike** | Research-only | domain-analyst | None |

## Quality Gates

```
DoR (Definition of Ready)
  └─ spec.md exists, no [NEEDS CLARIFICATION], 3+ BDD scenarios

ArchReview (Architecture Review)
  └─ plan.md exists, ADRs documented, layer boundaries defined

TaskReady (Task Preparation)
  └─ BDD reference, [test-first] tag, single layer, ≤4h estimate

BDDCoverage (Test Coverage)
  └─ Every BDD scenario has test, exact titles match

DoD (Definition of Done)
  └─ All gates pass, all tasks [x], compile + lint + typecheck PASS
```

## Commands

### Workflow Commands

| Command | Description |
|---------|-------------|
| `/dev-stack` | Smart entry - auto-routes based on intent |
| `/dev-stack:feature` | New feature with full DDD/BDD |
| `/dev-stack:bug` | Bug fix with minimal process |
| `/dev-stack:hotfix` | Emergency hotfix, no gates |
| `/dev-stack:refactor` | Code refactoring |
| `/dev-stack:security` | Security patch with OWASP |
| `/dev-stack:plan` | Read-only analysis mode |

### Utility Commands

| Command | Description |
|---------|-------------|
| `/dev-stack:dev` | Force dev workflow |
| `/dev-stack:resume` | Resume pending feature |
| `/dev-stack:status` | Show active features |
| `/dev-stack:check` | Run lint + typecheck + build |
| `/dev-stack:review` | Code review |
| `/dev-stack:audit` | Security + code review parallel |
| `/dev-stack:pr` | Generate PR description |
| `/dev-stack:drift` | Detect spec vs code gaps |
| `/dev-stack:impact` | Pre-change risk analysis |
| `/dev-stack:adr` | Query architecture decisions |
| `/dev-stack:retro` | Retrospective → constitution |
| `/dev-stack:snapshot` | Save session state |
| `/dev-stack:parallel` | Multiple features in worktrees |
| `/dev-stack:tools` | Show available tools |
| `/dev-stack:help` | Command reference |

## Hooks

| Hook | Event | Purpose |
|------|-------|---------|
| **session-start.sh** | SessionStart | Inject dev-stack context |
| **status-line.sh** | SessionStart/PostToolUse | Update status line |
| **auto-router.sh** | UserPromptSubmit | Auto-route dev tasks |
| **pre-tool-guard.sh** | PreToolUse | Block destructive commands |
| **notify.sh** | Notification | Desktop notifications |

## Skills (Internal Libraries)

| Skill | Purpose |
|-------|---------|
| **orchestration** | MODE routing, team dispatch, boot sequences |
| **lib-router** | AI-optimized tool mapping |
| **lib-workflow** | Workflow classification, team composition |
| **lib-domain** | DDD modeling, BDD authoring |
| **lib-tdd** | TDD cycle, constitution builder |
| **lib-intelligence** | Snapshot, drift, impact, memory sync |

## Project Structure

```
dev-stack-marketplace/
├── plugins/dev-stack/
│   ├── agents/           # 11 specialized agents
│   ├── commands/         # 22 slash commands
│   ├── hooks/            # 5 hook scripts
│   │   ├── prompts/      # Prompt-based hooks
│   │   └── scripts/      # Shell script hooks
│   └── skills/           # 6 internal skills
│       └── references/   # Skill documentation
└── docs/
    └── plans/            # Design documents
```

## Requirements

- Claude Code CLI
- Git
- Bash 4.0+

## Version History

### v7.0.0 (2026-03-01)
- Complete rewrite with 11 specialized agents
- Unified quality-gatekeeper (replaces code-reviewer + security-auditor)
- 7 workflow types with optimized team compositions
- 5 quality gates (DoR, ArchReview, TaskReady, BDDCoverage, DoD)
- Intelligent auto-routing with confidence thresholds
- Parallel agent dispatch for faster execution

## License

MIT

## Author

Generated with Claude Code (Opus 4.6)
