# AGENTS.md

## Principles

- **KISS:** Prefer the simplest solution that works.
- Follow existing project conventions.
- Write readable, idiomatic Ruby and Rails code.
- Avoid unnecessary abstractions, dependencies, and configuration.
- Make small, focused changes. Do not refactor unrelated code.

## Rails Commands

| Command | Purpose |
|---|---|
| `bin/rails server` | Start the development server |
| `bin/rails console` | Open the Rails console |
| `bin/rails routes` | List application routes |
| `bin/rails generate model Post title:string` | Generate a model and migration |
| `bin/rails generate controller Posts index` | Generate a controller and action |
| `bin/rails generate migration` | Generate a migration |
| `bin/rails db:migrate` | Run pending migrations |
| `bin/rails db:rollback` | Roll back the last migration |
| `bin/rails db:seed` | Run database seeds |
| `bin/rails db:prepare` | Prepare the database |
| `bin/check` | Run linter and tests |

- Inspect generated files before keeping them.
- Do not run destructive database commands without understanding their impact.
- Check project scripts and configuration before assuming a command is available.

## Ruby on Rails

- Follow Rails conventions and RESTful design.
- Prefer built-in Rails features over new dependencies.
- Keep controllers thin and business logic appropriately encapsulated.
- Use strong parameters for request input.
- Avoid N+1 queries and unnecessary database calls.
- Use migrations for schema changes; make them reversible when possible.
- Never commit secrets or credentials.

## Views and Templates

- Use **Slim** for all server-rendered templates.
- Do not introduce ERB or Haml templates.
- Keep views focused on presentation.
- Use partials for genuinely reusable markup.
- Prefer Rails helpers over complex template logic.
- Avoid business logic in templates.

## Testing

- Use **RSpec** for all tests.
- Write tests for new behavior and regression tests for bug fixes.
- Use model specs for model behavior, request specs for HTTP behavior, and system specs for critical user flows when appropriate.
- Keep tests focused, deterministic, and independent.
- Prefer testing observable behavior over implementation details.
- Reuse existing factories and test helpers.
- Avoid unnecessary mocking.
- Run relevant specs after changes and the full suite when practical.
- Fix failures caused by your changes before finishing.

Common commands:

| Command | Purpose |
|---|---|
| `bundle exec rspec` | Run the full RSpec suite |
| `bundle exec rspec spec/models` | Run model specs |
| `bundle exec rspec spec/requests` | Run request specs |
| `bundle exec rspec spec/models/post_spec.rb` | Run a specific spec file |
| `bundle exec rspec spec/models/post_spec.rb:42` | Run a specific example at line 42 |

- Use the project's configured test and lint commands when available.
- Do not claim tests passed unless they were actually executed.

## Code Quality

- Follow existing Ruby style and linting rules.
- Prefer clear names and small methods.
- Avoid premature abstraction.
- Handle errors explicitly where necessary.
- Add comments only to explain non-obvious decisions.
- Add dependencies only when justified.

## Workflow

1. Inspect relevant code and existing conventions.
2. Identify the expected behavior and smallest viable change.
3. Implement using Rails conventions and Slim templates.
4. Add or update RSpec tests.
5. Run relevant tests and available linters.
6. Review the diff for unintended changes.

## Completion

- Summarize what changed.
- Report tests and checks actually run.
- Mention known limitations or checks that could not be run.