# DDD Modeling Reference

## Bounded Context

```
bounded_context: {
  name: exact_name,
  subdomain_type: core | supporting | generic
}
```

## Ubiquitous Language

```
[{
  term: exact_name_in_this_context,
  definition: precise_meaning,
  NOT: {common confusion or synonym to avoid}
}]
```

Rules:
- All terms precise — no synonyms within same context
- One term per concept per bounded context
- Terms must appear verbatim in code

## Aggregates

```
[{
  name: PascalCase,
  root: {entity name},
  contains: [entities, value_objects],
  invariants: [must always hold — write as assertions],
  lifecycle: [states and transitions]
}]
```

## Domain Events

```
[{
  name: PastTense (e.g. OrderPlaced, SubscriptionCancelled),
  when: condition that triggers it,
  consumed_by: [list of bounded contexts or aggregates]
}]
```

Rule: Always past tense. Always explicitly named.

## Value Objects

```
[{
  name: PascalCase,
  attributes: [],
  constraints: [validation rules],
  equality: by_value_not_identity
}]
```

## Domain Services

```
[{
  name: PascalCase,
  why_not_on_aggregate: {reason it cannot be an aggregate method}
}]
```

## Persist to Memory

```
mcp__memory__create_entities: BoundedContext, DomainEvent[]
mcp__memory__create_relations: BoundedContext → PUBLISHES → DomainEvent
```
