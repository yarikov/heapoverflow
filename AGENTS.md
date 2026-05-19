# Heap Overflow — Agent Guide

Heap Overflow is a Rails 8 web application that clones Stack Overflow. Users ask and answer questions, vote, comment, subscribe to topics, and authenticate via email or OAuth (Facebook, Twitter).

## Technology Stack

| Layer | Technology |
|-------|------------|
| Runtime | Ruby 4.0.4 (see `.ruby-version`) |
| Framework | Rails ~> 8.1.0 |
| Database | PostgreSQL 17 |
| Search | Elasticsearch 8.16.0 via Searchkick |
| Asset Pipeline | Propshaft |
| JS Bundler | esbuild |
| CSS Preprocessor | Sass |
| Front-end | Bootstrap 5.3, Bootstrap Icons, Hotwire (Turbo + Stimulus) |
| Job Queue | Solid Queue |
| Web Server | Puma |
| Mail (dev) | Mailcatcher |

### Notable Gems

- **Auth**: `devise`, `omniauth` (Facebook, Twitter)
- **Authorization**: `cancancan`
- **Search**: `searchkick` + `elasticsearch`
- **Tagging**: `acts-as-taggable-on`
- **Pagination**: `pagy`
- **Forms**: `simple_form`
- **Markdown**: `redcarpet`, `pygments.rb`
- **Images**: `image_processing` (libvips), `active_storage_validations`
- **Views**: `slim-rails`
- **View Counting**: `impressionist`
- **Job Monitoring**: `mission_control-jobs` (mounted at `/mission_control/jobs`, admin-only)
- **JSON Responses**: `responders`

## Project Structure

```
app/
  controllers/          # Standard Rails controllers (questions, answers, comments, votes, users, etc.)
  models/               # Active Record models with concerns in concerns/
  views/                # Slim templates
  helpers/              # View helpers (single application_helper.rb)
  jobs/                 # Solid Queue jobs (daily digest, subscriber notifications)
  mailers/              # Action Mailer classes
  javascript/           # Entry point + Stimulus controllers
  assets/stylesheets/   # Sass files (application.sass.scss, plus per-feature files)
  assets/builds/        # esbuild / Sass output (checked in or generated)
  channels/             # Action Cable channels (if any)
config/
  initializers/         # Standard Rails initializers (devise, simple_form, bullet, etc.)
  environments/         # development.rb, test.rb, production.rb
db/
  migrate/              # Migration files (legacy, many from 2015–2016)
  schema.rb
spec/
  models/               # RSpec model specs
  system/               # Capybara system (feature) specs
  jobs/                 # Job specs
  mailers/              # Mailer specs
  factories/            # FactoryBot definitions
  support/              # SimpleCov config, Searchkick test helpers, OmniAuth macros
```

### Domain Model

Core entities and their relationships:

- **User** — has many questions, answers, comments, votes, subscriptions, authorizations.
- **Question** — belongs to user, has many answers/comments/subscriptions, acts_as_taggable, searchable via Searchkick.
- **Answer** — belongs to question and user, has many comments, can be marked "best".
- **Comment** — polymorphic (`commentable`) on questions and answers.
- **Vote** — polymorphic (`votable`) on questions and answers; tracks up/down votes.
- **Subscription** — users subscribe to questions for notifications.
- **Authorization** — stores OmniAuth provider data.

## Build & Development Commands

### Docker Development (Preferred)

The project uses **Dip** (`dip.yml`) + Docker Compose (`.dockerdev/compose.yml`) for development.

```bash
# One-time provisioning
dip provision

# Start Rails server (with deps)
dip rails s

# Or start the full web stack (server + watchers)
dip up web

# Rails console
dip rails c

# Database console
dip psql

# Run migrations
dip rails db:migrate

# Install Ruby gems
dip bundle install

# Install JS packages
dip yarn install
```

### Local Development (without Docker)

```bash
# Install dependencies
bundle install
yarn install

# Setup database & search index
bin/setup

# Start dev server (Foreman reads Procfile.dev)
bin/dev
```

`Procfile.dev` runs three processes:
- `web: bin/rails server -p 3000 -b 0.0.0.0`
- `js: yarn build --watch`
- `css: yarn build:css --watch`

### Asset Building

```bash
# JavaScript (esbuild)
yarn build
# => bundles app/javascript/*.* into app/assets/builds/

# CSS (Sass)
yarn build:css
# => compiles app/assets/stylesheets/application.sass.scss to app/assets/builds/application.css
```

## Testing

### Running Tests

**Always use Dip for running specs.** This ensures the test environment has the correct dependencies (PostgreSQL, Elasticsearch) and environment variables.

```bash
# Run full suite
dip rspec

# Run a specific spec file or directory
dip rspec spec/system/
dip rspec spec/models/question_spec.rb
```

Only fall back to local execution if you are deliberately running outside Docker and have all services running locally:

```bash
# Local (not recommended unless services are running locally)
bundle exec rspec
```

### Test Setup

- **Framework**: RSpec Rails
- **System tests**: Cuprite (headless Chrome) via `capybara/cuprite`
- **Factories**: FactoryBot (definitions in `spec/factories/`)
- **Matchers**: `shoulda-matchers`, `cancan/matchers`
- **Coverage**: SimpleCov with minimum thresholds — **92% line coverage**, **68% branch coverage**
- **Profiler**: `test-prof` (`let_it_be` enabled)
- **N+1 Detection**: Bullet (runs in development and test)

### Test Configuration Files

- `.rspec` — color output, requires `spec_helper`, uses Fuubar formatter
- `spec/rails_helper.rb` — loads Rails, support files, FactoryBot methods, OmniAuth macros, reindexes Searchkick before suite
- `spec/system_helper.rb` — Capybara + Cuprite config for system specs
- `spec/support/searchkick.rb` — disables Searchkick callbacks by default; enable per-example with `search: true`
- `spec/support/simplecov.rb` — starts SimpleCov with branch coverage
- `spec/support/omniauth_macros.rb` — helpers for OmniAuth test mode

### Test Types Present

| Directory | Type |
|-----------|------|
| `spec/models/` | Unit tests (validations, associations, scopes, abilities) |
| `spec/system/` | End-to-end browser tests (user flows for questions, answers, comments, votes, auth, profiles) |
| `spec/jobs/` | Background job tests |
| `spec/mailers/` | Mailer tests |

No controller/request specs exist in the codebase despite the generator configuration permitting controller specs.

### Writing New Tests

- Use `frozen_string_literal: true` at the top of new spec files.
- System specs live in `spec/system/` and are organized by feature (e.g., `spec/system/questions/user_asks_question_spec.rb`).
- Model specs live in `spec/models/`.
- If a test needs Searchkick callbacks, tag it with `search: true`:
  ```ruby
  it 'finds questions', search: true do
    # ...
  end
  ```
- Use FactoryBot factories from `spec/factories/`.
- OmniAuth is in test mode; use macros from `spec/support/omniauth_macros.rb`.

## Code Style Guidelines

### RuboCop

- Config: `.rubocop.yml` (inherits from `.rubocop_todo.yml`)
- Plugins: `rubocop-rails`
- **Line length max**: 120
- **Excluded from linting**: `bin/`, `config/`, `db/`, `node_modules/`, `spec/spec_helper.rb`, `spec/rails_helper.rb`
- **Block length**: excluded in `spec/`
- **Documentation**: disabled (`Style/Documentation: false`)

Run linting:
```bash
bundle exec rubocop
```

### Conventions Observed

- All Ruby files use `# frozen_string_literal: true`.
- Controllers use `before_action` filters and strong parameters.
- Models place business logic in private methods; shared behavior lives in `app/models/concerns/`.
- Views are written in **Slim**.
- Routes use `concern` for reusable route patterns (`:commentable`, `:votable`).

### Generators

`config/application.rb` configures generators:
- Test framework: RSpec
- Fixtures enabled; fixture replacement: FactoryBot (dir: `spec/factories`)
- Disabled by default: view specs, helper specs, routing specs, request specs
- Enabled: controller specs

## Security Considerations

- **Brakeman** is included for static security analysis (`bundle exec brakeman`).
- **Devise** handles authentication with confirmable and OAuth callbacks.
- **CanCanCan** (`Ability` model) manages authorization.
- **Mission Control Jobs** is mounted at `/mission_control/jobs` and restricted to admin users.
- **Active Storage** is used for avatars; validations are enforced via `active_storage_validations`.
- **Bullet** runs in development/test to catch N+1 queries.
- Filtered parameters and CSP are configured in `config/initializers/`.

## Environment & Services

### Required Environment Variables

The app relies on typical Rails env vars plus:
- `DATABASE_URL` — PostgreSQL connection string (used in `config/database.yml`)
- `ELASTICSEARCH_URL` — Elasticsearch endpoint (e.g., `http://elasticsearch:9200`)
- `RAILS_HOSTNAME` — host for mailer URLs (defaults to `localhost:3000`)

### Docker Services (`.dockerdev/compose.yml`)

| Service | Purpose | Exposed Port |
|---------|---------|--------------|
| `web` | Rails server + Foreman | `3000` |
| `rails` | Rails CLI runner | — |
| `jobs` | Solid Queue worker (`bin/jobs`) | — |
| `postgres` | PostgreSQL 17 | `5432` |
| `elasticsearch` | Elasticsearch 8.16.0 | `9200` |
| `mailcatcher` | SMTP catch + web UI | `1080` |

### Time Zone

Application time zone is set to **Moscow** (`config.time_zone = 'Moscow'`).

## Deployment

A production `Dockerfile` exists in the project root. It:
- Builds from the official Ruby image
- Installs libvips for image processing
- Installs Node.js and Yarn
- Installs Bundler
- Copies the application code into `/usr/src/app`

No CI/CD configuration (e.g., GitHub Actions) is present in the repository.

## Quick Reference

```bash
# Full Docker setup
dip provision

# Start server
dip rails s

# Run all tests (use dip — required for correct test environment)
dip rspec

# Run single spec or directory
dip rspec spec/models/question_spec.rb
dip rspec spec/system/

# Lint
bundle exec rubocop

# Security scan
bundle exec brakeman

# Reindex search
dip rails searchkick:reindex:all

# DB console
dip psql
```
