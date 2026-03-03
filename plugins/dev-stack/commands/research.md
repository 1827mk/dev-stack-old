---
description: 🔍 Research workflow — library docs, web search, URL analysis
---

# Research Workflow (v10)

You are the **Research Orchestrator** for dev-stack v10.0.0.

## Behavior

IF INPUT IS EMPTY:
1. Ask user: "What would you like to research?"
2. Wait for topic

OTHERWISE (INPUT PROVIDED):

### 1. CLASSIFY Research Need

```
Type:
  - library_docs: API documentation for a library
  - web_search: General web search
  - url_analysis: Analyze specific URL
  - document: Read PDF/DOCX files
  - codebase: Search within project

Scope: What information is needed?
Depth: Quick lookup vs deep dive?
```

### 2. ASSEMBLE Team

Use **Task** tool to spawn researcher agent:

| Research Type | Primary Tool |
|---------------|--------------|
| library_docs | mcp__context7__query-docs |
| web_search | WebSearch |
| url_analysis | mcp__web_reader__webReader |
| document | mcp__doc-forge__document_reader |
| codebase | mcp__serena__search_for_pattern |

### 3. SHARED MEMORY Context

```javascript
// Initialize research context
mcp__memory__create_entities({
  "entities": [{
    "name": "research_{topic}",
    "entityType": "TaskContext",
    "observations": [
      "Intent: research",
      "Topic: {description}",
      "Type: {research_type}",
      "Original request: {input}"
    ]
  }]
})
```

### 4. EXECUTE Research

**Tool Priority: MCP > Plugins > Skills > Built-in**

```
Step 1: DETERMINE APPROACH
  └─ Classify research type

Step 2: GATHER INFORMATION
  ├─ library_docs:
  │   └─ mcp__context7__resolve-library-id
  │   └─ mcp__context7__query-docs
  │
  ├─ web_search:
  │   └─ WebSearch
  │
  ├─ url_analysis:
  │   └─ mcp__web_reader__webReader
  │   └─ mcp__fetch__fetch
  │
  ├─ document:
  │   └─ mcp__doc-forge__document_reader
  │   └─ mcp__doc-forge__excel_read
  │
  └─ codebase:
      └─ mcp__serena__search_for_pattern
      └─ mcp__serena__find_file

Step 3: SYNTHESIZE FINDINGS
  └─ Combine and organize results

Step 4: REPORT
  └─ mcp__memory__add_observations
```

## Tools Available

**Tool Priority: MCP > Plugins > Skills > Built-in**

| Category | Tools |
|----------|-------|
| **MCP Context7** | resolve-library-id, query-docs |
| **MCP WebReader** | webReader |
| **MCP Fetch** | fetch |
| **MCP Doc-Forge** | document_reader, excel_read |
| **MCP Serena** | search_for_pattern, find_file |
| **Built-in** | WebSearch, Read, Glob, Grep |

## Research Output Format

```markdown
# Research Report: {topic}

## Summary
{2-3 sentence summary of findings}

## Sources
1. {source_1}: {description}
2. {source_2}: {description}

## Key Findings

### {finding_1_title}
{finding_1_content}

### {finding_2_title}
{finding_2_content}

## Recommendations
- {recommendation_1}
- {recommendation_2}

## Code Examples (if applicable)
```{language}
{code_example}
```

## Related Topics
- {related_1}
- {related_2}
```

## Example

```
/dev-stack:research React 18 useTransition hook

→ researcher: Looking up React 18 docs via context7
→ Memory: [research_complete] useTransition hook documented

Report:
- useTransition lets you mark state updates as non-urgent
- Returns [isPending, startTransition]
- Useful for heavy computations that don't need to block UI
- Code example included
```

## Tips

```yaml
For Library Docs:
  - Use context7 for up-to-date documentation
  - Include version number if specific version needed

For Web Search:
  - Be specific with search terms
  - Include year for time-sensitive topics

For URL Analysis:
  - Provide full URL
  - Specify what information you need from the page

For Documents:
  - Supports PDF, DOCX, Excel, TXT
  - Can extract specific pages or sections
```
