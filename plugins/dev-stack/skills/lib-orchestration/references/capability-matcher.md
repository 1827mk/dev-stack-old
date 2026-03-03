# Capability Matcher

> Algorithm สำหรับจับคู่ task requirements กับ agents ที่เหมาะสม

---

## Overview

Capability Matcher วิเคราะห์ user request และจับคู่กับ agents ที่มีความสามารถตรงกัน

```
User Request → Requirement Analysis → Capability Extraction → Agent Matching → Team Assembly
```

---

## Agent Capabilities Matrix

### Capability Definitions

```yaml
capabilities:
  # Code Operations
  code_analysis:
    description: "วิเคราะห์ code, หา bug, เข้าใจ structure"
    agents: [code-analyzer]
    keywords: [bug, error, issue, analyze, debug, investigate, ตรวจสอบ, หา, วิเคราะห์]

  code_writing:
    description: "เขียน code, implement feature, fix bug"
    agents: [code-writer]
    keywords: [implement, create, add, write, fix, build, สร้าง, เขียน, แก้, ทำ]

  code_refactoring:
    description: "ปรับปรุง code structure โดยไม่เปลี่ยน behavior"
    agents: [code-writer, code-analyzer]
    keywords: [refactor, improve, clean, restructure, optimize, ปรับปรุง, ล้าง]

  # Quality Operations
  testing:
    description: "รัน test, validate, verify"
    agents: [qa-validator]
    keywords: [test, verify, validate, coverage, ทดสอบ, ตรวจสอบ]

  security_scanning:
    description: "ตรวจ security vulnerabilities, OWASP"
    agents: [security-scanner]
    keywords: [security, vulnerability, OWASP, attack, exploit, ความปลอดภัย]

  # Data Operations
  database:
    description: "Schema, migration, query, ETL"
    agents: [data-engineer]
    keywords: [database, schema, migration, SQL, query, table, ฐานข้อมูล]

  # Documentation
  documentation:
    description: "เขียน docs, README, API docs"
    agents: [doc-writer]
    keywords: [document, readme, docs, wiki, เอกสาร]

  # Research
  research:
    description: "ค้นหา information, external docs, library usage"
    agents: [researcher]
    keywords: [research, find, search, library, documentation, external, ค้นหา, วิจัย]

  # File Operations
  file_management:
    description: "Create, move, delete, organize files"
    agents: [file-manager]
    keywords: [file, directory, folder, create, move, delete, ไฟล์]

  # Git Operations
  git:
    description: "Commit, push, PR, branch operations"
    agents: [git-operator]
    keywords: [git, commit, push, pull, branch, PR, merge]

  # Planning
  planning:
    description: "Task decomposition, scheduling, dependency"
    agents: [task-planner]
    keywords: [plan, schedule, task, decompose, วางแผน]

  # Memory
  memory_coordination:
    description: "Initialize and manage shared memory context"
    agents: [memory-keeper]
    keywords: [memory, context, share, coordinate]
```

---

## Matching Algorithm

### #analyze_requirements

```python
FUNCTION analyze_requirements(user_request)

INPUT:
  user_request: string  # "ช่วยตรวจสอบบัคของ auth.ts และตรวจ security"

OUTPUT:
  {
    "detected_capabilities": ["code_analysis", "security_scanning"],
    "confidence_scores": {
      "code_analysis": 0.95,
      "security_scanning": 0.85,
      "testing": 0.3  # low confidence, optional
    },
    "required_agents": ["code-analyzer", "security-scanner"],
    "optional_agents": ["qa-validator"]
  }

ALGORITHM:
  1. Tokenize and normalize request
  2. Match keywords against capability definitions
  3. Calculate confidence scores based on keyword matches
  4. Filter capabilities above threshold (0.5)
  5. Map capabilities to agents
  6. Separate required (>=0.7) vs optional (0.5-0.7)
```

### #match_capabilities_to_agents

```python
FUNCTION match_capabilities_to_agents(required_capabilities)

INPUT:
  required_capabilities: ["code_analysis", "security_scanning", "testing"]

OUTPUT:
  {
    "team": [
      {"agent": "code-analyzer", "capabilities": ["code_analysis"], "role": "primary"},
      {"agent": "security-scanner", "capabilities": ["security_scanning"], "role": "primary"},
      {"agent": "qa-validator", "capabilities": ["testing"], "role": "primary"},
      {"agent": "memory-keeper", "capabilities": ["memory_coordination"], "role": "support"}
    ],
    "execution_order": [["code-analyzer", "security-scanner"], ["qa-validator"]],
    "dependencies": {}
  }

ALGORITHM:
  1. Map each capability to responsible agent
  2. Always include memory-keeper as support
  3. Group agents by execution phase:
     - Phase 1: Analysis agents (code-analyzer, security-scanner, researcher)
     - Phase 2: Implementation agents (code-writer, data-engineer)
     - Phase 3: Validation agents (qa-validator)
  4. Identify dependencies between agents
```

---

## Team Assembly Rules

### Priority-Based Assembly

```yaml
rules:
  always_include:
    - memory-keeper  # For shared context

  conditional_include:
    security_scanning:
      trigger: ["security", "vulnerability", "OWASP", "attack"]
      agent: security-scanner

    testing:
      trigger: ["test", "verify", "validate"]
      agent: qa-validator
      after: [code-writer]  # Run after code changes

    database:
      trigger: ["database", "schema", "migration", "SQL"]
      agent: data-engineer

    documentation:
      trigger: ["document", "readme", "docs"]
      agent: doc-writer
      after: [code-writer]  # Run after implementation
```

### Execution Phases

```
Phase 1: ANALYSIS (Parallel)
├── code-analyzer
├── security-scanner
└── researcher

Phase 2: IMPLEMENTATION (Sequential if dependent)
├── code-writer
├── data-engineer
└── file-manager

Phase 3: VALIDATION (Parallel)
├── qa-validator
└── security-scanner (re-scan)

Phase 4: CLEANUP (Sequential)
├── doc-writer
└── git-operator
```

---

## Intent Classification Enhancement

### Combined Intent + Capability

```python
FUNCTION classify_and_match(user_request)

# Step 1: Classify Intent
intent = classify_intent(user_request)
# "bug_fix", "feature", "refactor", "security", "research", etc.

# Step 2: Get Base Team for Intent
base_team = INTENT_BASE_TEAM[intent]
# bug_fix → [code-analyzer, code-writer, qa-validator]

# Step 3: Analyze Additional Capabilities
additional = analyze_requirements(user_request)
# "ตรวจสอบบัค + security" → security_scanning

# Step 4: Merge Teams
final_team = merge_teams(base_team, additional.required_agents)

# Step 5: Add Support
final_team.append("memory-keeper")

RETURN final_team
```

### Intent Base Teams

```yaml
INTENT_BASE_TEAM:
  bug_fix:
    - code-analyzer   # Find the bug
    - code-writer     # Fix the bug
    - qa-validator    # Verify fix

  new_feature:
    - task-planner    # Decompose task
    - code-writer     # Implement
    - qa-validator    # Test
    - doc-writer      # Document

  refactor:
    - code-analyzer   # Understand current
    - code-writer     # Refactor
    - qa-validator    # Verify behavior

  security_patch:
    - security-scanner  # Find vulnerabilities
    - code-writer       # Fix issues
    - qa-validator      # Verify fix
    - security-scanner  # Re-scan

  research:
    - researcher      # Do research
    - doc-writer      # Document findings

  database_change:
    - data-engineer   # Handle DB
    - code-writer     # Update code
    - qa-validator    # Test

  documentation:
    - doc-writer      # Write docs

  git_operation:
    - git-operator    # Git ops
```

---

## Examples

### Example 1: Bug Fix with Security

```
Input: "ช่วยตรวจสอบบัคของ auth.ts และตรวจ security ด้วย"

Step 1: Intent Classification
  → intent: "bug_fix" (confidence: 0.9)

Step 2: Base Team
  → [code-analyzer, code-writer, qa-validator]

Step 3: Additional Capabilities
  → "security" detected → security_scanning (confidence: 0.85)

Step 4: Final Team
  → [code-analyzer, security-scanner, code-writer, qa-validator, memory-keeper]

Step 5: Execution Plan
  Phase 1 (Parallel): code-analyzer, security-scanner
  Phase 2 (Sequential): code-writer
  Phase 3 (Parallel): qa-validator
```

### Example 2: Feature with Database

```
Input: "เพิ่ม feature user preferences ต้องมี database schema"

Step 1: Intent Classification
  → intent: "new_feature" (confidence: 0.95)

Step 2: Base Team
  → [task-planner, code-writer, qa-validator, doc-writer]

Step 3: Additional Capabilities
  → "database" detected → database (confidence: 0.9)

Step 4: Final Team
  → [task-planner, data-engineer, code-writer, qa-validator, doc-writer, memory-keeper]

Step 5: Execution Plan
  Phase 1: task-planner
  Phase 2 (Parallel): data-engineer, code-writer
  Phase 3 (Parallel): qa-validator, doc-writer
```

### Example 3: Research Only

```
Input: "ค้นหา best practices สำหรับ JWT authentication"

Step 1: Intent Classification
  → intent: "research" (confidence: 0.9)

Step 2: Base Team
  → [researcher, doc-writer]

Step 3: Additional Capabilities
  → None detected

Step 4: Final Team
  → [researcher, doc-writer, memory-keeper]

Step 5: Execution Plan
  Phase 1 (Sequential): researcher → doc-writer
```

---

## Performance Optimization

### Caching

```python
# Cache capability matches for similar requests
CACHE_PREFIX = "capability_match:"
CACHE_TTL = 3600  # 1 hour

def get_cached_match(request_hash):
    return cache.get(f"{CACHE_PREFIX}{request_hash}")
```

### Parallel Processing

```python
# Analyze capabilities in parallel
async def analyze_parallel(request):
    tasks = [
        detect_code_capabilities(request),
        detect_security_capabilities(request),
        detect_data_capabilities(request),
        detect_doc_capabilities(request)
    ]
    results = await asyncio.gather(*tasks)
    return merge_results(results)
```

---

## Fallback Strategy

```python
IF capability_matching_fails:
  1. Fall back to intent-based team selection
  2. Use default team for detected intent
  3. Log warning for investigation

IF no_intent_detected:
  1. Use generic team: [code-analyzer, code-writer, qa-validator]
  2. Ask user for clarification
```
