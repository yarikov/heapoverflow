# Heap Overflow — Agent Guide

Heap Overflow is a Stack Overflow clone built with Ruby on Rails. It is a Q&A web application where users can ask questions, post answers, leave comments, vote on content, subscribe to questions, and authenticate via OAuth.

This document is written for AI coding agents. It assumes you know nothing about the project.

---

## Technology Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Language | Ruby | 4.0.4 |
| Framework | Rails | ~> 8.0.0 |
| Frontend bundler | esbuild | ^0.24.0 |
| CSS compiler | Sass | ^1.81.0 |
| JavaScript framework | Turbo + Stimulus (Hotwire) | — |
| CSS framework | Bootstrap | 5.3.3 |
| Database | PostgreSQL | 17.1 |
| Cache / Action Cable | Redis | 7 (via Docker) |
| Search | Elasticsearch | 8.16.0 |
| Background jobs | Solid Queue | ~> 1.0.2 |
| Job monitoring | Mission Control Jobs | ~> 0.6.0 |
| Authentication | Devise + OmniAuth | — |
| Authorization | CanCanCan | ~> 3.6.1 |
| Templating | Slim | via `slim-rails` |
| Testing | RSpec + Capybara (Cuprite) | — |

---

## Project Structure

Standard Rails 8 layout with a few conventions:

```
app/
  controllers/        # Standard RESTful controllers + OAuth callbacks
  models/             # Active Record models + `ability.rb` (CanCanCan)
    concerns/         # Shared model logic, e.g. `HasVotes`
  views/              # Slim templates, organized by controller/resource
  javascript/         # ES modules; entry point is `application.js`
    controllers/      # Stimulus controllers
  assets/stylesheets/ # Sass entry point: `application.sass.scss`
  jobs/               # Active Job classes backed by Solid Queue
  mailers/            # Action Mailer classes
  channels/           # Action Cable (minimal usage)

spec/
  models/             # Model specs
  system/             # End-to-end Capybara system specs
  factories/          # FactoryBot factories
  support/            # RSpec helpers and shared configuration

config/
  routes.rb           # Route definitions
  database.yml        # PostgreSQL via `DATABASE_URL`
  cable.yml           # Redis adapter in dev/prod, `:test` in test

lib/
  application_responder.rb  # Custom responder from `responders` gem
```

### Key Models

- `User` — Devise-managed, supports local + OAuth (Facebook, Twitter) auth, has attached `avatar` via Active Storage.
- `Question` — `acts_as_taggable`, `is_impressionable`, searchable via Searchkick.
- `Answer` — belongs to a Question, can be marked `best`.
- `Comment` — polymorphic (`commentable`), belongs to User.
- `Vote` — polymorphic (`votable`), values `+1` / `-1`.
- `Subscription` — User subscribes to a Question.
- `Authorization` — stores OAuth provider + UID for a User.

### Controllers of Note

- `ApplicationController` — sets `ApplicationResponder`, includes `Pagy::Backend`, enables `check_authorization` (CanCanCan), rescues `CanCan::AccessDenied` with JSON `401`.
- `QuestionsController` — `impressionist` gem for view counting.
- `OmniauthCallbacksController` — handles OAuth flows.
- `VotesController` — up / down / destroy votes on Questions and Answers.
- `SearchController` — global search via Searchkick across Questions and Answers.

---

## Build, Run, and Test Commands

The project is fully containerized with Docker Compose. The `Makefile` provides shortcuts.

### Setup (first time)

```bash
make setup
```

This runs:
1. `docker compose build web`
2. `docker compose run -it --rm web bin/setup`
3. `docker compose up`

`bin/setup` installs gems, JS dependencies, copies sample configs, prepares the database, reindexes Elasticsearch, and clears logs.

### Daily Development

```bash
make run        # docker compose up — starts all services
make bash       # docker compose run -it --rm web bash
make c          # docker compose run -it --rm web bin/rails c
```

### Asset Building

Inside the web container (or locally if dependencies are installed):

```bash
yarn build          # esbuild JS bundles → app/assets/builds/
yarn build:css      # Sass compile → app/assets/builds/application.css
```

In development, `Procfile.dev` runs both with `--watch` alongside the Rails server.

### Testing

All specs are RSpec. Run them inside the web container:

```bash
bin/rspec                    # entire suite
bin/rspec spec/models        # unit tests only
bin/rspec spec/system        # system (E2E) tests only
```

System specs use **Cuprite** (headless Chrome) talking to a `chrome` service at `http://chrome:4444`.

### Code Quality / Linting

```bash
bin/rubocop                  # lint Ruby code
bin/brakeman                 # static security analysis
```

---

## Development Conventions

### Ruby Style

- **Frozen string literals** are enforced: `# frozen_string_literal: true` at the top of every Ruby file.
- **RuboCop** is configured in `.rubocop.yml`:
  - Max line length: **120** characters.
  - `Style/Documentation` is **disabled** — do not write YARD or file-level documentation comments.
  - `Metrics/BlockLength` is excluded from `spec/**/*`.
  - Excluded paths: `bin/*`, `config/**/*`, `db/**/*`, `node_modules/**/*`, `spec/spec_helper.rb`, `spec/rails_helper.rb`.
- Inherit from `.rubocop_todo.yml` for legacy offenses.

### Rails Generators

`config/application.rb` configures generators:

```ruby
g.test_framework :rspec,
  fixtures: true,
  view_spec: false,
  helper_specs: false,
  routing_specs: false,
  request_specs: false,
  controller_spec: true
g.fixture_replacement :factory_girl, dir: 'spec/factories'
```

Prefer **system specs** over controller/request specs for new features.

### Views

- Templates are written in **Slim**.
- Layout is `app/views/layouts/application.html.slim` with a dark Bootstrap theme (`data-bs-theme="dark"`).
- Shared partials live in `app/views/common/` and `app/views/layouts/`.

### JavaScript / Stimulus

- Entry point: `app/javascript/application.js`
- Stimulus controllers live in `app/javascript/controllers/`
- Only three custom controllers exist at the time of writing: `avatar_uploader`, `form`, and the auto-loaded `application` controller.
- Bootstrap JS is imported as a module.

### Database & Migrations

- PostgreSQL is the only supported adapter.
- `DATABASE_URL` is required; `config/database.yml` reads from the environment.
- Do not edit `db/schema.rb` by hand; it is auto-generated.

### Background Jobs

- `config.active_job.queue_adapter = :solid_queue`
- Jobs run in a separate `jobs` Docker service (`bin/jobs`).
- `MissionControl::Jobs` mount point is at `/mission_control/jobs` and is restricted to admin users.

### Search & Indexing

- `searchkick` gem provides Elasticsearch integration.
- Searchkick callbacks are **disabled globally in the test suite** (`spec/support/searchkick.rb`).
- To test search behavior, tag the example with `search: true`:
  ```ruby
  it 'finds questions', search: true do
    # ...
  end
  ```
- Run `bin/rails searchkick:reindex:all` after setup or when seeding data.

---

## Testing Strategy

### Test Types

1. **Model specs** (`spec/models/`) — unit tests for validations, associations, scopes, and business logic. Use FactoryBot and Shoulda Matchers.
2. **Controller specs** (`spec/controllers/`) — legacy style, lightweight HTTP tests. New features should prefer system specs.
3. **System specs** (`spec/system/`) — full-browser integration tests using Capybara + Cuprite.

### Test Configuration

- `spec/rails_helper.rb` loads the Rails environment, SimpleCov, and support files.
- `spec/spec_helper.rb` keeps the global RSpec configuration lightweight.
- `spec/system_helper.rb` configures Cuprite to talk to the remote Chrome container.
- `ActiveRecord::Migration.maintain_test_schema!` ensures the test schema is current.
- Transactional fixtures are enabled (`config.use_transactional_fixtures = true`).

### Factories

Factories live in `spec/factories/`. A `user_with_profile` factory and a `:reindex` trait (for Searchkick) are available.

### Coverage

SimpleCov is enabled with a **minimum coverage gate**:
- Line coverage: **92%**
- Branch coverage: **68%**

Falling below these thresholds will fail the test suite.

### Running System Tests Locally (without Docker)

If you run tests outside Docker, ensure `CHROME_URL` points to a running Chrome instance, or override the driver registration in `spec/system_helper.rb`.

---

## Security Considerations

- **CanCanCan** is used for all authorization. `ApplicationController` calls `check_authorization` unless the controller is a Devise or MissionControl controller.
- **CSRF protection** is enabled (`protect_from_forgery with: :exception`).
- **Brakeman** is run periodically. Two XSS warnings are currently ignored in `config/brakeman.ignore` (marked as weak confidence).
- **CSP** is relied upon for some XSS mitigations (see brakeman ignore notes).
- Active Storage validations restrict avatars to `image/png`, `image/jpg`, `image/jpeg` and a max size of **2 MB**.
- OAuth secrets are expected to come from environment variables (managed via `dotenv-rails`).

---

## Deployment & Infrastructure

### Docker Services

The `docker-compose.yml` defines:

| Service | Purpose | Exposed Port |
|---------|---------|-------------|
| `web` | Rails app + asset watchers | `3000` |
| `jobs` | Solid Queue worker process | — |
| `postgres` | PostgreSQL database | — |
| `redis` | Redis (cache / Action Cable) | — |
| `elasticsearch` | Elasticsearch search engine | `9200` |
| `mailcatcher` | Dev email trap | `1080` |
| `chrome` | Headless Chrome for system tests | `4444` |

### Environment Variables

| Variable | Purpose |
|----------|---------|
| `DATABASE_URL` | PostgreSQL connection string |
| `REDIS_URL` | Redis connection string |
| `ELASTICSEARCH_URL` | Elasticsearch endpoint |
| `RAILS_HOSTNAME` | Host used in mailer URLs (default: `localhost:3000`) |
| `CHROME_URL` | Remote Chrome for Cuprite (default: `http://chrome:4444`) |

### Sample Config Files

- `config/database.yml.sample` → copy to `config/database.yml`
- `config/storage.yml.sample` → copy to `config/storage.yml`

These copies are performed automatically by `bin/setup`.

---

## Common Tasks

### Reindex Search

```bash
bin/rails searchkick:reindex:all
```

### Open Rails Console

```bash
make c
```

### Seed the Database

```bash
bin/rails db:seed
```

The seed script creates 30 users, 100 questions with random answers, comments, votes, and tags using Faker.

### View Emails in Development

Mailcatcher runs at `http://localhost:1080`. All outbound mail in development is captured there.

---

## Important Files for Agents

| File | Why it matters |
|------|---------------|
| `Gemfile` | Source of truth for all Ruby dependencies |
| `package.json` | Source of truth for JS dependencies and build scripts |
| `config/routes.rb` | Defines all URL endpoints and mounted engines |
| `app/models/ability.rb` | Defines authorization rules for guests, users, and admins |
| `app/controllers/application_controller.rb` | Global controller behavior, responder, pagination, auth checks |
| `spec/rails_helper.rb` | Test setup, helpers, and database strategy |
| `spec/system_helper.rb` | Cuprite / Capybara configuration for system tests |
| `spec/support/searchkick.rb` | Disables Searchkick callbacks in tests unless tagged |
| `docker-compose.yml` | All runtime infrastructure and service wiring |
| `Makefile` | Shortcuts for the most common Docker commands |
