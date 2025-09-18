FactoryBot.define do
  factory :program, class: 'Academic::Engine::Program' do
    name { Faker::Educator.degree } # generates realistic program names
    code { Faker::Alphanumeric.alpha(number: 5).upcase } # e.g. "ABC12"
    duration { Faker::Number.between(from: 1, to: 6) } # years/semesters
    active { true }
  end
end
