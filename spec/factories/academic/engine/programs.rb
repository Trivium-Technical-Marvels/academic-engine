FactoryBot.define do
  factory :program, class: 'Academic::Engine::Program' do
    sequence(:name) { |n| "#{Faker::Educator.degree} in #{Faker::Educator.subject} #{n}" }
    sequence(:code) { |n| "#{Faker::Alphanumeric.alpha(number: 3).upcase}#{Faker::Number.number(digits: 3)}#{n}" }
    duration { [1, 2, 3, 4].sample }
    description { Faker::Lorem.paragraph(sentence_count: 3, supplemental: false, random_sentences_to_add: 2) }

    trait :short_duration do
      duration { 1 }
    end

    trait :medium_duration do
      duration { 2 }
    end

    trait :long_duration do
      duration { [3, 4].sample }
    end

    trait :with_offerings do
      after(:create) do |program|
        create_list(:program_offering, 2, program: program)
      end
    end
  end
end
