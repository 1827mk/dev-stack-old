# Capability Mapping Reference

> Part of lib-orchestration skill for dev-stack v10.0.0

---

## Overview

Capability mapping translates classified intent into required capabilities. This determines what skills/tools are needed for the task.

## Capabilities Definition

### Core Capabilities

| Capability | Description | Required For |
|------------|-------------|--------------|
| `code_analysis` | Analyze existing code | bug_fix, refactor, security |
| `code_writing` | Write/modify code | bug_fix, new_feature, refactor, security |
| `testing` | Write/run tests | All code changes |
| `research` | Gather information | new_feature, research |
| `planning` | Decompose tasks | new_feature, complex refactor |
| `documentation` | Write docs | documentation, new_feature |
| `security_scan` | Security analysis | security, sensitive features |
| `git_ops` | Version control | All code changes |
| `file_ops` | File management | All tasks |
| `memory_coordination` | Shared memory | All multi-agent tasks |

### Extended Capabilities

| Capability | Description | Required For |
|------------|-------------|--------------|
| `api_research` | API documentation lookup | new_feature with external libs |
| `database_ops` | Database operations | data, migration |
| `performance_analysis` | Performance profiling | optimization tasks |
| `deployment` | Deploy/release | deploy |

---

## Intent to Capabilities Mapping

### INTENT_TO_CAPABILITIES

```python
INTENT_TO_CAPABILITIES = {
    "bug_fix": {
        "required": ["code_analysis", "code_writing", "testing"],
        "optional": ["git_ops", "documentation", "research"],
        "priority": "high"
    },
    "new_feature": {
        "required": ["research", "planning", "code_analysis", "code_writing", "testing"],
        "optional": ["documentation", "git_ops", "security_scan", "api_research"],
        "priority": "medium"
    },
    "refactor": {
        "required": ["code_analysis", "code_writing", "testing"],
        "optional": ["documentation", "git_ops"],
        "priority": "medium"
    },
    "security": {
        "required": ["security_scan", "code_analysis", "code_writing", "testing"],
        "optional": ["documentation", "git_ops"],
        "priority": "critical"
    },
    "research": {
        "required": ["research"],
        "optional": ["documentation", "code_analysis"],
        "priority": "low"
    },
    "documentation": {
        "required": ["documentation"],
        "optional": ["code_analysis", "research"],
        "priority": "low"
    },
    "hotfix": {
        "required": ["code_analysis", "code_writing", "testing", "git_ops"],
        "optional": [],
        "priority": "critical"
    },
    "git_ops": {
        "required": ["git_ops"],
        "optional": ["code_analysis"],
        "priority": "medium"
    },
    "quality": {
        "required": ["testing", "code_analysis"],
        "optional": ["security_scan"],
        "priority": "medium"
    },
    "data": {
        "required": ["database_ops", "code_writing"],
        "optional": ["testing", "documentation"],
        "priority": "medium"
    }
}
```

---

## Contextual Capability Enhancement

### Security-Sensitive Keywords

```python
SECURITY_KEYWORDS = [
    "password", "auth", "token", "secret", "key", "credential",
    "payment", "credit card", "PII", "personal data", "encrypt",
    "decrypt", "session", "cookie", "JWT", "OAuth", "API key"
]

def enhance_for_security(request, capabilities):
    """Add security_scan if security-sensitive keywords found"""
    request_lower = request.lower()
    if any(kw in request_lower for kw in SECURITY_KEYWORDS):
        if "security_scan" not in capabilities["required"]:
            capabilities["required"].append("security_scan")
    return capabilities
```

### Complexity Assessment

```python
def assess_complexity(request, context=None):
    """Assess task complexity to add planning capability"""

    complexity_signals = {
        "high": [
            "system", "architecture", "redesign", "multiple", "several",
            "integrate", "migrate", "refactor entire", "from scratch"
        ],
        "medium": [
            "module", "component", "service", "endpoint", "feature"
        ]
    }

    request_lower = request.lower()

    for signal in complexity_signals["high"]:
        if signal in request_lower:
            return "high"

    for signal in complexity_signals["medium"]:
        if signal in request_lower:
            return "medium"

    return "low"

def enhance_for_complexity(capabilities, complexity):
    """Add planning capability for complex tasks"""
    if complexity in ["high", "medium"]:
        if "planning" not in capabilities["required"]:
            capabilities["required"].append("planning")
    return capabilities
```

---

## Mapping Function

```
FUNCTION #map_capabilities(intent, request, context={})

INPUT:
  - intent: string (from classify_intent)
  - request: string (original user request)
  - context: object (optional additional context)

OUTPUT:
  {
    "required": ["code_analysis", "code_writing", ...],
    "optional": ["documentation", ...],
    "priority": "critical" | "high" | "medium" | "low",
    "complexity": "high" | "medium" | "low",
    "security_sensitive": true | false
  }

ALGORITHM:
  1. Get base capabilities for intent
  2. Assess complexity
  3. Check for security-sensitive keywords
  4. Enhance capabilities based on context
  5. RETURN enhanced capabilities
```

---

## Capability to Tool Mapping

### code_analysis

```python
CODE_ANALYSIS_TOOLS = {
    "primary": [
        "mcp__serena__find_symbol",
        "mcp__serena__find_referencing_symbols",
        "mcp__serena__get_symbols_overview",
        "mcp__serena__search_for_pattern"
    ],
    "fallback": [
        "Grep",
        "Read",
        "Glob"
    ]
}
```

### code_writing

```python
CODE_WRITING_TOOLS = {
    "primary": [
        "mcp__serena__replace_symbol_body",
        "mcp__serena__insert_after_symbol",
        "mcp__serena__insert_before_symbol",
        "mcp__serena__rename_symbol"
    ],
    "fallback": [
        "Edit",
        "Write"
    ]
}
```

### testing

```python
TESTING_TOOLS = {
    "primary": [
        "Bash (test commands)",
        "mcp__serena__search_for_pattern (test file analysis)"
    ],
    "fallback": [
        "Read",
        "Grep"
    ]
}
```

### research

```python
RESEARCH_TOOLS = {
    "primary": [
        "mcp__context7__resolve-library-id",
        "mcp__context7__query-docs",
        "mcp__web_reader__webReader",
        "mcp__fetch__fetch"
    ],
    "fallback": [
        "WebSearch",
        "Read"
    ]
}
```

### documentation

```python
DOCUMENTATION_TOOLS = {
    "primary": [
        "mcp__doc-forge__document_reader",
        "mcp__doc-forge__docx_to_pdf",
        "mcp__doc-forge__format_convert",
        "mcp__filesystem__write_file"
    ],
    "fallback": [
        "Write",
        "Edit"
    ]
}
```

### security_scan

```python
SECURITY_SCAN_TOOLS = {
    "primary": [
        "mcp__serena__search_for_pattern (OWASP patterns)"
    ],
    "fallback": [
        "Grep",
        "Read"
    ]
}
```

### planning

```python
PLANNING_TOOLS = {
    "primary": [
        "mcp__sequentialthinking__sequentialthinking",
        "TaskCreate",
        "TaskUpdate",
        "TaskList"
    ],
    "fallback": [
        "Write",
        "Read"
    ]
}
```

### git_ops

```python
GIT_OPS_TOOLS = {
    "primary": [
        "Bash (git commands)"
    ],
    "safety_check": "PreToolUse hook for commit/push confirmation"
}
```

### memory_coordination

```python
MEMORY_COORDINATION_TOOLS = {
    "primary": [
        "mcp__memory__create_entities",
        "mcp__memory__create_relations",
        "mcp__memory__add_observations",
        "mcp__memory__search_nodes",
        "mcp__memory__read_graph"
    ],
    "fallback": [
        "Write (to .specify/memory/*.json)",
        "Read"
    ]
}
```

---

## Examples

### Example 1: Bug Fix

```
Intent: bug_fix
Request: "fix login bug in auth.ts"

Capabilities:
{
  "required": ["code_analysis", "code_writing", "testing"],
  "optional": ["git_ops", "documentation"],
  "priority": "high",
  "complexity": "low",
  "security_sensitive": false
}
```

### Example 2: New Feature with Security

```
Intent: new_feature
Request: "add OAuth2 login with credit card payment"

Capabilities:
{
  "required": ["research", "planning", "code_analysis", "code_writing", "testing", "security_scan"],
  "optional": ["documentation", "git_ops", "api_research"],
  "priority": "medium",
  "complexity": "high",
  "security_sensitive": true
}
```

### Example 3: Simple Research

```
Intent: research
Request: "explain how caching works"

Capabilities:
{
  "required": ["research"],
  "optional": ["documentation", "code_analysis"],
  "priority": "low",
  "complexity": "low",
  "security_sensitive": false
}
```

---

## Integration with Team Assembly

After capability mapping, proceed to team assembly:

```
capabilities = map_capabilities(intent, request)
team = assemble_team(capabilities)
```

Each capability maps to one or more agents (see team-assembly.md).

---

## Testing

```gherkin
Scenario: Map bug fix capabilities
  Given intent "bug_fix"
  When map_capabilities is called
  Then required should include "code_analysis"
  And required should include "code_writing"
  And required should include "testing"

Scenario: Detect security-sensitive feature
  Given intent "new_feature"
  And request contains "credit card"
  When map_capabilities is called
  Then required should include "security_scan"

Scenario: Add planning for complex task
  Given request contains "redesign entire system"
  When map_capabilities is called
  Then required should include "planning"
```
