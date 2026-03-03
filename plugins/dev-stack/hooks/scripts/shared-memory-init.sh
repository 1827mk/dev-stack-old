#!/bin/bash

# shared-memory-init.sh
# Initializes shared memory for dev-stack v10.0.0 task coordination
# Called at session start to create TaskContext if needed

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
MEMORY_DIR=".specify/memory"
TASK_ID="${1:-task_$(date +%Y%m%d%H%M%S)}"
TASK_REQUEST="${2:-Session initialized}"

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if MCP memory is available
check_mcp_memory() {
    log_info "Checking MCP memory availability..."

    # MCP memory is checked by attempting to use it
    # If this script is called, we assume MCP tools will be used via Claude
    # This script primarily handles file-based fallback

    if command -v jq &> /dev/null; then
        log_success "jq available for JSON processing"
        return 0
    else
        log_warning "jq not found, using basic JSON handling"
        return 1
    fi
}

# Create memory directory structure
create_memory_structure() {
    log_info "Creating memory directory structure..."

    mkdir -p "$MEMORY_DIR"
    mkdir -p "$MEMORY_DIR/archive"
    mkdir -p ".specify/adr"

    log_success "Memory structure created at $MEMORY_DIR"
}

# Initialize TaskContext entity
init_task_context() {
    local task_id="$1"
    local request="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    log_info "Initializing TaskContext: $task_id"

    local memory_file="$MEMORY_DIR/${task_id}.json"

    # Check if task already exists
    if [ -f "$memory_file" ]; then
        log_warning "TaskContext $task_id already exists, updating..."
        update_task_status "$task_id" "resumed"
        return 0
    fi

    # Create new TaskContext
    cat > "$memory_file" << EOF
{
  "name": "$task_id",
  "entityType": "TaskContext",
  "observations": [
    {
      "content": "Original request: $request",
      "timestamp": "$timestamp",
      "agent": "session-init",
      "type": "task_request"
    },
    {
      "content": "Status: initialized",
      "timestamp": "$timestamp",
      "agent": "session-init",
      "type": "status_update"
    },
    {
      "content": "Memory initialized via file fallback",
      "timestamp": "$timestamp",
      "agent": "session-init",
      "type": "system"
    }
  ],
  "relations": [],
  "metadata": {
    "created": "$timestamp",
    "lastUpdated": "$timestamp",
    "fallback": true,
    "mcp_memory_available": false
  }
}
EOF

    log_success "TaskContext created: $memory_file"
}

# Update task status
update_task_status() {
    local task_id="$1"
    local status="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local memory_file="$MEMORY_DIR/${task_id}.json"

    if [ ! -f "$memory_file" ]; then
        log_error "TaskContext not found: $task_id"
        return 1
    fi

    # Add status observation
    if command -v jq &> /dev/null; then
        local new_observation=$(cat << EOF
{
  "content": "Status: $status",
  "timestamp": "$timestamp",
  "agent": "session-init",
  "type": "status_update"
}
EOF
)
        jq ".observations += [$new_observation] | .metadata.lastUpdated = \"$timestamp\"" \
            "$memory_file" > "${memory_file}.tmp" && \
            mv "${memory_file}.tmp" "$memory_file"
    else
        # Fallback without jq
        echo ",{\"content\": \"Status: $status\", \"timestamp\": \"$timestamp\", \"agent\": \"session-init\", \"type\": \"status_update\"}" >> "$memory_file"
    fi

    log_success "Task status updated: $status"
}

# Create memory index
create_memory_index() {
    local index_file="$MEMORY_DIR/index.json"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    log_info "Creating memory index..."

    cat > "$index_file" << EOF
{
  "version": "10.0.0",
  "created": "$timestamp",
  "tasks": [],
  "archive": []
}
EOF

    log_success "Memory index created"
}

# List available tasks
list_tasks() {
    log_info "Available tasks:"

    if [ -d "$MEMORY_DIR" ]; then
        for file in "$MEMORY_DIR"/task_*.json; do
            if [ -f "$file" ]; then
                local task_name=$(basename "$file" .json)
                echo "  • $task_name"
            fi
        done
    else
        log_warning "No tasks found"
    fi
}

# Main initialization
main() {
    echo "═══════════════════════════════════════════════════════════════"
    echo "        dev-stack v10.0.0 - Shared Memory Initialization"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""

    # Check prerequisites
    check_mcp_memory

    # Create structure
    create_memory_structure

    # Initialize task context
    init_task_context "$TASK_ID" "$TASK_REQUEST"

    # Create index if needed
    if [ ! -f "$MEMORY_DIR/index.json" ]; then
        create_memory_index
    fi

    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    log_success "Memory initialization complete!"
    echo ""
    echo "  Task ID: $TASK_ID"
    echo "  Memory:  $MEMORY_DIR/${TASK_ID}.json"
    echo ""
    echo "  Usage:"
    echo "    • Write findings: Use mcp__memory__add_observations"
    echo "    • Read context:   Use mcp__memory__open_nodes"
    echo "    • File fallback:  $MEMORY_DIR/${TASK_ID}.json"
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
}

# Handle command line arguments
case "${1:-}" in
    --list|-l)
        list_tasks
        ;;
    --status|-s)
        update_task_status "$2" "status_check"
        ;;
    --help|-h)
        echo "Usage: $0 [task_id] [request]"
        echo ""
        echo "Options:"
        echo "  --list, -l    List available tasks"
        echo "  --status, -s  Update task status"
        echo "  --help, -h    Show this help"
        echo ""
        echo "Examples:"
        echo "  $0 task_20260301 'Fix login bug'"
        echo "  $0 --list"
        ;;
    *)
        main
        ;;
esac
