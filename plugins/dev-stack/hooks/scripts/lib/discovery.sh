#!/bin/bash
#
# Tool Discovery Service for Hybrid Auto-Orchestrator
# Discovers all available tools across MCP, Plugin, Skill, Built-in
# with priority order: MCP > Plugin > Skill > Built-in
#
# Version: 7.0.0
# Part of: dev-stack Hybrid Auto-Orchestrator (Layer 1)
#

set -euo pipefail

# Constants
VERSION="7.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_GLOBAL_CONFIG="$HOME/.claude.json"

# BUGFIX: Dynamic project root detection (don't rely on fixed depth)
# Try multiple strategies to find project root
# Priority: CLAUDE_PLUGIN_ROOT > .claude-plugin marker > .git > relative fallback
find_project_root() {
    local dir="$SCRIPT_DIR"

    # Strategy 1: Use CLAUDE_PLUGIN_ROOT env var if set (highest priority)
    if [[ -n "${CLAUDE_PLUGIN_ROOT:-}" ]]; then
        # CLAUDE_PLUGIN_ROOT points to .claude-plugin directory
        # Project root is 2 levels up from it
        local plugin_root
        plugin_root="$(dirname "$(dirname "$CLAUDE_PLUGIN_ROOT")")"
        if [[ -d "$plugin_root" ]]; then
            echo "$plugin_root"
            return 0
        fi
    fi

    # Strategy 2: Look for .claude-plugin marker directory (identifies plugin/marketplace root)
    # Supports both plugin.json and marketplace.json
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.claude-plugin" ]]; then
            # Verify it's a valid plugin/marketplace by checking for config file
            if [[ -f "$dir/.claude-plugin/plugin.json" || -f "$dir/.claude-plugin/marketplace.json" ]]; then
                echo "$dir"
                return 0
            fi
        fi
        dir="$(dirname "$dir")"
    done

    # Strategy 3: Walk up looking for .git directory (fallback)
    dir="$SCRIPT_DIR"
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.git" ]]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done

    # Strategy 4: Fallback to relative path (legacy behavior)
    cd "$SCRIPT_DIR/../../../../.." && pwd
}
PROJECT_ROOT="$(find_project_root)"

# Output mode
OUTPUT_MODE="${OUTPUT_MODE:-json}"

#######################################
# Discover MCP servers from configuration files
# Priority: project .mcp.json > global ~/.claude.json
# Returns: JSON array of MCP server configurations
#######################################
discover_mcp() {
    local mcp_servers="[]"

    # Check for project-level .mcp.json
    local project_mcp="$PROJECT_ROOT/.mcp.json"
    if [[ -f "$project_mcp" ]]; then
        local project_servers
        project_servers=$(cat "$project_mcp" 2>/dev/null | jq -r '.mcpServers // {} | to_entries | map({name: .key, command: .value.command, args: .value.args // [], enabled: .value.enabled // true, autoApprove: .value.autoApprove // []})' 2>/dev/null || echo "[]")
        if [[ -n "$project_servers" && "$project_servers" != "[]" && "$project_servers" != "null" ]]; then
            mcp_servers="$project_servers"
        fi
    fi

    # Merge with global ~/.claude.json MCP servers
    if [[ -f "$CLAUDE_GLOBAL_CONFIG" ]]; then
        local global_servers
        global_servers=$(cat "$CLAUDE_GLOBAL_CONFIG" 2>/dev/null | jq -r '.mcpServers // {} | to_entries | map({name: .key, command: .value.command, args: .value.args // [], enabled: .value.enabled // true, autoApprove: .value.autoApprove // []})' 2>/dev/null || echo "[]")

        if [[ -n "$global_servers" && "$global_servers" != "[]" && "$global_servers" != "null" ]]; then
            # Merge arrays, preferring project servers for duplicates
            mcp_servers=$(echo "$mcp_servers" "$global_servers" | jq -s 'add | unique_by(.name)' 2>/dev/null || echo "$mcp_servers")
        fi
    fi

    echo "$mcp_servers"
}

#######################################
# Discover plugin agents from agents/*.md
# Returns: JSON array of agent configurations
#######################################
discover_plugin_agents() {
    local agents="[]"
    # PROJECT_ROOT is the plugin root (where .claude-plugin lives)
    local agents_dir="$PROJECT_ROOT/agents"

    if [[ -d "$agents_dir" ]]; then
        local agent_files
        agent_files=$(find "$agents_dir" -maxdepth 1 -name "*.md" -type f 2>/dev/null | sort)

        while IFS= read -r agent_file; do
            if [[ -n "$agent_file" && -f "$agent_file" ]]; then
                local name=""
                local description=""

                # Extract frontmatter
                local frontmatter
                frontmatter=$(sed -n '/^---$/,/^---$/p' "$agent_file" 2>/dev/null | sed '1d;$d')

                if [[ -n "$frontmatter" ]]; then
                    name=$(echo "$frontmatter" | grep -E '^name:' | head -1 | sed 's/^name:[[:space:]]*//' | tr -d '"' | tr -d "'" 2>/dev/null || echo "")
                    description=$(echo "$frontmatter" | grep -E '^description:' | head -1 | sed 's/^description:[[:space:]]*//' | tr -d '"' | tr -d "'" 2>/dev/null || echo "")
                fi

                # Fallback to filename if no name in frontmatter
                if [[ -z "$name" ]]; then
                    name=$(basename "$agent_file" .md)
                fi

                # Create agent entry
                local agent_entry
                agent_entry=$(jq -n \
                    --arg name "$name" \
                    --arg description "$description" \
                    --arg file "$agent_file" \
                    '{name: $name, description: $description, type: "agent", file: $file}')

                agents=$(echo "$agents" | jq --argjson entry "$agent_entry" '. + [$entry]' 2>/dev/null || echo "$agents")
            fi
        done <<< "$agent_files"
    fi

    echo "$agents"
}

#######################################
# Discover plugin skills from skills/*/SKILL.md
# Returns: JSON array of skill configurations
#######################################
discover_plugin_skills() {
    local skills="[]"
    # PROJECT_ROOT is the plugin root (where .claude-plugin lives)
    local skills_dir="$PROJECT_ROOT/skills"

    if [[ -d "$skills_dir" ]]; then
        local skill_dirs
        skill_dirs=$(find "$skills_dir" -maxdepth 1 -type d ! -path "$skills_dir" 2>/dev/null | sort)

        while IFS= read -r skill_dir; do
            if [[ -n "$skill_dir" && -d "$skill_dir" ]]; then
                local skill_file="$skill_dir/SKILL.md"

                if [[ -f "$skill_file" ]]; then
                    local name=""
                    local description=""
                    local user_invocable="true"

                    # Extract frontmatter
                    local frontmatter
                    frontmatter=$(sed -n '/^---$/,/^---$/p' "$skill_file" 2>/dev/null | sed '1d;$d')

                    if [[ -n "$frontmatter" ]]; then
                        name=$(echo "$frontmatter" | grep -E '^name:' | head -1 | sed 's/^name:[[:space:]]*//' | tr -d '"' | tr -d "'" 2>/dev/null || echo "")
                        description=$(echo "$frontmatter" | grep -E '^description:' | head -1 | sed 's/^description:[[:space:]]*//' | tr -d '"' | tr -d "'" 2>/dev/null || echo "")
                        user_invocable=$(echo "$frontmatter" | grep -E '^user-invokable:' | head -1 | sed 's/^user-invokable:[[:space:]]*//' 2>/dev/null || echo "true")
                    fi

                    # Fallback to directory name if no name in frontmatter
                    if [[ -z "$name" ]]; then
                        name=$(basename "$skill_dir")
                    fi

                    # Create skill entry
                    local skill_entry
                    skill_entry=$(jq -n \
                        --arg name "$name" \
                        --arg description "$description" \
                        --arg user_invocable "$user_invocable" \
                        --arg file "$skill_file" \
                        --arg dir "$skill_dir" \
                        '{name: $name, description: $description, type: "skill", userInvocable: ($user_invocable == "true"), file: $file, directory: $dir}')

                    skills=$(echo "$skills" | jq --argjson entry "$skill_entry" '. + [$entry]' 2>/dev/null || echo "$skills")
                fi
            fi
        done <<< "$skill_dirs"
    fi

    echo "$skills"
}

#######################################
# Return static list of built-in tools
# These are Claude Code's native tools
# Returns: JSON array of built-in tool configurations
#######################################
discover_builtin() {
    jq -n '[
        {"name": "Bash", "description": "Execute bash commands", "category": "execution"},
        {"name": "Read", "description": "Read file contents", "category": "file"},
        {"name": "Write", "description": "Write file contents", "category": "file"},
        {"name": "Edit", "description": "Edit file contents with string replacement", "category": "file"},
        {"name": "Glob", "description": "Find files by pattern", "category": "search"},
        {"name": "Grep", "description": "Search file contents with regex", "category": "search"},
        {"name": "TaskCreate", "description": "Create a task for tracking", "category": "task"},
        {"name": "TaskUpdate", "description": "Update task status", "category": "task"},
        {"name": "TaskGet", "description": "Get task details", "category": "task"},
        {"name": "TaskList", "description": "List all tasks", "category": "task"},
        {"name": "Skill", "description": "Invoke a skill", "category": "skill"},
        {"name": "WebSearch", "description": "Search the web", "category": "search"},
        {"name": "NotebookEdit", "description": "Edit Jupyter notebook cells", "category": "notebook"},
        {"name": "EnterWorktree", "description": "Create and enter git worktree", "category": "git"},
        {"name": "ListMcpResourcesTool", "description": "List MCP resources", "category": "mcp"},
        {"name": "ReadMcpResourceTool", "description": "Read MCP resource", "category": "mcp"}
    ]'
}

#######################################
# Build complete tool catalog
# Combines all tool sources with priority ordering
# Returns: JSON catalog with version, timestamp, and all tools
#######################################
build_catalog() {
    local mcp_tools
    local agent_tools
    local skill_tools
    local builtin_tools

    mcp_tools=$(discover_mcp)
    agent_tools=$(discover_plugin_agents)
    skill_tools=$(discover_plugin_skills)
    builtin_tools=$(discover_builtin)

    # Count totals
    local mcp_count agent_count skill_count builtin_count total

    mcp_count=$(echo "$mcp_tools" | jq 'length' 2>/dev/null || echo "0")
    agent_count=$(echo "$agent_tools" | jq 'length' 2>/dev/null || echo "0")
    skill_count=$(echo "$skill_tools" | jq 'length' 2>/dev/null || echo "0")
    builtin_count=$(echo "$builtin_tools" | jq 'length' 2>/dev/null || echo "0")
    total=$((mcp_count + agent_count + skill_count + builtin_count))

    # Build final catalog (spec: version, generated_at, priority, tools, total only)
    jq -n \
        --arg version "$VERSION" \
        --arg generated_at "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
        --argjson mcp "$mcp_tools" \
        --argjson agents "$agent_tools" \
        --argjson skills "$skill_tools" \
        --argjson builtin "$builtin_tools" \
        --argjson total "$total" \
        '{
            version: $version,
            generated_at: $generated_at,
            priority: ["mcp", "plugin", "skill", "builtin"],
            tools: {
                mcp: $mcp,
                agents: $agents,
                skills: $skills,
                builtin: $builtin
            },
            total: $total
        }'
}

#######################################
# Print usage information
#######################################
usage() {
    cat << EOF
Tool Discovery Service v$VERSION

Usage: $(basename "$0") [OPTIONS]

Options:
    --catalog       Output full tool catalog as JSON
    --mcp           Output only MCP servers
    --agents        Output only plugin agents
    --skills        Output only plugin skills
    --builtin       Output only built-in tools
    --summary       Output summary counts
    --help          Show this help message

Examples:
    $(basename "$0") --catalog | jq '.total'
    $(basename "$0") --mcp | jq '.[].name'
    $(basename "$0") --summary

EOF
}

#######################################
# Main entry point
#######################################
main() {
    local action="${1:---catalog}"

    case "$action" in
        --catalog)
            build_catalog
            ;;
        --mcp)
            discover_mcp
            ;;
        --agents)
            discover_plugin_agents
            ;;
        --skills)
            discover_plugin_skills
            ;;
        --builtin)
            discover_builtin
            ;;
        --summary)
            local mcp_count agent_count skill_count builtin_count total
            mcp_count=$(discover_mcp | jq 'length' 2>/dev/null || echo "0")
            agent_count=$(discover_plugin_agents | jq 'length' 2>/dev/null || echo "0")
            skill_count=$(discover_plugin_skills | jq 'length' 2>/dev/null || echo "0")
            builtin_count=$(discover_builtin | jq 'length' 2>/dev/null || echo "0")
            total=$((mcp_count + agent_count + skill_count + builtin_count))

            echo "Tool Discovery Summary"
            echo "======================"
            echo "MCP Servers:  $mcp_count"
            echo "Agents:       $agent_count"
            echo "Skills:       $skill_count"
            echo "Built-in:     $builtin_count"
            echo "----------------------"
            echo "Total:        $total"
            ;;
        --help|-h)
            usage
            ;;
        *)
            echo "Unknown option: $action" >&2
            usage
            exit 1
            ;;
    esac
}

# Run main if executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
