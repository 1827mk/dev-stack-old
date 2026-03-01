---
disable-model-invocation: false
user-invokable: false
name: lib-router
description: AI-optimized tool router with fallback chains. Call skill:lib-router(intent) to get tool chain.
---

# TOOL MAP (v9.0 - 12 Intents)

## Code Operations (Module: CODE)

```yaml
code_read:
  description: Read and understand code symbols
  primary: mcp__serena__find_symbol
  fallbacks: [mcp__serena__get_symbols_overview, Read]
  use_when: Need to understand a specific symbol

code_edit:
  description: Modify code with symbol awareness
  primary: mcp__serena__replace_symbol_body
  fallbacks: [mcp__serena__insert_after_symbol, mcp__serena__insert_before_symbol, Edit]
  use_when: Need to modify a function or class

code_refs:
  description: Find all references to a symbol
  primary: mcp__serena__find_referencing_symbols
  fallbacks: [Grep]
  use_when: Need to understand change impact

code_overview:
  description: Get file structure overview
  primary: mcp__serena__get_symbols_overview
  fallbacks: [Read]
  use_when: Need to understand file quickly
```

## File Operations (Module: DOCS)

```yaml
file_find:
  description: Find files by pattern
  primary: mcp__serena__find_file
  fallbacks: [mcp__filesystem__search_files, Glob]
  use_when: Looking for specific files

dir_list:
  description: List directory contents
  primary: mcp__serena__list_dir
  fallbacks: [mcp__filesystem__list_directory, Bash]
  use_when: Exploring project structure

dir_tree:
  description: Get full directory tree
  primary: mcp__filesystem__directory_tree
  fallbacks: [Bash:find . -type f]
  use_when: Need complete project structure
```

## Documentation Operations (Module: DOCS)

```yaml
doc_fetch:
  description: Fetch library documentation
  primary: mcp__context7__query-docs
  requires: mcp__context7__resolve-library-id first
  fallbacks: [mcp__web_reader__webReader, mcp__fetch__fetch, WebSearch]
  use_when: Need up-to-date library docs

doc_read:
  description: Read document files
  primary: mcp__doc-forge__document_reader
  fallbacks: [Read]
  use_when: Processing PDF, DOCX, HTML files
```

## Memory Operations (Module: KNOWLEDGE)

```yaml
memory_write:
  description: Store knowledge entities
  primary: mcp__memory__create_entities
  fallbacks: [mcp__serena__write_memory]
  use_when: Storing patterns, decisions, learnings

memory_read:
  description: Query knowledge graph
  primary: mcp__memory__search_nodes
  fallbacks: [mcp__memory__read_graph, mcp__serena__read_memory]
  use_when: Finding similar patterns or decisions

memory_link:
  description: Create relations between entities
  primary: mcp__memory__create_relations
  use_when: Linking related concepts
```

## Thinking Operations (Module: KNOWLEDGE)

```yaml
think_sequential:
  description: Step-by-step reasoning
  primary: mcp__sequentialthinking__sequentialthinking
  fallbacks: [mcp__serena__think_about_collected_information]
  use_when: Complex analysis or classification

think_complete:
  description: Check information sufficiency
  primary: mcp__serena__think_about_collected_information
  use_when: Before making decisions

think_adherence:
  description: Check task adherence
  primary: mcp__serena__think_about_task_adherence
  use_when: Quality gates

think_done:
  description: Check task completion
  primary: mcp__serena__think_about_whether_you_are_done
  use_when: Before delivery
```

## Pattern Operations (Module: CODE)

```yaml
pattern_search:
  description: Search code patterns
  primary: mcp__serena__search_for_pattern
  fallbacks: [Grep]
  use_when: Finding similar code patterns

symbol_find:
  description: Find symbols by name
  primary: mcp__serena__find_symbol
  fallbacks: [Grep]
  use_when: Looking for classes, functions
```

---

# INTENT → WORKFLOW MAPPING

```yaml
bug_fix:
  explore: [code_read, code_overview]
  find: [pattern_search, symbol_find]
  fix: [code_edit]
  verify: [code_refs, think_done]

new_feature:
  explore: [code_read, dir_tree]
  design: [think_sequential, memory_read]
  implement: [code_edit]
  test: [Bash]
  document: [doc_fetch, memory_write]

refactor:
  analyze: [code_refs, code_overview]
  transform: [code_edit]
  verify: [code_refs, think_adherence]

review:
  scan: [code_read, pattern_search]
  check: [think_complete, think_adherence]
  report: [Write]

security:
  audit: [pattern_search, code_read]
  report: [Write]
  verify: [think_done]
```

---

# EXECUTION PATTERN

```
1. GET intent from orchestrator
2. LOOKUP tool chain for intent
3. TRY primary tool
4. IF fail -> TRY fallbacks in order
5. RETURN result
6. IF all fail -> report tool unavailable
```

---

# SUB-SYSTEM ROUTING

```yaml
greenfield: speckit
legacy_bug: superpowers
hotfix: direct
security: superpowers+direct
```
