# HR Manager accounts for specs.
FactoryBot.define do
  factory :user do
    name { "Priya HR" }
    sequence(:email) { |n| "hr#{n}@acme.test" }
    password { "Secret123!" }

    trait :deleted do
      deleted_at { Time.current }
    end
  end
end
