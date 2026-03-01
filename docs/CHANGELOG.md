# Changelog - dev-stack

All notable changes to the dev-stack plugin.

---

## [8.0.0] - 2026-03-01

### 🚀 Major Refactor - Unified Smart Commands

#### Changed
- **Commands reduced from 21 to 11** - Each command is now a smart router
- **All `core-*` commands renamed** - Removed `core-` prefix:
  - `/dev-stack:core-bug` → `/dev-stack:bug`
  - `/dev-stack:core-feature` → `/dev-stack:feature`
  - `/dev-stack:core-hotfix` → `/dev-stack:hotfix`
  - `/dev-stack:core-plan` → `/dev-stack:plan`
  - `/dev-stack:core-refactor` → `/dev-stack:refactor`
  - `/dev-stack:core-security` → `/dev-stack:security`
- **Git commands unified** - All git operations now under `/dev-stack:git`:
  - `/dev-stack:git-impact` → `/dev-stack:git impact`
  - `/dev-stack:git-parallel` → `/dev-stack:git parallel`
  - `/dev-stack:git-pr` → `/dev-stack:git pr`
- **Info commands unified** - All info operations now under `/dev-stack:info`:
  - `/dev-stack:info-adr` → `/dev-stack:info adr`
  - `/dev-stack:info-help` → `/dev-stack:info help`
  - `/dev-stack:info-status` → `/dev-stack:info status`
  - `/dev-stack:info-tools` → `/dev-stack:info tools`
- **Quality commands unified** - All quality operations now under `/dev-stack:quality`:
  - `/dev-stack:quality-audit` → `/dev-stack:quality audit`
  - `/dev-stack:quality-check` → `/dev-stack:quality check`
  - `/dev-stack:quality-drift` → `/dev-stack:quality drift`
  - `/dev-stack:quality-review` → `/dev-stack:quality review`
- **Session commands unified** - All session operations now under `/dev-stack:session`:
  - `/dev-stack:session-resume` → `/dev-stack:session resume`
  - `/dev-stack:session-retro` → `/dev-stack:session retro`
  - `/dev-stack:session-snapshot` → `/dev-stack:session snapshot`

#### Added
- **Smart routing** - Each command now auto-detects intent from natural language
- **Interactive menus** - Commands show menu when called without arguments
- **Full tool access** - All commands can access all agents, skills, and MCP servers

#### Fixed
- **Agent subagent issue** - Fixed agents.md to not spawn non-existent subagents
- **Plugin agents are instructions** - Clarified that plugin agents are read as instructions, not spawned

---

## [7.7.0] - 2026-03-01

### Added
- **Interactive Grouped Menu** - `/dev-stack:agents` shows ASCII menu when called without arguments
- **Smart routing** - Menu displayed first, then accepts user input
- **Organized layout** - Commands grouped by category (Core, Git, Info, Quality, Session)

---

## [7.6.0] - 2026-03-01

### Added
- **Visual category prefixes** - `(A):` Agents, `(C):` Core, `(G):` Git, `(I):` Info, `(Q):` Quality, `(S):` Session
- **Instant visual grouping** - See command category at a glance

---

## [7.5.0] - 2026-03-01

### Changed
- **Simplified descriptions** - All commands have concise, readable descriptions
- **Better picker UX** - No more cluttered multi-line text

---

## [7.4.0] - 2026-03-01

### Added
- **Enhanced descriptions** - All commands include WORKFLOW, PHASE, USE WHEN context
- **Workflow constraints** - Clear rules for when to use each command

---

## [7.3.0] - 2026-03-01

### Changed
- **Category-prefixed commands** - `:bug` → `:core-bug`, `:feature` → `:core-feature`, etc.
- **Alphabetical grouping** - Commands sort by category in picker

---

## [7.2.0] - 2026-03-01

### Changed
- **Smart entry renamed** - `/dev-stack:dev-stack` → `/dev-stack:agents`
- **Commands sorted by frequency** - Most used first

---

## [7.1.0] - 2026-03-01

### Added
- **Category-prefixed commands** for better organization
  - Info: `info-status`, `info-tools`, `info-help`, `info-adr`
  - Quality: `quality-check`, `quality-review`, `quality-audit`, `quality-drift`
  - Session: `session-resume`, `session-snapshot`, `session-retro`
  - Git: `git-pr`, `git-impact`, `git-parallel`

---

## [7.0.0] - 2026-03-01

### Added
- **11 specialized agents** (was 9)
- **Unified quality-gatekeeper** - Replaces code-reviewer + security-auditor
- **7 workflow types** with optimized team compositions
- **5 quality gates** - DoR, ArchReview, TaskReady, BDDCoverage, DoD
- **Intelligent auto-routing** with confidence thresholds
- **Parallel agent dispatch** for faster execution
- **Real-time status line updates**
- **Desktop notifications** for gate events

---

## [6.x] - Pre-7.0

### Historical
- Initial plugin structure
- Basic command set
- Simple workflow routing

---

## Version Summary

| Version | Date | Commands | Key Change |
|---------|------|----------|------------|
| 8.0.0 | 2026-03-01 | 11 | Unified smart commands |
| 7.7.0 | 2026-03-01 | 21 | Interactive menu |
| 7.6.0 | 2026-03-01 | 21 | Visual prefixes |
| 7.5.0 | 2026-03-01 | 21 | Simplified descriptions |
| 7.4.0 | 2026-03-01 | 21 | Enhanced context |
| 7.3.0 | 2026-03-01 | 21 | Category prefixes |
| 7.2.0 | 2026-03-01 | 21 | Renamed entry point |
| 7.1.0 | 2026-03-01 | 21 | Command organization |
| 7.0.0 | 2026-03-01 | 21 | Major rewrite |
