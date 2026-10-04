# ACME Salary Management

A web application for ACME's HR Manager to manage salaries for ~10,000 employees across several countries, and to answer questions about how the organisation pays its people. It replaces a set of Excel sheets.

- **What and why:** [docs/requirements.md](docs/requirements.md) (scope and what's deliberately left out)
- **How it's built:** [docs/design.md](docs/design.md) (architecture, decisions and trade-offs, performance)
- **Database:** [docs/database.md](docs/database.md) (every table and column, and why)

## Repository layout

```
api/          Rails 8 API (Ruby, MySQL), all backend code and specs
web_portal/   React app (coming soon)
docs/         Requirements, design, database
.githooks/    Git hooks: lint, tests and security checks before commit/push
.github/      CI pipeline
.cursor/      Engineering rule book used with AI tooling
```

## Basic Commands

Run from `api/`:

```shell
bin/rails db:prepare            # Create the databases, load the schema, seed
bin/rails server                # API on http://localhost:3000
bundle exec rspec               # Run the test suite
CI=true bundle exec rspec       # ...with the coverage minimum enforced
bundle exec rubocop             # Lint
bin/brakeman                    # Security scan
bundle exec bundle-audit check --update   # Known gem vulnerabilities
bin/rails db:seed               # Re-run seeds (safe to repeat)
bin/rails console               # Rails console
```

## Getting Started

1. **Install prerequisites**
   1. Ruby (version in `api/.ruby-version`), via [rvm](https://rvm.io) or [rbenv](https://github.com/rbenv/rbenv)
   2. MySQL 8+: `brew install mysql && brew services start mysql`
   3. Bundler: `gem install bundler`
2. **Install gems**
   ```shell
   cd api && bundle install
   ```
3. **Configure your environment**
   ```shell
   cp .env.sample .env
   ```
   Set `DATABASE_PASSWORD` to your local MySQL root password. The other defaults work out of the box. `.env` is git-ignored and loaded automatically in development and test.
4. **Create the database and seed it**
   ```shell
   bin/rails db:prepare
   ```
   This creates the HR Manager, 10 departments and 10,000 realistic employees across 6 countries in about 2 seconds. The data is identical on every machine, and re-running `bin/rails db:seed` never duplicates rows or overwrites edits.
5. **Enable the git hooks** (once per clone, from the repository root)
   ```shell
   git config core.hooksPath .githooks
   ```
6. **Run it**
   ```shell
   bundle exec rspec        # everything should be green
   bin/rails server
   ```
7. **Sign in** with the seeded HR Manager: `hr@acme.com` / `ChangeMe123!`
   ```shell
   curl -i -X POST localhost:3000/api/v1/auth/sign_in \
     -H 'Content-Type: application/json' \
     -d '{"user":{"email":"hr@acme.com","password":"ChangeMe123!"}}'
   ```
   The token is in the `Authorization` response header. Send it on every other request.

### Environment variables

| Variable | Purpose | Default |
|---|---|---|
| `DATABASE_USERNAME` / `DATABASE_PASSWORD` | MySQL credentials | `root` / empty |
| `DATABASE_HOST` | Connect over TCP instead of the local socket (CI, Docker) | unset (socket) |
| `DEVISE_JWT_SECRET_KEY` | JWT signing secret; **set in production** | `secret_key_base` |
| `FRONTEND_ORIGINS` | Comma-separated origins allowed by CORS | `http://localhost:5173` |
| `SEED_HR_EMAIL` / `SEED_HR_PASSWORD` | Seeded HR Manager; password **required in production** | `hr@acme.com` / `ChangeMe123!` |
| `SEED_EMPLOYEE_COUNT` | How many demo employees the seed creates | `10000` |

## How a request flows

```
React ──HTTP+JWT──▶ CORS ──▶ Devise/JWT auth ──▶ Controller ──▶ Service ──▶ Model ──▶ MySQL
                                   │                  │             │
                                 401 if             renders      raises ApplicationError
                                invalid          (render_record      on rule violations
                                                 /render_records)
                    any error ──▶ ErrorHandling concern ──▶ { error, code, details }
```

- **Controllers** are thin: find, call one service, render. Every endpoint requires a signed-in user unless it explicitly opts out (only sign-in does).
- **Services** (`app/services/<domain>/`) hold all business logic: one class, one job, transactions around multi-step writes.
- **Models** declare associations, validations, enums and named scopes. No side-effect callbacks.
- **Lists** are paginated and use lite serializers that return only what the screen needs. Aggregates that can't be eager-loaded go through preloaders (one grouped query per page), so there are no N+1 queries.

The full rule book lives in [.cursor/rules/](.cursor/rules).

## Error handling

Errors are never swallowed. Services, models and controller actions don't `rescue`; everything travels up to one concern, `ErrorHandling`, on `ApplicationController`:

| Error | Response |
|---|---|
| Missing/invalid/expired token | `401` |
| Record not found | `404 not_found` |
| Missing parameter | `400 parameter_missing` |
| Validation failed | `422 record_invalid`, with field errors in `details` |
| Domain rule (`ApplicationError` subclass) | Its own status and code |
| Anything else (a bug) | Logged with full backtrace, reported via `Rails.error.report`, generic `500` |

Every error response has the same shape:

```json
{ "error": "Validation failed: Name can't be blank", "code": "record_invalid", "details": { "name": ["can't be blank"] } }
```

Handled errors are logged as warnings. Bugs are logged as errors and reported, but never leak internals to the client.

## Authentication

Devise with devise-jwt. Sign-in returns a JWT in the `Authorization` header, valid for 8 hours. Sign-out revokes it immediately (the user's `jti` rotates). Soft-deleted users can't sign in, and their tokens stop working.

## Data conventions

- **Soft delete:** business rows get `deleted_at`, never hard-deleted. Queries use `.kept`.
- **Money:** `decimal(15,2)`, never float. Salaries are annual gross with an ISO currency, never converted.
- **Salary history:** a change adds a row and closes the previous one; nothing is overwritten.
- **Integrity:** every rule is enforced in model validations *and* the database (foreign keys, unique indexes, check constraints).

## Quality pipeline

Every change passes the same gates locally and in CI.

| When | Check |
|---|---|
| `git commit` | Conflict markers blocked · RuboCop on staged Ruby files · full RSpec suite |
| `git push` | Full suite with coverage minimum · Brakeman · bundler-audit |
| GitHub CI | RuboCop · Brakeman + bundler-audit · RSpec on MySQL 8.4 with coverage report · data checks (migrations rebuild the committed schema, no pending migrations, seeds run twice, production boots) |
## Testing

RSpec with FactoryBot, run in random order so hidden dependencies between tests surface. Tests are written first, from a list of edge cases. Coverage is measured with SimpleCov, and full-suite runs fail below the minimum. Open `api/coverage/index.html` after a run.

```
spec/models/        validations, scopes, concerns
spec/requests/      endpoints: status codes, payloads, auth, errors
spec/controllers/   shared controller concerns (error handling)
spec/services/      business logic (coming with features)
spec/db/            seeds are correct and idempotent
```

## API reference

All endpoints are under `/api/v1` and require `Authorization: Bearer <token>` unless noted.

| Method | Path | Description |
|---|---|---|
| `POST` | `/auth/sign_in` | Sign in (no token needed). Body `{ user: { email, password } }` |
| `GET` | `/auth/me` | The signed-in user |
| `DELETE` | `/auth/sign_out` | Revoke the current token |

| `GET` | `/employees` | Paginated list (lite fields). Params: `q` (searches name, email, code), `department_id`, `country_code`, `employment_status`, `designation`, `sort` (`employee_code`, `first_name`, `last_name`, `joining_date`, `created_at`), `direction` (`asc`/`desc`), `page`, `per_page` (default 25, max 100) |
| `GET` | `/employees/:id` | Full employee record |
| `POST` | `/employees` | Create. Body `{ employee: { first_name, last_name, email, country_code, department_id, designation, joining_date, employment_status?, exit_date? } }`. The employee code is generated |
| `PATCH` | `/employees/:id` | Update (same fields; the code never changes) |
| `DELETE` | `/employees/:id` | Soft delete |
| `GET` | `/departments` | Paginated list of departments |
| `POST` | `/departments` | Create `{ department: { name } }`; restores a deleted department with the same name |
| `PATCH` | `/departments/:id` | Rename |
| `DELETE` | `/departments/:id` | Soft delete; `409 in_use_error` while employees belong to it |
| `GET` | `/filters` | Dropdown options: departments, countries (with currency), designations in use, statuses |

Lists respond with `{ data: [...], meta: { current_page, total_pages, total_count, per_page } }`, single records with `{ data: {...} }`.

More endpoints (salaries, structures, insights) will be documented here as they're built.

## Status

| Area | State |
|---|---|
| Requirements, design and database docs | Done |
| Database schema (8 tables) | Done |
| Authentication (Devise + JWT) | Done |
| Error handling, quality pipeline, CI | Done |
| Employees and departments | Done |
| Salary structures and calculator | Planned |
| Salary history and audit log | Planned |
| Insights | Planned |
| React UI, 10,000-employee seed, deployment | Planned |
