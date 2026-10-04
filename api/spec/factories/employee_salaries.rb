# Salary history rows and audit entries for specs.
FactoryBot.define do
  factory :employee_salary do
    employee
    salary_structure
    annual_salary { 1_200_000 }
    currency { "INR" }
    effective_from { Date.new(2024, 1, 15) }
    change_type { "joining" }
    association :created_by, factory: :user
  end

  factory :audit_log do
    user
    action { "created" }
    association :auditable, factory: :employee_salary
    change_set { { "annual_salary" => [ nil, "1200000.0" ] } }
  end
end
