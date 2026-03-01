---
disable-model-invocation: false
user-invokable: false
name: lib-router
description: Tool router. Call skill:lib-router(intent) to get tool chain.
---

# TOOL MAP

code_read: [mcp__serena__find_symbol, mcp__serena__get_symbols_overview, Read]
code_edit: [mcp__serena__replace_symbol_body, mcp__serena__insert_after_symbol, Edit]
code_refs: [mcp__serena__find_referencing_symbols, Grep]
file_find: [mcp__serena__find_file, Glob]
dir_list: [mcp__serena__list_dir, Bash:ls]
web_fetch: [mcp__web_reader__webReader, mcp__fetch__fetch, WebSearch]
doc_read: [mcp__doc-forge__document_reader, Read]
memory: [mcp__memory__create_entities, mcp__memory__search_nodes, mcp__memory__read_graph]
think: [mcp__sequentialthinking__sequentialthinking]

# INTENT → TOOLS

bug_fix: {find: code_read, fix: code_edit, verify: code_refs}
new_feature: {explore: code_read, design: code_edit, test: Bash}
refactor: {analyze: code_refs, transform: code_edit}
review: {scan: code_read, check: Grep}
security: {audit: code_read, report: Write}

# SUB-SYSTEM ROUTING

greenfield: speckit
legacy_bug: superpowers
hotfix: direct
security: superpowers+direct

# EXECUTION

1. GET intent from orchestrator
2. LOOKUP tool chain
3. TRY tools in order until success
4. RETURN result
