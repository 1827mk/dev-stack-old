#!/usr/bin/env bash
# router-core.sh — Combined classifier + selector (single pass)
# Input: JSON with .prompt field
# Output: JSON with intent, domain, tools, quality_gates

set -euo pipefail

classify_and_select() {
  local prompt="$1"

  # Default values
  local intent="unknown" domain="general" urgency="normal"
  local primary_mcp="" secondary_agent="" fallback_builtin="Read,Grep,Glob"
  local tdd="false" bdd="false" security="false"

  # ── Intent Classification ────────────────────────────────────────
  if echo "$prompt" | grep -qiE 'fix|bug|error|broken|exception|crash|fail'; then
    intent="bug_fix"
    primary_mcp="serena:find,serena:search"
    secondary_agent="senior-developer"
    tdd="true"
  elif echo "$prompt" | grep -qiE 'add|create|build|implement|new feature|develop'; then
    intent="new_feature"
    primary_mcp="serena:overview"
    secondary_agent="domain-analyst,senior-developer"
    tdd="true"; bdd="true"
  elif echo "$prompt" | grep -qiE 'refactor|clean|restructure|optimize'; then
    intent="refactor"
    primary_mcp="serena:references"
    secondary_agent="solution-architect"
  elif echo "$prompt" | grep -qiE 'security|vulnerability|cve|owasp|exploit|xss|injection'; then
    intent="security_patch"
    primary_mcp="serena:search"
    secondary_agent="quality-gatekeeper"
    security="true"
  elif echo "$prompt" | grep -qiE 'spike|research|poc|proof of concept|investigate|explore'; then
    intent="spike"
    secondary_agent="domain-analyst"
  elif echo "$prompt" | grep -qiE 'review|check|audit|analyze'; then
    intent="review"
    secondary_agent="quality-gatekeeper"
  elif echo "$prompt" | grep -qiE 'test|spec|coverage'; then
    intent="testing"
    secondary_agent="qa-engineer"
  elif echo "$prompt" | grep -qiE 'status|progress|show|list'; then
    intent="query"
    fallback_builtin="Glob,Grep,Read"
  fi

  # ── Domain Detection ─────────────────────────────────────────────
  if echo "$prompt" | grep -qiE 'auth|login|password|token|session'; then
    domain="auth"; security="true"
  elif echo "$prompt" | grep -qiE 'api|endpoint|route|controller'; then
    domain="api"; security="true"
  elif echo "$prompt" | grep -qiE 'ui|component|page|frontend|react'; then
    domain="ui"
  elif echo "$prompt" | grep -qiE 'database|db|sql|query|migration'; then
    domain="database"
  elif echo "$prompt" | grep -qiE 'security|vulnerability|xss|injection'; then
    domain="security"; security="true"
  fi

  # ── Urgency ──────────────────────────────────────────────────────
  if echo "$prompt" | grep -qiE 'urgent|asap|critical|hotfix|emergency'; then
    urgency="critical"
  elif echo "$prompt" | grep -qiE 'important|priority|soon'; then
    urgency="high"
  fi

  # ── Output (simple JSON without complex jq) ───────────────────────
  # BUGFIX: Handle empty strings properly to avoid [""] instead of []
  json_array() {
    local input="$1"
    if [[ -z "$input" ]]; then
      echo "[]"
    else
      echo "$input" | tr ',' '\n' | sed '/^$/d' | jq -R . | jq -s .
    fi
  }

  cat <<EOF
{
  "intent": "$intent",
  "domain": "$domain",
  "urgency": "$urgency",
  "tools": {
    "primary_mcp": $(json_array "$primary_mcp"),
    "secondary_agent": $(json_array "$secondary_agent"),
    "fallback_builtin": $(json_array "$fallback_builtin")
  },
  "quality_gates": {
    "tdd": $tdd,
    "bdd": $bdd,
    "security": $security
  }
}
EOF
}

# Entry point
INPUT="${1:-}"
[ -z "$INPUT" ] && INPUT=$(cat)

PROMPT=$(echo "$INPUT" | jq -r '.prompt // . // empty' 2>/dev/null || echo "")
[ -z "$PROMPT" ] && echo '{"intent":"unknown"}' && exit 0

classify_and_select "$PROMPT"
