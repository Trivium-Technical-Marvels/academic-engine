FactoryBot.define do
  factory :intake, class: 'Academic::Engine::Intake' do
    name { generate(:intake_name) }
    admission_type { %w[fall spring].sample }
    start_date { Faker::Date.forward(days: 23) }
    end_date { start_date.end_of_year }

    # Create with a pre-existing schema (schema-first workflow)
    trait :with_schema do
      transient do
        # Create schema with dummy polymorphic values to satisfy NOT NULL constraint
        schema do
          create(:schema,
            name:            "#{name.downcase.tr(' ', '_')}_requirements_schema",
            schemaable_type: 'DummyModel',
            schemaable_id:   999_999,
            schema:          {
              '$schema'    => 'https://json-schema.org/draft/2020-12/schema',
              'type'       => 'object',
              'properties' => {
                'gpa' => { 'type' => 'number', 'minimum' => 2.0 }
              },
              'required'   => ['gpa']
            })
        end
      end

      schema_id { schema.id }
    end
  end

  # Create intake name sequences to avoid unique constraint violations
  sequence :intake_name do |n|
    "Intake #{n}"
  end
end
