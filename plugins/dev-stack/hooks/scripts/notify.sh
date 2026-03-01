#!/bin/bash
# dev-stack Desktop Notification Hook
# Sends desktop notifications for gate pass/fail and workflow events

STATE_FILE="$HOME/.claude/dev-stack-state.json"

# Read from state file if args not provided
if [[ -z "$1" ]]; then
  EVENT_TYPE=$(jq -r '.last_event // "unknown"' "$STATE_FILE" 2>/dev/null || echo "unknown")
  SPEC_ID=$(jq -r '.last_spec // ""' "$STATE_FILE" 2>/dev/null || echo "")
  DETAILS=$(jq -r '.last_details // ""' "$STATE_FILE" 2>/dev/null || echo "")
else
  EVENT_TYPE="${1:-unknown}"
  SPEC_ID="${2:-}"
  DETAILS="${3:-}"
fi

# Detect platform
detect_platform() {
    case "$(uname -s)" in
        Darwin*) echo "macos" ;;
        Linux*)  echo "linux" ;;
        *)       echo "unknown" ;;
    esac
}

# Send notification (macOS)
notify_macos() {
    local title="$1"
    local message="$2"
    local sound="${3:-default}"

    osascript -e "display notification \"$message\" with title \"$title\" sound name \"$sound\"" 2>/dev/null
}

# Send notification (Linux)
notify_linux() {
    local title="$1"
    local message="$2"

    if command -v notify-send &> /dev/null; then
        notify-send "$title" "$message" 2>/dev/null
    fi
}

# Main notification function
send_notification() {
    local event_type="$1"
    local spec_id="$2"
    local details="$3"

    local title=""
    local message=""

    case "$event_type" in
        "gate_pass")
            title="dev-stack Gate Passed"
            message="Gate passed for ${spec_id}: ${details}"
            ;;
        "gate_fail")
            title="dev-stack Gate Failed"
            message="Gate failed for ${spec_id}: ${details}"
            ;;
        "workflow_complete")
            title="dev-stack Complete"
            message="${spec_id}: ${details}"
            ;;
        "escalation")
            title="dev-stack Escalation"
            message="Attention needed: ${spec_id} - ${details}"
            ;;
        "phase_complete")
            title="dev-stack Phase Complete"
            message="${spec_id}: ${details} phase done"
            ;;
        *)
            title="dev-stack"
            message="${spec_id}: ${details}"
            ;;
    esac

    case "$(detect_platform)" in
        macos) notify_macos "$title" "$message" ;;
        linux) notify_linux "$title" "$message" ;;
    esac
}

# Only notify if event type is provided
if [[ -n "$EVENT_TYPE" && "$EVENT_TYPE" != "unknown" ]]; then
    send_notification "$EVENT_TYPE" "$SPEC_ID" "$DETAILS"
fi

exit 0
