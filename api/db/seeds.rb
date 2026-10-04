# Seed data for `bin/rails db:seed`. Sections are ordered by dependency and
# grow as features are added. Safe to run any number of times: nothing is
# duplicated and HR's edits are never overwritten.

# == HR Manager ==============================================================
# The account used to sign in. The development default password must never
# reach production, so production requires SEED_HR_PASSWORD.
hr_email = ENV.fetch("SEED_HR_EMAIL", "hr@acme.com")
hr_password = ENV.fetch("SEED_HR_PASSWORD") do
  raise "Set SEED_HR_PASSWORD before seeding production" if Rails.env.production?

  "ChangeMe123!"
end

hr_user = User.find_or_create_by!(email: hr_email) do |user|
  user.name = "HR Manager"
  user.password = hr_password
end
puts "Seeded HR Manager: #{hr_email}"

# == Departments =============================================================
# name => [share of headcount, designations]
departments = {
  "Engineering" => [ 30, [ "Software Engineer", "Senior Software Engineer", "Staff Engineer", "Engineering Manager" ] ],
  "Product" => [ 6, [ "Product Manager", "Senior Product Manager", "Director of Product" ] ],
  "Design" => [ 5, [ "Product Designer", "Senior Product Designer", "Design Lead" ] ],
  "Sales" => [ 15, [ "Sales Executive", "Account Manager", "Sales Manager" ] ],
  "Marketing" => [ 7, [ "Marketing Executive", "Marketing Manager", "Content Strategist" ] ],
  "Finance" => [ 6, [ "Accountant", "Financial Analyst", "Finance Manager" ] ],
  "Human Resources" => [ 4, [ "HR Executive", "HR Business Partner", "HR Manager" ] ],
  "Operations" => [ 10, [ "Operations Executive", "Operations Analyst", "Operations Manager" ] ],
  "Customer Support" => [ 14, [ "Support Associate", "Senior Support Associate", "Support Manager" ] ],
  "Legal" => [ 3, [ "Legal Counsel", "Compliance Officer" ] ]
}

departments.each_key { |name| Department.find_or_create_by!(name:) }
puts "Seeded #{departments.size} departments"

# == Salary components and structures ========================================
# One standard structure per country. Rates are simplified illustrations, not
# legal tax rules. Existing rules are left alone, so HR's edits survive reseeding.
components = {
  "BASIC" => [ "Basic Salary", "earning" ], "HRA" => [ "House Rent Allowance", "earning" ],
  "SPECIAL" => [ "Special Allowance", "earning" ], "PF" => [ "Provident Fund", "deduction" ],
  "PROF_TAX" => [ "Professional Tax", "deduction" ], "INCOME_TAX" => [ "Income Tax", "deduction" ],
  "SOCIAL_SECURITY" => [ "Social Security", "deduction" ], "MEDICARE" => [ "Medicare", "deduction" ],
  "NI" => [ "National Insurance", "deduction" ], "PENSION" => [ "Pension", "deduction" ],
  "HEALTH_INS" => [ "Health Insurance", "deduction" ], "CPF" => [ "Central Provident Fund", "deduction" ]
}
components.each do |code, (name, component_type)|
  SalaryComponent.find_or_create_by!(code:) { |component| component.assign_attributes(name:, component_type:) }
end

# country => [[component, method, value, base component], ...] in calculation order
structures = {
  "IN" => [ [ "BASIC", "percentage_of_gross", 50 ], [ "HRA", "percentage_of_component", 40, "BASIC" ],
            [ "SPECIAL", "remainder" ], [ "PF", "percentage_of_component", 12, "BASIC" ],
            [ "PROF_TAX", "fixed", 200 ], [ "INCOME_TAX", "percentage_of_gross", 10 ] ],
  "US" => [ [ "BASIC", "percentage_of_gross", 80 ], [ "SPECIAL", "remainder" ], [ "SOCIAL_SECURITY", "percentage_of_gross", 6.2 ],
            [ "MEDICARE", "percentage_of_gross", 1.45 ], [ "INCOME_TAX", "percentage_of_gross", 15 ], [ "HEALTH_INS", "fixed", 200 ] ],
  "GB" => [ [ "BASIC", "percentage_of_gross", 80 ], [ "SPECIAL", "remainder" ], [ "INCOME_TAX", "percentage_of_gross", 20 ],
            [ "NI", "percentage_of_gross", 8 ], [ "PENSION", "percentage_of_component", 5, "BASIC" ] ],
  "DE" => [ [ "BASIC", "percentage_of_gross", 85 ], [ "SPECIAL", "remainder" ], [ "INCOME_TAX", "percentage_of_gross", 25 ],
            [ "PENSION", "percentage_of_gross", 9.3 ], [ "HEALTH_INS", "percentage_of_gross", 7.3 ] ],
  "SG" => [ [ "BASIC", "percentage_of_gross", 80 ], [ "SPECIAL", "remainder" ],
            [ "CPF", "percentage_of_component", 20, "BASIC" ], [ "INCOME_TAX", "percentage_of_gross", 7 ] ],
  "AE" => [ [ "BASIC", "percentage_of_gross", 60 ], [ "HRA", "percentage_of_gross", 25 ],
            [ "SPECIAL", "remainder" ], [ "HEALTH_INS", "fixed", 150 ] ]
}
component_ids = SalaryComponent.where(code: components.keys).pluck(:code, :id).to_h
structures.each do |country_code, rules|
  name = "#{Country.find(country_code)[:name]} Standard"
  structure = SalaryStructure.find_or_create_by!(code: "#{country_code}_STD") do |new_structure|
    new_structure.assign_attributes(name:, country_code:, description: "Standard pay structure for #{name.delete_suffix(' Standard')}")
  end
  rules.each.with_index(1) do |(code, calculation_method, value, base), position|
    structure.rules.find_or_create_by!(salary_component_id: component_ids.fetch(code)) do |rule|
      rule.assign_attributes(calculation_method:, value:, position:, base_component_id: base && component_ids.fetch(base))
    end
  end
end
puts "Seeded #{components.size} salary components and #{structures.size} salary structures"

# == Employees ===============================================================
# 10,000 by default (SEED_EMPLOYEE_COUNT overrides it). A fixed random seed
# makes every run produce identical data.
# insert_all instead of find_or_create_by!: one query per 1,000 rows (~2s, not
# ~1 min). It skips rows whose code or email already exists, so reruns add
# nothing and never overwrite edits. It skips model validations, so the
# generated values are kept inside the model's rules (covered by seeds_spec).
# country => [share of headcount, first names, last names]
countries = {
  "IN" => [ 50, %w[Aarav Vivaan Aditya Arjun Ishaan Ananya Diya Priya Kavya Meera],
                %w[Sharma Verma Gupta Iyer Reddy Nair Patel Singh Rao Mehta] ],
  "US" => [ 20, %w[James Michael David Daniel Ethan Emily Olivia Sophia Ava Grace],
                %w[Smith Johnson Brown Davis Miller Wilson Moore Taylor Clark Lewis] ],
  "GB" => [ 10, %w[Oliver George Harry Jack Thomas Amelia Isla Emily Poppy Lily],
                %w[Jones Williams Evans Thomas Roberts Walker Wright Hughes Green Hall] ],
  "DE" => [ 8, %w[Lukas Leon Finn Paul Jonas Mia Emma Hannah Lea Lena],
               %w[Müller Schmidt Schneider Fischer Weber Meyer Wagner Becker Hoffmann Koch] ],
  "SG" => [ 7, %w[Wei Jun Kai Ming Hao Hui Ling Mei Xin Yan],
               %w[Tan Lim Lee Ng Ong Wong Goh Chua Koh Teo] ],
  "AE" => [ 5, %w[Omar Ahmed Khalid Yousef Hamad Fatima Mariam Aisha Noura Layla],
               %w[Al-Mansoori Al-Hashimi Al-Nuaimi Al-Suwaidi Al-Ketbi Al-Mazrouei Al-Shamsi Al-Falasi Al-Dhaheri Al-Marri] ]
}

rng = Random.new(2026)
# Weighted random choice: each key wins with probability proportional to its weight.
pick = ->(weights) { weights.max_by { |_, (weight)| rng.rand**(1.0 / weight) }.first }
department_ids = Department.where(name: departments.keys).pluck(:name, :id).to_h
first_day = Date.new(2016, 1, 1)
last_day = Date.new(2026, 9, 30)
employee_count = ENV.fetch("SEED_EMPLOYEE_COUNT", 10_000).to_i

rows = (1..employee_count).map do |number|
  country = pick.call(countries)
  department = pick.call(departments)
  first_name, last_name = countries[country][1].sample(random: rng), countries[country][2].sample(random: rng)
  joining_date = first_day + rng.rand((last_day - first_day).to_i)
  roll = rng.rand
  status = roll < 0.10 ? "terminated" : (roll < 0.15 ? "on_leave" : "active")

  {
    employee_code: format("EMP%06d", number), first_name:, last_name:,
    email: "#{first_name}.#{last_name}.#{number}@acme.com".downcase.unicode_normalize(:nfkd).delete("^a-z0-9.@-"),
    country_code: country, department_id: department_ids.fetch(department),
    designation: departments[department][1].sample(random: rng), joining_date:, employment_status: status,
    exit_date: (joining_date + rng.rand(0..(last_day - joining_date).to_i) if status == "terminated")
  }
end

rows.each_slice(1_000) { |batch| Employee.insert_all(batch) }
puts "Seeded #{Employee.count} employees"

# == Salary history ==========================================================
# Every seeded employee without salary history gets a joining salary plus a
# raise on each work anniversary (3-10%, or 12-20% for the occasional
# promotion). Pay ends on the exit date for terminated employees.
# Built from the employees as stored, so HR's edits (country, title) are respected;
# employees who already have salaries are skipped, so HR's entries are never mixed with seed data.
# Same insert_all approach and reasoning as employees (~60,000 rows in seconds).
# country => starting annual salary for the most junior title, in local currency
base_salaries = { "IN" => 600_000, "US" => 70_000, "GB" => 40_000, "DE" => 50_000, "SG" => 60_000, "AE" => 120_000 }
# Seniority = position of the title in its department's list (0 = most junior)
title_levels = departments.values.flat_map { |(_, titles)| titles.each_with_index.to_a }.to_h
structure_ids = SalaryStructure.where(code: base_salaries.keys.map { |code| "#{code}_STD" }).pluck(:country_code, :id).to_h
already_paid = EmployeeSalary.distinct.pluck(:employee_id).to_set
salary_rng = Random.new(2027)
round_salary = ->(amount) { amount.round(-3) }

salary_rows = Employee.where(employee_code: rows.pluck(:employee_code)).order(:employee_code).flat_map do |employee|
  next [] if already_paid.include?(employee.id)

  amount = round_salary.call(base_salaries.fetch(employee.country_code) *
                             (1 + 0.6 * title_levels.fetch(employee.designation, 0)) * salary_rng.rand(0.85..1.15))
  periods = [ [ employee.joining_date, amount, "joining" ] ]
  next_start = employee.joining_date.next_year
  while next_start <= last_day && (employee.exit_date.nil? || next_start < employee.exit_date)
    promotion = salary_rng.rand < 0.1
    amount = round_salary.call(amount * (1 + (promotion ? salary_rng.rand(0.12..0.20) : salary_rng.rand(0.03..0.10))))
    periods << [ next_start, amount, promotion ? "promotion" : "increment" ]
    next_start = next_start.next_year
  end

  periods.each_with_index.map do |(effective_from, annual_salary, change_type), index|
    next_period = periods[index + 1]
    {
      employee_id: employee.id, salary_structure_id: structure_ids.fetch(employee.country_code),
      annual_salary:, currency: Country.find(employee.country_code)[:currency], effective_from:,
      effective_to: next_period ? next_period[0] - 1 : employee.exit_date,
      change_type:, created_by_id: hr_user.id
    }
  end
end

salary_rows.each_slice(1_000) { |batch| EmployeeSalary.insert_all(batch) }
puts "Seeded #{EmployeeSalary.count} salary records"
