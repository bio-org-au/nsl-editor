# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

The **NSL Editor** is a Rails 8 application for editing botanical names and taxonomy data for the Australian National Botanic Gardens (ANBG). It manages databases for Australian plants (APNI), Algae, Fungi, Lichen, and Moss, each in separate PostgreSQL databases sharing a common NSL schema.

- **Ruby**: 3.4.8 (see `.ruby-version`)
- **Rails**: 8.1.x
- **PostgreSQL**: 15.7
- **Time Zone**: Australia/Melbourne

## Build/Test/Lint Commands

```bash
# All Minitest
bundle exec rails test

# Single Minitest file / specific line
bundle exec rails test test/models/author_test.rb
bundle exec rails test test/models/author_test.rb:25

# All RSpec
bundle exec rspec

# Single RSpec file / specific line
bundle exec rspec spec/models/name_spec.rb
bundle exec rspec spec/models/name_spec.rb:10

# Linting
bin/rubocop                # RuboCop linter
bin/brakeman               # Security scanner
bundle exec annotaterb models --exclude tests,spec  # Update model annotations

# Development
bin/setup            # Full setup (git hooks, bundle, db, cleanup)
bin/dev              # Start dev server
bundle install       # Install dependencies
```

## External Configuration (Required)

These files are not in the repo and must be acquired:
- `~/.nsl/editor-database.yml` - Database credentials
- `~/.nsl/development/editor-r7-config.rb` - App config (auth, services endpoints)

## Code Style

### File Header (Required)

All Ruby files must include frozen string literal and Apache 2.0 license:

```ruby
# frozen_string_literal: true

#   Copyright 2015 Australian National Botanic Gardens
#   This file is part of the NSL Editor.
#   Licensed under the Apache License, Version 2.0
```

### Formatting Rules

| Rule | Guideline |
|------|-----------|
| Strings | Double quotes: `"string"` not `'string'` |
| Trailing commas | Multiline hashes: yes. Arrays: no |
| Line/method length | No limits (disabled) |
| `unless` | Never with `&&`/`\|\|`. Use `if !condition` |

### Strict Rules (Will Fail CI)

- **No `binding.pry` or `debugger`** statements
- **No `puts` debugging** (Rails/Output enforced)
- Use `find_each` over `each` for AR collections
- Use `uniq.pluck` not `pluck.uniq`

## Architecture

### Database

- **No migrations** - Schema managed externally via `structure.sql`
- All tables share sequence: `nsl_global_seq`
- Designed for low-privilege CRUD user in production

### Model Conventions

```ruby
class MyModel < ApplicationRecord
  self.table_name = "my_table"
  self.primary_key = "id"
  self.sequence_name = "nsl_global_seq"  # Shared sequence

  include NameScopable  # Use concerns for shared behavior
end
```

- `ApplicationRecord` auto-strips whitespace via `strip_attributes`
- Schema annotations managed by `annotaterb` gem

### Service Object Pattern

```ruby
class MyService < BaseService
  def initialize(params, options = nil)
    @params = params
    @options = options
    @logger = Rails.logger
  end

  def execute
    # Must override - raises NotImplementedError by default
  end
end

# Usage
MyService.call(params, options)
MyService.new_call_transaction(params)  # With rollback on errors
```

### Authorization

- LDAP/SimpleAD for authentication
- CanCanCan for authorization (`current_user`, `current_ability`)
- Database-backed roles for batch reviewers, products, profiles

### Search System

The search mechanism is critical - one unified page for all searches using custom directives. Two engines exist:

1. **Old engine**: Some models under `search/` with `base.rb`, `predicate.rb`
2. **New "OnModel" engine**: YAML-driven via `field_rule.rb`, `field_abbrev.rb`

See `doco/search-engine.md` for detailed architecture.

### External Dependencies

The Editor relies on NSL Services and Mapper apps for name construction, taxonomy operations, and certain deletes.

## Git Workflow

This repo is a fork. The workflow for changes is:
1. Create a local branch
2. Commit changes and push to origin (your fork)
3. Create a PR on GitHub to the upstream repo

**Post-merge git cleanup** (after PR is merged):
```bash
git fetch upstream
git checkout main
git merge upstream/main
git push
git branch -d <branch-name>
```

**Skills** (in `.claude/skills/`) automate these steps:
- `/git-branch-workflow-set-up`: branch, commit, push to origin, open a PR to upstream
- `/change-history-and-version`: add a `config/history/changes-YYYY.yml` entry and bump `config/version.properties` (user-facing changes only)
- `/post-merge-clean-up`: sync `main` with upstream after a merge and delete the branch

## Git Hooks

Run `bin/setup` or `git config core.hooksPath .githooks` to enable:

- **pre-commit**: Blocks Bootstrap 3/4 classes; runs RuboCop on staged Ruby files
- **pre-push**: Confirmation before pushing to main/master

Override options:
```bash
SKIP_RUBOCOP=1 git commit -m "message"  # Skip RuboCop only
git commit --no-verify -m "message"      # Skip all hooks
```

## Test Database Setup

Since there are no migrations, test database setup requires:
```bash
dropdb ned_test; createdb -O nsl ned_test; bundle exec rake db:schema:dump; bundle exec rake db:clean_up_structure_sql; RAILS_ENV=test bin/rails db:setup
```

The `structure.sql` may need hand-editing for complex views/extensions.

## Key Directories

```
app/
  controllers/     # CanCanCan authorization
  models/          # ActiveRecord models
    concerns/      # Shared model modules
    search/        # Search engine models
  services/        # BaseService pattern
config/
  history/         # Release notes (yearly YAML files)
  name-searches.yml  # Search directives
db/
  structure.sql    # Schema (externally managed)
spec/              # RSpec tests
test/              # Minitest tests
  factories/       # FactoryBot factories
  fixtures/        # Test fixtures
```

## Security Review (Oct 2026)

A security review was conducted with findings in `tmp/review/findings.md`. Key items:

### What's in good shape
- Search DSL: all SQL fragments from whitelisted maps, user values always bound with `?`
- Raw SQL: all calls use constant strings or `sanitize_sql` with binds
- LDAP: filters use `Net::LDAP::Filter.eq` (escapes input)
- No `permit!` or `to_unsafe_h` anywhere

### Open items to address
- **XSS via Markdown** (finding 2): Use `sanitize(Kramdown::Document.new(text).to_html)` not `.html_safe`
- **Other `.html_safe` uses** (finding 3): Wrap stored data in `sanitize(...)` rather than `.html_safe`
- **Transport hardening** (finding 4): Enable `force_ssl`/`assume_ssl`, add CSP
- **JSON.load** (finding 10): Use `JSON.parse` instead (5 places in `name/namable.rb`, `reference/citations.rb`, `name/as_services.rb`)

### Common bugs to avoid
- **Assignment in condition**: `=` instead of `==` (finding 8). Three bugs were fixed where `if x = y` was meant to be `if x == y`
- **Duplicate method definitions**: Watch for methods defined twice (second silently wins)

### RuboCop cops to enable
Add these to `.rubocop.yml` for CI to catch regressions:
- `Lint/AssignmentInCondition`
- `Lint/DuplicateMethods`
- `Lint/UnreachableCode`
- `Lint/InterpolationCheck`
- `Lint/UselessAssignment`
- `Security/JSONLoad`
