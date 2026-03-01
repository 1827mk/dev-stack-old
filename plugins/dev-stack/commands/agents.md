---
description: (A):Smart entry point — auto-routes to best workflow (bug/feature/refactor/security/hotfix)
---

IF INPUT IS EMPTY, SHOW THIS MENU FIRST:

```
╔═══════════════════════════════════════════════════════════════╗
║                    🚀 dev-stack v7.7.0                        ║
║              Enterprise Dev Orchestration                     ║
╠═══════════════════════════════════════════════════════════════╣
║  ⚡ /dev-stack:agents <task>                                  ║
║     Smart entry — describe what you want, we route it         ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  📦 CORE WORKFLOWS                                            ║
║  ─────────────────────────────────────────────────────────── ║
║  :core-feature    New functionality (full DDD/BDD)            ║
║  :core-bug        Bug fixes (quick process)                   ║
║  :core-hotfix     Emergency fixes (no gates)                  ║
║  :core-refactor   Code improvement (preserves behavior)       ║
║  :core-security   Security patches (full OWASP)               ║
║  :core-plan       Read-only analysis                          ║
║                                                               ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  🔀 GIT           │  📊 QUALITY      │  📁 INFO               ║
║  ───────────────  │  ──────────────  │  ──────────────        ║
║  :git-impact      │  :quality-audit  │  :info-adr             ║
║  :git-parallel    │  :quality-check  │  :info-help            ║
║  :git-pr          │  :quality-drift  │  :info-status          ║
║                   │  :quality-review │  :info-tools           ║
║                                                               ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  💾 SESSION                                                    ║
║  ─────────────────────────────────────────────────────────── ║
║  :session-resume    Resume pending feature                    ║
║  :session-retro     Run retrospective                         ║
║  :session-snapshot  Save state before switching               ║
║                                                               ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  Quick Start: /dev-stack:agents fix login bug                 ║
║  Full Help:   /dev-stack:info-help                            ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

THEN ASK USER: "What would you like to work on?"

---

OTHERWISE (INPUT PROVIDED), SPAWN ORCHESTRATOR:

```
subagent_type: dev-stack:orchestrator
prompt: |
  MODE: smart
  INPUT: $ARGUMENTS

  Execute the full workflow for this request.
```

---

**Quick Examples:**

```
/dev-stack:agents fix login bug
/dev-stack:agents add user authentication
/dev-stack:agents refactor database layer
/dev-stack:agents review security
```

---

## Workflow Constraints

**ALWAYS follow these rules when selecting commands:**

1. **ALWAYS** use `core-plan` before `core-feature` for complex features
2. **ALWAYS** use `core-security` (not `core-bug`) for vulnerabilities
3. **ALWAYS** run `quality-check` after implementation
4. **ALWAYS** run `session-snapshot` before switching branches
5. **ONLY** use `core-hotfix` for production emergencies
