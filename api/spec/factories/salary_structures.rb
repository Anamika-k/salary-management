# Salary components, structures and their rules for specs.
FactoryBot.define do
  factory :salary_component do
    sequence(:code) { |n| "COMP#{n}" }
    sequence(:name) { |n| "Component #{n}" }
    component_type { "earning" }

    trait :deduction do
      component_type { "deduction" }
    end
  end

  factory :salary_structure do
    sequence(:code) { |n| "STRUCT#{n}" }
    name { "Standard" }
    country_code { "IN" }
  end

  factory :salary_structure_component do
    salary_structure
    salary_component
    calculation_method { "percentage_of_gross" }
    value { 50 }
    sequence(:position) { |n| n }
  end
end
