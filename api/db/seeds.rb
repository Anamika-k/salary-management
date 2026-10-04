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

User.find_or_create_by!(email: hr_email) do |user|
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
