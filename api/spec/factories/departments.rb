# Departments for specs.
FactoryBot.define do
  factory :department do
    sequence(:name) { |n| "Department #{n}" }

    trait :deleted do
      deleted_at { Time.current }
    end
  end
end
