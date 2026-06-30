# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

See [`AGENTS.md`](./AGENTS.md) for the full agent guide (tech stack, domain model, gem list, CI pipeline, env vars, deployment). This file captures only the essentials and the things easy to get wrong.

## Common Commands

Development uses **Dip** (Docker Compose wrapper). The Rails CLI, RSpec, and psql all run inside containers — always go through `dip`, never `bundle exec rails ...` directly, unless explicitly working outside Docker.

```bash
dip provision                       # one-time: build image, start pg + elasticsearch, bin/setup
dip rails s                         # start web server at http://localhost:3000
dip rails c                         # Rails console
dip rails db:migrate
dip psql                            # PostgreSQL console (defaults to heapoverflow_development)
dip rspec                           # full test suite
dip rspec spec/models/question_spec.rb       # single file
dip rspec spec/system/questions/user_asks_question_spec.rb:42   # single example by line
dip rails searchkick:reindex:all    # rebuild Elasticsearch indices

dip rubocop                         # lint (no deps needed)
dip brakeman                        # security scan (no deps needed)
```

Mailcatcher UI: http://localhost:1080.

## Architecture Notes

Standard Rails 8 layout (`app/{controllers,models,views,jobs,mailers}`) plus these non-default layers:

- `app/services/` — business logic, grouped by domain (`questions/`, `answers/`, `oauth/`). All inherit from `ApplicationService` which uses `Dry::Initializer` (positional `param :foo`) and exposes `self.call(...) = new(...).call`. Side effects (jobs, mailers) are deferred with `after_commit { ... }` from `after_commit_everywhere` — see `Answers::Create` for the pattern.
- `app/policies/` — Action Policy classes per resource. `ApplicationPolicy` sets `default_rule :manage?` (admin escape hatch via `user&.admin?`) and provides `user?` / `author?` helpers. `ApplicationController` rescues `ActionPolicy::Unauthorized` → **JSON `{ error: … }` with HTTP 401** (not a redirect — this surprises HTML expectations).
- `app/presenters/` — view-side wrappers (currently just `MarkdownPresenter`: Redcarpet + Pygments for code highlighting, `filter_html: true`).
- `app/models/concerns/has_votes.rb` — the only model concern. Mixed into `Question` and `Answer`. Adds `has_many :votes, as: :votable` plus a `with_votes_sum` scope that left-joins votes and aggregates `COALESCE(SUM(votes.value), 0) AS votes_sum`. The questions index relies on it — read `votes_sum` off the loaded record instead of calling `votes.sum`.
- `app/javascript/` — esbuild entry + Stimulus controllers (only `form` and `avatar-uploader` registered). CSS is Sass compiled separately. Both watchers run via `Procfile.dev` when using `bin/dev` locally. Re-run `bin/rails stimulus:manifest:update` after adding a controller.

Polymorphic associations:
- `Comment.commentable` → `Question` or `Answer` (routes via `concern :commentable`).
- `Vote.votable` → `Question` or `Answer` (routes via `concern :votable`; `VotesController` resolves the parent from `params[:question_id]` or `params[:answer_id]`).

Search: `Question`, `Answer`, `Comment`, and `User` are all `searchkick`-indexed. In tests, Searchkick callbacks are **disabled by default** (the suite reindexes once in `before(:suite)`, then calls `Searchkick.disable_callbacks`). Opt in per example with `it '...', search: true do`. `SearchController#search` does a multi-model `Searchkick.pagy_search` over Question + Answer.

Auth: `Devise` (confirmable, trackable, recoverable) + OmniAuth (Facebook, Twitter) with provider data in `Authorization`. `Oauth::FindOrCreateUser` has three branches: existing auth → its user; OAuth payload missing email → unsaved `User.new` (controller renders an "ask for email" form); otherwise `find_or_create_by!(email:)` + create the `Authorization`. The Twitter callback is **`POST`** (explicit route in `config/routes.rb`).

Background jobs: Solid Queue (DB-backed; worker started by `bin/jobs` / the `jobs` compose service). `DailyDigestJob` is scheduled at `0 9 * * *` via `config/recurring.yml`. `NotifySubscribersJob` is enqueued after an `Answer` commits. Mission Control Jobs is mounted at `/mission_control/jobs`, gated to admin users.

Time zone is `Moscow` (`config/application.rb`).

## Testing Conventions

- Framework: RSpec + FactoryBot. System tests use Cuprite (headless Chrome) bound to `0.0.0.0:31337`; `process_timeout` is bumped to 60s when `CI` is set.
- Coverage thresholds enforced by SimpleCov: **92% line, 68% branch** — a failing run can be a coverage drop, not just a failing assertion.
- `test-prof`'s `let_it_be` is required globally — use it instead of `let!` when the record doesn't need per-example mutation.
- Bullet runs in **development only** (initializer guards on `Rails.env.development?`), not in test.
- Action Policy RSpec DSL is loaded — `spec/policies/` uses `describe_rule` / `succeed` / `failed`.
- OmniAuth is in test mode globally; use `mock_auth_hash` from `spec/support/omniauth_macros.rb`.
- No controller/request specs in the codebase — feature behavior is covered by `spec/system/` instead.
- Always add `# frozen_string_literal: true` to new Ruby files (RuboCop will flag otherwise).

## Code Style

- RuboCop config: `.rubocop.yml` (+ `.rubocop_todo.yml`). Line length cap: **120**.
- Views are written in **Slim**.
- Form rendering goes through `simple_form`.

## CI

`.github/workflows/ci.yml` runs RuboCop → Brakeman (`-q -w2 -z`) → RSpec on every push and PR. Asset build + `searchkick:reindex:all` happen before specs, so search-tagged tests can hit a real Elasticsearch.
