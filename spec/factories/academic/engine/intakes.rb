FactoryBot.define do
  factory :intake, class: 'Academic::Engine::Intake' do
    start_date { Date.current }
    admission_type { %i[spring fall].sample }
    sequence(:name) { |n| "#{Date.current.year} #{%w[Spring Fall].sample} Intake #{n}" }
    end_date { start_date.end_of_year }

    trait :spring do
      admission_type { :spring }
      start_date { Date.new(Date.current.year, [1, 2, 3].sample, [1, 15].sample) }
      end_date { start_date.end_of_year }
    end

    trait :fall do
      admission_type { :fall }
      start_date { Date.new(Date.current.year, [8, 9, 10].sample, [1, 15].sample) }
      end_date { start_date.end_of_year }
    end

    trait :current do
      start_date { Date.current }
      end_date { start_date.end_of_year }
    end

    trait :past do
      start_date { Faker::Date.between(from: 1.year.ago, to: Date.current - 1.day) }
      end_date { start_date.end_of_year }
    end

    trait :future do
      start_date { Faker::Date.between(from: Date.current + 1.day, to: Date.current.end_of_year) }
      end_date { start_date.end_of_year }
    end
  end
end
