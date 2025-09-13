require 'rails_helper'

RSpec.describe Academic::Engine::ProgramOffering, type: :model do
  subject(:program_offering) { build(:program_offering) }

  describe 'associations' do
    it { is_expected.to belong_to(:program) }
    it { is_expected.to belong_to(:intake) }
    it { is_expected.to belong_to(:academic_timeline) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:mode).with_values(full_time: 0, part_time: 1, extension: 2, online: 3) }
  end

  describe 'validations' do
    context 'presence validations' do
      it { is_expected.to validate_presence_of(:mode) }
      it { is_expected.to validate_presence_of(:program) }
      it { is_expected.to validate_presence_of(:intake) }
      it { is_expected.to validate_presence_of(:academic_timeline) }
    end

    context 'uniqueness validations' do
      let!(:existing_offering) { create(:program_offering) }

      it 'validates uniqueness of program scoped to intake' do
        duplicate_offering = build(:program_offering, 
                                  program: existing_offering.program, 
                                  intake: existing_offering.intake)
        expect(duplicate_offering).not_to be_valid
        expect(duplicate_offering.errors[:program]).to include('has already been taken')
      end

      it 'validates uniqueness of intake scoped to academic_timeline' do
        duplicate_offering = build(:program_offering,
                                  intake: existing_offering.intake,
                                  academic_timeline: existing_offering.academic_timeline)
        expect(duplicate_offering).not_to be_valid
        expect(duplicate_offering.errors[:intake]).to include('has already been taken')
      end

      it 'allows same program with different intake' do
        different_intake_offering = build(:program_offering,
                                         program: existing_offering.program,
                                         intake: create(:intake))
        expect(different_intake_offering).to be_valid
      end

      it 'allows same intake with different academic_timeline' do
        different_timeline_offering = build(:program_offering,
                                           intake: existing_offering.intake,
                                           academic_timeline: create(:academic_timeline))
        expect(different_timeline_offering).to be_valid
      end
    end
  end

  describe 'scopes' do
    let!(:full_time_offering) { create(:program_offering, :full_time) }
    let!(:part_time_offering) { create(:program_offering, :part_time) }
    let!(:extension_offering) { create(:program_offering, :extension) }
    let!(:online_offering) { create(:program_offering, :online) }
    let!(:current_offering) { create(:program_offering, :current) }

    describe '.full_time' do
      it 'returns only full-time offerings' do
        expect(described_class.full_time).to include(full_time_offering)
        expect(described_class.full_time).not_to include(part_time_offering, extension_offering, online_offering)
      end
    end

    describe '.part_time' do
      it 'returns only part-time offerings' do
        expect(described_class.part_time).to include(part_time_offering)
        expect(described_class.part_time).not_to include(full_time_offering, extension_offering, online_offering)
      end
    end

    describe '.extension' do
      it 'returns only extension offerings' do
        expect(described_class.extension).to include(extension_offering)
        expect(described_class.extension).not_to include(full_time_offering, part_time_offering, online_offering)
      end
    end

    describe '.online' do
      it 'returns only online offerings' do
        expect(described_class.online).to include(online_offering)
        expect(described_class.online).not_to include(full_time_offering, part_time_offering, extension_offering)
      end
    end

    describe '.current' do
      it 'returns offerings with current intakes' do
        expect(described_class.current).to include(current_offering)
      end
    end
  end

  describe 'class methods' do
    let!(:program) { create(:program) }
    let!(:intake) { create(:intake) }
    let!(:academic_timeline) { create(:academic_timeline) }
    let!(:offering) { create(:program_offering, program: program, intake: intake, academic_timeline: academic_timeline) }

    describe '.find_by_program_and_intake' do
      it 'finds offering by program and intake' do
        result = described_class.find_by_program_and_intake(program, intake)
        expect(result).to eq(offering)
      end

      it 'returns nil when no matching offering exists' do
        other_program = create(:program)
        result = described_class.find_by_program_and_intake(other_program, intake)
        expect(result).to be_nil
      end

      it 'handles nil program gracefully' do
        result = described_class.find_by_program_and_intake(nil, intake)
        expect(result).to be_nil
      end

      it 'handles nil intake gracefully' do
        result = described_class.find_by_program_and_intake(program, nil)
        expect(result).to be_nil
      end
    end

    describe '.find_all_by_program_and_academic_timeline' do
      let!(:another_offering) { create(:program_offering, program: program, academic_timeline: academic_timeline) }

      it 'finds all offerings by program and academic timeline' do
        results = described_class.find_all_by_program_and_academic_timeline(program, academic_timeline)
        expect(results).to include(offering, another_offering)
      end

      it 'returns empty when no matching offerings exist' do
        other_program = create(:program)
        results = described_class.find_all_by_program_and_academic_timeline(other_program, academic_timeline)
        expect(results).to be_empty
      end

      it 'handles nil program gracefully' do
        results = described_class.find_all_by_program_and_academic_timeline(nil, academic_timeline)
        expect(results).to be_empty
      end

      it 'handles nil academic_timeline gracefully' do
        results = described_class.find_all_by_program_and_academic_timeline(program, nil)
        expect(results).to be_empty
      end
    end

    describe '.find_by_mode_and_program' do
      let!(:test_program) { create(:program) }
      let!(:full_time_offering) { create(:program_offering, :full_time, program: test_program) }
      let!(:different_program) { create(:program) }

      it 'finds offering by mode and program' do
        result = described_class.find_by_mode_and_program(:full_time, test_program)
        expect(result).to eq(full_time_offering)
      end

      it 'returns nil when no matching offering exists' do
        result = described_class.find_by_mode_and_program(:part_time, different_program)
        expect(result).to be_nil
      end

      it 'handles nil mode gracefully' do
        result = described_class.find_by_mode_and_program(nil, program)
        expect(result).to be_nil
      end

      it 'handles nil program gracefully' do
        result = described_class.find_by_mode_and_program(:full_time, nil)
        expect(result).to be_nil
      end
    end

    describe '.find_all_by_academic_timeline' do
      let!(:another_offering) { create(:program_offering, academic_timeline: academic_timeline) }

      it 'finds all offerings by academic timeline' do
        results = described_class.find_all_by_academic_timeline(academic_timeline)
        expect(results).to include(offering, another_offering)
      end

      it 'returns empty when no matching offerings exist' do
        other_timeline = create(:academic_timeline)
        results = described_class.find_all_by_academic_timeline(other_timeline)
        expect(results).to be_empty
      end

      it 'handles nil academic_timeline gracefully' do
        results = described_class.find_all_by_academic_timeline(nil)
        expect(results).to be_empty
      end
    end

    describe '.find_all_by_intake' do
      let!(:another_offering) { create(:program_offering, intake: intake) }

      it 'finds all offerings by intake' do
        results = described_class.find_all_by_intake(intake)
        expect(results).to include(offering, another_offering)
      end

      it 'returns empty when no matching offerings exist' do
        other_intake = create(:intake)
        results = described_class.find_all_by_intake(other_intake)
        expect(results).to be_empty
      end

      it 'handles nil intake gracefully' do
        results = described_class.find_all_by_intake(nil)
        expect(results).to be_empty
      end
    end

    describe '.find_all_by_program' do
      let!(:another_offering) { create(:program_offering, program: program) }

      it 'finds all offerings by program' do
        results = described_class.find_all_by_program(program)
        expect(results).to include(offering, another_offering)
      end

      it 'returns empty when no matching offerings exist' do
        other_program = create(:program)
        results = described_class.find_all_by_program(other_program)
        expect(results).to be_empty
      end

      it 'handles nil program gracefully' do
        results = described_class.find_all_by_program(nil)
        expect(results).to be_empty
      end
    end
  end

  describe 'delegations' do
    let(:intake) { create(:intake, name: 'Fall 2025', admission_type: :fall, start_date: Date.new(2025, 9, 1)) }
    let(:program) { create(:program, name: 'Computer Science', code: 'CS101', duration: 4, description: 'CS Program') }
    let(:academic_timeline) { create(:academic_timeline, name: 'Fall Semester 2025') }
    let(:offering) { create(:program_offering, intake: intake, program: program, academic_timeline: academic_timeline) }

    describe 'intake delegations' do
      it 'delegates intake_name to intake' do
        expect(offering.intake_name).to eq('Fall 2025')
      end

      it 'delegates intake_admission_type to intake' do
        expect(offering.intake_admission_type).to eq('fall')
      end

      it 'delegates intake_start_date to intake' do
        expect(offering.intake_start_date).to eq(Date.new(2025, 9, 1))
      end

      it 'delegates intake_end_date to intake' do
        expect(offering.intake_end_date).to eq(Date.new(2025, 12, 31))
      end

      it 'delegates intake_active? to intake' do
        expect(offering).to respond_to(:intake_active?)
      end
    end

    describe 'program delegations' do
      it 'delegates program_name to program' do
        expect(offering.program_name).to eq('Computer Science')
      end

      it 'delegates program_code to program' do
        expect(offering.program_code).to eq('CS101')
      end

      it 'delegates program_duration to program' do
        expect(offering.program_duration).to eq(4)
      end

      it 'delegates program_description to program' do
        expect(offering.program_description).to eq('CS Program')
      end
    end

    describe 'academic timeline delegations' do
      it 'delegates timeline to academic_timeline' do
        expect(offering.timeline).to eq('Fall Semester 2025')
      end
    end
  end

  describe 'factory validations' do
    it 'creates valid program offering with factory' do
      offering = build(:program_offering)
      expect(offering).to be_valid
    end

    it 'creates valid full-time offering' do
      offering = build(:program_offering, :full_time)
      expect(offering).to be_valid
      expect(offering.mode).to eq('full_time')
    end

    it 'creates valid part-time offering' do
      offering = build(:program_offering, :part_time)
      expect(offering).to be_valid
      expect(offering.mode).to eq('part_time')
    end

    it 'creates valid extension offering' do
      offering = build(:program_offering, :extension)
      expect(offering).to be_valid
      expect(offering.mode).to eq('extension')
    end

    it 'creates valid online offering' do
      offering = build(:program_offering, :online)
      expect(offering).to be_valid
      expect(offering.mode).to eq('online')
    end

    it 'creates valid current offering' do
      offering = build(:program_offering, :current)
      expect(offering).to be_valid
    end

    it 'creates valid offering with spring intake' do
      offering = build(:program_offering, :with_spring_intake)
      expect(offering).to be_valid
      expect(offering.intake.admission_type).to eq('spring')
    end

    it 'creates valid offering with fall intake' do
      offering = build(:program_offering, :with_fall_intake)
      expect(offering).to be_valid
      expect(offering.intake.admission_type).to eq('fall')
    end
  end

  describe 'edge cases' do
    context 'when associations are destroyed' do
      let(:offering) { create(:program_offering) }

      it 'prevents program deletion when offering exists' do
        program = offering.program
        expect(program.program_offerings.count).to eq(1)
        expect { program.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
        expect(offering.reload).to be_present
      end

      it 'prevents intake deletion when offering exists' do
        intake = offering.intake
        expect(intake.program_offerings.count).to eq(1)
        expect { intake.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
        expect(offering.reload).to be_present
      end

      it 'prevents academic_timeline deletion when offering exists' do
        timeline = offering.academic_timeline
        expect(timeline.program_offerings.count).to eq(1)
        expect { timeline.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
        expect(offering.reload).to be_present
      end
    end

    context 'when dealing with enum edge cases' do
      it 'handles string mode assignment' do
        offering = build(:program_offering, mode: 'full_time')
        expect(offering).to be_valid
        expect(offering.mode).to eq('full_time')
      end

      it 'handles integer mode assignment' do
        offering = build(:program_offering, mode: 0)
        expect(offering).to be_valid
        expect(offering.mode).to eq('full_time')
      end

      it 'rejects invalid mode values' do
        expect { build(:program_offering, mode: 'invalid_mode') }.to raise_error(ArgumentError)
      end
    end

    context 'when dealing with complex uniqueness scenarios' do
      let!(:program1) { create(:program) }
      let!(:program2) { create(:program) }
      let!(:intake1) { create(:intake) }
      let!(:intake2) { create(:intake) }
      let!(:timeline1) { create(:academic_timeline) }
      let!(:timeline2) { create(:academic_timeline) }

      it 'allows multiple offerings with different combinations' do
        offering1 = create(:program_offering, program: program1, intake: intake1, academic_timeline: timeline1)
        offering2 = create(:program_offering, program: program2, intake: intake2, academic_timeline: timeline2)
        
        expect(offering1).to be_valid
        expect(offering2).to be_valid
      end

      it 'allows same program and timeline with different intakes' do
        offering1 = create(:program_offering, program: program1, intake: intake1, academic_timeline: timeline1)
        offering2 = create(:program_offering, program: program1, intake: intake2, academic_timeline: timeline1)
        
        expect(offering1).to be_valid
        expect(offering2).to be_valid
      end
    end
  end

  describe 'database constraints and cascading' do
    context 'when parent records have dependent restrictions' do
      let(:offering) { create(:program_offering) }

      it 'prevents program deletion when offering exists' do
        expect { offering.program.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
      end

      it 'prevents intake deletion when offering exists' do
        expect { offering.intake.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
      end

      it 'prevents academic_timeline deletion when offering exists' do
        expect { offering.academic_timeline.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
      end
    end
  end
end
