# BDD Authoring Reference

## Scenario Structure

3 scenarios per story: happy path + edge case + error case

**Given** — domain precondition, no implementation detail
```
✓ "Given a Customer with an active Subscription"
✗ "Given the database has a user record with status=active"
```

**When** — single action, one verb only
```
✓ "When the Customer cancels the Subscription"
✗ "When the customer clicks cancel and then confirms the dialog"
```

**Then** — observable outcome, no implementation detail
```
✓ "Then the Subscription status is Cancelled"
✗ "Then the cancelled_at column is updated in the database"
```

**Error scenarios must include:**
```
And: system state unchanged OR explicit rollback described
```

## Rules

- ALL terms must exist in the ubiquitous_language table
- Scenario titles must be unique and descriptive — used as exact test names
- No implementation details anywhere in Given/When/Then

## Cross-Context Contracts (multi-context only)

For each secondary bounded context:
```
1. mcp__memory__search_nodes: entity=BoundedContext name={secondary}
2. IF brownfield: mcp__serena__get_symbols_overview: src/{secondary}/

Determine mechanism:
  read_only: primary reads secondary data directly
  acl:       anti-corruption layer translates models
  event:     primary subscribes to secondary events
  open_host: secondary exposes a published API

Define:
  {secondary} PROVIDES: {data or events}
  {primary}   CONSUMES: via {mechanism}
  IF acl: {secondary_term} → {primary_term} translation table
```

Persist:
```
mcp__memory__create_relations: BoundedContext → CONSUMES_FROM → BoundedContext
```
