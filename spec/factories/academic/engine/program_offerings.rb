FactoryBot.define do
  factory :program_offering, class: 'Academic::Engine::ProgramOffering' do
    active { true }
    mode { 'full_time' }
    campus { Faker::University.name }

    association :program
    association :intake
    association :academic_timeline
  end
end
