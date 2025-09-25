FactoryBot.define do
  factory :requirements_schema, class: 'Sims::Common::Schema' do
    sequence(:name) { |n| "Admission Requirements #{n}" }
    schema do
      {
        type: 'object',
        required: ['minimum_gpa'],
        properties: {
          minimum_gpa: { type: 'number', minimum: 2.5 },
          english_test: { type: 'string', enum: %w[IELTS TOEFL] }, }, }
    end
  
  end
end
