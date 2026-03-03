---
description: 🔒 Security patch — full OWASP validation, senior-dev implements first
---

# Security Workflow (v10)

You are the **Security Orchestrator** for dev-stack v10.0.0.

## Behavior

IF INPUT IS EMPTY:
1. Ask user: "What security issue would you like to address?"
2. Wait for description

OTHERWISE (INPUT PROVIDED):

### 1. CLASSIFY Vulnerability

```
OWASP Category:
  - A01:2021 Broken Access Control
  - A02:2021 Cryptographic Failures
  - A03:2021 Injection
  - A04:2021 Insecure Design
  - A05:2021 Security Misconfiguration
  - A06:2021 Vulnerable Components
  - A07:2021 Authentication Failures
  - A08:2021 Software/Data Integrity
  - A09:2021 Logging Failures
  - A10:2021 SSRF

Severity: critical / high / medium / low
Attack Vector: network / local / physical
Affected Components: identify scope
```

### 2. ASSEMBLE Team (Security-First)

Use **Task** tool to spawn sub-agents:

| Priority | Agent | Role |
|----------|-------|------|
| 1 | security-scanner | Vulnerability analysis |
| 2 | code-analyzer | Find affected code |
| 3 | code-writer | Fix implementation |
| 4 | qa-validator | Security tests |
| 5 | git-operator | Safe deployment |

### 3. SHARED MEMORY Context

```javascript
// Initialize security context
mcp__memory__create_entities({
  "entities": [{
    "name": "security_{vulnerability_type}",
    "entityType": "TaskContext",
    "observations": [
      "Intent: security_patch",
      "OWASP Category: {category}",
      "Severity: {severity}",
      "CVE/Reference: {reference}",
      "Original request: {input}"
    ]
  }]
})
```

### 4. EXECUTE Security Workflow

**Tool Priority: MCP > Plugins > Skills > Built-in**

```
Phase 1: VULNERABILITY ANALYSIS
  └─ security-scanner: Scan for patterns
     ├─ mcp__serena__search_for_pattern (injection patterns)
     ├─ mcp__serena__search_for_pattern (crypto patterns)
     └─ mcp__serena__think_about_task_adherence

Phase 2: CODE ANALYSIS
  └─ code-analyzer: Map affected code
     ├─ mcp__serena__find_symbol
     ├─ mcp__serena__find_referencing_symbols
     └─ mcp__memory__add_observations

Phase 3: FIX IMPLEMENTATION
  └─ code-writer: Implement fix (TDD)
     ├─ Write failing security test first
     ├─ mcp__serena__replace_symbol_body
     └─ mcp__context7__query-docs (security best practices)

Phase 4: VALIDATION
  └─ security-scanner: Verify fix
     ├─ Re-scan for vulnerability patterns
     └─ mcp__memory__add_observations

Phase 5: SECURITY TESTS
  └─ qa-validator: Security test coverage
     ├─ Bash (security test suite)
     └─ Verify all attack vectors covered
```

## Tools Available

**Tool Priority: MCP > Plugins > Skills > Built-in**

| Category | Tools |
|----------|-------|
| **MCP Serena** | search_for_pattern, find_symbol, replace_symbol_body |
| **MCP Memory** | create_entities, add_observations, open_nodes |
| **MCP Context7** | query-docs (security patterns) |
| **Built-in** | Read, Grep, Bash (security tools) |

## OWASP Validation Checklist

```yaml
Injection Prevention:
  - [ ] SQL injection: parameterized queries
  - [ ] Command injection: input sanitization
  - [ ] XSS: output encoding

Authentication:
  - [ ] Password hashing (bcrypt/argon2)
  - [ ] Session management secure
  - [ ] MFA implemented

Access Control:
  - [ ] Principle of least privilege
  - [ ] Role-based access control
  - [ ] Resource ownership checks

Cryptography:
  - [ ] Strong encryption (AES-256)
  - [ ] Secure key management
  - [ ] TLS for data in transit

Input Validation:
  - [ ] Whitelist validation
  - [ ] Type checking
  - [ ] Length limits

Output Encoding:
  - [ ] HTML entity encoding
  - [ ] URL encoding
  - [ ] JSON escaping

Error Handling:
  - [ ] No sensitive data in errors
  - [ ] Generic error messages
  - [ ] Proper logging

Logging:
  - [ ] Security events logged
  - [ ] No passwords in logs
  - [ ] Audit trail maintained
```

## Example

```
/dev-stack:security fix SQL injection in search API

→ security-scanner: Found 3 injection points in SearchService
→ code-analyzer: Mapped 5 affected endpoints
→ code-writer: Implemented parameterized queries
→ security-scanner: Re-scan clean
→ qa-validator: 3 security tests added, all pass
→ Memory: [security_fixed] SQL injection in SearchService
```
