# How I Used AI

I built this with an AI coding agent (Cursor). The product, the requirements and the design are mine; the AI wrote code to them, and I reviewed everything it wrote.

## How the work was split

**Me.** The complete requirements for every feature: what it must do and what it must not, how the database looks, the filters, what the insights page shows and how each figure is counted, and what we deliberately leave out. I also set the engineering rules and the quality pipeline, and reviewed every change.

**AI.** Writing the code and tests to those requirements, one feature at a time, following my rule set.

**Backend** is my strength. I designed it and reviewed it closely: schema, soft delete, salary history, calculator, insights.

**Frontend** is not my main area, so the AI wrote the React code. I decided what the UI should be: the pages, what each one shows, the flows (search, salary change, rule editing, dashboard), the stack (React, plain JavaScript, Tailwind), a light and minimal look, and building it one page at a time. I checked each page in the browser against the real 10,000-employee data.

## Rules and a quality pipeline

Before any feature, I wrote a rule book the AI must follow on every change (`.cursor/rules/`):

- Test first: list every edge case, write failing tests, then the code.
- Keep it simple: the plain, obvious solution over a clever one; small files; no duplicated logic.
- Money is always `decimal`; business data is soft deleted, never hard deleted.
- No `rescue` in services or controllers; one place turns errors into JSON.
- Controller → Service → Model, and no raw SQL.

I set up a pipeline so the standard holds on every change, not only when someone remembers to check:

- **Locally, through git hooks:** RuboCop (style and complexity) and the full RSpec suite run first. Brakeman (security scan) and bundler-audit (vulnerable gems) run before code reaches GitHub.
- **On GitHub (CI):** the same checks again, plus a 95% coverage minimum. CI also checks that the migrations rebuild the schema, that the seeds can safely run twice, and that the production environment boots.

Code that is hard to read, insecure or untested doesn't get in, whoever or whatever wrote it.

## How a feature was built

1. I gave the full requirement for the feature, covering the rules and limits. For example, for insights:
   - pay figures count active and on-leave employees, not leavers;
   - amounts in different currencies are never added together, so every comparison is per country;
   - "recent changes" come from salary history;
   - salary bands are sized automatically.
2. The AI listed the edge cases, wrote failing tests covering each one, then wrote the code to my rule set.
3. I reviewed the code and checked the result in the browser or with API calls before moving to the next feature.

## Example instructions I gave

- "Never hard delete business data; use a deleted_at timestamp."
- "Money is always decimal, never float."
- "Reports that compare pay must be per country; never add rupees and dollars."
- "Seeds: keep everything in seeds.rb, use find_or_create_by!, insert_all is fine for employees and salaries."

## Mistakes caught by review and testing

AI output is not trusted until it is checked. Some things the process caught:

- **A dialog stole keyboard focus on every re-render.** A test showed it; focus is now set only when the dialog opens.
- **Production would not boot** after the deploy changes, because a leftover setting still pointed to a cache database we had removed. A production boot check caught it before deploy.
- **Deploy problems** (wrong root directory, a wrong secret, an HR password mismatch, CORS) were each confirmed fixed by calling the live URLs, not assumed.

## What I verified myself

- Core logic is covered by tests: salary calculator, salary history, every insights figure, and the API endpoints. There are 266 backend specs at 99% line coverage and 62 frontend tests.
- I tried every screen against the full seed: search, filters, salary change, breakdown, rule editing and the dashboard.
- I'm going through the backend line by line (database, associations, services, controllers) so I can explain and change any part of it.
