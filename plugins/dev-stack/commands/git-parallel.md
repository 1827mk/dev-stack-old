---
description: Run multiple features simultaneously in isolated git worktrees. Pass comma-separated feature descriptions or spec IDs (e.g. "user auth, payment flow" or "001, 003"). Max 4 parallel worktrees.
---
AGENT: orchestrator
MODE: parallel
INPUT: $ARGUMENTS
