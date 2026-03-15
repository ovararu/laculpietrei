# Device Inventory

A web application for managing network equipment (cameras, switches, routers, PCs, servers). Track device details, visualize the network topology, log service interventions, and export reports to Excel.

---

## What you need installed

Before starting, make sure you have the following on your machine:

1. **Ruby 3.4.8** — the programming language the app runs on
   - Check if installed: `ruby -v`
   - Install with [rbenv](https://github.com/rbenv/rbenv) or [mise](https://mise.jdx.dev/)

2. **Bundler** — manages Ruby dependencies
   - Install: `gem install bundler`

3. **Google Chrome** — required for running system tests headlessly
   - Download from [google.com/chrome](https://www.google.com/chrome/)

That's it. No Node.js, no Docker, no database server needed.

---

## First-time setup

Open a terminal, navigate to the project folder, and run these commands **in order**:

```bash
# 1. Install all Ruby gems (dependencies)
bundle install

# 2. Create the database and run all migrations
bin/rails db:create db:migrate

# 3. Load sample data (devices, interventions)
bin/rails db:seed
```

---

## Running the app

```bash
bin/dev
```

Then open your browser at **http://localhost:3000**

> `bin/dev` starts both the Rails server and the Tailwind CSS watcher at the same time. Keep this terminal open while working.

To stop the app: press `Ctrl+C` in the terminal.

---

## Pages

| URL | Description |
|-----|-------------|
| `/` | Device list — filter by type, export to Excel |
| `/devices/:id` | Device detail — credentials, interventions |
| `/dashboard` | Charts — devices by type and status |
| `/topology` | Interactive network diagram |
| `/interventions` | All service interventions |
| `/billing` | Monthly billing summary (hours worked) |

---

## Running tests

```bash
# All tests
bin/rails test

# Only model/controller tests (fast)
bin/rails test test/models test/controllers

# Only system tests (opens Chrome, slower)
bin/rails test:system

# A single test file
bin/rails test test/models/device_test.rb

# A single test by line number
bin/rails test test/models/device_test.rb:42
```

---

## Resetting the database

If you want to start fresh (wipes all data):

```bash
bin/rails db:reset
```

This drops, recreates, migrates, and re-seeds the database in one command.

---

## Adding a new migration

When you need to change the database schema (add a column, create a table):

```bash
# Example: add a "floor" column to devices
bin/rails generate migration AddFloorToDevices floor:string

# Then run it
bin/rails db:migrate
```

---

## Project structure

```
app/
  models/         # Business logic (Device, Intervention, ...)
  controllers/    # Handle HTTP requests
  views/          # HTML templates (.html.erb) and Excel templates (.xlsx.axlsx)
  javascript/     # Stimulus controllers (chart, topology, theme)
  assets/         # CSS (Tailwind)
config/
  routes.rb       # All URL routes
db/
  migrate/        # Database migrations (schema changes over time)
  seeds.rb        # Sample data for development
  schema.rb       # Current database structure (auto-generated, do not edit)
test/             # Automated tests
```

### Key concepts

- **Devices** use Single Table Inheritance (STI): `Camera`, `Switch`, `Router`, `Pc`, and `Server` are all stored in the `devices` table with a `type` column.
- **Topology** is built with a `parent_device_id` self-referential foreign key on devices.
- **Charts** use Chart.js loaded via `<script>` tag (not importmap) — accessed as `window.Chart`.
- **Topology diagram** uses Vis.js Network loaded via `<script>` tag — accessed as `window.vis.Network`.
- **Excel export** uses the `caxlsx` gem with `.xlsx.axlsx` view templates.
- **CSS** uses Tailwind v4 via `tailwindcss-rails` (no Node.js required).

---

## Tech stack

| | |
|---|---|
| Ruby | 3.4.8 |
| Rails | 8.1 |
| Database | SQLite3 |
| CSS | Tailwind CSS v4 |
| JavaScript | Hotwire (Turbo + Stimulus), importmap |
| Charts | Chart.js 4.4 |
| Topology | Vis.js Network 9.1 |
| Excel | caxlsx / caxlsx_rails |
| Tests | Minitest + Capybara + Selenium |
