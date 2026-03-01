# Team Messaging

## INIT_TEAM_MESSAGING

```
INIT_TEAM_MESSAGING(spec_id):
  # Initialize team message log
  CREATE: .specify/specs/{spec_id}/team-messages.log
  APPEND: "[init] Team assembled for {spec_id}"
```

---

## TEAM_MESSAGE

```
TEAM_MESSAGE(from, to, spec_id, type, content):
  # Log message for team visibility
  timestamp <- now().iso()
  APPEND TO .specify/specs/{spec_id}/team-messages.log:
    "[{timestamp}] {from} -> {to} [{type}]\n{content}\n---"

  # Types: handoff | update | question | alert
```

---

## HANDOFF

```
HANDOFF(from_agent, to_agent, spec_id, summary):
  # Structured handoff between phases
  TEAM_MESSAGE(from_agent, to_agent, spec_id, "handoff", summary)
  NOTIFY("phase_complete", spec_id, "{from_agent} -> {to_agent}")
```

---

## SYNC_MEMORY

```
SYNC_MEMORY(phase, spec_id):
  # Extract patterns and insights after phase completion
  patterns <- analyze_code_for_patterns()
  FOR each pattern:
    mcp__memory__create_entities: Pattern {name, context, example, spec: spec_id}
  insights <- extract_insights()
  FOR each insight:
    mcp__memory__create_entities: Insight {title, learning, spec: spec_id}
```

---

## Alternative Message Functions

```
INIT_TEAM_MESSAGES(spec_id):
  log_file = ".specify/specs/{spec_id}/team-messages.log"
  create empty log_file if not exists

SEND_MESSAGE(spec_id, from, to, type, content):
  timestamp = current_iso_timestamp
  append to log_file:
    "[{timestamp}] {from} -> {to} [{type}]
     {content}
     ---"

BROADCAST(spec_id, from, content):
  SEND_MESSAGE(spec_id, from, "all", "update", content)

HANDOFF(spec_id, from, to, summary):
  content = "Handoff from {from} to {to}
    - Completed: {summary.completed}
    - Decisions: {summary.decisions}
    - Files changed: {summary.files}
    - Notes: {summary.notes}"
  SEND_MESSAGE(spec_id, from, to, "handoff", content)
```

---

## MEMORY SYNC

```
SYNC_MEMORY(spec_id, phase):
  patterns <- extract_patterns_from_phase(phase)
  insights <- extract_insights_from_phase(phase)

  FOR each pattern in patterns:
    mcp__memory__create_entities:
      name: {pattern.name}
      entityType: Pattern
      observations: {pattern.observations}

  FOR each insight in insights:
    mcp__memory__create_entities:
      name: {insight.title}
      entityType: Insight
      observations: {insight.observations}

  mcp__memory__create_relations:
    Pattern -> used_in -> Spec:{spec_id}
    Insight -> from -> Spec:{spec_id}
```
