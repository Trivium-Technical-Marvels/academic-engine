require 'rails_helper'

RSpec.describe Academic::Engine::Intake, type: :model do
  subject(:intake) { build(:intake) }

  describe 'associations' do
    it { is_expected.to have_many(:program_offerings).dependent(:restrict_with_error) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:admission_type).with_values(spring: 0, fall: 1) }
  end

  describe 'validations' do
    context 'presence validations' do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_presence_of(:admission_type) }
      it { is_expected.to validate_presence_of(:start_date) }
    end

    context 'uniqueness validations' do
      before { create(:intake) }

      it { is_expected.to validate_uniqueness_of(:name) }
    end


    context 'date validations' do
      it 'validates start_date is on or before end of current year' do
        intake = build(:intake, start_date: Date.current.next_year.beginning_of_year)
        expect(intake).not_to be_valid
        expect(intake.errors[:start_date]).to include('must be on or before Dec 31, 2025')
      end

      it 'validates end_date is on or after start_date' do
        intake = build(:intake, start_date: Date.current, end_date: Date.current - 1.day)
        expect(intake).not_to be_valid
        expect(intake.errors[:end_date]).to include('must be on or after start date')
      end

      it 'validates end_date is on or before end of current year' do
        intake = build(:intake, end_date: Date.current.next_year.beginning_of_year)
        expect(intake).not_to be_valid
        expect(intake.errors[:end_date]).to include('must be on or before Dec 31, 2025')
      end
    end
  end

  describe 'scopes' do
    describe '.current' do
      let!(:current_intake) { create(:intake, start_date: Date.current) }
      let!(:past_intake) { create(:intake, start_date: 1.year.ago, end_date: 1.year.ago.end_of_year) }
      let!(:future_intake) do
        intake = build(:intake, start_date: Date.current.next_year, end_date: Date.current.next_year.end_of_year)
        intake.save(validate: false)
        intake
      end

      it 'returns intakes with start_date in current year' do
        expect(described_class.current).to include(current_intake)
        expect(described_class.current).not_to include(past_intake, future_intake)
      end
    end
  end

  describe 'class methods' do
    describe '.find_by_name' do
      let!(:intake) { create(:intake, name: 'Fall 2025 Intake') }

      it 'finds intake by name' do
        expect(described_class.find_by_name('Fall 2025 Intake')).to eq(intake)
      end

      it 'returns nil for non-existent name' do
        expect(described_class.find_by_name('Non-existent')).to be_nil
      end

      it 'handles nil name gracefully' do
        expect(described_class.find_by_name(nil)).to be_nil
      end

      it 'handles empty string gracefully' do
        expect(described_class.find_by_name('')).to be_nil
      end
    end

    describe '.find_all_by_admission_type' do
      let!(:spring_intake) { create(:intake, :spring) }
      let!(:fall_intake) { create(:intake, :fall) }

      it 'finds all intakes by admission type' do
        spring_intakes = described_class.find_all_by_admission_type(:spring)
        expect(spring_intakes).to include(spring_intake)
        expect(spring_intakes).not_to include(fall_intake)
      end

      it 'handles nil admission type gracefully' do
        expect(described_class.find_all_by_admission_type(nil)).to be_empty
      end
    end

    describe '.next_fall' do
      let!(:future_fall_1) { create(:intake, :fall, start_date: 2.months.from_now) }
      let!(:future_fall_2) { create(:intake, :fall, start_date: 3.months.from_now) }
      let!(:spring_intake) { create(:intake, :spring) }

      it 'returns the next fall intake ordered by start_date' do
        expect(described_class.next_fall).to eq(future_fall_1)
      end

      it 'returns nil when no fall intakes exist' do
        described_class.where(admission_type: :fall).delete_all
        expect(described_class.next_fall).to be_nil
      end
    end

    describe '.next_spring' do
      let!(:future_spring_1) { create(:intake, :spring, start_date: 2.months.from_now) }
      let!(:future_spring_2) { create(:intake, :spring, start_date: 3.months.from_now) }
      let!(:fall_intake) { create(:intake, :fall) }

      it 'returns the next spring intake ordered by start_date' do
        expect(described_class.next_spring).to eq(future_spring_1)
      end

      it 'returns nil when no spring intakes exist' do
        described_class.where(admission_type: :spring).delete_all
        expect(described_class.next_spring).to be_nil
      end
    end

    describe '.next_intake' do
      context 'when both fall and spring intakes exist' do
        let!(:next_fall) { create(:intake, :fall, start_date: 3.months.from_now) }
        let!(:next_spring) { create(:intake, :spring, start_date: 2.months.from_now) }

        it 'returns the next fall intake if it exists' do
          expect(described_class.next_intake).to eq(next_fall)
        end
      end

      context 'when only spring intake exists' do
        let!(:next_spring) { create(:intake, :spring, start_date: 2.months.from_now) }

        it 'returns the next spring intake' do
          expect(described_class.next_intake).to eq(next_spring)
        end
      end

      context 'when no future intakes exist' do
        it 'returns nil' do
          expect(described_class.next_intake).to be_nil
        end
      end
    end

    describe '.previous_fall' do
      let!(:past_fall_1) { create(:intake, :fall, start_date: 2.months.ago) }
      let!(:past_fall_2) { create(:intake, :fall, start_date: 4.months.ago) }

      it 'returns the most recent fall intake' do
        expect(described_class.previous_fall).to eq(past_fall_1)
      end
    end

    describe '.previous_spring' do
      let!(:past_spring_1) { create(:intake, :spring, start_date: 2.months.ago) }
      let!(:past_spring_2) { create(:intake, :spring, start_date: 4.months.ago) }

      it 'returns the most recent spring intake' do
        expect(described_class.previous_spring).to eq(past_spring_1)
      end
    end
  end

  describe 'instance methods' do
    describe '#active?' do
      it 'returns true when current date is between start_date and end of year' do
        intake = build(:intake, start_date: 1.month.ago)
        expect(intake.active?).to be true
      end

      it 'returns false when current date is before start_date' do
        intake = build(:intake, start_date: 1.month.from_now)
        expect(intake.active?).to be false
      end

      it 'returns false when current date is after end of year' do
        travel_to Date.new(2026, 1, 1) do
          intake = build(:intake, start_date: Date.new(2025, 6, 1))
          expect(intake.active?).to be false
        end
      end
    end

    describe '#duration' do
      it 'returns duration from start_date to end of year in days' do
        intake = build(:intake, start_date: Date.new(2025, 6, 1))
        expected_duration = (Date.new(2025, 12, 31) - Date.new(2025, 6, 1)).to_i.days
        expect(intake.duration).to eq(expected_duration)
      end
    end

    describe '#days_left' do
      it 'returns days left from current date to end of year' do
        travel_to Date.new(2025, 6, 15) do
          intake = build(:intake, start_date: Date.new(2025, 6, 1))
          expected_days = (Date.new(2025, 12, 31) - Date.new(2025, 6, 15)).to_i.days
          expect(intake.days_left).to eq(expected_days)
        end
      end
    end

    describe '#days_till_start' do
      it 'returns days from current date to start_date' do
        travel_to Date.new(2025, 5, 1) do
          intake = build(:intake, start_date: Date.new(2025, 6, 1))
          expected_days = (Date.new(2025, 6, 1) - Date.new(2025, 5, 1)).to_i.days
          expect(intake.days_till_start).to eq(expected_days)
        end
      end

      it 'returns negative days when start_date is in the past' do
        travel_to Date.new(2025, 7, 1) do
          intake = build(:intake, start_date: Date.new(2025, 6, 1))
          expected_days = (Date.new(2025, 6, 1) - Date.new(2025, 7, 1)).to_i.days
          expect(intake.days_till_start).to eq(expected_days)
        end
      end
    end

    describe '#days_passed_since_start' do
      it 'returns days passed since start_date' do
        travel_to Date.new(2025, 7, 1) do
          intake = build(:intake, start_date: Date.new(2025, 6, 1))
          expected_days = (Date.new(2025, 7, 1) - Date.new(2025, 6, 1)).to_i.days
          expect(intake.days_passed_since_start).to eq(expected_days)
        end
      end

      it 'returns negative days when start_date is in the future' do
        travel_to Date.new(2025, 5, 1) do
          intake = build(:intake, start_date: Date.new(2025, 6, 1))
          expected_days = (Date.new(2025, 5, 1) - Date.new(2025, 6, 1)).to_i.days
          expect(intake.days_passed_since_start).to eq(expected_days)
        end
      end
    end

    describe '#end_date' do
      it 'returns end of year for start_date' do
        intake = build(:intake, start_date: Date.new(2025, 6, 1))
        expect(intake.end_date).to eq(Date.new(2025, 12, 31))
      end
    end

    describe '#next_intake' do
      let!(:current_intake) { create(:intake, start_date: Date.current) }
      let!(:future_intake) { create(:intake, start_date: 2.months.from_now) }
      let!(:past_intake) { create(:intake, start_date: 2.months.ago) }

      it 'returns the next intake after current intake' do
        expect(current_intake.next_intake).to eq(future_intake)
      end

      it 'returns nil when no future intakes exist' do
        expect(future_intake.next_intake).to be_nil
      end
    end

    describe '#previous_intake' do
      let!(:current_intake) { create(:intake, start_date: Date.current) }
      let!(:future_intake) { create(:intake, start_date: 2.months.from_now) }
      let!(:past_intake) { create(:intake, start_date: 2.months.ago) }

      it 'returns the previous intake before current intake' do
        expect(current_intake.previous_intake).to eq(past_intake)
      end

      it 'returns nil when no previous intakes exist' do
        expect(past_intake.previous_intake).to be_nil
      end
    end

    describe '#next_intake?' do
      let!(:current_intake) { create(:intake, start_date: Date.current) }
      let!(:future_intake) { create(:intake, start_date: 2.months.from_now) }

      it 'returns true when next intake exists' do
        expect(current_intake.next_intake?).to be true
      end

      it 'returns false when no next intake exists' do
        expect(future_intake.next_intake?).to be false
      end
    end

    describe '#previous_intake?' do
      let!(:current_intake) { create(:intake, start_date: Date.current) }
      let!(:past_intake) { create(:intake, start_date: 2.months.ago) }

      it 'returns true when previous intake exists' do
        expect(current_intake.previous_intake?).to be true
      end

      it 'returns false when no previous intake exists' do
        expect(past_intake.previous_intake?).to be false
      end
    end
  end

  describe 'edge cases' do
    context 'when dealing with year boundaries' do
      it 'handles intakes starting at beginning of year' do
        intake = build(:intake, start_date: Date.current.beginning_of_year)
        expect(intake).to be_valid
        expect(intake.end_date).to eq(Date.current.end_of_year)
      end

      it 'handles intakes starting at end of year' do
        intake = build(:intake, start_date: Date.current.end_of_year)
        expect(intake).to be_valid
        expect(intake.duration).to eq(0.days)
      end
    end

    context 'when dealing with leap years' do
      it 'handles leap year calculations correctly' do
        travel_to Date.new(2024, 2, 29) do # Leap year
          intake = build(:intake, start_date: Date.current)
          expect(intake.end_date).to eq(Date.new(2024, 12, 31))
        end
      end
    end
  end
end
