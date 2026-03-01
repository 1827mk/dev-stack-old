#!/bin/bash
#
# dev-stack PreCommit Hook (v9.0)
# Quality gate before git commit - auto-detects project type
#

set -e

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$0")/..}"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║            🔍 dev-stack PreCommit Quality Gate                ║"
echo "╚═══════════════════════════════════════════════════════════════╝"

# Track check results
PASSED=0
FAILED=0
WARNINGS=0

# ─────────────────────────────────────────────────────────────────────
# DETECT PROJECT TYPE
# ─────────────────────────────────────────────────────────────────────

detect_project_type() {
    if [ -f "package.json" ]; then
        if [ -f "tsconfig.json" ]; then
            echo "typescript"
        else
            echo "javascript"
        fi
    elif [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "requirements.txt" ]; then
        echo "python"
    elif [ -f "go.mod" ]; then
        echo "go"
    elif [ -f "pom.xml" ] || [ -f "build.gradle" ]; then
        echo "java"
    elif [ -f "Cargo.toml" ]; then
        echo "rust"
    else
        echo "unknown"
    fi
}

PROJECT_TYPE=$(detect_project_type)
echo -e "\n📦 Detected project type: ${YELLOW}${PROJECT_TYPE}${NC}"

# ─────────────────────────────────────────────────────────────────────
# CHECK 1: SECURITY PATTERNS
# ─────────────────────────────────────────────────────────────────────

check_security_patterns() {
    echo -e "\n🔒 Checking security patterns..."

    # Patterns to detect (using basic grep for portability)
    PATTERNS=(
        "hardcoded.*password\s*=\s*['\"]"
        "api_key\s*=\s*['\"]"
        "secret\s*=\s*['\"]"
        "private_key\s*=\s*['\"]"
        "eval\s*("
        "exec\s*("
        "innerHTML\s*="
    )

    FOUND_ISSUES=0

    for pattern in "${PATTERNS[@]}"; do
        # Use grep with extended regex
        if grep -rqE "$pattern" --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" --include="*.py" --include="*.go" --include="*.java" . 2>/dev/null; then
            echo -e "  ${RED}✗${NC} Found pattern: $pattern"
            FOUND_ISSUES=$((FOUND_ISSUES + 1))
        fi
    done

    if [ $FOUND_ISSUES -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} No security pattern issues found"
        return 0
    else
        echo -e "  ${RED}✗${NC} Found $FOUND_ISSUES security pattern(s)"
        return 1
    fi
}

# ─────────────────────────────────────────────────────────────────────
# CHECK 2: LINT
# ─────────────────────────────────────────────────────────────────────

check_lint() {
    echo -e "\n🔧 Running lint check..."

    case $PROJECT_TYPE in
        typescript|javascript)
            if grep -q '"lint"' package.json 2>/dev/null; then
                if npm run lint 2>&1 | head -20; then
                    echo -e "  ${GREEN}✓${NC} Lint passed"
                    return 0
                else
                    echo -e "  ${RED}✗${NC} Lint failed"
                    return 1
                fi
            else
                echo -e "  ${YELLOW}⚠${NC} No lint script found, skipping"
                return 0
            fi
            ;;
        python)
            if command -v ruff &> /dev/null; then
                if ruff check . 2>&1 | head -20; then
                    echo -e "  ${GREEN}✓${NC} Ruff check passed"
                    return 0
                else
                    echo -e "  ${RED}✗${NC} Ruff check failed"
                    return 1
                fi
            elif command -v flake8 &> /dev/null; then
                if flake8 . 2>&1 | head -20; then
                    echo -e "  ${GREEN}✓${NC} Flake8 passed"
                    return 0
                else
                    echo -e "  ${RED}✗${NC} Flake8 failed"
                    return 1
                fi
            else
                echo -e "  ${YELLOW}⚠${NC} No linter found, skipping"
                return 0
            fi
            ;;
        go)
            if command -v golint &> /dev/null; then
                if golint ./... 2>&1 | head -20; then
                    echo -e "  ${GREEN}✓${NC} Golint passed"
                    return 0
                else
                    echo -e "  ${RED}✗${NC} Golint failed"
                    return 1
                fi
            else
                echo -e "  ${YELLOW}⚠${NC} golint not found, skipping"
                return 0
            fi
            ;;
        *)
            echo -e "  ${YELLOW}⚠${NC} Lint not configured for $PROJECT_TYPE"
            return 0
            ;;
    esac
}

# ─────────────────────────────────────────────────────────────────────
# CHECK 3: TYPE CHECK
# ─────────────────────────────────────────────────────────────────────

check_types() {
    echo -e "\n📝 Running type check..."

    case $PROJECT_TYPE in
        typescript)
            if [ -f "tsconfig.json" ]; then
                if npx tsc --noEmit 2>&1 | head -20; then
                    echo -e "  ${GREEN}✓${NC} TypeScript check passed"
                    return 0
                else
                    echo -e "  ${RED}✗${NC} TypeScript check failed"
                    return 1
                fi
            fi
            ;;
        python)
            if command -v mypy &> /dev/null; then
                if mypy . 2>&1 | head -20; then
                    echo -e "  ${GREEN}✓${NC} Mypy passed"
                    return 0
                else
                    echo -e "  ${RED}✗${NC} Mypy failed"
                    return 1
                fi
            else
                echo -e "  ${YELLOW}⚠${NC} mypy not found, skipping"
                return 0
            fi
            ;;
        go)
            if go build ./... 2>&1 | head -20; then
                echo -e "  ${GREEN}✓${NC} Go build passed"
                return 0
            else
                echo -e "  ${RED}✗${NC} Go build failed"
                return 1
            fi
            ;;
        rust)
            if cargo check 2>&1 | head -20; then
                echo -e "  ${GREEN}✓${NC} Cargo check passed"
                return 0
            else
                echo -e "  ${RED}✗${NC} Cargo check failed"
                return 1
            fi
            ;;
        *)
            echo -e "  ${YELLOW}⚠${NC} Type check not configured for $PROJECT_TYPE"
            return 0
            ;;
    esac
}

# ─────────────────────────────────────────────────────────────────────
# CHECK 4: TESTS
# ─────────────────────────────────────────────────────────────────────

check_tests() {
    echo -e "\n🧪 Running tests..."

    case $PROJECT_TYPE in
        typescript|javascript)
            if grep -q '"test"' package.json 2>/dev/null; then
                if npm test 2>&1 | tail -30; then
                    echo -e "  ${GREEN}✓${NC} Tests passed"
                    return 0
                else
                    echo -e "  ${RED}✗${NC} Tests failed"
                    return 1
                fi
            else
                echo -e "  ${YELLOW}⚠${NC} No test script found, skipping"
                return 0
            fi
            ;;
        python)
            if command -v pytest &> /dev/null; then
                if pytest --tb=short -q 2>&1 | tail -20; then
                    echo -e "  ${GREEN}✓${NC} Pytest passed"
                    return 0
                else
                    echo -e "  ${RED}✗${NC} Pytest failed"
                    return 1
                fi
            else
                echo -e "  ${YELLOW}⚠${NC} pytest not found, skipping"
                return 0
            fi
            ;;
        go)
            if go test ./... 2>&1 | tail -20; then
                echo -e "  ${GREEN}✓${NC} Go tests passed"
                return 0
            else
                echo -e "  ${RED}✗${NC} Go tests failed"
                return 1
            fi
            ;;
        rust)
            if cargo test 2>&1 | tail -20; then
                echo -e "  ${GREEN}✓${NC} Cargo tests passed"
                return 0
            else
                echo -e "  ${RED}✗${NC} Cargo tests failed"
                return 1
            fi
            ;;
        *)
            echo -e "  ${YELLOW}⚠${NC} Tests not configured for $PROJECT_TYPE"
            return 0
            ;;
    esac
}

# ─────────────────────────────────────────────────────────────────────
# RUN ALL CHECKS
# ─────────────────────────────────────────────────────────────────────

run_checks() {
    # Security patterns (always run)
    if check_security_patterns; then
        PASSED=$((PASSED + 1))
    else
        FAILED=$((FAILED + 1))
    fi

    # Lint
    if check_lint; then
        PASSED=$((PASSED + 1))
    else
        FAILED=$((FAILED + 1))
    fi

    # Type check
    if check_types; then
        PASSED=$((PASSED + 1))
    else
        FAILED=$((FAILED + 1))
    fi

    # Tests
    if check_tests; then
        PASSED=$((PASSED + 1))
    else
        FAILED=$((FAILED + 1))
    fi
}

# ─────────────────────────────────────────────────────────────────────
# REPORT
# ─────────────────────────────────────────────────────────────────────

print_report() {
    echo -e "\n╔═══════════════════════════════════════════════════════════════╗"
    echo "║                    📊 PreCommit Report                        ║"
    echo "╠═══════════════════════════════════════════════════════════════╣"
    echo -e "║  ${GREEN}✓ Passed: ${PASSED}${NC}                                                  "
    echo -e "║  ${RED}✗ Failed: ${FAILED}${NC}                                                  "
    echo "╚═══════════════════════════════════════════════════════════════╝"

    if [ $FAILED -gt 0 ]; then
        echo -e "\n${RED}❌ PreCommit FAILED - Please fix issues before committing${NC}"
        exit 1
    else
        echo -e "\n${GREEN}✅ PreCommit PASSED - Ready to commit${NC}"
        exit 0
    fi
}

# Main execution
run_checks
print_report
