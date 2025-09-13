FactoryBot.define do
  factory :program_offering, class: 'Academic::Engine::ProgramOffering' do
    association :program
    association :intake
    association :academic_timeline
    mode { %i[full_time part_time extension online].sample }
    campus { %w[Main North South Online].sample }

    trait :full_time do
      mode { :full_time }
    end

    trait :part_time do
      mode { :part_time }
    end

    trait :extension do
      mode { :extension }
    end

    trait :online do
      mode { :online }
    end

    trait :current do
      association :intake, :current
    end

    trait :with_spring_intake do
      association :intake, :spring
    end

    trait :with_fall_intake do
      association :intake, :fall
    end
  end
end
