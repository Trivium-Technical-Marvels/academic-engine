require 'rails_helper'

RSpec.describe Academic::Engine::Program, type: :model do
  subject(:program) { build(:program) }

  describe 'associations' do
    it { is_expected.to have_many(:program_offerings).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    context 'presence validations' do
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_presence_of(:code) }
      it { is_expected.to validate_presence_of(:duration) }
      it { is_expected.to validate_presence_of(:description) }
    end

    context 'uniqueness validations' do
      before { create(:program) }
      it { is_expected.to validate_uniqueness_of(:name) }
      it { is_expected.to validate_uniqueness_of(:code) }
    end

    context 'numericality validations' do
      it { is_expected.to validate_numericality_of(:duration).only_integer.is_greater_than(0) }
    end

    context 'length validations' do
      it { is_expected.to validate_length_of(:description).is_at_most(500) }
    end

    context 'edge cases for validations' do
      it 'allows duration of 1' do
        program = build(:program, duration: 1)
        expect(program).to be_valid
      end

      it 'does not allow duration of 0' do
        program = build(:program, duration: 0)
        expect(program).not_to be_valid
        expect(program.errors[:duration]).to include('must be greater than 0')
      end

      it 'does not allow negative duration' do
        program = build(:program, duration: -1)
        expect(program).not_to be_valid
        expect(program.errors[:duration]).to include('must be greater than 0')
      end

      it 'does not allow non-integer duration' do
        program = build(:program, duration: 1.5)
        expect(program).not_to be_valid
        expect(program.errors[:duration]).to include('must be an integer')
      end

      it 'allows description at maximum length' do
        program = build(:program, description: 'a' * 500)
        expect(program).to be_valid
      end

      it 'does not allow description over maximum length' do
        program = build(:program, description: 'a' * 501)
        expect(program).not_to be_valid
        expect(program.errors[:description]).to include('is too long (maximum is 500 characters)')
      end
    end
  end

  describe 'scopes' do
    describe '.active' do
      let!(:program_with_offerings) { create(:program, :with_offerings) }
      let!(:program_without_offerings) { create(:program) }

      it 'returns programs that have program offerings' do
        expect(described_class.active).to include(program_with_offerings)
        expect(described_class.active).not_to include(program_without_offerings)
      end
    end
  end

  describe 'class methods' do
    describe '.find_by_code' do
      let!(:program) { create(:program, code: 'CS101') }

      it 'finds program by code' do
        expect(described_class.find_by_code('CS101')).to eq(program)
      end

      it 'returns nil for non-existent code' do
        expect(described_class.find_by_code('NONEXISTENT')).to be_nil
      end

      it 'handles nil code gracefully' do
        expect(described_class.find_by_code(nil)).to be_nil
      end

      it 'handles empty string gracefully' do
        expect(described_class.find_by_code('')).to be_nil
      end

      it 'handles whitespace-only string gracefully' do
        expect(described_class.find_by_code('   ')).to be_nil
      end
    end

    describe '.find_by_name' do
      let!(:program) { create(:program, name: 'Computer Science') }

      it 'finds program by name' do
        expect(described_class.find_by_name('Computer Science')).to eq(program)
      end

      it 'returns nil for non-existent name' do
        expect(described_class.find_by_name('Non-existent Program')).to be_nil
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
  end

  describe 'instance methods' do
    describe '#active?' do
      context 'when program has program offerings' do
        let(:program) { create(:program, :with_offerings) }

        it 'returns true' do
          expect(program.active?).to be true
        end
      end

      context 'when program has no program offerings' do
        let(:program) { create(:program) }

        it 'returns false' do
          expect(program.active?).to be false
        end
      end

      context 'when program has program offerings but they are destroyed' do
        let(:program) { create(:program, :with_offerings) }

        it 'returns false after offerings are destroyed' do
          program.program_offerings.destroy_all
          expect(program.active?).to be false
        end
      end
    end

    describe '#duration_in_years' do
      it 'returns duration as ActiveSupport::Duration in years' do
        program = build(:program, duration: 4)
        expect(program.duration_in_years).to eq(4.years)
      end

      it 'handles single year duration' do
        program = build(:program, duration: 1)
        expect(program.duration_in_years).to eq(1.year)
      end

      it 'handles large duration values' do
        program = build(:program, duration: 10)
        expect(program.duration_in_years).to eq(10.years)
      end
    end
  end

  describe 'factory validations' do
    it 'creates valid program with factory' do
      program = build(:program)
      expect(program).to be_valid
    end

    it 'creates valid program with short duration trait' do
      program = build(:program, :short_duration)
      expect(program).to be_valid
      expect(program.duration).to eq(1)
    end

    it 'creates valid program with medium duration trait' do
      program = build(:program, :medium_duration)
      expect(program).to be_valid
      expect(program.duration).to eq(2)
    end

    it 'creates valid program with long duration trait' do
      program = build(:program, :long_duration)
      expect(program).to be_valid
      expect(program.duration).to be_in([3, 4])
    end
  end

  describe 'edge cases' do
    context 'when dealing with code formats' do
      it 'accepts various code formats' do
        valid_codes = ['CS101', 'MATH-200', 'ENG_300', 'PHY 400', 'BIO101A']
        valid_codes.each do |code|
          program = build(:program, code: code)
          expect(program).to be_valid, "Expected #{code} to be valid"
        end
      end
    end

    context 'when dealing with special characters in name' do
      it 'accepts names with special characters' do
        special_names = [
          'Computer Science & Engineering',
          'Mathematics - Applied',
          'English (Literature)',
          'Business Administration/Management'
        ]
        special_names.each do |name|
          program = build(:program, name: name)
          expect(program).to be_valid, "Expected '#{name}' to be valid"
        end
      end
    end

    context 'when dealing with very long names' do
      it 'accepts reasonable length names' do
        long_name = 'Bachelor of Science in Computer Science and Information Technology with Specialization in Artificial Intelligence'
        program = build(:program, name: long_name)
        expect(program).to be_valid
      end
    end

    context 'when dealing with unicode characters' do
      it 'accepts unicode characters in name and description' do
        program = build(:program, 
                       name: 'Ingénierie Informatique et Télécommunications',
                       description: 'Programme d\'études en français avec caractères spéciaux: àáâãäåæçèéêë')
        expect(program).to be_valid
      end
    end
  end

  describe 'database constraints' do
    context 'when creating duplicate names' do
      let!(:existing_program) { create(:program, name: 'Computer Science') }

      it 'raises validation error for duplicate name' do
        duplicate_program = build(:program, name: 'Computer Science')
        expect(duplicate_program).not_to be_valid
        expect(duplicate_program.errors[:name]).to include('has already been taken')
      end
    end

    context 'when creating duplicate codes' do
      let!(:existing_program) { create(:program, code: 'CS101') }

      it 'raises validation error for duplicate code' do
        duplicate_program = build(:program, code: 'CS101')
        expect(duplicate_program).not_to be_valid
        expect(duplicate_program.errors[:code]).to include('has already been taken')
      end
    end
  end

  describe 'association behavior' do
    context 'when trying to destroy program with offerings' do
      let(:program) { create(:program, :with_offerings) }

      it 'restricts destruction when program offerings exist' do
        expect { program.destroy! }.to raise_error(ActiveRecord::RecordNotDestroyed)
      end

      it 'allows destruction after removing program offerings' do
        program.program_offerings.destroy_all
        expect { program.destroy! }.not_to raise_error
      end
    end
  end
end
