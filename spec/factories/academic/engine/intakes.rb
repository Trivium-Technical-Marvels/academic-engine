FactoryBot.define do
  factory :intake, class: 'Academic::Engine::Intake' do
    name { generate(:intake_name) }
    admission_type { %w[fall spring].sample }
    start_date { Faker::Date.forward(days: 23) }
    end_date { start_date.end_of_year }

    trait :with_schema do
      after(:create) do |intake|
        create(:requirements_schema, schemaable: intake)
      end
    end
  end

  # Create intake name sequences to avoid unique constraint violations
  sequence :intake_name do |n|
    "Intake #{n}"
  end
end
