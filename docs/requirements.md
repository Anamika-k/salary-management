# ACME Salary Management — Requirements (MVP)

## The problem

ACME's HR team manages salaries for about 10,000 employees across several countries in Excel. That makes everyday work slow and error-prone. Updating a salary means finding the right row in the right sheet. Nobody can easily see what someone earned last year. A simple question like "what do we pay engineers in India on average?" turns into an afternoon of filters and pivot tables.

We are building a web application for the HR Manager to replace those spreadsheets. It does two things: it holds salary data reliably, and it answers questions about how the organisation pays its people.

## Who it's for

The only user is the HR Manager. Employees don't log in. Every screen is built around what an HR Manager does day to day: finding people, updating pay, and understanding the overall picture.

## What we're building

**Employee records.** HR can add, edit and view employees, search by name or employee code, and filter by department, country and employment status. Each employee has a department, designation, country, joining date and status. Search and filtering stay fast with the full 10,000 records loaded.

**Salaries with history.** Each employee's salary is recorded as an annual gross amount in their local currency, with the date it takes effect. When HR gives someone a raise, the system adds a new salary record instead of overwriting the old one. The full pay history is always available, and the system always knows which salary applied on any given date.

**Salary breakdown.** A real salary isn't one number, so HR can define reusable salary structures such as "India Standard". A structure lists earnings (Basic, HRA, allowances) and deductions (PF, insurance, tax). Each component is either a fixed amount or a percentage of the salary or of another component. Assigning a structure to an employee lets the system show their monthly gross, deductions and net pay. The rules are configuration, not hardcoded, so changing the PF rate is a settings change rather than a code change. The breakdown shows the standard monthly salary. Adjustments to an actual month's payout, such as unpaid leave or partial months for joiners and leavers, belong to payroll and are out of scope.

**Pay insights.** This answers the second half of the brief. An insights page shows headcount and total salary cost by country and department. It shows average, median, minimum and maximum pay by country, department and designation, how salaries are distributed, and recent salary changes. Amounts are always shown in their own currency, and comparisons are grouped by country, so rupees and dollars are never added together.

**Basics we won't skip.** HR signs in with an email and password. Every salary change is recorded in an audit log with who made it and when. A seed script loads 10,000 realistic employees, so the system is tested and demoed at real scale.

## What we're deliberately leaving out, and why

**Payroll runs** (monthly processing, approval workflows, payslips). The brief asks us to manage salary data and answer questions about it, not to process payroll. Payroll can be added later as new tables that read from the salary structures we're building now, without changing anything existing.

**Real tax and statutory compliance.** Tax rules differ by country, change every year, and depend on individual declarations. A half-built tax engine would be worse than none. Tax is treated as a configurable deduction, and we say plainly that it isn't legally accurate.

**Currency conversion.** Salaries are stored and shown in local currency, which is how most HR tools handle it. Converting everything to one reporting currency needs exchange rates and a policy for which rate applies when. Neither was asked for, and both are easy to add later.

**Leave, attendance and holidays,** including policies like sandwich leave. These are separate HR systems, and their rules vary from company to company. Building them would mean inventing policies the business hasn't defined.

**Employee self-service, bank payments, bonuses, reimbursements and loans.** They're useful, but each is a product in its own right and none is part of the problem we were given.

**An AI chatbot for pay questions.** The insights page answers the common questions reliably. A natural-language assistant over salary data raises accuracy and privacy concerns that deserve their own design.

## How we're building it

The backend is a Ruby on Rails API with a MySQL database. The frontend is React. All salary calculation lives in a single, well-tested service, so new rules can be added in one place. A single Rails application is plenty for 10,000 employees, so there are no microservices, queues or extra infrastructure. Tests focus on what matters most: salary calculation, salary history and the insights figures.

## What "done" looks like

An HR Manager can sign in, find any of the 10,000 employees in seconds, and update a salary without losing its history. They can see exactly how that salary breaks down into earnings and deductions, and answer common questions about pay across the organisation, all from a deployed web application without opening Excel.
