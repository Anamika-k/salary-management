# Seed data for `bin/rails db:seed`. Sections are ordered by dependency and
# grow as features are added. Everything uses find_or_create_by!, so seeding
# can run any number of times without duplicating data or overwriting HR's edits.

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
