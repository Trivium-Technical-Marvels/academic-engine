require 'rails_helper'

RSpec.describe Academic::Engine::AcademicTimeline, type: :model do
  subject(:academic_timeline) { build(:academic_timeline) }

  describe 'associations' do
    it { is_expected.to have_many(:program_offerings).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    context 'presence validations' do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_presence_of(:start_date) }
      it { is_expected.to validate_presence_of(:end_date) }
    end

    context 'uniqueness validations' do
      before { create(:academic_timeline) }
      it { is_expected.to validate_uniqueness_of(:name) }
    end

    context 'length validations' do
      it { is_expected.to validate_length_of(:name).is_at_most(100) }
    end

    context 'date validations' do
      it 'validates end_date is on or after start_date' do
        timeline = build(:academic_timeline, start_date: Date.current, end_date: Date.current - 1.day)
        expect(timeline).not_to be_valid
        expect(timeline.errors[:end_date]).to include("must be after start date (#{Date.current})")
      end

      it 'validates start_date is on or before end_date' do
        timeline = build(:academic_timeline, start_date: Date.current + 1.day, end_date: Date.current)
        expect(timeline).not_to be_valid
        expect(timeline.errors[:start_date]).to include("must be before end date (#{Date.current})")
      end

      it 'allows same start_date and end_date' do
        timeline = build(:academic_timeline, start_date: Date.current, end_date: Date.current)
        expect(timeline).to be_valid
      end

      it 'allows end_date after start_date' do
        timeline = build(:academic_timeline, start_date: Date.current, end_date: Date.current + 1.month)
        expect(timeline).to be_valid
      end
    end

    context 'edge cases for validations' do
      it 'allows name at maximum length' do
        timeline = build(:academic_timeline, name: 'a' * 100)
        expect(timeline).to be_valid
      end

      it 'does not allow name over maximum length' do
        timeline = build(:academic_timeline, name: 'a' * 101)
        expect(timeline).not_to be_valid
        expect(timeline.errors[:name]).to include('is too long (maximum is 100 characters)')
      end

      it 'handles very long date ranges' do
        timeline = build(:academic_timeline, 
                        start_date: Date.current, 
                        end_date: Date.current + 5.years)
        expect(timeline).to be_valid
      end
    end
  end

  describe 'class methods' do
    describe '.find_by_name' do
      let!(:timeline) { create(:academic_timeline, name: 'Fall Semester 2025') }

      it 'finds timeline by name' do
        expect(described_class.find_by_name('Fall Semester 2025')).to eq(timeline)
      end

      it 'returns nil for non-existent name' do
        expect(described_class.find_by_name('Non-existent Timeline')).to be_nil
      end

      it 'handles nil name gracefully' do
        expect(described_class.find_by_name(nil)).to be_nil
      end

      it 'handles empty string gracefully' do
        expect(described_class.find_by_name('')).to be_nil
      end

      it 'handles whitespace-only string gracefully' do
        expect(described_class.find_by_name('   ')).to be_nil
      end
    end

    describe '.find_all_by_year' do
      let!(:timeline_2025) { create(:academic_timeline, start_date: Date.new(2025, 1, 1)) }
      let!(:timeline_2026) { create(:academic_timeline, start_date: Date.new(2026, 1, 1)) }
      let!(:timeline_2025_fall) { create(:academic_timeline, start_date: Date.new(2025, 9, 1)) }

      it 'finds all timelines by year' do
        results = described_class.find_all_by_year(2025)
        expect(results).to include(timeline_2025, timeline_2025_fall)
        expect(results).not_to include(timeline_2026)
      end

      it 'returns empty for year with no timelines' do
        results = described_class.find_all_by_year(2030)
        expect(results).to be_empty
      end

      it 'handles nil year gracefully' do
        results = described_class.find_all_by_year(nil)
        expect(results).to be_empty
      end

      it 'handles string year' do
        results = described_class.find_all_by_year('2025')
        expect(results).to include(timeline_2025, timeline_2025_fall)
      end

      it 'handles invalid year gracefully' do
        results = described_class.find_all_by_year('invalid')
        expect(results).to be_empty
      end
    end
  end

  describe 'instance methods' do
    describe '#active?' do
      it 'returns true when current date is between start_date and end_date' do
        timeline = build(:academic_timeline, 
                        start_date: 1.month.ago, 
                        end_date: 1.month.from_now)
        expect(timeline.active?).to be true
      end

      it 'returns false when current date is before start_date' do
        timeline = build(:academic_timeline, 
                        start_date: 1.month.from_now, 
                        end_date: 2.months.from_now)
        expect(timeline.active?).to be false
      end

      it 'returns false when current date is after end_date' do
        timeline = build(:academic_timeline, 
                        start_date: 2.months.ago, 
                        end_date: 1.month.ago)
        expect(timeline.active?).to be false
      end

      it 'returns true when current date equals start_date' do
        timeline = build(:academic_timeline, 
                        start_date: Date.current, 
                        end_date: 1.month.from_now)
        expect(timeline.active?).to be true
      end

      it 'returns true when current date equals end_date' do
        timeline = build(:academic_timeline, 
                        start_date: 1.month.ago, 
                        end_date: Date.current)
        expect(timeline.active?).to be true
      end
    end

    describe '#duration' do
      it 'returns duration between start_date and end_date in days' do
        timeline = build(:academic_timeline, 
                        start_date: Date.new(2025, 1, 1), 
                        end_date: Date.new(2025, 1, 31))
        expected_duration = ((Date.new(2025, 1, 31) - Date.new(2025, 1, 1)).to_i + 1).days
        expect(timeline.duration).to eq(expected_duration)
      end

      it 'returns 1 day for same start and end date' do
        timeline = build(:academic_timeline, 
                        start_date: Date.current, 
                        end_date: Date.current)
        expect(timeline.duration).to eq(1.day)
      end

      it 'handles long durations correctly' do
        timeline = build(:academic_timeline, 
                        start_date: Date.new(2025, 1, 1), 
                        end_date: Date.new(2025, 12, 31))
        expected_duration = ((Date.new(2025, 12, 31) - Date.new(2025, 1, 1)).to_i + 1).days
        expect(timeline.duration).to eq(expected_duration)
      end
    end

    describe '#days_left' do
      it 'returns days left from current date to end_date' do
        travel_to Date.new(2025, 6, 15) do
          timeline = build(:academic_timeline, 
                          start_date: Date.new(2025, 6, 1), 
                          end_date: Date.new(2025, 6, 30))
          expected_days = (Date.new(2025, 6, 30) - Date.new(2025, 6, 15)).to_i.days
          expect(timeline.days_left).to eq(expected_days)
        end
      end

      it 'returns negative days when end_date is in the past' do
        travel_to Date.new(2025, 7, 15) do
          timeline = build(:academic_timeline, 
                          start_date: Date.new(2025, 6, 1), 
                          end_date: Date.new(2025, 6, 30))
          expected_days = (Date.new(2025, 6, 30) - Date.new(2025, 7, 15)).to_i.days
          expect(timeline.days_left).to eq(expected_days)
        end
      end

      it 'returns 0 when current date equals end_date' do
        travel_to Date.new(2025, 6, 30) do
          timeline = build(:academic_timeline, 
                          start_date: Date.new(2025, 6, 1), 
                          end_date: Date.new(2025, 6, 30))
          expect(timeline.days_left).to eq(0.days)
        end
      end
    end

    describe '#days_till_start' do
      it 'returns days from current date to start_date' do
        travel_to Date.new(2025, 5, 15) do
          timeline = build(:academic_timeline, 
                          start_date: Date.new(2025, 6, 1), 
                          end_date: Date.new(2025, 6, 30))
          expected_days = (Date.new(2025, 6, 1) - Date.new(2025, 5, 15)).to_i
          expect(timeline.days_till_start).to eq(expected_days)
        end
      end

      it 'returns negative days when start_date is in the past' do
        travel_to Date.new(2025, 7, 15) do
          timeline = build(:academic_timeline, 
                          start_date: Date.new(2025, 6, 1), 
                          end_date: Date.new(2025, 6, 30))
          expected_days = (Date.new(2025, 6, 1) - Date.new(2025, 7, 15)).to_i
          expect(timeline.days_till_start).to eq(expected_days)
        end
      end

      it 'returns 0 when current date equals start_date' do
        travel_to Date.new(2025, 6, 1) do
          timeline = build(:academic_timeline, 
                          start_date: Date.new(2025, 6, 1), 
                          end_date: Date.new(2025, 6, 30))
          expect(timeline.days_till_start).to eq(0)
        end
      end
    end

    describe '#days_passed_since_start' do
      it 'returns days passed since start_date' do
        travel_to Date.new(2025, 6, 15) do
          timeline = build(:academic_timeline, 
                          start_date: Date.new(2025, 6, 1), 
                          end_date: Date.new(2025, 6, 30))
          expected_days = (Date.new(2025, 6, 15) - Date.new(2025, 6, 1)).to_i
          expect(timeline.days_passed_since_start).to eq(expected_days)
        end
      end

      it 'returns negative days when start_date is in the future' do
        travel_to Date.new(2025, 5, 15) do
          timeline = build(:academic_timeline, 
                          start_date: Date.new(2025, 6, 1), 
                          end_date: Date.new(2025, 6, 30))
          expected_days = (Date.new(2025, 5, 15) - Date.new(2025, 6, 1)).to_i
          expect(timeline.days_passed_since_start).to eq(expected_days)
        end
      end

      it 'returns 0 when current date equals start_date' do
        travel_to Date.new(2025, 6, 1) do
          timeline = build(:academic_timeline, 
                          start_date: Date.new(2025, 6, 1), 
                          end_date: Date.new(2025, 6, 30))
          expect(timeline.days_passed_since_start).to eq(0)
        end
      end
    end
  end

  describe 'factory validations' do
    it 'creates valid academic timeline with factory' do
      timeline = build(:academic_timeline)
      expect(timeline).to be_valid
    end

    it 'creates valid semester timeline' do
      timeline = build(:academic_timeline, :semester)
      expect(timeline).to be_valid
      expect(timeline.name).to include('Semester')
    end

    it 'creates valid quarter timeline' do
      timeline = build(:academic_timeline, :quarter)
      expect(timeline).to be_valid
      expect(timeline.name).to include('Quarter')
    end

    it 'creates valid current timeline' do
      timeline = build(:academic_timeline, :current)
      expect(timeline).to be_valid
      expect(timeline.active?).to be true
    end

    it 'creates valid past timeline' do
      timeline = build(:academic_timeline, :past)
      expect(timeline).to be_valid
      expect(timeline.active?).to be false
    end

    it 'creates valid future timeline' do
      timeline = build(:academic_timeline, :future)
      expect(timeline).to be_valid
      expect(timeline.active?).to be false
    end
  end

  describe 'edge cases' do
    context 'when dealing with special characters in name' do
      it 'accepts names with special characters' do
        special_names = [
          'Fall Semester 2025 - Main Campus',
          'Spring Quarter (Online)',
          'Summer Session I & II',
          'Winter Break/Holiday Period'
        ]
        special_names.each do |name|
          timeline = build(:academic_timeline, name: name)
          expect(timeline).to be_valid, "Expected '#{name}' to be valid"
        end
      end
    end

    context 'when dealing with unicode characters' do
      it 'accepts unicode characters in name' do
        timeline = build(:academic_timeline, 
                        name: 'Semestre d\'Automne 2025 - Université')
        expect(timeline).to be_valid
      end
    end

    context 'when dealing with year boundaries' do
      it 'handles timelines spanning multiple years' do
        timeline = build(:academic_timeline, 
                        start_date: Date.new(2025, 12, 1), 
                        end_date: Date.new(2026, 2, 28))
        expect(timeline).to be_valid
      end

      it 'handles timelines within leap years' do
        timeline = build(:academic_timeline, 
                        start_date: Date.new(2024, 2, 1), 
                        end_date: Date.new(2024, 2, 29))
        expect(timeline).to be_valid
        expect(timeline.duration).to eq(29.days)
      end
    end

    context 'when dealing with very short durations' do
      it 'handles single-day timelines' do
        timeline = build(:academic_timeline, 
                        start_date: Date.current, 
                        end_date: Date.current)
        expect(timeline).to be_valid
        expect(timeline.duration).to eq(1.day)
      end
    end

    context 'when dealing with very long durations' do
      it 'handles multi-year timelines' do
        timeline = build(:academic_timeline, 
                        start_date: Date.new(2025, 1, 1), 
                        end_date: Date.new(2029, 12, 31))
        expect(timeline).to be_valid
        expect(timeline.duration).to be > 1000.days
      end
    end
  end

  describe 'database constraints' do
    context 'when creating duplicate names' do
      let!(:existing_timeline) { create(:academic_timeline, name: 'Fall Semester 2025') }

      it 'raises validation error for duplicate name' do
        duplicate_timeline = build(:academic_timeline, name: 'Fall Semester 2025')
        expect(duplicate_timeline).not_to be_valid
        expect(duplicate_timeline.errors[:name]).to include('has already been taken')
      end
    end
  end

  describe 'association behavior' do
    context 'when trying to destroy timeline with offerings' do
      let(:timeline) { create(:academic_timeline) }
      let!(:offering) { create(:program_offering, academic_timeline: timeline) }

      it 'restricts destruction when program offerings exist' do
        expect { timeline.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
      end

      it 'allows destruction after removing program offerings' do
        offering.destroy
        expect { timeline.destroy! }.not_to raise_error
      end
    end
  end

  describe 'date calculation accuracy' do
    context 'when dealing with time zones' do
      it 'uses date calculations consistently regardless of time zone' do
        timeline = build(:academic_timeline, 
                        start_date: Date.new(2025, 6, 1), 
                        end_date: Date.new(2025, 6, 30))
        
        # Test in different time zones
        Time.use_zone('UTC') do
          duration_utc = timeline.duration
          Time.use_zone('America/New_York') do
            duration_est = timeline.duration
            expect(duration_utc).to eq(duration_est)
          end
        end
      end
    end
  end
end
