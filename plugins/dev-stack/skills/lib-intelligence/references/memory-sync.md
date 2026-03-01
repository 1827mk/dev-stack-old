# Auto Memory Sync

Automatically store patterns, insights, and lessons learned in native memory.

## Overview

After each phase completion, dev-stack extracts patterns and insights from the work performed and stores them in `mcp__memory` for future reference and cross-project learning.

## Entity Types

### Pattern
Reusable code patterns discovered during implementation.

```
mcp__memory__create_entities:
  - name: {pattern_name}
    entityType: Pattern
    observations:
      - "Description: {what_it_does}"
      - "Context: {when_to_use}"
      - "Example: {code_snippet}"
      - "Spec: {spec_id}"
```

### Insight
Key learnings or realizations during development.

```
mcp__memory__create_entities:
  - name: {insight_title}
    entityType: Insight
    observations:
      - "Learning: {what_was_learned}"
      - "Impact: {how_it_helps}"
      - "Spec: {spec_id}"
      - "Date: {timestamp}"
```

### LessonLearned
Post-retro insights about process improvements.

```
mcp__memory__create_entities:
  - name: {lesson_title}
    entityType: LessonLearned
    observations:
      - "What worked: {successes}"
      - "What failed: {failures}"
      - "Recommendation: {improvement}"
      - "Workflow: {workflow_type}"
```

## Sync Triggers

### After Phase Completion

| Phase | What to Extract |
|-------|-----------------|
| after_spec | Domain insights, BDD scenarios |
| after_plan | Architecture decisions, ADRs |
| after_tasks | Code patterns, test strategies |
| after_review | Quality findings, refactoring opportunities |

### After Retro

Extract lessons learned and link to workflow type.

## Implementation

In orchestrator, after each GATE pass:

```
SYNC_MEMORY(phase, spec_id):
  patterns ← analyze_code_for_patterns()
  insights ← extract_insights_from_work()

  FOR each pattern in patterns:
    mcp__memory__create_entities: Pattern {...}
    mcp__memory__create_relations: Pattern → used_in → Spec

  FOR each insight in insights:
    mcp__memory__create_entities: Insight {...}
    mcp__memory__create_relations: Insight → from → Spec
```

## Querying Memory

### Find patterns for domain

```
mcp__memory__search_nodes:
  query: "Pattern {domain_keyword}"
```

### Find lessons for workflow type

```
mcp__memory__search_nodes:
  query: "LessonLearned {workflow_type}"
```

### Find related specs

```
mcp__memory__open_nodes: ["{spec_id}"]
# Follows relations to find connected patterns and insights
```

## Configuration

In `.specify/memory/constitution.md`:

```yaml
memory_sync:
  enabled: true
  sync_patterns: true
  sync_insights: true
  sync_lessons: true
  exclude_patterns:
    - "boilerplate"
    - "generated"
```
