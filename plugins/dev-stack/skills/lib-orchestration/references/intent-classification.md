# Intent Classification Reference

> Part of lib-orchestration skill for dev-stack v10.0.0

---

## Overview

Intent classification analyzes user request to determine task type. This is the first step in dynamic orchestration.

## Intent Types

### Primary Intents

| Intent | Description | Keywords |
|--------|-------------|----------|
| `bug_fix` | Fix bugs, errors, issues | bug, fix, error, issue, broken, crash, exception, not working |
| `new_feature` | Add new functionality | feature, add, new, implement, create, build |
| `refactor` | Improve code structure | refactor, improve, clean, restructure, optimize, simplify |
| `security` | Security-related changes | security, vulnerability, OWASP, attack, exploit, CVE |
| `research` | Information gathering | research, analyze, investigate, explore, understand |
| `documentation` | Write/update docs | document, docs, README, guide, tutorial |
| `hotfix` | Emergency production fix | hotfix, emergency, production down, critical, ASAP |
| `git_ops` | Git operations | git, commit, push, merge, rebase, branch, PR |
| `quality` | Code quality checks | lint, format, check, audit, test, coverage |
| `data` | Database operations | database, DB, SQL, migration, schema, query |

### Secondary Intents

| Intent | Description | Keywords |
|--------|-------------|----------|
| `config` | Configuration changes | config, settings, environment, .env |
| `test` | Testing operations | test, spec, coverage, unit, integration |
| `deploy` | Deployment operations | deploy, release, CI/CD, pipeline |
| `planning` | Task planning | plan, roadmap, milestone, sprint |

---

## Classification Algorithm

### Step 1: Keyword Matching

```python
INTENT_KEYWORDS = {
    "bug_fix": ["bug", "fix", "error", "issue", "broken", "crash", "exception", "not working", "fails", "failure"],
    "new_feature": ["feature", "add", "new", "implement", "create", "build", "develop"],
    "refactor": ["refactor", "improve", "clean", "restructure", "optimize", "simplify", "rewrite"],
    "security": ["security", "vulnerability", "OWASP", "attack", "exploit", "CVE", "injection", "XSS"],
    "research": ["research", "analyze", "investigate", "explore", "understand", "explain", "how does"],
    "documentation": ["document", "docs", "README", "guide", "tutorial", "write up"],
    "hotfix": ["hotfix", "emergency", "production down", "critical", "ASAP", "urgent"],
    "git_ops": ["git", "commit", "push", "merge", "rebase", "branch", "PR", "pull request"],
    "quality": ["lint", "format", "check", "audit", "test", "coverage", "quality"],
    "data": ["database", "DB", "SQL", "migration", "schema", "query", "table"]
}

def classify_by_keywords(request):
    scores = {}
    request_lower = request.lower()

    for intent, keywords in INTENT_KEYWORDS.items():
        score = sum(1 for kw in keywords if kw in request_lower)
        if score > 0:
            scores[intent] = score

    return scores
```

### Step 2: Context Analysis

```python
def analyze_context(request, context=None):
    """Analyze additional context signals"""

    signals = {}

    # File path signals
    if context and "file_path" in context:
        path = context["file_path"]
        if "test" in path or "spec" in path:
            signals["test"] = 2
        if "docs" in path or "README" in path:
            signals["documentation"] = 2
        if "migration" in path or "schema" in path:
            signals["data"] = 2

    # Code signals
    if context and "code_snippet" in context:
        code = context["code_snippet"]
        if "TODO" in code or "FIXME" in code:
            signals["bug_fix"] = 1
        if "def test_" in code or "describe(" in code:
            signals["test"] = 2

    return signals
```

### Step 3: Confidence Calculation

```python
def calculate_confidence(keyword_scores, context_signals):
    """Calculate confidence score (0.0 - 1.0)"""

    # Combine scores
    combined = keyword_scores.copy()
    for intent, score in context_signals.items():
        combined[intent] = combined.get(intent, 0) + score

    if not combined:
        return None, 0.0

    # Get top intent
    top_intent = max(combined, key=combined.get)
    top_score = combined[top_intent]

    # Normalize to 0-1
    max_possible = 5  # Max keyword matches + context signals
    confidence = min(top_score / max_possible, 1.0)

    return top_intent, confidence
```

---

## Classification Function

```
FUNCTION #classify_intent(request, context={})

INPUT:
  - request: string (user's task description)
  - context: object (optional additional context)

OUTPUT:
  {
    "intent": "bug_fix" | "new_feature" | "refactor" | "security" | ...,
    "confidence": 0.0 - 1.0,
    "keywords": ["matched", "keywords"],
    "secondary_intents": [...],
    "reasoning": "Brief explanation"
  }

ALGORITHM:
  1. Normalize request (lowercase, remove punctuation)
  2. Score each intent by keyword matching
  3. Add context signals if available
  4. Calculate confidence
  5. IF confidence < 0.5:
       RETURN ask_user_for_clarification()
  6. RETURN classification result
```

---

## Confidence Thresholds

| Confidence | Action |
|------------|--------|
| >= 0.8 | Proceed with classification |
| 0.5 - 0.8 | Proceed with warning |
| < 0.5 | Ask user for clarification |

---

## Ambiguity Resolution

### Multi-Intent Requests

When request matches multiple intents:

```
IF "bug" AND "security" keywords both present:
  → Prioritize "security" (higher risk)

IF "feature" AND "refactor" both present:
  → Prioritize "new_feature" (more specific)

IF "git" AND any code intent:
  → Treat as code intent + git_operator for commit
```

### Context-Dependent Classification

```
"fix auth" alone:
  → bug_fix (assuming broken auth)

"fix auth" + "OAuth2" + "add":
  → new_feature (adding OAuth2)
```

---

## Examples

### Example 1: Bug Fix

```
Request: "fix login bug in auth.ts"

Classification:
{
  "intent": "bug_fix",
  "confidence": 0.9,
  "keywords": ["fix", "bug"],
  "secondary_intents": [],
  "reasoning": "Clear bug fix request with 'fix' and 'bug' keywords"
}
```

### Example 2: New Feature with Security

```
Request: "add OAuth2 login with credit card payment"

Classification:
{
  "intent": "new_feature",
  "confidence": 0.85,
  "keywords": ["add", "OAuth2"],
  "secondary_intents": ["security"],
  "reasoning": "New feature request with security-sensitive payment handling"
}
```

### Example 3: Ambiguous Request

```
Request: "help with auth"

Classification:
{
  "intent": null,
  "confidence": 0.3,
  "keywords": [],
  "secondary_intents": [],
  "reasoning": "Ambiguous - could be bug, feature, or research"
}

Action: Ask user "What would you like to do with auth? (fix bug / add feature / understand code)"
```

### Example 4: Research

```
Request: "explain how the caching layer works"

Classification:
{
  "intent": "research",
  "confidence": 0.85,
  "keywords": ["explain", "how"],
  "secondary_intents": ["documentation"],
  "reasoning": "Research/explanation request"
}
```

---

## Integration with Tool Priority

After classification, proceed to capability mapping:

```
intent_result = classify_intent(user_request)
IF intent_result.confidence >= 0.5:
  capabilities = map_capabilities(intent_result.intent, user_request)
  team = assemble_team(capabilities)
```

---

## Error Handling

```
IF classification fails:
  1. Log error to memory
  2. Fall back to "general" intent
  3. Assemble full team (all relevant agents)
  4. Notify user of uncertainty
```

---

## Testing

### Unit Tests

```gherkin
Scenario: Classify clear bug fix
  Given request "fix login bug"
  When classify_intent is called
  Then intent should be "bug_fix"
  And confidence should be >= 0.8

Scenario: Classify ambiguous request
  Given request "help with auth"
  When classify_intent is called
  Then confidence should be < 0.5
  And user should be asked for clarification

Scenario: Classify security-sensitive feature
  Given request "add payment processing"
  When classify_intent is called
  Then intent should be "new_feature"
  And secondary_intents should include "security"
```
