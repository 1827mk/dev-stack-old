---
description: Run lint + typecheck + build (opt-in quality gate)
---

Run quality checks based on project type:

```bash
cd $(git rev-parse --show-toplevel 2>/dev/null || echo ".")

# Node/TypeScript
[ -f tsconfig.json ] && npx --no-install tsc --noEmit
[ -f biome.json ] && npx --no-install biome check .
[ -f .eslintrc* ] && npx --no-install eslint . --max-warnings=0

# Python
command -v ruff &>/dev/null && ruff check .
command -v mypy &>/dev/null && mypy . --ignore-missing-imports

# Go
[ -f go.mod ] && { go vet ./...; go build ./...; }

# Rust
[ -f Cargo.toml ] && { cargo check; cargo clippy -- -D warnings; }

# Java
[ -f pom.xml ] && mvn compile -q
[ -f build.gradle ] && ./gradlew compileJava -q
```
