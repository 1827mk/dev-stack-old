#!/usr/bin/env bash
# SessionStart hook — inject dev-stack context into Claude's session
# Outputs JSON with additionalContext (silently injected, no user-visible message)

set -euo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$(dirname "$0")")")}"

INPUT=$(cat)
SOURCE=$(echo "$INPUT" | grep -o '"source":"[^"]*"' | cut -d'"' -f4 2>/dev/null || echo "startup")
CWD=$(echo "$INPUT" | grep -o '"cwd":"[^"]*"' | cut -d'"' -f4 2>/dev/null || pwd)

# Detect if .specify/ exists (initialized project)
SPECIFY_DIR="$CWD/.specify"
HAS_SPECIFY=false
[ -d "$SPECIFY_DIR" ] && HAS_SPECIFY=true

# Build context
CONTEXT=""

# --- Core identity ---
CONTEXT="You have the dev-stack plugin active (SDD+DDD+BDD+TDD orchestration).

AVAILABLE COMMANDS:
  /dev-stack              Smart entry — describe anything, orchestrator routes automatically
  /dev-stack:dev          Force dev workflow (bypass classifier)
  /dev-stack:resume [id]  Resume pending feature
  /dev-stack:status [id]  Show progress + velocity
  /dev-stack:review       Code review on changed files
  /dev-stack:audit        Security + code review in parallel
  /dev-stack:snapshot     Save session state (run before branch switch)
  /dev-stack:pr           Generate PR description
  /dev-stack:drift [id]   Detect spec vs code gaps
  /dev-stack:impact       Pre-change risk analysis
  /dev-stack:adr          Query architecture decisions
  /dev-stack:retro        Retrospective → constitution.md"

# --- Project state ---
if $HAS_SPECIFY; then
  CONSTITUTION="$SPECIFY_DIR/memory/constitution.md"
  SPECS_DIR="$SPECIFY_DIR/specs"

  # Count active specs
  ACTIVE_COUNT=0
  PENDING_IDS=""
  if [ -d "$SPECS_DIR" ]; then
    for spec_file in "$SPECS_DIR"/*/spec.md; do
      [ -f "$spec_file" ] || continue
      STATUS=$(grep -m1 "^Status:" "$spec_file" 2>/dev/null | cut -d' ' -f2 || echo "")
      if [ "$STATUS" != "COMPLETE" ]; then
        ACTIVE_COUNT=$((ACTIVE_COUNT + 1))
        SPEC_ID=$(basename "$(dirname "$spec_file")")
        PENDING_IDS="$PENDING_IDS $SPEC_ID"
      fi
    done
  fi

  # Constitution summary
  if [ -f "$CONSTITUTION" ]; then
    STACK_LINE=$(grep -m1 "^Stack:" "$CONSTITUTION" 2>/dev/null || echo "")
    CONTEXT="$CONTEXT

PROJECT STATE (.specify initialized):
  Constitution: found$([ -n "$STACK_LINE" ] && echo " | $STACK_LINE" || echo "")"
  else
    CONTEXT="$CONTEXT

PROJECT STATE (.specify initialized):
  Constitution: not yet generated (will auto-create on first /dev-stack:dev)"
  fi

  if [ "$ACTIVE_COUNT" -gt 0 ]; then
    CONTEXT="$CONTEXT
  Active specs: $ACTIVE_COUNT — IDs:$PENDING_IDS
  → Run /dev-stack:status to see progress, or /dev-stack:resume [id] to continue"
  else
    CONTEXT="$CONTEXT
  Active specs: none — ready for new feature"
  fi

  # Git branch context
  if command -v git &>/dev/null && git -C "$CWD" rev-parse --git-dir &>/dev/null 2>&1; then
    BRANCH=$(git -C "$CWD" branch --show-current 2>/dev/null || echo "")
    DIRTY=$(git -C "$CWD" diff --name-only HEAD 2>/dev/null | wc -l | tr -d ' ')
    if [ -n "$BRANCH" ]; then
      CONTEXT="$CONTEXT
  Git: branch=$BRANCH, changed files=$DIRTY"
    fi
  fi

  # Resume hint after compact
  if [ "$SOURCE" = "compact" ]; then
    CONTEXT="$CONTEXT

NOTE: Context was compacted. If you were mid-workflow, run /dev-stack:resume to restore state."
  fi

else
  # No .specify yet
  CONTEXT="$CONTEXT

PROJECT STATE: Not yet initialized
  → Use /dev-stack to start your first feature (constitution.md will be auto-generated)"
fi

# ═══════════════════════════════════════════════════════════════
# LAYER 1: Inject Tool Catalog
# ═══════════════════════════════════════════════════════════════

TOOL_CATALOG=$("$PLUGIN_ROOT/hooks/scripts/lib/discovery.sh" --catalog 2>/dev/null || echo '{"total":0}')

TOOL_COUNT=$(echo "$TOOL_CATALOG" | jq -r '.total // 0')

if [ "$TOOL_COUNT" -gt 0 ]; then
  CONTEXT="$CONTEXT

🧰 Available Tools: $TOOL_COUNT discovered
  Priority: MCP → Plugin → Skill → Built-in
  Run /dev-stack:tools to see full catalog"
fi

# Output as hookSpecificOutput.additionalContext (correct format per docs)
jq -n --arg ctx "$CONTEXT" '{
  hookSpecificOutput: {
    hookEventName: "SessionStart",
    additionalContext: $ctx
  }
}'

exit 0
