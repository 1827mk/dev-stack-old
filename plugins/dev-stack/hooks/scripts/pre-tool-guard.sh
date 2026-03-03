#!/usr/bin/env bash
# PreToolUse — block destructive commands + protect sensitive files
# Simplified: use jq instead of inline Python

set -euo pipefail

INPUT=$(cat)
TOOL=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null || echo "")

# ── Bash tool guards ────────────────────────────────────────────────
if [ "$TOOL" = "Bash" ]; then
  CMD=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null || echo "")

  # Block rm -rf
  if echo "$CMD" | grep -qE '^\s*rm\s+-[a-z]*r[a-z]*f|^\s*rm\s+-[a-z]*f[a-z]*r'; then
    jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:"Blocked: rm -rf not allowed. Use specific paths."}}'
    exit 0
  fi

  # Block .specify deletion
  if echo "$CMD" | grep -qE 'rm.*\.specify|rm.*constitution\.md'; then
    jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:"Blocked: .specify/ files are protected."}}'
    exit 0
  fi

  # Warn on destructive SQL
  if echo "$CMD" | grep -qiE '\b(DROP\s+TABLE|TRUNCATE|DELETE\s+FROM)\b' && ! echo "$CMD" | grep -qi 'migration'; then
    jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"ask",permissionDecisionReason:"Destructive SQL detected. Confirm?"}}'
    exit 0
  fi

  # ── Git write operation guards (require confirmation) ────────────────
  # Block git commit (require confirmation)
  if echo "$CMD" | grep -qE 'git\s+commit'; then
    jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"ask",permissionDecisionReason:"⚠️ git commit requires user confirmation. Proceed?"}}'
    exit 0
  fi

  # Block git push (require confirmation)
  if echo "$CMD" | grep -qE 'git\s+push'; then
    jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"ask",permissionDecisionReason:"⚠️ git push requires user confirmation. Proceed?"}}'
    exit 0
  fi

  # Block git reset --hard (require confirmation)
  if echo "$CMD" | grep -qE 'git\s+reset\s+--hard'; then
    jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"ask",permissionDecisionReason:"⚠️ git reset --hard will discard all uncommitted changes. Confirm?"}}'
    exit 0
  fi

  # Block git push --force (require confirmation)
  if echo "$CMD" | grep -qE 'git\s+push.*--force|git\s+push.*-f'; then
    jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"ask",permissionDecisionReason:"🚨 git push --force can overwrite remote history. Confirm?"}}'
    exit 0
  fi

  # Block git amend on published branches (require confirmation)
  if echo "$CMD" | grep -qE 'git\s+commit\s+--amend'; then
    jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"ask",permissionDecisionReason:"⚠️ git commit --amend rewrites history. Confirm?"}}'
    exit 0
  fi
fi

# ── Write/Edit tool guards ──────────────────────────────────────────
if [ "$TOOL" = "Write" ] || [ "$TOOL" = "Edit" ]; then
  FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || echo "")
  BASENAME=$(basename "$FILE_PATH" 2>/dev/null || echo "")

  # Block .env files
  if echo "$BASENAME" | grep -qE '^\.env$|^\.env\.[^.]*$' && ! echo "$BASENAME" | grep -qE 'example|sample|template'; then
    jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:"Blocked: .env files are protected. Use .env.example."}}'
    exit 0
  fi

  # Block lockfiles
  if echo "$BASENAME" | grep -qE '^(package-lock|yarn|pnpm-lock)\.'; then
    jq -n '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:"Blocked: lockfiles must not be edited directly."}}'
    exit 0
  fi
fi

exit 0
