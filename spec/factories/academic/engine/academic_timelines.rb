FactoryBot.define do
  factory :academic_timeline, class: 'Academic::Engine::AcademicTimeline' do

    name { Faker::Educator.course_name }
    start_date { Faker::Date.forward(days: 23) }
    end_date { start_date.end_of_year }
    timeline_type { %w[semester quarter].sample }
  end
end
