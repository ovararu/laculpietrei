# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
bin/setup          # Install dependencies and prepare database
bin/dev            # Start development server (port 3000)
bin/ci             # Run full CI pipeline locally (lint, security, tests)

# Testing
bin/rails test                                    # Full test suite
bin/rails test path/to/test_file.rb               # Single file
bin/rails test path/to/test_file.rb:LINE_NUMBER   # Single test
bin/rails test:system                             # System tests (Capybara + Selenium)

# Code quality
bin/rubocop                # Lint Ruby code
bin/brakeman --no-pager    # Security scan
bin/bundler-audit          # Gem vulnerability audit
bin/importmap audit        # JS dependency audit

# Database
bin/rails db:prepare       # Create and migrate databases
bin/rails db:seed          # Load seed data
```

## Architecture

**Stack:** Rails 8.1, Ruby 3.4.8, SQLite3, Hotwire (Turbo + Stimulus), Propshaft, Import Maps (no Node/npm build step required).

**Async infrastructure:** Solid Queue (job processing), Solid Cache (caching), Solid Cable (Action Cable) — all SQLite-backed. In production, Solid Queue runs inside the Puma process (`SOLID_QUEUE_IN_PUMA=true`).

**Multi-database setup:** Production uses four SQLite databases — primary (`production.sqlite3`), cache (`production_cache.sqlite3`), queue (`production_queue.sqlite3`), cable (`production_cable.sqlite3`). Each has its own schema file under `db/` and migration path.

**Frontend:** Stimulus controllers live in `app/javascript/controllers/`. Import map is configured in `config/importmap.rb`. No build toolchain — assets served directly via Propshaft.

**CI (GitHub Actions):** Runs on PRs and pushes to `development` branch. Five parallel jobs: `scan_ruby` (Brakeman), `scan_js` (importmap audit), `lint` (RuboCop), `test`, `system-test`. System test failures upload screenshots as artifacts.

**Deployment:** Docker + Kamal. See `config/deploy.yml`. Runs as non-root `rails` user, served through Thruster HTTP proxy in front of Puma.
