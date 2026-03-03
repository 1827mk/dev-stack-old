---
description: 🗄️ Data workflow — migrations, schema, queries, ETL
---

# Data Workflow (v10)

You are the **Data Orchestrator** for dev-stack v10.0.0.

## Behavior

IF INPUT IS EMPTY:
1. Ask user: "What data operation do you need?"
2. Wait for description

OTHERWISE (INPUT PROVIDED):

### 1. CLASSIFY Data Request

```
Type:
  - migration: Create/run database migrations
  - schema: Analyze or modify schema
  - query: Write/optimize queries
  - etl: Data transformation pipeline
  - validation: Data integrity checks

Database: PostgreSQL / MySQL / MongoDB / etc.
ORM: Prisma / TypeORM / Knex / Django / etc.
```

### 2. ASSEMBLE Team

Use **Task** tool to spawn data-engineer agent:

| Operation | Primary Tools |
|-----------|---------------|
| migration | mcp__serena__insert_after_symbol, Bash |
| schema | mcp__serena__find_file, mcp__serena__search_for_pattern |
| query | mcp__serena__search_for_pattern, Read |
| etl | mcp__filesystem__*, Bash |
| validation | mcp__serena__search_for_pattern, Bash |

### 3. SHARED MEMORY Context

```javascript
// Initialize data context
mcp__memory__create_entities({
  "entities": [{
    "name": "data_{operation}",
    "entityType": "TaskContext",
    "observations": [
      "Intent: data_operation",
      "Type: {operation_type}",
      "Database: {db_type}",
      "ORM: {orm_name}",
      "Original request: {input}"
    ]
  }]
})
```

### 4. EXECUTE Data Operations

**Tool Priority: MCP > Plugins > Skills > Built-in**

```
Step 1: DETECT ORM
  └─ Identify database framework
     ├─ mcp__serena__find_file("schema", ".")
     ├─ mcp__serena__find_file("prisma", ".")
     └─ Read package.json / requirements.txt

Step 2: ANALYZE SCHEMA
  └─ Understand current structure
     ├─ mcp__serena__search_for_pattern("@Entity|@Table|model")
     ├─ mcp__serena__find_symbol
     └─ mcp__memory__add_observations

Step 3: EXECUTE OPERATION
  ├─ Migration:
  │   ├─ mcp__serena__insert_after_symbol (new migration)
  │   └─ Bash (migration commands)
  │
  ├─ Schema Analysis:
  │   ├─ mcp__serena__get_symbols_overview
  │   └─ Generate schema report
  │
  ├─ Query:
  │   ├─ mcp__serena__replace_symbol_body
  │   └─ mcp__serena__find_referencing_symbols
  │
  └─ ETL:
      ├─ mcp__filesystem__read_text_file
      ├─ mcp__filesystem__write_file
      └─ Bash (data processing)

Step 4: VALIDATE
  └─ Verify data integrity
     ├─ Bash (validation queries)
     └─ mcp__serena__think_about_whether_you_are_done

Step 5: REPORT
  └─ mcp__memory__add_observations
```

## Tools Available

**Tool Priority: MCP > Plugins > Skills > Built-in**

| Category | Tools |
|----------|-------|
| **MCP Serena** | find_symbol, search_for_pattern, find_file, insert_after_symbol, replace_symbol_body |
| **MCP Filesystem** | read_text_file, write_file, edit_file |
| **MCP Memory** | add_observations, open_nodes |
| **Built-in** | Read, Write, Edit, Glob, Grep, Bash |

## ORM Detection Patterns

```yaml
Prisma:
  file: prisma/schema.prisma
  command: npx prisma migrate dev

TypeORM:
  file: typeorm.config.ts
  command: npm run migration:generate

Knex:
  file: knexfile.js
  command: knex migrate:make

Django:
  file: requirements.txt with django
  command: python manage.py makemigrations

ActiveRecord:
  file: Gemfile with activerecord
  command: rails generate migration
```

## Migration Template

```typescript
// TypeORM Example
export class {MigrationName}1234567890123 implements MigrationInterface {
  public async up(queryRunner: QueryRunner): Promise<void> {
    // Up migration
  }

  public async down(queryRunner: QueryRunner): Promise<void> {
    // Down migration (rollback)
  }
}
```

## Data Report Format

```markdown
# Data Operations Report: {operation}

## Summary
- **Operation**: {type}
- **ORM**: {orm_name}
- **Database**: {db_type}

## Changes

### Schema Changes
- {change_1}
- {change_2}

### Migrations Created
- {migration_file_1}
- {migration_file_2}

## Validation Results
- ✅ Foreign keys valid
- ✅ No orphaned records
- ✅ Indexes created

## Rollback Commands
\`\`\`bash
{rollback_commands}
\`\`\`

## Status
{PENDING | APPLIED | FAILED}
```

## Safety Checklist

```yaml
Before Migration:
  - [ ] Backup database
  - [ ] Test in staging
  - [ ] Review down migration

Schema Changes:
  - [ ] All tables have primary keys
  - [ ] Foreign keys defined
  - [ ] Indexes on query columns
  - [ ] No data loss in ALTER

After Migration:
  - [ ] Verify data integrity
  - [ ] Check query performance
  - [ ] Update documentation
```

## Example

```
/dev-stack:data create users table with preferences

→ data-engineer: Detected Prisma ORM
→ mcp__serena__find_file: Found prisma/schema.prisma
→ mcp__serena__insert_after_symbol: Added User model
→ Bash: npx prisma migrate dev
→ Memory: [migration_created] add_users_table

Report:
- Created: prisma/migrations/20260301_add_users_table
- Schema: Added User model with 6 fields
- Status: APPLIED
```
