# Heap Overflow — Agent Guide

A Stack Overflow clone used as a sandbox for modern Rails. Users ask & answer questions, comment on both, vote, subscribe to threads, and authenticate via email or OAuth (Facebook / Twitter). Not intended for production.

## Stack

| Layer | Choice |
|---|---|
| Ruby | 4.0.4 (`.ruby-version`) |
| Rails | ~> 8.1.3 (defaults `8.1`) |
| Database | PostgreSQL 17 |
| Search | Elasticsearch 9.4.0 via `searchkick` |
| Background jobs | Solid Queue (DB-backed) |
| Web server | Puma |
| Asset pipeline | Propshaft |
| JS bundler | esbuild (`jsbundling-rails`) |
| CSS | Sass + Bootstrap 5.3 (`cssbundling-rails`) |
| Front-end | Hotwire (Turbo + Stimulus), Bootstrap Icons |
| Templates | Slim |
| Node | 24 |
| Dev SMTP UI | Mailcatcher (`:1080`) |

### Notable gems

- **Auth**: `devise` (with confirmable, trackable, recoverable) + `omniauth` / `omniauth-facebook` / `omniauth-twitter`
- **Authorization**: `action_policy`
- **Service layer**: `dry-initializer` (positional `param :foo` declarations + `self.call(...) = new(...).call`)
- **Pagination**: `pagy` (offset extension; also `pagy/searchkick`)
- **Tagging**: `acts-as-taggable-on`
- **Markdown**: `redcarpet` + `pygments.rb` for code highlighting
- **Forms**: `simple_form` (Bootstrap integration)
- **JSON/HTML responders**: `responders` via custom `ApplicationResponder`
- **View counting**: `impressionist` (counter_cache on `Question`)
- **Images**: `image_processing` (libvips) + `active_storage_validations`
- **Job UI**: `mission_control-jobs` at `/mission_control/jobs` (admin-gated route)
- **After-commit hooks**: `after_commit_everywhere` (used in `Answers::Create`)
- **Testing**: `rspec-rails`, `factory_bot_rails`, `cuprite`, `shoulda-matchers`, `capybara-email`, `test-prof` (`let_it_be`), `simplecov`, `fuubar`, `faker`
- **Dev tooling**: `bullet`, `rack-mini-profiler`, `brakeman`, `rubocop` + `rubocop-rails`, `web-console`, `dotenv-rails`

## Architecture

### Domain model

| Model | Notes |
|---|---|
| `User` | Devise (database + confirmable + OmniAuth). `has_one_attached :avatar` with `:medium` (320²) and `:thumb` (100²) variants. `searchkick searchable: [:full_name]`. `is_impressionable`. Admin flag (`admin`). Has helpers `author_of?`, `vote_up?`, `vote_down?` (accept a preloaded vote collection to avoid N+1). |
| `Question` | `belongs_to :user`; `has_many :answers, :comments, :subscriptions`. `acts_as_taggable`. `searchkick searchable: %i[title body]`. `is_impressionable counter_cache: true, unique: :session_hash`. `answers_count` counter cache. Scope `created_last_24_hours`. Title 10–200, body 10–3000, `tag_list` required. Includes `HasVotes`. |
| `Answer` | `belongs_to :question` (counter_cache) and `:user`. Polymorphic `has_many :comments`. `best` boolean flag (only one per question — enforced via `Answers::MarkBest`). `searchkick searchable: [:body]`. Includes `HasVotes`. |
| `Comment` | Polymorphic on `commentable` (Question or Answer). `searchkick searchable: [:body]`. Body 5–200. |
| `Vote` | Polymorphic on `votable` (Question or Answer). `value` is +1 / -1. Unique per `(user, votable_id, votable_type)`. |
| `Subscription` | `User` ↔ `Question`. Author is auto-subscribed in `Questions::Create`. Unique per pair. |
| `Authorization` | Stores `provider` + `uid` for an OAuth identity tied to a `User`. |

`app/models/concerns/has_votes.rb` is the only model concern. It mixes in `has_many :votes, as: :votable` plus a `with_votes_sum` scope that adds a `COALESCE(SUM(votes.value), 0) AS votes_sum` column via `left_joins(:votes).group(table_name.id)`. The instance method `#votes_sum` reads that aliased column when present, otherwise falls back to a query. The questions index uses this to sort/display vote totals without N+1.

`ApplicationRecord` defines a single shared scope: `newest` (`order(created_at: :desc)`).

### Service layer (`app/services/`)

All services inherit from `ApplicationService`:

```ruby
class ApplicationService
  extend Dry::Initializer
  def self.call(...) = new(...).call
end
```

Conventions:
- Positional args via `param :name` (no `option`/kwargs in the current codebase).
- `#call` does the work and returns the relevant resource.
- Transactions wrap multi-step writes; side effects (jobs, mailers) deferred via `after_commit { ... }` from `after_commit_everywhere`.

Existing services:
- `Questions::Create(params, author)` — creates the question and auto-subscribes the author inside one transaction.
- `Answers::Create(params, author, question)` — creates the answer and enqueues `NotifySubscribersJob` *after* the DB commits.
- `Answers::MarkBest(answer)` — atomically clears any other `best: true` answer on the same question and marks this one.
- `Oauth::FindOrCreateUser(auth)` — three-branch resolution: existing `Authorization` ⇒ its user; OAuth payload missing email ⇒ unsaved `User.new` (controller renders the "ask for email" form); otherwise `find_or_create_by!(email: …)` + create an `Authorization`. Skips Devise confirmation when credentials are present.

### Controllers

- `ApplicationController` includes `ActiveStorage::SetCurrent` and `Pagy::Method`. Sets `ApplicationResponder` (`responders` gem + flash + HTTP cache). Rescues `ActionPolicy::Unauthorized` → JSON `{ error: … }` with `401`. Permits Devise params (`full_name`, `email`, `password`, `password_confirmation`).
- Resource controllers (`questions`, `answers`, `comments`, `votes`, `subscriptions`) follow the same pattern: `before_action :authenticate_user!` (except read-only question actions), `authorize!` via Action Policy, then either render Turbo Stream views or call a service object. The questions controller uses `Question.with_votes_sum.newest.includes(:tags, :user)` everywhere it lists.
- `VotesController` resolves the votable from `params[:question_id]` or `params[:answer_id]` (single endpoint, two parents) and authorizes against `vote_up?` / `vote_down?` on the parent record.
- `OmniauthCallbacksController#facebook` is aliased as `#twitter`. If `Oauth::FindOrCreateUser` returns an unsaved user, it stashes the auth payload in the session and renders `omniauth/get_email`; the route `POST /users/auth/twitter` is mapped explicitly because Twitter omniauth needs a POST callback.
- `SearchController#search` paginates a multi-model `Searchkick.pagy_search(query, models: [Question, Answer])` with `limit: 15`.

### Authorization (`app/policies/`)

Action Policy with `authorize :user, optional: true`. `ApplicationPolicy` sets `default_rule :manage?`, where `manage?` returns `user&.admin? || false`. Helpers: `user?` (signed-in) and `author?` (`user.author_of?(record)`).

Resource policies:
- `QuestionPolicy` — show/index/tagged public; create/new requires sign-in; update/destroy/edit allowed for admin or author; `vote_up?` / `vote_down?` require signed-in and not author.
- `AnswerPolicy` — same shape; `best?` allowed for admin or for the author of the question.
- `CommentPolicy`, `SubscriptionPolicy`, `UserPolicy` — same conventions.

### Routes (`config/routes.rb`)

```text
root            → questions#index
GET  /search    → search#search
DELETE /vote, PATCH /vote/up|down (concern :votable on questions + answers)
resources :comments (concern :commentable)
resources :questions
  GET /questions/tagged/:tag (collection)
  resources :answers, shallow: true (+ PATCH :best)
  resource :subscription (create/destroy)
resources :users / resource :avatar
resources :tags (index only)
mount MissionControl::Jobs::Engine at /mission_control/jobs  (admin-only via `authenticate :user, ->(u) { u.admin? }`)
```

### Views

- Slim throughout. Layout in `app/views/layouts/application.html.slim` + header/footer/flash partials.
- Devise views are customized under `app/views/devise/`.
- Turbo Stream responses (`*.turbo_stream.slim`) drive most write actions for questions, answers, comments, votes, subscriptions, avatars.
- `MarkdownPresenter` renders bodies — Redcarpet (`autolink`, `fenced_code_blocks`, `strikethrough`, `superscript`, `filter_html: true`) with a custom HTML renderer that pipes code blocks through Pygments.

### JavaScript

- Entry point `app/javascript/application.js` imports Turbo, the Stimulus controllers, and Bootstrap.
- Stimulus controllers registered in `app/javascript/controllers/index.js`: `form` and `avatar-uploader`. The Stimulus manifest is auto-generated; re-run `bin/rails stimulus:manifest:update` after adding controllers.

### Jobs & mailers

- Solid Queue (`config.active_job.queue_adapter = :solid_queue`). Worker started by `bin/jobs` (and the `jobs` service in compose).
- `NotifySubscribersJob` (enqueued after an `Answer` commit) — emails every subscriber via `Mailer#notify`.
- `DailyDigestJob` — iterates `User.find_each` and mails the day's `Question.created_last_24_hours` via `DailyMailer#digest`. Scheduled via `config/recurring.yml` at `0 9 * * *`.

### Configuration highlights

- `config.time_zone = 'Moscow'` (`config/application.rb`).
- `config.autoload_lib(ignore: %w[assets tasks])`.
- Generators: RSpec, FactoryBot (`spec/factories`), with view/helper/routing/request specs **off** and controller specs **on** by default — but the codebase ships **no controller or request specs** (system specs cover behavior end-to-end).
- Bullet is enabled **in development only** (initializer guards on `Rails.env.development?`).
- Sample configs live in `config/database.yml.sample` and `config/storage.yml.sample`; real ones are gitignored (CI copies the samples).

## Project layout

```
app/
  controllers/        # one per resource; concerns/ is empty
  models/             # AR models + concerns/has_votes.rb
  services/           # ApplicationService base + answers/ oauth/ questions/
  policies/           # action_policy subclasses
  presenters/         # MarkdownPresenter
  jobs/               # ApplicationJob + DailyDigestJob + NotifySubscribersJob
  mailers/            # ApplicationMailer + Mailer + DailyMailer
  views/              # slim templates (HTML + Turbo Stream)
  javascript/         # entry + Stimulus controllers
  assets/stylesheets/ # Sass sources; builds/ is generated
  channels/           # empty (ActionCable plumbing only)
config/
  initializers/       # devise, simple_form, bullet, pagy, content_security_policy, …
  recurring.yml       # Solid Queue cron tasks
  queue.yml           # Solid Queue worker config
db/
  migrate/            # historical migrations (some from 2015–2016)
  schema.rb           # current schema (Rails 8.1 format)
lib/
  application_responder.rb   # FlashResponder + HttpCacheResponder
  tasks/                     # custom rake tasks (autoload ignored)
  templates/                 # generator templates (autoload ignored)
spec/
  models/ jobs/ mailers/ policies/ presenters/ services/ system/
  factories/                 # one file per model
  support/                   # simplecov, searchkick test wiring, omniauth_macros
  rails_helper.rb            # adds action_policy/rspec, let_it_be, omniauth test mode
  system_helper.rb           # Cuprite driver + Capybara host wiring
```

## Common commands

The project's primary dev workflow is **Dip** (a thin Docker Compose wrapper). Local-on-host workflow works too if you have PostgreSQL, Elasticsearch, and Node available.

### Dip / Docker (preferred)

```bash
dip provision                 # first-time: build image, start pg, run bin/setup
dip rails s                   # web server at http://localhost:3000 (uses the `web` service for port mapping)
dip up web                    # start web stack in the background
dip rails c                   # console
dip rails db:migrate          # any rails subcommand
dip rspec                     # full test suite (RAILS_ENV=test is set by the dip interaction)
dip rspec spec/models/question_spec.rb        # single file
dip rspec spec/system/questions/user_asks_question_spec.rb:42   # single example by line
dip rubocop                   # lint (no deps needed)
dip psql                      # postgres console (defaults to heapoverflow_development)
dip bundle install
dip yarn install
dip down                      # stop all containers
```

`dip rails s` is a special subcommand that swaps the service to `web` so port 3000 is published.

### Local (no Docker)

```bash
bundle install
yarn install
bin/setup            # copies sample configs, db:prepare, db:test:prepare, searchkick:reindex:all
bin/dev              # foreman: web + js watch + css watch (per Procfile.dev)
bundle exec rspec
bundle exec rubocop
bundle exec brakeman -q -w2 -z
```

### Asset builds

```bash
yarn build           # esbuild app/javascript/*.* → app/assets/builds/
yarn build:css       # sass app/assets/stylesheets/application.sass.scss → app/assets/builds/application.css
```

`Procfile.dev` runs both watchers alongside the Rails server.

### Useful Rails tasks

```bash
dip rails searchkick:reindex:all     # rebuild Elasticsearch indices
dip rails stimulus:manifest:update   # after adding a Stimulus controller
dip rails db:prepare                 # create + migrate, idempotent
```

## Testing

- **Framework**: RSpec Rails. `.rspec` requires `spec_helper` and uses the Fuubar formatter with color output.
- **System tests**: Cuprite (headless Chrome). `spec/system_helper.rb` registers `:cuprite_chrome` (window 1400×1400, `--no-sandbox`, `process_timeout: 60` when `CI` is set), binds Capybara to `0.0.0.0:31337`, and sets `Capybara.app_host` to the hostname so the dockerized app can reach itself.
- **Coverage** (`spec/support/simplecov.rb`): `SimpleCov.start('rails')` with `enable_coverage :branch`. **Minimum thresholds: 92% line, 68% branch** — a passing assertion run will still fail if coverage drops below this.
- **`test-prof`'s `let_it_be`** is required globally; prefer it over `let!` for records that don't need per-example mutation.
- **`shoulda-matchers`** is wired to `:rspec` + `:rails`.
- **Action Policy** RSpec DSL is loaded — `spec/policies/` uses its `describe_rule`/`succeed`/`failed` matchers.
- **OmniAuth** is in test mode globally; `spec/support/omniauth_macros.rb` provides `mock_auth_hash` (mocks Facebook + Twitter).
- **Searchkick** (`spec/support/searchkick.rb`): before the suite, runs `searchkick:reindex:all` then `Searchkick.disable_callbacks`. To re-enable callbacks for one example, tag it `search: true`:
  ```ruby
  it 'finds questions', search: true do
    # …
  end
  ```
- **Factories**: one file per model in `spec/factories/`. `FactoryBot::Syntax::Methods` included.
- **System helper extras**: includes `Warden::Test::Helpers` and `ApplicationHelper` into system specs, and reassigns `Rails.application.default_url_options[:host]` to Capybara's host around each example.

### What's covered

| Dir | Type |
|---|---|
| `spec/models/` | validations, associations, scopes |
| `spec/policies/` | Action Policy rules (`describe_rule`) |
| `spec/services/` | service-object unit tests |
| `spec/presenters/` | `MarkdownPresenter` rendering |
| `spec/jobs/` | enqueue + perform behavior |
| `spec/mailers/` | mailer rendering & recipients |
| `spec/system/` | end-to-end Capybara/Cuprite flows, grouped by feature area (`auth/`, `questions/`, `answers/`, `users/`) |

There are **no `spec/controllers/` or `spec/requests/`** — controller behavior is exercised via system specs.

### Writing new tests

- Always add `# frozen_string_literal: true` (RuboCop will flag otherwise).
- Feature/system specs go under `spec/system/<area>/user_<verb>_<noun>_spec.rb`.
- Use FactoryBot factories; prefer `let_it_be` for fixtures shared across examples in a group.
- Tag tests that depend on real Elasticsearch indexing with `search: true`.

## Code style

- RuboCop config in `.rubocop.yml`, with autogen exclusions in `.rubocop_todo.yml`.
- Plugin: `rubocop-rails`.
- **Line length: 120**.
- Excluded paths: `bin/*`, `config/**/*`, `db/**/*`, `node_modules/**/*`, `spec/spec_helper.rb`, `spec/rails_helper.rb`.
- `Metrics/BlockLength` excluded from `spec/**/*`.
- `Style/Documentation` disabled.

Observed conventions in the codebase:
- All Ruby files start with `# frozen_string_literal: true`.
- Controllers stick to `before_action` filters and strong params; non-trivial writes delegate to a service.
- Slim for templates; `simple_form` for forms; turbo_stream views per write action.
- Routes use Rails concerns (`:commentable`, `:votable`) for shared subroutes.
- Private helpers stay private; shared model behavior goes to `app/models/concerns/`.

## Security & ops

- **Brakeman** runs in CI (`-q -w2 -z`); also available locally via `dip brakeman` (or `bundle exec brakeman` outside Docker).
- **Devise** confirmable handles email verification; OAuth callbacks short-circuit confirmation when credentials are present.
- **Action Policy** is enforced in every write action; `ApplicationPolicy#manage?` is the admin escape hatch.
- **Mission Control** is wrapped in `authenticate :user, ->(u) { u.admin? }`, so only admin users can reach `/mission_control/jobs`.
- **CSP**, **filtered parameter logging**, and **permissions policy** are configured under `config/initializers/`.
- **Bullet** runs in development only (alerts on N+1 / unused eager loading / counter caches).

## Environment variables

The compose stack and CI set these:

| Var | Used for |
|---|---|
| `DATABASE_URL` | PostgreSQL connection (dev defaults to `postgresql://postgres:postgres@postgres:5432`) |
| `ELASTICSEARCH_URL` | Searchkick endpoint (dev: `http://elasticsearch:9200`) |
| `RAILS_ENV`, `NODE_ENV` | standard |
| `WEB_CONCURRENCY`, `JOB_CONCURRENCY` | Puma / Solid Queue worker counts |
| `BOOTSNAP_CACHE_DIR`, `XDG_DATA_HOME`, `YARN_CACHE_FOLDER` | container caches |

Local-only `.env` files are loaded eagerly via `dotenv-rails` (`require: 'dotenv/load'`).

## Docker services

`.dockerdev/compose.yml`:

| Service | Role | Ports |
|---|---|---|
| `rails` | Rails CLI runner (default Dip target) | — |
| `web` | `bin/dev` (Foreman: server + watchers) | `3000` |
| `jobs` | `bin/jobs` (Solid Queue supervisor) | — |
| `postgres` | PostgreSQL 17 | `5432` |
| `elasticsearch` | Elasticsearch 9.4.0 (single-node, security off, 500M cap) | `9200` |
| `mailcatcher` | SMTP + web UI | `1080` |

Both DB and Elasticsearch are gated by healthchecks; backend services `depends_on` them with `condition: service_healthy`.

## CI/CD

`.github/workflows/ci.yml` runs on push to `master` and on every PR. Steps:

1. Checkout
2. Install `libvips42`
3. Setup Ruby from `.ruby-version` (with bundler cache)
4. Setup Node 24 (with yarn cache)
5. `yarn install --frozen-lockfile`
6. Copy `config/{database,storage}.yml.sample` → real configs
7. `yarn build` + `yarn build:css`
8. `bin/rails db:create db:schema:load`
9. `bin/rails searchkick:reindex:all`
10. `bundle exec rubocop`
11. `bundle exec brakeman -q -w2 -z`
12. `bundle exec rspec`

Services in CI: `postgres:17` and `elasticsearch:9.4.0` as GitHub Actions service containers, reachable at `localhost:5432` / `localhost:9200`.

## Quick reference

```bash
dip provision                                 # one-time setup
dip rails s                                   # dev server
dip rspec                                     # tests
dip rspec spec/models/question_spec.rb        # single file
dip rspec spec/system/                        # one directory
dip rubocop                                   # lint
dip brakeman                                  # security scan (add `-q -w2 -z` to mirror CI)
dip rails searchkick:reindex:all              # rebuild search indices
dip psql                                      # db console
dip rails c                                   # rails console
```
