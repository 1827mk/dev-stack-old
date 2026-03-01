#!/usr/bin/env bash
# Auto-Router Hook (Layer 2) - Simplified
# Single script: classify + select + inject context
# Runs on UserPromptSubmit event

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty' 2>/dev/null || echo "")

# Skip if no prompt
[ -z "$PROMPT" ] && exit 0

# Quick Filter: Skip non-dev messages
DEV_KEYWORDS="build|create|fix|implement|add|refactor|test|code|bug|feature|deploy|debug|error|api|function|class|module|component|service|database|auth|login|security|migration"

if ! echo "$PROMPT" | grep -qiE "$DEV_KEYWORDS"; then
  exit 0  # Pass-through for non-dev messages
fi

# Run combined classifier + selector (single process instead of two)
# BUGFIX: Add error handling with graceful fallback
if ! RESULT=$("$LIB_DIR/router-core.sh" <<< "$INPUT" 2>/dev/null); then
  # Fallback: pass through without routing on error
  exit 0
fi

# Validate RESULT is valid JSON
if ! echo "$RESULT" | jq -e '.' >/dev/null 2>&1; then
  exit 0
fi

INTENT=$(echo "$RESULT" | jq -r '.intent')
DOMAIN=$(echo "$RESULT" | jq -r '.domain')
URGENCY=$(echo "$RESULT" | jq -r '.urgency')

PRIMARY=$(echo "$RESULT" | jq -r '.tools.primary_mcp | join(", ")')
SECONDARY=$(echo "$RESULT" | jq -r '.tools.secondary_agent | join(", ")')
FALLBACK=$(echo "$RESULT" | jq -r '.tools.fallback_builtin | join(", ")')

TDD=$(echo "$RESULT" | jq -r '.quality_gates.tdd')
BDD=$(echo "$RESULT" | jq -r '.quality_gates.bdd')

# Build context
case "$URGENCY" in
  critical) EMOJI="🚨" ;;
  high)     EMOJI="⚡" ;;
  *)        EMOJI="🔧" ;;
esac

GATES=""
[ "$TDD" = "true" ] && GATES="${GATES}✓TDD "
[ "$BDD" = "true" ] && GATES="${GATES}✓BDD "
GATES="${GATES}✓Review"

CONTEXT="$EMOJI dev-stack auto-route

Task: $INTENT | Domain: $DOMAIN
Tools: ${PRIMARY:-none} → ${SECONDARY:-$FALLBACK}
Quality: $GATES"

# Output
jq -n --arg ctx "$CONTEXT" '{
  hookSpecificOutput: {
    hookEventName: "UserPromptSubmit",
    additionalContext: $ctx
  }
}'

exit 0
