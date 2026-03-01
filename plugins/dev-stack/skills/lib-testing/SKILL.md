---
disable-model-invocation: false
user-invokable: false
name: lib-testing
description: Test strategies and validation. Call skill:lib-testing(detect|discover|generate|coverage) for test operations.
---

# lib-testing

Internal library for test strategies, framework detection, and BDD-to-test generation.

## Capabilities

| Function | Description |
|----------|-------------|
| `detect` | Detect test framework and config |
| `discover` | Find all test files matching pattern |
| `generate` | Generate tests from BDD scenarios |
| `coverage` | Validate coverage thresholds |
| `run` | Execute tests with framework-specific command |

---

## DETECT: Framework Detection

Auto-detect test framework based on project files:

```yaml
Detection Map:
  package.json + jest.config.js → Jest
  package.json + vitest.config.ts → Vitest
  package.json + "*.test.ts" → Jest (default)
  pytest.ini / pyproject.toml [tool.pytest] → pytest
  go.mod + "*_test.go" → go test
  Cargo.toml + tests/ → cargo test
  pom.xml + src/test/ → Maven Surefire
  build.gradle + src/test/ → Gradle Test
```

### Usage

```
skill:lib-testing(detect)
```

### Output

```yaml
framework: jest|pytest|go-test|cargo-test|maven|gradle
config_file: jest.config.js|pytest.ini|...
test_pattern: "*.test.ts"|test_*.py|*_test.go
command: npm test|pytest|go test ./...
coverage_command: npm test -- --coverage|pytest --cov
```

### Implementation

```
1. mcp__serena__find_file:
   - jest.config.*
   - vitest.config.*
   - pytest.ini
   - pyproject.toml
   - go.mod
   - Cargo.toml

2. mcp__serena__search_for_pattern:
   - "jest|vitest|mocha" in package.json
   - "pytest|unittest" in requirements.txt
   - "testing" in go.mod

3. RETURN framework config
```

---

## DISCOVER: Test File Discovery

Find all test files in project:

### Usage

```
skill:lib-testing(discover)
skill:lib-testing(discover, pattern="*.integration.test.ts")
```

### Output

```yaml
test_files:
  - path: src/auth/login.test.ts
    type: unit
    framework: jest
  - path: tests/integration/api.test.ts
    type: integration
    framework: jest
  - path: e2e/login.spec.ts
    type: e2e
    framework: playwright

summary:
  total: 15
  unit: 10
  integration: 3
  e2e: 2
```

### Implementation

```
1. Detect framework (call detect)
2. mcp__filesystem__search_files:
   - pattern: "{test_pattern}"
   - exclude: node_modules, dist, build
3. Classify by path:
   - *.spec.ts → e2e
   - *.integration.test.ts → integration
   - *.test.ts → unit
4. RETURN file list
```

---

## GENERATE: BDD to Test Generation

Generate test file from BDD scenarios in spec.md:

### Usage

```
skill:lib-testing(generate, spec_id="001-auth", scenario="User Login")
```

### Process

```
1. Read spec.md → extract BDD scenarios
2. FOR each scenario:
   a. Extract: Given, When, Then
   b. Map to test structure:
      - Given → arrange/setup
      - When → act/execute
      - Then → assert/verify
   c. Generate test function
3. Write test file
```

### Template (Jest/TypeScript)

```typescript
describe('{scenario_title}', () => {
  // Given: {given_description}
  beforeEach(() => {
    // Setup code from Given
  });

  // When: {when_description}
  test('{expected_outcome}', async () => {
    // Act code from When
    const result = await {action};

    // Then: {then_description}
    expect(result).{assertion};
  });
});
```

### Template (pytest/Python)

```python
class Test{ScenarioClass}:
    """BDD: {scenario_title}"""

    # Given: {given_description}
    @pytest.fixture
    def setup(self):
        # Setup code from Given
        yield
        # Teardown

    def test_{test_name}(self, setup):
        """When: {when_description}"""
        # Act code from When
        result = {action}()

        # Then: {then_description}
        assert result == {expected}
```

### Implementation

```
1. Read .specify/specs/{spec_id}/spec.md
2. mcp__serena__search_for_pattern:
   - "Scenario:|Given|When|Then"
3. Parse BDD blocks
4. Detect language → select template
5. Generate test file
6. Write to test directory
```

---

## COVERAGE: Coverage Validation

Validate test coverage meets thresholds:

### Usage

```
skill:lib-testing(coverage)
skill:lib-testing(coverage, threshold=80)
```

### Output

```yaml
coverage:
  lines: 85.2
  functions: 92.1
  branches: 78.5
  statements: 85.0

threshold: 80
status: PASS

uncovered_files:
  - src/utils/legacy.ts (45%)
  - src/api/external.ts (62%)

recommendations:
  - "Add tests for src/utils/legacy.ts error handling"
  - "Cover edge cases in src/api/external.ts"
```

### Implementation

```
1. Detect framework → get coverage command
2. Run coverage command
3. Parse coverage output:
   - Jest: coverage/lcov-report/coverage-final.json
   - pytest: .coverage + coverage report
   - go: go test -coverprofile=coverage.out
4. Compare against threshold
5. RETURN report
```

---

## RUN: Execute Tests

Run tests with framework-specific command:

### Usage

```
skill:lib-testing(run)
skill:lib-testing(run, filter="auth")
skill:lib-testing(run, watch=true)
```

### Commands by Framework

```yaml
jest:
  default: npm test
  filter: npm test -- --testPathPattern={filter}
  watch: npm test -- --watch
  coverage: npm test -- --coverage

vitest:
  default: npx vitest run
  filter: npx vitest run {filter}
  watch: npx vitest
  coverage: npx vitest run --coverage

pytest:
  default: pytest
  filter: pytest -k {filter}
  watch: pytest-watch
  coverage: pytest --cov --cov-report=term

go-test:
  default: go test ./...
  filter: go test -run {filter} ./...
  coverage: go test -cover ./...

cargo-test:
  default: cargo test
  filter: cargo test {filter}
  coverage: cargo tarpaulin
```

### Output

```yaml
status: PASS|FAIL
tests_run: 42
tests_passed: 40
tests_failed: 2
duration: "12.5s"

failures:
  - test: "User Login with invalid credentials"
    error: "Expected 401, got 500"
    file: src/auth/login.test.ts:45
```

---

## TDD WORKFLOW INTEGRATION

Integration with superpowers:test-driven-development:

```yaml
RED phase:
  1. skill:lib-testing(generate, scenario) → create failing test
  2. skill:lib-testing(run, filter=scenario) → verify fails

GREEN phase:
  1. Implement minimal code
  2. skill:lib-testing(run, filter=scenario) → verify passes

REFACTOR phase:
  1. Refactor implementation
  2. skill:lib-testing(run) → verify still passes
  3. skill:lib-testing(coverage) → ensure coverage maintained
```

---

## TOOLS USED

| Tool | Purpose |
|------|---------|
| mcp__serena__find_file | Find config files |
| mcp__serena__search_for_pattern | Detect frameworks, parse BDD |
| mcp__filesystem__search_files | Find test files |
| mcp__filesystem__directory_tree | Analyze test structure |
| Read | Read spec.md for BDD scenarios |
| Write | Generate test files |
| Bash | Run test commands |

---

## ERROR HANDLING

```yaml
framework_not_detected:
  action: ASK user for test framework
  fallback: Use generic test patterns

no_tests_found:
  action: WARN and suggest test generation
  options:
    - Generate from BDD scenarios
    - Create test scaffolding

coverage_below_threshold:
  action: Report uncovered files
  severity: WARNING (not blocking)
```
