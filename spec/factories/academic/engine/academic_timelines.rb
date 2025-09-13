FactoryBot.define do
  factory :academic_timeline, class: 'Academic::Engine::AcademicTimeline' do
    sequence(:name) { |n| "#{%w[Semester Quarter Trimester].sample} #{n} - #{Date.current.year}" }
    start_date { Faker::Date.between(from: Date.current, to: 3.months.from_now) }
    end_date { start_date + 3.months }
    type { :semester }

    trait :semester do
      name { "#{%w[Fall Spring Summer].sample} Semester #{Date.current.year}" }
      type { :semester }
      end_date { start_date + 4.months }
    end

    trait :quarter do
      name { "#{%w[Fall Winter Spring Summer].sample} Quarter #{Date.current.year}" }
      type { :quarter }
      end_date { start_date + 3.months }
    end

    trait :trimester do
      name { "#{%w[Fall Winter Spring].sample} Trimester #{Date.current.year}" }
      type { :trimester }
      end_date { start_date + 4.months }
    end

    trait :current do
      start_date { 1.month.ago }
      end_date { 2.months.from_now }
    end

    trait :past do
      start_date { Faker::Date.between(from: 1.year.ago, to: 6.months.ago) }
      end_date { start_date + 4.months }
    end

    trait :future do
      start_date { Faker::Date.between(from: 1.month.from_now, to: 6.months.from_now) }
      end_date { start_date + 4.months }
    end
  end
end
