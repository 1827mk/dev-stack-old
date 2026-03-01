#!/bin/bash
# dev-stack Status Line Hook
# Updates status line with current workflow progress

SPEC_DIR="${CLAUDE_PROJECT_ROOT:-.}/.specify/specs"
STATUS_FILE="/tmp/dev-stack-status"

# Find active spec
find_active_spec() {
    if [[ -d "$SPEC_DIR" ]]; then
        for spec in "$SPEC_DIR"/*/; do
            if [[ -f "$spec/tasks.md" ]]; then
                # Check if spec is active (not complete)
                if ! grep -q "COMPLETE" "$spec/spec.md" 2>/dev/null; then
                    echo "$spec"
                    return
                fi
            fi
        done
    fi
}

# Parse task progress
get_progress() {
    local tasks_file="$1/tasks.md"
    if [[ -f "$tasks_file" ]]; then
        local total=$(grep -c "^\- \[" "$tasks_file" 2>/dev/null || echo "0")
        local done=$(grep -c "^\- \[x\]" "$tasks_file" 2>/dev/null || echo "0")
        echo "${done}/${total}"
    else
        echo "0/0"
    fi
}

# Get workflow type
get_workflow() {
    local spec_file="$1/spec.md"
    if [[ -f "$spec_file" ]]; then
        grep "Workflow:" "$spec_file" 2>/dev/null | head -1 | sed 's/.*Workflow: //' || echo "unknown"
    else
        echo "unknown"
    fi
}

# Main
ACTIVE_SPEC=$(find_active_spec)

if [[ -n "$ACTIVE_SPEC" ]]; then
    PROGRESS=$(get_progress "$ACTIVE_SPEC")
    WORKFLOW=$(get_workflow "$ACTIVE_SPEC")
    SPEC_ID=$(basename "$ACTIVE_SPEC")

    # Write status for consumption by other tools
    echo "dev-stack: ${WORKFLOW} | ${SPEC_ID} | Tasks: ${PROGRESS}" > "$STATUS_FILE"

    # Output as JSON for hook system
    cat <<EOF
{"status": "dev-stack: ${WORKFLOW}", "spec": "${SPEC_ID}", "progress": "${PROGRESS}"}
EOF
fi
